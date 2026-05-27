# Lens: Coupling & Dependencies

Code that knows too much about too many things. A change in one place ripples unpredictably through many others.

## The Question

What does each unit depend on, and is that dependency necessary?

## How to Spot

- Reaching through objects: `a.getB().getC().doThing()` — this unit knows its collaborators' internals. Chains through data structures or fluent APIs are navigation, not coupling.
- One change, many files: a single conceptual change forces edits scattered across the codebase
- Pass-through: parameters or data flowing through a function untouched, coupling it to both caller and callee

## Process

Trace the ripple outward: if I changed this unit, what else would break? If the answer crosses many boundaries, the coupling is too tight.

## Trade-off

Some coupling is necessary — zero coupling means the code does nothing. The question is whether each dependency is *essential* (this unit genuinely needs it) or *accidental* (an artifact of how the code was written). Coupling along a stable axis that never triggers change is cheap to keep.

## Go Deeper

What coupling is still invisible? Where do framework details leak into domain logic? Where do modules depend on each other in circles? And beware: wrapping a train wreck in a delegation method doesn't reduce coupling — it hides it.
