# job_function_patch

A little tool to help us squash job function problems until we can figure out what the hell is going on.

`job_function_check.py` runs `function_check.sql` against BigQuery. If the query
returns anything, it posts a one-line summary to a Slack channel, @-mentions the
two people who need to act on it, and puts every offending row in that message's
thread. If the query returns nothing, it stays quiet.

## Setup

```bash
pip install -r requirements.txt
```

Create a `.env` file in this directory (already gitignored) with these four
variables:

| Variable | What it is |
| --- | --- |
| `GOOGLE_APPLICATION_CREDENTIALS` | Absolute path to the BigQuery service account JSON key file |
| `BIGQUERY_PROJECT_ID` | Project the query runs against |
| `SLACK_BOT_TOKEN` | Slack bot token (`xoxb-...`) |
| `SLACK_ALERT_CHANNEL` | Channel the alert posts to — the channel ID (`C01ABC...`) |
| `SLACK_ALERT_RECIPIENTS` | The two people to @-mention, comma-separated — emails or user IDs (`U01ABC...`) |

## Setting up Slack

The bot posts to one channel and @-mentions the two people who should act on the
alert. A small private channel with just the two of you works fine.

**1. Create the app.** Go to <https://api.slack.com/apps> → *Create New App* →
*From scratch*. Name it something obvious like `Job Function Check` and pick the
KTAF workspace.

**2. Add bot scopes.** In the app's *OAuth & Permissions* page, scroll to *Bot
Token Scopes* and add:

| Scope | Why |
| --- | --- |
| `chat:write` | Post the summary and thread replies |
| `users:read` | Read display names (used by `--test-slack`) |
| `users:read.email` | Look up recipients by email instead of user ID |

`channels:read` (public) or `groups:read` (private) is optional — it only lets
`--test-slack` confirm the bot is actually in the channel. Without it the check
still runs, it just can't inspect the channel.

**3. Install it.** Click *Install to Workspace* at the top of the same page. If
the KTAF workspace requires admin approval for apps, this sends a request and
you'll wait on a workspace admin.

**4. Copy the token.** After install you get a *Bot User OAuth Token* starting
with `xoxb-`. That goes in `.env` as `SLACK_BOT_TOKEN`. It is a credential —
`.env` is gitignored, keep it that way.

**5. Invite the bot to the channel.** In the channel itself, run
`/invite @Job Function Check`. Without this, posting fails with `not_in_channel`.
This is required for private channels and for public ones the bot hasn't joined.

**6. Get the channel ID.** Channel name → *View channel details* → scroll to the
bottom, where the ID (`C01ABC…`) is shown. Use the ID rather than `#name` —
name lookups are unreliable for bots.

**7. Get the two recipients.** Easiest is email — just list them. If you'd
rather use IDs, open the person's Slack profile → *More* (⋮) → *Copy member ID*,
which gives you a `U…` string. Either form works, mixed is fine:

```
SLACK_ALERT_RECIPIENTS=you@apps.teamschools.org,U01ABCDEFGH
```

**8. Verify before sending anything.**

```bash
python job_function_check.py --test-slack
```

This checks the token, prints which scopes are actually granted, resolves both
recipients to names, and reports whether the bot is in the channel — without
posting. Fix anything marked `MISSING`, then:

```bash
python job_function_check.py --test-slack --post-test-message
```

That posts a real test message mentioning both people, with one fake row in its
thread, so you can see the shape in Slack before any live data flows.

### When it doesn't work

| Error | Cause |
| --- | --- |
| `invalid_auth` | Token is wrong, or the app was uninstalled |
| `not_in_channel` | Bot was never invited — run `/invite @YourBotName` in the channel |
| `channel_not_found` | Wrong `SLACK_ALERT_CHANNEL`, or a private channel the bot isn't in. Use the `C…` ID |
| `users_not_found` | Email isn't the person's Slack email; use their member ID |
| Scopes show `MISSING` | Scopes were added but the app wasn't reinstalled afterward |

Adding a scope does **not** apply until you reinstall the app. That's the most
common thing to get stuck on.

## Usage

```bash
# Check the Slack side only - token, scopes, recipients, channel. Posts nothing.
python job_function_check.py --test-slack

# Same, but actually post a test message into the channel
python job_function_check.py --test-slack --post-test-message

# Normal run - alerts only if the query returns rows
python job_function_check.py

# See what would be sent without posting to Slack
python job_function_check.py --dry-run

# Also post an "all clear" when nothing is wrong
python job_function_check.py --notify-when-clean

# Point at a different query file
python job_function_check.py --sql some_other_check.sql
```

Exit code is 0 on success and non-zero if configuration, the query, or Slack
fails, so it drops into Task Scheduler or cron as-is.

## A note on the data

The query returns `formatted_name`, `employee_number`, and `worker_id` — real
staff-identifiable information. The script writes nothing to disk and prints
only a count to the terminal unless you pass `--dry-run`. Make sure both Slack
recipients are entitled to see staff roster data before pointing this at them.

Long result sets are capped at 200 rows in the thread, with a note showing how
many were omitted.
