# Karpathy-Inspired Rule Consolidation - Implementation Plan

## Overview

Consolidate the always-loaded agent rules around four compact operating principles inspired by the Karpathy-style rule set, without making `.agents/rules/base.md` heavier. The change should preserve the repo-specific contracts that matter in this configuration repository while deprecating generic or duplicated guidance that current models already handle well.

## Current State

- `.agents/rules/base.md` is the canonical always-loaded rule file through the root `AGENTS.md` symlink.
- `.agents/rules/base.md` currently contains 16 sections that mix universal agent behavior, repository-specific invariants, skill governance, documentation rules, workflow rules, RTK guidance, and Context7 guidance.
- Several current bullets overlap with the proposed Karpathy-style rules:
  - "Think Before Acting", "Question Assumptions", and "Evidence First" all point at the same behavior.
  - "Simplicity First", "Baby Steps", "Incremental Changes", and "Small Components" overlap.
  - "Test-Driven Development", "Code Quality & Coverage", and "Testing Strategy Distinction" can be represented more compactly as goal-driven verification.
  - "Avoid Rushing", "Persistence", and "Fail Fast" can be represented as checkpointing and surfacing skipped work.
- `.agents/rules/base.md` contains a corrupted contextual rule reference: `.agents/rules/pyth![[REDIS_AUTH_REMEDIATION_HANDOFF]]on-project.md`.
- `tests/healthcheck-automation-test.sh` already protects some always-loaded rule contracts, especially skill inventory governance.
- `README.md`, `docs/development-guide.md`, and `PROJECT_STATUS.md` document the shared rule architecture and should stay aligned if the base-rule model changes.

## Desired End State

1. `.agents/rules/base.md` stays compact and always-loaded.
2. The universal operating model is expressed as four enriched principles:
   - Think Before Acting
   - Simplest Surgical Change
   - Goal-Driven Verification
   - Checkpoint and Escalate
3. The four principles absorb the useful parts of the 12-rule template without copying the whole template.
4. Repo-specific invariants remain explicit in `base.md`:
   - contextual rule loading
   - GitHub SSH alias and GitHub CLI auth boundary
   - English-only technical artifacts
   - skill inventory governance
   - RTK and Context7 routing pointers
   - personal knowledge routing boundary
5. Generic or duplicated guidance is removed from the always-loaded base instead of moved into another always-loaded document.
6. The corrupted Python contextual rule path is fixed.
7. Automated tests guard the compact rule shape and the retained repo-specific contracts.

## Out of Scope

- Implementing the rule rewrite in this planning pass.
- Changing any skill contents, skill catalogs, or skill discovery indexes.
- Changing RTK, Context7, GitHub SSH, or symlink behavior.
- Adding hard numeric token budgets to the base rules.
- Reworking Cursor, Claude, Gemini, or Codex symlink topology.
- Creating a new broad "best practices" rule file that would simply move base-rule bloat elsewhere.

## Design Options

### Option 1: Compact Base With Four Operating Principles

Rewrite `.agents/rules/base.md` so the top-level behavioral model is four principles, then keep only concrete repo-specific invariants below them.

**Pros**

- Directly addresses the concern that base rules are getting too heavy.
- Preserves the always-loaded behavior that actually matters.
- Makes the rule file easier for every tool to consume.
- Gives future maintainers a clearer testable shape.

**Cons**

- Requires careful editing so important repo-specific contracts are not accidentally removed.
- Some generic best-practice wording will disappear from the always-loaded rulebook.

### Option 2: Keep Base As-Is And Add A Separate Karpathy Rule File

Add a new `.agents/rules/karpathy-principles.md` file and reference it from `base.md`.

**Pros**

- Lower immediate risk to the current base file.
- Easy to add without rewriting existing sections.

**Cons**

- Makes the always-loaded rule stack heavier.
- Duplicates ideas already present in `base.md`.
- Conflicts with the goal of a size-controlled mix.

## Chosen Approach

Use **Option 1**. The purpose is not to preserve every sentence from either rule set, but to make the always-loaded rules smaller, sharper, and more enforceable. The implementation should treat the four principles as the execution constitution and keep contextual or repo-specific details only when they route behavior that models cannot infer reliably.

