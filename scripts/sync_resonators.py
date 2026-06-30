#!/usr/bin/env python3
"""
Rebuild resonators.json from echovaluecalc.com data.

The website is the source of truth. This script fetches the embedded JSON
from the echo calculator page and rebuilds the project's resonators.json.

Usage:
  python scripts/sync_resonators.py          # Show what would change (dry-run)
  python scripts/sync_resonators.py --apply  # Rebuild resonators.json
"""

import json
import re
import sys
import argparse
from html.parser import HTMLParser
from urllib.request import urlopen, Request
from pathlib import Path

EVC_URL = "https://www.echovaluecalc.com/echo"
RESONATORS_PATH = Path(__file__).parent.parent / "assets" / "data" / "resonators.json"

# Website stat names → project stat keys
STAT_MAP = {
    "Crit Rate(%)":    "critRate",
    "Crit Damage(%)":  "critDamage",
    "Atk(%)":          "atkPercent",
    "Flat Atk":        "flatAtk",
    "HP(%)":           "hpPercent",
    "Flat HP":         "flatHp",
    "Def(%)":          "defPercent",
    "Flat Def":        "flatDef",
    "Basic(%)":        "basicPercent",
    "Heavy(%)":        "heavyPercent",
    "Skill(%)":        "skillPercent",
    "Liberation(%)":   "liberationPercent",
    "ER(%)":            "erPercent",
}


def derive_id(name: str) -> str:
    """Derive a stable ID from a website character name.

    Purely mechanical: lowercase, replace non-alphanumeric runs with hyphens.
    "Aemeath (Fusion Burst)" → "aemeath-fusion-burst"
    "The Shorekeeper"        → "the-shorekeeper"
    """
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def derive_base_name(name: str) -> str:
    """Extract the character's base name (before any role specifier).
    "Aemeath (Fusion Burst)" → "Aemeath"
    "The Shorekeeper"        → "The Shorekeeper"
    """
    return name.split("(")[0].strip()


# ---- HTML parser -----------------------------------------------------------

class CharDataExtractor(HTMLParser):
    """Extract JSON from <script id="char-data"> and <script id="echo-data">."""

    def __init__(self):
        super().__init__()
        self.char_data = None
        self.echo_data = None
        self._tag = None
        self._id = None

    def handle_starttag(self, tag, attrs):
        self._tag = tag
        self._id = dict(attrs).get("id")

    def handle_endtag(self, tag):
        self._tag = None
        self._id = None

    def handle_data(self, data):
        if self._tag != "script":
            return
        if self._id == "char-data":
            self.char_data = json.loads(data)
        elif self._id == "echo-data":
            self.echo_data = json.loads(data)


# ---- Fetch -----------------------------------------------------------------

def fetch_evc_data():
    """Fetch and parse character data from echovaluecalc.com."""
    req = Request(EVC_URL, headers={"User-Agent": "evc-sync/1.0"})
    with urlopen(req, timeout=30) as resp:
        html = resp.read().decode("utf-8")

    parser = CharDataExtractor()
    parser.feed(html)

    if not parser.char_data or not parser.echo_data:
        sys.exit("ERROR: Could not find char-data or echo-data in page. "
                 "Site structure may have changed.")

    return parser.char_data, parser.echo_data


# ---- Build entries from website data ---------------------------------------

def build_entries(char_data: dict, echo_data: list[str],
                  existing: list[dict] | None = None) -> list[dict]:
    """Build the complete resonators.json entry list from website data.

    For metadata not on the website (stars, attribute, weapon, icons),
    values are carried over from existing entries when a match is found.
    """
    if existing is None:
        existing = []

    # Index existing entries by name for metadata carry-over
    existing_by_name = {e["name"]: e for e in existing}

    entries = []
    for web_name, data in char_data.items():
        weights = data[0]        # list[float] — stat relevance
        teams_er = data[1][0]    # dict[str, float] — team → ER requirement

        # ---- usable stats ----
        usable = []
        for i, w in enumerate(weights):
            if w > 0 and i < len(echo_data):
                key = STAT_MAP.get(echo_data[i])
                if key:
                    usable.append(key)

        # ER is usable when any team needs > 100%
        if teams_er and max(teams_er.values()) > 100:
            usable.append("erPercent")

        # ---- teams ----
        teams = sorted([t for t in teams_er if t != "Default"])

        # ---- carry over metadata from existing ----
        old = existing_by_name.get(web_name)
        if old:
            stars = old.get("stars", 0)
            attribute = old.get("attribute", "???")
            weapon = old.get("weapon", "???")
            icon = old.get("iconAsset", "")
            portrait = old.get("portraitAsset", "")
        else:
            stars = 0
            attribute = "???"
            weapon = "???"
            icon = ""
            portrait = ""

        entries.append({
            "id": derive_id(web_name),
            "name": web_name,
            "stars": stars,
            "attribute": attribute,
            "weapon": weapon,
            "iconAsset": icon,
            "portraitAsset": portrait,
            "usableStats": usable,
            "teams": teams,
        })

    return entries


