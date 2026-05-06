---
date: 2026-03-07
researcher: agent
topic: "XP skills structure and rules so every coding tool knows how to use it"
tags: [research, skills, .agents, cursor, plan, documentation]
status: complete
---

# Research: XP Skills Structure and Tool Awareness

## Summary

The implementation plan **2026-03-06-xp-commands-to-skills** is largely implemented: `.agents/skills/` is the canonical skill root, symlinks point all tools at it, XP commands have been removed from `.agents/commands/`, and README plus cursor-config rule document the structure. **What exists** for “every coding tool” to know about the structure and how to use it is spread across: (1) symlink setup and validation in `setup-symlinks.sh`, (2) README (repository structure, symlinks, XP Skills table, Cursor Skills table), (3) `.cursor/rules/cursor-config-management.mdc` (canonical source and Shared Skills), and (4) each skill’s `SKILL.md` (name + trigger-rich description). The canonical development rulebook **`.agents/rules/base.md`** does not mention skills or `.agents/skills/`. The create-skill meta-skill still documents storage as `~/.cursor/skills/` and `.cursor/skills/`, not `.agents/skills/`. Cursor injects the skill list and “read skill file when relevant” from the workspace; that behavior is product-specific, not defined in the repo.

---

## Detailed Findings

### 1. Plan and implementation status

**Source**: [thoughts/shared/plans/2026-03-06-xp-commands-to-skills.md](thoughts/shared/plans/2026-03-06-xp-commands-to-skills.md)

- **Phases 1–3**: `.agents/skills/` exists; 8 XP skills plus test-doubles-first, cwv-improvement-planner, ownership-routing live under it. `setup-symlinks.sh` sets `~/.cursor/skills` → repo `.agents/skills` and creates `~/$tool/skills` → repo `.agents/skills` for each entry in `TOOLS_WITH_SKILLS` (`.codex`, `.antigravity`, `.claude`, `.gemini`, `.langflow`).
- **Phase 4**: No `xp-*.md` files remain under `.agents/commands/`; only FIC and EB commands are present.
- **Phase 5**: README documents XP skills as trigger-based under `.agents/skills/` and symlink behavior; cursor-config rule mentions Shared Skills and `.agents/skills/`.

### 2. Canonical skill location and layout

**Canonical root**: `.agents/skills/` (repo path: `saski/augmentedcode-configuration/.agents/skills/`).

**Current skills under `.agents/skills/`**:

| Skill directory              | Purpose (from plan/README) |
|-----------------------------|----------------------------|
| xp-technical-debt           | Catalog/prioritize tech debt; quick wins, strategic debt |
| xp-simple-design-refactor   | Refactor, simple design, maintainability, ROI |
| xp-security-analysis        | Security review, OWASP, threat modeling |
| xp-predict-problems         | Predict failures, production risk, edge cases |
| xp-plan-untested-code       | Test plan, untested code, coverage gaps |
| xp-mikado-method            | Mikado Method, safe refactoring, dependency graph |
| xp-increase-coverage        | Increase coverage, high-value tests |
| xp-code-review              | Code review, pending changes, maintainability, project rules |
| test-doubles-first          | Prefer fake/stub/spy over mock |
| cwv-improvement-planner     | Core Web Vitals plans (LCP, INP, TTFB) |
| ownership-routing              | Determine owning team for issues |

Each skill has at least `SKILL.md` with YAML frontmatter (`name`, `description`) and a body. Example: [.agents/skills/xp-technical-debt/SKILL.md](.agents/skills/xp-technical-debt/SKILL.md) — `description` includes trigger phrases (“Use when the user asks for technical debt analysis, prioritization, quick wins…”). No `disable-model-invocation: true` in the XP skills (trigger-based).

**Duplicate content**: Repo also contains `.cursor/skills/` with overlapping skills (e.g. ownership-routing, test-doubles-first, cwv-improvement-planner). The plan designates `.agents/skills/` as canonical; `setup-symlinks.sh` makes `~/.cursor/skills` point at repo `.agents/skills/`, so the symlinked runtime source is `.agents/skills/`.

### 3. Symlink script and tool coverage

**File**: [setup-symlinks.sh](setup-symlinks.sh)

