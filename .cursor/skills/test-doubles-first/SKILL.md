---
name: test-doubles-first
description: Select and implement the right test double with a default preference for fakes, stubs, and spies over mocks. Use when writing or refactoring tests, especially when users mention test doubles, mocking strategy, interaction assertions, or flaky tests caused by over-mocking.
---

# Test Doubles First

## Quick Navigation

- [Goal](#goal)
- [Default Rule](#default-rule)
- [Decision Tree](#decision-tree)
- [Naming and Placement](#naming-and-placement)
- [Style Constraints](#style-constraints)
- [What Can Be Doubled](#what-can-be-doubled)
- [Quick PR Smell Check](#quick-pr-smell-check)
- [Minimal Templates](#minimal-templates)

## Goal

Write tests that describe behavior and state, not implementation details. Avoid mock-by-default.

## Default Rule

1. Prefer state/output assertions first.
2. Choose the lightest double that makes the test clear.
3. Use mocks only when interaction contract is the behavior under test.

## Decision Tree

1. Can the test assert state (persisted data, returned value, emitted event)?
   - Yes -> use a `Fake` (in-memory or lightweight real implementation).
   - No -> continue.
2. Do you need to force a branch (success/failure/timeout) with controlled responses?
   - Yes -> use a `Stub`.
   - No -> continue.
3. Do you need to observe an outbound effect (email, message, metrics) without prescribing internal construction?
   - Yes -> use a `Spy`.
   - No -> continue.
4. Do you need to verify interaction contract (never called, called once, call order/protocol)?
   - Yes -> use a `Mock`, with minimal expectations.

If one test needs many interaction expectations, treat it as a design smell and raise the abstraction of the port.

## Naming and Placement

- Names
  - `FakeXxxRepo`, `InMemoryXxxRepo`
  - `StubXxxGateway`, `FailingXxxStub`, `FixedClockStub`
  - `SpyXxxPublisher`, `SpyEmailService`
  - `MockXxxClient` only for contract-driven tests
- Paths (cross-platform style)
  - Python: `tests/doubles/`
  - TypeScript: `test/doubles/` or `__tests__/doubles/`

Always use forward slashes in paths.

## Style Constraints

- Prefer state/output assertions over `called_with` assertions.
- For spies, assert only relevant facts (for example count, recipient, subject).
- Keep stubs configurable per scenario; do not build mini-systems.
- Keep fakes honest to domain invariants; add contract tests for real adapters when needed.

## What Can Be Doubled

- Usually yes: ports to I/O (database, network, queues), time/randomness, email, logs, metrics.
- Usually no by default: value objects, entities, pure domain logic, internal mappers.

## Quick PR Smell Check

- Would renaming an internal method break the test without behavior change? If yes, likely over-mocked.
- More than 2-3 interaction expectations in one test? Prefer fake/spy or redesign the port.
- Could the fake diverge from the real adapter? Add a contract test.

## Minimal Templates

See [examples.md](examples.md) for Jest-based JavaScript and TypeScript templates for fake, stub, spy, and contract-focused mock.
See [usage.md](usage.md) for trigger prompts and copy-paste templates.
See [quick.md](quick.md) for single-page fast reference.
