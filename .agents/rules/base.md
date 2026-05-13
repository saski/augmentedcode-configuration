<!-- last_updated: 2026-05-07 -->
<!-- version: 2.5 -->
# AI Agent Development Rules

This document contains the universal development rules and guidelines for this project, applicable to all AI agents (Claude, Gemini, Codex, and others).

## 1. Core Principles

- **Baby Steps**: Always work in baby steps, one at a time. Never go forward more than one step.
- **Test-Driven Development**: Start with a failing test for any new functionality.
- **Progressive Revelation**: Never show all the code at once; only the next step.
- **Type Safety**: Keep code fully typed where the language supports it.
- **Simplicity First**: Use the simplest working solution; avoid unnecessary abstractions.
- **Small Components**: Keep classes and methods small and focused.
- **Clear Naming**: Use clear, descriptive names for all variables and functions.
- **Incremental Changes**: Prefer incremental, focused changes over large, complex modifications.
- **Question Assumptions**: Always question assumptions and inferences.
- **Refactoring Awareness**: Highlight opportunities for refactoring and flag functions that are getting too large.
- **Pattern Detection**: Detect and highlight repeated code patterns.

## 2. Contextual Rule Loading

- When the repo contains Python source or Python project markers, also read `.agents/rules/pyth![[REDIS_AUTH_REMEDIATION_HANDOFF]]on-project.md` if that file exists in the current repository.
- When the repo contains a `Makefile`, also read `.agents/rules/makefile-project.md` if that file exists in the current repository.
- If a contextual rule file is referenced by this section but is not present in the current repository, treat it as optional, note that it is missing, and continue with the applicable rules that are available.
- These contextual rules extend, not replace, the universal rules in this file.

## 3. Code Quality & Coverage

- Maintain strong code quality and maintainability standards.
- Keep test coverage high, aiming for comprehensive coverage where practical.
- Validate important changes with the repository's canonical automated checks before merging.
- Prefer the smallest change that solves the problem cleanly.

## 4. Style Guidelines

- **Clear Communication**: Use direct, concise, professional language.
- **Progressive Building**: Explain decisions step by step when helpful.
- **Avoid Rushing**: Reassess assumptions before concluding.
- **Seek Clarification**: If requirements are ambiguous, ask one focused question.
- **Self-Documenting Code**: Avoid comments in code; rely on self-documenting names.

## 5. Output Format Requirements

- **Answer Structure**: Provide a concise outcome first, then supporting detail as needed.
- **No Hidden-Reasoning Formats**: Do not require internal-monologue or chain-of-thought sections.
- **No Moralizing**: Never include moralizing warnings.
- **Progress Indicators**: When outlining plans, use numbered progress steps.
- **Run Metadata (On Request Only)**: Do not append metadata blocks to responses by default. Include run metadata only when the user explicitly requests it.
  - When requested, keep the block short and include: `Tool`, `Mode`, `Model ID`, `Model Source`, `Task Type`, `Confidence`, and `Verification`.

## 6. Process & Key Requirements

- **Evidence First**: Validate important assumptions with code, tests, or docs.
- **Persistence**: Persist through multiple attempts until resolution.
- **Thorough Iteration**: Break complex changes into incremental steps.
- **Sequential Questions**: Only one question at a time; each question should build on previous answers.
- **Workspace-Aware GitHub SSH And CLI Auth**: Before suggesting or running GitHub SSH commands (`git clone`, `git fetch`, `git pull`, `git push`, `git remote add`, `git remote set-url`), choose the SSH host alias from the local workspace path. Use `git@github.com-eventbrite:` for repositories under `~/eventbrite/*` and `git@github.com-saski:` for repositories under `~/saski/*`. Never use bare `git@github.com:` in this environment. Treat `github.com-eventbrite` and `github.com-saski` as SSH routing only; do not use `gh auth login` to pick between them. Only suggest `gh auth login` when GitHub CLI API auth is actually needed. Before suggesting `gh auth login`, check whether `GITHUB_TOKEN` is set. If stored interactive login is required, run `env -u GITHUB_TOKEN gh auth login` or unset `GITHUB_TOKEN` in that shell first, because `gh` will otherwise authenticate from the environment variable instead of storing credentials. Verify CLI auth with `gh auth status`. If the correct alias or credential source is unclear, load the `github-host-alias` skill and verify against `~/.ssh/config` and the active shell environment.

