# Pull + Sync Skills Wrapper — Implementation Plan

## Overview

Add a single-command wrapper that (1) pulls the latest skill-factory repo and (2) runs `sync-skill-factory.sh` so users can update skill-factory skills in one step. Current state (sync script, README, 28 linked skills) remains unchanged; this plan only adds the wrapper and updates documentation.

## Current State Analysis

- **sync-skill-factory.sh** (repo root): Finds every `SKILL.md` under `skill-factory/output_skills/`, creates relative symlinks in `.agents/skills/<name>` only when that name does not exist. Supports `--dry-run` and `SKILL_FACTORY`. Default: sibling `../skill-factory`.
- **README**: "Syncing skills from skill-factory" documents what the script does, when to run it, layout, dry-run. Installation includes optional `./sync-skill-factory.sh`.
- **Workflow today**: Manual two-step — `cd ~/saski/skill-factory && git pull` then `cd ~/saski/augmentedcode-configuration && ./sync-skill-factory.sh`.
- **No Makefile** in repo. **setup-symlinks.sh** handles only home↔repo symlinks (setup, validate, status, commit); it does not reference skill-factory.

## Desired End State

1. One command from augmentedcode-configuration repo root: "pull skill-factory, then sync" (e.g. `./pull-and-sync-skills.sh`).
2. Wrapper respects `SKILL_FACTORY` so custom paths still work.
3. README recommends the one-liner and documents the wrapper.
4. No change to `sync-skill-factory.sh` behavior or to native skills in `.agents/skills/`.

## What We're NOT Doing

- Changing logic inside `sync-skill-factory.sh`.
- Adding a Makefile (wrapper is a script; can add `make sync-skills` later if desired).
- Modifying `setup-symlinks.sh` (wrapper is a separate script).
- Pulling or syncing anything other than skill-factory → .agents/skills.

## Implementation Approach

Add a small bash script `pull-and-sync-skills.sh` in repo root that:
1. Resolves skill-factory directory (same as sync script: `SKILL_FACTORY` or `../skill-factory` from repo root).
2. Runs `git pull` in that directory (no branch/remote assumptions beyond default).
3. Runs `./sync-skill-factory.sh` (inherits `SKILL_FACTORY` and passes through any extra args, e.g. `--dry-run` if we choose to support it).
4. Exits with failure if either step fails.

Then update README: recommend this script in "Syncing skills from skill-factory" and in Installation as the optional one-liner.

---

## Phase 1: Add `pull-and-sync-skills.sh`

### Overview

Create a script that pulls skill-factory and runs the existing sync script, with the same path semantics as `sync-skill-factory.sh`.

### Changes Required

#### 1. New script: `pull-and-sync-skills.sh`

**File**: `pull-and-sync-skills.sh` (repo root)

**Behavior**:

- Set `REPO_DIR` to script directory; set `SKILL_FACTORY` default to `$REPO_DIR/../skill-factory` (same as sync script).
- If `SKILL_FACTORY` is not a git repo or `output_skills` is missing, exit with clear error.
- `cd "$SKILL_FACTORY"` and run `git pull`; on failure, exit with non-zero.
- `cd "$REPO_DIR"` and run `./sync-skill-factory.sh` (pass through args, e.g. `--dry-run`); exit with its status.

**Optional**: Support `--dry-run` only for the sync step (pull always runs); document in script usage.

**Implementation sketch**:

```bash
#!/bin/bash
set -e
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FACTORY="${SKILL_FACTORY:-$REPO_DIR/../skill-factory}"

# Ensure skill-factory exists and is git
if [[ ! -d "$SKILL_FACTORY/.git" ]]; then
  echo "❌ Not a git repo: $SKILL_FACTORY"
  exit 1
fi
if [[ ! -d "$SKILL_FACTORY/output_skills" ]]; then
  echo "❌ output_skills not found: $SKILL_FACTORY/output_skills"
  exit 1
fi

echo "📥 Pulling skill-factory..."
(cd "$SKILL_FACTORY" && git pull)
echo ""
echo "🔗 Syncing skills..."
cd "$REPO_DIR"
exec ./sync-skill-factory.sh "$@"
```

- Make executable: `chmod +x pull-and-sync-skills.sh`.

### Success Criteria

- [x] From repo root, `./pull-and-sync-skills.sh` pulls sibling skill-factory and runs sync.
- [x] `SKILL_FACTORY=/path ./pull-and-sync-skills.sh` uses custom path.
- [x] `./pull-and-sync-skills.sh --dry-run` runs pull then sync in dry-run mode (if we pass `"$@"`).
- [x] Script exits non-zero if `git pull` or sync fails.

---

## Phase 2: Update README

### Overview

Document the wrapper as the recommended way to "pull + sync" and mention it in Installation.

### Changes Required

#### 1. Section "Syncing skills from skill-factory"

**File**: `README.md`

- After the existing "Run the sync script after pulling skill-factory" sentence, add: **Recommended one-liner**: `./pull-and-sync-skills.sh` (pulls skill-factory then runs sync; respects `SKILL_FACTORY`). Optional: one line for dry-run, e.g. `./pull-and-sync-skills.sh --dry-run`.
- Keep existing bullets (what it does, when to run, layout, dry-run).

#### 2. Installation section

**File**: `README.md`

- Replace or supplement the optional comment line:
  - From: `# ./sync-skill-factory.sh`
  - To: `# ./pull-and-sync-skills.sh   # pull skill-factory + sync into .agents/skills`
  (or keep both: sync-only vs pull+sync).

### Success Criteria

- [x] README recommends `./pull-and-sync-skills.sh` for pull+sync.
- [x] Installation optional step mentions the wrapper.
- [x] Existing sync-only and dry-run docs remain.

---

## Testing Strategy

### Manual verification

- From augmentedcode-configuration root with sibling skill-factory: run `./pull-and-sync-skills.sh` and confirm git pull runs and sync adds/skips as expected.
- Run with `SKILL_FACTORY=/other/path` and confirm that path is used.
- Run `./pull-and-sync-skills.sh --dry-run` and confirm sync step is dry-run (no new symlinks created).
- Simulate failure: e.g. wrong `SKILL_FACTORY` or no network for git pull; confirm script exits non-zero and message is clear.

### No new automated tests

- Wrapper is a thin orchestration script; behavior is "run git pull then run existing script." No new unit tests in this plan; rely on manual checks above.

---

## References

- Current sync script: `sync-skill-factory.sh` (repo root)
- README: "Syncing skills from skill-factory", "Installation"
- Research: `thoughts/shared/research/2026-03-07-skill-factory-and-augmentedcode-configuration.md`
