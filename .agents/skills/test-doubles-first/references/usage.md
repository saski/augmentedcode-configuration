# Usage Cheatsheet

Use these prompts to trigger `test-doubles-first` while writing tests.

For a compact reference, use [quick.md](quick.md).
It includes the decision tree, dependency chooser, and anti-pattern replacement table.

## Direct Trigger Prompts

- "Use the test-doubles-first skill for this test."
- "Help me choose a fake/stub/spy instead of a mock."
- "Apply a test-double decision tree for this test."
- "Refactor this test to avoid over-mocking."
- "Pick the lightest test double for this scenario."

## Scenario-Based Prompts

- "I need to force payment failure in a unit test; what double should I use?"
- "I need to assert one email was sent with the right recipient and subject."
- "I want a repository double that lets me assert persisted state."
- "This test has too many `toHaveBeenCalledWith` assertions, simplify it."
- "Review these tests for interaction-heavy mocking smells."

## Prompt Templates

### Template 1: New Test

```text
Use test-doubles-first.
Context:
- Unit under test: <class/function>
- Dependencies/ports: <list>
- Behavior to verify: <outcome>
Please choose the right test double per dependency and explain why in one line each.
```

### Template 2: Refactor Existing Test

```text
Apply test-doubles-first to this test.
Goal:
- Replace unnecessary mocks with fakes/stubs/spies
- Keep assertions behavior-focused
Return:
1) issues found
2) proposed double replacements
3) minimal patch
```

### Template 3: PR Review

```text
Review this test file with test-doubles-first.
Check:
- over-mocking
- excessive interaction assertions
- fake honesty vs real adapter
Return findings ordered by severity.
```

## PR Review Comment Templates

Use these as quick, actionable review comments.

### Over-mocking

```text
This test looks interaction-heavy (multiple mock expectations) and may be brittle under harmless refactors.
Can we switch this dependency to a Fake/Spy and assert behavior/state instead?
```

### Repository mocked by default

```text
Could we replace this mocked repository with an InMemory/Fake repo?
That would let us assert resulting state directly and reduce coupling to internals.
```

### Excessive call assertions

```text
There are several `called_with`/`toHaveBeenCalledWith` checks here.
Can we keep only contract-critical checks and assert the main outcome through state/output?
```

### Stub too complex

```text
The stub seems to contain branching logic that mirrors production behavior.
Can we simplify it to scenario-driven configuration (success/failure/timeout) only?
```

### Spy recommendation for outbound effects

```text
This seems like an outbound-effect assertion (email/message/event).
A Spy could be a better fit here: capture sent payload and assert only relevant fields.
```

### Call order not business-critical

```text
Do we need strict call-order assertions for this scenario?
If order is not part of the business contract, state/effect assertions should be more stable.
```

### Fake honesty / contract tests

```text
This fake may drift from the real adapter behavior over time.
Please consider adding/refreshing adapter contract tests to keep both aligned.
```

### Positive reinforcement

```text
Great use of a Fake/Spy here.
The test is behavior-focused and resilient to internal refactors.
```
