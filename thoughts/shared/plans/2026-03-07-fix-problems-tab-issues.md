# Fix Problems Tab (240 Issues) – Implementation Plan

## Overview

Systematically reduce and resolve the 240 issues reported in the IDE Problems tab by triaging, prioritizing, and fixing in batches, then adding guards so they do not regress.

## Current State Analysis

- **Source of truth**: The Problems tab in Cursor/VS Code (we cannot read it from here). Issues may come from:
  - TypeScript/JavaScript (`tsc`, language service)
  - ESLint (or other JS/TS linters)
  - Markdown linters (e.g. markdownlint, markdownlint-cli)
  - Other extensions (Python, JSON, YAML, etc.)
- **Workspace**: Workspace root is `/Users/saski`; likely target is a specific project (e.g. `saski/augmentedcode-configuration` or another repo).
- **Constraint**: Plan is written without direct access to the 240 issues; **reproducing them** is Phase 0.

## Desired End State

- Problems tab shows **0** issues (or an agreed non‑zero baseline) for the chosen project.
- One or more commands (e.g. `make validate`, `npm run lint`, `npx markdownlint-cli`) reproduce the same set of issues.
- Fixes are applied in small, reviewable batches.
- CI or pre-commit runs the same checks so issues do not reappear.

## What We're NOT Doing

- Fixing issues in dependencies or generated files (unless explicitly in scope).
- Changing behavior or features; only addressing tooling/quality issues that the Problems tab reports.
- Fixing issues outside the agreed project/scope.

## Prerequisites (Clarification)

Before execution, confirm:

1. **Project**: Which path contains the 240 issues? (e.g. `saski/augmentedcode-configuration`, or full workspace?)
2. **Reproduction**: How can we reproduce the same list?
   - Run a specific command (e.g. `npm run lint`, `npx tsc --noEmit`, `npx markdownlint-cli '**/*.md'`) and get a comparable count?
   - Or export from the IDE (e.g. copy from Problems panel, or use an extension that exports)?
3. **Types**: What kinds of issues appear? (e.g. TypeScript errors, ESLint rules, markdown rules, Python, etc.)

Once these are known, run the reproduction command and capture output (or a sample) so we can categorize and prioritize.

---

## Phase 0: Reproduce and Categorize

### Overview

Get a machine-readable list of the 240 issues and group them by tool, rule, file, and severity so we can prioritize.

### Steps

1. **Identify project root**
   - Set `PROJECT_ROOT` to the path that should have 0 issues (e.g. `saski/augmentedcode-configuration`).

2. **Reproduce via command line**
   - From `PROJECT_ROOT`, run whatever produces the same issues. Examples:
     - TypeScript: `npx tsc --noEmit` (or `pnpm exec tsc --noEmit`).
     - ESLint: `npx eslint .` (or `npm run lint` / `make check-style`).
     - Markdown: `npx markdownlint-cli '**/*.md'` or project script.
   - If the IDE uses a different config, align CLI to it (same `tsconfig`, same ESLint config, etc.).

3. **Export/capture output**
   - Redirect to a file, e.g. `problems-raw.txt` or use JSON/formatter if available:
     - ESLint: `--format json > eslint-report.json`
     - TypeScript: keep stdout/stderr or use a tool that outputs structured errors
   - Optionally: from the IDE, copy a sample of the Problems list (e.g. first 50 lines) into `thoughts/shared/research/2026-03-07-problems-tab-sample.txt` for reference.

4. **Categorize**
   - Group by:
     - **Tool**: tsc vs ESLint vs markdownlint vs other.
     - **Rule or code** (e.g. `@typescript-eslint/no-explicit-any`, `ts(2307)`).
     - **File** (and optionally folder).
     - **Severity**: error vs warning (if applicable).
   - Produce a short summary, e.g. in `thoughts/shared/research/2026-03-07-problems-tab-categories.md`:
     - Count per tool.
     - Top 5–10 rules and their counts.
     - List of files with most issues (e.g. top 20).

### Success Criteria

- [ ] Reproduction command runs from `PROJECT_ROOT` and yields a comparable number of issues (~240).
- [ ] Categories and counts are documented (tool, rule, file).
- [ ] Sample of raw output (or full report) is saved under `thoughts/shared/research/` for reference.

---

## Phase 1: Harden Tooling and Baseline

### Overview

Ensure one command (or a small set) fully reflects what the Problems tab reports, and decide whether to fix or temporarily suppress certain rules.

### Steps

1. **Single entry point**
   - Prefer one command that runs all relevant checks (e.g. `make validate` or `npm run validate`).
   - If the project has `make validate`, ensure it runs the same linters/compilers as the IDE (e.g. `make check-typing`, `make check-style`, `make check-format`).
   - If not, add a script that runs tsc + lint (+ markdown if applicable) and exits with a non‑zero code if any issue remains.

