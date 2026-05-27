# Lens: Naming (Reviewer Guide)

## When to Apply

After formatting is clean. Names are easier to evaluate without surface noise.

## What to Look For in Diffs

- Names shifted from mechanism to intent (implementation verbs → domain verbs)
- Sibling names differentiated — each communicates what makes it distinct
- Generic placeholders replaced with specific domain concepts

## First Pass

Worker should find names that force implementation reading — generic verbs, vague containers, abbreviations that obscure.

Check for false positives: if the worker renamed conventional short names in small scopes (`i`, `e`, `ctx`, `req`/`res`), push back — these carry meaning through convention and expanding them adds noise. If the worker renamed one sibling but not its family (`parse` in one place, `deserialize` in another for the same operation), that's worse — inconsistency creates false signal about whether they're different.

## Second Pass

Do the explain-aloud test yourself: describe what the code does in plain language. Where do you use a different word than the code uses? Those are the names the worker missed.

Then look for what the worker missed:
- Sibling functions whose names still blur their distinctions
- Names that were accurate once but now lie because the code evolved
- Test names that describe operations (`test_addition`) instead of behavior (`test_two_numbers_are_summed`)

Check for wrong fixes: if the worker renamed something they didn't understand, the new name may be confidently wrong — verify the name matches what the code actually does, not what the worker assumed. If a name is hard to improve, the problem might be the code's design, not the vocabulary.

## When Done

Move on when names communicate intent — a reader can understand the code's purpose without reading implementations.
