# review

**Purpose:** a focused human-grade review of a change, not a tool dump.

## Detect

Scope first: if the target is a path, review that path. Otherwise review the working diff
(`git diff` against the merge base, or staged/unstaged if not a branch). If there is no
diff and no path, ask what to review.

Use the other commands' tools as inputs where they help: run the detected stack's linter,
dependency auditor, and dead-code detector (as `analyze`, `security`, and `deadcode`
would for that stack — see SKILL.md § Stack detection) over the changed files and fold
real findings in. Then read the change for what tools miss:

- Correctness: off-by-one, error paths, async/await misuse, missed `null`/empty cases.
- Edge cases the change introduces or fails to handle.
- Design: wrong abstraction level, leaky boundaries, state that should not be shared
  (deep module design is `design`'s job — flag, don't audit it here).
- Slop: invented APIs, plausible-but-wrong library usage, over-engineering, fake
  robustness (see `analyze.md` smells).

## Triage

Three buckets: **blocking** (correctness/security), **should-fix** (design/maintainability),
**optional** (preference — mark as such, keep few). Cite `file:line` and explain *why* it
is wrong, not just that it differs from taste.

## Fix policy

Review proposes; it does not auto-edit. After the user has read the review, offer the
blocking fixes as an itemized checklist (one per finding, with its diff) and apply only
the approved items — Confirmation flow per SKILL.md. should-fix/optional stay as proposals.

## Report

The three buckets, ordered, each item: `file:line` — issue — why — suggested fix.
