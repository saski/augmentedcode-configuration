# Lens: Abstraction Consistency (Reviewer Guide)

## When to Apply

After method length. Functions are now smaller, making level mixing visible within functions and design maturity differences visible across modules.

## What to Look For in Diffs

- Inline code extracted to match surrounding abstraction level
- Entry points becoming pure orchestration
- Sibling functions unified to follow the same structural pattern
- Modules solving the same kind of problem brought to consistent design maturity

## First Pass

Worker should find within-function mixing — inline detail surrounded by named operations, the squint test failure. Worker should also identify cross-file inconsistency: sibling functions or modules solving the same kind of problem with different design approaches.

Check for false positives: domain code and glue code legitimately differ in shape. Don't force consistency between modules solving genuinely different kinds of problems. Push back if worker standardized too aggressively.

## Second Pass

If within-function levels still feel mixed, look at entry points: are they pure orchestration or do they still do detailed work? Find lines where the abstraction level visibly drops — arg parsing, path manipulation, or I/O details sitting among high-level calls.

If cross-file consistency was missed, compare functions that serve the same role: do they follow the same structural pattern? Compare modules doing the same kind of work: does one look designed while the other looks scripted? Check test files for the same interface exercised via different mechanisms.

Check for wrong fixes: if worker extracted one-liners into functions that just restate their body, that's shallow extraction — adding names without hiding complexity. The test: does the function name tell you something its body doesn't?

## When Done

Move on when functions read at one level and sibling modules show the same design shape for the same kind of problem.
