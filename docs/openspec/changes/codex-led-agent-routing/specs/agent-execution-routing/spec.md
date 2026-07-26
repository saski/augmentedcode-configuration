## ADDED Requirements

### Requirement: Frontier control plane

The system SHALL use Codex, authenticated directly to the user's ChatGPT account, as the single frontier control plane per orchestrated run for planning, OpenSpec-driven development, orchestration, integration, and final acceptance. The default principal SHALL be a frontier Codex model suitable for ambiguous multi-step work.

#### Scenario: Start a new development change

- **GIVEN** a user requests a multi-step feature, refactor, migration, or bug fix from Hermes, OpenCode, Codex App/CLI, or Cursor
- **WHEN** the principal establishes the implementation contract
- **THEN** Codex creates or updates the relevant OpenSpec artifacts before delegating bounded execution
- **AND** OpenCode, Hermes, and OmniRoute do not reinterpret the product goal

#### Scenario: Use the existing OpenAI account

- **GIVEN** Codex is authenticated with the user's OpenAI account
- **WHEN** frontier planning or review is required
- **THEN** the system uses Codex directly
- **AND** it does not route the frontier request through OpenCode, Hermes, or OmniRoute

### Requirement: Multiple user entry surfaces

The system SHALL allow Hermes, OpenCode, Codex App/CLI, and Cursor to initiate work through the same logical entry contract without making every client an orchestration owner.

#### Scenario: Start a frontier run from any supported client

- **GIVEN** a user is working in Hermes, OpenCode, Codex App/CLI, or Cursor
- **WHEN** the user selects `frontier` mode
- **THEN** the parent request SHALL start or continue a Codex-controlled run
- **AND** the originating client SHALL remain an entry and presentation surface

#### Scenario: Run an explicit free task

- **GIVEN** a user selects `free` mode for a bounded, non-sensitive, verifiable task
- **WHEN** the entry contract accepts the request
- **THEN** it SHALL invoke the free-worker adapter without creating a frontier orchestration tree
- **AND** it SHALL return the structured result to the originating client

#### Scenario: Avoid automatic edge routing

- **GIVEN** the initial implementation is active
- **WHEN** a request enters through Hermes, OpenCode, or Cursor
- **THEN** the entry client SHALL NOT use an LLM to infer `frontier` versus `free`
- **AND** a `frontier` Codex principal MAY delegate eligible subtasks after it owns the run

### Requirement: Explicit task classification

The Codex principal SHALL classify each subtask by ambiguity, sensitivity, blast radius, and verifiability before selecting an execution lane.

#### Scenario: Delegate a bounded implementation task

- **GIVEN** a task has an explicit file scope, requirement, acceptance scenario, and verification command
- **AND** the task contains no sensitive data
- **WHEN** the principal selects an execution lane
- **THEN** the task MAY be delegated to a verified free worker

#### Scenario: Retain high-risk work on the frontier lane

- **GIVEN** a task involves credentials, personal data, security decisions, destructive operations, architectural ambiguity, or cross-cutting integration
- **WHEN** the principal selects an execution lane
- **THEN** the task SHALL remain on Codex
- **AND** any delegated agents SHALL be native frontier Codex agents

### Requirement: One orchestration owner

The system SHALL allow only Codex to decompose the parent task, spawn or invoke workers, select the next task, and accept completion.

#### Scenario: Run a free worker

- **GIVEN** Codex delegates one bounded task to a free worker
- **WHEN** OpenCode executes the task
- **THEN** OpenCode SHALL run as a one-shot worker
- **AND** the worker SHALL NOT spawn a nested agent tree
- **AND** Hermes delegation SHALL NOT participate in the execution

### Requirement: Stable free-worker adapter

The repository SHALL provide one documented adapter that invokes OpenCode against the local OmniRoute endpoint and returns a stable structured result to Codex.

#### Scenario: Invoke a free worker

- **GIVEN** a verified free model and a bounded task contract
- **WHEN** Codex invokes the adapter
- **THEN** the adapter runs OpenCode in one-shot structured-output mode
- **AND** passes only the required working directory, task context, allowed scope, and validation contract
- **AND** records the selected model, outcome, changed files, validation status, and usage when available

#### Scenario: Reject unsafe command modes

- **GIVEN** a free worker invocation
- **WHEN** the adapter constructs the OpenCode command
- **THEN** it SHALL NOT enable global automatic approval or sandbox bypass flags

### Requirement: Verified free-model allowlist

The system SHALL route worker requests only to free models that have passed the repository's conformance checks.

#### Scenario: Admit a model

- **GIVEN** OmniRoute advertises a candidate free model
- **WHEN** the model completes the required non-streaming or streaming response, tool-use, structured-result, and bounded edit checks
- **THEN** the model MAY be added to the checked-in allowlist
- **AND** its verification date and supported task classes SHALL be recorded

#### Scenario: Encounter an advertised but unverified model

- **GIVEN** OmniRoute advertises a model that is absent from the verified allowlist
- **WHEN** an agent task is routed
- **THEN** the model SHALL NOT be selected

### Requirement: Free-only OmniRoute boundary

The agent execution route SHALL contain only verified free models and SHALL never silently escalate to a paid provider.

#### Scenario: Exhaust the free route

- **GIVEN** every eligible free model fails or is unavailable
- **WHEN** the route cannot complete the task
- **THEN** the system SHALL return a visible failure to Codex
- **AND** SHALL NOT invoke a paid model without a new explicit decision

#### Scenario: Protect upstream credentials

- **GIVEN** a free worker calls the local OmniRoute endpoint
- **WHEN** credentials are attached
- **THEN** the client SHALL use only a dedicated local OmniRoute client credential or non-secret placeholder as required by local policy
- **AND** SHALL NOT forward an OpenAI or paid OpenCode Zen upstream credential

