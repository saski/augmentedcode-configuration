# Augmented Code Configuration

Reusable AI agent configurations for development workflows. Designed for XP/TDD practitioners who want consistent, high-quality AI assistance.

## Repository Structure

```text
.
├── .agent/
│   └── workflows/              # Context-driven development, TDD cycle
├── .agents/
│   ├── rules/                  # Canonical agent rules (shared across tools)
│   │   ├── base.md
│   │   ├── ai-feedback-learning-loop.md
│   │   └── react-best-practices.md
│   └── commands/               # Slash commands (synced to .cursor/commands by sync script)
│       ├── fic-*.md
│       ├── xp-*.md
│       └── eb-bug-fixing-agent.md
├── .cursor/
│   └── rules/                  # Cursor rules (.mdc); reference .agents/rules where applicable
│       ├── use-base-rules.mdc
│       ├── ai-feedback-learning-loop.mdc
│       ├── cursor-config-management.mdc
│       ├── project-status-maintenance.mdc
│       ├── fic-workflow.mdc
│       ├── tdd-workflow.mdc
│       ├── refactoring.mdc
│       ├── debugging.mdc
│       ├── python-dev.mdc
│       ├── react-best-practices.mdc
│       └── tlz-connection.mdc
├── src/thoughts/               # Node/TS CLI for thoughts/ management
├── thoughts/                   # Research and plans (see thoughts/ tree below)
├── sync-cursor-config.sh       # Sync .agents/commands ↔ .cursor/commands ↔ ~/.cursor/
└── (optional) AGENTS.md / CLAUDE.md / GEMINI.md → .agents/rules/base.md
```

Note: `.cursor/commands/` is created and populated from `.agents/commands/` when you run `./sync-cursor-config.sh`.

## FIC Workflow (Context Engineering)