## Approach

Implement the consolidation test-first:

1. Add a contract test that captures the compact base-rule shape and the must-keep repository contracts.
2. Rewrite `.agents/rules/base.md` into the four-principle model.
3. Update README, development docs, and project status only where the documented rule architecture changes.
4. Run narrow checks while iterating, then finish with `make check`.

## Phased Changes

### Phase 1: Add A Base Rule Shape Contract

Status: Completed.

#### Overview

Create a failing test that defines the desired always-loaded rule shape before changing the rule text.

#### Files to Modify

- `tests/healthcheck-automation-test.sh`

#### Changes Required

1. Add assertions that `.agents/rules/base.md` contains the four compact principle names:
   - `Think Before Acting`
   - `Simplest Surgical Change`
   - `Goal-Driven Verification`
   - `Checkpoint and Escalate`
2. Add assertions that the base file still contains the must-keep repo-specific contracts:
   - `.agents/rules/python-project.md`
   - `.agents/rules/makefile-project.md`
   - `git@github.com-eventbrite:`
   - `git@github.com-saski:`
   - `.agents/docs/skill-factory-skills.md`
   - `.agents/skills/skill-foundry/agents/catalog-engineering.yaml`
   - `.agents/skills/skill-foundry/agents/catalog-product-management.yaml`
   - `./validate-skill-library.sh`
   - `.agents/rules/RTK.md`
   - `ctx7`
   - `personal-knowledge-routing`
3. Add a negative assertion that the corrupted Python contextual rule path is absent.

#### Automated Success Criteria

- `./tests/healthcheck-automation-test.sh` fails before the base rewrite because the four new principle names are not present.
- The failure names a missing expected string from `.agents/rules/base.md`.

Result:

- `/opt/homebrew/bin/rtk ./tests/healthcheck-automation-test.sh` fails before the base rewrite with: `expected .../.agents/rules/base.md to contain: Simplest Surgical Change`.

### Phase 2: Rewrite `base.md` Into The Compact Four-Principle Model

Status: Completed.

#### Overview

Replace the current broad 16-section base rulebook with a smaller always-loaded rulebook that keeps behavior, routing, and repo invariants, but removes duplicated generic guidance.

#### Files to Modify

- `.agents/rules/base.md`

#### Changes Required

1. Update metadata:
   - `last_updated: 2026-05-13`
   - increment the version from `2.5` to the next minor version.
2. Replace the current core-principles section with four enriched principles:
   - **Think Before Acting**: state assumptions, read before writing, surface ambiguity, use tools or code for deterministic answers, stop when confused.
   - **Simplest Surgical Change**: smallest working change, no speculative features, no unrelated cleanup, match existing conventions, surface harmful conventions instead of silently forking.
   - **Goal-Driven Verification**: define success criteria, use tests and canonical checks, tests encode intent, never claim skipped checks passed.
   - **Checkpoint and Escalate**: summarize significant state changes, disclose uncertainty, surface conflicts, ask one focused question when blocked.
3. Keep a short contextual loading section:
   - Python projects load `.agents/rules/python-project.md`.
   - Makefile projects load `.agents/rules/makefile-project.md`.
   - Missing contextual files are optional.
4. Fix the corrupted Python rule path.
5. Keep the GitHub SSH and CLI auth guidance because it is environment-specific and not inferable from general model behavior.
6. Keep English-only technical artifact guidance.
7. Keep documentation maintenance rules, but condense them so README and developer-doc boundaries remain clear.
8. Keep skill governance instructions exactly enough for the existing healthcheck contract to remain meaningful.
9. Keep the quality-skill routing pointers, but do not expand them.
10. Keep personal knowledge routing as a short boundary.
11. Keep the RTK include pointer.
12. Keep the Context7 guidance, but prefer a compact routing block over a long tutorial if the current behavior remains enforceable.
13. Remove or fold these duplicated headings from the always-loaded base:
    - `Core Principles`
    - `Code Quality & Coverage`
    - `Style Guidelines`
    - `Mental Preparation`
    - `Development Best Practices`
    - `Testing Strategy Distinction`
    - `TDD Rules`
    - `Periodic Self-Audit`

