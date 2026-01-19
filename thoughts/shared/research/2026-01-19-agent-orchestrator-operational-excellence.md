---
date: 2026-01-19
researcher: saski
topic: "Agent Orchestrator for Operational Excellence and Tech OKRs"
tags: [research, agent-orchestrator, operational-excellence, okrs, fic-workflow]
status: complete
git_commit: 42521097f0f58c616ac4eb799ee7bec99c788049
branch: main
---

# Research: Agent Orchestrator for Operational Excellence and Tech OKRs

## Summary

The current project is **augmentedcode-configuration**, a repository containing reusable AI agent configurations for development workflows. The goal is to create an **agent orchestrator** that handles Operational Excellence duties and manages the team's Tech OKRs for 2025.

The project currently implements a **FIC (Frequent Intentional Compaction)** workflow system with commands, rules, and a thoughts management system. No orchestrator exists yet - this research documents what exists and what needs to be built.

## Project Structure

### Repository Overview

The project is located at `/Users/ignacio.viejo/saski/augmentedcode-configuration` and contains:

```
.
├── .agents/
│   ├── commands/          # Agent commands (FIC workflow, XP/TDD)
│   └── rules/             # Base rules for AI agents
├── .cursor/
│   ├── commands/          # Cursor IDE slash commands
│   └── rules/             # Cursor-specific rules
├── src/thoughts/          # Node/TypeScript CLI for thoughts management
├── thoughts/              # Research docs and plans (FIC workflow)
│   ├── shared/
│   │   ├── research/     # Research documents
│   │   └── plans/         # Implementation plans
│   └── saski/             # Personal notes
├── AGENTS.md              # Symlink to base.md
├── CLAUDE.md              # Symlink to base.md
├── GEMINI.md              # Symlink to base.md
└── README.md              # Project documentation
```

### Core Components

#### 1. FIC Workflow System

**Location**: `.cursor/commands/fic-*.md` and `.agents/commands/fic-*.md`

The FIC (Frequent Intentional Compaction) workflow is implemented through four main commands:

- **`fic-research`** (`1:96:.cursor/commands/fic-research.md`): Documents codebase comprehensively, saves to `thoughts/shared/research/`
- **`fic-create-plan`**: Creates detailed implementation plans iteratively
- **`fic-implement-plan`**: Executes plans phase by phase with verification
- **`fic-validate-plan`**: Verifies implementation against plan

**Purpose**: Solves the context management problem where LLMs lose attention after ~60% context usage by:
1. Research → Save to thoughts/ → Clear context
2. Plan → Save to thoughts/ → Clear context
3. Implement (phase by phase) → Clear between phases
4. Validate → Report

#### 2. Thoughts Management System

**Location**: `src/thoughts/src/`

A Node/TypeScript CLI for managing the `thoughts/` directory:

- **`index.ts`** (`1:58:src/thoughts/src/index.ts`): Main CLI entry point with commands:
  - `init`: Initialize thoughts/ directory structure
  - `sync`: Synchronize hardlinks in searchable/
  - `metadata`: Print git/project metadata for document frontmatter

- **`sync.ts`** (`1:188:src/thoughts/src/sync.ts`): Creates hardlinks in `thoughts/searchable/` for fast grep operations. Handles:
  - Finding all .md files in thoughts/
  - Creating hardlinks (or symlinks as fallback)
  - Cleaning up orphaned links
  - Removing empty directories

- **`metadata.ts`** (`1:101:src/thoughts/src/metadata.ts`): Generates git/project metadata including:
  - Date/time information (ISO, timezone-aware, short format)
  - Git commit hash, branch name, repository name
  - Git user name and email
  - Filename timestamps

**Directory Structure**:
```
thoughts/
├── {username}/          # Personal notes (e.g., saski/)
│   ├── tickets/        # Ticket documentation
│   └── notes/          # Personal notes
├── shared/             # Team-shared documents
│   ├── research/       # Research documents
│   ├── plans/          # Implementation plans
│   └── prs/            # PR descriptions
└── searchable/         # Hardlinks for fast grep (gitignored)
```

#### 3. Agent Commands

**Location**: `.agents/commands/` and `.cursor/commands/`

Two sets of commands exist (mirrored structure):

**FIC Workflow Commands**:
- `fic-research.md`
- `fic-create-plan.md`
- `fic-implement-plan.md`
- `fic-validate-plan.md`

