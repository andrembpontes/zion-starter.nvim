---
name: update-nvim
description: Update Neovim plugin dependencies using lazy.nvim, review the changelog for breaking changes, and commit. Trigger this skill whenever the user says "update nvim deps", "update plugins", "lazy update", "update neovim packages", or anything about updating/upgrading nvim plugins. Always use this skill for any nvim plugin update task.
---

# Update Neovim Plugins

Full workflow: update plugins, review changelog for breaking changes, act on any issues, then commit.

## Step 1 — Run the update script

```bash
python .claude/skills/update-nvim/scripts/nvim_update.py
```

Run from the project root (where `lazy-lock.json` lives). The script:
1. Runs `nvim --headless "+Lazy! update" +qa`  (`+qa` = quit-all, exits Neovim after update)
2. Diffs the updated `lazy-lock.json` against `HEAD:lazy-lock.json` (last git commit)
3. For each changed plugin, pulls `git log --oneline` from `~/.local/share/nvim/lazy/<name>/`
4. Flags lines matching breaking-change keywords (`BREAKING`, `deprecated`, `renamed`, `migrated`, etc.)
5. Prints only the flagged commits, then exits 0 (clean) or 1 (flagged commits found)

## Step 2 — If exit 0: commit and done

```bash
git add lazy-lock.json
git commit -m "update plugins"
```

## Step 3 — If exit 1: smart filter with Haiku before acting

The script writes full details to a timestamped file in `/tmp/` and prints only the path.
The regex has false positives, so before acting spawn a **background Task using the haiku model**
to do a smart first pass — this keeps noise out of the main context:

```
Task prompt (haiku model):

Read the flagged commits report at: <file-path from script output>

For each flagged commit, fetch the full commit body:
  git -C ~/.local/share/nvim/lazy/<plugin> show <sha>

Classify each as:
  - ACTIONABLE: genuinely breaking for a Neovim config (API removed/renamed,
    option changed, required migration step)
  - NOISE: false positive (docs, internal refactor, typo fix, CI change,
    unrelated use of "remove"/"rename"/"deprecated")

Read the report file in sections if it is large — do not try to load it all at once.
Output ONLY the ACTIONABLE items with a one-line explanation of what needs to change.
If none are actionable, say so clearly.
```

Wait for the Task to complete, then bring only the ACTIONABLE findings into the main context.

## Step 4 — Act on actionable findings

For each actionable item:

1. **Assess impact** — does the change affect this config?
   - API rename → search for the old name in `lua/` and `init.lua`
   - Removed option → check if it's set anywhere in the config
   - New required setup call → update the plugin's spec

2. **Fix config if needed**, then verify Neovim starts cleanly:
   ```bash
   nvim --headless +qa 2>&1 | grep -i error
   ```

3. **Commit everything together** — plugin fixes + lockfile in one commit:
   ```bash
   git add lazy-lock.json <any changed config files>
   git commit -m "update plugins, fix <plugin> breaking change"
   ```

## Notes

- Plugins are cached under `~/.local/share/nvim/lazy/` — git log works offline.
- Use `--base HEAD~1` to inspect what changed in the previous update (useful if you forgot to run the script before committing).
- If a plugin has no local git history, it was likely reinstalled from scratch; check its GitHub releases manually.