2. **Config alignment**
   - Compare IDE vs CLI configs (e.g. `tsconfig.json`, `.eslintrc*`, `markdownlint.*`).
   - Make CLI use the same configs so that “fix in CLI” = “fix in Problems tab”.

3. **Baseline decision**
   - For rules that are too noisy or out of scope: either fix in a later phase or add a temporary baseline (e.g. ESLint `--max-warnings` or inline disables with a TODO).
   - Document in the research file which rules are “fix now” vs “baseline for later”.

### Success Criteria

- [ ] One (or a small set of) command(s) from `PROJECT_ROOT` reproduces the Problems-tab issues.
- [ ] Configs used by CLI and IDE are aligned and documented.
- [ ] Any baseline or “fix later” list is written down.

---

## Phase 2: Prioritize and Batch

### Overview

Define an order of work: by impact (errors first), by rule (one rule at a time), or by file (one folder at a time).

### Steps

1. **Prioritize**
   - **Errors first**: any issue that fails the build or blocks deploy.
   - **Then by rule**: pick rules with high count and low risk (e.g. formatting, quote style) for quick wins.
   - **Then by file**: focus on key modules or most-violated files.

2. **Define batches**
   - Batch size: e.g. 20–40 issues per PR/session so changes stay reviewable.
   - Example batching:
     - Batch A: All TypeScript errors (if any).
     - Batch B: Top 2 ESLint rules (e.g. 80 issues).
     - Batch C: Next 2 ESLint rules (e.g. 60 issues).
     - Batch D: Remaining ESLint + markdown (e.g. 100 issues).

3. **Document**
   - In `thoughts/shared/research/2026-03-07-problems-tab-categories.md` (or a short “batches” section), list:
     - Batch 1: [rule/file], estimated count, command to verify.
     - Batch 2: …

### Success Criteria

- [ ] Batches are defined with clear scope and a way to verify (e.g. “run ESLint, only rule X”).
- [ ] Order of batches is agreed (errors → high-count rules → rest).

---

## Phase 3: Fix by Batch

### Overview

Apply fixes batch by batch, run the reproduction command after each batch, and commit (or prepare PRs) so progress is traceable.

### Steps (per batch)

1. **Fix one batch**
   - Only address the scope of the current batch (one rule, one folder, or one tool).
   - Prefer autofix where safe (e.g. `eslint --fix`, formatter).
   - Manual edits: small, focused changes (e.g. one rule per commit).

2. **Verify**
   - From `PROJECT_ROOT`, run the full reproduction command.
   - Confirm the number of issues decreased by the expected amount and no new issues appear.

3. **Commit / PR**
   - Commit with a message that references the batch (e.g. “fix(eslint): resolve no-explicit-any in src/ (batch 2)”).
   - Optionally open a PR so batches can be reviewed independently.

4. **Repeat**
   - Next batch until the reproduction command reports 0 (or the agreed baseline).

### Success Criteria (per batch)

- [ ] Reproduction command shows fewer issues after the batch.
- [ ] No new issues introduced (same command, no regressions).
- [ ] Changes are committed (or in a PR) with a clear batch identifier.

---

## Phase 4: Automate and Lock

### Overview

Ensure the same checks run in CI and, if desired, in pre-commit so the 240 issues cannot silently return.

### Steps

1. **CI**
   - Add or update a job that runs the same command(s) as in Phase 0/1 (e.g. `make validate` or `npm run validate`).
   - Fail the job if the command exits non‑zero (or if issue count exceeds the agreed baseline).

2. **Pre-commit (optional)**
   - If the project uses pre-commit hooks, run the same checks on staged files (or full repo).
   - Document in README or `docs/development_guide.md` how to run checks locally.

3. **Docs**
   - In README or developer guide: “To get 0 issues locally, run `<command>` from project root.”

### Success Criteria

- [ ] CI runs the reproduction command and fails on new issues (or above baseline).
- [ ] Local run of the same command is documented.
- [ ] Pre-commit (if used) is aligned with that command.

---

## Testing Strategy

- **No new tests for “fixing Problems tab”**: this work is about satisfying existing linters/compilers.
- **Verification**: the reproduction command *is* the test (e.g. `make validate`, `npm run lint`, `tsc --noEmit`).
- **Regression**: CI and pre-commit prevent the issue count from growing again.

---

## References

- FIC workflow: `.cursor/rules/fic-workflow.mdc`
- Project status: `PROJECT_STATUS.md`
- Plan location: `thoughts/shared/plans/2026-03-07-fix-problems-tab-issues.md`

---

## Next Steps

1. **You**: Confirm project path, how you reproduce the 240 (command or export), and main issue types.
2. **Execute Phase 0**: Run the command, capture output, and fill `thoughts/shared/research/2026-03-07-problems-tab-categories.md` (and optional sample file).
3. **Then**: Proceed with Phase 1 (tooling/baseline) and Phase 2 (batches), then Phase 3 (fix) and Phase 4 (automate).
