# Lens: Emergent Design Rules

A compact checklist to evaluate whether the refactoring work so far actually improved the design — criteria instead of vibes.

## The Question

After all the refactoring passes, is the code actually simpler and better? Apply the four rules of simple design, in priority order:

1. Tests pass — behavior is preserved
2. Reveals intention — the code communicates what it does and why
3. No duplication — but not at the cost of the wrong abstraction
4. Fewest elements — no unnecessary classes, methods, variables, or abstractions

## Process

Review the codebase as a whole after the previous lenses:
- Does every change preserve behavior? Are tests green?
- Is the intent clearer than before the refactoring started?
- Has duplication been reduced without introducing forced abstractions?
- Has unnecessary complexity been removed rather than added? Are there new abstractions that nobody needs yet?

## Trade-off

These rules are ordered by priority. Tests passing trumps everything. Revealing intention trumps removing duplication. Removing duplication trumps minimizing elements. When two rules conflict, the higher-priority rule wins.

## Go Deeper

Where has refactoring added complexity instead of removing it? Where do new abstractions exist that are not yet justified? What is still unclear to a reader?