- **Lines 9–12**: `TOOLS_WITH_SKILLS=".codex .antigravity .claude .gemini .langflow"`; comment states that Cursor is handled separately and other tools get a `skills` symlink to repo `.agents/skills`.
- **Lines 56–61**: Cursor: `ln -sf "$REPO_DIR/.agents/skills" ~/.cursor/skills` (and other .cursor symlinks).
- **Lines 64–68**: For each `$tool` in `TOOLS_WITH_SKILLS`, `ln -sf "$REPO_DIR/.agents/skills" "$HOME/$tool/skills"`.
- **Lines 81–105**: Validation ensures `~/.cursor/skills` and each `~/$tool/skills` are symlinks and (for skills) that the target path contains `.agents/skills`.

So the **data** for “where skills live” and “which tools get them” is in this script; adding a tool is done by editing `TOOLS_WITH_SKILLS`.

### 4. Where the structure is documented (for humans and tools)

**README.md**

- **Lines 11–41**: Repository structure lists `.agents/skills/` with subdirs (xp-*, test-doubles-first, cwv-improvement-planner, ownership-routing) and states “Symlink → repo .agents/skills/” under `.cursor/`.
- **Lines 48–64**: Symlink table and “Shared skills live in `.agents/skills/` (canonical)” and that tools point their `skills` directory at this repo path.
- **Lines 155–167**: “XP Skills” section: XP behaviors as trigger-based skills under `.agents/skills/`, applied when the request matches the skill description; table of 8 XP skills and purpose.
- **Lines 177–185**: “Cursor Skills (from `.agents/skills/`)” and table for test-doubles-first, cwv-improvement-planner, ownership-routing.

So README is the main place that explains (1) where skills live, (2) that they are trigger-based, and (3) how symlinks expose them to tools.

**.cursor/rules/cursor-config-management.mdc**

- **Lines 13–14**: Canonical source lists “Shared Skills: `.agents/skills/` — canonical skill root; exposed to Cursor (and Codex, Antigravity, etc.) via symlinks (e.g. `~/.cursor/skills` → repo `.agents/skills/`).”
- **Line 41**: “Edits in Cursor (to rules, commands, skills) modify the repo files directly.”

So the **rules** that are always applied in Cursor include the canonical skill root and symlink exposure; no instruction here on *when* to apply a skill (that is in each skill’s `description` and in Cursor’s skill system).

**.agents/rules/base.md**

- No occurrence of “skill”, “SKILL”, or “.agents” in the file. Base rules cover principles, quality, style, TDD, Makefile, etc., but do **not** define where skills live or that the agent should use `.agents/skills/` when the user’s request matches a skill description. AGENTS.md/CLAUDE.md/GEMINI.md point at this file, so tools that only load base rules do not get any skill-structure or skill-usage guidance from the repo.

### 5. How Cursor (and other tools) learn to use skills

**Cursor**

- The workspace supplies an **agent_skills** block: list of skills with `fullPath` and `description` (from each `SKILL.md`). The system instruction tells the agent to check if a skill can help, and to **read the skill file at the provided path** and follow it when relevant. So “how to use” is: (1) see skill names and descriptions in the prompt, (2) when the user’s request matches, read the full SKILL.md and follow it. That instruction is part of the product/workspace configuration, not stored in the repo.

**Other tools (Codex, Antigravity, etc.)**

- Symlinks give them the same file tree under `~/.codex/skills`, `~/.antigravity/skills`, etc. Whether they have a similar “skill list + description + read file when relevant” mechanism depends on each product. The repo does not contain a single, tool-agnostic rule file that says “Skills live in `.agents/skills/`; when the user’s request matches a skill’s description, read that skill’s SKILL.md and follow it.”

### 6. Create-skill meta-skill and research doc

**.cursor/skills-cursor/create-skill/SKILL.md**

- **Lines 42–44**: “Storage Locations”: “Personal | ~/.cursor/skills/skill-name/” and “Project | .cursor/skills/skill-name/”. It does **not** state that the canonical shared location is `.agents/skills/` in this repo. So anyone following only this skill would create skills under `~/.cursor/skills/` or `.cursor/skills/`, not under `.agents/skills/`.

**thoughts/shared/research/2026-03-06-commands-movable-as-skills.md**

- **Line 24**: “Skills live in `.cursor/skills/*/SKILL.md`”. That reflects the pre-migration layout; the current canonical location is `.agents/skills/`.

### 7. Skill format reference

**SKILL.md format** (from create-skill and from existing XP skills):

