# design

**Purpose:** the logical design quality of a module or package — not a diff (`review`),
not file/folder layout (`structure`). Paradigm-aware: SOLID framing for OO codebases;
cohesion/coupling/composition framing for Go, Rust, and functional ones.

## Detect

Detect the stack (SKILL.md § Stack detection) and pick the lens:

- **OO (Java/C#/TS classes/Python classes):** single responsibility, open/closed, Liskov
  substitutability, interface segregation, dependency inversion.
- **Non-OO (Go/Rust/functional/procedural):** module cohesion, afferent/efferent
  coupling, composition over inheritance, dependency *direction* (do stable modules depend
  on volatile ones?), package boundaries and what leaks across them.

Read the target's public surface, its dependency graph, and the size/shape of its units.
Flag, with the symbol named: god objects/functions, leaky or one-caller abstractions,
import cycles, inverted dependency direction, an interface no caller needs in full,
shared mutable state across boundaries.

## Triage

Rank by `blast radius × how entrenched it is`. Three buckets: **blocking** (architectural
rot that will compound), **should-fix** (real but contained), **optional** (defensible
taste — keep few). Name the principle, not a vibe; if the design is sound, say so plainly
rather than inventing findings.

## Fix policy

- Auto: nothing — design changes are structural and semantic.
- Propose (diff + ask): the specific refactor and the principle it restores, one change
  per finding, never a sweeping rewrite. Confirmation flow per SKILL.md.

## Report

Findings ranked by bucket, each: `target` — principle violated — why it bites — proposed
refactor. State the lens used (SOLID vs. cohesion/coupling) and why.
