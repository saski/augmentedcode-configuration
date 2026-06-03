# baseline

**Purpose:** the *start* command — establish the guardrail configs a project should have
had on day one, for the detected stack. The only generative command; treat it accordingly.

## Detect

1. Detect the stack as in `structure.md` (language, framework, build tool, test runner,
   package manager).
2. Inventory what already exists: linter, formatter, type-checker, test, CI, editorconfig,
   gitignore, license, lockfile. **Existing config is authoritative — never overwrite it.**
3. Identify only the *missing* guardrails for this stack.

## Triage

Propose the minimum standard set for the detected stack, nothing speculative
(CLAUDE.md §2): formatter + linter + type-checker config, a test setup if none, a CI
workflow that gates them, `.gitignore`, `.editorconfig`, `LICENSE` if absent. Do not
add tools the stack doesn't need or the team hasn't signaled wanting.

## Fix policy

This command writes new files, so it is the most destructive — rule 5 applies hardest:

- Present the full list of files to create with their proposed contents **first**.
- Create only what the user approves, one coherent group at a time (e.g. lint+format
  together), each independently reviewable.
- Never modify or "upgrade" an existing config as part of baseline — that is a separate,
  explicit decision. If an existing config is weak, *report* it, don't rewrite it.
- Match conventions the project already shows (indentation, module style).

## Report

Detected stack, what exists, what is missing, then the proposed file set for confirmation.
After applying, list exactly what was created.