**XP/TDD Commands** (xp-* prefix):
- `xp-code-review.md`
- `xp-increase-coverage.md`
- `xp-mikado-method.md`
- `xp-plan-untested-code.md`
- `xp-predict-problems.md`
- `xp-security-analysis.md`
- `xp-technical-debt.md`
- `xp-simple-design-refactor.md`
- `xp-refactor.md`

**Eventbrite-Specific Commands** (eb-* prefix):
- `eb-bug-fixing-agent.md`
- `eb-code-review.md`
- `eb-increase-coverage.md`
- `eb-mikado-method.md`
- `eb-plan-untested-code.md`
- `eb-predict-problems.md`
- `eb-security-analysis.md`
- `eb-technical-debt.md`

#### 4. Rules System

**Location**: `.agents/rules/` and `.cursor/rules/`

**Base Rules** (`1:243:.agents/rules/base.md`):
- Core XP/TDD principles
- Code quality and coverage requirements
- Test-driven development rules
- Makefile target usage
- Pre-commit validation requirements
- Language standards (English-only artifacts)
- Documentation standards

**Specialized Rules**:
- `ai-feedback-learning-loop.md`: AI feedback and rule refinement cycle
- `fic-workflow.mdc`: FIC context management
- `tdd-workflow.mdc`: TDD-specific rules
- `refactoring.mdc`: Safe refactoring
- `debugging.mdc`: Systematic debugging
- `python-dev.mdc`: Python-specific rules

#### 5. Workflows

**Location**: `.agent/workflows/`

**Context-Driven Development Workflow** (`1:51:.agent/workflows/context-driven-development.md`):
- Phase 1: Research (Mode: PLANNING)
- Phase 2: Plan (Mode: PLANNING)
- Phase 3: Implement (Mode: EXECUTION)
- Phase 4: Verify (Mode: VERIFICATION)

Uses `task_boundary` to define phases and `implementation_plan.md` / `walkthrough.md` for persistence.

## Current State: What Exists

### Existing Capabilities

1. **FIC Workflow Infrastructure**: Complete system for research → plan → implement → validate cycles
2. **Thoughts Management**: CLI tools for managing research and plan documents
3. **Agent Commands**: Multiple commands for code review, testing, refactoring, security analysis
4. **Rules System**: Comprehensive rules for XP/TDD practices
5. **Documentation**: Research documents and implementation plans in `thoughts/shared/`

### Existing Research Documents

Located in `thoughts/shared/research/`:

1. **`2025-12-15-stepwise-dev-analysis.md`**: Analysis of stepwise-dev plugin for Cursor adaptation
   - Documents 6 commands, 5 agents, 3 scripts
   - Parallel agent spawning patterns
   - Document frontmatter structure
   - Cursor adaptation considerations

2. **`2026-01-01-auto-improvement-mechanisms.md`**: Research on auto-improvement mechanisms

### Existing Plans

Located in `thoughts/shared/plans/`:

1. **`2026-01-01-activate-feedback-loop-cursor.md`**: Plan for activating feedback loop in Cursor

## Goal: Agent Orchestrator for Operational Excellence

### Objective

Create an **agent orchestrator** that:
1. Handles **Operational Excellence duties** of the team
2. Takes care of the team's **Tech OKRs** (2025 Listings Tech OKRs)

### Tech OKRs Reference

**Source**: https://eventbrite.atlassian.net/wiki/spaces/LT/pages/17253466113/Listings+Tech+OKRs+-+2025

**Status**: Could not access directly (requires authentication). The orchestrator should:
- Monitor and report on OKR progress and health
- Trigger required actions when key metrics are off-track
- Automate recurring operational tasks
- Manage escalation for incidents/deviations
- Ensure alignment between work execution and OKRs

### What Needs to Be Built

Based on operational excellence best practices and the current project structure:

#### 1. Orchestrator Core Components

**Data Collector**:
- Consume metrics from OKRs, system performance, ticket backlogs, incident logs
- Integration with Atlassian tools (Jira, Confluence) via MCP
- Real-time monitoring capabilities

**Evaluator / Rule Engine**:
- Encode policies: what "on track / off track" means
- Thresholds and SLA violation rules
- OKR progress evaluation logic

**Action Planner**:
- Determine steps to take (create ticket, notify team, escalate)
- Prioritize actions based on OKR impact
- Generate remediation plans

**Orchestration Agent**:
- Execute actions (possibly with human reviews)
- Coordinate between different systems
- Manage workflow state

