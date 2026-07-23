"""
Scheduler — cron entries for running the Noida scraper daily.

--- Linux / macOS crontab (crontab -e) ---

# Daily at 6:00 AM IST (server timezone = Asia/Kolkata):
0 6 * * * /full/path/to/scraper_project/scripts/run_scraper.sh >> /full/path/to/scraper_project/logs/cron.log 2>&1

# Daily at 6:00 AM IST if server uses UTC (IST = UTC+5:30, so 6 AM IST = 00:30 UTC):
30 0 * * * /full/path/to/scraper_project/scripts/run_scraper.sh >> /full/path/to/scraper_project/logs/cron.log 2>&1

--- Verify ---
# crontab -l    # list your active cron entries
# tail -f logs/cron.log   # watch the log

--- Windows Task Scheduler ---
1. Open Task Scheduler → Create Basic Task
2. Trigger: Daily, 6:00 AM
3. Action: Start a program
   Program: python
   Arguments: main.py --all
   Start in: G:\Projects\Scrapling\scraper_project
4. Finish
"""
