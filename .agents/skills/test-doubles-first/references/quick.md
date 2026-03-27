# Test Doubles First - Quick Mode

One-page guide for fast test-double decisions and reviews.

## 1) Decision Tree (Default Flow)

1. Can I assert state/output directly?
   - Yes -> `Fake` (or lightweight real implementation)
2. Need to force branch outcomes (success/failure/timeout)?
   - Yes -> `Stub`
3. Need to observe outbound effects (email/event/metrics)?
   - Yes -> `Spy`
4. Need strict interaction contract (call count/order/protocol)?
   - Yes -> `Mock` (last resort)

Rule: if a test needs many interaction assertions, prefer raising port abstraction and switching to fake/spy.

## 2) Quick Chooser by Dependency

| Dependency | Preferred Double | Example Name |
| --- | --- | --- |
| Repository/persistence | Fake | `FakeOrderRepo`, `InMemoryUserRepo` |
| External API/gateway | Stub | `StubPaymentGateway`, `FailingGatewayStub` |
| Email/publisher/notifier | Spy | `SpyEmailService`, `SpyEventPublisher` |
| Clock/time source | Stub | `FixedClockStub` |
| Randomness/ID generator | Stub | `DeterministicIdStub` |
| Logger/metrics | Spy | `SpyLogger`, `SpyMetrics` |
| Strict protocol contract | Mock (last resort) | `MockQueueClient` |

## 3) Anti-Pattern -> Replacement

| Anti-Pattern | Replacement |
| --- | --- |
| 3+ interaction assertions in one test | Use `Spy` + assert essential payload/state |
| Mocked repository for save/load behavior | Use `Fake` repo + assert resulting state |
| Stub with complex branching | Keep stub scenario-driven only |
| Mocking pure domain objects | Use real domain objects |
| Call-order assertions without business need | Assert state/effect instead |
| Asserting every outbound field | Assert contract-critical fields only |

## 4) PR Review Templates (Copy/Paste)

### Over-mocking

```text
This test is interaction-heavy and may be brittle under harmless refactors.
Can we replace some mocks with a Fake/Spy and assert behavior/state instead?
```

### Repository replacement

```text
Can we replace this mocked repository with an InMemory/Fake repo and assert resulting state directly?
```

### Excessive interaction checks

```text
There are many called-with assertions here.
Can we keep only contract-critical checks and assert the main outcome through state/output?
```

### Stub simplification

```text
This stub looks too complex. Could we make it scenario-driven (success/failure/timeout) only?
```

### Contract alignment

```text
This fake might diverge from the real adapter. Please add/refresh adapter contract tests.
```

## 5) Prompt Starters

- "Use test-doubles-first quick mode for this test."
- "Pick the lightest test double for each dependency."
- "Refactor this test to reduce over-mocking."
