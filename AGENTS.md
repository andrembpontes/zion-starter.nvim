# AGENTS.md

Guidance for coding agents working in `zion-starter.nvim`.

## Repository Snapshot

- Language: Lua (Neovim config).
- Entry point: `init.lua`.
- Main local config folders:
  - `lua/configs/`
  - `lua/plugins/`
- Build/debug orchestration: `Makefile`.
- Plugin lockfile: `lazy-lock.json`.
- Demo files for smoke/debug checks: `tests/demo-files/*`.

## Important Upstream Dependency (Read This First)

Most behavior is not defined in this starter repo.

- Local sibling plugin source (primary reference): `../zion.nvim`
- GitHub plugin repository: `https://github.com/andrembpontes/zion.nvim`
- Plugin is wired in `lua/configs/lazy.lua` as:
  - repo: `andrembpontes/zion.nvim`
  - local override dir: `~/development/zion.nvim` when present

When implementing features, changing defaults, or debugging key behavior, inspect
`../zion.nvim` first. This repository mainly layers overrides and custom additions.

## Setup / Build Commands

Run commands from repository root.

- Initial local symlink setup:
  - `make link`
- Default setup path from README:
  - `make`
- Pull this repo and sibling `../zion.nvim`:
  - `make pull`
- Project helper to commit/push this repo and `../zion.nvim`:
  - `make push`

## Lint / Format / Test Status

- There is no dedicated lint command in this repository.
- There is no dedicated unit/integration test runner in this repository.
- No repo-local `.stylua.toml`, `stylua.toml`, `.luacheckrc`, or `selene.toml` found.
- Validation is done via Neovim startup/debug smoke runs.

## Test Commands (Smoke-Based)

- Fast headless startup sanity check:
  - `nvim --headless +qa`
- Debug startup with notify instrumentation:
  - `make nvim-debug`
- Headless cycle through all demo files:
  - `make nvim-debug-cycle`
- UI debug run:
  - `make nvim-debug-ui`
- UI debug cycle:
  - `make nvim-debug-cycle-ui`
- Debug default user config (`~/.config/nvim`) with notify wrapper:
  - `make nvim-debug-ui-user`
- Headless cycle for default user config:
  - `make nvim-debug-cycle-user`

## Single Test / Single File (Most Important)

Since no formal test framework exists, use one-file debug runs as single-test equivalents.

- Run one file:
  - `make nvim-debug NVIM_DEBUG_EDIT=tests/demo-files/index.ts`
- Other examples:
  - `make nvim-debug NVIM_DEBUG_EDIT=tests/demo-files/index.js`
  - `make nvim-debug NVIM_DEBUG_EDIT=README.md`
- Tune wait time for a single-file run:
  - `make nvim-debug NVIM_DEBUG_EDIT=README.md NVIM_DEBUG_WAIT=3000`
- Tune per-file wait in cycle mode:
  - `make nvim-debug-cycle NVIM_DEBUG_WAIT_PER_FILE=1000`

## Plugin Update Workflow

Use the provided script in this repo:

- Update plugins + check flagged changelog entries:
  - `python .claude/skills/update-nvim/scripts/nvim_update.py`
- Dry-run compare against lockfile baseline:
  - `python .claude/skills/update-nvim/scripts/nvim_update.py --dry-run`
- Compare against alternate baseline ref:
  - `python .claude/skills/update-nvim/scripts/nvim_update.py --base HEAD~1`

Expected exits:

- Exit `0`: no flagged potential breaking changes.
- Exit `1`: flagged commits found; inspect `.tmp/nvim-update-flagged-*.txt`.

## Cursor / Copilot Rules

Checked for agent rule files:

- `.cursor/rules/`: not present
- `.cursorrules`: not present
- `.github/copilot-instructions.md`: not present

Therefore no Cursor/Copilot instruction files are currently available to mirror.

## Code Organization Guidelines

- Keep startup/bootstrap logic in `init.lua` minimal.
- Keep editor/runtime config in `lua/configs/*.lua`.
- Keep plugin specs and plugin-specific overrides in `lua/plugins/*.lua`.
- Add local overrides here; upstream defaults usually belong to `../zion.nvim`.
- Prefer small, focused files over large all-in-one config files.

## Imports and Module Patterns

- Use `require("...")` with double quotes (existing dominant style).
- Keep `require` calls near top-level unless laziness/ordering is required.
- Common module pattern:
  - `local M = {}`
  - `function M.setup() ... end`
  - `return M`
- Use local aliases for frequently used APIs (`local map = vim.keymap.set`).

## Formatting Conventions

- Preserve existing style in each touched file.
- Do not reformat unrelated code.
- Favor readable multiline tables with trailing commas.
- Keep comments only for non-obvious behavior.
- Keep lines concise but prioritize readability over strict width.

## Types and Data Handling

- Lua is dynamic here; no strict type framework is configured.
- Guard optional integrations with `pcall`.
- Validate values before use when plugin APIs are optional/late-loaded.
- Use `tostring`/nil guards when logging mixed value types.

## Naming Conventions

- Variables/functions: `snake_case`.
- Module table name: `M`.
- File names: lowercase and purpose-driven (`debug.lua`, `treesitter.lua`).
- Autocmd groups: clear descriptive names.
- Env vars: uppercase, usually `NVIM_DEBUG_*` prefixed.

## Error Handling Guidelines

- Startup should degrade gracefully; avoid hard failures for optional paths.
- Use best-effort behavior for debug logging and notify wrappers.
- Use `pcall` for optional dependencies and non-critical side effects.
- Fail loudly only when a required path cannot continue safely.

## Keymap and Autocmd Guidelines

- Use `vim.keymap.set` (often via `local map = vim.keymap.set`).
- Provide `desc` when practical for discoverability.
- Buffer-local LSP maps should be created inside `LspAttach` callbacks.
- Terminal maps should be scoped/guarded to terminal buffers.

## Agent Workflow Expectations

- Before broad changes, inspect both this repo and `../zion.nvim`.
- If behavior appears missing locally, assume it may live upstream in `zion.nvim`.
- Keep changes minimal, targeted, and reversible.
- Do not manually edit `lazy-lock.json` unless explicitly doing plugin updates.
- For plugin-update tasks, use the provided Python update flow.

## Suggested Verification Checklist

After modifying config:

1. `nvim --headless +qa`
2. `make nvim-debug NVIM_DEBUG_EDIT=tests/demo-files/demo.md`
3. If filetype/plugin related: `make nvim-debug-cycle`
4. If plugin-lock changes were made: run update script and inspect report output

If all checks pass without new startup errors, the change is likely safe.
