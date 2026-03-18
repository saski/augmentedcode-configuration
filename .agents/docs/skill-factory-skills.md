# Skill-Factory Skills (synced into .agents/skills/)

Skills in this list are synced from [skill-factory](https://github.com/saski/skill-factory) into `.agents/skills/` via `./pull-and-sync-skills.sh`. When the user's request matches a purpose below, read that skill's `SKILL.md` and follow its instructions.

| Skill | Category | Purpose |
|-------|----------|---------|
| traductor-bilingue | tools | Translates technical text between English and Spanish preserving tone and format. Keeps technical terms in English when common in Spanish dev teams (deploy, pull request, pipeline, staging). Use when translating technical documentation, code comments, or team communication. |
| test-desiderata | testing | Analyze and improve test code quality using Kent Beck's Test Desiderata framework. Use when analyzing test files, reviewing test code, identifying test quality issues, suggesting test improvements, or when asked to evaluate tests against best practices. Applies to unit tests, integration tests, and any automated test code. |
| tdd | testing | Test-driven development (TDD) process used when writing code. Use whenever you are adding any new code, unless the user explicitly asks to skip TDD or the code is exploratory/spike. |
| nullables | testing | Writes tests without mocks using Nullables. Use when writing tests, especially testing code with external I/O (HTTP, files, databases, clocks, random numbers), designing infrastructure wrappers or replacing mocking libraries. |
| mutation-testing | testing | Finds weak or missing tests by analyzing if code changes would be caught. Use when verifying test effectiveness, strengthening test suites, or validating TDD workflows. |
| bdd-with-approvals | testing | Scannable BDD tests written in domain language. Use when doing BDD. |
| approval-tests | testing | Writes approval tests (snapshot/golden master testing) for Python, JavaScript/TypeScript, or Java. Use when verifying complex output, characterization testing legacy code, testing combinations, or working with .approved/.received files. |
| thinkies | practices | Applies Kent Beck's Thinkies—pattern-based thinking habits that generate ideas. Use when stuck, exploring alternatives, or reframing decisions. |
| thin-wrappers | practices | Encapsulates infrastructure SDKs behind minimal domain-aligned interfaces. Use when accessing any external infrastructure to keep SDK usage contained, testing simple, and changes easy. |
| story-splitting | practices | Detects stories that are too big and applies splitting heuristics. Identifies linguistic red flags (and, or, manage, handle, including) and suggests concrete splitting strategies. Use when breaking down requirements or splitting large work. |
| small-safe-steps | practices | Small Safe Steps (S3): breaks work into 1-3h increments with zero downtime. Use when asking "how do I implement/migrate/refactor", "what steps to do X", "plan safe migration", or handling risky DB/API changes. Applies expand-contract pattern for migrations, refactorings, schema changes. |
| refinement-loop | practices | Iterative refinement through multiple passes. Use when the user asks to 'meditate on', 'distill', 'refine', or 'iterate on' something, or proactively when a problem benefits from multiple passes rather than a single attempt. |
| refactoring | practices | Refactoring process. Invoke immediately when user or document mentions refactoring, or proactively when code gets too complex or messy. |
| hamburger-method | practices | Slices features into vertical deliverable pieces using the Hamburger Method. Generates 4-5 implementation options per layer and composes minimal end-to-end slices. Use when slicing work, breaking down features into layers, or delivering incrementally. |
| complexity-review | practices | Reviews technical proposals against 30 complexity dimensions. Questions necessity of scale, consistency, and resilience. Use when proposing technologies (Kafka, microservices, event sourcing) or designing systems. Pushes for simplest viable approach. |
| code-simplifier | practices | Simplifies and refines code for clarity, readability, and maintainability. Reduces complexity without changing behavior. Use when simplifying, cleaning up, or reducing complexity in code. |
| writing-bash-scripts | developer-tools | Bash script style guide. Always use when writing bash scripts, shell scripts, or CLI bash tools. |
| using-uv | developer-tools | Python package and project management with UV. Use when creating Python scripts, initializing projects, or managing dependencies. |
| bun-toolkit | developer-tools | JS/TS/JSX toolkit with Bun awareness. Use when using Bun as a runtime, test runner, or package manager in JavaScript and TypeScript projects. |
| git-worktrees | developer-tools | Creates git worktrees for parallel development. Use when creating a git worktree, setting up multiple working directories, or working on features in parallel. |
| dockerfile-review | developer-tools | Reviews Dockerfiles for build performance, image size, and security issues. Use when optimizing, validating, or improving Dockerfiles. |
| modern-cli-design | design | Principles for scalable, modern command-line tools - object-command architecture (noun-verb), LLM-optimized help, JSON output, concurrency patterns, credential management. Use when building CLIs, designing command structures, or implementing terminal applications. |
| hexagonal-architecture | design | Applies hexagonal (ports & adapters) architecture. Use when designing application structure, separating domain from infrastructure, creating testable boundaries, or when user mentions ports, adapters, hexagonal, or clean architecture. |
| event-modeling | design | Designs systems using Event Modeling. |
| collaborative-design | design | Designs software features collaboratively through visual scenarios and iterative refinement. Use when designing features, tools, UIs, workflows, or any system before implementation. |
| creating-process-files | ai | Creates process files - text as code instructions for reliable AI workflows. Use when creating new process files. |
| writing-statuslines | ai | Writes Claude Code status line scripts. Use when creating, customizing, or debugging statusline configurations. |
| creating-hooks | ai | Creates Claude Code hooks. |
| ai-patterns | ai | Reference patterns for augmented coding with AI. Use when discussing AI coding patterns, anti-patterns, obstacles, context management, steering AI, or looking up Lexler's patterns collection. |
