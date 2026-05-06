# XP Skills Structure and Tool Awareness — Implementation Plan

## Overview

Make “every coding tool” that loads this repo’s rules aware of where skills live and how to use them: document skills in the canonical rulebook (base.md), align create-skill and prior research with `.agents/skills/`, and leave a single source of truth so Cursor, Codex, Antigravity, and any tool using base.md get the same guidance.

## Current State Analysis

- **Canonical skills**: `.agents/skills/` exists; 8 XP skills plus test-doubles-first, cwv-improvement-planner, ownership-routing live there. Symlinks (`setup-symlinks.sh`) point `~/.cursor/skills` and `~/$tool/skills` (for tools in `TOOLS_WITH_SKILLS`) at repo `.agents/skills/`.
- **Documentation**: README and `.cursor/rules/cursor-config-management.mdc` describe `.agents/skills/` and symlinks. **`.agents/rules/base.md` does not mention skills or `.agents/skills/`** — so tools that only load base (e.g. via AGENTS.md/CLAUDE.md/GEMINI.md) have no guidance.
- **create-skill**: `.cursor/skills-cursor/create-skill/SKILL.md` documents storage as `~/.cursor/skills/` and `.cursor/skills/` only; it does not mention `.agents/skills/` as the canonical shared location for this repo.
- **Research**: `thoughts/shared/research/2026-03-06-commands-movable-as-skills.md` line 24 says “Skills live in `.cursor/skills/*/SKILL.md`” — outdated; canonical location is `.agents/skills/`.

**Constraint**: No behavior change to symlinks or skill content; only documentation and one new section in base.md.

## Desired End State

1. **base.md**: Contains a short “Skills” section stating (1) skills live in `.agents/skills/`, (2) they are trigger-based (apply when the user’s request matches the skill’s description), (3) when relevant, read that skill’s `SKILL.md` and follow its instructions.
2. **create-skill**: Storage locations table (or equivalent) includes `.agents/skills/` as the canonical shared/project location for this repo (and when working in augmentedcode-configuration).
3. **Research doc**: `2026-03-06-commands-movable-as-skills.md` states that skills live in `.agents/skills/` and that `.cursor/skills` is a symlink to it.
4. **Verification**: `./setup-symlinks.sh validate` still passes; grep/lint checks confirm new/updated text; no open questions left in the plan.

## What We're NOT Doing

- Adding or changing symlinks or `setup-symlinks.sh` logic.
- Changing any skill’s `SKILL.md` content (only create-skill meta-skill is updated).
- Introducing a separate rule file for “how to use skills” (guidance lives in base.md only).
- Modifying Cursor-specific skill injection or product behavior.

## Implementation Approach

1. Add one new section to `.agents/rules/base.md`: “Skills” (location + trigger-based use + read-and-follow).
2. Update `.cursor/skills-cursor/create-skill/SKILL.md`: add canonical shared location `.agents/skills/` and when it applies.
3. Update `thoughts/shared/research/2026-03-06-commands-movable-as-skills.md`: fix the “Skills live in” sentence and mention symlink.

---

## Phase 1: Add Skills section to base.md

### Overview

Ensure the canonical rulebook tells every tool where skills live and how to use them (trigger-based; read SKILL.md when relevant).

### Changes Required

#### 1. `.agents/rules/base.md`

**File**: `.agents/rules/base.md`
**Location**: After section 14 (Antigravity Workflows), add new section 15.

**Add**:

```markdown
## 15. Skills

- **Location**: Shared skills live in **`.agents/skills/`** (canonical). Each tool (Cursor, Codex, Antigravity, etc.) may expose them via symlinks (e.g. `~/.cursor/skills` → repo `.agents/skills/`).
- **Use**: Skills are **trigger-based**. When the user’s request matches a skill’s description (e.g. “technical debt”, “code review”, “Mikado Method”), read that skill’s `SKILL.md` from `.agents/skills/<skill-name>/SKILL.md` and follow its instructions.
- **Scope**: Prefer using a skill when the request clearly matches its description; do not invoke skills for unrelated tasks.
```

### Success Criteria

- [ ] New section 15 “Skills” exists in `base.md`.
- [ ] Section states location (`.agents/skills/`), trigger-based use, and read-and-follow.
- [ ] No other sections renumbered or removed.
- [ ] `make validate` (if present in repo) or equivalent still passes.

