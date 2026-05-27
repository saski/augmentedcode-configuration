# Lens: Responsibility & Type Design

Logic that lives in the wrong place, or types that are not pulling their weight — passive containers manipulated by outside code.

## The Question

Is each piece of logic in the place that owns the data it works with? Are types carrying behavior and enforcing their own rules?

## How to Spot

- A function that uses several attributes of another class and none of its own
- Anemic objects: classes with only getters and setters, all logic lives in services
- Tell-Don't-Ask violations: code that asks an object for its state, makes a decision, then tells it what to do — the object should make the decision itself
- Domain logic hiding in utilities, helpers, or service layers when it belongs on a domain object
- Classes that can be constructed in invalid states — invariants not enforced in the constructor

## Process

For each function, ask: whose data does this work with? If it reaches into another object for most of its inputs, the logic probably belongs on that object. For each type, ask: does it carry behavior, or do callers do all the thinking?

## Trade-off

Not everything needs to be a rich domain object. Data transfer objects, configuration records, and coordination layers are legitimately separate. The smell is logic that is *envious* — constantly reaching for another object's internals — and types that *should* carry behavior but do not.

## Go Deeper

What other logic is in the wrong place? Where are callers making decisions that belong on the objects they query? Where are helpers doing work that belongs on a domain object?
