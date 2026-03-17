#!/usr/bin/env python3
"""
nvim_update.py — Update Neovim plugins via lazy.nvim and report changelog + breaking changes.

Usage:
    python nvim_update.py [--dry-run]

Run from the directory containing lazy-lock.json (project root).
Diffs the updated lockfile against the last git commit to find what changed.
Exits with code 1 if any potential breaking changes are detected.
"""

import json
import subprocess
import sys
import re
import argparse
from pathlib import Path
from datetime import datetime

LAZY_PLUGIN_DIR = Path.home() / ".local/share/nvim/lazy"

BREAKING_RE = re.compile(
    r'\b(BREAKING[ _-]CHANGE|breaking change|deprecat|removed?|drop(ped)? support'
    r'|incompatible|no longer|renamed|migrat)',
    re.IGNORECASE,
)


def load_lockfile(path: Path) -> dict:
    with open(path) as f:
        return json.load(f)


def load_committed_lockfile(ref: str) -> dict:
    """Load lazy-lock.json as it exists at the given git ref."""
    result = subprocess.run(
        ["git", "show", f"{ref}:lazy-lock.json"],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        print(f"Error: could not read lazy-lock.json from {ref}. Is this a git repo with that ref?",
              file=sys.stderr)
        sys.exit(2)
    return json.loads(result.stdout)


def run_update() -> None:
    print("Running lazy.nvim update...\n")
    subprocess.run(["nvim", "--headless", "+Lazy! update", "+qa"], check=True)


def plugin_log(name: str, old: str, new: str) -> list[str]:
    plugin_dir = LAZY_PLUGIN_DIR / name
    if not plugin_dir.exists():
        return []
    result = subprocess.run(
        ["git", "-C", str(plugin_dir), "log", "--oneline", f"{old}..{new}"],
        capture_output=True, text=True,
    )
    return result.stdout.strip().splitlines() if result.returncode == 0 else []


def diff_lockfiles(old: dict, new: dict) -> dict[str, tuple[str, str]]:
    """Return {plugin_name: (old_commit, new_commit)} for plugins that changed."""
    changed = {}
    for name, new_info in new.items():
        old_info = old.get(name)
        if old_info and old_info["commit"] != new_info["commit"]:
            changed[name] = (old_info["commit"], new_info["commit"])
    return changed


def main() -> None:
    parser = argparse.ArgumentParser(description="Update Neovim plugins and report changes.")
    parser.add_argument("--dry-run", action="store_true",
                        help="Skip the actual update; diff baseline lockfile against working copy.")
    parser.add_argument("--base", default="HEAD", metavar="REF",
                        help="Git ref to use as the baseline lockfile (default: HEAD).")
    args = parser.parse_args()

    lockfile_path = Path("lazy-lock.json")
    if not lockfile_path.exists():
        print("Error: lazy-lock.json not found. Run from the project root.", file=sys.stderr)
        sys.exit(2)

    if not args.dry_run:
        run_update()

    old_lock = load_committed_lockfile(args.base)
    new_lock = load_lockfile(lockfile_path)
    changed = diff_lockfiles(old_lock, new_lock)

    if not changed:
        print("All plugins already up to date — nothing changed.")
        sys.exit(0)

    print(f"{len(changed)} plugin(s) updated\n")
    print("=" * 64)

    breaking_plugins: list[tuple[str, list[str]]] = []

    for name, (old, new) in sorted(changed.items()):
        commits = plugin_log(name, old, new)
        flagged = [c for c in commits if BREAKING_RE.search(c)]
        if flagged:
            breaking_plugins.append((name, flagged))

    n_updated = len(changed)
    n_flagged = len(breaking_plugins)
    n_clean = n_updated - n_flagged

    if not breaking_plugins:
        print(f"✓ {n_updated} plugin(s) updated, 0 breaking changes flagged. Safe to commit.")
        sys.exit(0)

    # Write full details to .tmp/ inside the project so subagents can access it
    report_dir = Path(".tmp")
    report_dir.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_path = report_dir / f"nvim-update-flagged-{timestamp}.txt"
    with open(report_path, "w") as f:
        f.write(f"nvim plugin update — flagged commits report\n")
        f.write(f"generated: {datetime.now().isoformat()}\n")
        f.write(f"{n_updated} plugin(s) updated, {n_flagged} with flagged commits\n")
        f.write("=" * 64 + "\n\n")
        f.write("Use `git -C ~/.local/share/nvim/lazy/<plugin> show <sha>` to inspect a commit.\n\n")
        for name, lines in breaking_plugins:
            f.write(f"{name}:\n")
            for line in lines:
                f.write(f"  → {line}\n")
            f.write("\n")

    print(f"⚠️  {n_updated} plugin(s) updated, {n_flagged} with flagged commits ({n_clean} clean).")
    print(f"    See: {report_path}")
    sys.exit(1)


if __name__ == "__main__":
    main()
