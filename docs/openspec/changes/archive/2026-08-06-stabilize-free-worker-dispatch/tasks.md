## 1. Policy and RED Tests

- [x] 1.1 Add a behavior-level failing test for an OpenCode worker that emits an input-token count above the task-class budget and keeps running.
- [x] 1.2 Add manifest-validation coverage for required positive execution limits.
- [x] 1.3 Add a failing test for a contract timeout that exceeds the policy ceiling.
- [x] 1.4 Add a failing test proving an edit contract with `require_changes: true` rejects a no-op completion.

## 2. Dispatcher Hardening

- [x] 2.1 Declare `max_steps`, `max_input_tokens`, and `max_timeout_seconds` for `bounded_code`.
- [x] 2.2 Generate the ephemeral worker step cap from the routing policy.
- [x] 2.3 Stop live execution after a reported context-budget breach and return `termination_reason`.
- [x] 2.4 Enforce the policy timeout ceiling without adding retry or paid fallback.
- [x] 2.5 Reject a no-op completion when the contract requires attributed changes.

## 3. Documentation and Conformance

- [x] 3.1 Document the single-dispatcher path and context-budget behavior in the skill and user-facing routing guide.
- [x] 3.2 Record `free-deterministic` as active-but-unhealthy rather than absent or verified.
- [x] 3.3 Run focused tests, shell lint, manifest validation, OpenSpec validation, and the canonical repository check.
- [x] 3.4 Run bounded live smokes through the dispatcher and retain direct pins unless the combo passes independent semantic conformance.