**Dashboard & Reporting**:
- Real-time visibility
- Weekly OKR status reports
- Monthly Operational Excellence review

#### 2. Integration Points

**Atlassian MCP Integration**:
- Fetch current OKR status from Jira/Confluence
- Create/update issues when metrics deviate
- Summarize Confluence pages with team reports
- Security: OAuth, least privileges, audit logs

**Existing FIC Workflow Integration**:
- Use existing research/plan/implement/validate cycles
- Leverage thoughts/ directory for documentation
- Integrate with existing agent commands

**Monitoring & Observability**:
- Integration with logging/monitoring tools (Datadog, NewRelic, Grafana)
- System performance metrics
- Incident tracking

#### 3. Automation Capabilities

**Recurring Tasks**:
- Automated health checks
- Alert generation
- Dashboard updates
- Status report generation

**Incident Management**:
- Automatic ticket creation for deviations
- Escalation workflows
- Remediation task assignment

**OKR Tracking**:
- Progress monitoring
- Trend analysis
- Forecast generation
- Alignment verification

## Architecture Patterns

### Current Patterns

1. **Command-Based Architecture**: Commands are markdown files with instructions
2. **Rule-Based System**: Rules define behavior and constraints
3. **Document-Driven Workflow**: Research and plans stored in thoughts/
4. **CLI Tools**: Node/TypeScript CLI for thoughts management
5. **Symlink Structure**: Symlinks for multi-tool compatibility (AGENTS.md, CLAUDE.md, GEMINI.md)

### Orchestrator Design Considerations

1. **Leverage Existing Infrastructure**:
   - Use FIC workflow for orchestrator development itself
   - Store orchestrator research/plans in thoughts/
   - Follow existing command/rule patterns

2. **Integration Strategy**:
   - Atlassian MCP for OKR data
   - Existing agent commands for operational tasks
   - Thoughts CLI for documentation management

3. **Extensibility**:
   - Plugin architecture for new operational duties
   - Configurable rules engine
   - Modular component design

## Code References

### Key Files

- `README.md` (`1:174:README.md`): Project overview and FIC workflow documentation
- `AGENTS.md` → `.agents/rules/base.md`: Base rules for all AI agents
- `.agents/rules/base.md` (`1:243:.agents/rules/base.md`): Core development principles
- `.cursor/commands/fic-research.md` (`1:96:.cursor/commands/fic-research.md`): Research command template
- `.agent/workflows/context-driven-development.md` (`1:51:.agent/workflows/context-driven-development.md`): Development workflow
- `src/thoughts/src/index.ts` (`1:58:src/thoughts/src/index.ts`): Thoughts CLI entry point
- `src/thoughts/src/sync.ts` (`1:188:src/thoughts/src/sync.ts`): Thoughts sync implementation
- `src/thoughts/src/metadata.ts` (`1:101:src/thoughts/src/metadata.ts`): Metadata generation
- `thoughts/shared/research/2025-12-15-stepwise-dev-analysis.md`: Stepwise-dev analysis

## Open Questions

1. **OKR Details**: What are the specific 2025 Listings Tech OKRs? (Requires Atlassian access)
2. **Operational Excellence Scope**: What specific duties are included? (Incident response, reliability, cost optimization, performance, tooling?)
3. **Integration Requirements**: What systems need to be integrated? (Atlassian, monitoring tools, CI/CD, etc.)
4. **Automation Level**: What level of automation is desired? (Full automation vs. human-in-the-loop)
5. **Stakeholders**: Who are the stakeholders and what are their needs?
6. **Timeline**: What is the target timeline for orchestrator implementation?
7. **Technology Stack**: What technology stack should be used? (Python, TypeScript, other?)
8. **Deployment**: Where will the orchestrator run? (Local, cloud, containerized?)

## Next Steps

1. **Access OKRs**: Obtain access to the 2025 Listings Tech OKRs document
2. **Define Scope**: Clarify Operational Excellence duties and priorities
3. **Create Implementation Plan**: Use `/fic-create-plan` to create detailed implementation plan
4. **Design Architecture**: Design orchestrator components and integration points
5. **Build MVP**: Start with minimal orchestrator covering 1-2 OKRs
6. **Iterate**: Expand coverage based on feedback and requirements

## Related Research

- `thoughts/shared/research/2025-12-15-stepwise-dev-analysis.md`: FIC workflow and agent patterns
- `thoughts/shared/research/2026-01-01-auto-improvement-mechanisms.md`: Auto-improvement patterns
