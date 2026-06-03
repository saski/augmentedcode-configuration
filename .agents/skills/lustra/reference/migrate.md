# migrate

**Purpose:** execute one major dependency upgrade, isolated and verified. `deps` only
reports health and batches safe bumps; `migrate` does the risky part — read the breaking
notes, apply codemods, run the suite, keep the change isolated.

## Detect

One major per invocation, never chained. Take the target dependency from the argument or
from `deps`'s **Major** group. Detect the stack (SKILL.md § Stack detection), then:

1. Read the changelog / release notes / migration guide for the exact version delta —
   quote the breaking items, do not summarize from memory.
2. Find whether an official codemod exists for this upgrade.
3. Inventory affected call sites with Grep over the changed API surface.

## Triage

Classify each breaking change: **mechanical** (a codemod handles it), **manual** (needs a
human decision per call site), **behavioral-risky** (compiles but changes runtime
behavior — the dangerous class). Order the work so the test suite can attribute any
failure to this upgrade alone.

## Fix policy

rule 5 applies hardest — this changes a dependency and many call sites. Present the plan
first: the single dependency, the version delta, the breaking items, the call-site list,
and the codemod command(s). On approval apply as **one isolated change** — no unrelated
bumps, no opportunistic edits — then run the test suite and report. Confirmation flow per
SKILL.md.

## Report

Dependency + version delta, breaking changes addressed (and how), call sites changed,
codemods applied, suite result, and the manual follow-up that still remains. If the suite
fails, say so with the output — do not present a half-done migration as complete.
