# Skill-Factory Skills List and Tool Awareness — Implementation Plan

## Overview

Give every coding tool (Cursor, Codex, Antigravity, and any consumer of this repo’s rules) explicit awareness of which skills come from skill-factory and their purpose, so agents can match user requests to the right skill. Today, rules say “consider all skills in `.agents/skills/`” but do not enumerate skill-factory skills or when to use them; there is no persisted list (see research). This plan adds a single maintained list and wires it into the rulebook and docs.

## Current State Analysis

- **Research** ([thoughts/shared/research/2026-03-08-skill-factory-available-skills-list.md](thoughts/shared/research/2026-03-08-skill-factory-available-skills-list.md)): No committed list of skill-factory skills; discovery is runtime (sync script, skill-factory `./skills status`). Enumeration of `output_skills/**/SKILL.md` yields 28 skills with names and categories; purpose (description) lives only in each skill’s `SKILL.md` frontmatter.
- **Rules**: `.agents/rules/base.md` §9 states canonical location (`.agents/skills/`), two sources (native + skill-factory), and trigger-based use (“when the user’s request matches a skill’s description”). It does not list skill-factory skills or their purpose. `.cursor/rules/cursor-config-management.mdc` mentions skill-factory skills (synced via `./pull-and-sync-skills.sh`) but does not enumerate them.
- **README**: Has tables for native XP skills and native Cursor skills with purpose; “Syncing skills from skill-factory” explains sync but does not list the 28 skill-factory skills or their purpose.
- **Tools**: Cursor loads rules from `.cursor/rules/` and base from `use-base-rules.mdc`. Codex/other tools use base.md via AGENTS.md/CLAUDE.md. No tool currently has a single reference for “which skills are from skill-factory and when to use them.”

## Canonical reference and no duplication

- **`.agents` is the single source of truth** for skills and rules. All tooling (Cursor, Codex, Antigravity, etc.) should use `.agents` as the canonical reference.
- **No duplication**: The skill-factory skills list exists only in `.agents/docs/skill-factory-skills.md`. Other files (`.cursor/rules/`, README) do not duplicate the table or the list; they only point to `.agents` (or to the rulebook in `.agents/rules/base.md` which in turn points to the list).
- **One link to the list**: The path to the list appears in one place in the rulebook (base.md §9). Cursor-specific rules and README point to base.md or to `.agents` so they never repeat the list path or content.

## Desired End State

1. **Single list in .agents**: One maintained document at `.agents/docs/skill-factory-skills.md` lists all skill-factory skills (name, category, purpose). Purpose = the skill’s “when to use” (from `SKILL.md` frontmatter `description`). List is updated when new skills are added (e.g. after sync). No copy of this list elsewhere.
2. **Rulebook in .agents**: base.md §9 references the list (single occurrence of the list path in rules). Cursor rules point to base.md / .agents, not to the list file directly, so the canonical reference stays inside `.agents`.
3. **README**: One pointer to `.agents` (e.g. “Skill-factory skills and purpose: see `.agents/docs/skill-factory-skills.md` and base.md §9”). No table duplication in README.
4. **Verification**: List file exists under `.agents`; base.md references it; cursor-config and README reference .agents/base.md only; no broken paths.

## What We're NOT Doing

- Changing `sync-skill-factory.sh` behavior or adding manifest generation to skill-factory repo.
- Automating list generation in this plan (optional follow-up: sync or a script could regenerate the list from `SKILL.md` frontmatter).
- Modifying any skill’s `SKILL.md` content in skill-factory or in native skills.

## Implementation Approach

1. Create the canonical list only under `.agents/docs/skill-factory-skills.md` (name + category + purpose for the 28 skills). Populate purpose from each skill’s `SKILL.md` frontmatter (one-time extraction when skill-factory or symlinks are available).
2. Reference that list only from `.agents/rules/base.md` §9 (single place where the list path appears in rules). Have cursor-config point to base.md / .agents so Cursor uses the same canonical reference without duplicating the link.
3. Update README with one pointer to `.agents` (the list and/or base.md §9); no table or list duplication.

---

## Phase 1: Create the skill-factory skills list document

### Overview

Add a single source of truth that enumerates skill-factory skills with name, category, and purpose (when to use). This gives tools a scannable reference without parsing the filesystem.

### Changes Required

#### 1. New file: `.agents/docs/skill-factory-skills.md`

**Path**: `.agents/docs/skill-factory-skills.md`

**Content** (structure):