# ---- Diff ------------------------------------------------------------------

def diff_entries(new_entries: list[dict], old_entries: list[dict]):
    """Compare new (website-derived) entries against the current file."""
    old_by_id = {e["id"]: e for e in old_entries}
    new_by_id = {e["id"]: e for e in new_entries}

    added = [e for e in new_entries if e["id"] not in old_by_id]
    removed = [e for e in old_entries if e["id"] not in new_by_id]
    modified = []
    unchanged = []

    for nid, new in new_by_id.items():
        old = old_by_id.get(nid)
        if old is None:
            continue
        diffs = []
        if sorted(new.get("usableStats", [])) != sorted(old.get("usableStats", [])):
            diffs.append("stats")
        if sorted(new.get("teams", [])) != sorted(old.get("teams", [])):
            diffs.append("teams")
        if new.get("id") != old.get("id"):
            diffs.append("id")
        if new.get("name") != old.get("name"):
            diffs.append("name")
        if diffs:
            modified.append({"entry": new, "old": old, "diffs": diffs})
        else:
            unchanged.append(nid)

    return added, removed, modified, unchanged


def print_diff(added, removed, modified, unchanged):
    """Print a human-readable diff."""
    print("=" * 60)
    print("EVC Sync — Resonator Data Diff")
    print(f"  Website: {len(added) + len(modified) + len(unchanged)} chars")
    print(f"  Local:   {len(removed) + len(modified) + len(unchanged)} chars")
    print("=" * 60)

    if added:
        print(f"\n[NEW] ({len(added)}):")
        for e in added:
            print(f"  + {e['name']}")
            print(f"    id: {e['id']}")
            print(f"    stats: {', '.join(e['usableStats'])}")
            print(f"    teams: {', '.join(e['teams']) if e['teams'] else '(none)'}")
            if e["stars"] == 0:
                print(f"    WARNING: stars/attribute/weapon/icons need manual fill")

    if removed:
        print(f"\n[REMOVED] ({len(removed)}):")
        for e in removed:
            print(f"  - {e['name']} ({e['id']})")

    if modified:
        print(f"\n[MODIFIED] ({len(modified)}):")
        for m in modified:
            new = m["entry"]
            old = m["old"]
            print(f"\n  {new['name']} ({new['id']})")
            if "id" in m["diffs"]:
                print(f"    id:    {old['id']} → {new['id']}")
            if "name" in m["diffs"]:
                print(f"    name:  {old['name']} → {new['name']}")
            if "stats" in m["diffs"]:
                ns = set(new.get("usableStats", []))
                os_ = set(old.get("usableStats", []))
                if ns - os_:
                    print(f"    stats +{sorted(ns - os_)}")
                if os_ - ns:
                    print(f"    stats -{sorted(os_ - ns)}")
            if "teams" in m["diffs"]:
                nt = set(new.get("teams", []))
                ot = set(old.get("teams", []))
                if nt - ot:
                    print(f"    teams +{sorted(nt - ot)}")
                if ot - nt:
                    print(f"    teams -{sorted(ot - nt)}")

    if unchanged:
        print(f"\n[OK] UNCHANGED: {len(unchanged)} entries")

    if not added and not removed and not modified:
        print("\n[OK] No changes. resonators.json is up to date.")

    print("\n" + "=" * 60)
    if added or removed or modified:
        print("Run with --apply to rebuild resonators.json")
    print("=" * 60)


# ---- Main ------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(
        description="Rebuild resonators.json from echovaluecalc.com")
    ap.add_argument("--apply", action="store_true",
                    help="Write changes to resonators.json")
    args = ap.parse_args()

    print("Fetching echovaluecalc.com...")
    char_data, echo_data = fetch_evc_data()

    print("Loading existing resonators.json...")
    if RESONATORS_PATH.exists():
        with open(RESONATORS_PATH, encoding="utf-8") as f:
            existing = json.load(f)
    else:
        existing = []

    print("Building entries from website data...")
    new_entries = build_entries(char_data, echo_data, existing)

    added, removed, modified, unchanged = diff_entries(new_entries, existing)
    print_diff(added, removed, modified, unchanged)

    if args.apply:
        with open(RESONATORS_PATH, "w", encoding="utf-8") as f:
            json.dump(new_entries, f, indent=2, ensure_ascii=False)
            f.write("\n")
        print(f"Wrote {len(new_entries)} entries to {RESONATORS_PATH}")


if __name__ == "__main__":
    main()
