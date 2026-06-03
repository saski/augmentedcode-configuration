# analyze

**Purpose:** the linter / static analyzer's findings, plus the slop a linter structurally
cannot see.

## Detect

Detect the stack (SKILL.md § Stack detection), then run its linter scoped to the target:

| Stack | Linter |
| --- | --- |
| JS/TS | `npx -y eslint . --format json` |
| Python | `ruff check --output-format json` (or `flake8`/`pylint`) |
| Go | `go vet ./...` and `staticcheck ./...` if present |
| Rust | `cargo clippy --message-format json` |

1. If a linter config exists for the stack, use it.
2. If none exists, do **not** silently add one. Run with the tool's recommended config,
   say the result is advisory, and offer to add a real config as a separate confirmed step.
3. Read the target for AI-slop smells no rule catches:
   - Abstractions with exactly one caller; indirection that only forwards.
   - `try/catch` that logs and rethrows, swallows, or re-wraps with no added meaning.
   - Comments that restate the code, section-header comments, `added for X` notes,
     leftover TODOs.
   - Defensive checks for conditions the type system or call sites make impossible.
   - Dead config keys and options wired to nothing.

## Triage

Linter errors before warnings. For slop smells, only raise ones you can justify concretely
— name the caller count, the impossible condition, the comment that adds nothing. Skip
stylistic preferences the repo's own config does not enforce.

## Fix policy

- Present the autofixable set as a checklist (rule + `file:line` per item). On approval,
  run the linter's autofix scoped to the approved files, then re-run to confirm zero
  regressions. Confirmation flow per SKILL.md.
- Propose (diff + ask): every slop-smell change — these are semantic. Match existing
  style; do not reformat untouched lines.

## Report

Two sections: linter (counts + remaining manual items) and slop smells (`file:line`,
the smell, the concrete justification, the proposed change).
