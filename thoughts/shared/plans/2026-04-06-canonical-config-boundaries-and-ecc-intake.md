# Canonical Config Boundaries and ECC Intake - Implementation Plan

> Superseded note added on 2026-06-17: references in this historical plan to `.claude/RTK.md` describe the older include-based design. Current RTK guidance lives inline in `.agents/rules/base.md` §8, with hooks managed from `.agents/hooks/rtk-rewrite.sh`.

## Overview

Reinforce `augmentedcode-configuration` as the canonical personal AI development configuration while removing runtime-state bleed and creating a small, explicit intake path for selected ECC assets. The implementation keeps the repo opinionated around Lean/Agile/XP values, reduces daily config churn, and makes ECC an upstream reference library rather than a competing operating system.

## Current State Analysis

### Repo purpose and constraints

- `README.md` positions the repo as the single source of truth for cross-tool configuration, shared skills, and FIC workflows.
- `.agents/rules/base.md` reinforces canonical shared skills, TDD, and periodic self-audit.
- `setup-symlinks.sh` currently treats the repo as the direct source for `~/.cursor/`, `~/.codex/`, `~/.claude/`, and `~/.gemini/`.

### Problems to address

1. **Runtime/config boundary is wrong for Claude**
   - `setup-symlinks.sh` creates `~/.claude -> repo/.claude`.
   - Repo `.claude/` currently contains volatile runtime state:
     - `.claude/backups/`
     - `.claude/cache/`
     - `.claude/downloads/`
     - `.claude/notifications/`
     - `.claude/projects/`
     - `.claude/sessions/`
   - This makes normal tool usage dirty the repo.

2. **Some tracked files are tool-mutated rather than canonical**
   - `.claude/plugins/blocklist.json` changes `fetchedAt` on refresh.
   - `.claude/settings.json` contains machine-specific absolute paths under `/Users/ignacio.viejo/...`.
   - `.codex/config.toml` mixes canonical defaults with machine-local trust and plugin state.

3. **Docs and rules have drift**
   - `README.md` still describes `.agent/workflows/`, but the repo uses `.agents/workflows/`.
   - `.agents/rules/base.md` also points Antigravity workflows to `.agent/workflows/`.
   - `README.md` says `thoughts/shared/` is committed, while `.gitignore` still ignores `thoughts/`.

4. **There is no explicit ECC intake lane**
   - Selected ECC ideas were identified as useful (`documentation-lookup`, `verification-loop`, `strategic-compact`).
   - There is currently no manifest or provenance workflow for vendoring ECC assets into `.agents/skills/`.

## Desired End State

- `augmentedcode-configuration` remains the canonical personal config repo for cross-tool rules, skills, and workflows.
- Only stable, intentional config surfaces are tracked in git.
- Claude and Codex mutable files are local, generated from repo templates or left tool-owned.
- `setup-symlinks.sh` manages **selective stable symlinks**, not whole runtime directories.
- The repo has an explicit ECC intake manifest with owner, source reference, and review date.
- Three ECC pilot skills are vendored into `.agents/skills/` and discoverable by the repo’s skill routing index.

## What We're NOT Doing

- Not switching daily use to ECC or making ECC the canonical config repo.
- Not bulk-importing ECC agents, commands, hooks, or install system.
- Not introducing a second sync mechanism that depends on a local ECC checkout at runtime.
- Not rewriting all repo docs; only update the parts required for the new boundaries and intake workflow.
- Not changing existing XP/native skills beyond references needed to keep discovery accurate.
- Not adding a full test framework to this repo; use targeted shell/JSON/script validation.

## Implementation Approach

Use the smallest clean redesign:

1. **Clarify policy in docs and rules**
   - Make canonical-vs-local boundaries explicit.
   - Fix workflow path drift and `thoughts/` tracking contradictions.

