<!-- last_updated: 2026-03-19 -->
<!-- version: 1.0 -->
# Python Project Rules

This module extends `base.md` for repositories that contain Python code or Python project markers.

## 1. Testing and Tooling

- Use `pytest` as the test runner.
- Use `expects` for assertion style when the project already relies on BDD-style assertions.
- Use `doublex` and `doublex-expects` for application-code doubles and interaction assertions.
- Use `@patch` from `unittest.mock` only for Python system modules such as `sys`, `os`, `subprocess`, `readline`, and `atexit`.
- Prefer behavior-focused tests over interaction-heavy tests when both options are reasonable.

## 2. Python Typing

- Keep all functions, methods, and helpers fully typed.
- Type class attributes explicitly.
- Use `Optional[...]` only when `None` is a valid value.
- Prefer small, typed helpers over deeply nested logic.

## 3. Python Design

- Keep classes and functions small and focused.
- Prefer clear, descriptive names over abbreviated ones.
- Use OOP for Python components when the code models behavior or state that benefits from it.
- Prefer explicit control flow over clever abstractions.

## 4. Python Project Conventions

- Keep Python-specific package, testing, and typing guidance here instead of in `base.md`.
- Apply this module together with the universal rules in `base.md`.

