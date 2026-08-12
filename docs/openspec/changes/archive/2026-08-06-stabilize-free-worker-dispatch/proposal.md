## Why

Codex can already invoke the verified free OpenCode worker through the
repository adapter, but recent failed attempts bypassed that constrained path.
The first recorded request contained 133 messages, 318 KB of request data, and
11 tools, then continued with repeated 80k-150k-token calls until the parent
turn timed out. The provider returned HTTP 200, so the failure was uncontrolled
context growth rather than free-model availability.

OmniRoute now advertises an active `free-deterministic` combo. A live semantic
probe on 2026-08-06 reached the combo but failed with `payment_required` at
pipeline step 3 (`longcat/LongCat-2.0`). Active catalog presence therefore does
not yet qualify the combo for worker routing.

## What Changes

- Retain `run-free-worker` as the single Codex-to-OpenCode dispatcher instead
  of adding a second wrapper.
- Move worker step, input-token, and timeout ceilings into the routing manifest
  so every task class has an explicit execution budget.
- Stop a worker after the first reported input-token budget breach and return a
  stable termination reason, preventing repeated oversized calls.
- Let edit contracts require at least one attributed change so an exhausted
  worker cannot turn a no-op explanation into a successful implementation.
- Reject contracts whose requested timeout exceeds the task-class policy.
- Document that active OmniRoute combos remain candidates until they pass
  semantic conformance; keep direct verified model pins as the production lane.

## Out of Scope

- Making OpenCode workers appear as native Codex subagents.
- Building another gateway, scheduler, or model router.
- Automatically retrying a failed or edited worker.
- Promoting `free-deterministic` before it returns a usable semantic completion.
- Preventing the cost of the first oversized provider call; the adapter can
  observe usage only after OpenCode emits the corresponding step event.
