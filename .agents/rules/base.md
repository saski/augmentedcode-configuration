<!-- last_updated: 2026-05-27 -->
<!-- version: 2.9 -->
# AI Agent Development Rules

This is the compact universal rulebook for this project. It applies to every AI agent unless a narrower project, tool, or user instruction explicitly overrides it.

## 1. Operating Principles

### Think Before Acting

- Confirm the goal, constraints, and risks before making changes.
- State important assumptions explicitly; when ambiguity has multiple plausible interpretations, name them.
- Read before writing: inspect exports, immediate callers, shared utilities, docs, and tests that can change the decision.
- Use tools, code, tests, and docs for deterministic answers; reserve model judgment for classification, drafting, synthesis, and tradeoffs.
- Stop when confused. Name what is unclear and ask one focused question instead of guessing.

### Simplest Surgical Change

- Prefer the smallest working change that satisfies the request.
- Do not add speculative features, abstractions, cleanup, comments, or formatting churn.
- Touch only files required for the goal. Clean up only the mess created by the current change.
- Match the codebase's conventions even when you disagree. If a convention is harmful, surface it instead of silently forking the style.
- Push back when a simpler, safer, or more reversible approach exists.

### Goal-Driven Verification

- Define success criteria before implementation and loop until they are verified.
- For new functionality, use outside-in TDD: start with one behavior-level use-case test through the public interface, implement the smallest MVP path that makes it pass, then extend behavior through one verified iteration at a time.
- Start with a failing test for new behavior or bug fixes whenever practical.
- Tests should encode why behavior matters, not only what output happens today.
- Run the repository's canonical automated checks for meaningful changes; use narrower checks while iterating.
- Never say checks passed if any were skipped, unavailable, or only partially run.

### Checkpoint and Escalate

- After each significant step, summarize what changed, what is verified, and what remains.
- Surface conflicts instead of averaging them. Choose the more recent, local, tested, or explicit pattern and explain the choice.
- Fail loud: disclose uncertainty, skipped work, blocked checks, and unresolved risks.
- Persist through normal debugging and validation loops, but pause when requirements or environment state make the next step unsafe.

## 2. Contextual Rule Loading

- When the repo contains Python source or Python project markers, also read `.agents/rules/python-project.md` if that file exists.
- When the repo contains a `Makefile`, also read `.agents/rules/makefile-project.md` if that file exists.
- When the repo contains React/TSX source files, also read `.agents/rules/react-best-practices.md` if that file exists.
- If a referenced contextual rule file is absent, treat it as optional, note that it is missing, and continue with the applicable rules that are available.
- Contextual rules extend this file; they do not replace it.

## 3. Communication and Artifacts

- Provide the outcome first, then concise supporting detail when needed.
- Do not require hidden-reasoning, internal-monologue, or chain-of-thought sections.
- Do not append broad run metadata (token counts, tool traces, session identifiers) unless the user explicitly asks for it. Serving-model and applied-skill disclosure are excluded from this restriction.
- When you have concrete information about the serving model or skills actually loaded and applied for the inference, disclose them briefly without waiting for the user to ask (for example a short line at the start or end). Do not guess model names or claim a skill was used if it was only considered but not read and followed.
- Team communication can be in Spanish or English.
- All technical artifacts must be in English, including code, documentation, tickets, schemas, configuration, scripts, git commit messages, and test names.

## 4. Documentation Boundaries

- Keep `README.md` user-focused.
- Put developer, CI, and infrastructure documentation in a separate development guide, with a clear link from the README when needed.
- Include example error messages in user-facing documentation for common validation failures.
- Update `README.md` when a change affects repository structure, features, setup, or usage.
- When rules change because of a durable learning, follow `.agents/rules/ai-feedback-learning-loop.md`.

## 5. Skills and Shared Knowledge

- Shared skills live in `.agents/skills/`, one directory per skill with at least `SKILL.md`.
- Use `.agents/docs/skill-factory-skills.md` to route user requests to shared skills before reading the matching `SKILL.md`.
- For Cursor-only skills under `.cursor/skills-cursor/` (Canvas, SDK, loops, meta-skills), use `.agents/docs/cursor-skills.md`; they are not in `.agents/skills/`.
- Shared workflows live in `.agents/workflows/`; load the matching workflow when the user explicitly asks for a named workflow or the task clearly matches one of the repo's canonical delivery flows.
- Shared command prompts live in `.agents/commands/`; treat them as the canonical source when the user explicitly invokes or asks about a repo command mirrored into tool-specific command folders.
- Product-management entries use `.agents/skills/skill-foundry/agents/catalog-product-management.yaml`; engineering entries use `.agents/skills/skill-foundry/agents/catalog-engineering.yaml`; general entries may use `.agents/skills/skill-foundry/agents/catalog.yaml`.
- Adding, removing, renaming, or moving any skill must update `.agents/docs/skill-factory-skills.md` and the relevant skill-foundry governance catalog in the same change: `.agents/skills/skill-foundry/agents/catalog-engineering.yaml`, `.agents/skills/skill-foundry/agents/catalog-product-management.yaml`, or `.agents/skills/skill-foundry/agents/catalog.yaml`.
- Also update `.agents/docs/skill-domain-routing.md`, `README.md`, `PROJECT_STATUS.md`, and provenance lock files when routing, user-facing inventory, status, or source ownership changes.
- Run `./validate-skill-library.sh` before committing shared skill inventory changes; `./pull-and-sync-skills.sh` runs it automatically after every skill-factory sync.
- Run `./validate-cursor-skills.sh` when changing `.cursor/skills-cursor/` or `.agents/docs/cursor-skills.md`.
- Use matching skills when the user's request matches a skill description.

