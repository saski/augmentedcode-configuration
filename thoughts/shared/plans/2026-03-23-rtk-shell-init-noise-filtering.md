# RTK Activation Across Configured AI Tools for Noise Filtering

> Superseded on 2026-06-17: `RTK.md` is no longer part of the active configuration. Current RTK guidance lives inline in `.agents/rules/base.md` §8, and Codex/Claude Bash command rewriting is wired through `.agents/hooks/rtk-rewrite.sh` via `setup-symlinks.sh`.

## Overview
Enable RTK across all AI tools configured from `~/saski/augmentedcode-configuration` so command output is consistently noise-filtered in agent sessions while preserving existing symlink-managed configuration.

## Current State
- `rtk` is installed at `/opt/homebrew/bin/rtk`.
- This repo centrally manages configs for multiple tools via symlinks:
  - `.claude` (`~/.claude` symlink)
  - `.codex` (`~/.codex/config.toml`, `~/.codex/AGENTS.md` symlinked)
  - `.cursor` (`~/.cursor/cli-config.json` symlinked)
  - `.gemini` (`~/.gemini/*` symlinked)
- Claude RTK integration already exists (hook + `RTK.md`).
- Codex RTK is not configured yet (`rtk init --codex --show` reports missing global RTK artifacts).
- Active interactive shell is `zsh`; primary user shell config is `/Users/saski/.zshrc`.

## Desired End State
- Claude: existing RTK integration remains healthy.
- Codex: RTK guidance is enabled without breaking repo-managed symlinks.
- Cursor: RTK hook integration is installed and detectable by RTK status.
- Gemini: RTK integration is configured if supported by RTK; otherwise documented fallback through shell wrappers.
- Shell: minimal RTK helpers in `~/.zshrc` provide explicit opt-in usage.
- All changes are validated with automated checks, including symlink integrity.

## Out of Scope
- Rewriting the entire shell configuration.
- Broad alias overrides for core commands (`ls`, `cat`, `grep`) that alter normal developer workflows.
- Per-project RTK filter authoring/tuning.
- Unrelated refactors in `.agents/rules`, skills, or shell secret/token handling.

## Design Options and Tradeoffs
1. Shell-only RTK wrappers (`~/.zshrc`) without tool-specific init.
- Pros: Lowest risk to managed tool configs.
- Cons: Does not guarantee agent-native integration (hooks/instructions) for Cursor/Codex/Claude.

2. Hybrid multi-tool init (recommended): preserve existing Claude setup, add Codex/Cursor/Gemini RTK integration where supported, plus shell wrappers.
- Pros: Maximum coverage across configured tools with explicit verification.
- Cons: More moving parts; must guard against symlink side effects.

Recommendation: Option 2.

## Approach
Implement in small phases:
- First baseline symlink targets and current RTK status per tool.
- Preserve and verify existing Claude integration before/after any RTK init.
- Add Codex/Cursor/Gemini RTK activation with symlink-safe guards.
- Add minimal shell wrappers (`rtk-*`) for explicit opt-in fallback.
- Validate with RTK status commands, shell syntax checks, and repo symlink validation.

## Phased Changes

### Phase 1: Baseline and Symlink Safety Gate
Goal: Capture current RTK state and protect repo-managed symlinks before modifications.

Expected modifications:
- No file modifications expected.

Implementation notes:
- Record current status:
  - `rtk init --codex --show`
  - `rtk init --agent cursor --show`
  - `rtk init --show` (Claude)
- Verify critical symlinks point to repo:
  - `~/.codex/AGENTS.md`
  - `~/.codex/config.toml`
  - `~/.cursor/cli-config.json`
  - `~/.claude`
  - `~/.gemini/GEMINI.md`
- Define rollback checkpoint if any tool init breaks symlink expectations.

Automated success criteria:
- `readlink ~/.codex/AGENTS.md ~/.codex/config.toml ~/.cursor/cli-config.json ~/.gemini/GEMINI.md`
- `/Users/saski/Code/augmentedcode-configuration/setup-symlinks.sh validate`

### Phase 2: Preserve and Verify Claude RTK
Goal: Ensure existing Claude RTK remains functional and unchanged by later steps.

Expected modifications:
- No file modifications expected.

Implementation notes:
- Confirm hook, RTK.md, and settings are valid.
- Keep `.claude` as canonical RTK source for Claude in this repo.

Automated success criteria:
- `rtk init --show | rg -n "Hook:|RTK.md:|settings.json: RTK hook configured"`
- `test -f /Users/saski/Code/augmentedcode-configuration/.claude/hooks/rtk-rewrite.sh`
- `test -f /Users/saski/Code/augmentedcode-configuration/.claude/RTK.md`

### Phase 3: Codex RTK Initialization (Symlink-Safe)
Goal: Enable Codex RTK while preserving shared AGENTS symlink behavior.

Expected modifications:
- `/Users/saski/.codex/RTK.md` (or repo-equivalent target if RTK writes through symlinked path)
- Possible update to `/Users/saski/Code/augmentedcode-configuration/AGENTS.md` only if explicitly accepted

