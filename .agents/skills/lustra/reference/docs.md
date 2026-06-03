# docs

**Purpose:** documentation that matches the code — the bus-factor leg of due diligence.

## Detect

1. README/setup drift: run the documented install/build/run steps mentally against the
   actual manifest and scripts. Flag commands, env vars, and versions that no longer
   match reality.
2. Public-surface coverage: enumerate exported API (public functions, CLI commands, HTTP
   routes, config keys) and flag the ones with no doc or doc comment.
3. Stale/lying docs: comments and docs describing behavior the code no longer has,
   examples that would not run, dead links, TODO/`coming soon` that never came.
4. Missing essentials for the project type: no README, no LICENSE reference, no
   contributing/setup notes where the project clearly needs them.

## Triage

Rank: wrong docs (actively misleading) > missing docs for public surface > thin docs >
cosmetic. A confidently wrong README is worse than no README — say so. Do not demand
docs for private internals.

## Fix policy

- Auto: nothing — prose is judgment.
- Propose (diff + ask): corrected steps/examples grounded in the actual code, and
  doc stubs for undocumented public surface. Never invent behavior to fill a gap; if the
  code's intent is unclear, flag it as a question, not a fabricated description.

## Report

Drift (doc vs. reality, with the mismatch), undocumented public surface, stale items —
each `file:line`/section with the concrete correction proposed.
