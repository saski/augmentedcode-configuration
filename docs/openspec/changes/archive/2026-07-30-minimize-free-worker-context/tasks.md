## 1. Minimal Worker

- [x] 1.1 Add a regression assertion for the constrained ephemeral agent configuration.
- [x] 1.2 Restrict the worker to `read` and `edit`, set a concise prompt, and cap it at three steps.
- [x] 1.3 Run three live bounded smokes and record the input-token comparison: 90,297 baseline versus 20,082, 20,134, and 20,509 input tokens (77.3–77.8% reduction), with structured results and validation passed.

## 2. Verification

- [x] 2.1 Run the free-worker regression suite and routing-manifest validation.
- [x] 2.2 Run `openspec validate --all` after the live smoke result is recorded.
