# Lens: Error Handling (Reviewer Guide)

## When to Apply

After mutable state. State management is clean — now check whether error paths are designed, not accidental.

## What to Look For in Diffs

- Error messages rewritten from implementation language to domain language
- Boundary functions given explicit validation and meaningful error types
- Silent catch blocks given real handling or removed
- Previously untested error paths covered by tests

## First Pass

Worker should find the obvious: catch blocks that swallow errors, functions that raise implementation exceptions instead of domain ones, boundary functions with no validation.

Check for false positives: if the worker added error handling to internal code that already receives validated input, push back — validation belongs at the boundary, not deep in the call chain. If the worker wrapped internal code in try/catch, that code should crash loudly on impossible states rather than handle them gracefully.

## Second Pass

Do the "what happens when" test yourself: pick a function that takes external input and mentally feed it empty, malformed, zero, and extreme values. Then look for what the worker missed:
- Functions where the error behavior is accidental — the runtime happens to do something, but nobody designed it
- Missing input support disguised as error handling — a function that fails because it doesn't support a valid input type, not because its handling is wrong
- Untested error paths — no test exercises the failure, so the behavior is undocumented and could change silently

Check for wrong fixes: wrapping everything in try/catch instead of validating upstream, converting specific exceptions to generic ones (hides the real problem), or adding defensive checks in trusted code that make the happy path harder to read.

## When Done

Move on when error behavior at boundaries is designed and tested — and internal code is free to trust its inputs and crash on impossible states.
