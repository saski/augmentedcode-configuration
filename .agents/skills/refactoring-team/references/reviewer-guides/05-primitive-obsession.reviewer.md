# Lens: Primitive Obsession (Reviewer Guide)

## When to Apply

After abstraction consistency. Now that functions are clean and cohesive, hidden concepts become visible — primitives carrying meaning the code doesn't name.

## What to Look For in Diffs

- Tuples or parallel parameters replaced with named types (NamedTuple, dataclass)
- Strings with structure replaced by parsed representations
- Scattered validation or parsing consolidated into a type's constructor
- Type signatures narrowed from generic primitives to domain-specific types

## First Pass

Worker should find the obvious: values that travel together as separate primitives, strings parsed or validated the same way in multiple places, dicts with known keys accessed repeatedly.

Check for false positives: if the worker wrapped a primitive that has no validation, no formatting, and no behavior, push back — a Name class wrapping a bare string with zero logic is overhead, not design. If the worker created types for purely local values or simple algorithmic counters, those are fine as primitives.

## Second Pass

Do the description test yourself: pick a module and explain what it does in domain language. Any noun you use that doesn't exist as a type is a concept the worker may have missed. Then look for:
- Raw strings flowing through the system that could be parsed into structured form at the boundary
- Groups of primitives always passed together — remove one, do the others make sense alone? If not, they're a type
- The same format assumption scattered across functions — every place that splits on a delimiter or checks for a prefix is a missing parser

Check for wrong fixes: types introduced but all logic left external (the type should attract behavior, not just rename the data). Watch for parsing scattered across call sites when a single parse-once point at the boundary would suffice.

## When Done

Move on when primitives feel intentional — domain concepts have names, values that travel together are grouped, and no parsing logic is scattered across the codebase.