- Short intro: skills in this list are synced from [skill-factory](https://github.com/saski/skill-factory) into `.agents/skills/` via `./pull-and-sync-skills.sh`. When the user’s request matches a purpose below, read that skill’s `SKILL.md` and follow its instructions.
- Table: **Skill** | **Category** | **Purpose** (one line per skill).

**Data source**:

- **Names and categories**: Use the table from [research 2026-03-08](thoughts/shared/research/2026-03-08-skill-factory-available-skills-list.md) (28 skills by category: tools, testing, practices, developer-tools, design, ai).
- **Purpose**: From each skill’s `SKILL.md` frontmatter `description` (the “Use when …” part). If skill-factory repo is available: run a one-off extraction (e.g. from skill-factory root: for each `output_skills/*/*/SKILL.md`, read `description:` line). If not: copy descriptions from skill-factory `SKILL.md` files when you have them, or leave placeholder “See SKILL.md” and fill in as skills are synced.

**Example table rows** (format only; actual purpose text from SKILL.md):

```markdown
| Skill | Category | Purpose |
|-------|----------|---------|
| tdd | testing | Use when writing new code or practicing TDD. |
| refactoring | practices | Use when refactoring or improving design. |
...
```

#### 2. Ensure `.agents/docs` exists

- Create directory `.agents/docs/` if it does not exist (no other files required in this phase).

### Success Criteria

- [x] `.agents/docs/skill-factory-skills.md` exists.
- [x] File contains a table with columns Skill, Category, Purpose for all 28 skills from the research.
- [x] Purpose column is populated (from SKILL.md extraction or placeholder “See .agents/skills/<name>/SKILL.md” until filled).
- [x] Intro mentions sync and “when the user’s request matches a purpose, read that skill’s SKILL.md.”

---

## Phase 2: Reference the list from .agents only; Cursor points to .agents

### Overview

Keep the list path only in the canonical rulebook (base.md in .agents). Cursor rules point to .agents/base.md so all tools use the same single reference; no duplication of the list path.

### Changes Required

#### 1. `.agents/rules/base.md`

**File**: `.agents/rules/base.md`

**Change**: In §9 “Skills (Canonical Location and Use)”, after the “Two sources” bullet, add:

- “Skill-factory skills (synced into `.agents/skills/`) are listed with their purpose in [.agents/docs/skill-factory-skills.md](.agents/docs/skill-factory-skills.md). Use that list when matching user requests to skills; then read the skill’s `SKILL.md` and follow its instructions.”

This is the only place in the rulebook that links to the list.

#### 2. `.cursor/rules/cursor-config-management.mdc`

**File**: `.cursor/rules/cursor-config-management.mdc`

**Change**: In the “Shared Skills” bullet (or immediately after it), add one sentence that points to the canonical reference in .agents (do not repeat the list path):

- Add: “For skill-factory skills and when to use them, follow the Skills section in `.agents/rules/base.md` (canonical); it links to the list in `.agents/docs/`.”

So Cursor uses .agents as the single reference; the list path appears only in base.md.

### Success Criteria

- [ ] base.md §9 contains the single reference to `.agents/docs/skill-factory-skills.md` and “use that list when matching user requests.”
- [x] cursor-config-management.mdc references base.md / .agents only (no duplicate link to the list file).
- [x] Link in base.md is valid (path from repo root: `.agents/docs/skill-factory-skills.md`).

---

## Phase 3: Update README to point to .agents only (no duplication)

### Overview

README gives readers and tools a single pointer to the canonical reference in `.agents`. No table or list is copied into README.

### Changes Required

#### 1. `README.md`

**File**: `README.md`

**Change**: In the “Syncing skills from skill-factory” subsection (or in “Cursor Skills” / “XP Skills”), add one short sentence that points to .agents:

- Add: “Skill-factory skills and their purpose (for matching user requests) are listed in [.agents/docs/skill-factory-skills.md](.agents/docs/skill-factory-skills.md); usage is defined in [.agents/rules/base.md](.agents/rules/base.md) §9.”

Do not add a table or copy of the list; README only references the canonical location under `.agents`.

### Success Criteria

- [x] README contains exactly one pointer to the list (`.agents/docs/skill-factory-skills.md`) and one to base.md §9.
- [x] No table or list content is duplicated in README.

---

## Testing Strategy

- **No automated tests** in repo for docs/rules; verification is manual and file-based.
- **Checklist**: (1) List exists only in `.agents/docs/skill-factory-skills.md` (28 rows). (2) Only base.md §9 contains the link to the list. (3) cursor-config points to base.md/.agents only. (4) README points to .agents (list + base.md) with no duplicated table. (5) Links resolve in the repo.

## References

- Research: [thoughts/shared/research/2026-03-08-skill-factory-available-skills-list.md](thoughts/shared/research/2026-03-08-skill-factory-available-skills-list.md)
- Sync script: `sync-skill-factory.sh` (repo root)
- base.md §9: `.agents/rules/base.md` (Skills canonical location and use)
- cursor-config-management: `.cursor/rules/cursor-config-management.mdc`
- Prior tool-awareness plan: [thoughts/shared/plans/2026-03-07-xp-skills-structure-and-tool-awareness.md](thoughts/shared/plans/2026-03-07-xp-skills-structure-and-tool-awareness.md)
