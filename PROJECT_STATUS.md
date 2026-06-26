# Augmentedcode Configuration - Project Status

**Last Updated**: 2026-06-26
**Overall Status**: 🟢 **Ready** - Canonical local workspace is `~/Code`; home-level tool symlinks point at this checkout and `make check` passes. Validation gaps, destructive-script bugs, and hook fail-open gaps closed; CI added.

---

## Executive Summary

| Component | Status | Notes |
|---|---|---|
| Universal rulebook (`base.md`) | ✅ Single source | Loaded once per Cursor session; cross-tool via `~/AGENTS.md`, `~/CLAUDE.md`, `~/.codex/AGENTS.md` |
| Cursor `.cursor/rules/` | ✅ Reduced 13 → 3 | Workspace-only: `use-base-rules`, `cursor-config-management`, `ai-feedback-learning-loop` |
| Workflows as skills | ✅ Migrated | `tdd`, `refactoring`, `diagnose`, `fic-*`, `project-status-maintenance` |
| Conditional rules | ✅ Single source | `.agents/rules/{python,makefile,react}-project.md`, loaded on demand per `base.md §2` |
| RTK guidance and hooks | ✅ Inline in `base.md §8`; shared hook wired | Recursive `@-include` removed; Codex and Claude Bash hooks use `.agents/hooks/rtk-rewrite.sh` |
| Skill governance | ✅ Aligned | Index, catalog, and provenance lock validated |
| Local healthchecks | ✅ Passing | `make check` covers tests, shell lint, skill validation, OpenSpec validation, symlink validation, and tracked-ignored reporting |
| Marmalade team rules | ⚠️ Pending | Still loading via Eventbrite team config; awaiting admin removal |

**Current Readiness**: Configuration is stable for daily use across Cursor, Codex, Claude Code, Gemini, Antigravity, and Langflow. Local saski repositories now live under `~/Code`; the old `~/saski` root has been retired to `~/saski.legacy-2026-06-17`.

---

## Recent Changes

### 2026-06-26: Hardening and validation gap closure ✅

Full review-driven remediation across validators, destructive sync scripts, the RTK hook, CI, and tests. Phased plan: `thoughts/shared/plans/2026-06-26-hardening-and-validation-gaps.md`.

