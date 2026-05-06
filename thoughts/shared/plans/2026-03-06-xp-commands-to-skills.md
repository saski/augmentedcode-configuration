# XP Commands to .agents/skills Migration — Implementation Plan

## Overview

Convert the 9 XP slash commands in `.agents/commands/` into 8 trigger-based skills under **`.agents/skills/`** so they are reachable by every AI tool (Cursor, Codex, Antigravity) via symlinks, not only Cursor from `~/.cursor/`. Skills live in the canonical `.agents/` tree and each tool’s “skills” (or equivalent) directory symlinks to repo `.agents/skills/`.

## Current State Analysis

- **Commands**: 9 XP command files in `.agents/commands/`: `xp-technical-debt`, `xp-simple-design-refactor`, `xp-refactor` (duplicate of simple-design-refactor), `xp-security-analysis`, `xp-predict-problems`, `xp-plan-untested-code`, `xp-mikado-method`, `xp-increase-coverage`, `xp-code-review`.
- **Skills today**: Cursor-only under `.cursor/skills/` (e.g. `test-doubles-first`, `cwv-improvement-planner`, `ownership-routing`); `~/.cursor/skills` → repo `.cursor/skills`.
- **Symlinks** (`setup-symlinks.sh`): `~/.cursor/.agents` → repo `.agents`; `~/.cursor/skills` → repo `.cursor/skills`. No `.agents/skills/` yet; no Codex/Antigravity skills symlinks.

**Constraint**: Research specifies XP skills must be **trigger-based** (no `disable-model-invocation: true`).

## Desired End State

1. **Canonical skills under `.agents`**: `.agents/skills/` contains 8 XP skills (one per concern; `xp-refactor` and `xp-simple-design-refactor` merged into one).
2. **All tools use `.agents/skills`**: Cursor, Codex, and Antigravity resolve “skills” from repo `.agents/skills/` via symlinks (e.g. `~/.cursor/skills` → repo `.agents/skills`, and equivalent for other tools).
3. **Single source of truth**: No duplicate XP content in `.agents/commands/`; README and config docs describe XP behaviors as skills under `.agents/skills/`.
4. **Verification**: `./setup-symlinks.sh validate` passes; listing skills from each tool shows the XP skills; no XP command files remain in `.agents/commands/`.

## What We're NOT Doing

- Moving FIC or EB commands to skills (they stay in `.agents/commands/`).
- Changing `eb-bug-fixing-agent` in this plan (optional later: extract expertise to a skill).
- Adding `disable-model-invocation: true` to the new XP skills (they remain trigger-based).
- Modifying content of existing `.cursor/skills-cursor/` or Cursor-only meta-skills.

## Implementation Approach

1. Introduce `.agents/skills/` as the shared skill root.
2. Optionally migrate existing `.cursor/skills/` content into `.agents/skills/` so one directory serves all tools (recommended).
3. Add 8 XP skills under `.agents/skills/` (SKILL.md + trigger-rich descriptions).
4. Point each tool’s skills directory at `.agents/skills/` in `setup-symlinks.sh`.
5. Remove the 9 XP command files from `.agents/commands/`.
6. Update README and cursor-config rule to document `.agents/skills/` and symlink behavior.

---

## Phase 1: Create `.agents/skills/` and optional merge from `.cursor/skills/`

### Overview

Establish `.agents/skills/` and, so Cursor can use it as the single skills source, move existing Cursor-only skills from `.cursor/skills/` into `.agents/skills/`.

### Changes Required

#### 1. Create directory

**Path**: `.agents/skills/`
**Action**: Create directory (empty or with migrated skills).

#### 2. (Optional) Migrate existing `.cursor/skills/` into `.agents/skills/`

**Paths**:
- Source: `.cursor/skills/test-doubles-first/`, `.cursor/skills/cwv-improvement-planner/`, `.cursor/skills/ownership-routing/`
- Destination: `.agents/skills/test-doubles-first/`, `.agents/skills/cwv-improvement-planner/`, `.agents/skills/ownership-routing/`

**Action**: Copy each skill directory into `.agents/skills/` (preserve SKILL.md and any scripts/docs). Optionally remove originals from `.cursor/skills/` after symlink switch so `.cursor/skills` points to `.agents/skills` and Cursor only reads from one place.

