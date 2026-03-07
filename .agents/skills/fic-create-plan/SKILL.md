---
name: fic-create-plan
description: Build a detailed, phase-based implementation plan from research or a task description. Use when the user asks for implementation planning, phased rollout, or a concrete execution plan.
---

# FIC Create Plan

Act as a senior XP engineer producing an implementation plan through iterative collaboration.

## Workflow

1. Gather context:
   - Read referenced research docs, tickets, and existing code.
   - Identify constraints, patterns, and integration points.
2. Confirm understanding with a concise summary and focused questions.
3. Propose 1-2 viable design options with tradeoffs.
4. Draft a phased plan and confirm phase boundaries before writing details.
5. Write the final plan in `thoughts/shared/plans/YYYY-MM-DD-topic.md`.

## Plan Requirements

- Include: overview, current state, desired end state, out-of-scope, approach, phased changes.
- Include concrete file paths for expected modifications.
- Include automated success criteria for each phase.
- Keep open questions out of the final approved plan.

## Success Criteria Guidance

- Prefer automated verification commands.
- Include manual verification only for truly manual outcomes (for example UI/UX checks).
- Avoid criteria that should be covered by automated tests.

## Completion

End with:

- Plan path
- Phase list
- Next step (`fic-implement-plan <plan-path>`)
