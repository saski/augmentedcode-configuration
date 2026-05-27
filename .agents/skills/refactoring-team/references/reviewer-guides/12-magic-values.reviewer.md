# Lens: Magic Values & Configuration (Reviewer Guide)

## When to Apply

After conditionals. Now that branching logic is clean, unnamed values in conditions and function calls become visible.

## What to Look For in Diffs

- Numeric and string literals replaced with named constants or enums
- Boolean arguments replaced with named parameters or enum values
- Configuration values extracted from logic into declarations

## First Pass

Worker should find the obvious: unnamed numbers in conditions, string literals used as keys in multiple places, boolean arguments with no context.

## Second Pass

If magic values remain:
- Check function calls with multiple arguments of the same type — are positional arguments clear without reading the signature?
- Look for string literals that represent domain concepts and could be enums
- Check for configuration values embedded in logic that should be declared separately

## When Done

Move on when every value in the code either has an obvious meaning from context or has been given a name.
