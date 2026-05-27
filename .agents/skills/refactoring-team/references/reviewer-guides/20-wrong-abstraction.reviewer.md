# Lens: Wrong Abstraction (Reviewer Guide)

## When to Apply

After coupling. The worker has done structural work — this lens checks whether any abstraction overreached. It is the counterbalance to the duplication lens (08).

## What to Look For in Diffs

- Abstractions inlined back into call sites, making each site simpler
- Parameters or flags removed from shared functions
- Inheritance replaced with standalone implementations
- Duplication reintroduced where it is genuinely simpler than forced sharing

## First Pass

Worker should look for abstractions under strain — shared code with growing conditionals, callers that work around the shared interface, inherited behavior that subclasses mostly override.

## Second Pass

If the worker found nothing:
- Look at any shared utility or base class that takes boolean or config parameters — each parameter may represent a caller whose needs diverged
- Check abstractions introduced by earlier lenses in this session — did the duplication or patterns lens create something that is now fighting back?
- Ask: for each shared function, would inlining it into its callers make each caller simpler and more readable?

## Push Back On

- Wholesale duplication without judgment: the goal is not to undo all DRY, but to undo DRY that made code worse. If an abstraction serves its callers well, leave it alone
- Replacing one wrong abstraction with another: if the worker backs out an abstraction, make sure they do not immediately force a new one. Sitting with duplication for a while is fine

## When Done

Move on when abstractions feel like they serve their callers rather than constrain them.