2. **Refactor tool integration to selective stable surfaces**
   - Cursor stays largely symlink-driven because its repo-backed files are intentionally canonical.
   - Claude moves from full-directory symlink to selective symlinks plus local generated config.
   - Codex moves from symlinked mutable config to a generated local config from a repo template.

3. **Create an explicit ECC intake lane**
   - Vendor selected skills into `.agents/skills/`.
   - Track provenance in a small manifest.
   - Update discovery docs so imported skills participate in normal trigger-based routing.

4. **Add lightweight validation**
   - Validate selective symlink boundaries.
   - Validate ECC intake manifest structure and referenced files.
   - Keep the repo clean after normal tool use.

## Phase 1: Fix Documentation and Repository Policy

### Overview

Make the architecture and boundaries explicit before changing scripts. This phase removes contradictions that would otherwise make the refactor ambiguous.

### Changes Required

#### 1. Update user-facing architecture summary
**Files**:
- `README.md`
- `docs/development-guide.md` (new)

**Changes**:
- Keep `README.md` focused on what the repo provides to end users.
- Add a short link in `README.md` to `docs/development-guide.md`.
- Move detailed config-boundary, workflow, and maintenance guidance into `docs/development-guide.md`.
- Correct `.agent/workflows/` references to `.agents/workflows/`.
- Document the split between:
  - canonical repo-tracked config
  - local generated config
  - tool-owned runtime state

#### 2. Update canonical rules
**File**: `.agents/rules/base.md`

**Changes**:
- Correct Antigravity workflow path from `.agent/workflows/` to `.agents/workflows/`.
- Add a short boundary rule:
  - repo tracks stable config, templates, shared skills, and shared workflows
  - repo must not track tool-generated session/cache/project state
- Add a short provenance rule for vendored upstream skills:
  - imported skills must be recorded in `.agents/upstreams/...`

#### 3. Fix `thoughts/` tracking policy
**File**: `.gitignore`

**Changes**:
- Stop blanket-ignoring `thoughts/`.
- Keep personal and generated areas ignored while allowing shared research/plans to remain tracked.
- Target state:
  - keep `thoughts/shared/` trackable
  - ignore personal/user-specific note trees as needed
  - ignore generated search/index artifacts only

### Success Criteria

- [ ] `README.md` links to `docs/development-guide.md` for developer and infrastructure guidance.
- [ ] `README.md` and `.agents/rules/base.md` both reference `.agents/workflows/`.
- [ ] `.gitignore` no longer contradicts the documented `thoughts/shared/` model.
- [ ] `rg -n "\.agent/workflows|thoughts/" README.md .agents/rules/base.md .gitignore docs/development-guide.md` shows only the intended references.

---

## Phase 2: Refactor Canonical vs Local Tool Boundaries

### Overview

Replace whole-directory tool symlinks where they capture runtime state. Preserve portability while removing day-to-day repo churn.

### Changes Required

#### 1. Define stable Claude assets and local Claude runtime
**Files**:
- `setup-symlinks.sh`
- `.claude/hooks/rtk-rewrite.sh`
- `.claude/CLAUDE.md`
- `.claude/RTK.md`
- `templates/claude/settings.json` (new)

**Changes**:
- Stop creating `~/.claude -> repo/.claude`.
- In `setup-symlinks.sh`, create `~/.claude/` as a normal directory.
- Symlink only stable Claude assets:
  - `~/.claude/commands -> repo/.agents/commands`
  - `~/.claude/skills -> repo/.agents/skills`
  - `~/.claude/hooks/rtk-rewrite.sh -> repo/.claude/hooks/rtk-rewrite.sh`
  - `~/.claude/CLAUDE.md -> repo/.claude/CLAUDE.md`
  - `~/.claude/RTK.md -> repo/.claude/RTK.md`
- Generate `~/.claude/settings.json` from `templates/claude/settings.json` with `$HOME`-resolved paths.
- Leave these as tool-owned local runtime paths and do not manage or symlink them:
  - `~/.claude/backups/`
  - `~/.claude/cache/`
  - `~/.claude/downloads/`
  - `~/.claude/notifications/`
  - `~/.claude/projects/`
  - `~/.claude/sessions/`
  - `~/.claude/plugins/blocklist.json`

