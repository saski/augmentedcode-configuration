# Augmentedcode Configuration - Project Status

**Last Updated**: 2026-05-25
**Overall Status**: 🟢 **Ready** - Universal rulebook is single-source and cross-tool verified; agent context reduced significantly after rule/skill reorganization

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
| Local healthchecks | ✅ Passing | `make check` covers tests, shell lint, skill validation, symlink validation |
| Marmalade team rules | ⚠️ Pending | Still loading via Eventbrite team config; awaiting admin removal |

**Current Readiness**: Configuration is stable for daily use across Cursor, Codex, Claude Code, and Gemini. Cross-tool RTK access verified after the 2026-05-25 RTK inline change. Marmalade rules persist in Cursor team config and need an organizational follow-up.

---

## Recent Changes

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
4. **Upstream skill-factory improvements** that should be shared back to the source repository.
5. **Keep governance aligned**: `components.lock.json`, the discovery index, and the skill-foundry catalogs whenever skills change.

---

## Known Issues

- **Marmalade team rules in Cursor**: the `marmalade-*` rules pushed by Eventbrite Engineering team config keep loading even when toggled off in the Cursor UI. Workaround in place (skill mirror in `listings-webapp/.cursor/skills/`); definitive fix requires removing the entries from team config upstream.
- **`@-include` in `.mdc` files is non-recursive**: Cursor expands a top-level `@path` reference but does not re-expand `@path` references inside the included file. Codex CLI shows the same behavior. RTK content was inlined into `base.md` to work around this; future cross-tool inclusions should avoid relying on recursive `@-include`.

---

## Notes

- This repo is the canonical source for AI agent configuration across Cursor, Codex, Claude Code, Gemini, Antigravity, and Langflow.
- Mutable runtime state (sessions, caches, workspace state, mutable credentials) intentionally stays local; only rules, skills, commands, workflows, hooks, and validation are versioned.
- After pulling, contributors must re-run `./setup-symlinks.sh setup` so the home-level symlinks are refreshed to the new targets (`~/AGENTS.md` → `base.md`, `~/.codex/AGENTS.md` → `base.md`, removal of `~/.cursor/rules`, `~/.codex/RTK.md`, `~/.claude/RTK.md`, `~/.claude/CLAUDE.md`).
