# Lens: API & Interface Design (Reviewer Guide)

## When to Apply

After object/type design. Types are well-designed internally — now check the surfaces they present to callers.

## What to Look For in Diffs

- Parameter lists shortened via parameter objects or data clump extraction
- Boolean flags replaced with separate methods or enum parameters
- Temporal coupling made impossible (builder pattern, required constructor args)
- Implementation details hidden behind cleaner interfaces

## First Pass

Worker should find obvious API problems: long parameter lists, boolean flags, data clumps that always travel together.

## Second Pass

If interfaces are still awkward:
- Try using each public function as a caller — what could you get wrong?
- Look for methods that must be called in a specific order with no enforcement
- Check for values that always appear together in function signatures — they want a name

## When Done

Move on when public interfaces are hard to misuse and callers do not need to know about internals.
