<!-- last_updated: 2026-08-12 -->
<!-- version: 1.1 -->
# Makefile Project Rules

This module extends `base.md` for repositories that use a `Makefile` as the canonical automation entry point.

## 1. Make Targets

- Prefer `make` targets over calling tools directly.
- Use the repository's documented targets for testing, formatting, type checking, building, and validation.
- Add a new `make` target before introducing a direct tool invocation into agent workflows.

## 2. Validation

- Run the repository's canonical validation target before any commit.
- Treat validation failures as blocking until fixed and re-run.
- Use the narrowest relevant `make` target while iterating, then finish with the full validation target.

## 3. Target Discovery

- Read the repository's `Makefile` and development documentation before naming a target.
- Do not assume generic target names such as `validate`, `test-unit`, or `check-format` exist.
- When documentation and the `Makefile` disagree, treat the executable `Makefile` as current and report the stale documentation.

## 4. Makefile Conventions

- Keep automation in `Makefile` targets when the repository already uses `make` as the primary workflow.
- Keep the Makefile guidance here instead of in `base.md`.
- Apply this module together with the universal rules in `base.md`.