**Decision**: If “optional merge” is skipped, Cursor can keep `~/.cursor/skills` → `.cursor/skills` and we add a separate mechanism for Cursor to load `.agents/skills` only if the product supports multiple skill roots; otherwise Cursor would not see XP skills unless we later merge. Plan assumes merge so one source of truth.

### Success Criteria

- [x] `.agents/skills/` exists.
- [x] If merge done: existing skills (e.g. test-doubles-first, cwv-improvement-planner, ownership-routing) exist under `.agents/skills/` with same content.

---

## Phase 2: Add 8 XP skills under `.agents/skills/`

### Overview

Create one SKILL.md per XP concern under `.agents/skills/{name}/`, with frontmatter `name` and a `description` that includes trigger phrases. Do **not** set `disable-model-invocation: true`. Body = current command content (persona + task + deliverables). Merge `xp-refactor` and `xp-simple-design-refactor` into a single skill (e.g. `xp-simple-design-refactor`).

### Mapping (command → skill)

| Command file | Skill name | Description trigger focus |
|--------------|------------|---------------------------|
| xp-technical-debt.md | xp-technical-debt | technical debt, catalog, prioritize, quick wins, ROI |
| xp-simple-design-refactor.md + xp-refactor.md | xp-simple-design-refactor | refactor, simple design, maintainability, ROI |
| xp-security-analysis.md | xp-security-analysis | security review, risk, OWASP, threat modeling |
| xp-predict-problems.md | xp-predict-problems | predict failures, production risk, edge cases |
| xp-plan-untested-code.md | xp-plan-untested-code | untested code, test plan, coverage gaps |
| xp-mikado-method.md | xp-mikado-method | Mikado Method, safe refactoring, dependency graph |
| xp-increase-coverage.md | xp-increase-coverage | increase coverage, write tests, high-value tests |
| xp-code-review.md | xp-code-review | code review, pending changes, maintainability, project rules |

### Changes Required (per skill)

**Template** for each:

1. Create `.agents/skills/{name}/SKILL.md`.
2. Frontmatter:
   - `name`: same as directory (e.g. `xp-technical-debt`).
   - `description`: one or two sentences stating what the skill does and **when** to use it (trigger phrases), e.g. “Use when user asks for technical debt analysis, prioritization, or quick wins.”
3. Body: copy current command markdown (title, task, deliverables) verbatim from the corresponding `.agents/commands/*.md` file. For `xp-simple-design-refactor`, use the content of `xp-simple-design-refactor.md` (same as xp-refactor).

**Example** — `xp-technical-debt`:

**File**: `.agents/skills/xp-technical-debt/SKILL.md`

```markdown
---
name: xp-technical-debt
description: Catalog and prioritize technical debt with Lean/XP lens; top 5, quick wins, strategic debt. Use when user asks for technical debt analysis, prioritization, quick wins, or tech debt payoff order.
---

## Senior XP Developer — Technical Debt Analysis

Act as a **Senior XP Developer** with **Lean thinking** and a focus on sustainable pace.

### Task
**Identify and prioritize technical debt** in the codebase:
... (rest of existing command body)
```

Repeat for the other 7 skills (8 directories total).

### Success Criteria

- [x] Eight directories exist under `.agents/skills/`: `xp-technical-debt`, `xp-simple-design-refactor`, `xp-security-analysis`, `xp-predict-problems`, `xp-plan-untested-code`, `xp-mikado-method`, `xp-increase-coverage`, `xp-code-review`.
- [x] Each has a `SKILL.md` with `name`, trigger-rich `description`, and body matching the intent of the original command(s).
- [x] No `disable-model-invocation: true` in any of these skills.

---

## Phase 3: Point all tools at `.agents/skills/` in setup-symlinks.sh

### Overview

Make Cursor and all other dev/AI tool configs under `~` resolve skills from repo `.agents/skills/` via symlinks. Extended beyond Cursor, Codex, and Antigravity to any tool in a configurable list.

### Changes Required

#### 1. `setup-symlinks.sh` — Cursor skills

**File**: `setup-symlinks.sh`
**Change**: Point Cursor skills at `.agents/skills`:

```bash
ln -sf "$REPO_DIR/.agents/skills" ~/.cursor/skills
```

