# Lens: Conditionals & Boolean Logic (Reviewer Guide)

## When to Apply

After semantic clarity. Now that the code tells its story, look at branching logic — is the main path visible, or buried under conditions?

## What to Look For in Diffs

- Nested if/else flattened into guard clauses with early returns
- Complex boolean expressions extracted into named variables or predicate functions
- Multiple conditions with the same outcome consolidated into one named check
- Type-switching replaced with lookup tables or maps

## First Pass

Worker should find the obvious: deep nesting that can be flattened with guard clauses, unnamed boolean expressions, repeated null checks.

Check for false positives: if the worker converted symmetric branches into guard clauses, push back — if/else communicates that both paths are equally important. If the worker named a boolean that's no clearer than the expression (`isCountPositive` for `count > 0`), the name should say more than the code already does. If the worker added 7+ guard clauses, the function does too much — it needs splitting, not more guards.

## Second Pass

Do the main-path test yourself: pick a function and find what it normally does without reading every branch. Then look for what the worker missed:
- Boolean expressions left inline that have a name in the domain
- The same switching pattern in multiple places — the signal for polymorphism
- Guards that could be consolidated — three guards returning the same thing are one concept
- Boolean combinations encoding hidden states — flags checked together are a state machine

Check for wrong fixes: premature polymorphism for a one-off conditional (a lookup table is simpler), Null Objects swallowing errors that should surface, or null checks deep in domain code (fix the boundary or type, not the symptom).

## When Done

Move on when the main path is visible at a glance and branching logic is as simple as it can be.