- **Phase 0 (stop the bleeding):** Registered the untracked `onboard` Cursor skill in `.agents/docs/cursor-skills.md`; replaced the untracked root `AGENTS.md` regular file with a tracked symlink to `.agents/rules/base.md` (matching `CLAUDE.md`/`GEMINI.md`); fixed managed-binary resolution in `setup-symlinks.sh` so the `command -v` probe excludes `~/.agents/bin` (eliminated the openspec shim false-warning).
- **Phase 1 (validator blind spots):** `validate-skill-library.sh` and `validate-cursor-skills.sh` now do bidirectional `comm` (catch stale index/catalog entries, not just missing ones) and a git-tracking check (catch skill dirs on disk but not committed — the exact failure that broke `make check`). Awk index parser restricted to `[a-z0-9][a-z0-9-]*` skill names so wiring-table rows are no longer mis-parsed. Duplicated Ruby frontmatter block extracted into `lib/validate-skill-frontmatter.sh`. Consolidated the 4× accumulating EXIT trap to one.
- **Phase 2 (destructive-script hardening):** `sync-saski-repos.sh` now uses `set -euo pipefail`, guards `git rev-parse` (broken HEAD reports `error` + `failed=1` instead of silently mis-reporting `skip`/`current`), and parses manifest rows with `IFS=$'\t' read` instead of `set -- $line` (no word-split/glob). `sync-skill-factory.sh` rejects unknown options (a typo'd `--dry-run` no longer performs destructive `rm -rf`/`cp -R`) and writes the provenance lock atomically (temp + rename). `backup-cursor-config.sh` got `set -euo pipefail`, `#!/usr/bin/env bash`, and quoted `$BACKUP_DIR` in printed cleanup.
- **Phase 3 (hook fail-open):** `.agents/hooks/rtk-rewrite.sh` is now uniformly fail-open: a non-zero `--version` exit, malformed/empty stdin, and empty `rtk rewrite` output all exit 0 (passthrough) instead of aborting or emitting an empty command. Version probe switched to `grep -m1` to avoid `head` SIGPIPE under pipefail.
- **Phase 4 (CI + deps + rtk reconciliation):** Added `.github/workflows/check.yml` running a new `make ci-check` target (CI-portable subset) on push/PR. Added `command -v ruby`/`command -v python3` guards with friendly errors. Reconciled the RTK resolution order across `rtk-rewrite.sh`, `setup-symlinks.sh`, and `base.md §8` (added `/usr/local/bin/rtk`; documented the intentional shim-linking vs. runtime-resolution difference).
- **Phase 5 (test hygiene):** Temp-file leaks fixed via a shared global EXIT-trap cleanup pattern across all fixture-based tests; `sed -i ''` (BSD-only, would break ubuntu CI) replaced with portable `sed -i.bak`.

**Validation**: `make check` and `make ci-check` both pass. New tests: `tests/sync-saski-repos-test.sh`, `tests/sync-skill-factory-test.sh`, plus stale-entry/untracked/git-tracking cases in the validator tests and three fail-open cases in `tests/rtk-global-contract-test.sh`.

### 2026-06-17: Codex and Claude RTK hook wiring repaired ✅

- Removed the stale operational reference to `~/.codex/RTK.md`; RTK guidance remains inline in `base.md §8`.
- Added a Codex `hooks.json` template and taught `setup-symlinks.sh` to manage `~/.codex/hooks/rtk-rewrite.sh`.
- Updated Claude and Codex hook commands to use `$HOME` paths instead of machine-specific legacy paths.
- Extended the RTK contract test so Codex hook wiring and the absence of `RTK.md` references are checked.

### 2026-06-17: GitHub access simplified to the `saski` account ✅

- Simplified GitHub SSH rules so all GitHub access uses `git@github.com-saski:`.
- Removed path-based personal/work account selection from `base.md` and `github-host-alias`.
- Updated the healthcheck contract to reject `git@github.com-eventbrite:` in the universal rulebook.
- Updated local GitHub remotes for this checkout so both `origin` and `upstream` use the `github.com-saski` SSH alias.
- Updated related repository documentation and active routing metadata to use `~/Code` and `github.com-saski`.

### 2026-06-17: Canonical repo root migrated to `~/Code` ✅

- Moved local GitHub repositories from `~/saski` into `~/Code`.
- Kept the active `/Users/saski/Code/augmentedcode-configuration` checkout as canonical because it already owned the live home symlinks and had local worktree changes.
- Renamed the remaining clean duplicate checkout root from `~/saski` to `~/saski.legacy-2026-06-17`.
- Updated `setup-symlinks.sh`, `README.md`, `base.md`, and `saski-github-repos.tsv` so new setup and sync workflows default to `~/Code`.
- Refreshed managed home symlinks with `./setup-symlinks.sh setup`; `~/.agents/bin/openspec` now points at the current Node-managed OpenSpec executable.
- Registered Cursor-only review skills in `.agents/docs/cursor-skills.md` so Cursor skill validation reflects the current tree.

**Validation**: `make check` passes from `/Users/saski/Code/augmentedcode-configuration`.

### 2026-06-08: Canonical home symlink setup repaired 🟡

- Ran `REPO_DIR=/Users/saski/Code/augmentedcode-configuration ./setup-symlinks.sh setup`.
- Verified managed links with `make validate-symlinks`; home-level links now point at `/Users/saski/Code/augmentedcode-configuration`.
- Linked `~/.agents/bin/rtk` to `/opt/homebrew/bin/rtk`; `~/.agents/bin/rtk --version` reports `rtk 0.42.3`.
- Updated `Makefile` so `make validate-symlinks` passes the current checkout path through `REPO_DIR="$(pwd)"` instead of relying on the setup script's previous default `~/saski/augmentedcode-configuration`.

Remaining blockers:

- `make test` and `make validate-skills` fail because seven local sibling skill symlinks are broken: `complexity-review`, `hamburger-method`, `micro-steps-coach`, `story-splitting`, `mutation-testing-js`, `mutation-testing-python`, and `test-desiderata`.
- `make validate-openspec` fails because the `openspec` CLI is not installed in `/opt/homebrew/bin`, `~/.bun/bin`, `/usr/local/bin`, or the active shell `PATH`.
- A root `AGENTS.md` file exists as untracked local drift; the tracked root shims are `CLAUDE.md` and `GEMINI.md`, while home-level `~/AGENTS.md` now points directly to `.agents/rules/base.md`.

### 2026-05-28: Lustra governance and routing registration ✅

- Added `lustra` governance metadata to `.agents/skills/skill-foundry/agents/catalog-engineering.yaml`.
- Added `lustra` to the shared skill inventory index in `.agents/docs/skill-factory-skills.md`.
- Added `lustra` routing guidance in `.agents/docs/skill-domain-routing.md`.
- Added `/lustra` command entry to `README.md` so user-facing command docs match the registered skill set.

### 2026-05-25: Cross-tool rulebook deduplication and reorganization ✅

Three commits delivering single-source-of-truth and on-demand-skills architecture.

- **`c0355b1` Dedupe `base.md` sources**
  - Drop workspace-level `AGENTS.md` symlink (Cursor was loading 4 copies of `base.md`).
  - Re-point `~/AGENTS.md` and `~/.codex/AGENTS.md` directly to `.agents/rules/base.md`.
  - Embed `base.md` into `use-base-rules.mdc` via `@-include` so Cursor loads the rulebook once.
- **`6fc0c80` Reorganize agent rules**
  - `.cursor/rules/`: 13 → 3 files. Universal workflows (TDD, refactoring, debugging, FIC, project-status) moved to skills; conditional rules (Python, Makefile, React) consolidated to single source in `.agents/rules/`; redundant `context7.mdc` absorbed into `base.md §8`; Eventbrite-only `tlz-connection.mdc` migrated to `cursor-prompts` repo.
  - New skill `project-status-maintenance` registered in skill-factory index and catalog.
  - `~/.cursor/rules` symlink removed: Cursor rules now apply only when the saski repo is the active workspace; the universal rulebook reaches every Cursor workspace via `~/AGENTS.md`.
- **`bf6a4d2` Inline RTK into `base.md`**
  - Validation in Cursor and Codex showed the recursive `@RTK.md` include never expanded — RTK guidance was missing from agent context. Inlined as `### RTK` subsection in `base.md §8`.
  - Removed `.agents/rules/RTK.md`, `.claude/RTK.md`, `.claude/CLAUDE.md`, and the corresponding home-level symlinks.
  - Updated tests (`rtk-global-contract-test.sh`, `healthcheck-automation-test.sh`) to match the new contract.

**Validation**: All `make check` targets pass. Cursor + Codex CLI cross-tool functional tests confirm 4/4 rulebook sections accessible; RTK verified after the inline change.

---

### 2026-05-13: Healthcheck and four-principle base rules ✅

Compact `base.md` around four operating principles; added healthcheck contract; added Context7 CLI routing; registered local sibling skill references; managed tool PATH shims via `setup-symlinks.sh`.

### 2026-05-12: Shared RTK hook (`rtk-rewrite.sh`) and OpenSpec docs-first installation ✅

Canonical RTK hook at `.agents/hooks/rtk-rewrite.sh`. OpenSpec artifacts under `docs/openspec/`. `~/.agents/bin/rtk` shim added to setup script.

### 2026-04-13 → 2026-05-07: Skill governance and registration consolidation ✅

OpenSpec shared skill, skill inventory governance rules, MCP/Atlassian endpoint update, Codex RTK symlink, several skill catalog updates.

### Earlier (2026-04-06 → 2026-04-29) ✅

Self-contained skill library, validator and contract tests, repository validation and portability cleanup, `mattpocock/skills` and `Ar9av/obsidian-wiki` registration, repo hygiene pass, `personal-knowledge-routing` skill.

---

## Next Steps

1. **Marmalade team rules** — escalate to Eventbrite Engineering Cursor admin to remove the `marmalade-*` rules from team config (they are now available as a workspace skill in `~/eventbrite/listings-webapp/.cursor/skills/marmalade-design-system/`).
2. **`tlz-connection` PR** — push the `add-tlz-connection-rule` branch in `~/eventbrite/cursor-prompts` and open a PR.
3. **Benchmark monitored skills** (`pbt-pragmatic-adoption`, `creating-hooks`, `writing-statuslines`) after the next major model update.
4. **Keep governance aligned**: `components.lock.json`, the discovery index, and the skill-foundry catalogs whenever skills change.
5. **Monitor CI** once `.github/workflows/check.yml` runs on the first push/PR; expand `ci-check` toward the full `make check` if sibling-repo skill sources and the openspec CLI are provisioned on the runner.

---

## Known Issues

- **Marmalade team rules in Cursor**: the `marmalade-*` rules pushed by Eventbrite Engineering team config keep loading even when toggled off in the Cursor UI. Workaround in place (skill mirror in `listings-webapp/.cursor/skills/`); definitive fix requires removing the entries from team config upstream.
- **`@-include` in `.mdc` files is non-recursive**: Cursor expands a top-level `@path` reference but does not re-expand `@path` references inside the included file. Codex CLI shows the same behavior. RTK content was inlined into `base.md` to work around this; future cross-tool inclusions should avoid relying on recursive `@-include`.

---

## Notes

- This repo is the canonical source for AI agent configuration across Cursor, Codex, Claude Code, Gemini, Antigravity, and Langflow.
- Mutable runtime state (sessions, caches, workspace state, mutable credentials) intentionally stays local; only rules, skills, commands, workflows, hooks, and validation are versioned.
- After pulling, contributors must re-run `./setup-symlinks.sh setup` so the home-level symlinks are refreshed to the current targets, including `~/AGENTS.md` -> `base.md`, `~/.codex/AGENTS.md` -> `base.md`, and `~/.codex/hooks/rtk-rewrite.sh` -> `.agents/hooks/rtk-rewrite.sh`.