Based on [stepwise-dev](https://github.com/nikeyes/stepwise-dev) and the [FIC methodology](https://nikeyes.github.io/tu-claude-md-no-funciona-sin-context-engineering-es/).

**Problem**: LLMs lose attention after ~60% context usage.

**Solution**: Structured phases with intentional context clearing:

```text
📖 Research → Save to thoughts/ → Clear context
📋 Plan → Save to thoughts/ → Clear context
⚙️ Implement (phase by phase) → Clear between phases
✅ Validate → Report
```

### FIC Commands

| Command | Purpose |
|---------|---------|
| `/fic-research` | Document codebase comprehensively, save to thoughts/shared/research/ |
| `/fic-create-plan` | Create detailed implementation plans iteratively |
| `/fic-implement-plan` | Execute plans phase by phase with verification |
| `/fic-validate-plan` | Verify implementation against plan |

### thoughts/ Directory

Persistent storage for research and plans (tracked in git). The repo contains `thoughts/shared/research/` and `thoughts/shared/plans/`. Run `npx thoughts init` to create the full structure:

```text
thoughts/
├── {username}/           # Personal notes (you write); created by init
│   ├── tickets/
│   └── notes/
├── shared/               # Team-shared (AI writes, tracked in git)
│   ├── research/         # Research documents
│   ├── plans/            # Implementation plans
│   └── prs/              # PR descriptions; created by init
└── searchable/           # Hardlinks for grep; created by init (gitignored)
```

Research documents and implementation plans in `thoughts/shared/` are committed to the repository to maintain project knowledge and enable collaboration.

### thoughts CLI

Node/TS CLI for managing thoughts/:

```bash
cd src/thoughts
npm install
npm run build

# Commands
npx thoughts init       # Initialize thoughts/ structure
npx thoughts sync       # Sync hardlinks after adding files
npx thoughts metadata   # Get git metadata for frontmatter
```

## XP/TDD Commands

XP/TDD commands use the `xp-` prefix. Eventbrite-specific variants use the `eb-` prefix.

| Command | Purpose |
|---------|---------|
| `/xp-code-review` | Review pending changes (tests, maintainability, rules) |
| `/xp-increase-coverage` | Identify and test high-value untested code |
| `/xp-plan-untested-code` | Create actionable plan to cover untested code |
| `/xp-predict-problems` | Predict likely production failures |
| `/xp-mikado-method` | Guide safe, incremental refactoring |
| `/xp-technical-debt` | Catalog and prioritize technical debt |
| `/xp-refactor` | Apply XP Simple Design principles |
| `/xp-simple-design-refactor` | Maintainability & Simple Design refactoring |
| `/xp-security-analysis` | Pragmatic security risk analysis |

## Eventbrite-Specific Commands

Eventbrite-specific commands use the `eb-` prefix.

| Command | Purpose |
|---------|---------|
| `/eb-bug-fixing-agent` | Eventbrite bug fixing expert with OWASP, threat modeling, cloud security |

## Cursor Rules

Development rules live in `.agents/rules/` (canonical). Cursor rules in `.cursor/rules/` point to them or add Cursor-specific behavior.

| Rule | Purpose | Activation |
|------|---------|------------|
| `use-base-rules.mdc` | Use `.agents/rules/base.md` as development rulebook | Always active |
| `ai-feedback-learning-loop.mdc` | Points to `.agents/rules/ai-feedback-learning-loop.md` | Always active |
| `cursor-config-management.mdc` | Repo ↔ global sync workflow | Always active |
| `project-status-maintenance.mdc` | PROJECT_STATUS.md maintenance | Always active |
| `fic-workflow.mdc` | FIC context management | Manual |
| `tdd-workflow.mdc` | TDD-specific rules | Manual |
| `refactoring.mdc` | Safe refactoring | Manual |
| `debugging.mdc` | Systematic debugging | Manual |
| `python-dev.mdc` | Python-specific | Auto on *.py |
| `react-best-practices.mdc` | React/TS rules (points to .agents/rules) | Auto on *.tsx, *.ts, *.jsx, *.js |
| `tlz-connection.mdc` | TLZ/aws/setup context | Globs (package.json, setup*.sh, etc.) |

## Installation

### Global (applies to all projects)

```bash
# Automated sync (recommended) — syncs .agents/commands ↔ .cursor/commands, then .cursor/* ↔ ~/.cursor/
cd ~/saski/augmentedcode-configuration
./sync-cursor-config.sh repo-to-global

# Or manual copy (ensure .cursor/commands exists; run sync once to create it from .agents/commands)
cp -r .cursor/commands/* ~/.cursor/commands/
cp -r .cursor/rules/* ~/.cursor/rules/

# Restart Cursor
```

### Configuration Sync

This repository maintains bidirectional sync with your global Cursor configuration (`~/.cursor/`). Use the sync script to keep them synchronized:

```bash
cd ~/saski/augmentedcode-configuration

# Sync both directions (default)
./sync-cursor-config.sh

# Or specify direction
./sync-cursor-config.sh repo-to-global   # Repository → Global
./sync-cursor-config.sh global-to-repo   # Global → Repository
```

See `.cursor/rules/cursor-config-management.mdc` for detailed sync workflow.

### Per-project

```bash
# Copy to your project
cp -r .cursor /path/to/your/project/
```

### For Other AI Tools

Canonical rules are in `.agents/rules/base.md`. To use them in Claude Code, Codex, or Gemini, create a symlink in your project root:

```bash
# Symlink for Claude Code
ln -s .agents/rules/base.md CLAUDE.md

# Optional: for Codex or Gemini
ln -s .agents/rules/base.md AGENTS.md
ln -s .agents/rules/base.md GEMINI.md
```

## Philosophy

These configurations enforce:

- **TDD**: Test-first, one failing test at a time
- **Baby Steps**: Small, incremental changes
- **Simple Design**: Clarity over cleverness
- **High Quality**: Strict validation before commits
- **Context Engineering**: Manage AI context effectively

## References

- [Context Engineering Article](https://nikeyes.github.io/tu-claude-md-no-funciona-sin-context-engineering-es/)
- [stepwise-dev Plugin](https://github.com/nikeyes/stepwise-dev)
- [Ashley Ha Workflow](https://medium.com/@ashleyha/i-mastered-the-claude-code-workflow-145d25e502cf)

## License

[Unlicense](https://unlicense.org) — Public Domain
