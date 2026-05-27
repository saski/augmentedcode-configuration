# Lens: Duplication (Reviewer Guide)

## When to Apply

After patterns. Once patterns are explicit, duplicate encodings of the same concept become visible — in production code, in tests, and between the two.

## What to Look For in Diffs

- Parallel structures consolidated into a single source of truth
- Structural duplication extracted into a shared skeleton (template method, shared algorithm)
- Test scenarios deduplicated — behavior proved once, not re-tested across classes
- Test assertions using pre-calculated expected values instead of recomputing production logic

## First Pass

Worker should find the obvious: parallel structures encoding the same set of things, structural duplication (same algorithm shape repeated), test classes re-verifying behavior proved elsewhere, tests that mirror production logic in assertions.

Check for false positives: identical code that serves different domain purposes is not duplication. Two functions may look the same today but represent different business rules that will change independently. Push back if the worker merged code that happens to look alike but has different reasons to change.

## Second Pass

If the worker missed things:
- Apply the "change for the same reason" test: pick a business rule and trace where it's encoded — if it appears in more than one place, that's knowledge duplication
- Look at test classes: does any class re-test behavior that another class already covers?
- Check for tests that recompute what production code computes — the assertion should state the expected value, not re-derive it
- Look for redundant assertions: does assertIsInstance add anything when assertEqual on the value already proves the type?

Check for wrong fixes: if the worker extracted a premature abstraction to eliminate surface duplication, that may create a wrong abstraction — conditionals and parameters to serve divergent callers. Better to leave duplication than force a bad merge. The fix for structural duplication is a shared skeleton, not copy-paste elimination.

## When Done

Move on when duplicated knowledge is consolidated where the reason to change is genuinely shared, and left alone where the similarity is coincidental.
