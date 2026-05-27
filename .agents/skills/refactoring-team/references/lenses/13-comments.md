# Lens: Comments & Documentation

Comments that lie, repeat the code, explain what instead of why, or exist because the code is not clear enough on its own.

## The Question

Is each comment here because the code cannot express it, or because the code failed to?

## How to Spot

- Comments that say what the code does — if the code is readable, the comment is noise
- Outdated comments that no longer match the code
- TODO comments that have been there for a long time
- Commented-out code kept "just in case"
- Comments compensating for bad names: `// get user by email` above `getUserByEmail()`

## Process

For each comment, try to make it unnecessary — rename, extract, or restructure so the code speaks for itself. Keep only comments that explain *why* something non-obvious was done this way.

## Trade-off

Some comments are genuinely valuable: explaining a non-obvious algorithm choice, documenting a workaround for a known issue, or clarifying a business rule that would be invisible in code. The goal is not zero comments but zero *unnecessary* comments.

## Go Deeper

What other comments are masking unclear code? Where is commented-out code lingering? Where are genuinely complex decisions missing a "why" comment?
