# Lens: Primitive Obsession

Domain concepts hiding as raw data — strings, tuples, and dicts carrying meaning the type system doesn't capture.

## The Question

What domain concepts in this code exist only as primitives?

## How to Spot

- Values that travel together: the same two or three primitives passed as a group between functions, unpacked the same way each time
- Strings carrying structure: values split, joined, parsed, or validated in consistent patterns — a format hiding inside a string
- Scattered parsing: the same guard clause, validation, or string-splitting logic repeated across multiple locations
- Type signatures that lie: a function accepts `str` or `dict` but only works correctly with a specific format or set of keys

## Process

Describe the code to someone in domain language. Every noun you use that doesn't exist as a type in the code is a missing concept. The gap between how you talk about the code and what the type system captures is where the primitives are hiding.

## Trade-off

Not every primitive needs a type. Act when parsing or validation is duplicated, when values always travel together, or when bugs come from confusing one value for another. Leave primitives alone when the concept is purely local and has no rules or behavior worth naming.

## Go Deeper

Where are intermediate representations missing — raw strings flowing end-to-end because nothing ever parses them into structured form? What values always travel together but get passed as separate arguments? Which functions silently assume a string has a specific format without the type making that guarantee visible?
