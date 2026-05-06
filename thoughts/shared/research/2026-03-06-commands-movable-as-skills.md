---
date: 2026-03-06
researcher: agent
topic: "Which .cursor/commands can be moved as skills"
tags: [research, cursor, commands, skills, fic, xp, eb]
status: complete
---

# Research: Commands movable as skills

## Summary

There are **16 command files** in `.cursor/commands/`. Whether each should stay a command or become a skill depends on **how it is used**: commands are **explicitly invoked** workflows (user runs `/name`); skills are **trigger-based** knowledge the agent applies when it detects a scenario. **FIC and EB orchestration commands** (fixed paths, phases, completion messages) should stay as commands. **XP and expertise-style commands** (persona + task, no fixed artifacts) are strong candidates to move as skills so the agent can apply them when the user asks for refactoring, tech debt, security review, or test coverage without requiring a slash command.

## Distinction: Command vs skill

| Aspect | Command | Skill |
|--------|---------|--------|
| **Invocation** | User runs `/command-name` (explicit) | Agent applies when description/triggers match (implicit or “use when…”) |
| **Content** | Multi-step procedure, often with $ARGUMENTS | Domain knowledge + when to use it |
| **Outputs** | Often fixed (e.g. `thoughts/shared/research/YYYY-MM-DD-topic.md`) | Open-ended (answer, suggest, apply behavior) |
| **Reference** | [create-skill SKILL.md](.cursor/skills-cursor/create-skill/SKILL.md): skills teach “how to perform specific tasks”; description drives “when to apply” |

**Source**: Commands live in `~/.cursor/commands/` (symlinked from `augmentedcode-configuration/.cursor/commands/`). Skills live in **`.agents/skills/*/SKILL.md`** (canonical); `~/.cursor/skills` is a symlink to the repo `.agents/skills/`. Each skill has frontmatter `name` and `description`; the description is used for trigger-based application.

## Inventory of commands

All paths below are under `.cursor/commands/` (repo: `saski/augmentedcode-configuration`).

### FIC workflow (4 commands)

| File | Purpose | Movable as skill? |
|------|---------|-------------------|
| `fic-research.md` | Research codebase, write `thoughts/shared/research/YYYY-MM-DD-topic.md`, no suggestions | **No** |
| `fic-create-plan.md` | Interactive plan creation, save to `thoughts/shared/plans/YYYY-MM-DD-topic.md`, 5-step process | **No** |
| `fic-validate-plan.md` | Validate implementation vs plan, report format | **No** |
| `fic-implement-plan.md` | Execute plan phase-by-phase, update plan checkboxes, context management | **No** |

**Why keep as commands**: Defined workflow with fixed paths (`thoughts/shared/research/`, `thoughts/shared/plans/`), numbered phases, completion messages, and explicit “run this flow” intent. User chooses “research” or “plan” or “implement” by invoking the command.

### EB (Eventbrite) workflow (3 commands)

| File | Purpose | Movable as skill? |
|------|---------|-------------------|
| `eb-review-pr.md` | Full PR review: checkout, analyze, file-by-file walkthrough, post comments via `gh`, metrics (`.pr-review-metrics.json`) | **No** |
| `eb-install-command.md` | Install/customize commands from templates (scan templates, repo discovery, write to `.cursor/commands/`) | **No** |
| `eb-bug-fixing-agent.md` | Bug fix from Jira: setup → plan → act modes, structured deliverables, confidence % | **Partial** |

**Why keep as commands**:
- **eb-review-pr**: Long, interactive, phase-based (Phase 0–8), uses `gh` and file paths; user explicitly starts “review PR 123”.
- **eb-install-command**: One-off installer; not “when to apply” knowledge.
- **eb-bug-fixing-agent**: The *expertise* (OWASP, threat modeling, confidence, deliverable structure) could be a skill (“when user asks to fix a bug from Jira…”); the *strict mode switching* (setup/plan/act) is command-like. So: expertise and structure → good skill candidate; orchestration can stay command or be simplified.

### XP / expertise-style (9 commands)

| File | Purpose | Movable as skill? |
|------|---------|-------------------|
| `xp-technical-debt.md` | Catalog/classify/prioritize tech debt; top 5, quick wins, strategic debt | **Yes** |
| `xp-simple-design-refactor.md` | Apply XP Simple Design; analyze, prioritize by ROI, implement one refactor | **Yes** |
| `xp-security-analysis.md` | Security expert: risks, scenarios, mitigations, defensive practices | **Yes** |
| `xp-refactor.md` | Same as xp-simple-design-refactor (duplicate) | **Yes** |
| `xp-predict-problems.md` | Predict production failures; high-risk paths, edge cases | **Yes** |
| `xp-plan-untested-code.md` | Plan tests for untested code; gaps, prioritize, design tests, iterate | **Yes** |
| `xp-mikado-method.md` | Mikado Method: goal, naive attempt, graph, leaf nodes, execution order | **Yes** |
| `xp-increase-coverage.md` | Run coverage, write one focused test, explain why it matters | **Yes** |
| `xp-code-review.md` | Review pending changes: tests, maintainability, project rules, risk | **Yes** |

**Why movable as skills**: No fixed file paths or multi-phase orchestration. They define **persona + task** (“Act as Senior XP Developer / Security Expert and do X”). The agent could apply the same behavior when the user says “what’s our tech debt?”, “review this for maintainability”, “help me refactor safely”, “security review”, “add tests for this”, or “review my uncommitted changes”. Moving them to skills with clear descriptions (e.g. “Use when user asks for technical debt analysis or prioritization”) makes them trigger-based instead of requiring `/xp-technical-debt`.

