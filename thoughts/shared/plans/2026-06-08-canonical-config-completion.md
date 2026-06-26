# Canonical Config Completion Plan

## Overview

This repository is the canonical source for AI development tool configuration. The home-directory symlink layer has been repaired for this checkout at `/Users/saski/Code/augmentedcode-configuration`, but full repository validation is not yet green.

## Current State

- `make validate-symlinks` passes after `Makefile` now passes `REPO_DIR="$(pwd)"` into `setup-symlinks.sh`.
- `~/.cursor`, `~/.codex`, `~/.claude`, `~/.gemini`, `~/.antigravity`, `~/.langflow`, `~/.agents`, `~/AGENTS.md`, `~/CLAUDE.md`, and `~/GEMINI.md` are wired to this checkout.
- `~/.agents/bin/rtk` points to `/opt/homebrew/bin/rtk`, and `/Users/saski/.agents/bin/rtk --version` reports `rtk 0.42.3`.
- `make lint-shell`, `make validate-cursor-skills`, `./tests/healthcheck-automation-test.sh`, `./tests/rtk-global-contract-test.sh`, `./tests/cursor-skills-validation-test.sh`, and `make check-tracked-ignored` pass.
- `make test` and `make validate-skills` fail because local sibling skill symlinks are broken.
- `make validate-openspec` fails because the OpenSpec CLI is missing.
- `AGENTS.md` exists as an untracked regular file in the repository root.

## Desired End State

- `make check` passes from `/Users/saski/Code/augmentedcode-configuration`.
- All managed home-directory links point to this checkout.
- The local sibling skill source strategy is explicit, reproducible, and validated.
- OpenSpec validation runs through the canonical Makefile target.
- Root instruction shims have no untracked drift.

## Out Of Scope

- Changing the universal rulebook content beyond what is needed for validation.
- Reworking skill governance catalogs unless the sibling skill source strategy changes.
- Resolving Eventbrite Cursor team-level Marmalade rules.
- Completing the `tlz-connection` PR.

## Phase 1: Restore Sibling Skill Sources

Restore the sources referenced by `.agents/upstreams/local-saski-skills/components.lock.json`.

Preferred path:

1. Clone or restore `saski/augmented-lean-delivery` next to this checkout as `/Users/saski/Code/augmented-lean-delivery`.
2. Clone or restore `saski/augmentedcode-skills` next to this checkout as `/Users/saski/Code/augmentedcode-skills`.
3. Check out the recorded commits if exact provenance is required:
   - `augmented-lean-delivery`: `e60dba69ecaf799e786a96fd27dccf2e5e216ee3`
   - `augmentedcode-skills`: `3e0c39814ae041c92a5c52e01c79994f42a309ea`

Alternative path:

1. Vendor the seven skills directly into `.agents/skills/`.
2. Remove or revise the symlink expectations in `tests/external-skill-references-test.sh`.
3. Update `.agents/upstreams/local-saski-skills/components.lock.json`, `.agents/docs/skill-factory-skills.md`, `.agents/docs/skill-domain-routing.md`, the relevant skill-foundry catalog, `README.md`, and `PROJECT_STATUS.md`.

Success criteria:

- `./tests/external-skill-references-test.sh`
- `make validate-skills`

## Phase 2: Install OpenSpec CLI

Install `openspec` in a location managed by `setup-symlinks.sh`, preferably `/opt/homebrew/bin/openspec` or `~/.bun/bin/openspec`.

Then run:

```bash
REPO_DIR=/Users/saski/Code/augmentedcode-configuration ./setup-symlinks.sh setup
make validate-symlinks
make validate-openspec
```

Success criteria:

- `~/.agents/bin/openspec` exists and points to an executable.
- `make validate-openspec` passes.

## Phase 3: Resolve Root Instruction Drift

Decide whether the root `AGENTS.md` should be tracked again or removed.

Recommended path:

1. Remove the untracked root `AGENTS.md` regular file.
2. Keep `~/AGENTS.md` pointing directly to `.agents/rules/base.md`.
3. Keep tracked root shims limited to the currently tracked `CLAUDE.md` and `GEMINI.md`, unless documentation says otherwise.

Success criteria:

- `git status --short AGENTS.md CLAUDE.md GEMINI.md` shows no untracked root `AGENTS.md`.
- `make validate-symlinks` still passes.

## Phase 4: Final Verification

Run the complete canonical healthcheck:

```bash
make check
```

Success criteria:

- `make check` exits 0.
- `PROJECT_STATUS.md` is updated to record the final result.
