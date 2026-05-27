# Lens: Method Length (Reviewer Guide)

## When to Apply

After naming. Easier to see function boundaries when names already communicate well.

## What to Look For in Diffs

- Functions extracted with names describing WHAT, not HOW
- Inline code paragraphs replaced by named calls at a consistent abstraction level
- Long functions split along natural seams (blank lines, comments, phase boundaries)

## First Pass

Worker should find functions with visible paragraphs, comments acting as section headers, and mixed abstraction levels.

Check for false positives: if the worker split a flat sequence of steps all at the same abstraction level, push back — that was a coherent story, not a smell. If extracted methods have mechanism names (`parseAndValidate`, `loopThroughItems`), the names need work — they should describe intent.

## Second Pass

Do the name-vs-body test yourself: read a function's name, then its body. Where the body surprises you with work the name didn't promise, the worker missed an extraction.

Then look for what the worker missed:
- Functions that mix computation with I/O or formatting — always separable
- Sibling functions handling the same pattern at inconsistent depths (one recurses, another doesn't)
- Test methods with multiple act-assert cycles — each cycle should be its own test

Check for wrong fixes: pass-through methods that just delegate to another method with the same signature are indirection, not extraction. If an extracted method only makes sense when you also read the caller, the cut was in the wrong place.

## When Done

Move on when each function's name honestly describes what its body does, and the body works at one level of abstraction.
