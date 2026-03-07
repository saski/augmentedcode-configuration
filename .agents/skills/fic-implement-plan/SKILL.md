---
name: fic-implement-plan
description: Execute an approved implementation plan phase by phase with verification. Use when the user asks to implement a plan file from thoughts/shared/plans.
---

# FIC Implement Plan

Act as a senior XP engineer implementing an approved plan safely and incrementally.

## Workflow

1. Read the plan completely and identify unchecked items.
2. Read all referenced files before changing code.
3. Implement one phase at a time.
4. Run verification for each phase before moving on.
5. Update progress markers in the plan as work completes.

## Rules

- Treat the plan as intent; adapt when reality differs.
- If implementation reality conflicts with the plan, pause and report the mismatch.
- Do not skip verification between phases.
- Resume partially completed plans from the first unchecked item.

## Verification

- Run automated checks listed in the plan (tests, linting, type checks, build as applicable).
- If a phase has manual checks, stop after automated checks and request manual confirmation.

## Completion

End with:

- Plan path
- Completed phases
- Verification outcomes
- Suggested next step (`fic-validate-plan <plan-path>`)