#### 2. Split canonical Codex defaults from local Codex state
**Files**:
- `setup-symlinks.sh`
- `templates/codex/config.toml` (new)
- `.codex/config.toml` (remove from canonical tracked surface)

**Changes**:
- Replace the symlink from `~/.codex/config.toml` to repo `.codex/config.toml`.
- Store only portable defaults in `templates/codex/config.toml`.
- Remove machine-specific project trust entries and mutable plugin selections from the canonical template.
- Have `setup-symlinks.sh` render/copy `templates/codex/config.toml` into `~/.codex/config.toml` when missing.
- Refuse to overwrite an existing local file unless an explicit force flag is supplied.

#### 3. Remove tracked volatile files from repo-managed surfaces
**Files / paths**:
- `.claude/plugins/blocklist.json`
- `.claude/backups/`
- `.claude/cache/`
- `.claude/downloads/`
- `.claude/notifications/`
- `.claude/projects/`
- `.claude/sessions/`
- `.cursor/plans/`

**Changes**:
- Remove tool-generated runtime artifacts from the repository tree.
- Update `.gitignore` to ignore these paths explicitly.
- Keep only intentional repo-owned tool helpers under `.claude/` and `.cursor/`.

#### 4. Tighten backup and validation behavior
**Files**:
- `backup-cursor-config.sh`
- `setup-symlinks.sh`
- `scripts/validate-config-boundaries.sh` (new)

**Changes**:
- Keep `backup-cursor-config.sh` for Cursor backups.
- Extend `setup-symlinks.sh validate` to verify:
  - selective Claude symlinks exist
  - no full `~/.claude` symlink is present
  - Codex shared skills/rules are symlinked
  - local generated config files exist
- Add `scripts/validate-config-boundaries.sh` to check:
  - repo does not contain tracked files in forbidden runtime paths
  - template files exist
  - JSON and TOML template files are readable

### Success Criteria

- [ ] `~/.claude` is a normal directory, not a symlink.
- [ ] `~/.claude/commands` and `~/.claude/skills` resolve to repo canonical paths.
- [ ] `~/.claude/settings.json` is local and generated from template.
- [ ] `~/.codex/config.toml` is local and generated from template.
- [ ] `git status` stays clean after normal Claude/Codex use.
- [ ] `bash -n setup-symlinks.sh backup-cursor-config.sh scripts/validate-config-boundaries.sh` passes.
- [ ] `./setup-symlinks.sh validate` passes on the developer machine.

---

## Phase 3: Add Explicit ECC Intake Governance

### Overview

Create a small, explicit import path for selected ECC components so the repo can reuse upstream work without becoming dependent on a second live config system.

### Changes Required

#### 1. Add ECC intake manifest
**Files**:
- `.agents/upstreams/ecc/components.lock.json` (new)
- `docs/development-guide.md`

**Changes**:
- Create a JSON manifest for vendored ECC assets.
- Each manifest row must include:
  - `id`
  - `kind`
  - `source_repo`
  - `source_ref`
  - `source_path`
  - `local_path`
  - `owner`
  - `reason`
  - `review_date`
  - `status`
- Document the intake workflow in `docs/development-guide.md`:
  - copy or adapt selected asset into repo
  - record provenance in manifest
  - update discovery docs
  - review on the recorded date

#### 2. Pilot-import three ECC skills
**Files**:
- `.agents/skills/documentation-lookup/SKILL.md` (new, vendored/adapted)
- `.agents/skills/verification-loop/SKILL.md` (new, vendored/adapted)
- `.agents/skills/strategic-compact/SKILL.md` (new, vendored/adapted)
- `.agents/docs/skill-factory-skills.md`

