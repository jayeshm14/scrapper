#!/usr/bin/env bash
# Scrapling Noida Property Scraper — cron entrypoint
# Place this in crontab to run daily at 6:00 AM IST.
#
# Prerequisites:
#   1. Python virtualenv at REPO_DIR/venv/
#   2. `scrapling install` already run inside the venv
#   3. REPO_DIR points to the root of scraper_project/

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$REPO_DIR/logs"
VENV_DIR="$REPO_DIR/venv"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

mkdir -p "$LOG_DIR"

# Activate virtualenv
if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
elif [ -f "$VENV_DIR/Scripts/activate" ]; then
    source "$VENV_DIR/Scripts/activate"
else
    echo "[ERROR] No virtualenv found at $VENV_DIR" >> "$LOG_DIR/cron_error.log"
    exit 1
fi

cd "$REPO_DIR" || exit 1

# Run all scrapers, append stdout+stderr to a timestamped log
python main.py --all >> "$LOG_DIR/cron_${TIMESTAMP}.log" 2>&1
EXIT_CODE=$?

# Consolidate into SQLite (only if scrape succeeded at least partially)
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 1 ]; then
    python consolidate.py >> "$LOG_DIR/consolidate_${TIMESTAMP}.log" 2>&1
fi

# Rotate logs older than 30 days
find "$LOG_DIR" -name "cron_*.log" -mtime +30 -delete 2>/dev/null
find "$LOG_DIR" -name "consolidate_*.log" -mtime +30 -delete 2>/dev/null

exit $EXIT_CODE
