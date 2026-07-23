import re
from difflib import SequenceMatcher
from itertools import combinations

from storage import Storage


def extract_locality_parts(locality: str | None) -> set[str]:
    if not locality:
        return set()
    parts = re.findall(r"[A-Za-z0-9]+", locality.lower())
    return set(parts)


def locality_similarity(loc_a: str | None, loc_b: str | None) -> float:
    if not loc_a or not loc_b:
        return 0.0
    parts_a = extract_locality_parts(loc_a)
    parts_b = extract_locality_parts(loc_b)
    if not parts_a or not parts_b:
        return 0.0
    intersection = parts_a & parts_b
    union = parts_a | parts_b
    jaccard = len(intersection) / len(union) if union else 0.0
    return jaccard


def title_similarity(title_a: str | None, title_b: str | None) -> float:
    if not title_a or not title_b:
        return 0.0
    return SequenceMatcher(None, title_a.lower(), title_b.lower()).ratio()


def find_duplicates(storage: Storage, min_confidence: float = 0.7) -> list[dict]:
    listings = storage.get_all_listings()
    matches = []

    for a, b in combinations(listings, 2):
        if a["source_site"] == b["source_site"]:
            continue

        scores = []
        reasons = []

        if a["bhk"] and b["bhk"] and a["bhk"] == b["bhk"]:
            scores.append(0.3)
            reasons.append("bhk_match")

        loc_sim = locality_similarity(a.get("locality"), b.get("locality"))
        if loc_sim > 0.5:
            scores.append(loc_sim * 0.3)
            reasons.append(f"locality_{loc_sim:.2f}")

        title_sim = title_similarity(a.get("title"), b.get("title"))
        if title_sim > 0.4:
            scores.append(title_sim * 0.25)
            reasons.append(f"title_{title_sim:.2f}")

        if a["price_inr"] and b["price_inr"]:
            p_ratio = min(a["price_inr"], b["price_inr"]) / max(a["price_inr"], b["price_inr"])
            if p_ratio >= 0.97:
                scores.append(p_ratio * 0.15)
                reasons.append(f"price_{p_ratio:.2f}")

        if a["area_sqft"] and b["area_sqft"]:
            a_ratio = min(a["area_sqft"], b["area_sqft"]) / max(a["area_sqft"], b["area_sqft"])
            if a_ratio >= 0.95:
                scores.append(a_ratio * 0.15)
                reasons.append(f"area_{a_ratio:.2f}")

        confidence = sum(scores)
        if confidence >= min_confidence:
            matches.append({
                "listing_a": a,
                "listing_b": b,
                "confidence": round(confidence, 2),
                "reasons": "; ".join(reasons),
            })

    return sorted(matches, key=lambda m: m["confidence"], reverse=True)


def store_duplicates(storage: Storage, min_confidence: float = 0.7) -> list[dict]:
    matches = find_duplicates(storage, min_confidence)

    id_map = {}
    for row in storage.conn.execute("SELECT source_site, listing_id, id FROM listings").fetchall():
        id_map[(row[0], row[1])] = row[2]

    stored = []
    for m in matches:
        key_a = (m["listing_a"]["source_site"], m["listing_a"]["listing_id"])
        key_b = (m["listing_b"]["source_site"], m["listing_b"]["listing_id"])
        id_a = id_map.get(key_a)
        id_b = id_map.get(key_b)
        if id_a and id_b:
            storage.add_duplicate_pair(id_a, id_b, m["confidence"], m["reasons"])
            stored.append(m)

    return stored
