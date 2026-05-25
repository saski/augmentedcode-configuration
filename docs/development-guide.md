# Development Guide

This document covers repository-internal structure, sync workflows, and validation for maintainers.

## Canonical Sources

- `.agents/rules/` is the shared rulebook.
- `.agents/skills/` is the canonical shared skill library.
- `.agents/commands/` is the canonical shared command library.
- `.agents/mcp.json` is the shared MCP configuration.
- `.agents/hooks/` is the canonical shared hook location (including RTK rewrite hook).
- `.agents/bin/` contains ignored local tool shims created by `setup-symlinks.sh`.
- `docs/openspec/` is the OpenSpec artifact root for this tooling repo, exposed through the root `openspec` symlink for CLI compatibility.
- `.cursor/skills-cursor/` contains Cursor-only local skills. `.cursor/skills/` is not tracked in this repo.

## Rule Model

`.agents/rules/base.md` is intentionally compact and always-loaded. Its universal behavior is organized around four operating principles: Think Before Acting, Simplest Surgical Change, Goal-Driven Verification, and Checkpoint and Escalate.

Repo-type details belong in contextual rule files such as `.agents/rules/python-project.md` and `.agents/rules/makefile-project.md`. Task-specific workflows belong in skills. Do not add generic best-practice prose to `base.md` unless it routes concrete behavior that agents cannot reliably infer from the codebase or user request.

## Skill Library Model

The skill library is self-contained:

- Native skills are authored directly in `.agents/skills/`.
- Imported skill-factory skills are copied into `.agents/skills/` and tracked in git.
- Matt Pocock skills are installed into `.agents/skills/` and tracked in git with provenance in `skills-lock.json`.
- Product-management skills are tracked in `.agents/skills/` with provenance in `skills-lock.json`.
- Skill-factory provenance is tracked in `.agents/upstreams/skill-factory/components.lock.json`.
- ECC upstream components are tracked in `.agents/upstreams/ecc/components.lock.json`.

Governance lives in:

- `.agents/docs/skill-factory-skills.md`
- `.agents/skills/skill-foundry/agents/catalog.yaml`
- `.agents/skills/skill-foundry/agents/catalog-engineering.yaml`
- `.agents/skills/skill-foundry/agents/catalog-product-management.yaml`

## Setup and Validation

```bash
./setup-symlinks.sh setup
make install-hooks
make check
```

`make check` is the canonical local healthcheck and runs:

- `make test`
- `make lint-shell`
- `make validate-skills`
- `make validate-openspec`
- `make validate-symlinks`
- `make check-tracked-ignored`

Recommended direct checks when diagnosing a specific failure:

```bash
make lint-shell
make test
./tests/validate-skill-library-test.sh
./validate-skill-library.sh
OPENSPEC_TELEMETRY=0 openspec validate --all
```

`check-tracked-ignored` is report-only. It surfaces tracked files that match `.gitignore` so maintainers can decide whether a path is intentional or should be removed from version control.

The TypeScript CLI under `src/thoughts/` is not part of mandatory `make check` until dependency installation is reproducible for this repository.

The Makefile prepends `~/.agents/bin`, `~/.bun/bin`, `/opt/homebrew/bin`, and `/usr/local/bin` to `PATH` so checks can find managed tools from non-login shells.

## Pre-Commit Hook

The tracked pre-commit template lives at `hooks/pre-commit` and delegates to `make check`.

Install it with:

```bash
make install-hooks
```

The install target uses `git rev-parse --git-path hooks/pre-commit`, so it works from linked worktrees as well as the main checkout.

## Syncing Imported Skills

Use the local `skill-factory` checkout to refresh imported skills:

```bash
SKILL_FACTORY=/path/to/skill-factory ./pull-and-sync-skills.sh
```

What this does:

- pulls the upstream repository
- copies upstream skill directories into `.agents/skills/`
- preserves native repo-owned skills and other external skill packs
- refreshes `.agents/upstreams/skill-factory/components.lock.json`

Preview only:

```bash
SKILL_FACTORY=/path/to/skill-factory ./sync-skill-factory.sh --dry-run
```

## Tool Wiring

`setup-symlinks.sh` manages these local links:

- `~/.cursor/commands` -> repo `.cursor/commands` -> repo `.agents/commands`
- `~/.cursor/skills` -> repo `.agents/skills`
- `~/.cursor/skills-cursor` -> repo `.cursor/skills-cursor`
- `~/.cursor/.agents` -> repo `.agents`
- `~/.cursor/mcp.json` -> repo `.agents/mcp.json`
- `~/.cursor/cli-config.json` -> repo `.cursor/cli-config.json`
- `~/.codex/skills/skills` -> repo `.agents/skills`
- `~/.codex/rules/default.rules` -> repo `.agents/rules/codex-default.rules`
- `~/.claude/commands` -> repo `.agents/commands`
- `~/.claude/skills` -> repo `.agents/skills`
- `~/.claude/hooks` -> repo `.claude/hooks`
- `~/.claude/hooks/rtk-rewrite.sh` -> repo `.claude/hooks/rtk-rewrite.sh` -> repo `.agents/hooks/rtk-rewrite.sh`
- `~/.gemini/antigravity/mcp_config.json` -> repo `.agents/mcp.json`
- `~/.gemini/GEMINI.md` -> repo `GEMINI.md`
- `~/.agents` -> repo `.agents`
- `~/.agents/bin/rtk` -> `/opt/homebrew/bin/rtk` when Homebrew RTK is present
- `~/.agents/bin/openspec` -> `/opt/homebrew/bin/openspec` or `~/.bun/bin/openspec` when OpenSpec is present

Mutable local config such as `~/.codex/config.toml` and `~/.claude/settings.json` is seeded from `templates/` and intentionally not symlinked back into the repo.

## Thoughts and Workflow Assets

- `thoughts/shared/research/` stores shared research artifacts.
- `thoughts/shared/plans/` stores implementation plans.
- `src/thoughts/` contains the CLI used to manage the `thoughts/` tree.

## Repository Notes

- The root shims `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` point to `.agents/rules/base.md`.
- The validator only passes when filesystem inventory, catalogs, and the skills index are in sync.
- Adding, removing, renaming, or moving a skill requires the same-change updates to `.agents/docs/skill-factory-skills.md` and the relevant skill-foundry governance catalog. Update `.agents/docs/skill-domain-routing.md`, `README.md`, `PROJECT_STATUS.md`, and provenance lock files when routing, user-facing inventory, status, or source ownership changes.
- If a skill moves from skill-factory to another source, remove it from `.agents/upstreams/skill-factory/components.lock.json`; otherwise the skill-factory sync will refresh and overwrite it.