**Changes**:
- Vendor the three selected ECC skills into `.agents/skills/`.
- Keep them aligned with repo style and local skill-routing rules.
- Update `.agents/docs/skill-factory-skills.md` so the skills are discoverable by current rules.
- Record each imported skill in `.agents/upstreams/ecc/components.lock.json`.

#### 3. Keep provenance separate from other skill sources
**Files**:
- `skills-lock.json` (only if needed for consistency note)
- `docs/development-guide.md`

**Changes**:
- Do not overload `skills-lock.json` with ECC imports in this phase.
- Document that `skills-lock.json` remains the existing source/provenance file for its current sync flows, while ECC imports use the dedicated intake manifest.

### Success Criteria

- [ ] `.agents/upstreams/ecc/components.lock.json` exists and validates as JSON.
- [ ] All three pilot skills exist under `.agents/skills/`.
- [ ] `.agents/docs/skill-factory-skills.md` includes the imported skills.
- [ ] Every imported ECC asset has one manifest entry with source path and review date.

---

## Phase 4: Verification, Cleanup, and Handoff

### Overview

Finish the migration with a clean working model and an explicit next step for future ECC intake.

### Changes Required

#### 1. Validate the repo boundary model
**Files**:
- `scripts/validate-config-boundaries.sh`
- `setup-symlinks.sh`

**Checks**:
- Run repo boundary validation.
- Run symlink validation.
- Verify no tracked files remain under forbidden runtime paths.

#### 2. Validate the ECC intake lane
**Files**:
- `.agents/upstreams/ecc/components.lock.json`
- `.agents/docs/skill-factory-skills.md`

**Checks**:
- Confirm every manifest `local_path` exists.
- Confirm discovery doc rows match on-disk skill directories.
- Confirm review dates are present for all pilot imports.

#### 3. Capture the final architecture in docs
**Files**:
- `docs/development-guide.md`
- `README.md`

**Changes**:
- Add a short “How to decide where a file belongs” section:
  - canonical repo config
  - local generated config
  - tool-owned runtime state
- Add a short “How to import from ECC” section with the pilot skills as examples.

### Success Criteria

- [ ] `./scripts/validate-config-boundaries.sh` passes.
- [ ] `./setup-symlinks.sh validate` passes.
- [ ] `python3 -m json.tool .agents/upstreams/ecc/components.lock.json` passes.
- [ ] `git status` is clean after a normal setup/validate cycle.
- [ ] Docs describe the new boundary and import model without contradicting repo behavior.

## Testing Strategy

### Automated

- `bash -n setup-symlinks.sh`
- `bash -n backup-cursor-config.sh`
- `bash -n scripts/validate-config-boundaries.sh`
- `./setup-symlinks.sh validate`
- `./scripts/validate-config-boundaries.sh`
- `python3 -m json.tool .agents/upstreams/ecc/components.lock.json`
- `rg -n "\.agent/workflows" README.md .agents/rules/base.md docs/development-guide.md`

### Manual

- Run `./setup-symlinks.sh setup` on the local machine and confirm:
  - `~/.claude` is not a symlink
  - `~/.claude/commands` and `~/.claude/skills` are symlinks
  - `~/.codex/config.toml` is local, not symlinked
- Start Claude and Codex once, then check the repo stays clean.
- Trigger one imported ECC skill by name in a tool session and confirm it is discoverable.

## References

- Existing recommendation: keep `augmentedcode-configuration` canonical and use ECC as upstream source
- Prior plan: `thoughts/shared/plans/2026-03-06-config-deduplication-symlinks.md`
- Prior plan: `thoughts/shared/plans/2026-03-26-skill-foundry-repo-alignment.md`
- Repo rulebook: `.agents/rules/base.md`
- Repo architecture: `README.md`

## Phase List

1. Fix documentation and repository policy
2. Refactor canonical vs local tool boundaries
3. Add explicit ECC intake governance
4. Verify, clean up, and hand off

## Next Step

`fic-implement-plan thoughts/shared/plans/2026-04-06-canonical-config-boundaries-and-ecc-intake.md`
