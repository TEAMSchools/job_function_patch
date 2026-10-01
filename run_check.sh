#!/usr/bin/env bash
#
# Runs the job function check and posts the result to Slack.
# macOS/Linux counterpart to run_check.bat. Safe to point launchd
# (or cron) at this file.
#
# Runs in the project venv, called by absolute path so it doesn't depend on PATH.
#
# Arguments are passed through, so these work too:
#     ./run_check.sh --test-slack
#     ./run_check.sh --test-slack --post-test-message
#
# Do NOT use --dry-run here. It prints staff names and employee numbers,
# which would then sit in the log file in plain text.
#
# First run only:  chmod +x run_check.sh

# No `set -e` -- we want to capture job_function_check.py's exit code and
# log it rather than abort the moment it fails.
set -uo pipefail

# Run from the repo folder so .env and function_check.sql resolve no matter
# what working directory the caller (or launchd) started us in.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

VENV_DIR="$SCRIPT_DIR/.venv"

mkdir -p logs
LOGFILE="logs/job_function_check.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] starting" >> "$LOGFILE"

# ── Venv ──────────────────────────────────────────────────────────────────────
#
# launchd runs with a much thinner PATH than your shell -- thinner than Windows
# Task Scheduler's, so a bare `python3` often isn't found at all. Calling the
# venv's python by absolute path sidesteps PATH entirely.
#
# Set PYTHON=/full/path/to/python before calling to bypass the venv and use a
# specific interpreter instead.

# Build the venv on first run, or if it's been deleted, so a fresh clone works.
if [ -z "${PYTHON:-}" ] && [ ! -x "$VENV_DIR/bin/python" ]; then
    echo "No venv found -- creating one at $VENV_DIR" | tee -a "$LOGFILE"
    if ! python3 -m venv "$VENV_DIR" \
        || ! "$VENV_DIR/bin/python" -m pip install --quiet --upgrade pip \
        || ! "$VENV_DIR/bin/pip" install --quiet -r "$SCRIPT_DIR/requirements.txt"
    then
        echo "Venv setup FAILED. See $SCRIPT_DIR/$LOGFILE." | tee -a "$LOGFILE"
        exit 1
    fi
    echo "Venv created and dependencies installed." | tee -a "$LOGFILE"
fi

# No `activate` needed: python reads pyvenv.cfg next to this binary and sets
# sys.prefix from it, so calling it by path gives the venv's site-packages.
PYTHON="${PYTHON:-$VENV_DIR/bin/python}"

# ── Run ───────────────────────────────────────────────────────────────────────

# Show this run's output on screen (for a manual run) and keep it in the
# rolling log (for a scheduled run nobody is watching). PIPESTATUS[0] is
# job_function_check.py's exit code, not tee's.
"$PYTHON" job_function_check.py "$@" 2>&1 | tee -a "$LOGFILE"
EXITCODE=${PIPESTATUS[0]}

echo "[$(date '+%Y-%m-%d %H:%M:%S')] finished with exit code $EXITCODE" >> "$LOGFILE"

if [ "$EXITCODE" -ne 0 ]; then
    echo
    echo "FAILED with exit code $EXITCODE. See $SCRIPT_DIR/$LOGFILE."
fi

# Hand the code to launchd so a failure shows up as a failure.
exit "$EXITCODE"
