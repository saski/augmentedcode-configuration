---
date: 2026-03-08
researcher: agent
topic: "Is there a list of available skills coming from skill-factory?"
tags: [research, skill-factory, skills, list, manifest, sync]
status: complete
---

# Research: List of Available Skills from skill-factory

## Summary

**There is no committed or persisted list file of available skills from skill-factory.** Both the skill-factory repo and the augmentedcode-configuration repo discover skills at runtime by scanning the filesystem for `SKILL.md` under `output_skills/`. The only way to obtain a list today is to run the discovery (sync dry-run, or skill-factory’s `./skills status`), or to enumerate `output_skills/**/SKILL.md` and use the parent directory name as the skill name.

---

## Detailed Findings

### 1. skill-factory: no list file, runtime discovery only

**Location**: `saski/skill-factory/`.

**Discovery mechanism** ([skills](saski/skill-factory/skills), lines 17–34):

- `discover_skills()` builds a registry by running `SKILLS_SOURCE_DIR.rglob("SKILL.md")` where `SKILLS_SOURCE_DIR = REPO_ROOT / "output_skills"`.
- No JSON, YAML, or manifest file is read or written. The registry is in-memory only.
- Skill name = directory name of the parent of each `SKILL.md` (e.g. `output_skills/testing/tdd/SKILL.md` → name `tdd`).

**How the list is exposed to users**:

- `./skills status` (and `./skills status local`) call `discover_skills()` and print skills grouped by category with installed/not installed ([skills](saski/skill-factory/skills), lines 123–156). So the “list” is the output of this command, not a file.
- `./skills toggle` uses the same registry to build the TUI ([skills](saski/skill-factory/skills), lines 198–208).

**README** ([skill-factory/README.md](saski/skill-factory/README.md)): Describes structure as `output_skills/[category]/[skill-name]/` and mentions `./skills status` to “check what’s installed”. It does not enumerate skill names or reference a list file.

---

### 2. augmentedcode-configuration: no list file, sync-time discovery only

**Location**: `saski/augmentedcode-configuration/`.

**Sync script** ([sync-skill-factory.sh](saski/augmentedcode-configuration/sync-skill-factory.sh), lines 53–75):

- Discovers skills with `find "$OUTPUT_SKILLS" -name "SKILL.md" -type f -print0 | sort -z`.
- For each `SKILL.md`, `skill_dir = dirname(skill_md)` and `name = basename(skill_dir)`.
- Creates symlinks in `.agents/skills/$name` only when that name does not already exist.
- No manifest or list file is read or generated; discovery is done each time the script runs.

**Dry-run as “list”**: Running `./sync-skill-factory.sh --dry-run` prints lines like `link <name> -> <rel_path>` or `skip (exists) <name>`, which effectively lists what would be linked. That is the closest thing to a “list” of skill-factory skills from the config repo’s perspective, but it is command output, not a stored list.

**Documentation**: README and plans describe that skills come from `skill-factory/output_skills/` and that the sync script adds symlinks for any skill not already present. One plan mentions “28 linked skills” as a count ([2026-03-07-pull-and-sync-skills-wrapper.md](saski/augmentedcode-configuration/thoughts/shared/plans/2026-03-07-pull-and-sync-skills-wrapper.md), line 5); there is no maintained document or file that enumerates those names.

---

### 3. Current skill-factory skill set (from filesystem)

Enumerating `output_skills/**/SKILL.md` in the skill-factory repo yields **28 skills** (directory name = skill name):

| Category        | Skill names |
|----------------|------------|
| tools          | traductor-bilingue |
| testing        | test-desiderata, tdd, nullables, mutation-testing, bdd-with-approvals, approval-tests |
| practices      | thinkies, thin-wrappers, story-splitting, small-safe-steps, refinement-loop, refactoring, hamburger-method, complexity-review, code-simplifier |
| developer-tools| writing-bash-scripts, using-uv, git-worktrees, dockerfile-review |
| design         | modern-cli-design, hexagonal-architecture, event-modeling, collaborative-design |
| ai             | creating-process-files, writing-statuslines, creating-hooks, ai-patterns |

*(writing-statuslines and creating-hooks live under `output_skills/ai/claude-code/`.)*

This enumeration is derived from the current filesystem (glob of `SKILL.md`); it is not sourced from any list or manifest file in either repo.

---

## Code References

- `saski/skill-factory/skills` (lines 17–34): `discover_skills()` — `output_skills.rglob("SKILL.md")`, builds in-memory registry.
- `saski/skill-factory/skills` (lines 123–139): `cli_status()` — prints discovered skills with category and installed state.
- `saski/augmentedcode-configuration/sync-skill-factory.sh` (lines 53–75): `find "$OUTPUT_SKILLS" -name "SKILL.md"` loop; no list file read or written.
- `saski/augmentedcode-configuration/README.md` (lines 231–245): “Syncing skills from skill-factory”; describes script behavior, dry-run; no list file.

---

## Architecture

- **skill-factory**: Single source of truth for skill content is the directory tree under `output_skills/`. The list of “available” skills is defined implicitly by the presence of `SKILL.md` in each skill directory. The `skills` script is the only consumer that builds and exposes this list (status/toggle).
- **augmentedcode-configuration**: Consumes skill-factory by pointing at `$SKILL_FACTORY/output_skills` and mirroring that structure into `.agents/skills/` via symlinks. It does not maintain a separate list of “skills from skill-factory”; after sync, the set of skill-factory-originated skills is the set of symlinks in `.agents/skills/` that point into skill-factory (in practice, any name under `.agents/skills/` that was added by the sync script and not a native skill).

---

## Open Questions

- Whether to introduce a generated or maintained list (e.g. `sync-skill-factory.sh` writing `skill-factory-skills.txt` or a JSON manifest) for documentation or tooling.
- Whether skill-factory should ship a manifest (e.g. `output_skills/manifest.json`) for consumers that want a list without scanning the filesystem.
