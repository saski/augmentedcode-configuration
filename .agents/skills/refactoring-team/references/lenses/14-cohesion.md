# Lens: Cohesion & Boundaries

A class that serves two masters, a file too thin to justify its boundary, or a module whose contents are grouped by convenience instead of by concept.

## The Question

When this unit changes, does the whole thing change — or just part of it? Do the boundaries between units follow the boundaries between ideas?

## How to Spot

- A class whose methods cluster into groups that touch different fields — two concepts sharing one name
- Files named "utils," "helpers," "constants" — domain concepts hiding behind vague containers
- A test file mixing unit tests and integration tests, or test classes grouping unrelated scenarios by what they exclude ("TestEdgeCases") rather than what they cover
- A module so thin that its boundary adds navigation cost without hiding any complexity — a file you could inline without losing clarity

## Process

For each unit, ask: when one thing inside it changes, does everything else need to change too? If only part changes, the unit contains more than one idea. If two separate units always change together, they may be one idea split across a boundary.

Then check whether each boundary earns its keep. A module exists to hide complexity — if importing it costs as much mental effort as inlining its contents, the boundary is overhead, not structure. Conversely, if a file has grown clusters of functions that change independently, each cluster is a module waiting to emerge.

## Trade-off

Over-splitting creates its own damage: tiny modules that all depend on each other, navigation overhead that outweighs any clarity gained, and abstractions extracted before the pattern is clear. A 500-line file where everything changes together is more cohesive than five 100-line files with circular imports. Merge back when the split increased coupling instead of reducing it.

## Go Deeper

Where do test files mix fast unit tests with slow integration tests — different feedback loops forced into one run? Where do tests live in the wrong file — a parsing test among formatting tests because someone put it in the nearest file? Where do constants from unrelated concerns share a file because they're all "config"? Where do import hacks like sys.path manipulation reveal that code needing to work together can't reach each other through the natural hierarchy?
