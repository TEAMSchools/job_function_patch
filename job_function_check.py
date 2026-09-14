"""Run the job function check query and alert two people in a Slack channel.

Reads function_check.sql, runs it against BigQuery, and if any staff rows come
back, posts a summary to the configured channel that @-mentions the two
recipients, with the offending rows as replies in that message's thread.

Results contain staff-identifiable data (name, employee number, worker ID).
Nothing is written to disk, and stdout shows only a count unless --dry-run
is passed.
"""

import argparse
import os
import sys
from dataclasses import dataclass
from datetime import date
from pathlib import Path

from dotenv import load_dotenv
from google.cloud import bigquery
from google.oauth2 import service_account
from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError

REPO_ROOT = Path(__file__).parent
DEFAULT_SQL_PATH = REPO_ROOT / "function_check.sql"

# Slack caps a message at 4000 characters. Leave headroom for the chunk header.
MAX_REPLY_CHARS = 2800

# Guard against a runaway result set flooding the channel thread.
MAX_ROWS_IN_THREAD = 200

REQUIRED_BIGQUERY_VARS = ("GOOGLE_APPLICATION_CREDENTIALS", "BIGQUERY_PROJECT_ID")
REQUIRED_SLACK_VARS = (
    "SLACK_BOT_TOKEN",
    "SLACK_ALERT_CHANNEL",
    "SLACK_ALERT_RECIPIENTS",
)

# Scopes the bot token needs to post into the channel and @-mention people.
# users:read.email is only needed when recipients are listed by email.
EXPECTED_SCOPES = ("chat:write", "users:read", "users:read.email")


@dataclass(frozen=True)
class BigQueryConfig:
    credentials_path: Path
    project_id: str


@dataclass(frozen=True)
class SlackConfig:
    token: str
    channel: str
    recipients: list[str]


@dataclass(frozen=True)
class StaffIssue:
    employee_number: str
    worker_id: str
    formatted_name: str
    text: str

    def to_line(self) -> str:
        return f"• *{self.formatted_name}* (emp #{self.employee_number}) — {self.text}"


def require_env(names: tuple[str, ...]) -> None:
    """Exit with a readable message if any of the named variables are unset."""
    load_dotenv(REPO_ROOT / ".env")

    missing = [name for name in names if not os.environ.get(name)]
    if missing:
        sys.exit(
            "Missing required environment variable(s): "
            + ", ".join(missing)
            + f"\nSet them in {REPO_ROOT / '.env'} (see the README for what each one is)."
        )


def load_bigquery_config() -> BigQueryConfig:
    require_env(REQUIRED_BIGQUERY_VARS)

    credentials_path = Path(os.environ["GOOGLE_APPLICATION_CREDENTIALS"])
    if not credentials_path.exists():
        sys.exit(f"BigQuery credentials file not found: {credentials_path}")

    return BigQueryConfig(
        credentials_path=credentials_path,
        project_id=os.environ["BIGQUERY_PROJECT_ID"],
    )


def load_slack_config() -> SlackConfig:
    require_env(REQUIRED_SLACK_VARS)

    recipients = [
        entry.strip()
        for entry in os.environ["SLACK_ALERT_RECIPIENTS"].split(",")
        if entry.strip()
    ]
    if len(recipients) < 2:
        sys.exit(
            "SLACK_ALERT_RECIPIENTS must list at least two comma-separated "
            "Slack user IDs or emails."
        )

    return SlackConfig(
        token=os.environ["SLACK_BOT_TOKEN"],
        channel=os.environ["SLACK_ALERT_CHANNEL"],
        recipients=recipients,
    )


def run_query(config: BigQueryConfig, sql_path: Path) -> list[StaffIssue]:
    """Execute the saved SQL and return one StaffIssue per offending row."""
    if not sql_path.exists():
        sys.exit(f"Query file not found: {sql_path}")

    client = bigquery.Client(
        project=config.project_id,
        credentials=service_account.Credentials.from_service_account_file(
            str(config.credentials_path)
        ),
    )

    rows = client.query(sql_path.read_text(encoding="utf-8")).result()
    return [
        StaffIssue(
            employee_number=str(row["employee_number"] or "unknown"),
            worker_id=str(row["worker_id"] or "unknown"),
            formatted_name=str(row["formatted_name"] or "unknown"),
            text=str(row["text"] or ""),
        )
        for row in rows
    ]


