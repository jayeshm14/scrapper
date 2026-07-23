# Scrapling Multi-Site Scraper

A production-grade, multi-site web scraping system built on the **Scrapling** framework.

## Setup

```bash
# Create virtual environment (optional but recommended)
python -m venv venv
# Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install Scrapling browser dependencies for stealth/dynamic fetchers
scrapling install
```

## Configuration

Edit `config/sites.yaml` to define your target sites. Each site entry specifies:

| Field | Description |
|---|---|
| `name` | Unique identifier for the site |
| `start_urls` | List of entry-point URLs |
| `fetcher` | `basic` (static HTML), `dynamic` (JS-rendered), or `stealthy` (anti-bot protected) |
| `selectors.item` | CSS selector for each item container |
| `selectors.fields` | Dict mapping field names to CSS selectors |
| `pagination.next_selector` | CSS selector for next-page link/button |
| `pagination.max_pages` | Max pages to scrape per site |
| `rate_limit_seconds` | Delay between requests (minimum 1.0s) |
| `output_format` | `json` or `csv` |

## Usage

```bash
# Run a single site
python main.py --site quotes_static

# Run all sites
python main.py --all

# Dry-run (fetch + parse, no saving, no dedup tracking)
python main.py --site books_dynamic --dry-run
```

## Output

Results are saved to `output/{site_name}/{date}.{json|csv}`. Each record includes `site_name` and `scraped_at` timestamp.

## Scheduling

See `scheduler.py` for:
- Linux/macOS crontab entry
- Windows Task Scheduler setup
- FastAPI endpoint (`POST /scrape/{site_name}`) for on-demand HTTP-triggered runs

## Compliance

- **robots.txt**: Always check and respect the target site's `robots.txt` before scraping.
- **Rate limiting**: Default minimum is 1 second between requests per domain. Do not override below this unless you have explicit permission.
- **Legality**: Scraping legality depends on the target site's Terms of Service, the type of data collected, and your jurisdiction. This tool does not grant permission to scrape any specific site. You are responsible for ensuring compliance with all applicable laws and terms.