Implementation notes:
- Prefer non-destructive init path first (`rtk init -g --codex --show`, dry inspection).
- Run `rtk init -g --codex`.
- Re-check whether `~/.codex/AGENTS.md` remains a symlink to repo `AGENTS.md`.
- If RTK requires AGENTS content injection, keep insertion minimal and deterministic.

Automated success criteria:
- `rtk init --codex --show | rg -n "Global RTK.md: exists"`
- `test -f /Users/saski/.codex/RTK.md`
- `test -L /Users/saski/.codex/AGENTS.md`
- `/Users/saski/Code/augmentedcode-configuration/setup-symlinks.sh validate`

### Phase 4: Cursor and Gemini RTK Coverage
Goal: Ensure non-Claude tools managed by this repo also benefit from RTK when supported.

Expected modifications:
- Cursor hook/config files as managed by RTK init, if supported.
- Gemini RTK artifacts if RTK supports Gemini-specific init.
- If not supported, no file changes and explicit fallback to `rtk-*` shell wrappers.

Implementation notes:
- Cursor:
  - Check status with `rtk init --agent cursor --show`.
  - Run `rtk init -g --agent cursor` if not configured.
- Gemini:
  - Check availability of `--gemini` flow and resulting status.
  - If RTK has no Gemini hook path in this setup, document fallback and rely on shell wrappers.
- Re-run symlink validation after each tool init.

Automated success criteria:
- `rtk init --agent cursor --show | rg -n "Cursor hook:|Cursor hooks.json:"`
- `rtk init --gemini --show` (command succeeds)
- `/Users/saski/Code/augmentedcode-configuration/setup-symlinks.sh validate`

### Phase 5: Add Minimal Shell RTK Bootstrap
Goal: Provide explicit, tool-agnostic RTK commands for any agent or manual shell usage.

Expected modifications:
- `/Users/saski/.zshrc`
- Optional: `/Users/saski/.bashrc` and `/Users/saski/.bash_profile` if bash parity is requested.

Implementation notes:
- Add an isolated `RTK` block near end of `.zshrc`:
  - Guard on `command -v rtk`.
  - Namespaced aliases only:
    - `alias rtk-err='rtk err'`
    - `alias rtk-test='rtk test'`
    - `alias rtk-log='rtk log'`
    - `alias rtk-summary='rtk summary'`
- Do not override built-in/common commands.

Automated success criteria:
- `zsh -n /Users/saski/.zshrc`
- `zsh -ic 'alias rtk-err >/dev/null && alias rtk-test >/dev/null && echo ok'`
- If bash mirrored: `bash -n /Users/saski/.bashrc && bash -lc 'type rtk-err >/dev/null && echo ok'`

### Phase 6: End-to-End Verification
Goal: Confirm noise-filtering benefit and no config drift across managed tools.

Expected modifications:
- No additional file changes expected.

Implementation notes:
- Smoke test RTK commands and token analytics.
- Run canonical repo symlink validation and inspect any drift.

Automated success criteria:
- `rtk --version`
- `rtk err -- ls /tmp >/dev/null`
- `rtk summary -- echo 'build ok' | rg -n ".+"`
- `rtk gain`
- `/Users/saski/Code/augmentedcode-configuration/setup-symlinks.sh validate`
- `git -C /Users/saski/Code/augmentedcode-configuration status --short`

## Risks and Mitigations
- Risk: RTK init breaks symlinked managed config.
- Mitigation: Validate symlinks before/after each init with `setup-symlinks.sh validate`.

- Risk: Codex init mutates shared repo `AGENTS.md` unexpectedly.
- Mitigation: Check symlink target and review diff immediately after codex init.

- Risk: Inconsistent support across tools (especially Gemini/Cursor modes).
- Mitigation: Add explicit per-tool status checks and fallback path via shell wrappers.

## Rollback
- Remove shell RTK block from `/Users/saski/.zshrc` (and optional bash files).
- Run tool-specific uninstall where available:
  - `rtk init -g --codex --uninstall`
  - `rtk init -g --uninstall` (Claude path)
  - Cursor/Gemini uninstall if supported by installed RTK version.
- Re-run `/Users/saski/Code/augmentedcode-configuration/setup-symlinks.sh setup` then `validate` to restore canonical links.

## Implementation Progress (2026-03-23)

- [x] Phase 1: Baseline and Symlink Safety Gate
- [x] Phase 2: Preserve and Verify Claude RTK
- [x] Phase 3: Codex RTK Initialization (Symlink-Safe)
- [x] Phase 4: Cursor and Gemini RTK Coverage
- [x] Phase 5: Add Minimal Shell RTK Bootstrap
- [x] Phase 6: End-to-End Verification

### Notes

- `rtk init -g --codex` created `~/.codex/RTK.md` but replaced `~/.codex/AGENTS.md` symlink with a regular file.
- Symlink-safe recovery applied:
  - Added `@RTK.md` to repo-managed `/Users/saski/Code/augmentedcode-configuration/.agents/rules/base.md` (target of `AGENTS.md` symlink).
  - Re-ran `/Users/saski/Code/augmentedcode-configuration/setup-symlinks.sh setup` to restore canonical symlinks.
- Final validation confirms all managed symlinks are valid and Codex RTK is active.