---

## Phase 2: Update create-skill SKILL.md with canonical shared path

### Overview

Document `.agents/skills/` as the canonical shared skill location for this repo so skill authors don’t only see `~/.cursor/skills` and `.cursor/skills/`.

### Changes Required

#### 1. `.cursor/skills-cursor/create-skill/SKILL.md`

**File**: `.cursor/skills-cursor/create-skill/SKILL.md`
**Target**: “Storage Locations” table (around lines 52–56) and optionally one sentence in “Before You Begin” or “Target location”.

**Change**: Add a row (or subsection) for the shared/canonical location:

- **Option A (table only)**: Add a third row to the Storage Locations table:

| Type     | Path                     | Scope                                              |
|----------|--------------------------|----------------------------------------------------|
| Personal | ~/.cursor/skills/…       | Available across all your projects                 |
| Project  | .cursor/skills/…         | Shared with anyone using the repository            |
| **Shared (this repo)** | **.agents/skills/skill-name/** | Canonical in augmentedcode-configuration; all tools symlink here |

- **Option B (table + one line)**: Same table change plus one sentence after the table: “In **augmentedcode-configuration**, the canonical shared root is `.agents/skills/`; create or edit skills there so all tools (Cursor, Codex, Antigravity) use the same source.”

Use **Option B** so both the table and the repo-specific case are clear.

Also update the “Target location” bullet in “Before You Begin” (around line 15) to mention the shared option: e.g. “Should this be a personal skill (~/.cursor/skills/), a project skill (.cursor/skills/), or in this repo’s shared root (.agents/skills/)?”

### Success Criteria

- [ ] Storage Locations table includes `.agents/skills/` as canonical shared location for this repo.
- [ ] “Before You Begin” or “Target location” mentions the shared option.
- [ ] No removal of existing Personal/Project rows; only addition/clarification.

---

## Phase 3: Fix research doc “Skills live in” and symlink

### Overview

Align the older research document with the current architecture so it doesn’t say skills live under `.cursor/skills/` only.

### Changes Required

#### 1. `thoughts/shared/research/2026-03-06-commands-movable-as-skills.md`

**File**: `thoughts/shared/research/2026-03-06-commands-movable-as-skills.md`
**Target**: Line 24 — the **Source** sentence: “Commands live in … Skills live in `.cursor/skills/*/SKILL.md` with frontmatter …”

**Change**: Replace the “Skills live in …” part with: “Skills live in **`.agents/skills/<name>/SKILL.md`** (canonical); in Cursor, `~/.cursor/skills` is a symlink to the repo’s `.agents/skills/`. Skills use frontmatter `name` and `description`; the description is used for trigger-based application.”

If there is a “Source” or “Reference” line that only mentions `.cursor/skills/`, update it to mention `.agents/skills/` and the symlink.

### Success Criteria

- [ ] The research doc no longer states that skills live only in `.cursor/skills/*/SKILL.md`.
- [ ] It states that the canonical location is `.agents/skills/` and that `.cursor/skills` (or `~/.cursor/skills`) is a symlink to it.
- [ ] Rest of the doc remains consistent (no contradictory “skills live in .cursor/skills” elsewhere).

---

## Testing Strategy

- **Symlinks**: Run `./setup-symlinks.sh validate`; must still pass.
- **base.md**: Grep for “Skills” and “.agents/skills” in `base.md`; section 15 present and readable.
- **create-skill**: Grep for “.agents/skills” in `create-skill/SKILL.md`; table and target location mention shared path.
- **Research**: Grep for “.agents/skills” and “symlink” in `2026-03-06-commands-movable-as-skills.md`; no remaining “Skills live in .cursor/skills” only.

## References

- Research: `thoughts/shared/research/2026-03-07-xp-skills-structure-and-tool-awareness.md`
- Prior plan: `thoughts/shared/plans/2026-03-06-xp-commands-to-skills.md`
- Rulebook: `.agents/rules/base.md`
- create-skill: `.cursor/skills-cursor/create-skill/SKILL.md`
- Symlinks: `setup-symlinks.sh`
- Cursor config rule: `.cursor/rules/cursor-config-management.mdc`
