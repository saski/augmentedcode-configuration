---
date: 2026-03-07
researcher: agent
topic: "skill-factory vs augmentedcode-configuration; skills-cursor role; how to combine"
tags: [research, skill-factory, augmentedcode-configuration, skills-cursor, skills, symlinks]
status: complete
---

# Research: skill-factory, augmentedcode-configuration, and skills-cursor

## Summary

**skill-factory** and **augmentedcode-configuration** are separate repositories with different roles: skill-factory produces skills (output in `output_skills/`) and installs them to `~/.claude/skills/` via its `./skills` script; augmentedcode-configuration is the single source of truth for AI tool config and exposes **canonical** skills from `.agents/skills/` to Cursor, Claude Code, Codex, Antigravity, etc. via symlinks. There is no in-repo reference from one to the other. They can be combined by using augmentedcode-configuration’s symlink setup first, then installing selected skill-factory skills so they appear as symlinks inside the config repo’s `.agents/skills/`, making them visible to all tools.

**skills-cursor** is not a replacement for augmentedcode-configuration. It is a directory *inside* augmentedcode-configuration (`.cursor/skills-cursor/`) that holds five Cursor meta-skills (create-skill, create-rule, create-subagent, migrate-to-skills, update-cursor-settings). It is symlinked as `~/.cursor/skills-cursor` → repo `.cursor/skills-cursor` and is part of the same repo’s configuration.

---

## Detailed Findings

### 1. skill-factory (saski/skill-factory)

**Location**: `~/saski/skill-factory` (sibling to augmentedcode-configuration under `saski/`).

**Purpose** ([README.md](saski/skill-factory/README.md)): Creates Claude Code skills with built-in best practices from Anthropic’s official documentation. Skills are model-invoked (trigger-based) and release information gradually (name + description at startup, full instructions when triggered, references on demand).

**Output**: Generated skills live under `output_skills/[category]/[skill-name]/`. Categories observed: `testing/`, `practices/`, `tools/`, `developer-tools/`, `design/`. Each skill has at least `SKILL.md`; many have `references/`, `REFERENCE.md`, or similar. Example: [output_skills/testing/tdd/SKILL.md](saski/skill-factory/output_skills/testing/tdd/SKILL.md) — frontmatter `name`, `description`, body with TDD process and STARTER_CHARACTER.

**Installation script** ([skills](saski/skill-factory/skills), Python with `uv`):

- **Global**: `./skills install <name>` creates a symlink `~/.claude/skills/<name>` → `skill-factory/output_skills/.../name`. `./skills toggle` is an interactive TUI; `./skills status` lists skills and installed state.
- **Local**: `./skills local install <name>` copies the skill tree into `<cwd>/.claude/skills/<name>`.
- Constants: `GLOBAL_SKILLS_DIR = Path.home() / ".claude" / "skills"`, `LOCAL_SKILLS_DIR = Path.cwd() / ".claude" / "skills"`. No reference to `.cursor`, `.agents`, or augmentedcode-configuration.

**Docs**: `docs/project.md`, `docs/map.md`, `docs/create_new_skill-process.md` describe the output directory and save path as `output_skills/[category]/[skill-name]/`. No mention of augmentedcode-configuration or Cursor.

---

### 2. augmentedcode-configuration (saski/augmentedcode-configuration)

**Location**: `~/saski/augmentedcode-configuration`.

**Purpose** ([README.md](saski/augmentedcode-configuration/README.md)): Reusable AI agent configuration for development workflows (XP/TDD). Single source of truth for Cursor, Claude Code, and other tools; config is shared via symlinks.

**Canonical skills**: `.agents/skills/` is the canonical skill root. Current skills (each with `SKILL.md`):

| Skill directory         | Purpose (from README / plan) |
|-------------------------|------------------------------|
| xp-code-review          | Review pending changes (tests, maintainability, project rules) |
| xp-increase-coverage    | High-value tests for untested code |
| xp-mikado-method        | Mikado Method, safe refactoring |
| xp-plan-untested-code   | Test plan, coverage gaps |
| xp-predict-problems     | Predict failures, production risk |
| xp-security-analysis    | Security review, OWASP, threat modeling |
| xp-simple-design-refactor | Refactor, simple design, ROI |
| xp-technical-debt       | Tech debt catalog, quick wins |
| test-doubles-first      | Prefer fake/stub/spy over mock |
| cwv-improvement-planner | Core Web Vitals (LCP, INP, TTFB) |
| ownership-routing          | Determine owning team for issues |

**Symlink setup** ([setup-symlinks.sh](saski/augmentedcode-configuration/setup-symlinks.sh)):

