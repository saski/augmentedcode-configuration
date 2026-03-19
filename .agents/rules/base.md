<!-- last_updated: 2026-03-19 -->
<!-- version: 2.0 -->
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

- When the repo contains Python source or Python project markers, also read `.agents/rules/python-project.md`.
- When the repo contains a `Makefile`, also read `.agents/rules/makefile-project.md`.
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
- **Run Metadata (Required)**: End each response with a short metadata block for cross-tool calibration, especially in Auto mode.
  - `Tool`: Tool or assistant name.
  - `Mode`: `auto` or `manual`.
  - `Model ID`: Exact model id if exposed, else `not exposed`.
  - `Model Source`: `api/runtime`, `ui label`, or `inferred`.
  - `Task Type`: Short category (e.g., `bugfix`, `review`, `refactor`, `planning`, `docs`).
  - `Confidence`: `low`, `medium`, or `high`.
  - `Verification`: Checks executed (tests/lint/typecheck) or `none`.

## 6. Process & Key Requirements

- **Evidence First**: Validate important assumptions with code, tests, or docs.
- **Persistence**: Persist through multiple attempts until resolution.
- **Thorough Iteration**: Break complex changes into incremental steps.
- **Sequential Questions**: Only one question at a time; each question should build on previous answers.

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
- **Two sources**: Skills in `.agents/skills/` may be native or synced from the skill-factory repository.
- **Skill-factory skills**: Use [.agents/docs/skill-factory-skills.md](.agents/docs/skill-factory-skills.md) to match user requests to skills before reading the skill's `SKILL.md`.
- **Trigger-based use**: When the user's request matches a skill's description, read that skill's `SKILL.md` and follow its instructions.
- **Skill format**: Each skill has frontmatter `name` and `description`; the description states when to use it.

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

- When operating in Antigravity mode, use the defined workflows in `.agent/workflows/` for structured tasks.
- Keep task, plan, and verification artifacts current when those workflows are in use.
- Explicitly call task boundaries when switching modes or major sub-tasks.

## 15. Periodic Self-Audit

- At the start of each planning session, verify that the rules, skills, workflows, and project status are current.
- Flag redundant, outdated, or missing guidance when you find it.
- If discrepancies are found, follow the feedback learning loop in [ai-feedback-learning-loop.md](.agents/rules/ai-feedback-learning-loop.md).

 
