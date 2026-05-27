# Lens: Conditionals & Boolean Logic

Branching logic that obscures the main path, booleans that require mental gymnastics, or type-switching scattered across the codebase.

## The Question

Can the reader see the main path at a glance? Is branching logic as simple as it can be?

## How to Spot

- Deep nesting: the happy path is buried under layers of if/else
- Complex booleans: `if a && !b || c && d` — conditions that lack a name for what they mean
- Repeated switching: the same type-check in multiple places — a single switch is not a smell
- Null checks scattered through domain code instead of handling absence once at the boundary

## Process

Stand back from each function. Can you see the main path — what this code normally does — without reading every branch?

Work from the outside in: flatten nesting with guard clauses first, then name the conditions that remain. If multiple conditions produce the same result, they are one concept — consolidate and name it. If a conditional is a value mapping, a lookup table replaces the branching entirely. If the same type-switching repeats across the codebase, that's the signal for polymorphism.

## Trade-off

A simple conditional is not a smell. Guard clauses and if/else both have their place — use guards when one path is clearly exceptional, if/else when both paths are equally important. Converting symmetric branches into guards misrepresents the logic. If a function has 7+ guard clauses, the problem is not the conditionals — the function does too much.

## Go Deeper

Where do booleans checked in combination encode a hidden state machine — valid states masquerading as independent flags? Where do boolean parameters control branching — a type you haven't named? Where do null checks inside trusted code reveal a boundary that isn't doing its job?
