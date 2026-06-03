# observability

**Purpose:** logging and instrumentation good enough that a production failure is
diagnosable from the outside, not a guess.

## Detect

Detect the stack (SKILL.md § Stack detection), then locate its logging surface:

| Stack | Typical loggers |
| --- | --- |
| JS/TS | `console`, pino, winston, bunyan |
| Python | `logging`, structlog, loguru |
| Go | `log`, `slog`, zap, zerolog |
| Rust | `log`, `tracing`, env_logger |

Read the target for:

- Ad-hoc logging (`console.log`/`print`) where a structured logger is the convention.
- Missing or inconsistent log levels; everything at one level.
- Errors logged without context (no cause, no stack, no correlating id).
- Secrets or PII in log lines (tokens, passwords, emails, full request bodies).
- Swallowed errors: empty catch, catch-and-continue with no log, errors converted to a
  bare boolean.
- Critical paths with no instrumentation: request handlers, background jobs, external
  calls, and retries with no metric, span, or log.

## Triage

Rank: swallowed errors / secrets in logs > errors with no context > inconsistent
levels/structure > absent metrics or tracing on hot paths > cosmetic. Separate confirmed
from needs-human-judgment. A log line that leaks a secret is **blocking** — say so.

## Fix policy

- Auto: nothing — logging changes are semantic.
- Propose (diff + ask): add the missing context, redact the secret, log-and-rethrow the
  swallowed error, add the level or span — one change per finding. Confirmation flow per
  SKILL.md.

## Report

Findings ranked, each: `file:line` — the issue — the operational impact (what an on-call
engineer cannot see because of it) — proposed fix. End with what was skipped and why.
