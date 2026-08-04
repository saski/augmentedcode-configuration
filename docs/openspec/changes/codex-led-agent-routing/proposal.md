## Why

The current local agent stack gives Hermes and OmniRoute overlapping orchestration and fallback responsibilities, exposes stale OpenCode model identifiers, and routes the default Hermes request through `auto/best-coding`, which can accept an empty HTTP 200 response as success. It also assumes that the user enters the workflow through Codex, while the desired operating model must support Hermes (including Telegram), OpenCode, Codex App/CLI, and Cursor as entry surfaces. This makes failures difficult to diagnose and prevents reliable use of free workers without unnecessarily constraining the user interface.

The OpenAI account already provides direct access to frontier Codex agents, so routing paid OpenAI models through OpenCode or OmniRoute adds protocol, credential, and health-state failure modes without adding useful capability. The missing capability is a controlled handoff from a frontier Codex orchestrator to bounded, non-sensitive execution tasks on verified free models.

## What Changes

- Allow Hermes, OpenCode, Codex App/CLI, and Cursor to initiate work through a shared entry contract with explicit `frontier` and `free` modes.
- Make Codex, authenticated directly with the user's OpenAI account, the single frontier control plane per orchestrated run for planning, OpenSpec-driven development, orchestration, integration, and final review.
- Use `gpt-5.6-sol` as the default principal for ambiguous or high-impact work, with native Codex subagents available for frontier-quality exploration and review.
- Add a repository-managed free-worker execution adapter that lets Codex invoke OpenCode in one-shot mode against the local OmniRoute endpoint.
- Restrict OmniRoute's agent workload to a health-checked allowlist of free models and explicit task-class routes. The initial release pins individually verified models instead of using broad `auto/*` routes.
- Keep OpenCode as both a user entry surface and the free-worker runtime. A frontier request entered through OpenCode hands off to Codex; a direct free request is explicit, bounded, and non-orchestrating.
- Make Hermes the recommended remote entry surface through Telegram. Frontier turns use the Codex app-server runtime; optional native Hermes OAuth and explicit free-only requests remain separate modes.
- Let Cursor initiate the same frontier or explicit free contracts from its IDE agent or terminal without making Cursor another orchestration owner.
- Keep OpenAI/Codex OAuth at the runtime that consumes it: Codex CLI/App OAuth for Codex app-server turns and optional Hermes-managed OAuth for Hermes' native `openai-codex` provider. OmniRoute will not store or proxy either credential.
- Postpone automatic semantic routing at the entry clients. The user selects `frontier` or `free`; after a frontier request starts, Codex alone decides whether to delegate bounded work.
- Add structured handoff, semantic-success, privacy, concurrency, and no-silent-paid-fallback policies.
- Add smoke tests and configuration validation so stale, empty, paid, or unsupported routes cannot be promoted into the free-worker pool.

## Implementation Status

The first free-worker slice is implemented: the repository contains a documented one-shot OpenCode adapter, an explicit allowlist containing the two verified `omniroute/oc/*` identifiers, and behavior-level tests for a bounded frontier-to-worker handoff. A live smoke run has also completed through OpenCode and local OmniRoute.

The verified model identifiers are `omniroute/oc/deepseek-v4-flash-free` and `omniroute/oc/big-pickle`. Six `omniroute/opencode-zen/*` candidates were found in the live catalog and exercised individually on 2026-07-30; all failed with OpenCode status 1 and no usable completion. They are quarantined, not admitted. A future catalog change requires a new conformance run before any candidate is promoted.

The repository now provides a portable OpenCode free-entry template and a
preservation-aware managed installer. The template exposes only the two
verified OmniRoute models and mirrors the constrained worker policy. The
installer atomically adds missing managed fields while preserving unrelated
configuration and never reading or writing OpenCode credentials; incompatible
local fields fail visibly without modification.

The adapter treats non-empty final worker text as semantic completion, while preferring the structured `FREE_AGENT_RESULT` summary when supplied. It still requires a successful OpenCode process, allowed newly changed paths, and passing declared validation. It now consumes a secret-free declarative routing manifest; process timeout enforcement is the next hardening slice.

The local Telegram entry has now completed a verified operational slice: the default ingress routes the configured chat to the `coding` profile; `/new` starts a Codex app-server frontier session; and an explicit session-only switch to `oc/deepseek-v4-flash-free` through the named `omniroute-local` custom provider returned a non-empty completion. The operation is documented separately because the profile files, bot credentials, and local Hermes patch are mutable machine state rather than repository-managed templates.

## Capabilities

### New Capabilities

- `agent-execution-routing`: Codex-led planning and orchestration with controlled delegation to OpenCode workers through a verified OmniRoute free-model pool.

### Modified Capabilities

None.

## Impact

- New shared entry/routing policy and free-worker adapter under `.agents/`.
- New or updated managed templates for Codex, OpenCode, Hermes, and Cursor configuration.
- `setup-symlinks.sh` and repository checks will gain idempotent installation and validation for the new local configuration surfaces.
- The shared skill inventory and governance catalog will be updated if the implementation introduces a `free-agent-execution` skill.
- OmniRoute remains a separately running local service at `http://localhost:20128/v1`; no ChatGPT/Codex OAuth or paid OpenAI credential will be stored in or forwarded through it.
- The existing Codex CLI session, currently authenticated through ChatGPT OAuth, remains the credential source for Codex App/CLI and Hermes Codex app-server turns.
- Hermes-managed `openai-codex` OAuth remains optional and isolated in Hermes' credential store; it is not shared with the Codex CLI session.
- Existing local credentials remain outside the repository. Configuration artifacts will contain environment-variable references or non-secret local placeholders only.
- The first implementation slice uses the already verified OpenCode provider-qualified model identifiers `omniroute/oc/deepseek-v4-flash-free` and `omniroute/oc/big-pickle`. Other free models require conformance testing before they are promoted from provisional admission (manifest acceptance + `validate-routing-manifest` exit 0) to fully verified status (§5.4).