def resolve_user_ids(client: WebClient, recipients: list[str]) -> list[str]:
    """Turn a mixed list of emails and Slack user IDs into Slack user IDs."""
    user_ids = []
    for entry in recipients:
        if "@" not in entry:
            user_ids.append(entry)
            continue
        try:
            response = client.users_lookupByEmail(email=entry)
        except SlackApiError as error:
            sys.exit(f"Could not find a Slack user for {entry}: {error.response['error']}")
        user_ids.append(response["user"]["id"])
    return user_ids


def build_reply_chunks(issues: list[StaffIssue]) -> list[str]:
    """Group detail lines into message-sized chunks that fit Slack's limits."""
    chunks: list[str] = []
    current: list[str] = []
    current_length = 0

    for issue in issues[:MAX_ROWS_IN_THREAD]:
        line = issue.to_line()
        if current and current_length + len(line) > MAX_REPLY_CHARS:
            chunks.append("\n".join(current))
            current = []
            current_length = 0
        current.append(line)
        current_length += len(line) + 1

    if current:
        chunks.append("\n".join(current))

    if len(issues) > MAX_ROWS_IN_THREAD:
        chunks.append(
            f"_...and {len(issues) - MAX_ROWS_IN_THREAD} more. "
            "Run the query directly to see the full list._"
        )

    return chunks


def post_message(client: WebClient, channel: str, text: str, thread_ts: str | None = None):
    """Post to the alert channel, explaining the usual failures instead of stack-tracing."""
    try:
        return client.chat_postMessage(channel=channel, text=text, thread_ts=thread_ts)
    except SlackApiError as error:
        reason = error.response["error"]
        hints = {
            "not_in_channel": "Invite the bot to the channel: /invite @YourBotName",
            "channel_not_found": (
                "Check SLACK_ALERT_CHANNEL. Use the channel ID (C...) rather than "
                "the #name, and for a private channel the bot must be invited first."
            ),
            "missing_scope": "The bot token is missing chat:write.",
        }
        sys.exit(
            f"Could not post to {channel}: {reason}"
            + (f"\n{hints[reason]}" if reason in hints else "")
        )


def build_mentions(client: WebClient, recipients: list[str]) -> str:
    """Render the recipients as Slack mentions so both people get pinged."""
    return " ".join(f"<@{user_id}>" for user_id in resolve_user_ids(client, recipients))


def send_alert(config: SlackConfig, issues: list[StaffIssue]) -> None:
    """Post a summary to the alert channel, with the detail rows in its thread."""
    client = WebClient(token=config.token)
    mentions = build_mentions(client, config.recipients)
    today = date.today().strftime("%b %d, %Y")

    if not issues:
        post_message(
            client,
            config.channel,
            f":white_check_mark: Job function check — {today}. No issues found.",
        )
        return

    summary = post_message(
        client,
        config.channel,
        f"{mentions} :rotating_light: Job function check — {today}: "
        f"*{len(issues)} issue(s)* found. Details in thread.",
    )

    for chunk in build_reply_chunks(issues):
        post_message(client, config.channel, chunk, thread_ts=summary["ts"])


def granted_scopes(response) -> list[str]:
    """Pull the token's granted scopes out of an API response's headers."""
    header = response.headers.get("x-oauth-scopes")
    if not header:
        return []
    raw = header[0] if isinstance(header, list) else header
    return [scope.strip() for scope in raw.split(",") if scope.strip()]


