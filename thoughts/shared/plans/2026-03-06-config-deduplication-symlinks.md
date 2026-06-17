# Config Deduplication via Symlinks - Implementation Plan

## Overview

Eliminate ~50 duplicated configuration files by replacing the copy-based sync workflow with symlinks from `~/.cursor/` to the canonical repository at `~/saski/augmentedcode-configuration/`. This establishes the repo as the single source of truth, with all AI tools (Cursor, Claude Code, Codex, Gemini) reading from it via symlink chains.

## Current State Analysis

**Duplication inventory:**
- `~/.cursor/commands/`: 16 files (duplicates of repo `.cursor/commands/`)
- `~/.cursor/rules/`: 11 files (duplicates of repo `.cursor/rules/`) + 1 unique file (`base.mdc`)
- `~/.cursor/.agents/commands/`: 16 files (duplicates of repo `.agents/commands/`)
- `~/.cursor/.agents/rules/`: 3 files (duplicates of repo `.agents/rules/`)
- `~/.cursor/skills/test-doubles-first/`: 4 files (duplicates of repo `.cursor/skills/`)
- `~/.cursor/skills/ownership-routing/`: Global-only, not in repo
- `~/.cursor/skills-cursor/`: 5 skills, global-only, not in repo

**Total**: ~50 duplicated files

**Key constraints discovered:**
- `base.mdc` exists ONLY at `~/.cursor/rules/` (unique global file, not in repo)
- `use-base-rules.mdc` in repo already references `.agents/rules/base.md` for project work
- Sync script already implements bidirectional timestamp-based sync (from previous enhancement)
- `~/CLAUDE.md`, `~/AGENTS.md`, `~/GEMINI.md` do NOT currently exist in home directory
- `~/.claude/` directory does NOT exist yet

**File counts verified:**
```bash
~/.cursor/rules/        # 12 files (11 + base.mdc)
~/.cursor/commands/     # 16 files
~/.cursor/skills/       # 2 skills (test-doubles-first, ownership-routing)
~/.cursor/skills-cursor/ # 5 skills
~/.cursor/.agents/commands/ # 16 files
~/.cursor/.agents/rules/    # 3 files
```

## Desired End State

**Directory structure after implementation:**

```
~/saski/augmentedcode-configuration/          # SINGLE SOURCE OF TRUTH
├── .agents/
│   ├── commands/                             # 16 canonical command files
│   └── rules/
│       ├── base.md                           # Full rulebook (246 lines)
│       ├── ai-feedback-learning-loop.md
│       └── react-best-practices.md
├── .cursor/
│   ├── commands → ../.agents/commands/       # Existing symlink
│   ├── rules/                                # 11 .mdc files (Cursor wrappers)
│   ├── skills/                               # All skills consolidated
│   │   ├── test-doubles-first/
│   │   ├── cwv-improvement-planner/
│   │   └── ownership-routing/                   # Moved from global
│   └── skills-cursor/                        # Moved from global
│       ├── create-rule/
│       ├── create-skill/
│       ├── create-subagent/
│       ├── migrate-to-skills/
│       └── update-cursor-settings/
├── .claude/
│   └── commands → ../.agents/commands/       # Existing symlink
├── AGENTS.md → .agents/rules/base.md         # Existing symlink
├── CLAUDE.md → .agents/rules/base.md         # Existing symlink
├── GEMINI.md → .agents/rules/base.md         # Existing symlink
└── setup-symlinks.sh                         # Repurposed sync script

~/ (Home directory)                           # ALL SYMLINKS, NO COPIES
├── .cursor/
│   ├── rules → ~/saski/augmentedcode-configuration/.cursor/rules/
│   ├── commands → ~/saski/augmentedcode-configuration/.cursor/commands/
│   ├── skills → ~/saski/augmentedcode-configuration/.cursor/skills/
│   ├── skills-cursor → ~/saski/augmentedcode-configuration/.cursor/skills-cursor/
│   └── .agents → ~/saski/augmentedcode-configuration/.agents/
├── .claude → ~/saski/augmentedcode-configuration/.claude/
├── CLAUDE.md → ~/saski/augmentedcode-configuration/CLAUDE.md
├── AGENTS.md → ~/saski/augmentedcode-configuration/AGENTS.md
└── GEMINI.md → ~/saski/augmentedcode-configuration/GEMINI.md
```

