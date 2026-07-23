from .base import BaseScraper


def get_scraper(config: dict, dry_run: bool = False, max_items: int | None = None) -> BaseScraper:
    return BaseScraper(config, dry_run=dry_run, max_items=max_items)
