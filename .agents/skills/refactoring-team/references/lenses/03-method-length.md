# Lens: Method Length

Functions that do unnamed work — phases, details, or side-jobs hiding inside a body that claims to do one thing.

## The Question

Does each function do one thing that its name honestly describes? Or is work hiding inside that deserves its own name?

## How to Spot

- Blank-line "paragraphs" inside a function — the developer already sensed separate concerns
- Comments explaining what the next block does — each is an extraction waiting for a name
- Mixed abstraction levels: orchestration calls next to inline detail work in the same body
- A function whose body has phases: setup, then processing, then formatting output

## Process

Read each function's name, then its body, one function at a time. Where the body does work the name doesn't promise, something needs extracting.

Look for the seams: blank lines, comments, and shifts in abstraction level are natural cut points. For each potential extraction, ask: can I name this piece after WHAT it does, not HOW? If the name would just restate the code (`loopAndSum`, `parseAndValidate`), the boundary is wrong — look for a different cut.

## Trade-off

Length is not the signal — a flat sequence of steps at one abstraction level can be long and clear. The smell is mixed levels or unnamed phases. Don't split a coherent story into pieces that must be read together — two methods that only make sense as a pair are worse than one longer method. If you can't name the extracted piece honestly, don't extract yet.

## Go Deeper

Where do functions mix computation with presentation — calculating a result AND formatting it? Where do sibling functions handle the same structure at different depths — one recurses, another doesn't, and nothing explains why? In tests: where do multiple act-assert cycles live in one method instead of being separate tests?