**Verification:**
- No duplicated files at `~/.cursor/` (all symlinks): `ls -la ~/.cursor/`
- All symlinks point to repo: `readlink ~/.cursor/rules`
- Cursor can read rules from symlinked directory: Open Cursor, verify rules load
- Commands work from symlinked directory: Run a command in Cursor
- Skills work from symlinked directory: List skills in Cursor
- Git doesn't track home symlinks: `cd ~/saski/augmentedcode-configuration && git status` (clean)

## What We're NOT Doing

- **NOT splitting base.md**: The base.md refactoring (universal vs python-specific) is a separate effort (see `thoughts/shared/research/2026-03-06-base-md-split-context.md`)
- **NOT modifying base.mdc**: It stays as-is at `~/.cursor/rules/` for now
- **NOT syncing .gitignore**: Skills may have .venv/ or local artifacts
- **NOT creating systemd/LaunchAgent**: No background processes
- **NOT symlinking .vscode/**, .codex/config.toml, or tool-specific configs (not part of deduplication scope)
- **NOT handling other AI tools' config beyond symlinks**: No Kiro, Antigravity changes

## Implementation Approach

**Strategy:**
1. **Consolidate to repo**: Move global-only content (skills-cursor/, ownership-routing/) into repo
2. **Backup existing**: Create safety backup of `~/.cursor/` before destructive changes
3. **Remove duplicates**: Delete all duplicated directories/files at `~/.cursor/`
4. **Create symlinks**: Replace with symlinks pointing to repo
5. **Extend to other tools**: Create symlinks for Claude Code, Codex, Gemini
6. **Repurpose sync script**: Convert to setup/validate/git helper tool

**Safety measures:**
- Create timestamped backup of entire `~/.cursor/` directory
- Test symlinks in non-destructive way first (create in temp location)
- Validate Cursor can read from symlinks before removing originals
- Keep backup for 7 days after successful transition

---

## Phase 1: Consolidate Skills into Repository

### Overview
Move global-only skills from `~/.cursor/skills/` and `~/.cursor/skills-cursor/` into the repository to establish single source of truth.

### Changes Required:

#### 1. Move ownership-routing Skill to Repo
**Action**: Copy directory tree from global to repo

```bash
# From repo root
cp -r ~/.cursor/skills/ownership-routing/ .cursor/skills/
```

**Files moved**: `ownership-routing/` (13 files based on ls output)

#### 2. Move skills-cursor to Repo
**Action**: Copy entire skills-cursor directory

```bash
# From repo root
cp -r ~/.cursor/skills-cursor/ .cursor/
```

**Files moved**: 5 skill directories (create-rule, create-skill, create-subagent, migrate-to-skills, update-cursor-settings)

#### 3. Update .gitignore for Skills
**File**: `.gitignore`
**Changes**: Add patterns for skill-specific artifacts

```
# Skill artifacts
.cursor/skills/**/.venv/
.cursor/skills/**/__pycache__/
.cursor/skills/**/*.pyc
.cursor/skills-cursor/**/.venv/
```

#### 4. Verify Skill Structure
**Action**: Ensure each skill has proper SKILL.md format

```bash
# From repo root
find .cursor/skills/ .cursor/skills-cursor/ -name "SKILL.md" -exec echo "Found: {}" \;
```

### Success Criteria:
- [x] `ownership-routing/` exists in repo `.cursor/skills/`
- [x] All 5 skills exist in repo `.cursor/skills-cursor/`
- [x] `.gitignore` updated with skill artifact patterns
- [x] All SKILL.md files are present and valid
- [x] Git shows new files: `git status` in repo
- [x] Directory structure matches target architecture

---

## Phase 2: Create Safety Backup

### Overview
Create timestamped backup of current `~/.cursor/` state before making destructive changes.

### Changes Required:

#### 1. Create Backup Script
**File**: `backup-cursor-config.sh` (new file in repo)
**Changes**: Create backup utility script

```bash
#!/bin/bash
# Backup existing ~/.cursor/ configuration before symlink migration

BACKUP_DIR="$HOME/.cursor-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_PATH="$BACKUP_DIR/cursor-backup-$TIMESTAMP"

echo "🗄️  Creating backup of ~/.cursor/..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Copy entire .cursor directory
cp -R ~/.cursor/ "$BACKUP_PATH"

# Verify backup
if [ -d "$BACKUP_PATH" ]; then
    SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
    echo "✅ Backup created: $BACKUP_PATH ($SIZE)"
    echo ""
    echo "📝 Backup retention: 7 days"
    echo "   To restore: cp -R $BACKUP_PATH ~/.cursor/"
    echo "   To clean old backups: find $BACKUP_DIR -type d -mtime +7 -exec rm -rf {} +"
