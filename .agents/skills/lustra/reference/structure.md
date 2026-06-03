# structure

**Purpose:** detect the stack, judge its structure against that stack's conventions, then
either advise or reorganize — the user's choice.

## Detect

Detect the stack (SKILL.md § Stack detection). Additionally note the build tool, test
runner, and module system, since structure is judged against *that* stack's conventions.

## Triage

Against the conventions of the *detected* stack (not a generic ideal), report:

- Layout that fights the framework's expected structure.
- Mixed concerns: business logic in routes/controllers, god modules, circular packages.
- Inconsistent naming/casing across the same layer.
- Missing or misplaced test, config, and entry-point locations for this stack.
- Folders that exist for no reason; files in the wrong layer.

Be concrete: name the file, the convention it violates, the expected location.

## Fix policy

Present both and let the user pick:

- **(a) Recommendations only** — the assessment above, ranked by payoff vs. churn, no
  changes made.
- **(b) Reorganize** — produce a staged plan: each step is one coherent move (relocate a
  layer, split a god module, rename for consistency) with the file moves and the import
  updates it forces. Execute **one step at a time, confirming each**, keeping every step
  independently reviewable. Never bulk-move the tree in one shot (rule 5). After each
  step, update imports your move broke and nothing else.

## Report

Detected stack, ranked assessment, then the chosen path's output.
