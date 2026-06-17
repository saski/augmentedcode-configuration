# Augmentedcode Configuration - Project Status

**Last Updated**: 2026-06-17
**Overall Status**: 🟢 **Ready** - Canonical local workspace is `~/Code`; home-level tool symlinks point at this checkout and `make check` passes.

---

## Executive Summary

| Component | Status | Notes |
|---|---|---|
| Universal rulebook (`base.md`) | ✅ Single source | Loaded once per Cursor session; cross-tool via `~/AGENTS.md`, `~/CLAUDE.md`, `~/.codex/AGENTS.md` |
| Cursor `.cursor/rules/` | ✅ Reduced 13 → 3 | Workspace-only: `use-base-rules`, `cursor-config-management`, `ai-feedback-learning-loop` |
| Workflows as skills | ✅ Migrated | `tdd`, `refactoring`, `diagnose`, `fic-*`, `project-status-maintenance` |
| Conditional rules | ✅ Single source | `.agents/rules/{python,makefile,react}-project.md`, loaded on demand per `base.md §2` |
| RTK guidance | ✅ Inline in `base.md §8` | Recursive `@-include` removed; cross-tool verified |
| Skill governance | ✅ Aligned | Index, catalog, and provenance lock validated |
| Local healthchecks | ✅ Passing | `make check` covers tests, shell lint, skill validation, OpenSpec validation, symlink validation, and tracked-ignored reporting |
| Marmalade team rules | ⚠️ Pending | Still loading via Eventbrite team config; awaiting admin removal |

**Current Readiness**: Configuration is stable for daily use across Cursor, Codex, Claude Code, Gemini, Antigravity, and Langflow. Local saski repositories now live under `~/Code`; the old `~/saski` root has been retired to `~/saski.legacy-2026-06-17`.

---

## Recent Changes

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

1. **Resolve root `AGENTS.md` drift** — either remove the untracked local file or intentionally track the root shim again with matching documentation.
2. **Marmalade team rules** — escalate to Eventbrite Engineering Cursor admin to remove the `marmalade-*` rules from team config (they are now available as a workspace skill in `~/eventbrite/listings-webapp/.cursor/skills/marmalade-design-system/`).
3. **`tlz-connection` PR** — push the `add-tlz-connection-rule` branch in `~/eventbrite/cursor-prompts` and open a PR.
4. **Benchmark monitored skills** (`pbt-pragmatic-adoption`, `creating-hooks`, `writing-statuslines`) after the next major model update.
5. **Keep governance aligned**: `components.lock.json`, the discovery index, and the skill-foundry catalogs whenever skills change.

---

## Known Issues

- **Root `AGENTS.md` untracked drift**: `/Users/saski/Code/augmentedcode-configuration/AGENTS.md` is currently an untracked regular file, while `~/AGENTS.md` correctly points to `.agents/rules/base.md`.
- **Marmalade team rules in Cursor**: the `marmalade-*` rules pushed by Eventbrite Engineering team config keep loading even when toggled off in the Cursor UI. Workaround in place (skill mirror in `listings-webapp/.cursor/skills/`); definitive fix requires removing the entries from team config upstream.
- **`@-include` in `.mdc` files is non-recursive**: Cursor expands a top-level `@path` reference but does not re-expand `@path` references inside the included file. Codex CLI shows the same behavior. RTK content was inlined into `base.md` to work around this; future cross-tool inclusions should avoid relying on recursive `@-include`.

---

## Notes

- This repo is the canonical source for AI agent configuration across Cursor, Codex, Claude Code, Gemini, Antigravity, and Langflow.
- Mutable runtime state (sessions, caches, workspace state, mutable credentials) intentionally stays local; only rules, skills, commands, workflows, hooks, and validation are versioned.
- After pulling, contributors must re-run `./setup-symlinks.sh setup` so the home-level symlinks are refreshed to the new targets (`~/AGENTS.md` → `base.md`, `~/.codex/AGENTS.md` → `base.md`, removal of `~/.cursor/rules`, `~/.codex/RTK.md`, `~/.claude/RTK.md`, `~/.claude/CLAUDE.md`).
