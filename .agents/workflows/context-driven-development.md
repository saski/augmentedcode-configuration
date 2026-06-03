---
description: Structured development cycle (Research -> Plan -> Implement -> Verify) aligned with the repo's FIC workflow.
---

# Context-Driven Development Workflow

This workflow implements the Frequent Intentional Compaction (FIC) strategy used in this repository.

## Core Principle
Keep research, planning, implementation, and verification as separate phases. Persist durable artifacts in `thoughts/shared/` so long-running work does not depend on one chat window.

## Phase 1: Research
**Goal**: Understand the current state.

1. Use the `fic-research` skill when the task is primarily investigation.
2. Read the current code, tests, docs, exports, and callers before proposing changes.
3. Save durable findings in `thoughts/shared/research/` when the investigation should survive context compaction or handoff.

## Phase 2: Plan
**Goal**: Design the change.

1. Use `fic-create-plan` when the work needs a phased implementation plan.
2. Capture the context, proposed changes, and verification approach in `thoughts/shared/plans/`.
3. Keep the plan small, testable, and reversible. If the work is already obvious and low risk, skip formal planning and proceed directly to implementation.

## Phase 3: Implement
**Goal**: Execute the plan in baby steps.

1. Use `fic-implement-plan` when following an approved plan.
2. Prefer outside-in TDD for new behavior and bug fixes whenever practical.
3. Make the smallest change that satisfies the goal, and update the relevant research or plan artifact if the implementation changes the original approach.

## Phase 4: Verify
**Goal**: Prove it works.

1. Run the narrowest useful checks while iterating, then run the repo's canonical validation command, `make check`, for meaningful changes.
2. Use `fic-validate-plan` when the task needs plan-versus-implementation evidence.
3. Record what changed, what was verified, and any remaining gaps or risks before closing the work.
