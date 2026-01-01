# Augmented Code Configuration

Reusable AI agent configurations for development workflows. Designed for XP/TDD practitioners who want consistent, high-quality AI assistance.

## Repository Structure

```text
.
├── .agents/rules/
│   └── base.md                 # 📌 Single source of truth for all AI rules
├── .cursor/
│   ├── commands/               # Slash commands (Cursor IDE)
│   │   ├── fic-*.md            # FIC workflow commands
│   │   └── plt-*.md            # XP/TDD commands
│   └── rules/                  # Cursor rules
│       ├── base.mdc            # Core XP/TDD principles
│       ├── fic-workflow.mdc    # FIC context management
│       └── *.mdc               # Specialized rules
├── src/thoughts/               # Node/TS CLI for thoughts/ management
├── thoughts/                   # Research docs and plans (FIC workflow)
├── AGENTS.md → base.md         # Symlink for OpenAI Codex
├── CLAUDE.md → base.md         # Symlink for Claude
└── GEMINI.md → base.md         # Symlink for Gemini
```

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

Persistent storage for research and plans (tracked in git):

```text
thoughts/
├── {username}/          # Personal notes (you write)
│   ├── tickets/
│   └── notes/
├── shared/              # Team-shared (AI writes, tracked in git)
│   ├── research/        # Research documents (e.g., auto-improvement mechanisms)
│   ├── plans/           # Implementation plans (e.g., feedback loop activation)
│   └── prs/             # PR descriptions
└── searchable/          # Hardlinks for fast grep (gitignored)
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

| Command | Purpose |
|---------|---------|
| `/code-review` | Review pending changes (tests, maintainability, rules) |
| `/increase-coverage` | Identify and test high-value untested code |
| `/plan-untested-code` | Create actionable plan to cover untested code |
| `/predict-problems` | Predict likely production failures |
| `/mikado-method` | Guide safe, incremental refactoring |
| `/technical-debt` | Catalog and prioritize technical debt |
| `/xp-refactor` | Apply XP Simple Design principles |
| `/security-analysis` | Pragmatic security risk analysis |

## Cursor Rules

| Rule | Purpose | Activation |
|------|---------|------------|
| `base.mdc` | Core XP/TDD principles | Always active |
| `ai-feedback-learning-loop.mdc` | AI feedback and rule refinement cycle | Always active |
| `fic-workflow.mdc` | FIC context management | Manual |
| `tdd-workflow.mdc` | TDD-specific rules | Manual |
| `refactoring.mdc` | Safe refactoring | Manual |
| `debugging.mdc` | Systematic debugging | Manual |
| `python-dev.mdc` | Python-specific | Auto on *.py |

## Installation

### Global (applies to all projects)

```bash
# Automated sync (recommended)
cd ~/saski/augmentedcode-configuration
./sync-cursor-config.sh repo-to-global

# Or manual copy
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

```bash
# Symlink for Claude Code
ln -s .agents/rules/base.md CLAUDE.md
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
