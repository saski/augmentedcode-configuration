# Lens: Duplication

Knowledge that exists in more than one place — not just copied code, but shared algorithm skeletons, re-tested behavior, and rules re-derived where they don't belong.

## The Question

What knowledge exists in more than one place? Where would a single conceptual change require editing multiple locations?

## How to Spot

- Same algorithm shape with different details: multiple functions that all find-split-recurse or validate-transform-return — the skeleton is duplicated even though the specifics differ
- Same behavior tested in multiple places: one test class already proves it, another re-verifies it with overlapping scenarios
- Tests that recompute production logic: the assertion re-derives what the code computes instead of stating an expected value, coupling test and production to the same knowledge
- Parallel structures that must stay in sync: two lists, two maps, two switch statements encoding the same set of things

## Process

Shift from looking at code similarity to looking at knowledge ownership. For each piece of domain knowledge — a business rule, a format, a set of valid values — ask: how many places encode this? If more than one, a change to that knowledge forces multiple edits. Would these change together, for the same reason? That's the duplication that matters.

## Trade-off

Duplication is far cheaper than the wrong abstraction. Don't consolidate until you've seen the pattern three times and the reason to change is clearly shared. Premature DRY creates abstractions that accumulate conditionals and parameters to serve divergent callers — then the cure is worse than the disease.

## Go Deeper

Where are tests encoding knowledge that production code already owns? Where does structural similarity hide behind different variable names — functions that don't look alike but follow the same skeleton? Where has past DRY-ing already gone wrong — an abstraction straining under conditionals because the callers diverged?
