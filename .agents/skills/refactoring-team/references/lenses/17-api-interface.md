# Lens: API & Interface Design

An interface that is easy to use wrong, hard to use right, or that forces callers into awkward contortions.

## The Question

If someone called this function or used this class for the first time, could they get it right without reading the implementation?

## How to Spot

- Functions with many parameters, especially of the same type in sequence: `resize(width, height)` — which is which?
- Boolean flag parameters that bifurcate function behavior
- Methods that must be called in a specific order with no enforcement
- Data clumps: values that always travel together but have no name or type of their own
- Implementation details leaking through the public interface

## Process

For each public function or class, look at it from the caller's perspective. What could go wrong? What is easy to confuse? What forces the caller to know about internals?

## Trade-off

Internal helper functions do not need the same API polish as public interfaces. Focus on boundaries — the surfaces that other modules, classes, or external callers depend on.

## Go Deeper

What other interfaces are easy to misuse? Where do callers have to know too much about internals? Where do values travel together without a name?
