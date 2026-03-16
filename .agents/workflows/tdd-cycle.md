---
description: Red-Green-Refactor cycle for rigorous Test-Driven Development.
---

# TDD Cycle Workflow

## Protocol
Follow the Red-Green-Refactor cycle for every functional change.

### 1. RED (Failing Test)
-   **Step**: Write a SINGLE test case that targets the new functionality.
-   **Action**: Run the test using the appropriate `make` target (e.g., `make test-unit`).
-   **Verify**: Ensure the test fails *for the expected reason*.

### 2. GREEN (Passing Test)
-   **Step**: Write the *minimum* amount of code required to pass the test.
-   **Action**: Run the test again.
-   **Verify**: Ensure the test passes.

### 3. REFACTOR (Clean Code)
-   **Step**: Improve code structure, naming, and remove duplication.
-   **Constraint**: Functionality must remain unchanged.
-   **Action**: Run the test (and related tests) again to ensure no regressions.

## Rules
-   **Baby Steps**: One test at a time.
-   **No Cheating**: Do not write source code before the failing test.
-   **Validation**: Always run `make validate` before committing.
