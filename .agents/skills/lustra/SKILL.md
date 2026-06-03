---
name: lustra
description: "Use when the user wants to clean up AI slop, harden a codebase, or run technical due diligence: review code for security flaws and vulnerable or wrongly-licensed dependencies, find and remove dead code, audit dependency health, run and triage linters, type checkers, test suites and formatters, evaluate design principles (SOLID and the cohesion/coupling equivalents for non-OO stacks), audit logging and observability, find performance smells, check documentation and CI health, scaffold baseline configs for the detected stack, do a structured code review, guide a one-major-at-a-time dependency migration, fix project structure, or produce one aggregated health report across all of these. Triggers on phrases like clean this up, find security issues, remove dead code, check dependencies, lint, typecheck, run the tests, format, review my code, check the design, check logging, is this slow, migrate a dependency, fix the project structure, set up the project, audit everything, due diligence, or this looks like AI slop. Wraps the detected stack's real tooling — dependency auditor, linter, type checker, test runner, formatter, dead-code and license scanners — and triages its output. Not for UI/visual design work."
user-invocable: true
argument-hint: "[audit|baseline|review|types|tests|analyze|format|security|license|deadcode|deps|design|observability|perf|docs|migrate|ci|structure] [target]"
allowed-tools: Bash Read Edit Grep Glob
---

# Lustra

Lustra wraps real code-hygiene tooling and applies judgment on top of it. It does not
guess where a tool would. It runs the tool, filters false positives, ranks what matters,
and applies only the changes the user approves.

## Dispatch

`$1` is the command. `$2` and beyond are the target (a path or glob). When no target is
given, default to the whole repository.

- If `$1` is empty or `help`, print the command list below and stop.
- Otherwise read `${CLAUDE_SKILL_DIR}/reference/$1.md` and follow it exactly, scoped to the
  target. If `reference/$1.md` does not exist, say so and print the command list.

## Commands

Grouped by lifecycle phase. `audit` runs the diagnostic ones together.

**Assess / start**
- `audit` — meta-command: one graded health report across every dimension (due diligence).
- `baseline` — scaffold the guardrail configs a project should have, for the detected stack.

**Iterate**
- `review` — structured correctness / design / slop review of a diff or path.
- `types` — type-checker triage; catch `any`/`@ts-ignore`-style evasion.
- `tests` — run the suite, coverage on the diff, catch fake/empty tests.
- `analyze` — the linter's findings plus AI-slop smells that no rule catches.
- `format` — formatting drift, fixed mechanically.

**Polish**
- `security` — vulnerabilities: secrets, injection, broken authorization, vulnerable deps.
- `license` — dependency license compatibility and IP risk.
- `deadcode` — unused files, exports, and dependencies; deletes only what is confirmed.
- `deps` — dependency health and upgrades: outdated, deprecated, duplicated. Reports
  unused deps and advisories but defers deletion to `deadcode` and vuln fixes to `security`.
- `design` — module/package design quality: SOLID, or cohesion/coupling/composition for
  non-OO stacks. Module-scoped, unlike diff-scoped `review` or layout-scoped `structure`.
- `observability` — logging and instrumentation quality so failures are diagnosable.
- `perf` — performance smells: N+1, blocking IO, unbounded growth, bundle weight.
- `docs` — documentation drift and undocumented public surface.

**Maintain**
- `migrate` — guided one-major-at-a-time dependency migration: changelog, codemods, suite.
- `ci` — pipeline soundness: real gates, CI security, reproducibility.
- `structure` — detect the stack, then report or reorganize project structure.

## Rules that override every reference file

These come from the project's own engineering guidelines and are not negotiable:

1. **Surgical.** Every changed line must trace to the requested command. Never "improve"
   adjacent code, comments, or formatting that the command did not target.
2. **No silent changes — ever.** Nothing is auto-applied, not even mechanically-safe
   formatting or an unambiguously unused import. Every change is presented as an itemized
   checklist with its evidence/diff, and only the items the user approves are applied.
3. **Report honestly.** If a tool is missing, a step was skipped, or a finding is
   low-confidence, say so plainly. Do not present a partial pass as a clean one.
4. **English only**, in all output and any code or config you write.
5. **Confirm before any file or dependency change.** Not just destructive or
   hard-to-reverse ones — every edit goes through the Confirmation flow below as a staged,
   explicitly-confirmed checklist, never a bulk rewrite.

## Confirmation flow

The single flow every command follows (the `deadcode` pattern). Reference files do not
redefine it:

1. Run the read-only detect/triage steps automatically — these never need confirmation.
2. Present every proposed change as an itemized checklist: the `file`/target, the exact
   action (command or diff), and the evidence/reason per item.
3. Apply only the items the user approves, in one reviewable change.
4. Re-run the relevant check to confirm clean, then report what was applied, what was
   skipped, and why.

Read-only detection is exempt. Changing files or dependencies is not.

## Stack detection

Every command that runs a tool first identifies the stack. Reference files point here and
do not redefine this:

1. Read the manifests at the target root to identify language and framework:
   `package.json` (and the framework), `pyproject.toml`/`setup.py`, `go.mod`,
   `Cargo.toml`, `pom.xml`/`build.gradle`, `Gemfile`, `composer.json`.
2. State the detected stack explicitly before running anything. If detection is ambiguous
   or the repo is polyglot, ask rather than assume.
3. Pick the tool from the reference file's per-ecosystem table. If no tool exists for the
   detected stack, say so and fall back to static reading — mark that result
   lower-confidence. Never run a stack's tool against a project that is not that stack.