## 7. Mental Preparation

- **Think Before Acting**: Confirm goal, constraints, and risks before making changes.

## 8. Language Standards

- **Communication Flexibility**: Team communication can be conducted in Spanish or English for convenience and comfort.
- **English-Only Artifacts**: All technical artifacts must always use English, including code, documentation, tickets, schemas, configuration, scripts, git commit messages, and test names.
- **Professional Consistency**: This ensures global collaboration, tool compatibility, and industry best practices.

## 9. Documentation Standards

- **User-Focused README**: README.md must be user-focused, containing only information relevant to end users.
- **Separate Dev Docs**: All developer, CI, and infrastructure documentation must be placed in a separate development guide, with a clear link from the README.
- **Error Examples**: User-facing documentation should include example error messages for common validation failures to help users quickly resolve issues.
- **README Maintenance**: When making changes to this repository that affect its structure, features, or usage, the README.md must be updated accordingly.
- **Rules Maintenance**: Keep the rules updated with every learning for each of the interactions, after satisfactorily completing every task. Follow the guidelines in [ai-feedback-learning-loop.md](.agents/rules/ai-feedback-learning-loop.md).

## 10. Skills (Canonical Location and Use)

- **Canonical location**: Shared skills live in `.agents/skills/` in this repository, one directory per skill with at least `SKILL.md`.
- **Sources**: Skills in `.agents/skills/` may be native, synced from [skill-factory](https://github.com/saski/skill-factory), or synced from other packages (e.g. product-management skills; see `skills-lock.json`).
- **Discovery index**: Use [.agents/docs/skill-factory-skills.md](.agents/docs/skill-factory-skills.md) to match user requests to skills before reading the skill's `SKILL.md`. Product-management entries use skill-foundry governance in [.agents/skills/skill-foundry/agents/catalog-product-management.yaml](.agents/skills/skill-foundry/agents/catalog-product-management.yaml) (category, pattern, overlaps); routing text remains in each `SKILL.md` frontmatter.
- **Inventory maintenance**: Adding, removing, renaming, or moving any skill must update [.agents/docs/skill-factory-skills.md](.agents/docs/skill-factory-skills.md) and the relevant skill-foundry governance catalog in the same change: [.agents/skills/skill-foundry/agents/catalog-engineering.yaml](.agents/skills/skill-foundry/agents/catalog-engineering.yaml), [.agents/skills/skill-foundry/agents/catalog-product-management.yaml](.agents/skills/skill-foundry/agents/catalog-product-management.yaml), or [.agents/skills/skill-foundry/agents/catalog.yaml](.agents/skills/skill-foundry/agents/catalog.yaml). Also update `.agents/docs/skill-domain-routing.md`, `README.md`, `PROJECT_STATUS.md`, and provenance lock files when routing, user-facing inventory, status, or source ownership changes. Run `./validate-skill-library.sh` before committing skill inventory changes.
- **Trigger-based use**: When the user's request matches a skill's description, read that skill's `SKILL.md` and follow its instructions.
- **Skill format**: Each skill has frontmatter `name` and `description`; the description states when to use it.

### Quality Skill References

- **Complexity avoidance**: use `~/.agents/skills/complexity-review/SKILL.md` to challenge complexity drivers before committing to technical direction.
- **Plan and task slicing**: use `~/.agents/skills/story-splitting/SKILL.md` for oversized stories and `~/.agents/skills/hamburger-method/SKILL.md` for vertical delivery slices.
- **Small safe steps**: use `~/.agents/skills/micro-steps-coach/SKILL.md` to turn decided work into 1-3 hour, reversible implementation increments.

## 11. Development Best Practices

- **Error Handling & Debugging**: Always implement proper error handling with meaningful error messages.
- **Debugging First**: When encountering issues, use debugging tools and logging before asking for help.
- **Error Context**: Provide sufficient context in error messages to enable quick problem resolution.
- **Fail Fast**: Design code to fail fast and fail clearly when errors occur.
- **Pair Programming**: Prefer pairing sessions for complex features and knowledge sharing.
- **Small Pull Requests**: Keep changes small and focused for easier review and faster integration.
- **Code Review Standards**: All code must be reviewed before merging, following project quality standards.
- **Security by Design**: Consider security implications in all design decisions.
- **Input Validation**: Always validate and sanitize user inputs and external data.
- **Secrets Management**: Never hardcode secrets; use proper secret management systems.
- **Dependency Security**: Regularly update dependencies and monitor for security vulnerabilities.

## 12. Testing Strategy Distinction

- **Unit Tests**: Fast, isolated tests for individual components.
- **Integration Tests**: Test interactions between components and external systems.
- **E2E Tests**: Full system validation for critical user paths only.
- **Test Pyramid**: Follow the test pyramid with many unit tests, some integration tests, and few E2E tests.

## 13. TDD Rules

- **Failing Test First**: Always start with a failing test before implementing new functionality.
- **Single Test**: Write only one test at a time; never create more than one test per change.
- **Complete Coverage**: Ensure every new feature or bugfix is covered by a test.
- **Test Simplicity**: Keep tests focused, readable, and easy to modify.
- **Process Discipline**: After every code or test change, rerun the repository's canonical automated checks.

## 14. Antigravity Workflows

- When operating in Antigravity mode, use the defined workflows in `.agents/workflows/` for structured tasks.
- Keep task, plan, and verification artifacts current when those workflows are in use.
- Explicitly call task boundaries when switching modes or major sub-tasks.

## 15. Periodic Self-Audit

- At the start of each planning session, verify that the rules, skills, workflows, and project status are current.
- Flag redundant, outdated, or missing guidance when you find it.
- If discrepancies are found, follow the feedback learning loop in [ai-feedback-learning-loop.md](.agents/rules/ai-feedback-learning-loop.md).

## 16. Personal Knowledge Persistence

- Durable personal context, reusable knowledge, source summaries, and decisions belong in the personal knowledge vault, not in always-loaded agent rules.
- Use the `personal-knowledge-routing` skill when the user asks to remember, persist, capture, retrieve, or route personal knowledge, or when deciding whether information belongs in `augmentedcode-configuration` versus the personal knowledge vault.
- Load only the vault guide, conventions, relevant maps, and exact target files needed for the task. Do not bulk-load the vault into context.
- Keep this repository focused on executable agent behavior: rules, skills, workflows, commands, validation, and setup.

@/Users/ignacio.viejo/saski/augmentedcode-configuration/.agents/rules/RTK.md

<!-- context7 -->
Use the `ctx7` CLI to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service -- even well-known ones like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. This includes API syntax, configuration, version migration, library-specific debugging, setup instructions, and CLI tool usage. Use even when you think you know the answer -- your training data may not reflect recent changes. Prefer this over web search for library docs.

Do not use for: refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts.

## Steps

1. Resolve library: `npx ctx7@latest library <name> "<user's question>"` — use the official library name with proper punctuation (e.g., "Next.js" not "nextjs", "Customer.io" not "customerio", "Three.js" not "threejs")
2. Pick the best match (ID format: `/org/project`) by: exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). If results don't look right, try alternate names or queries (e.g., "next.js" not "nextjs", or rephrase the question)
3. Fetch docs: `npx ctx7@latest docs <libraryId> "<user's question>"`
4. Answer using the fetched documentation

You MUST call `library` first to get a valid ID unless the user provides one directly in `/org/project` format. Use the user's full question as the query -- specific and detailed queries return better results than vague single words. Do not run more than 3 commands per question. Do not include sensitive information (API keys, passwords, credentials) in queries.

For version-specific docs, use `/org/project/version` from the `library` output (e.g., `/vercel/next.js/v14.3.0`).

If a command fails with a quota error, inform the user and suggest `npx ctx7@latest login` or setting `CONTEXT7_API_KEY` env var for higher limits. Do not silently fall back to training data.
<!-- context7 -->
