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
CD_URL = "https://www.echovaluecalc.com/cd"
RESONATORS_PATH = Path(__file__).parent.parent / "assets" / "data" / "resonators.json"
MIGRATIONS_PATH = Path(__file__).parent.parent / "assets" / "data" / "resonator_id_migrations.json"

# Website stat names ->project stat keys
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
    "Aemeath (Fusion Burst)" ->"aemeath-fusion-burst"
    "The Shorekeeper"        ->"the-shorekeeper"
    """
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def derive_base_name(name: str) -> str:
    """Extract the character's base name (before any role specifier).
    "Aemeath (Fusion Burst)" ->"Aemeath"
    "The Shorekeeper"        ->"The Shorekeeper"
    """
    return name.split("(")[0].strip()


# ---- CD page helpers -------------------------------------------------------

def parse_cd_name(raw: str) -> tuple[str, str]:
    """Parse a /cd row name into (resonator_name, team).

    The LAST outermost (depth=1) parenthesized group is the team.
    Everything before it is the resonator name.

    "Aalto (Main-DPS) (Default)"          ->("Aalto (Main-DPS)",   "Default")
    "Camellya (Default)"                  ->("Camellya",           "Default")
    "Cantarella (Midnight Veil (P + R))"  ->("Cantarella",         "Midnight Veil (P + R)")
    "Jinhsi (Alternate Rotation Burst)"   ->("Jinhsi",             "Alternate Rotation Burst")
    """
    raw = raw.strip().rstrip(":")
    if not raw:
        return raw, "Default"

    depth = 0
    groups = []  # list of (start, end) for outermost (depth==1) groups

    for i, ch in enumerate(raw):
        if ch == "(":
            if depth == 0:
                groups.append([i, None])
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0 and groups and groups[-1][1] is None:
                groups[-1][1] = i

    if not groups:
        return raw, "Default"

    # Last outermost group is the team
    team_start, team_end = groups[-1]
    team = raw[team_start + 1:team_end].strip()
    resonator = raw[:team_start].strip()

    return resonator, team


def parse_er_range(raw: str):
    """Parse an ER target cell into {"min": X, "max": Y} or None.

    "125.0 - 128.1"  -> {"min": 125.0, "max": 128.1}
    " - " / "—" / ""  -> None
    """
    if not raw:
        return None
    raw = raw.strip()
    if raw in ("-", "—", ""):
        return None
    parts = raw.split("-")
    if len(parts) != 2:
        return None
    try:
        return {"min": float(parts[0].strip()), "max": float(parts[1].strip())}
    except ValueError:
        return None


def parse_damage_split(basic: str, heavy: str, skill: str, liberation: str):
    """Parse damage split cells into a dict, or None if all are NA.

    Individual "NA" cells become 0.0.
    If *all four* are NA, returns None (no damage split data for this character).
    """
    vals = []
    for raw in (basic, heavy, skill, liberation):
        stripped = raw.strip()
        if stripped.upper() == "NA":
            vals.append(0.0)
        else:
            try:
                vals.append(float(stripped))
            except ValueError:
                vals.append(0.0)

    if all(v == 0.0 for v in vals):
        # Check if truly all were NA (not just all legitimately 0.0)
        all_na = all(
            raw.strip().upper() == "NA"
            for raw in (basic, heavy, skill, liberation)
        )
        if all_na:
            return None

    return {
        "basic": vals[0],
        "heavy": vals[1],
        "skill": vals[2],
        "liberation": vals[3],
    }


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


class CDTableParser(HTMLParser):
    """Extract rows from the /cd page HTML table."""

    def __init__(self):
        super().__init__()
        self.rows: list[dict] = []
        self._in_tr = False
        self._in_td = False
        self._in_header = False
        self._current_row: list[str] = []
        self._skip = False

    def handle_starttag(self, tag, attrs):
        if tag in ("tr", "td", "th"):
            self._skip = False
        if tag == "tr":
            self._in_tr = True
            self._current_row = []
        elif tag == "th":
            self._in_header = True
        elif tag in ("td", "th"):
            self._in_td = True

    def handle_endtag(self, tag):
        if tag == "tr":
            self._in_tr = False
            if not self._in_header and len(self._current_row) >= 7:
                row = {
                    "raw_name": self._current_row[0].strip(),
                    "er_target_raw": self._current_row[1].strip(),
                    "er_importance": self._current_row[2].strip(),
                    "basic": self._current_row[3].strip(),
                    "heavy": self._current_row[4].strip(),
                    "skill": self._current_row[5].strip(),
                    "liberation": self._current_row[6].strip(),
                }
                self.rows.append(row)
            self._in_header = False
        elif tag in ("td", "th"):
            self._in_td = False

    def handle_data(self, data):
        if self._skip:
            return
        if self._in_td and self._in_tr:
            self._current_row.append(data)


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


def fetch_cd_data() -> list[dict]:
    """Fetch and parse the /cd Character Data table.

    Returns a list of row dicts, or an empty list on failure.
    """
    req = Request(CD_URL, headers={"User-Agent": "evc-sync/1.0"})
    with urlopen(req, timeout=30) as resp:
        html = resp.read().decode("utf-8")

    parser = CDTableParser()
    parser.feed(html)

    if not parser.rows:
        print("WARNING: No CD table rows found. Site structure may have changed.")
        return []

    return parser.rows


# ---- Build entries from website data ---------------------------------------

def build_entries(char_data: dict, echo_data: list[str],
                  existing: list[dict] | None = None,
                  cd_rows: list[dict] | None = None) -> list[dict]:
    """Build the complete resonators.json entry list from website data.

    For metadata not on the website (stars, attribute, weapon, icons),
    values are carried over from existing entries when a match is found.

    When cd_rows is provided (from the /cd page), ER importance, damage
    split, and per-team ER target ranges are merged into entries.
    """
    if existing is None:
        existing = []

    # Index existing entries by name for metadata carry-over
    existing_by_name = {e["name"]: e for e in existing}

    # ---- Build CD lookups ----
    damage_by_name: dict[str, dict] = {}
    importance_by_name: dict[str, str] = {}
    er_by_name_team: dict[tuple[str, str], dict | None] = {}

    if cd_rows:
        for row in cd_rows:
            res_name, team = parse_cd_name(row["raw_name"])
            # Damage split: take first non-None for this resonator name
            if res_name not in damage_by_name:
                split = parse_damage_split(
                    row["basic"], row["heavy"], row["skill"], row["liberation"]
                )
                if split is not None:
                    damage_by_name[res_name] = split
            # ER importance: take first for this resonator name
            if res_name not in importance_by_name:
                imp = row["er_importance"].strip()
                if imp:
                    importance_by_name[res_name] = imp
            # ER range: store per (resonator, team), using {} for "no ER"
            key = (res_name, team)
            if key not in er_by_name_team:
                er_range = parse_er_range(row["er_target_raw"])
                er_by_name_team[key] = er_range if er_range is not None else {}

        # Report unmatched CD rows
        matched = {name for name, _ in er_by_name_team}
        all_res_names = set(char_data.keys())
        unmatched = matched - all_res_names
        if unmatched:
            print(f"  Note: {len(unmatched)} CD row(s) did not match "
                  f"any /echo character name (may be alt versions):")
            for name in sorted(unmatched):
                print(f"    - {name}")

    # ---- Build entries ----
    entries = []
    for web_name, data in char_data.items():
        weights = data[0]        # list[float] — stat relevance
        teams_er = data[1][0]    # dict[str, float] — team ->ER requirement

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

        entry = {
            "id": derive_id(web_name),
            "name": web_name,
            "stars": stars,
            "attribute": attribute,
            "weapon": weapon,
            "iconAsset": icon,
            "portraitAsset": portrait,
            "usableStats": usable,
            "teams": teams,
        }

        # ---- merge CD data ----
        if cd_rows:
            imp = importance_by_name.get(web_name)
            if imp:
                entry["erImportance"] = imp

            split = damage_by_name.get(web_name)
            if split is not None:
                entry["damageSplit"] = split

            team_er = {}
            for team_name in ["Default"] + teams:
                er_range = er_by_name_team.get((web_name, team_name))
                if er_range is not None:
                    team_er[team_name] = er_range
            if team_er:
                entry["teamER"] = team_er

        entries.append(entry)

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
        if new.get("erImportance") != old.get("erImportance"):
            diffs.append("erImportance")
        if new.get("damageSplit") != old.get("damageSplit"):
            diffs.append("damageSplit")
        if new.get("teamER") != old.get("teamER"):
            diffs.append("teamER")
        if diffs:
            modified.append({"entry": new, "old": old, "diffs": diffs})
        else:
            unchanged.append(nid)

    return added, removed, modified, unchanged


def _fmt_split(split: dict | None) -> str:
    """Format a damage split dict for diff display."""
    if not split:
        return "none"
    return f"B={split['basic']} H={split['heavy']} S={split['skill']} L={split['liberation']}"


def _fmt_er_range(r: dict | None) -> str:
    """Format an ER range dict for diff display."""
    if r is None:
        return "none"
    if not r:
        return "not needed"
    return f"{r['min']}-{r['max']}"


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
            if e.get("erImportance"):
                print(f"    ER importance: {e['erImportance']}")
            if e.get("damageSplit"):
                ds = e["damageSplit"]
                print(f"    damage split: B={ds['basic']} H={ds['heavy']} "
                      f"S={ds['skill']} L={ds['liberation']}")
            if e.get("teamER"):
                for t, r in e["teamER"].items():
                    if r:
                        print(f"    ER target ({t}): {r['min']} - {r['max']}")
                    else:
                        print(f"    ER target ({t}): not needed")
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
                print(f"    id:    {old['id']} ->{new['id']}")
            if "name" in m["diffs"]:
                print(f"    name:  {old['name']} ->{new['name']}")
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
            if "erImportance" in m["diffs"]:
                print(f"    ER importance: "
                      f"{old.get('erImportance', 'none')} ->"
                      f"{new.get('erImportance', 'none')}")
            if "damageSplit" in m["diffs"]:
                print(f"    damage split: "
                      f"{_fmt_split(old.get('damageSplit'))} ->"
                      f"{_fmt_split(new.get('damageSplit'))}")
            if "teamER" in m["diffs"]:
                print(f"    team ER ranges updated")
                for t in sorted(set(new.get("teamER", {})) | set(old.get("teamER", {}))):
                    nr = new.get("teamER", {}).get(t)
                    or_ = old.get("teamER", {}).get(t)
                    if nr != or_:
                        print(f"      {t}: {_fmt_er_range(or_)} ->{_fmt_er_range(nr)}")

    if unchanged:
        print(f"\n[OK] UNCHANGED: {len(unchanged)} entries")

    if not added and not removed and not modified:
        print("\n[OK] No changes. resonators.json is up to date.")

    print("\n" + "=" * 60)
    if added or removed or modified:
        print("Run with --apply to rebuild resonators.json")
    print("=" * 60)


# ---- Migration map ---------------------------------------------------------

def compute_new_migrations(old_entries: list[dict], new_entries: list[dict]) -> dict:
    """Find ID changes between old and new entries.

    Matching strategy:
    1. Exact name match — most reliable (name didn't change, only ID did)
    2. Base name match — for renamed entries where only the specifier changed
       (e.g. "Aalto (DPS)" ->"Aalto (Main-DPS)"). Only applied when exactly
       one unmatched new entry shares the base name.

    Returns {old_id: new_id} for entries whose ID changed.
    """
    migrations = {}

    new_by_name = {e["name"]: e for e in new_entries}

    # Pass 1: exact name matches
    unmatched_old = []
    for old in old_entries:
        new = new_by_name.get(old["name"])
        if new and new["id"] != old["id"]:
            migrations[old["id"]] = new["id"]
        elif not new:
            unmatched_old.append(old)

    # Pass 2: base-name matching for renamed entries.
    matched_new_ids = set(migrations.values())
    new_by_base = {}  # base_name ->[unmatched_new_entry, ...]
    for new in new_entries:
        if new["id"] in matched_new_ids:
            continue
        base = derive_base_name(new["name"]).lower()
        new_by_base.setdefault(base, []).append(new)

    for old in unmatched_old:
        old_base = derive_base_name(old["name"]).lower()
        candidates = new_by_base.get(old_base, [])
        if len(candidates) == 1:
            new = candidates[0]
            if new["id"] != old["id"]:
                migrations[old["id"]] = new["id"]

    return migrations


def load_migration_map() -> dict:
    """Read the existing cumulative migration map from disk."""
    if MIGRATIONS_PATH.exists():
        with open(MIGRATIONS_PATH, encoding="utf-8") as f:
            return json.load(f)
    return {}


def update_migration_map(old_entries: list[dict],
                         new_entries: list[dict]) -> dict:
    """Build a cumulative migration map by merging new ID changes into the
    existing map.

    The existing map is preserved so that users who skip releases still get
    all historical migrations applied.
    """
    existing = load_migration_map()

    # Apply existing migrations to old entries so we only detect *new* changes.
    # e.g. if char1→char2 was already migrated, old entries with char1 become
    # char2 before we compare, so we won't re-detect char1→char2.
    migrated_old = []
    for e in old_entries:
        entry = dict(e)
        if entry["id"] in existing:
            entry["id"] = existing[entry["id"]]
        migrated_old.append(entry)

    new_migrations = compute_new_migrations(migrated_old, new_entries)

    # Merge: existing migrations first (historical), then new (current release).
    # The combined map is {historical_old_id: current_new_id}.
    merged = dict(existing)
    merged.update(new_migrations)
    return merged


def print_migrations(migrations: dict):
    """Print the migration map."""
    if not migrations:
        return
    print(f"\n[MIGRATE] Echo set keys to rename ({len(migrations)}):")
    for old_id, new_id in sorted(migrations.items()):
        print(f"  {old_id} ->{new_id}")


# ---- Main ------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(
        description="Rebuild resonators.json from echovaluecalc.com")
    ap.add_argument("--apply", action="store_true",
                    help="Write changes to resonators.json")
    ap.add_argument("--skip-cd", action="store_true",
                    help="Skip fetching /cd Character Data page")
    args = ap.parse_args()

    print("Fetching echovaluecalc.com (echo data)...")
    char_data, echo_data = fetch_evc_data()

    print("Loading existing resonators.json...")
    if RESONATORS_PATH.exists():
        with open(RESONATORS_PATH, encoding="utf-8") as f:
            existing = json.load(f)
    else:
        existing = []

    # Fetch CD data (ER targets, importance, damage splits)
    cd_rows = []
    if not args.skip_cd:
        print("Fetching echovaluecalc.com/cd (character data)...")
        try:
            cd_rows = fetch_cd_data()
            print(f"  Parsed {len(cd_rows)} CD rows")
        except Exception as exc:
            print(f"WARNING: Could not fetch/parse /cd page: {exc}")
            print("  ER target and damage split data will not be updated.")
            print("  Run with --skip-cd to suppress this attempt.")
    else:
        print("Skipping /cd fetch (--skip-cd)")

    print("Building entries from website data...")
    new_entries = build_entries(char_data, echo_data, existing,
                                cd_rows if cd_rows else None)

    added, removed, modified, unchanged = diff_entries(new_entries, existing)
    print_diff(added, removed, modified, unchanged)

    existing_migrations = load_migration_map()
    migrations = update_migration_map(existing, new_entries)
    new_count = len(migrations) - len(existing_migrations)
    if new_count > 0:
        print(f"\n[MIGRATE] {new_count} new ID change(s) this run "
              f"({len(migrations)} total in cumulative map)")
    print_migrations(migrations)

    if args.apply:
        with open(RESONATORS_PATH, "w", encoding="utf-8") as f:
            json.dump(new_entries, f, indent=2, ensure_ascii=False)
            f.write("\n")
        print(f"Wrote {len(new_entries)} entries to {RESONATORS_PATH}")

        with open(MIGRATIONS_PATH, "w", encoding="utf-8") as f:
            json.dump(migrations, f, indent=2, ensure_ascii=False)
            f.write("\n")
        if migrations:
            print(f"Wrote {len(migrations)} migrations to {MIGRATIONS_PATH}")
        else:
            print(f"Wrote empty migration file to {MIGRATIONS_PATH}")


if __name__ == "__main__":
    main()
