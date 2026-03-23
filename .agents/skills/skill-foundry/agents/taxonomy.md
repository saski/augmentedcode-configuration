# Skill taxonomy

This taxonomy is designed for cross-platform skill libraries that use the Agent Skills format.

## Categories

### artifact-creation
Skills that create a concrete output artifact such as a document, slide deck, email, page, report, or template.

### workflow-automation
Skills that execute or coordinate a repeatable multi-step process.

### tool-reference
Skills that encode best practices, conventions, and gotchas for a specific tool, SDK, framework, CLI, or API.

### verification-testing
Skills that verify behavior, review outputs, run checks, or enforce a rubric.

### data-analysis
Skills that interpret data, summarize evidence, compare cohorts, or produce insight from structured inputs.

### connector-enhancement
Skills that improve how an agent works with connected tools, data sources, or MCP-style integrations.

### team-process
Skills for internal rituals and operational flows such as onboarding, incident review, release checklists, planning, or retrospectives.

### skill-governance
Meta-skills that create, organize, evaluate, benchmark, audit, and retire other skills.

## Patterns

### tool-wrapper
Use when the skill primarily teaches the agent how to use one tool or framework well.

### generator
Use when the skill’s core value is generating a structured artifact consistently.

### reviewer
Use when the skill critiques, validates, scores, or verifies an output.

### inversion
Use when the skill should gather requirements or diagnose missing information before solving the main problem.

### pipeline
Use when the skill must follow explicit stages or gates.

## Governance guidance

Each shared skill should track:
- owner
- category
- pattern
- lifecycle status
- supported platforms
- review cycle
- overlap warnings
- last reviewed date
- benchmark requirement after model updates
