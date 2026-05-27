# Lens: Domain Alignment

Concepts that exist in the problem but not in the code — domain rules hiding as implementation details, structures the code works with constantly but never names.

## The Question

What would a domain expert call the things this code works with? Do those concepts exist in the code, or are they implicit?

## How to Spot

- Values that always travel together but have no name — the same group of parameters passed around, a concept dying to become a type
- Domain rules hiding as code: a guard clause, a magic comparison, or a hardcoded sequence that encodes a business rule nobody named
- The code works with a concept constantly but it only exists as a raw string, number, or dict — never as a named thing with its own behavior
- You'd explain the code using words that don't appear anywhere in it — the gap between how you'd describe it and how it reads

## Process

Describe what this code does as if explaining it to someone who knows the problem domain but not the codebase. Write it down. Now compare your description to the code: every noun in your description that doesn't exist as a type, class, or named concept in the code is a missing domain concept. Every rule you stated that lives only as an unnamed conditional or a hardcoded sequence is an implicit domain rule that needs a name.

## Trade-off

Not all code is domain code. Infrastructure, framework glue, and utilities should use technical language — forcing domain names onto adapters and repositories creates confusion. And don't model what you don't understand yet — a wrong domain concept is harder to remove than no concept at all. Wait until you see the concept in at least three places before giving it a home.

## Go Deeper

Where does the order of operations encode a domain rule — a sequence that silently breaks if reordered, but nothing explains why the order matters? Where does the same string or value serve two unrelated roles in the domain — a coupling that would surprise a domain expert? Where do tests name a concept that the production code doesn't?