So `~/.cursor/skills` → repo `.agents/skills/`.

#### 2. `setup-symlinks.sh` — All other dev tools (data-driven)

**File**: `setup-symlinks.sh`
**Action**: Introduced `TOOLS_WITH_SKILLS` list; for each tool, create `~/$tool/skills` → repo `.agents/skills`. Default list includes: `.codex`, `.antigravity`, `.claude`, `.gemini`, `.langflow`. Add or remove tool names in the script to cover any dev tool config under `~`.

```bash
TOOLS_WITH_SKILLS=".codex .antigravity .claude .gemini .langflow"
for tool in $TOOLS_WITH_SKILLS; do
  mkdir -p "$HOME/$tool"
  ln -sf "$REPO_DIR/.agents/skills" "$HOME/$tool/skills"
done
```

#### 3. `setup-symlinks.sh` — Validation

**File**: `setup-symlinks.sh`
**Action**: Validate `~/.cursor/skills` points to `.agents/skills`; for each `TOOLS_WITH_SKILLS`, validate `~/$tool/skills` is a symlink pointing to repo `.agents/skills`.

### Success Criteria

- [x] `./setup-symlinks.sh setup` creates `~/.cursor/skills` → repo `.agents/skills`, and for each tool in `TOOLS_WITH_SKILLS` creates `~/$tool/skills` → repo `.agents/skills`.
- [x] `./setup-symlinks.sh validate` checks these symlinks and that they point to `.agents/skills`.

---

## Phase 4: Remove XP command files from `.agents/commands/`

### Overview

Delete the 9 XP command files so XP behavior is only provided by the new skills.

### Changes Required

**Path**: `.agents/commands/`
**Action**: Delete:

- `xp-technical-debt.md`
- `xp-simple-design-refactor.md`
- `xp-refactor.md`
- `xp-security-analysis.md`
- `xp-predict-problems.md`
- `xp-plan-untested-code.md`
- `xp-mikado-method.md`
- `xp-increase-coverage.md`
- `xp-code-review.md`

### Success Criteria

- [x] These 9 files no longer exist under `.agents/commands/`.
- [x] Remaining commands (FIC, EB) unchanged and still present.

---

## Phase 5: Update README and cursor-config rule

### Overview

Document that XP behaviors are skills under `.agents/skills/`, reachable by all tools via symlinks, and update the cursor-config rule to mention `.agents/skills/`.

### Changes Required

#### 1. README — XP section and symlinks

**File**: `README.md`
**Changes**:

- Replace or reframe the “XP/TDD Commands” table (around lines 148–161) so it describes **XP skills** under `.agents/skills/` and that they are applied when the user’s request matches the skill description (trigger-based). List the 8 skill names and short purpose (same as current table, but as skills).
- In the symlink/architecture section, state that `~/.cursor/skills` (and, if added, `~/.codex/skills`, `~/.antigravity/skills`) point to repo `.agents/skills/` so all tools share the same skills.

#### 2. cursor-config-management.mdc

**File**: `.cursor/rules/cursor-config-management.mdc`
**Changes**: In “Canonical Source” (or equivalent), add that shared skills live in `.agents/skills/` and are exposed to Cursor (and other tools) via symlinks.

### Success Criteria

- [x] README no longer lists XP items as slash commands; they are documented as skills under `.agents/skills/` with trigger-based use.
- [x] Symlink section documents `.agents/skills/` as the canonical skill root for all tools.
- [x] cursor-config rule mentions `.agents/skills/` where appropriate.

---

## Testing Strategy

- **Symlinks**: Run `./setup-symlinks.sh validate` after setup; confirm each tool’s skills directory resolves to repo `.agents/skills/`.
- **Content**: Spot-check 2–3 XP skills: frontmatter has `name` and trigger-rich `description`, body matches original command, no `disable-model-invocation`.
- **Cleanup**: `ls .agents/commands/xp-*.md` (or equivalent) returns nothing; FIC/EB command files still present.

## References

- Research: `thoughts/shared/research/2026-03-06-commands-movable-as-skills.md`
- Command source: `.agents/commands/xp-*.md`
- Skill format: `.cursor/skills-cursor/create-skill/SKILL.md`
- Symlink script: `setup-symlinks.sh`
