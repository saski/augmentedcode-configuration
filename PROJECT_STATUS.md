# Augmentedcode Configuration - Project Status

**Last Updated**: 2026-03-27
**Overall Status**: 🟢 **100% Complete** - Config deduplication via symlinks

---

## Recent Changes

### 2026-03-27: Product management skills — skill-foundry catalog and docs index ✅

- **Catalog**: `.agents/skills/skill-foundry/agents/catalog-product-management.yaml` — 25 skills from `pmprompt/claude-plugin-product-management` with category, pattern, `overlap_with`, and sync provenance (see `skills-lock.json`).
- **Discovery**: `.agents/docs/skill-factory-skills.md` retitled to a general skills index; added Product management table mirroring each skill’s `description` frontmatter.

### 2026-03-26: Stop tracking Claude runtime notification state ✅

- **Issue**: `.claude/notifications/last_stop_notification` remained in the index after `.gitignore` gained `.claude/notifications/`; ignored paths do not untrack existing files.
- **Fix**: `git rm --cached .claude/notifications/last_stop_notification` so the file stays local-only and per-session; directory remains ignored.

### 2026-03-26: Skill-foundry vs repo skills — implementation plan drafted 📋

- **Research**: `thoughts/shared/research/2026-03-26-skill-foundry-vs-repo-skills.md` (governance gap vs minimal `SKILL.md` contract).
- **Plan**: `thoughts/shared/plans/2026-03-26-skill-foundry-repo-alignment.md` — document two-layer model, add `library-catalog.json`, validate filesystem vs catalog, keep skill-foundry bundle catalog separate; `skill-foundry` directory has no top-level `SKILL.md` (bundle exception encoded in validator spec).

### 2026-03-19: Base Rule Context Split Completed ✅

Split the rulebook into a universal base plus contextual modules:

- **base.md**: Trimmed to universal rules and added contextual loading for Python and Makefile repositories.
- **python-project.md** and **makefile-project.md**: Added canonical contextual rule modules for Python and Makefile projects.
- **Cursor wrappers**: Aligned `python-dev.mdc`, added `makefile-dev.mdc`, and updated `use-base-rules.mdc` to point at the canonical modules.

### 2026-03-18: Self-Improvement Mechanisms Hardened ✅

Closed 6 gaps in recursive self-improvement infrastructure:

- **base.md**: Added `<!-- version: 1.1 -->` header, fixed broken path to `ai-feedback-learning-loop.md`, added §16 Periodic Self-Audit.
- **ai-feedback-learning-loop.md**: Broadened scope from rules-only to cover skills, workflows, and commands. Added `PROJECT_STATUS.md` refresh to step 6.
- **Root shims**: Converted `AGENTS.md`, `GEMINI.md`, `CLAUDE.md` from copies to symlinks → `.agents/rules/base.md`.

### 2026-03-07: XP Skills Tool-Awareness Follow-up ✅

Tool-awareness documentation so every coding tool knows how to use skills:

- **base.md**: Added §9 Skills (Canonical Location and Use) — `.agents/skills/`, trigger-based use, skill format.
- **create-skill**: Storage Locations row for canonical shared path `.agents/skills/skill-name/` and symlink exposure.
- **Research**: `2026-03-06-commands-movable-as-skills.md` updated — canonical `.agents/skills/` and open question "where XP skills should live" resolved.

**Reference**: Validation report `thoughts/shared/research/2026-03-07-VALIDATION-REPORT-xp-skills-tool-awareness.md`.

### 2026-03-06: Config Deduplication via Symlinks ✅

Completed migration from copy-based sync to symlink-based configuration:

- **Eliminated**: ~50 duplicated files across `~/.cursor/`
- **Consolidated**: All skills moved to repository (skills-cursor)
- **Symlinked**: `~/.cursor/`, `~/.claude/`, and root configs now point to repo
- **Repurposed**: `sync-cursor-config.sh` → `setup-symlinks.sh`

**Impact**: Single source of truth established. All config edits in any tool propagate to repo automatically.

**Files**: See implementation plan at `thoughts/shared/plans/2026-03-06-config-deduplication-symlinks.md`

---

## Executive Summary

| Component | Status | Progress | Blocking |
| ----- | ----- | ---- | ---- |
| Cursor rules baseline | ✅ Complete | 100% | - |
| Workflow/rule documentation | 🟡 In Progress | 90% | - |
| Skills catalog | 🟡 In Progress | 80% | No |

**Current Readiness**: 🟢 Ready - Configuration repo is usable and actively maintained.

---

## ✅ Completed Components

### Test Doubles Skill (2026-02-19)

- Added project skill at `.cursor/skills/test-doubles-first/`.
- Added `SKILL.md` with decision tree favoring fake/stub/spy before mock.
- Added `examples.md` with minimal Python and TypeScript templates.
- Added `usage.md` with trigger prompts and copy-paste templates.
- Added language-specific quick chooser tables for Python and TypeScript dependency types.
- Added anti-pattern -> replacement table to speed up test review and refactoring decisions.
- Added PR review comment templates for fast, consistent code review feedback.
- Added `quick.md` single-page fast reference for test-double decisions and review.
- Reduced overlap between `usage.md` and `quick.md` to keep quick reference concise and detailed templates centralized.
- Added `SKILL.md` quick navigation section for faster in-file discovery.
- Reworked `examples.md` to Jest-first JavaScript/TypeScript patterns (fake, stub, spy, contract-focused mock).

---

## 🚧 In Progress

- Expanding reusable Cursor skills for common engineering workflows.

---

## 📋 Next Steps

1. Validate the new skill with real test-writing prompts.
2. Add additional test-double examples for async and error-handling scenarios.
3. Keep skills index and docs aligned with new skills.

---

## 🐛 Known Issues

- None currently tracked for the test-doubles skill.

---

## 📝 Notes

- Skill content is cross-platform and uses forward-slash paths.
- Skill intentionally encourages behavior/state assertions over interaction-heavy mocking.
