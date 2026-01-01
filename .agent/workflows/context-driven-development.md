---
description: Structured development cycle (Research -> Plan -> Implement -> Verify) adapted for Antigravity.
---

# Context-Driven Development Workflow

This workflow implements the Frequent Intentional Compaction (FIC) strategy, adapted for Antigravity's Agentic Mode.

## Core Principle
Maintain strict separation of concerns to preserve context quality. Use `task_boundary` to define phases and `implementation_plan.md` / `walkthrough.md` for persistence.

## Phase 1: Research (Mode: PLANNING)
**Goal**: Understand the current state.

1.  **Start Task**: Call `task_boundary` with `Mode: PLANNING`, `TaskName: Researching [Topic]`.
2.  **Explore**: Use `search_web`, `grep_search`, `view_file` to gather context.
3.  **Document**: Create or update `task.md` with findings.
    -   *Optional*: Create a research note in `thoughts/shared/research/` if deep architectural documentation is needed.

## Phase 2: Plan (Mode: PLANNING)
**Goal**: Design the change.

1.  **Update Task**: Call `task_boundary` with `Mode: PLANNING`, `TaskName: Planning [Topic]`.
2.  **Draft Plan**: Create `implementation_plan.md`.
    -   **Context**: What calls for this change?
    -   **Proposed Changes**: File-level breakdown.
    -   **Verification Plan**: How it will be tested.
3.  **Review**: logic check your plan. If complex, use `notify_user` to request approval.

## Phase 3: Implement (Mode: EXECUTION)
**Goal**: Execute the plan in baby steps.

1.  **Start Implementation**: Call `task_boundary` with `Mode: EXECUTION`, `TaskName: Implementing [Topic]`.
2.  **TDD Cycle**:
    -   Create a failing test.
    -   Run test (fail).
    -   Implement feature.
    -   Run test (pass).
    -   Refactor.
3.  **Update Progress**: Update `task.md` as items are completed.

## Phase 4: Verify (Mode: VERIFICATION)
**Goal**: Prove it works.

1.  **Start Verification**: Call `task_boundary` with `Mode: VERIFICATION`, `TaskName: Verifying [Topic]`.
2.  **Run Tests**: Execute full test suite `make validate`.
3.  **Create Walkthrough**: Create `walkthrough.md` documenting:
    -   What changed.
    -   Evidence of verification (screenshots, logs).
4.  **Finalize**: Call `notify_user` to inform the user of completion.
