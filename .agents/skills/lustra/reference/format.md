# format

**Purpose:** formatting drift, fixed mechanically, with nothing else touched.

## Detect

Detect the stack (SKILL.md § Stack detection), then run its formatter in check mode:

| Stack | Formatter (check) | Write |
| --- | --- | --- |
| JS/TS | `npx -y prettier --check` | `prettier --write` |
| Python | `ruff format --check` (or `black --check`) | `ruff format` / `black` |
| Go | `gofmt -l` | `gofmt -w` |
| Rust | `cargo fmt --check` | `cargo fmt` |

1. Honor any existing formatter config (`.prettierrc`/`.prettierignore`, `pyproject.toml`,
   etc.); do not create or modify it.
2. If the project has no formatter config, run with the tool's defaults and say the result
   reflects tool defaults, not a project standard; offer to add a config as a separate
   confirmed step.

## Triage

Output is deterministic, so there is nothing to rank. Split the result into two sets:
files the formatter can rewrite, and files it cannot parse. A parse failure is a real
error to fix at the source — never "format away" by hand.

## Fix policy

- Present the drifted files as an itemized checklist. On approval, run the formatter's
  write mode on the approved subset only, then re-run check mode to confirm clean.
  Confirmation flow per SKILL.md.
- Never hand-edit formatting or "tidy" code the formatter did not flag.

## Report

Count of files reformatted (and which), then the unparseable files each with `file:line`
and the parser error — listed as fix-at-source items, not formatting.
