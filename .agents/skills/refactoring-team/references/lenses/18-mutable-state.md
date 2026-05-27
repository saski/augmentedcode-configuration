# Lens: Mutable State & Side Effects

State that changes in ways that are hard to track, or functions that do invisible work alongside their main purpose.

## The Question

Where does state change in this code, and can a reader predict those changes?

## How to Spot

- Global or module-level mutable state
- Functions that modify their arguments unexpectedly
- Temporal coupling: functions that must be called in a specific order because they share mutable state
- Side effects mixed into computations — a calculation that also logs, sends, or writes
- Functions returning void that do all their work through mutation

## Process

For each function, ask: does it change anything beyond its return value? If so, is that change visible to the caller? For shared state, ask: who can modify this, and can they step on each other?

## Trade-off

Some mutation is necessary and natural. The goal is not purity everywhere but *predictability* — a reader should be able to tell what a function changes without reading its implementation. Push side effects to the edges, keep the core logic pure.

## Go Deeper

What other state changes are hidden? Where are side effects mixed into computations? Where does temporal coupling force a specific calling order?
