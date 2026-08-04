# free-worker-execution Specification

## Purpose
TBD - created by archiving change minimize-free-worker-context. Update Purpose after archive.
## Requirements
### Requirement: Minimal bounded-worker context

The free-worker adapter SHALL invoke OpenCode with an ephemeral agent that has
a concise worker prompt, a maximum of three steps, and only `read` and `edit`
enabled. It SHALL disable shell, web, delegation, discovery, interactive, and
skill tools.

#### Scenario: Bounded worker configuration

- **GIVEN** a valid non-sensitive bounded-code worker contract
- **WHEN** the adapter invokes OpenCode
- **THEN** it SHALL select the constrained ephemeral worker configuration
- **AND** it SHALL retain post-execution allowed-file and validation checks

### Requirement: Context-efficiency evidence

The project SHALL record the input-token usage of an equivalent live smoke
before deciding whether to impose a budget or introduce a direct-completion
worker class.

#### Scenario: Equivalent smoke comparison

- **GIVEN** a baseline and a minimal-worker one-file smoke with the same model
- **WHEN** both executions return usage data
- **THEN** their input-token counts SHALL be recorded as decision evidence