### Quality Skill References

- Complexity avoidance: use `~/.agents/skills/complexity-review/SKILL.md` to challenge complexity drivers before committing to technical direction.
- Plan and task slicing: use `~/.agents/skills/story-splitting/SKILL.md` for oversized stories and `~/.agents/skills/hamburger-method/SKILL.md` for vertical delivery slices.
- Small safe steps: use `~/.agents/skills/micro-steps-coach/SKILL.md` to turn decided work into 1-3 hour, reversible implementation increments.
- Test-driven development: use `~/.agents/skills/tdd/SKILL.md` for the red-green-refactor loop and outside-in TDD specifics.
- Refactoring: use `~/.agents/skills/refactoring/SKILL.md` for structured prep/refactor/evaluate phases when code gets messy.
- Debugging and diagnosis: use `~/.agents/skills/diagnose/SKILL.md` for systematic reproduce → minimise → hypothesise → fix loops on hard bugs and regressions.
- Plan and execute large work: use `~/.agents/skills/fic-research/SKILL.md`, `~/.agents/skills/fic-create-plan/SKILL.md`, `~/.agents/skills/fic-implement-plan/SKILL.md`, and `~/.agents/skills/fic-validate-plan/SKILL.md` for the FIC research → plan → implement → validate workflow.
- Project status maintenance: use `~/.agents/skills/project-status-maintenance/SKILL.md` to create or update `PROJECT_STATUS.md` files with the canonical structure.

## 6. Personal Knowledge Persistence

- Durable personal context, reusable knowledge, source summaries, and decisions belong in the personal knowledge vault, not in always-loaded agent rules.
- Use the `personal-knowledge-routing` skill when the user asks to remember, persist, capture, retrieve, or route personal knowledge, or when deciding whether information belongs in `augmentedcode-configuration` versus the personal knowledge vault.
- Load only the vault guide, conventions, relevant maps, and exact target files needed for the task.
- Keep this repository focused on executable agent behavior: rules, skills, workflows, commands, validation, and setup.

## 7. GitHub SSH And CLI Auth

- Use the `saski` GitHub account for all GitHub access in this environment.
- Before suggesting or running GitHub SSH commands (`git clone`, `git fetch`, `git pull`, `git push`, `git remote add`, `git remote set-url`), use the SSH host alias `git@github.com-saski:`.
- Never use bare `git@github.com:` in this environment.
- Treat `github.com-saski` as SSH routing only; do not use `gh auth login` to choose Git-over-SSH identity.
- Only suggest `gh auth login` when GitHub CLI API auth is actually needed.
- Before suggesting `gh auth login`, check whether `GITHUB_TOKEN` is set. If stored interactive login is required, run `env -u GITHUB_TOKEN gh auth login` or unset `GITHUB_TOKEN` in that shell first, because `gh` will otherwise authenticate from the environment variable instead of storing credentials.
- Verify CLI auth with `gh auth status`.
- If the SSH alias or credential source is unclear, load the `github-host-alias` skill and verify against `~/.ssh/config` and the active shell environment.

## 8. Tool Routing

### RTK

Use `rtk` as the default command wrapper for shell operations whenever available.

#### Resolution Order

When a tool hook needs to find RTK, resolve binaries in this order:

1. `rtk` from `PATH`
2. `~/.agents/bin/rtk`
3. `/opt/homebrew/bin/rtk`
4. `/usr/local/bin/rtk`

`setup-symlinks.sh` links the `~/.agents/bin/rtk` shim to the first available real binary (`/opt/homebrew/bin`, then `/usr/local/bin`, then PATH). The hook resolves PATH-first at runtime; these orders differ by purpose (shim linking vs. runtime resolution) and are intentional.

#### Quick Check

Run this once per session if shell usage is expected:

```bash
rtk --version
```

If `rtk` is not available, continue with normal shell commands.

#### Preferred Usage

- Prefer `rtk <command>` over raw `<command>` for common CLI tasks.
- Keep direct `rtk` meta commands available for diagnostics:
  - `rtk gain`
  - `rtk gain --history`
  - `rtk discover`
  - `rtk proxy <command>`

#### Notes

- If no compatible RTK binary is available, hooks should fail open and continue with normal shell commands.

### Context7

- Use the `ctx7` CLI to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service.
- Do not use Context7 for refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts.
- Resolve the library first with `npx ctx7@latest library <name> "<user's question>"`, unless the user provides a valid `/org/project` ID. Use the official library name with proper punctuation (for example "Next.js", "Customer.io", "Three.js"), and use the user's full question as the query.
- Pick the best match by exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). For version-specific docs, use `/org/project/version` (for example `/vercel/next.js/v14.3.0`).
- Fetch docs with `npx ctx7@latest docs <libraryId> "<user's question>"`.
- Use no more than three Context7 commands per question.
- Do not include sensitive information (API keys, passwords, credentials) in queries.
- If Context7 fails with a quota error, tell the user and suggest `npx ctx7@latest login` or `CONTEXT7_API_KEY`.