else
    echo "❌ Backup failed"
    exit 1
fi
```

#### 2. Run Backup
**Action**: Execute backup before proceeding

```bash
chmod +x backup-cursor-config.sh
./backup-cursor-config.sh
```

#### 3. Verify Backup Contents
**Action**: Confirm all critical files are backed up

```bash
LATEST_BACKUP=$(ls -td ~/.cursor-backups/* | head -1)
ls -la "$LATEST_BACKUP/rules/"
ls -la "$LATEST_BACKUP/commands/"
ls "$LATEST_BACKUP/skills/"
```

### Success Criteria:
- [x] Backup script created and executable
- [x] Backup directory created at `~/.cursor-backups/cursor-backup-YYYYMMDD-HHMMSS/`
- [x] Backup contains all files from `~/.cursor/`
- [x] `base.mdc` is backed up (critical unique file)
- [x] Backup size matches original: `du -sh ~/.cursor/` vs backup
- [x] Backup script added to repo

---

## Phase 3: Prepare Repository for Symlink Transition

### Overview
Ensure repository has all content and is ready to be the canonical source.

### Changes Required:

#### 1. Verify All Skills in Repo
**Action**: Confirm previous phase completed successfully

```bash
# From repo root
ls .cursor/skills/
# Expected: test-doubles-first, cwv-improvement-planner, ownership-routing

ls .cursor/skills-cursor/
# Expected: create-rule, create-skill, create-subagent, migrate-to-skills, update-cursor-settings
```

#### 2. Commit Skills to Repository
**Action**: Add and commit all new skill content

```bash
git add .cursor/skills/ownership-routing/
git add .cursor/skills-cursor/
git add .gitignore
git commit -m "feat: consolidate skills into repository for symlink deduplication

- Move ownership-routing from global-only to repo
- Move skills-cursor/ directory into repo (5 meta-skills)
- Update .gitignore for skill artifacts
- Preparation for Phase 4 symlink migration"
```

#### 3. Verify Repository State
**Action**: Ensure repo is clean and ready

```bash
git status
# Should show: working tree clean
```

#### 4. Document Current Structure
**Action**: Save inventory for rollback reference

```bash
# From repo root
tree -L 3 .cursor/ > docs/cursor-structure-pre-symlink.txt
```

### Success Criteria:
- [x] All skills committed to repo
- [x] Repository working tree is clean
- [x] No uncommitted changes
- [x] Structure documented for reference
- [ ] Push to remote successful: `git push` (run manually if needed)

---

## Phase 4: Create Symlinks at ~/.cursor/

### Overview
Replace duplicated directories at `~/.cursor/` with symlinks to repo. This is the critical phase that eliminates duplication.

### Changes Required:

#### 1. Remove Duplicated Directories
**Action**: Delete directories that will be replaced by symlinks

```bash
# CRITICAL: Ensure backup exists first!
test -d ~/.cursor-backups/ || { echo "❌ No backup found! Run Phase 2 first."; exit 1; }

# Remove duplicated content (these will become symlinks)
rm -rf ~/.cursor/rules/
rm -rf ~/.cursor/commands/
rm -rf ~/.cursor/skills/
rm -rf ~/.cursor/skills-cursor/
rm -rf ~/.cursor/.agents/
```

**IMPORTANT**: Do NOT remove `~/.cursor/` itself - only the subdirectories we're replacing with symlinks.

#### 2. Create Symlinks to Repository
**Action**: Replace removed directories with symlinks

```bash
# From home directory
cd ~/.cursor/

# Create symlinks (absolute paths)
ln -s ~/saski/augmentedcode-configuration/.cursor/rules rules
ln -s ~/saski/augmentedcode-configuration/.cursor/commands commands
ln -s ~/saski/augmentedcode-configuration/.cursor/skills skills
ln -s ~/saski/augmentedcode-configuration/.cursor/skills-cursor skills-cursor
ln -s ~/saski/augmentedcode-configuration/.agents .agents
```

#### 3. Verify Symlinks Created
**Action**: Check all symlinks point correctly

```bash
ls -la ~/.cursor/ | grep '^l'
# Expected output:
# lrwxr-xr-x ... .agents -> /Users/saski/Code/augmentedcode-configuration/.agents
# lrwxr-xr-x ... commands -> /Users/saski/Code/augmentedcode-configuration/.cursor/commands
# lrwxr-xr-x ... rules -> /Users/saski/Code/augmentedcode-configuration/.cursor/rules
# lrwxr-xr-x ... skills -> /Users/saski/Code/augmentedcode-configuration/.cursor/skills
# lrwxr-xr-x ... skills-cursor -> /Users/saski/Code/augmentedcode-configuration/.cursor/skills-cursor
```

#### 4. Test Symlink Access
**Action**: Verify files are readable through symlinks

```bash
# Test rules
ls ~/.cursor/rules/
cat ~/.cursor/rules/use-base-rules.mdc | head -5

# Test commands
ls ~/.cursor/commands/
cat ~/.cursor/commands/fic-create-plan.md | head -5

# Test skills
ls ~/.cursor/skills/
cat ~/.cursor/skills/test-doubles-first/SKILL.md | head -5

# Test .agents
ls ~/.cursor/.agents/commands/
cat ~/.cursor/.agents/rules/base.md | head -5
```

#### 5. Handle base.mdc Special Case
**Action**: Restore the unique global file

The backup contains `~/.cursor/rules/base.mdc` which is NOT in the repo. After creating the rules symlink, this file is "lost" because rules/ now points to repo (which doesn't have base.mdc).

**Decision needed**: Where should `base.mdc` live?
- Option A: Copy it from backup to `~/saski/augmentedcode-configuration/.cursor/rules/base.mdc` (becomes tracked)
- Option B: Keep it separate at `~/.cursor/base.mdc` (outside the symlinked directory)
- Option C: Delete it (use-base-rules.mdc already points to base.md)

**Recommended**: Option A - Copy to repo so it's version controlled and backed up with everything else.

```bash
# Copy base.mdc from backup into repo
LATEST_BACKUP=$(ls -td ~/.cursor-backups/* | head -1)
cp "$LATEST_BACKUP/rules/base.mdc" ~/saski/augmentedcode-configuration/.cursor/rules/

# Now it's accessible via symlink
ls ~/.cursor/rules/base.mdc
```

### Success Criteria:
- [x] All duplicate directories removed from `~/.cursor/`
- [x] Five symlinks created: rules, commands, skills, skills-cursor, .agents
- [x] All symlinks point to correct repo paths
- [x] Files are readable through symlinks
- [x] `base.mdc` is preserved and accessible (copied to repo)
- [x] `~/.cursor/` directory structure is clean (only symlinks + other Cursor files)

---

## Phase 5: Test Cursor Integration

### Overview
Verify Cursor IDE can read and use configuration from symlinked directories.

### Changes Required:

#### 1. Restart Cursor
**Action**: Fully restart Cursor to reload configuration

```bash
# Kill all Cursor processes
pkill -9 Cursor

# Start Cursor
open -a Cursor
```

#### 2. Verify Rules Load
**Action**: Check that rules are active

- Open Cursor settings → Rules
- Verify all .mdc files appear in the rules list
- Check that `base.mdc` is listed (if using alwaysApply)
- Verify rule count matches repo: should see 12 rules

#### 3. Verify Commands Available
**Action**: Test command palette

- Open command palette (Cmd+Shift+P)
- Search for custom commands (e.g., `/fic-create-plan`, `/xp-refactor`)
- Verify commands appear in the list
- Expected: 16 commands visible

#### 4. Verify Skills Available
**Action**: Check skills are recognized

- Invoke a skill (e.g., test-doubles-first)
- Verify skill files are found
- Test that skill execution works

#### 5. Test Editing Through Symlink
**Action**: Make a change in Cursor, verify it propagates to repo

```bash
# Edit a rule file in Cursor
# Save the file

# Check git status in repo
cd ~/saski/augmentedcode-configuration
git status
# Should show the edited file as modified
```

### Success Criteria:
- [ ] Cursor starts without errors
- [ ] All 12 rules are loaded and active
- [ ] All 16 commands appear in command palette
- [ ] Skills are recognized and executable
- [ ] Editing a file in Cursor modifies the repo file directly
- [ ] No "file not found" or symlink errors in Cursor logs

---

## Phase 6: Extend Symlinks to Other AI Tools

### Overview
Create symlinks for Claude Code, Codex, and Gemini to share the same configuration.

### Changes Required:

#### 1. Create ~/.claude/ Symlink
**Action**: Link entire .claude directory to repo

```bash
# Create symlink for .claude directory
ln -s ~/saski/augmentedcode-configuration/.claude ~/.claude

# Verify
ls -la ~/.claude
readlink ~/.claude
```

#### 2. Create Root-Level Config Symlinks
**Action**: Link CLAUDE.md, AGENTS.md, GEMINI.md to home directory

```bash
# Create symlinks in home directory
cd ~
ln -s saski/augmentedcode-configuration/CLAUDE.md CLAUDE.md
ln -s saski/augmentedcode-configuration/AGENTS.md AGENTS.md
ln -s saski/augmentedcode-configuration/GEMINI.md GEMINI.md

# Verify
ls -la ~/CLAUDE.md ~/AGENTS.md ~/GEMINI.md
```

#### 3. Verify Symlink Chains Work
**Action**: Test that tool → home symlink → repo symlink → actual file works

```bash
# Follow the symlink chain for CLAUDE.md
ls -l ~/CLAUDE.md
# -> saski/augmentedcode-configuration/CLAUDE.md

readlink ~/CLAUDE.md
# -> saski/augmentedcode-configuration/CLAUDE.md

ls -l ~/saski/augmentedcode-configuration/CLAUDE.md
# -> .agents/rules/base.md

cat ~/CLAUDE.md | head -5
# Should show base.md content
```

#### 4. Test Claude Code Integration
**Action**: Verify Claude Code can read CLAUDE.md

```bash
# Open a Claude Code session in the repo
# Verify it reads the CLAUDE.md configuration
# Check that it follows the base.md rules
```

#### 5. Document Symlink Architecture
**Action**: Update README with symlink structure

**File**: `README.md`
**Changes**: Add section explaining symlink architecture

```markdown
## Configuration Architecture

This repository uses symlinks to share configuration across multiple AI tools:

```
~/.cursor/rules     → repo/.cursor/rules/
~/.cursor/commands  → repo/.cursor/commands/  → repo/.agents/commands/
~/.cursor/skills    → repo/.cursor/skills/
~/.cursor/.agents   → repo/.agents/
~/.claude/          → repo/.claude/
~/CLAUDE.md         → repo/CLAUDE.md          → repo/.agents/rules/base.md
~/AGENTS.md         → repo/AGENTS.md          → repo/.agents/rules/base.md
~/GEMINI.md         → repo/GEMINI.md          → repo/.agents/rules/base.md
```

**Single source of truth**: All configuration lives in this repo. Edits in any tool propagate to the repo automatically.
```
```

### Success Criteria:
- [x] `~/.claude/` symlink created and points to repo
- [x] `~/CLAUDE.md` symlink created
- [x] `~/AGENTS.md` symlink created
- [x] `~/GEMINI.md` symlink created
- [x] Symlink chains resolve correctly (can cat files)
- [ ] Claude Code can read CLAUDE.md (manual)
- [ ] Documentation updated with architecture diagram (Phase 8)

---

## Phase 7: Repurpose sync-cursor-config.sh

### Overview
Convert the sync script from a copy-based tool to a symlink setup/validation/git helper utility.

### Changes Required:

#### 1. Rename Script
**Action**: Rename to reflect new purpose

```bash
# From repo root
git mv sync-cursor-config.sh setup-symlinks.sh
```

#### 2. Rewrite Script for New Purpose
**File**: `setup-symlinks.sh`
**Changes**: Complete rewrite focusing on three modes

```bash
#!/bin/bash
# Setup and Validate Symlinks for AI Tool Configuration
# Establishes ~/.cursor/, ~/.claude/, and other AI tool config as symlinks to this repo

set -e

REPO_DIR="$HOME/saski/augmentedcode-configuration"

usage() {
    cat << EOF
Usage: $(basename $0) [command]

Commands:
  setup     - Create all symlinks (first-time setup or repair)
  validate  - Verify all symlinks are correct
  status    - Show git status of config changes
  commit    - Stage, commit, and push config changes
  help      - Show this help message

Examples:
  $(basename $0) setup      # Initial setup on new machine
  $(basename $0) validate   # Check symlinks are intact
  $(basename $0) commit     # Commit and push config changes
EOF
    exit 1
}

# Verify we're in the right place
check_environment() {
    if [ ! -d "$REPO_DIR" ]; then
        echo "❌ Repository not found at $REPO_DIR"
        exit 1
    fi

    if [ ! -d "$REPO_DIR/.cursor" ]; then
        echo "❌ .cursor directory not found in repo"
        exit 1
    fi
}

# Create all symlinks
setup_symlinks() {
    echo "🔗 Setting up symlinks..."

    # Backup existing if not symlinks
    if [ -d ~/.cursor/rules ] && [ ! -L ~/.cursor/rules ]; then
        echo "⚠️  Found existing ~/.cursor/rules (not a symlink)"
        echo "   Create backup with: ./backup-cursor-config.sh"
        exit 1
    fi

    # Create .cursor symlinks
    mkdir -p ~/.cursor
    ln -sf "$REPO_DIR/.cursor/rules" ~/.cursor/rules
    ln -sf "$REPO_DIR/.cursor/commands" ~/.cursor/commands
    ln -sf "$REPO_DIR/.cursor/skills" ~/.cursor/skills
    ln -sf "$REPO_DIR/.cursor/skills-cursor" ~/.cursor/skills-cursor
    ln -sf "$REPO_DIR/.agents" ~/.cursor/.agents

    # Create .claude symlink
    ln -sf "$REPO_DIR/.claude" ~/.claude

    # Create root-level config symlinks
    ln -sf "$REPO_DIR/CLAUDE.md" ~/CLAUDE.md
    ln -sf "$REPO_DIR/AGENTS.md" ~/AGENTS.md
    ln -sf "$REPO_DIR/GEMINI.md" ~/GEMINI.md

    echo "✅ Symlinks created"
}

# Validate all symlinks
validate_symlinks() {
    echo "🔍 Validating symlinks..."

    local errors=0

    # Check .cursor symlinks
    for link in rules commands skills skills-cursor .agents; do
        local path="$HOME/.cursor/$link"
        if [ ! -L "$path" ]; then
            echo "❌ $path is not a symlink"
            errors=$((errors + 1))
        elif [ ! -e "$path" ]; then
            echo "❌ $path is a broken symlink"
            errors=$((errors + 1))
        else
            local target=$(readlink "$path")
            echo "✓ ~/.cursor/$link → $target"
        fi
    done

    # Check .claude
    if [ ! -L ~/.claude ]; then
        echo "❌ ~/.claude is not a symlink"
        errors=$((errors + 1))
    else
        echo "✓ ~/.claude → $(readlink ~/.claude)"
    fi

    # Check root configs
    for config in CLAUDE.md AGENTS.md GEMINI.md; do
        local path="$HOME/$config"
        if [ ! -L "$path" ]; then
            echo "❌ ~/$config is not a symlink"
            errors=$((errors + 1))
        else
            echo "✓ ~/$config → $(readlink $path)"
        fi
    done

    if [ $errors -eq 0 ]; then
        echo ""
        echo "✅ All symlinks valid"
        return 0
    else
        echo ""
        echo "❌ Found $errors symlink issues"
        return 1
    fi
}

# Show git status
show_status() {
    echo "📊 Configuration changes:"
    cd "$REPO_DIR"
    git status --short .cursor/ .agents/ *.md
}

# Commit and push changes
commit_changes() {
    cd "$REPO_DIR"

    if git diff --quiet .cursor/ .agents/ *.md 2>/dev/null; then
        echo "ℹ️  No config changes to commit"
        exit 0
    fi

    echo "📝 Changes to commit:"
    git status --short .cursor/ .agents/ *.md
    echo ""

    read -p "Commit message: " -r message

    if [ -z "$message" ]; then
        echo "❌ Commit message required"
        exit 1
    fi

    git add .cursor/ .agents/ *.md
    git commit -m "$message"

    read -p "Push to remote? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push
        echo "✅ Changes pushed"
    else
        echo "ℹ️  Changes committed locally (not pushed)"
    fi
}

# Main
check_environment

case "${1:-help}" in
    setup)
        setup_symlinks
        ;;
    validate)
        validate_symlinks
        ;;
    status)
        show_status
        ;;
    commit)
        commit_changes
        ;;
    help|*)
        usage
        ;;
esac
```

#### 3. Update Documentation References
**Action**: Update all references to old script name

**File**: `.cursor/rules/cursor-config-management.mdc`
**Changes**: Replace sync script references

```markdown
## Bidirectional Sync Workflow

The repository uses symlinks for configuration. Use `setup-symlinks.sh` for:

1. **Initial setup**: `./setup-symlinks.sh setup`
2. **Validation**: `./setup-symlinks.sh validate`
3. **Commit changes**: `./setup-symlinks.sh commit`

### Setup on New Machine

```bash
cd ~/saski/augmentedcode-configuration
./setup-symlinks.sh setup
```

### Verify Symlinks

```bash
./setup-symlinks.sh validate
```
```

#### 4. Test New Script
**Action**: Verify all modes work

```bash
# Test validate
./setup-symlinks.sh validate

# Test status
./setup-symlinks.sh status

# Test help
./setup-symlinks.sh help
```

### Success Criteria:
- [x] Script renamed to `setup-symlinks.sh`
- [x] All three modes work: setup, validate, status, commit
- [x] Validation correctly identifies symlink issues
- [x] Status shows git changes
- [x] Commit mode stages and commits config changes
- [x] Documentation updated with new script name (cursor-config-management.mdc)
- [x] Old bidirectional sync logic removed

---

## Phase 8: Cleanup and Documentation

### Overview
Remove obsolete backup files, update documentation, and verify final state.

### Changes Required:

#### 1. Update README.md
**File**: `README.md`
**Changes**: Document new symlink-based architecture

Add section after existing content:

```markdown
## Configuration Management

### Architecture

This repository is the **single source of truth** for AI tool configuration. Configuration is shared via symlinks:

**Symlink structure:**
```
~/.cursor/rules     → ~/saski/augmentedcode-configuration/.cursor/rules/
~/.cursor/commands  → ~/saski/augmentedcode-configuration/.cursor/commands/
~/.cursor/skills    → ~/saski/augmentedcode-configuration/.cursor/skills/
~/.cursor/.agents   → ~/saski/augmentedcode-configuration/.agents/
~/.claude/          → ~/saski/augmentedcode-configuration/.claude/
~/CLAUDE.md         → ~/saski/augmentedcode-configuration/CLAUDE.md
~/AGENTS.md         → ~/saski/augmentedcode-configuration/AGENTS.md
~/GEMINI.md         → ~/saski/augmentedcode-configuration/GEMINI.md
```

### Setup on New Machine

```bash
cd ~/saski/augmentedcode-configuration
./setup-symlinks.sh setup
```

### Verifying Configuration

```bash
# Validate all symlinks are correct
./setup-symlinks.sh validate

# Check for uncommitted changes
./setup-symlinks.sh status
```

### Making Changes

All configuration edits (in Cursor, VS Code, or any editor) automatically modify the repository files. Commit changes with:

```bash
./setup-symlinks.sh commit
```

### Troubleshooting

**Symlinks broken**: Run `./setup-symlinks.sh setup` to recreate
**Config not loading**: Run `./setup-symlinks.sh validate` to diagnose
**Restore backup**: See `~/.cursor-backups/` for timestamped backups
```
```

#### 2. Update PROJECT_STATUS.md
**File**: `PROJECT_STATUS.md`
**Changes**: Document symlink migration completion

```markdown
## Recent Changes

### 2026-03-06: Config Deduplication via Symlinks ✅

Completed migration from copy-based sync to symlink-based configuration:

- **Eliminated**: ~50 duplicated files across `~/.cursor/`
- **Consolidated**: All skills moved to repository
- **Symlinked**: `~/.cursor/`, `~/.claude/`, and root configs now point to repo
- **Repurposed**: `sync-cursor-config.sh` → `setup-symlinks.sh`

**Impact**: Single source of truth established. All config edits in any tool propagate to repo automatically.

**Files**: See implementation plan at `thoughts/shared/plans/2026-03-06-config-deduplication-symlinks.md`
```

#### 3. Clean Old Backups (Optional)
**Action**: Remove backups older than 7 days

```bash
find ~/.cursor-backups/ -type d -mtime +7 -exec rm -rf {} +
```

#### 4. Verify Final State
**Action**: Comprehensive validation of migration

```bash
# Symlinks exist and valid
./setup-symlinks.sh validate

# No duplicate files
ls -la ~/.cursor/ | grep -v '^l' | grep -v '^d' | grep -v '^total'
# Should only show non-symlink Cursor files (mcp.json, etc.)

# Git clean
git status
# Should be clean or only show documentation updates

# Count reduction verified
# Before: ~50 duplicated files
# After: 0 duplicated files (all symlinks)
```

#### 5. Final Commit
**Action**: Commit all documentation and cleanup

```bash
git add README.md PROJECT_STATUS.md
git add setup-symlinks.sh backup-cursor-config.sh
git add .gitignore
git commit -m "docs: complete symlink deduplication migration

- Update README with symlink architecture
- Document migration in PROJECT_STATUS
- Add setup and backup scripts
- Update .gitignore for skill artifacts

Eliminates ~50 duplicated files. Repository is now single source of truth
for Cursor, Claude Code, Codex, and Gemini configuration."

git push
```

### Success Criteria:
- [x] README.md updated with symlink documentation
- [x] PROJECT_STATUS.md reflects migration completion
- [ ] All changes committed and pushed (run manually; GPG may be required)
- [x] Symlink validation passes
- [x] No duplicate files remain at `~/.cursor/`
- [ ] Backup older than 7 days cleaned (optional; run when desired)
- [ ] Git repository is clean (after commit)

---

## Testing Strategy

### Validation Commands

Run after each phase:

```bash
# Symlink integrity
./setup-symlinks.sh validate

# Git status check
cd ~/saski/augmentedcode-configuration
git status

# File access test
cat ~/.cursor/rules/use-base-rules.mdc
cat ~/.cursor/commands/fic-create-plan.md
cat ~/.cursor/skills/test-doubles-first/SKILL.md
```

### Integration Tests

**Cursor Integration:**
1. Open Cursor
2. Open command palette (Cmd+Shift+P)
3. Verify custom commands appear
4. Edit a rule file in Cursor
5. Verify `git status` in repo shows the change

**Claude Code Integration:**
1. Open Claude Code in terminal: `claude`
2. Navigate to repo: `cd ~/saski/augmentedcode-configuration`
3. Verify it reads CLAUDE.md rules
4. Ask Claude to explain the base.md rules

**Manual Verification:**
- [ ] Edit `~/.cursor/rules/use-base-rules.mdc` → Changes appear in repo
- [ ] Edit repo `.cursor/rules/tdd-workflow.mdc` → Changes appear in Cursor
- [ ] Run `git diff` in repo → Shows changes from both directions
- [ ] Symlink chains resolve: `cat ~/CLAUDE.md` shows base.md content

### Edge Cases

1. **Broken symlink recovery**: Delete a symlink, run `./setup-symlinks.sh setup`
2. **Permission issues**: Check file permissions after symlinking
3. **Case sensitivity**: Verify macOS symlinks work with case-insensitive filesystem
4. **Cursor reload**: Restart Cursor multiple times, verify config persists

### Rollback Plan

If migration fails:

```bash
# Restore from backup
LATEST_BACKUP=$(ls -td ~/.cursor-backups/* | head -1)
rm -rf ~/.cursor/
cp -R "$LATEST_BACKUP" ~/.cursor/

# Restore original sync script
cd ~/saski/augmentedcode-configuration
git checkout sync-cursor-config.sh

# Resume normal copy-based sync
./sync-cursor-config.sh both
```

---

## References

- Research document: `thoughts/shared/research/2026-03-06-config-deduplication-symlinks.md`
- Previous sync enhancement: `thoughts/shared/plans/2026-01-20-sync-cursor-config-enhancement.md`
- Current sync script: `sync-cursor-config.sh:1:270`
- Cursor config rule: `.cursor/rules/cursor-config-management.mdc`
- Base rules: `.agents/rules/base.md:1:246`
- Unique global rule: `~/.cursor/rules/base.mdc` (not in repo)

## Notes

### Why Symlinks?

- **Single source of truth**: One place to edit, changes propagate everywhere
- **No sync lag**: Changes are instant (no running sync scripts)
- **Git integration**: All edits tracked in repo automatically
- **Multi-tool support**: Cursor, Claude Code, Codex, Gemini share same config
- **Backup simplicity**: Git history is the backup

### Symlink Chains Explained

Some symlinks point to other symlinks (chains):

```
~/CLAUDE.md → repo/CLAUDE.md → repo/.agents/rules/base.md
```

This works because:
1. macOS follows symlink chains automatically
2. Allows tool-specific entry points (CLAUDE.md) to share content (base.md)
3. Single edit to base.md updates all tools

### base.mdc Special Case

`base.mdc` currently lives only at `~/.cursor/rules/` (not in repo). After Phase 4, it's moved into repo so it's:
- Version controlled
- Backed up with everything else
- Accessible via symlink

Alternative: Delete it and rely on `use-base-rules.mdc` pointing to base.md. This decision is deferred to the base.md split work (separate context document).

### Safety First

The backup created in Phase 2 is critical. Keep it for at least 7 days after successful migration. If anything goes wrong, restore with:

```bash
cp -R ~/.cursor-backups/cursor-backup-YYYYMMDD-HHMMSS/ ~/.cursor/
```
