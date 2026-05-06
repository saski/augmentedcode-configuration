# Fix small-safe-steps Skill Frontmatter

## Overview

Fix the loader-breaking YAML frontmatter in `.agents/skills/small-safe-steps/SKILL.md` and verify the shared skill library loads cleanly again.

## Current State

- `./validate-skill-library.sh` fails on `.agents/skills/small-safe-steps/SKILL.md`.
- The failing field is line 3: `description: Small Safe Steps (S3): ...`.
- YAML treats the unquoted colon after `(S3)` as a mapping separator.
- `small-safe-steps` is imported from `saski/skill-factory` at source path `output_skills/practices/small-safe-steps`, so a future sync can reintroduce the issue if upstream remains unfixed.
- The validator already has a regression test for invalid unquoted colon frontmatter in `tests/validate-skill-library-test.sh`.

## Desired End State

- `small-safe-steps` has parser-safe YAML frontmatter.
- `./validate-skill-library.sh` passes.
- `tests/validate-skill-library-test.sh` passes.
- If the imported source is available, the upstream `skill-factory` copy is fixed or a follow-up is explicitly tracked.

## Out of Scope

- Rewriting the body of the `small-safe-steps` skill.
- Changing validator behavior.
- Reworking skill discovery, governance catalogs, or sync scripts unless validation exposes an additional failure.

## Approach

Use the smallest local correction first: convert the `description` value to a YAML folded scalar with `>-`. This preserves the text while making punctuation such as colons and quotes safe.

Then run the validator and its regression test. If they pass, check whether the local `skill-factory` checkout is available and patch the upstream source too, or record that upstream remediation remains pending.

## Phased Changes

### Phase 1: Confirm the Red State

Status: Completed.

1. Run `rtk ./validate-skill-library.sh`.
2. Confirm the only failure is `small-safe-steps` invalid frontmatter.

Success criteria:

- The command fails before implementation.
- The failure names `small-safe-steps`.

### Phase 2: Make the Minimal Local Fix

Status: Completed.

1. Edit `.agents/skills/small-safe-steps/SKILL.md`.
2. Replace the plain scalar description with folded YAML:

```yaml
description: >-
  Small Safe Steps (S3): breaks work into 1-3h increments with zero downtime. Use when asking "how do I implement/migrate/refactor", "what steps to do X", "plan safe migration", or handling risky DB/API changes. Applies expand-contract pattern for migrations, refactorings, schema changes.
```

Success criteria:

- Only the frontmatter representation changes.
- The visible description text is semantically unchanged.

### Phase 3: Verify the Local Library

Status: Completed.

1. Run `rtk ./validate-skill-library.sh`.
2. Run `rtk ./tests/validate-skill-library-test.sh`.
3. Optionally run `rtk bash -n validate-skill-library.sh tests/validate-skill-library-test.sh` if shell syntax validation is desired.

Success criteria:

- Skill library validation passes.
- Validator regression tests pass.

### Phase 4: Prevent Reintroduction

Status: Completed.

1. Locate the local `skill-factory` checkout if available.
2. Apply the same folded-scalar fix to `output_skills/practices/small-safe-steps/SKILL.md`.
3. If upstream cannot be edited from this workspace, record a follow-up to fix `saski/skill-factory` before the next sync.

Success criteria:

- Either the upstream source is patched, or the remaining upstream risk is explicitly documented.

Result:

- Local upstream checkout found at `../skill-factory`.
- Its `output_skills/practices/small-safe-steps/SKILL.md` still has the unquoted `description` scalar.
- The checkout is outside this workspace's writable roots and already contains unrelated modified skill files, so the upstream source was not edited in this implementation pass.
- Follow-up: patch `../skill-factory/output_skills/practices/small-safe-steps/SKILL.md` with the same folded-scalar `description` before the next `./pull-and-sync-skills.sh` run.

## Expected Modified Files

- `.agents/skills/small-safe-steps/SKILL.md`
- `PROJECT_STATUS.md` if implementation completes and status should reflect the remediation
- Optional upstream file outside this repo: `skill-factory/output_skills/practices/small-safe-steps/SKILL.md`

## Next Step

Run: `fic-implement-plan thoughts/shared/plans/2026-05-05-fix-small-safe-steps-frontmatter.md`
