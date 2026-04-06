# Development Guide

This document covers repository-internal structure, sync workflows, and validation for maintainers.

## Canonical Sources

- `.agents/rules/` is the shared rulebook.
- `.agents/skills/` is the canonical shared skill library.
- `.agents/commands/` is the canonical shared command library.
- `.agents/mcp.json` is the shared MCP configuration.
- `.cursor/skills-cursor/` contains Cursor-only local skills. `.cursor/skills/` is not tracked in this repo.

## Skill Library Model

The skill library is self-contained:

- Native skills are authored directly in `.agents/skills/`.
- Imported skill-factory skills are copied into `.agents/skills/` and tracked in git.
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
./setup-symlinks.sh validate
./validate-skill-library.sh
```

Recommended script checks after changes:

```bash
bash -n setup-symlinks.sh sync-skill-factory.sh pull-and-sync-skills.sh backup-cursor-config.sh validate-skill-library.sh tests/validate-skill-library-test.sh
./tests/validate-skill-library-test.sh
./validate-skill-library.sh
```

## Syncing Imported Skills

Use the local `skill-factory` checkout to refresh imported skills:

```bash
SKILL_FACTORY=/path/to/skill-factory ./pull-and-sync-skills.sh
```

What this does:

- pulls the upstream repository
- copies upstream skill directories into `.agents/skills/`
- preserves native repo-owned skills
- refreshes `.agents/upstreams/skill-factory/components.lock.json`

Preview only:

```bash
SKILL_FACTORY=/path/to/skill-factory ./sync-skill-factory.sh --dry-run
```

## Tool Wiring

`setup-symlinks.sh` manages these local links:

- `~/.cursor/rules` -> repo `.cursor/rules`
- `~/.cursor/commands` -> repo `.agents/commands`
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
- `~/.gemini/antigravity/mcp_config.json` -> repo `.agents/mcp.json`
- `~/.agents` -> repo `.agents`

Mutable local config such as `~/.codex/config.toml` and `~/.claude/settings.json` is seeded from `templates/` and intentionally not symlinked back into the repo.

## Thoughts and Workflow Assets

- `thoughts/shared/research/` stores shared research artifacts.
- `thoughts/shared/plans/` stores implementation plans.
- `src/thoughts/` contains the CLI used to manage the `thoughts/` tree.

## Repository Notes

- The root shims `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` point to `.agents/rules/base.md`.
- The validator only passes when filesystem inventory, catalogs, and the skills index are in sync.
- When updating imported or native skills, update both the discovery index and the relevant skill-foundry catalog.
