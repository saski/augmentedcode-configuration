# Lens: Mutable State & Side Effects (Reviewer Guide)

## When to Apply

After API/interface design. Interfaces are clean — now look at what happens inside: where does state change and are those changes predictable?

## What to Look For in Diffs

- Side effects separated from computations (query functions no longer modify state)
- Global mutable state reduced or encapsulated
- Functions that mutated arguments refactored to return new values
- Temporal coupling eliminated by removing shared mutable state between sequential calls

## First Pass

Worker should find obvious state problems: global mutable state, void functions doing work through mutation, side effects mixed into computations.

## Second Pass

If hidden state issues remain:
- Look for functions that must be called in a specific order — that is temporal coupling through shared state
- Check for functions that modify their arguments — would returning a new value be clearer?
- Look for side effects in functions whose names suggest they are queries or computations

## When Done

Move on when a reader can predict what each function changes without reading its implementation.