## Detailed findings

### FIC commands ([fic-research.md](.cursor/commands/fic-research.md), [fic-create-plan.md](.cursor/commands/fic-create-plan.md), [fic-validate-plan.md](.cursor/commands/fic-validate-plan.md), [fic-implement-plan.md](.cursor/commands/fic-implement-plan.md))

- **fic-research**: Research query in `$ARGUMENTS`; save to `thoughts/shared/research/YYYY-MM-DD-topic.md` with fixed frontmatter and sections; completion message references `/fic-create-plan`. Tight coupling to path and next command.
- **fic-create-plan**: Reads research or task; interactive steps (context → research → design options → plan structure → write); saves to `thoughts/shared/plans/YYYY-MM-DD-topic.md` with a defined template.
- **fic-validate-plan**: Takes plan path; runs git/checks; produces validation report in a fixed format.
- **fic-implement-plan**: Takes plan path; phase-by-phase implementation; updates plan checkboxes; context management and completion message.

All depend on specific artifact paths and sequential flow → keep as commands.

### EB commands

- **eb-review-pr** ([eb-review-pr.md](.cursor/commands/eb-review-pr.md)): Phases 0–8, `gh` usage, `.pr-review-metrics.json`, interactive “next/comment/fix this”. Explicit “I’m reviewing PR X” → keep as command.
- **eb-install-command** ([eb-install-command.md](.cursor/commands/eb-install-command.md)): Template scan, repo detection, variable substitution, writes to `.cursor/commands/` and scripts. Setup action, not scenario-based knowledge → keep as command.
- **eb-bug-fixing-agent** ([eb-bug-fixing-agent.md](.cursor/commands/eb-bug-fixing-agent.md)): Setup/plan/act modes; Jira URL; deliverables (Issue Summary, Context, Impacted Files, Suspected Cause, Proposed Fix, Estimated Time, Owners). The *method and deliverables* could be a skill; the *mode gates* could remain in a lighter command or be dropped so the skill drives the flow.

### XP commands (all under [.cursor/commands/](.cursor/commands/))

- Short (≈20–45 lines). No `$ARGUMENTS`, no fixed output paths.
- Pattern: “Act as Senior XP Developer / Security Expert” + task list + deliverables (e.g. “Top 5 debt items”, “Mikado graph”, “structured review”).
- **xp-refactor.md** and **xp-simple-design-refactor.md** are effectively the same content.

If converted to skills:

- **name**: e.g. `xp-technical-debt`, `xp-mikado-method`, `xp-security-analysis`.
- **description**: Include trigger phrases, e.g. “Use when user asks for technical debt analysis, prioritization, or quick wins” / “Use when user wants to refactor safely with the Mikado Method” / “Use when user asks for security review or risk analysis”.
- Body: Keep the current “Task” and “Deliverables” (and for Mikado, the core loop) so the agent applies the same behavior when the scenario matches.

## Code references

- `.cursor/commands/fic-research.md` — Research process and output path
- `.cursor/commands/fic-create-plan.md` — Plan template and phases
- `.cursor/commands/fic-validate-plan.md` — Validation steps and report format
- `.cursor/commands/fic-implement-plan.md` — Phase-by-phase execution and context rules
- `.cursor/commands/eb-review-pr.md` — PR review phases and `gh` usage
- `.cursor/commands/eb-install-command.md` — Template variables and install flow
- `.cursor/commands/eb-bug-fixing-agent.md` — Setup/plan/act and deliverables
- `.cursor/commands/xp-*.md` — All 9 XP/expertise commands
- `.cursor/skills-cursor/create-skill/SKILL.md` — Skill format and description/triggers
- `.cursor/skills-cursor/migrate-to-skills/SKILL.md` — Converting commands to SKILL.md (with `disable-model-invocation: true` for explicit-only)

## Architecture

- **Commands**: User-initiated, often with arguments; can define phases, file paths, and completion messages. Stored in `.cursor/commands/*.md`.
- **Skills**: SKILL.md with `name` and `description`; agent uses description to apply when relevant. Optional `disable-model-invocation: true` keeps “slash-only” behavior after migration (see migrate-to-skills).
- **Existing migration path**: The migrate-to-skills skill converts any command to a skill and sets `disable-model-invocation: true` so the model does not auto-invoke it—i.e. it stays slash-triggered. The *choice* of which commands to move “as skills” in the sense of *trigger-based* use is separate: for those (e.g. XP set), do **not** set `disable-model-invocation: true` so the agent can apply them when the user’s request matches the description.

## Recommendation summary

| Category | Count | Action |
|----------|--------|--------|
| **Keep as commands** | 10 | FIC (4), eb-review-pr, eb-install-command; optionally keep eb-bug-fixing-agent as command and extract expertise to a skill |
| **Move as skills (trigger-based)** | 9 | All xp-* (merge xp-refactor / xp-simple-design-refactor into one skill) |
| **Partial** | 1 | eb-bug-fixing-agent: skill for bug-fix expertise + deliverables; command optional for mode orchestration |

## Open questions

- Whether to keep a thin “bug-fix workflow” command that invokes the new bug-fix skill with Jira URL and modes, or rely entirely on the skill when the user says “fix this Jira bug”.
- Where XP skills should live: **resolved** — canonical location is **`.agents/skills/`** in augmentedcode-configuration; `~/.cursor/skills` and other tools’ `skills` dirs symlink to it for sharing.
