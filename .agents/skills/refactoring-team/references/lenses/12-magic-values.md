# Lens: Magic Values & Configuration

Unexplained numbers, strings, and flags scattered through the code with no name or context.

## The Question

Does every value in this code have a name that explains its meaning?

## How to Spot

- Numeric literals that are not 0 or 1: `if retries > 3`, `timeout = 5000`
- String literals used as keys, identifiers, or flags in multiple places
- Boolean arguments with no context: `doThing(true, false, true)`
- Configuration hard-coded into logic rather than injected or declared separately

## Process

For each literal value, ask: would someone unfamiliar with this code know what it means? If not, give it a name — a constant, an enum, or a configuration value that communicates its purpose.

## Trade-off

Not every literal needs a name. `0`, `1`, `""`, and obvious defaults are fine. The smell is values whose meaning is invisible without context.

## Go Deeper

What other unnamed values are hiding in conditions, function calls, or configuration? Where do string literals carry meaning that could be an enum?
