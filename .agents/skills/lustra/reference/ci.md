# ci

**Purpose:** the pipeline that guards the project is itself sound.

## Detect

1. Locate CI config: `.github/workflows/*`, `.gitlab-ci.yml`, `Jenkinsfile`,
   `.circleci/`, etc. If a real project has none, that is the top finding.
2. Check the pipeline actually gates: are lint, types, tests, build, and audit run, and
   do they **fail** the job (not `|| true`, not `continue-on-error` masking failures)?
3. Security/hygiene: secrets echoed into logs, untrusted PR code running with secrets,
   unpinned third-party actions (`@main`), missing least-privilege `permissions`,
   no deterministic lockfile install (the stack's frozen-install mode, e.g. `npm ci`,
   `pip install --require-hashes`, `go mod download` + verify, `cargo build --locked`).
4. Reproducibility: pinned toolchain versions, cache keyed correctly, deterministic
   install from the lockfile.

## Triage

Rank: a gate that doesn't gate (green pipeline, broken check) > security exposure in CI >
non-reproducible build > missing-but-non-critical step. The most dangerous finding is a
pipeline that *looks* green while enforcing nothing — call it out first.

## Fix policy

- Auto: nothing — CI changes affect every future build.
- Present the fixes as an itemized checklist, one concern per item: the specific workflow
  edit (add the failing gate, pin the action, scope `permissions`, switch to a frozen
  install) with the risk it closes. Apply only approved items; Confirmation flow per
  SKILL.md.

## Report

```
CI — <target>

Pipeline inventory: <workflows / jobs found, or "none — top finding">

Gate analysis
  <check> enforced|claimed-only|absent   <evidence>

Security/reproducibility
  - <finding> — <risk> — proposed config change
```
