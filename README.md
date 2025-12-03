# Augmented Code Configuration

Reusable AI agent configurations for development workflows. Designed for XP/TDD practitioners who want consistent, high-quality AI assistance.

## Repository Structure

```
.
├── .agents/rules/
│   └── base.md             # 📌 Single source of truth for all AI rules
├── .cursor/
│   ├── commands/           # Slash commands (Cursor IDE)
│   └── rules/              # Rule that references base.md
├── AGENTS.md → base.md     # Symlink for OpenAI Codex
├── CLAUDE.md → base.md     # Symlink for Claude
└── GEMINI.md → base.md     # Symlink for Gemini
```

### Key Concept

**One ruleset, multiple entry points.** All AI agents use the same rules defined in `.agents/rules/base.md`. The symlinks (AGENTS.md, CLAUDE.md, GEMINI.md) allow each tool to find the rules in its expected location.

## Available Commands

Cursor IDE slash commands. Copy to `.cursor/commands/` or adapt for other tools:

| Command | Purpose |
|---------|---------|
| `plt-code-review` | Review pending changes (tests, maintainability, rules) |
| `plt-increase-coverage` | Identify and test high-value untested code |
| `plt-plan-untested-code` | Create actionable plan to cover untested code |
| `plt-predict-problems` | Predict likely production failures |
| `plt-mikado-method` | Guide safe, incremental refactoring |
| `plt-technical-debt` | Catalog and prioritize technical debt |
| `plt-xp-simple-design-refactor` | Apply XP Simple Design principles |
| `plt-security-analysis` | Pragmatic security risk analysis |

## Usage

### For Cursor IDE

```bash
# Copy commands and rules
cp -r .cursor /path/to/your/project/
```

### For Other AI Tools

Copy the appropriate symlink or create one pointing to `base.md`:

```bash
# Example: for Claude
ln -s .agents/rules/base.md CLAUDE.md
```

## Philosophy

These configurations enforce:
- **TDD**: Test-first, one failing test at a time
- **Baby Steps**: Small, incremental changes
- **Simple Design**: Clarity over cleverness
- **High Quality**: Strict validation before commits

## License

[Unlicense](https://unlicense.org) — Public Domain