### Requirement: Semantic completion validation

The system SHALL validate the semantic content and declared verification of a worker result rather than relying only on HTTP status or process exit code.

#### Scenario: Empty HTTP 200 response

- **GIVEN** an upstream returns HTTP 200 with empty or null assistant content, zero useful output tokens, or no usable final result
- **WHEN** the adapter evaluates the run
- **THEN** the run SHALL be classified as failed
- **AND** the task SHALL remain incomplete

#### Scenario: Successful worker result

- **GIVEN** a worker returns non-empty final content and the required completion fields
- **WHEN** the adapter validates the result
- **THEN** it SHALL report the declared changed files and validation outcome to Codex
- **AND** Codex SHALL perform final review before accepting the task

### Requirement: Controlled fallback

The initial implementation SHALL use explicit model pins. Any later automatic fallback SHALL be free-only, retry-safe, and owned by one routing policy.

#### Scenario: Initial pinned model failure

- **GIVEN** the initial release invokes a pinned free model
- **WHEN** that model fails
- **THEN** the failure SHALL return to Codex without an automatic provider cascade

#### Scenario: Future free-only fallback

- **GIVEN** a task class has an explicitly ordered list of verified free models
- **AND** semantic health detection has been validated
- **WHEN** a retry-safe failure occurs
- **THEN** the routing policy MAY try the next free model
- **AND** SHALL record every attempt

### Requirement: Safe write coordination

The system SHALL prevent multiple workers from writing concurrently to the same worktree.

#### Scenario: Parallel read-only exploration

- **GIVEN** multiple delegated tasks are read-only
- **WHEN** Codex runs them concurrently
- **THEN** they MAY share a working tree

#### Scenario: Multiple writing tasks

- **GIVEN** multiple delegated tasks can change files
- **WHEN** Codex schedules them
- **THEN** it SHALL run them sequentially in one worktree or place them in separate explicit worktrees

### Requirement: Minimal context and privacy

The system SHALL minimize the information sent to free models and SHALL deny free execution for sensitive tasks by default.

#### Scenario: Sensitive task

- **GIVEN** a task or required context contains credentials, personal data, private customer data, proprietary secrets, or security-sensitive material
- **WHEN** routing is evaluated
- **THEN** the task SHALL stay on the frontier Codex lane

#### Scenario: Non-sensitive bounded task

- **GIVEN** a task is eligible for free execution
- **WHEN** the handoff is created
- **THEN** it SHALL include only the relevant requirement, files, constraints, and verification contract
- **AND** SHALL exclude the parent transcript, environment secrets, and unrelated repository content

### Requirement: Hermes remote access

Hermes SHALL support Telegram, CLI, and TUI as entry surfaces for both Codex app-server frontier turns and explicit verified free-model requests.

#### Scenario: Enter Codex through Telegram

- **GIVEN** the supervised Hermes Telegram gateway is connected
- **AND** Codex CLI is authenticated through ChatGPT OAuth
- **WHEN** the user starts a `frontier` turn
- **THEN** Hermes SHALL hand the turn to the Codex app-server runtime
- **AND** Codex SHALL own model execution, tools, sandboxing, and orchestration

#### Scenario: Use Hermes for an explicit free task

- **GIVEN** a user chooses Hermes for an ad hoc non-sensitive task
- **WHEN** the user selects `free` mode
- **THEN** Hermes SHALL select an explicit verified free model or verified free-only route
- **AND** SHALL NOT default to an uncontrolled broad `auto/*` route

#### Scenario: OmniRoute or Hermes is unavailable

- **GIVEN** Hermes or OmniRoute is unavailable
- **WHEN** frontier planning, review, or critical implementation is required
- **THEN** Codex SHALL remain usable without that optional path

### Requirement: Separated OAuth ownership

The system SHALL keep ChatGPT/Codex OAuth credentials in the runtime-specific stores that consume them and SHALL NOT copy or centralize them in OmniRoute.

#### Scenario: Use Hermes Codex app-server runtime

- **GIVEN** Codex CLI reports an active ChatGPT OAuth session
- **WHEN** Hermes hands a turn to Codex app-server
- **THEN** the Codex subprocess SHALL use the Codex CLI credential store
- **AND** OmniRoute SHALL NOT receive the credential

#### Scenario: Authenticate Hermes' native Codex provider

- **GIVEN** the user enables Hermes-native `openai-codex` behavior
- **WHEN** Hermes OAuth is configured
- **THEN** Hermes SHALL store and refresh its own OAuth session separately
- **AND** SHALL NOT copy the Codex CLI token store

#### Scenario: Use OmniRoute free providers

- **GIVEN** OmniRoute routes a verified free worker request
- **WHEN** it authenticates an upstream provider
- **THEN** it SHALL use only the credential required for that free provider
- **AND** SHALL NOT contain ChatGPT/Codex OAuth or paid OpenAI API credentials

### Requirement: Secret-free managed configuration

The repository SHALL version only non-secret routing policy, templates, adapters, and tests. Mutable credentials and provider health SHALL remain in local runtime state.

#### Scenario: Install managed configuration

- **GIVEN** an existing local Codex, OpenCode, Hermes, or OmniRoute setup
- **WHEN** repository setup is applied
- **THEN** it SHALL preserve credentials and unrelated user configuration
- **AND** SHALL install or validate only the managed non-secret fields

#### Scenario: Validate the repository

- **GIVEN** a routing configuration change
- **WHEN** canonical repository checks run
- **THEN** they SHALL reject paid models in the free pool, missing required policy fields, stale unverified defaults, and secret-like committed values
