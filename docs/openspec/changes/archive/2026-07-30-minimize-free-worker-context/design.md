## Decision

The adapter will keep OpenCode for bounded edits but configure an ephemeral
minimal agent. It keeps `read` and `edit` because the worker must understand
and change an allowed file. All other built-in capabilities are disabled.

The adapter remains the security boundary for file attribution, validation,
timeouts, and structured-result acceptance. An allowlist reduces prompt and
capability surface; it is not treated as a filesystem sandbox.

## Measurement

The existing successful smoke is the baseline: 90,297 input tokens. On
2026-07-30, three non-sensitive minimal-worker contracts completed with 20,082,
20,134, and 20,509 input tokens (77.8%, 77.7%, and 77.3% reductions). They
covered one-file creation, one-file replacement, and two-file creation; each
returned a structured result, modified only allowed files, and passed
validation. The configuration is now the worker default. A later change may
introduce an input-token budget after collecting representative real-task data.
