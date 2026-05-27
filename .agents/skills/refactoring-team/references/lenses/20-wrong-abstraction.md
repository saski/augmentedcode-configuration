# Lens: Wrong Abstraction

An abstraction that makes change harder than duplication would. DRY applied too eagerly, producing conditionals and parameter threading to handle callers that have diverged.

## The Question

Is any abstraction in this code fighting its callers? Would duplication actually be simpler?

## How to Spot

- A shared function or class that has grown if-branches or config parameters to handle different callers
- An abstraction where every new use case requires adding a flag or option
- Callers that work around an abstraction rather than through it
- Inheritance where subclasses override most of what the parent does
- Code that was deduplicated but is now harder to understand than the original repetition

## Process

For each abstraction that feels strained:
1. Count the conditionals and parameters that exist only to serve different callers
2. Ask: if I inlined this back into each call site, would each site become simpler?
3. If yes, back out the abstraction — reintroduce duplication, then look for the real commonality

## Trade-off

This lens is the counterbalance to the duplication lens. Duplication says "merge these." This lens says "not if merging makes both worse." The right abstraction simplifies every caller. The wrong one complicates all of them.

## Go Deeper

What other abstractions are under strain? Where is shared code accumulating flags to serve divergent needs?
