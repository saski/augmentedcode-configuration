# Lens: Emergent Design Rules (Reviewer Guide)

## When to Apply

After wrong abstraction. All refactoring passes are done — this lens evaluates the result against simple design criteria before the final meta-lenses.

## What to Look For

This is an evaluation lens, not a refactoring lens. The reviewer should assess the codebase against the four rules:

1. Tests pass — has any behavior been broken? Run the full test suite
2. Reveals intention — is the code clearer than when we started?
3. No duplication — has duplication been reduced without forced abstractions?
4. Fewest elements — have unnecessary classes, methods, or abstractions been removed rather than added?

## First Pass

Worker should review the codebase holistically and flag anything that got worse during refactoring — unnecessary abstractions added, clarity reduced, complexity increased.

## Second Pass

If the worker found nothing:
- Compare the current code to the starting point — is intent clearer or did refactoring add indirection?
- Check for new abstractions that serve only one caller — are they earning their keep?
- Look for complexity added by earlier lenses that later lenses did not clean up

## When Done

Move on when the code is demonstrably simpler and clearer than when the refactoring started. If any refactoring made things worse, undo it before proceeding to the final meta-lenses.
