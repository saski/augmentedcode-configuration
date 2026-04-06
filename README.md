# Augmented Code Configuration

Reusable AI agent configuration for development workflows across Codex, Cursor, Claude, Gemini, and related tools.

## What You Get

- Shared rules in `.agents/rules/`
- Shared skills in `.agents/skills/`
- Shared commands in `.agents/commands/`
- Setup scripts that wire local tool config back to this repository

## Quick Start

```bash
git clone <repo-url> augmentedcode-configuration
cd augmentedcode-configuration
./setup-symlinks.sh setup
./setup-symlinks.sh validate
./validate-skill-library.sh
```

## Repository Layout

```text
.
├── .agents/          # Shared rules, skills, commands, MCP config
├── .cursor/          # Cursor-specific rules and config
├── .claude/          # Claude-specific hooks and helper files
├── .gemini/          # Gemini-specific config shims
├── templates/        # Seed files copied into mutable local config
├── thoughts/         # Shared research and plans
└── docs/             # Maintainer and development documentation
```

## Common Tasks

```bash
./setup-symlinks.sh setup
./setup-symlinks.sh validate
./validate-skill-library.sh
./pull-and-sync-skills.sh
```

## Troubleshooting

Broken local setup usually shows up as one of these messages:

- `Repository not found at ...`
  Set `REPO_DIR=/path/to/augmentedcode-configuration` and rerun `./setup-symlinks.sh setup`.
- `broken skill symlinks:`
  Run `./pull-and-sync-skills.sh` if you are refreshing imported upstream skills, then rerun `./validate-skill-library.sh`.
- `missing from governance catalogs:`
  Add the missing skill entries to the skill-foundry catalogs under `.agents/skills/skill-foundry/agents/`.

## Development Guide

Maintainer, CI, and repository-internal workflow documentation lives in [docs/development-guide.md](docs/development-guide.md).
