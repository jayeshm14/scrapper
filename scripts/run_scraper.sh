#!/usr/bin/env bash
# ==============================================================
# run_scraper.sh — Cron entrypoint for Scrapling Noida scraper
#
# Usage:
#   ./scripts/run_scraper.sh                     # full run
#   ./scripts/run_scraper.sh --limit 5           # dry-run / limit
#
# Crontab (daily 6:00 AM IST = 00:30 UTC):
#   30 0 * * * /path/to/scraper_project/scripts/run_scraper.sh >> /path/to/scraper_project/logs/cron.log 2>&1
# ==============================================================
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# ── Activate virtualenv ───────────────────────────────────────
if [ -d "venv" ]; then
    source venv/bin/activate
elif [ -d ".venv" ]; then
    source .venv/bin/activate
elif command -v pipenv &>/dev/null && pipenv --venv &>/dev/null; then
    exec pipenv run python main.py --all "$@"
fi

# ── Run ───────────────────────────────────────────────────────
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

python main.py --all "$@" 2>&1 | tee -a "$LOG_DIR/cron.log"
EXIT_CODE=$?

echo "[$(date)] run_scraper.sh finished — exit code $EXIT_CODE" >> "$LOG_DIR/cron.log"
exit $EXIT_CODE