def test_slack(config: SlackConfig, post_test_message: bool) -> None:
    """Check the Slack token, scopes, recipients, and channel without running the query."""
    client = WebClient(token=config.token)

    try:
        auth = client.auth_test()
    except SlackApiError as error:
        sys.exit(
            f"Slack token rejected: {error.response['error']}\n"
            "Check that SLACK_BOT_TOKEN is the bot token (starts with xoxb-) "
            "and that the app is still installed in the workspace."
        )

    print(f"Token OK. Bot '{auth['user']}' in workspace '{auth['team']}'.")

    scopes = granted_scopes(auth)
    if scopes:
        for scope in EXPECTED_SCOPES:
            mark = "ok     " if scope in scopes else "MISSING"
            print(f"  [{mark}] {scope}")
    else:
        print("  (could not read granted scopes from the response headers)")

    print(f"Resolving {len(config.recipients)} recipient(s):")
    user_ids = resolve_user_ids(client, config.recipients)
    for entry, user_id in zip(config.recipients, user_ids):
        try:
            info = client.users_info(user=user_id)
        except SlackApiError as error:
            sys.exit(f"Could not look up {entry} ({user_id}): {error.response['error']}")
        print(f"  {entry} -> {user_id} ({info['user']['real_name']})")

    describe_channel(client, config.channel)

    if not post_test_message:
        print("\nChecks passed. Nothing was posted.")
        print("Run with --post-test-message to confirm the bot can actually post there.")
        return

    mentions = " ".join(f"<@{user_id}>" for user_id in user_ids)
    summary = post_message(
        client,
        config.channel,
        f"{mentions} :test_tube: Job function check — connection test. "
        "This is what a real alert looks like. Details in thread.",
    )
    post_message(
        client,
        config.channel,
        "• *Sample Person* (emp #E00000) — Job Function is null (test row, not real data)",
        thread_ts=summary["ts"],
    )
    print("\nTest message posted. Both recipients should have been mentioned.")


def describe_channel(client: WebClient, channel: str) -> None:
    """Report what the bot can see about the alert channel, if scopes allow."""
    try:
        info = client.conversations_info(channel=channel)
    except SlackApiError as error:
        reason = error.response["error"]
        if reason == "missing_scope":
            print(f"Channel: {channel} (cannot inspect without channels:read/groups:read)")
            return
        sys.exit(
            f"Channel {channel} is not usable: {reason}\n"
            "Use the channel ID (C...) from Slack's channel details, and make sure "
            "the bot has been invited to it."
        )

    # DM conversations have no name and no is_member flag, so read both defensively.
    channel_info = info["channel"]
    name = channel_info.get("name", "direct message")
    if channel_info.get("is_member", True):
        print(f"Channel: {name} ({channel_info['id']}) — bot can post here")
        return

    print(f"Channel: {name} ({channel_info['id']}) — BOT IS NOT A MEMBER")
    print("  Invite it in Slack with: /invite @YourBotName")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Run the job function check and alert two people on Slack."
    )
    parser.add_argument(
        "--sql",
        type=Path,
        default=DEFAULT_SQL_PATH,
        help="Path to the query file (default: function_check.sql in this repo).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the results to the terminal instead of sending to Slack.",
    )
    parser.add_argument(
        "--notify-when-clean",
        action="store_true",
        help="Post an all-clear message to Slack even when nothing is returned.",
    )
    parser.add_argument(
        "--test-slack",
        action="store_true",
        help="Check the Slack token, scopes, recipients, and channel. Posts nothing.",
    )
    parser.add_argument(
        "--post-test-message",
        action="store_true",
        help="With --test-slack, also post a real test message into the channel.",
    )
    args = parser.parse_args()

    if args.test_slack:
        test_slack(load_slack_config(), args.post_test_message)
        return

    if args.post_test_message:
        sys.exit("--post-test-message only applies together with --test-slack.")

    # Validate the Slack side before the query so a bad token fails in a second
    # rather than after a full BigQuery run.
    slack_config = None if args.dry_run else load_slack_config()
    issues = run_query(load_bigquery_config(), args.sql)

    if args.dry_run:
        print(f"{len(issues)} issue(s) found. Slack alert suppressed (--dry-run).")
        for issue in issues:
            print(issue.to_line())
        return

    if not issues and not args.notify_when_clean:
        print("0 issues found. No Slack alert sent.")
        return

    send_alert(slack_config, issues)
    print(f"{len(issues)} issue(s) found. Slack alert sent.")


if __name__ == "__main__":
    main()
