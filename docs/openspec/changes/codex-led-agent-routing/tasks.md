## 1. Routing Policy and Contracts

- [x] 1.1 Add a behavior-level test that describes a Codex principal delegating one bounded OpenSpec task to a free worker and receiving a structured result.
- [ ] 1.2 Add a small, secret-free routing manifest under `.agents/` with frontier roles, free-worker task classes, privacy rules, and the initially verified model identifiers.
- [ ] 1.3 Add schema validation that rejects missing task policies, paid models in the free pool, unverified defaults, and secret-like values.
- [ ] 1.4 Define the shared `frontier` and `free` entry contract, including `entry` versus `worker` roles and a loop guard.
- [ ] 1.5 Document the account boundary: Codex App/CLI uses ChatGPT OAuth; Hermes-managed OAuth is separate and optional; OmniRoute never receives either credential.

## 2. Free-Worker Adapter

- [ ] 2.1 Add failing adapter tests for a successful structured OpenCode result, provider error, unsupported model, empty HTTP 200 completion, missing final result, timeout, and out-of-scope file change.
- [x] 2.2 Implement the smallest adapter that invokes `opencode run` in one-shot JSON mode with an explicit OmniRoute model and working directory.
- [x] 2.3 Return a stable result containing model, status, summary, changed files, validation command and outcome, token usage when available, and diagnostic details on failure.
- [ ] 2.4 Enforce the no-auto-approval, context-minimization, and one-writer-per-worktree policies.
- [x] 2.5 Prove the adapter does not retry a paid model or an unlisted free model.

## 3. Shared Agent Workflow

- [x] 3.1 Create a `free-agent-execution` shared skill that teaches Codex and other frontier agents how to classify tasks, prepare the OpenSpec handoff, invoke the adapter, and review the result.
- [ ] 3.2 Add entry instructions that let Hermes, OpenCode, Codex App/CLI, and Cursor select `frontier` or explicit `free` mode without adding another LLM router.
- [x] 3.3 Register the skill in `.agents/docs/skill-factory-skills.md`, `.agents/docs/skill-domain-routing.md`, the engineering governance catalog, `README.md`, `PROJECT_STATUS.md`, and the applicable provenance lock.
- [ ] 3.4 Update the universal rules with only the smallest routing pointer needed to make compatible clients discover the skill; keep model catalogs and operational detail out of always-loaded rules.
- [x] 3.5 Run `./validate-skill-library.sh` after the shared skill inventory changes.

## 4. Managed Client Configuration

- [ ] 4.1 Add an OpenCode template that defines OmniRoute as a local OpenAI-compatible provider and exposes only the verified free worker models.
- [ ] 4.2 Add a Hermes template/profile for Telegram and local sessions that supports Codex app-server `frontier` turns plus an explicit verified `free` route, with no broad `auto/*` default.
- [ ] 4.3 Add Codex and Cursor entry instructions that invoke the same shared contract from the App/CLI and IDE without requiring a new background service.
- [ ] 4.4 Extend `setup-symlinks.sh` with idempotent, non-destructive installation and validation of the managed entry fields.
- [ ] 4.5 Add contract tests proving setup preserves existing credentials and unrelated user configuration.
- [ ] 4.6 Keep GPT-5.6 and all other paid frontier models out of the OmniRoute worker pool; frontier access remains direct through Codex.

## 5. OmniRoute Conformance

- [ ] 5.1 Add a smoke-test command that obtains OmniRoute's live catalog without printing credentials and checks each candidate against the routing manifest.
- [ ] 5.2 Verify `oc/deepseek-v4-flash-free` and `oc/big-pickle` through the adapter and record their verification date and supported task classes.
- [ ] 5.3 Add a regression fixture proving a zero-token or null-content HTTP 200 response is rejected as a failed worker run.
- [ ] 5.4 Test current additional OpenCode Zen free candidates individually; promote only models that pass the full response, tool-use, structured-result, and bounded-edit checks.
- [ ] 5.5 Document manual removal or quarantine when a previously verified model becomes unsupported or semantically unhealthy.

## 6. End-to-End Acceptance

- [ ] 6.1 From a Codex `gpt-5.6-sol` session, create or select a bounded OpenSpec task and execute it through the free-worker adapter.
- [ ] 6.2 Confirm the worker changes only allowed files, runs the declared validation, and returns a structured handoff.
- [ ] 6.3 Have Codex review the diff and validation evidence before marking the OpenSpec task complete.
- [ ] 6.4 Confirm an unavailable or empty free route fails visibly and does not trigger paid fallback.
- [ ] 6.5 Confirm Telegram/Hermes can start a Codex app-server frontier turn using the Codex CLI OAuth session.
- [ ] 6.6 Confirm Hermes and OpenCode can each complete an explicit one-shot free request without participating in frontier orchestration.
- [ ] 6.7 Confirm Codex App/CLI and Cursor can initiate the shared contract and that OpenCode entry-to-worker recursion is rejected.
- [ ] 6.8 Run `openspec validate --all`, `./setup-symlinks.sh validate`, and the repository's canonical `make check`.

## 7. Deferred Health-Gated Pools

- [ ] 7.1 Measure free-worker success, unsupported-model churn, prompt overhead, and manual refresh frequency during the explicit-pin phase.
- [ ] 7.2 Add OmniRoute task-class pools only if pinned-model availability failures exceed 20% or manual catalog maintenance is required more than once per week.
- [ ] 7.3 Before enabling a pool, prove OmniRoute or the adapter treats semantically empty HTTP 200 responses as failures and records every attempted free model.
- [ ] 7.4 Keep custom gateways, automatic paid fallback, recursive delegation, and automatic entry classification out of scope unless measured constraints justify a separate OpenSpec change.
