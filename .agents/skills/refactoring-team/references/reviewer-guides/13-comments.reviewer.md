# Lens: Comments & Documentation (Reviewer Guide)

## When to Apply

After magic values. By now the code is expressive — comments compensating for unclear code should stand out.

## What to Look For in Diffs

- Comments removed and replaced by clearer code (renamed variables, extracted functions)
- Commented-out code deleted
- Stale TODO comments removed or acted on
- Genuinely valuable "why" comments preserved

## First Pass

Worker should remove obvious noise: comments that restate the code, commented-out code, outdated comments.

## Second Pass

If comment noise remains:
- Look for comments that explain *what* — can the code be restructured to make the comment unnecessary?
- Check for missing "why" comments on non-obvious decisions — the worker should add these, not just delete
- Look for TODOs that have been present long enough to be stale

## Push Back On

- Deleting comments that explain genuine complexity or non-obvious business rules — those should stay
- Adding new comments instead of making code clearer

## When Done

Move on when remaining comments earn their place — each explains something the code cannot express on its own.