#### Automated Success Criteria

- `./tests/healthcheck-automation-test.sh`
- `rg -n 'Think Before Acting|Simplest Surgical Change|Goal-Driven Verification|Checkpoint and Escalate' .agents/rules/base.md`
- `rg -n '.agents/rules/python-project.md|.agents/rules/makefile-project.md' .agents/rules/base.md`
- `! rg -n 'pyth!\\[\\[REDIS_AUTH_REMEDIATION_HANDOFF\\]\\]on-project\\.md' .agents/rules/base.md`
- `rg -n 'git@github.com-eventbrite:|git@github.com-saski:' .agents/rules/base.md`
- `rg -n 'Adding, removing, renaming, or moving any skill|./validate-skill-library.sh' .agents/rules/base.md`

Result:

- `/opt/homebrew/bin/rtk ./tests/healthcheck-automation-test.sh` passed after the base rewrite.
- Targeted `rg` checks verified the four principles, contextual rule paths, GitHub SSH aliases, skill governance strings, and removal of the corrupted Python rule path.

### Phase 3: Align User-Facing And Maintainer Documentation

Status: Completed.

#### Overview

Update docs only where they describe the shared rules architecture. Keep the README user-focused and put maintainer rationale in the development guide.

#### Files to Modify

- `README.md`
- `docs/development-guide.md`
- `PROJECT_STATUS.md`

#### Changes Required

1. In `README.md`, keep the repository structure accurate and mention that `.agents/rules/base.md` is a compact universal entry point extended by contextual rule files.
2. In `docs/development-guide.md`, add or update a short "Rule Model" note:
   - base rules are compact and always-loaded
   - contextual rule files hold repo-type details
   - skills hold task-specific workflows
   - generic best-practice prose should not be added to base unless it routes concrete behavior
3. In `PROJECT_STATUS.md`, add a recent-change entry for the compact four-principle base-rule consolidation.

#### Automated Success Criteria

- `rg -n 'compact|contextual|base.md' README.md docs/development-guide.md PROJECT_STATUS.md`
- `rg -n 'four|Think Before Acting|Simplest Surgical Change|Goal-Driven Verification|Checkpoint and Escalate' PROJECT_STATUS.md docs/development-guide.md`
- `./tests/healthcheck-automation-test.sh`

Result:

- Targeted `rg` checks verified the compact/contextual rule-model docs in `README.md`, `docs/development-guide.md`, and `PROJECT_STATUS.md`.
- Targeted `rg` checks verified the four-principle wording in `docs/development-guide.md` and `PROJECT_STATUS.md`.
- `/opt/homebrew/bin/rtk ./tests/healthcheck-automation-test.sh` passed.
- Removed a stale README reference to `base.md §10`.

### Phase 4: Full Validation

Status: Completed.

#### Overview

Run the repository's canonical checks and fix any fallout from the rule rewrite or documentation edits.

#### Files to Modify

- No expected file changes unless validation exposes a narrow issue.

#### Automated Success Criteria

- `make lint-shell`
- `make test`
- `./setup-symlinks.sh validate`
- `make check`

Result:

- `/opt/homebrew/bin/rtk make lint-shell` passed.
- `/opt/homebrew/bin/rtk make test` passed.
- `/opt/homebrew/bin/rtk ./setup-symlinks.sh validate` passed with existing non-blocking warnings for missing `~/.agents/bin` and `~/.agents/bin/rtk`.
- `/opt/homebrew/bin/rtk make check` failed in the non-login tool shell because `openspec` was not on `PATH`.
- `zsh -lc 'rtk make check'` passed after using the login shell PATH where `openspec` is available.
- `git diff --check` passed.

## Expected Modified Files

- `.agents/rules/base.md`
- `tests/healthcheck-automation-test.sh`
- `README.md`
- `docs/development-guide.md`
- `PROJECT_STATUS.md`

## Next Step

Run: `fic-implement-plan thoughts/shared/plans/2026-05-13-karpathy-rule-consolidation.md`
