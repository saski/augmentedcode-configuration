# Lens: Abstraction Consistency

Functions that mix orchestration with detail, and modules solving the same kind of problem at different levels of design maturity.

## The Question

Are similar problems solved at the same level of abstraction — within functions and across the codebase?

## How to Spot

- Inline detail surrounded by named operations: the squint test fails — one block looks denser or more mechanical than the lines around it
- Sibling functions with different approaches: functions solving the same kind of problem, but one follows a clean pattern while the other hand-rolls the logic
- Design maturity mismatch across modules: one module has clear separation of concerns while another doing the same kind of work is a flat script with everything inlined
- Same interface tested differently: one test suite passes arguments while another patches globals to exercise the same behavior

## Process

Start within functions. Blur your eyes and scan: if all lines look similar in density, the function is at one level. If a block looks denser or more mechanical, that's a level break — detail that should be behind a name.

Then zoom out. Find modules that solve the same kind of problem. Do they show the same design shape? When one has named concepts and clear boundaries while its sibling is a monolithic script, the design understanding hasn't propagated. Inconsistency breeds more inconsistency — quality erodes toward the worst example.

## Trade-off

Not every extraction improves things. If the extracted function's name restates its one-line body, the extraction adds interface complexity without hiding meaningful work. A 30-line function at one consistent level is better than five shallow wrappers. And cross-file consistency only applies between modules solving the same kind of problem — domain code and glue code legitimately differ in shape.

## Go Deeper

Where do sibling functions that should follow the same pattern use different approaches — recursion vs iteration, named steps vs inline logic? Where has one module matured in design while its peer remains a first draft? Where do tests reveal the inconsistency — the same interface exercised through fundamentally different mechanisms?