- Frontmatter: `name`, `description`. The `description` is used for trigger-based use (e.g. “Use when the user asks for …”).
- Body: task, deliverables, persona (e.g. “Act as Senior XP Developer”).
- No `disable-model-invocation: true` for XP skills (they are trigger-based).

---

## Code References

- `thoughts/shared/plans/2026-03-06-xp-commands-to-skills.md` — Implementation plan and phase checklist.
- `setup-symlinks.sh:9-12` — `TOOLS_WITH_SKILLS` and comment.
- `setup-symlinks.sh:56-68` — Creation of `~/.cursor/skills` and `~/$tool/skills` symlinks to repo `.agents/skills`.
- `setup-symlinks.sh:81-125` — Validation of Cursor and other-tool skills symlinks.
- `README.md:11-41` — Repo structure including `.agents/skills/`.
- `README.md:48-64` — Symlinks and canonical shared skills.
- `README.md:155-167` — XP Skills section and table.
- `README.md:177-185` — Cursor Skills section and table.
- `.cursor/rules/cursor-config-management.mdc:13-14` — Canonical source and Shared Skills.
- `.agents/skills/xp-technical-debt/SKILL.md` — Example XP skill with trigger-rich description.
- `.agents/rules/base.md` — No mention of skills or `.agents/skills/`.
- `.cursor/skills-cursor/create-skill/SKILL.md:54-60` — Storage locations (`~/.cursor/skills`, `.cursor/skills` only).
- `thoughts/shared/research/2026-03-06-commands-movable-as-skills.md:24` — Outdated “Skills live in `.cursor/skills/`”.

---

## Architecture Summary

- **Canonical skills**: `.agents/skills/` in the repo; one directory per skill, each with at least `SKILL.md` (name + description + body).
- **Exposure**: Symlinks from `~/.cursor/skills` and from `~/$tool/skills` (for each tool in `TOOLS_WITH_SKILLS`) to repo `.agents/skills/`. Setup and validation are in `setup-symlinks.sh`.
- **Documentation**: README (structure, symlinks, XP Skills, Cursor Skills) and cursor-config rule (canonical source and Shared Skills). Base rules include a **Skills** section (section 9) with canonical location and trigger-based use.
- **Trigger-based use**: Described in README and in each skill’s `description`; Cursor’s “when to read and follow a skill” is enforced by the product via the injected skill list and instruction, not by a repo rule file.

---

## Open Questions

1. **Single rule for “how to use skills”**: Is there a need for a rule (e.g. in `.agents/rules/` or referenced by base.md) that states: “Skills live in `.agents/skills/`. When the user’s request matches a skill’s description, read that skill’s SKILL.md and follow its instructions,” so that any tool loading repo rules gets the same guidance?
2. **base.md and skills**: Should `.agents/rules/base.md` (and thus AGENTS.md/CLAUDE.md/GEMINI.md) include a short section on skills location and trigger-based use so that tools that only use base rules still know about `.agents/skills/`?
3. **create-skill and canonical path**: Should the create-skill meta-skill document `.agents/skills/` as the canonical project/shared skill location for this repo (and possibly “when working in augmentedcode-configuration”)?
4. **Research doc**: Should `2026-03-06-commands-movable-as-skills.md` be updated to say skills live in `.agents/skills/` (and that `.cursor/skills` is a symlink to it) for consistency?

---

## Implementation (tool-awareness follow-up)

Implemented 2026-03-07 (fic-implement-plan from this research):

- [x] **base.md and skills**: Added **§9. Skills (Canonical Location and Use)** to `.agents/rules/base.md`: canonical location `.agents/skills/`, trigger-based use (read SKILL.md when request matches description), skill format note.
- [x] **Single rule for “how to use skills”**: Addressed by the new section in base.md so any tool loading repo rules gets the same guidance.
- [x] **create-skill and canonical path**: In `.cursor/skills-cursor/create-skill/SKILL.md`, added **Storage Locations** row for “Canonical shared (this repo)” path **`.agents/skills/skill-name/`** and symlink exposure.
- [x] **Research doc**: Updated `2026-03-06-commands-movable-as-skills.md`: Source line now states skills live in `.agents/skills/*/SKILL.md` (canonical) and `~/.cursor/skills` symlinks to it; open question on “where XP skills should live” marked **resolved**.
