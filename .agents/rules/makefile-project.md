<!-- last_updated: 2026-03-19 -->
<!-- version: 1.0 -->
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

## 3. Common Targets

- `make validate`
- `make test-unit`
- `make test-e2e`
- `make check-typing`
- `make check-format`
- `make check-style`
- `make reformat`

## 4. Makefile Conventions

- Keep automation in `Makefile` targets when the repository already uses `make` as the primary workflow.
- Keep the Makefile guidance here instead of in `base.md`.
- Apply this module together with the universal rules in `base.md`.
