# Hardening and Validation Gap Closure Plan

## Overview

A full review of the repository surfaced verified `make check` failures, correctness bugs in destructive sync scripts, one-directional validators that miss stale/untracked skills, a hook that is not uniformly fail-open, no CI, and test-hygiene defects. This plan closes those gaps in safe, verifiable phases. Each phase leaves `make check` green.

## Current State

- `make check` is RED: `validate-cursor-skills` aborts because the `onboard` Cursor skill is untracked and missing from `.agents/docs/cursor-skills.md`.
- Root `AGENTS.md` is an untracked regular file, byte-identical to `.agents/rules/base.md`; tracked root shims are `CLAUDE.md` and `GEMINI.md` (symlinks to `base.md`).
- `make validate-symlinks` warns "openspec executable not found in known locations" even though `~/.agents/bin/openspec` is correctly linked to the nvm binary. The `command -v` probe resolves to the managed shim itself (circular), so the hardcoded candidate list never matches.
- `sync-saski-repos.sh` uses `set -u` only (no `-e`/`pipefail`); a `git rev-parse` failure silently reports a repo as `current` (false positive).
- `sync-skill-factory.sh` does not reject unknown options; a typo'd `--dry-run` performs a real destructive `rm -rf` + `cp -R`.
- `sync-saski-repos.sh` parses manifest lines with `set -- $line` (word-split + glob).
- `validate-skill-library.sh` and `validate-cursor-skills.sh` use one-directional `comm -23`; stale index/catalog/routing entries are invisible. No validator checks git-tracking of skill dirs.
- The two validators duplicate a Ruby frontmatter block that can drift.
- `.agents/hooks/rtk-rewrite.sh` is fail-open for missing `rtk`/`jq` but not for a non-zero `--version` exit, malformed stdin, or empty rewrite output.
- No `.github/` CI; `ruby`/`python3` hard deps have no guards; pre-commit hard-blocks without `openspec`/`ruby`.
- Three divergent "known locations" lists for `rtk` (hook PATH-first, setup homebrew-first, rules).
- Temp-file leaks in tests (no trap, or `RETURN` vs `EXIT`); `sed -i ''` is macOS-only in one test.

## Desired End State

- `make check` is green and stays green after every phase.
- Validators detect stale index/catalog/routing entries AND untracked skill dirs (bidirectional + git-tracking).
- Destructive sync scripts fail loud on errors, reject unknown options, and parse the manifest safely.
- The RTK hook fails open uniformly.
- CI runs `make check` on push/PR.
- Hard runtime deps report friendly errors when missing.
- Tests clean up temp files and are portable.

## Out Of Scope

- Populating `docs/openspec/` with specs/changes (the OpenSpec scaffold is intentionally empty).
- Switching catalog parsing from regex to a YAML parser (lower leverage; current regex works for today's names).
- Rewriting tests from string-presence to behavioral assertions (larger effort; noted for future).
- Resolving Eventbrite Marmalade team rules (organizational, out of repo control).
- Changing universal rulebook content beyond validation needs.

## Phase 0: Stop The Bleeding (get make check green)

Low-risk surgical edits, no new tests.

1. Register `onboard` in `.agents/docs/cursor-skills.md` inventory (it is a legitimate `ide` skill).
2. Replace the untracked root `AGENTS.md` regular file with a tracked symlink `AGENTS.md -> .agents/rules/base.md`, matching `CLAUDE.md` and `GEMINI.md`. A symlink cannot drift.
3. Fix managed-binary resolution in `setup-symlinks.sh` so `command -v` probes with `$HOME/.agents/bin` stripped from PATH (avoids the circular self-match), eliminating the openspec false-warning and hardening rtk resolution.

Success criteria:

- `make check` exits 0.
- `make validate-symlinks` reports `✓` for both `rtk` and `openspec` shims (no "not found in known locations" warning).
- `git status --short AGENTS.md` shows it as a tracked symlink, not untracked drift.

## Phase 1: Validator Blind Spots (TDD)

Close the gaps that let today's failure slip through.

1. Failing test: a stale index entry pointing at a non-existent skill is flagged by `validate-skill-library.sh`.
2. Failing test: a stale cursor-skills index entry is flagged by `validate-cursor-skills.sh`.
3. Failing test: an untracked skill dir is flagged.
4. Implement bidirectional `comm` (add `comm -13` direction) in both validators.
5. Implement a git-tracked-skill check in `validate-skill-library.sh` and `validate-cursor-skills.sh`.
6. Extract the duplicated Ruby frontmatter block into a shared helper sourced by both validators.

Success criteria:

- New tests pass; `make check` stays green.
- A deliberately stale index entry now fails validation.

## Phase 2: Destructive-Script Hardening (TDD + small safe steps)

Highest-risk code; expand-contract where applicable.

1. Failing test: `sync-saski-repos.sh` exits non-zero and does NOT report `current` when `git rev-parse` fails.
2. Add `set -euo pipefail` to `sync-saski-repos.sh`; guard `rev-parse` calls.
3. Replace `set -- $line` with `IFS=$'\t' read -r ...` for safe manifest parsing.
4. Failing test: `sync-skill-factory.sh --dryrun` (typo) is rejected, not executed as a real sync.
5. Add unknown-option rejection to `sync-skill-factory.sh`.
6. Make the provenance lock write atomic (temp + rename) in `sync-skill-factory.sh`.
7. Add `set -euo pipefail` and `#!/usr/bin/env bash` to `backup-cursor-config.sh`; quote `$BACKUP_DIR` in printed cleanup.

Success criteria:

- New tests pass; `make check` and `make lint-shell` stay green.
- A typo'd dry-run no longer performs destructive writes.

## Phase 3: Hook Hardening (TDD)

Make `.agents/hooks/rtk-rewrite.sh` uniformly fail-open.

1. Failing test: hook exits 0 (fail-open) when `rtk --version` exits non-zero.
2. Failing test: hook exits 0 when stdin is empty/malformed.
3. Failing test: hook does NOT emit an empty command when `rtk rewrite` outputs empty string.
4. Wrap the version probe and stdin parse in fail-open guards; treat empty rewrite output as "no rewrite".

Success criteria:

- New tests pass; existing `tests/rtk-global-contract-test.sh` stays green.

## Phase 4: CI And Dependency Guards

1. Add `.github/workflows/check.yml` running `make check` on push and PR.
2. Add `command -v ruby` / `command -v python3` guards with friendly messages to the validators/sync scripts.
3. Reconcile the `rtk` known-locations order across `rtk-rewrite.sh`, `setup-symlinks.sh`, and `AGENTS.md` §8 to a single documented resolution order.

Success criteria:

- CI workflow is valid YAML and would run `make check`.
- Missing `ruby`/`python3` produces a friendly error, not a raw traceback.
- The `rtk` resolution order is identical across all three locations.

## Phase 5: Test Hygiene

1. Fix temp-file leaks: add `trap ... EXIT` to `tests/rtk-global-contract-test.sh` and `tests/openspec-install-test.sh`; change `trap ... RETURN` to `EXIT` in the two fixture-based tests.
2. Replace `sed -i ''` with a portable `sed -i.bak` pattern in `tests/rtk-global-contract-test.sh`.
3. Collapse the 4x accumulating EXIT trap in `validate-skill-library.sh` to a single definition.

Success criteria:

- `make check` stays green; no fixtures left behind in `$TMPDIR` after a failing test run.

## Final Verification

```bash
make check
```

Success criteria:

- `make check` exits 0.
- `PROJECT_STATUS.md` updated to reflect closed gaps.
