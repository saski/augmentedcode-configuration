## ADDED Requirements

### Requirement: Policy-owned worker budgets

Every free-worker task class SHALL declare positive maximum steps, cumulative
input tokens, and wall-clock timeout values. The dispatcher SHALL reject a
contract whose requested timeout exceeds the class policy.

#### Scenario: Dispatch a bounded-code worker

- **GIVEN** a valid bounded-code contract using a verified free model
- **WHEN** the frontier invokes the dispatcher
- **THEN** the OpenCode worker step cap SHALL come from the task-class policy
- **AND** the requested timeout SHALL NOT exceed the policy ceiling

### Requirement: Context budget termination

The dispatcher SHALL monitor input usage reported by OpenCode and SHALL stop a
worker after the cumulative task-class budget is exceeded. It SHALL return a
structured failed result with a stable termination reason and SHALL NOT retry
another free or paid model automatically.

#### Scenario: Worker exceeds the input-token budget

- **GIVEN** a free worker emits a step whose cumulative input usage exceeds the configured ceiling
- **AND** the OpenCode process remains active
- **WHEN** the dispatcher observes the usage event
- **THEN** it SHALL stop the process before another iteration
- **AND** it SHALL return `termination_reason: context_budget_exceeded`
- **AND** it SHALL report the observed usage

### Requirement: Combo semantic admission

An OmniRoute combo SHALL NOT be promoted merely because it is active or listed
in the model catalog. It SHALL return non-empty semantic output without billing,
transport, or member-step failure before it can enter a verified task class.

#### Scenario: Active combo has an unhealthy member

- **GIVEN** OmniRoute lists an active free-only combo
- **WHEN** a minimal semantic probe fails in one pipeline step
- **THEN** the route SHALL remain a candidate rather than a verified worker model
- **AND** production dispatch SHALL retain a verified direct pin

### Requirement: Required edit postcondition

An edit contract MAY require at least one newly attributed changed file. When
that postcondition is present, non-empty explanatory text without a change
SHALL be a structured failure rather than a successful implementation.

#### Scenario: Worker exhausts its steps without editing

- **GIVEN** a valid worker contract sets `require_changes: true`
- **WHEN** OpenCode returns non-empty final text but changes no attributed file
- **THEN** the dispatcher SHALL return a failed result
- **AND** `termination_reason` SHALL be `required_changes_missing`
