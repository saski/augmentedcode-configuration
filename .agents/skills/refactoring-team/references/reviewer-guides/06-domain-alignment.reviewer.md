# Lens: Domain Alignment (Reviewer Guide)

## When to Apply

After primitive obsession. Now that concepts are extracted from primitives, check if they're the RIGHT concepts — domain concepts, not implementation groupings.

## What to Look For in Diffs

- New types or classes representing domain concepts that previously existed only as raw values
- Domain rules extracted from scattered conditionals into named policies or methods
- Code that a domain expert could now follow without reading implementation details

## First Pass

Worker should find the obvious: concepts the code works with constantly but never names, domain rules buried in guard clauses, values that always travel together.

Check for false positives: if the worker introduced domain types for infrastructure concerns (naming a database adapter after a business concept), push back — technical code uses technical names. If the worker modeled a concept they don't fully understand, verify the model matches the actual domain, not the worker's assumption about it.

## Second Pass

Do the describe-then-compare test yourself: explain what the code does in domain language, then check if those words exist in the code. Where your description uses a noun the code doesn't have, the worker missed a concept.

Then look for what the worker missed:
- Sequences that encode domain rules (ordering that matters but nothing explains why)
- Values playing dual roles — the same string or constant serving two unrelated domain purposes
- Implicit grammars or protocols the code implements but never declares

Check for wrong fixes: if the worker created a domain type that's just a thin wrapper with no behavior or validation, it may be premature — a concept worth naming should also carry rules. If the worker forced every concept into a class when a well-named function or constant would suffice, that's over-modeling.

## When Done

Move on when the code's structure mirrors the domain's structure — the concepts a domain expert would name all have homes in the code.
