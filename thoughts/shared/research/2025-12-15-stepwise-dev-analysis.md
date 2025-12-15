---
date: 2025-12-15
researcher: saski
topic: "stepwise-dev plugin analysis for Cursor adaptation"
tags: [research, context-engineering, fic-workflow, cursor-adaptation]
status: complete
---

# Research: stepwise-dev Plugin Analysis for Cursor Adaptation

## Summary

The `stepwise-dev` plugin implements the **FIC (Frequent Intentional Compaction)** workflow for Claude Code. It solves the context management problem where LLMs lose attention after ~60% context usage. The plugin provides 6 commands, 5 specialized agents, and a thoughts management system.

## Core Concepts

### FIC Workflow
1. **Research** → Document codebase comprehensively
2. **Plan** → Create detailed implementation plans iteratively
3. **Implement** → Execute plans phase by phase
4. **Validate** → Verify implementation against plan

**Key principle**: Clear context (`/clear`) between phases, persist knowledge to `thoughts/` directory.

### thoughts/ Directory Structure
```
thoughts/
├── {username}/          # Personal notes
│   ├── tickets/        # Ticket documentation
│   └── notes/          # Personal notes
├── shared/             # Team-shared documents
│   ├── research/       # Research documents
│   ├── plans/          # Implementation plans
│   └── prs/            # PR descriptions
└── searchable/         # Hardlinks for fast grep
```

## Plugin Components

### Commands (6 total)

| Command | Purpose | Key Features |
|---------|---------|--------------|
| `research_codebase` | Document codebase as-is | Spawns parallel agents, saves to `thoughts/shared/research/` |
| `create_plan` | Create implementation plans | Interactive iteration, phased approach, success criteria |
| `iterate_plan` | Update existing plans | Modify plans based on feedback |
| `implement_plan` | Execute plans | Phase-by-phase, automated+manual verification |
| `validate_plan` | Verify implementation | Compare code to plan, generate validation report |
| `commit` | Create git commits | Atomic commits without Claude attribution |

### Agents (5 total)

| Agent | Purpose | Tools |
|-------|---------|-------|
| `codebase-locator` | Find WHERE code lives | Grep, Glob, LS |
| `codebase-analyzer` | Understand HOW code works | Read, Grep, Glob, LS |
| `codebase-pattern-finder` | Find similar patterns/examples | Grep, Glob, Read, LS |
| `thoughts-locator` | Find documents in thoughts/ | Grep, Glob, LS |
| `thoughts-analyzer` | Extract insights from docs | Read, Grep, Glob, LS |

### Scripts (3 total)

| Script | Purpose |
|--------|---------|
| `thoughts-init` | Initialize thoughts/ directory structure |
| `thoughts-sync` | Sync hardlinks in searchable/ |
| `thoughts-metadata` | Generate git metadata for frontmatter |

## Key Design Patterns

### Parallel Agent Spawning
Commands spawn multiple agents concurrently for efficiency:
```
Task 1: codebase-locator → Find files
Task 2: codebase-analyzer → Understand implementation
Task 3: thoughts-locator → Find historical context
```
Wait for all tasks, then synthesize.

### Document Frontmatter
All documents include YAML frontmatter with:
- Date, researcher, git_commit, branch
- Topic, tags, status
- last_updated, last_updated_by

### Success Criteria Pattern
Plans distinguish between:
- **Automated Verification**: `make test`, `make lint`, etc.
- **Manual Verification**: Only for subjective qualities (UI aesthetics)

### Critical Ordering
1. Read mentioned files FIRST before spawning agents
2. Wait for ALL agents to complete before synthesizing
3. Gather metadata BEFORE writing documents
4. Sync after creating/modifying documents

## Cursor Adaptation Considerations

### What Cursor Has
- Commands: `.cursor/commands/*.md` - Simple prompts
- Rules: `.cursor/rules/*.mdc` - Context guidelines
- No native agent spawning or skill system

### Adaptation Strategy
1. **Commands** → Convert to Cursor command format (simplified)
2. **Agents** → Embed as detailed instructions within commands OR separate commands
3. **Rules** → Create FIC workflow rule with phase guidance
4. **Scripts** → Port to Node/TS for cross-platform support
5. **thoughts/ management** → Can work as-is (filesystem operations)

### Key Differences
| Claude Code | Cursor |
|-------------|--------|
| `Task` tool spawns agents | No parallel agent spawning |
| Agents have specific tools | All tools available |
| Skills with bash scripts | Custom scripts via terminal |
| Plugin marketplace | Manual file management |

### Proposed Cursor Structure
```
.cursor/
├── commands/
│   ├── fic-research.md
│   ├── fic-create-plan.md
│   ├── fic-implement-plan.md
│   └── fic-validate-plan.md
├── rules/
│   └── fic-workflow.mdc
src/
├── thoughts/
│   ├── init.ts
│   ├── sync.ts
│   └── metadata.ts
└── package.json
```

## Implementation Priority

1. **High**: Core commands (research, plan, implement, validate)
2. **High**: thoughts/ directory management
3. **Medium**: FIC workflow rule
4. **Low**: Full agent behavior (simplified in Cursor)

## References

- [Original Article](https://nikeyes.github.io/tu-claude-md-no-funciona-sin-context-engineering-es/)
- [stepwise-dev GitHub](https://github.com/nikeyes/stepwise-dev)
- [Ashley Ha Workflow](https://medium.com/@ashleyha/i-mastered-the-claude-code-workflow-145d25e502cf)
- [HumanLayer FIC](https://github.com/humanlayer/humanlayer)

