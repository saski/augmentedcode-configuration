# Lens: Responsibility & Type Design (Reviewer Guide)

## When to Apply

After cohesion. Units are internally coherent — now check whether logic is in the right unit and whether types carry their own weight.

## What to Look For in Diffs

- Logic moved from services or helpers onto the domain objects that own the data
- Data classes gaining behavior (methods that enforce invariants or make decisions)
- Tell-Don't-Ask refactorings: callers asking objects to act instead of querying and deciding
- Duplicated logic across callers consolidated onto the callee
- Inheritance replaced with composition where appropriate

## First Pass

Worker should find obvious problems: functions that reach heavily into another object's data, anemic types with only getters/setters, domain logic hiding in utility layers.

## Second Pass

If misplaced logic or passive types remain:
- For each function, count whose data it uses most — if it uses another object's data more than its own, the logic likely belongs there
- Look for decisions made *about* objects that the objects could make themselves
- Check constructors — can the type be created in an invalid state?
- Check for "orchestration" classes that contain business rules instead of just coordinating

## Push Back On

- Moving truly cross-cutting concerns (logging, orchestration, coordination) onto domain objects — those are legitimately separate
- Over-enriching simple data transfer objects or configuration records — not everything needs behavior

## When Done

Move on when logic lives with the data it works with, types enforce their own invariants, and services coordinate rather than compute.
