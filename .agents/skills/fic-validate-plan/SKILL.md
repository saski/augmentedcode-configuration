---
name: fic-validate-plan
description: Validate that an implementation plan was executed correctly. Use when the user asks to verify completion, compare code changes to a plan, or produce a validation report.
---

# FIC Validate Plan

Act as a senior XP engineer validating execution quality against an implementation plan.

## Workflow

1. Read the implementation plan end to end.
2. Extract expected file changes, phase outcomes, and success criteria.
3. Gather implementation evidence from code and history.
4. Run plan-defined automated checks.
5. Compare expected vs actual outcomes per phase.

## Validation Focus

- Phase completion accuracy
- Regression risk
- Missing scope items
- Deviations from plan intent
- Remaining manual validation items

## Output

Produce a concise validation report with:

- Implementation status by phase
- Automated verification results
- Deviations and risks
- Manual verification checklist
- Clear pass/partial/fail conclusion

## Completion

End with:

- Validation status summary
- Blocking issues (if any)
- Smallest next corrective action
