# Lens: Naming

Names that force you to read the implementation to understand what the code does — or worse, names that mislead you about what it does.

## The Question

Could someone unfamiliar with this code understand what each function, variable, and class does from its name alone?

## How to Spot

- Names that describe mechanism instead of intent: `processData` when it really validates, `handle` when it really transforms
- Sibling names that blur distinctions: functions that do different things but whose names don't communicate how they differ
- Names that lie: the code evolved but the name didn't, so it now promises something it doesn't deliver
- Generic containers: `-Manager`, `-Utils`, `-Helper`, `data`, `info`, `result` — concepts hiding behind vague labels

## Process

Read names as if you're new to this codebase. For each name that makes you look at the implementation, ask: what would I call this if I were explaining it to someone? That's the name it should have.

For sibling functions, line up their names and ask: can I tell them apart? If not, what's the actual distinction? Name each after the specific thing that makes it different from its siblings. Use one verb for one concept — if `parse`, `fetch`, and `get` all mean the same operation, pick one and use it everywhere.

## Trade-off

Not every name needs to be long or elaborate. Short names are fine in small scopes — `i`, `e`, `ctx` carry meaning through convention. Names inside a class don't need to repeat the class name (`cart.getCartItems()` → `cart.items()`). And don't rename something you don't fully understand — a confidently wrong name is worse than a vague one. When naming is hard, that's often a design problem surfacing, not just a vocabulary problem.

## Go Deeper

Where do test names describe operations instead of behaviors — what would a failing test tell you? Where do noise-word suffixes create phantom distinctions (`Product` vs `ProductInfo` vs `ProductData`)? Where would you use a different word than the code uses if you were explaining it out loud?