- `~/.cursor/rules` → repo `.cursor/rules`
- `~/.cursor/commands` → repo `.cursor/commands`
- `~/.cursor/skills` → repo **`.agents/skills`**
- `~/.cursor/skills-cursor` → repo **`.cursor/skills-cursor`**
- `~/.cursor/.agents` → repo `.agents`
- For each tool in `TOOLS_WITH_SKILLS=".codex .antigravity .claude .gemini .langflow"`: `~/$tool/skills` → repo `.agents/skills`
- `~/.claude` → repo `.claude`
- Root configs: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` → repo

So after `./setup-symlinks.sh setup`, `~/.claude` points at the repo’s `.claude/`. Inside the repo, `.claude/` contains `commands` → `../.agents/commands/` and `skills` → `../.agents/skills` (or the same via the home symlink). So **`~/.claude/skills` resolves to repo `.agents/skills/`**.

**No reference to skill-factory**: Grep for `skill-factory`, `output_skills`, or skill-factory paths in augmentedcode-configuration finds no references. The config repo does not document or script integration with skill-factory.

---

### 3. skills-cursor: part of augmentedcode-configuration, not a replacement

**What it is**: A directory inside the config repo: `.cursor/skills-cursor/`. It holds five **meta-skills** (skills about creating or managing skills/rules/settings):

- [create-skill/SKILL.md](saski/augmentedcode-configuration/.cursor/skills-cursor/create-skill/SKILL.md) — creating Agent Skills for Cursor; storage locations include canonical shared `.agents/skills/`.
- create-rule/SKILL.md
- create-subagent/SKILL.md
- migrate-to-skills/SKILL.md
- update-cursor-settings/SKILL.md

**Symlink**: [setup-symlinks.sh:62](saski/augmentedcode-configuration/setup-symlinks.sh) creates `~/.cursor/skills-cursor` → `"$REPO_DIR/.cursor/skills-cursor"`. Validation ([setup-symlinks.sh:89](saski/augmentedcode-configuration/setup-symlinks.sh)) checks `skills-cursor` along with `rules`, `commands`, `skills`, `.agents`.

**Conclusion**: skills-cursor is not a separate project and not a replacement for augmentedcode-configuration. It is a **subset** of the config repo: the Cursor-specific meta-skills, stored in the repo and exposed via the same symlink mechanism. The name “skills-cursor” is the directory name for that subset; the “replacement” idea does not apply.

---

### 4. How to use skill-factory with augmentedcode-configuration

**Conflict**: skill-factory’s `./skills install` expects to create symlinks (or entries) under `~/.claude/skills/`. If that path is already a symlink to a directory (repo `.agents/skills/`), then installing a skill creates `~/.claude/skills/<name>` → which is **repo `.agents/skills/<name>`**. So the install target is the same directory that Cursor and other tools already use when they read `~/.cursor/skills` or `~/.claude/skills`.

**Compatible workflow**:

1. Run augmentedcode-configuration’s `./setup-symlinks.sh setup` so that `~/.claude` and `~/.cursor/skills` point at the repo and `.agents/skills/` is the active skills directory.
2. From skill-factory, run `./skills install <name>` for each skill you want. That creates `~/.claude/skills/<name>` as a symlink; because `~/.claude/skills` is the repo’s `.agents/skills/`, the new symlink is **inside** `.agents/skills/<name>` → `skill-factory/output_skills/.../name`.
3. All tools that read from `~/.cursor/skills` or `~/.claude/skills` (and any other `~/$tool/skills` pointing at `.agents/skills`) will then see the skill-factory skills alongside the existing XP/config skills.

**Caveats**:

- Symlinks created by skill-factory inside `.agents/skills/` are in the config repo; they should be committed if you want them shared (and the symlink target path may need to be portable, e.g. relative or documented for other machines).
- skill-factory’s `./skills status` and toggle operate on `~/.claude/skills`; after setup, that is the same as `.agents/skills/`, so install/uninstall from skill-factory directly affects the canonical skills directory.
- No script or doc in either repo currently describes this combined workflow; it is inferred from the symlink layout.

**Alternative**: Copy (or symlink) selected skill-factory skill directories from `skill-factory/output_skills/...` into `augmentedcode-configuration/.agents/skills/` and commit them. Then you don’t rely on skill-factory’s install script for those skills; they become first-class skills in the config repo.

---

## Code References

- `saski/skill-factory/README.md` — purpose, quick start, output_skills, ./skills usage, STARTER_CHARACTER.
- `saski/skill-factory/skills` (lines 13–14, 58–59, 69–83) — `GLOBAL_SKILLS_DIR`, `LOCAL_SKILLS_DIR`, install/uninstall via symlink or copy.
- `saski/augmentedcode-configuration/README.md` — repo structure, symlink table, XP skills, Cursor skills, FIC workflow.
- `saski/augmentedcode-configuration/setup-symlinks.sh` — lines 7, 12, 56–62, 64–68, 81–106: REPO_DIR, TOOLS_WITH_SKILLS, Cursor and .claude symlinks, validation.
- `saski/augmentedcode-configuration/.cursor/rules/cursor-config-management.mdc` — canonical source, `.agents/skills/`, symlink workflow.
- `saski/augmentedcode-configuration/.cursor/skills-cursor/create-skill/SKILL.md` — storage locations table including canonical shared `.agents/skills/`; warning not to create skills in `~/.cursor/skills-cursor/`.

---

## Architecture

- **skill-factory**: Producer of skills; output in `output_skills/`; install script targets `~/.claude/skills` (and optionally `<cwd>/.claude/skills`). No knowledge of Cursor or augmentedcode-configuration.
- **augmentedcode-configuration**: Single source of truth; canonical skills in `.agents/skills/`; symlinks expose that directory to Cursor (`~/.cursor/skills`), Claude Code (`~/.claude/skills`), and other tools; `.cursor/skills-cursor/` is a second symlinked directory for meta-skills.
- **Combination**: Use config repo’s symlinks so that `~/.claude/skills` is `.agents/skills/`, then run skill-factory’s install to add skills into that directory (or copy/symlink selected skills into `.agents/skills/` and commit).

---

## Open Questions

- Whether to document the combined workflow (and/or add a small script) in augmentedcode-configuration or skill-factory.
- Whether skill-factory symlinks into `.agents/skills/` should use absolute paths (machine-specific) or relative paths (if supported) for portability across clones.
- Whether any skill-factory skills overlap or conflict with existing `.agents/skills/` (e.g. TDD vs project rules) and how to resolve naming or scope.
