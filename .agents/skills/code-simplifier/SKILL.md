---
name: code-simplifier
description: Simplifies and refines code for clarity, readability, and maintainability. Reduces complexity without changing behavior. Use when simplifying, cleaning up, or reducing complexity in code.
---

STARTER_CHARACTER = 🧹

When starting, announce: "🧹 Using CODE-SIMPLIFIER skill".

## Scope

Default scope: code modified in the current session or specified by the user.
Broader scope only when explicitly requested.

Read CLAUDE.md for project-specific coding standards before making changes.

## Process

1. Identify the code sections in scope
2. Analyze each section for simplification opportunities
3. Apply changes one at a time — run tests if available to verify behavior preservation
4. Summarize what changed and why

## Simplification Principles

Prioritize clarity over brevity.

- Reduce nesting depth — extract early returns, guard clauses
- Eliminate dead code, unreachable branches, unused variables
- Replace complex conditionals with named booleans or extracted functions
- Consolidate duplicated logic only when the duplication is real (same reason to change), not coincidental
- Remove comments that restate what the code already says
- Flatten callback chains or deeply nested structures
- Use domain language in names — describe what things ARE, not implementation details

## Over-Simplification Anti-Patterns

These make code worse, not better. Do not apply them:

- **Nested ternaries**: Use if/else or switch for multiple conditions
- **Dense one-liners**: A readable 3-line version beats a clever 1-line version
- **Premature abstraction**: Three similar lines are better than a generic helper used once
- **Merging unrelated concerns**: Two simple functions beat one "smart" function with flags
- **Stripping useful abstractions**: If an abstraction improves organization or testability, keep it
- **Compressing at the cost of debuggability**: Code that's hard to step through with a debugger is too compressed

## What NOT to Change

- Test code (unless imports/names must follow production renames)
- Public API signatures (unless explicitly requested)
- Behavior — the code must do exactly what it did before
- Code outside of scope
