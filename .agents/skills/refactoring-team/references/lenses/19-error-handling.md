# Lens: Error Handling

Error paths that nobody designed — failures that leak implementation details, go untested, or get silently swallowed.

## The Question

When this code receives bad input or hits a failure, is the behavior designed or accidental?

## How to Spot

- Implementation leaking through errors: a function raises the exception of the library it wraps — the error message speaks implementation language, not domain language
- Undesigned error paths: a function can receive invalid input but there is no test and no explicit handling — the behavior is whatever the runtime happens to do
- Untested boundaries: functions that take external input but no test exercises them with empty, zero, malformed, or extreme values
- Silent swallowing: catch blocks that discard failures, catch-all handlers that mask bugs, functions returning null to signal failure without context

## Process

Feed the code inputs it wasn't designed for. Pick a function that takes external input and ask: what happens when the input is empty? Malformed? Zero where it shouldn't be? If you can't answer without reading the implementation, the error behavior is accidental — nobody designed it. Start with the most-called functions: they encounter the widest range of input and are the most costly to leave undesigned.

## Trade-off

Validate at the boundaries, trust internally. Code behind a validated boundary can assume its inputs are good — adding defensive checks there obscures the real logic. When internal code hits an impossible state, crashing immediately and visibly is more robust than handling gracefully. The goal is designed error paths at the edges, not try/catch everywhere.

## Go Deeper

Where do implementation exceptions surface as domain errors? Where does a function fail not because its error handling is wrong but because it doesn't support a valid input type? Where is error behavior purely accidental — the implementation happens to throw, but nobody decided it should?
