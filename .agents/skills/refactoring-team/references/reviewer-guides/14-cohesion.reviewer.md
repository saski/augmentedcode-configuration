# Lens: Cohesion & Boundaries (Reviewer Guide)

## When to Apply

After comments. Surface cleanup is done — now look at whether the contents of each unit belong together and whether boundaries are in the right places.

## What to Look For in Diffs

- Classes or modules split into more cohesive units
- Unrelated functions moved out of convenience groupings into domain-named modules
- Test files reorganized by level or fixture, tests moved to the file matching their subject
- Thin wrapper modules merged into their callers

## First Pass

Worker should find the obvious: classes whose methods split into groups using different fields, utils files that are grab-bags of unrelated functions, test files mixing unit and integration tests, tests living in the wrong file, constants from different concerns crammed into one file.

Check for false positives: a large file where everything genuinely changes together is NOT a cohesion problem — size alone is not a signal. A test file with many tests for one complex class is fine if they all test that class. If the worker split a module but the pieces still import each other heavily, the split made things worse — push back.

## Second Pass

Apply the change-pattern test yourself: pick a class or module and ask what would change if one requirement shifted. If the answer is "only this half," those halves are separate concepts. Then look for what the worker missed:
- Test classes named by exclusion ("TestEdgeCases," "TestMisc") rather than by concept — often a symptom of missing structure in the production code
- Tests that don't match the file they're in — a parsing test among formatting tests, orphaned by convenience
- Constants grouped by implementation role ("config," "constants") instead of by the domain concern they serve
- sys.path manipulation or import hacks revealing the module structure doesn't match the dependency structure

Check for wrong fixes: renaming a grab-bag test class without splitting it by concept, extracting a module thinner than the import overhead it creates, splitting a legitimately cohesive file just because it's long, or moving tests between files without verifying the new grouping reflects the subject under test.

## When Done

Move on when each unit changes as a whole and boundaries fall between ideas, not through them.
