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
│   ├── skills/                 # Shared skills (XP + others); symlinked by all tools
│   │   ├── xp-*/
│   │   ├── test-doubles-first/
│   │   ├── cwv-improvement-planner/
│   │   └── team-ownership/
│   └── commands/               # Slash commands (FIC, EB; synced to .cursor/commands)
│       ├── fic-*.md
│       └── eb-bug-fixing-agent.md
├── .cursor/
│   ├── rules/                  # Cursor rules (.mdc); reference .agents/rules where applicable
│   │   ├── use-base-rules.mdc
│   │   ├── ai-feedback-learning-loop.mdc
│   │   ├── cursor-config-management.mdc
│   │   ├── project-status-maintenance.mdc
│   │   ├── fic-workflow.mdc
│   │   ├── tdd-workflow.mdc
│   │   ├── refactoring.mdc
│   │   ├── debugging.mdc
│   │   ├── python-dev.mdc
│   │   ├── react-best-practices.mdc
│   │   └── tlz-connection.mdc
│   └── skills/                 # Symlink → repo .agents/skills/
├── src/thoughts/               # Node/TS CLI for thoughts/ management
├── thoughts/                   # Research and plans (see thoughts/ tree below)
├── setup-symlinks.sh           # Setup/validate symlinks; commit config changes
└── (optional) AGENTS.md / CLAUDE.md / GEMINI.md → .agents/rules/base.md
```

## Configuration Management

### Architecture

This repository is the **single source of truth** for AI tool configuration. Configuration is shared via symlinks:

**Symlink structure:**
```text
~/.cursor/rules     → ~/saski/augmentedcode-configuration/.cursor/rules/
~/.cursor/commands  → ~/saski/augmentedcode-configuration/.cursor/commands/
~/.cursor/skills    → ~/saski/augmentedcode-configuration/.agents/skills/
~/.cursor/.agents   → ~/saski/augmentedcode-configuration/.agents/
~/.codex/skills     → ~/saski/augmentedcode-configuration/.agents/skills/   (if using Codex)
~/.antigravity/skills → ~/saski/augmentedcode-configuration/.agents/skills/ (if using Antigravity)
~/.claude/          → ~/saski/augmentedcode-configuration/.claude/
~/CLAUDE.md         → ~/saski/augmentedcode-configuration/CLAUDE.md
~/AGENTS.md         → ~/saski/augmentedcode-configuration/AGENTS.md
~/GEMINI.md         → ~/saski/augmentedcode-configuration/GEMINI.md
```

Shared skills live in **`.agents/skills/`** (canonical). Cursor and other dev tools (Codex, Antigravity, etc.) point their `skills` directory at this repo path so all tools use the same XP and project skills.

### Setup on New Machine

```bash
cd ~/saski/augmentedcode-configuration
./setup-symlinks.sh setup
```

### Verifying Configuration

```bash
# Validate all symlinks are correct
./setup-symlinks.sh validate

# Check for uncommitted changes
./setup-symlinks.sh status
```

### Making Changes

All configuration edits (in Cursor, VS Code, or any editor) automatically modify the repository files. Commit changes with:

```bash
./setup-symlinks.sh commit
```

### Troubleshooting

**Symlinks broken**: Run `./setup-symlinks.sh setup` to recreate  
**Config not loading**: Run `./setup-symlinks.sh validate` to diagnose  
**Restore backup**: See `~/.cursor-backups/` for timestamped backups

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

## XP Skills

XP behaviors are provided as **trigger-based skills** under `.agents/skills/`. They are applied when the user's request matches the skill description (e.g. "technical debt", "code review", "Mikado Method"). All tools (Cursor, Codex, Antigravity, etc.) resolve skills from repo `.agents/skills/` via symlinks (e.g. `~/.cursor/skills` → repo `.agents/skills/`).

| Skill | Purpose |
|-------|---------|
| `xp-code-review` | Review pending changes (tests, maintainability, project rules) |
| `xp-increase-coverage` | Identify and test high-value untested code |
| `xp-plan-untested-code` | Create actionable plan to cover untested code and coverage gaps |
| `xp-predict-problems` | Predict likely production failures and edge cases |
| `xp-mikado-method` | Guide safe refactoring via dependency graph (Mikado Method) |
| `xp-technical-debt` | Catalog and prioritize technical debt; quick wins, strategic debt |
| `xp-simple-design-refactor` | Maintainability & Simple Design refactoring with ROI focus |
| `xp-security-analysis` | Pragmatic security risk analysis (OWASP, threat modeling) |

## Eventbrite-Specific Commands

Eventbrite-specific commands use the `eb-` prefix.

| Command | Purpose |
|---------|---------|
| `/eb-bug-fixing-agent` | Eventbrite bug fixing expert with OWASP, threat modeling, cloud security |

## Cursor Skills (from `.agents/skills/`)

Reusable project-level skills live in **`.agents/skills/`** and are exposed to Cursor via `~/.cursor/skills` → repo `.agents/skills/`. They are applied when user prompts match the skill description (trigger-based).

| Skill | Purpose |
|-------|---------|
| `test-doubles-first` | Choose the lightest effective test double, preferring fake/stub/spy before mock. |
| `cwv-improvement-planner` | Create prioritized Core Web Vitals plans for LCP/INP/TTFB, including edge caching/compression and safe experimentation. |
| `team-ownership` | Determine owning team for reported issues using ownership sources and confidence-based routing. |

## Cursor Rules

Development rules live in `.agents/rules/` (canonical). Cursor rules in `.cursor/rules/` point to them or add Cursor-specific behavior.

| Rule | Purpose | Activation |
|------|---------|------------|
| `use-base-rules.mdc` | Use `.agents/rules/base.md` as development rulebook | Always active |
| `ai-feedback-learning-loop.mdc` | Points to `.agents/rules/ai-feedback-learning-loop.md` | Always active |
| `cursor-config-management.mdc` | Symlink setup and config workflow | Always active |
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
cd ~/saski/augmentedcode-configuration
./setup-symlinks.sh setup

# Restart Cursor
```

See **Configuration Management** above and `.cursor/rules/cursor-config-management.mdc` for symlink workflow.

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
