---
date: 2026-03-06
researcher: claude-4.6-opus
topic: "Config deduplication, symlink strategy, and interoperable skills"
tags: [research, configuration, symlinks, deduplication, skills, interoperability]
status: complete
---

# Research: Config Deduplication, Symlinks & Interoperable Skills

## 1. Current Inventory

### AI Tool Config Directories at `~`

| Tool | Directory | Has custom config? | Connected to repo? |
|------|-----------|-------------------|-------------------|
| Cursor | `~/.cursor/` | Yes (rules, commands, skills) | Partially (copy-sync) |
| Codex | `~/.codex/` | Minimal (config.toml) | No |
| Antigravity | `~/.antigravity/` | Extensions only | No |
| Gemini | `~/.gemini/` | GEMINI.md (empty) | No |
| Kiro | `~/.kiro/` | Empty steering/powers | No |
| VSCode | `~/.vscode/` | Extensions only | No |
| Copilot | `~/.copilot/` | Empty | No |
| Composio | `~/.composio/` | user_data.json | No |
| Mem0 | `~/.mem0/` | config.json | No |
| Langflow | `~/.langflow/` | Venv + data | No |

### Repo Structure (`~/saski/augmentedcode-configuration/`)

```
.agents/
├── commands/           # 16 command files (canonical source)
└── rules/
    ├── base.md         # Full development rulebook (all tools)
    ├── ai-feedback-learning-loop.md
    └── react-best-practices.md

.agent/
└── workflows/          # Antigravity-specific workflows
    ├── context-driven-development.md
    └── tdd-cycle.md

.cursor/
├── commands → ../.agents/commands/   (SYMLINK ✅)
├── rules/              # 11 .mdc files (Cursor-specific wrappers)
└── skills/
    ├── test-doubles-first/
    └── cwv-improvement-planner/

.claude/
└── commands → ../.agents/commands/   (SYMLINK ✅)

AGENTS.md → .agents/rules/base.md    (SYMLINK ✅)
CLAUDE.md → .agents/rules/base.md    (SYMLINK ✅)
GEMINI.md → .agents/rules/base.md    (SYMLINK ✅)
```

---

## 2. Duplication Map

### Commands (16 .md files) — TRIPLE DUPLICATION

| Location | Type | Content |
|----------|------|---------|
| Repo `.agents/commands/` | Canonical source | 16 files |
| Repo `.cursor/commands/` | Symlink → `.agents/commands/` | No duplication ✅ |
| Repo `.claude/commands/` | Symlink → `.agents/commands/` | No duplication ✅ |
| `~/.cursor/commands/` | **COPY** (not symlink) | 16 identical files ❌ |
| `~/.cursor/.agents/commands/` | **COPY** (not symlink) | 16 identical files ❌ |

**Impact**: 32 duplicated files at `~`.

### Rules (.mdc files) — DOUBLE DUPLICATION

| Location | Files | Status |
|----------|-------|--------|
| Repo `.cursor/rules/` | 11 .mdc files | Source |
| `~/.cursor/rules/` | 12 .mdc files (11 + base.mdc) | 11 identical copies ❌ |

**Note**: `base.mdc` exists **only** in `~/.cursor/rules/`. It is a Cursor-specific wrapper (shorter, no Makefile/pytest sections). The canonical `base.md` in `.agents/rules/` is a superset with project-specific sections.

### Rules (.md files) — base.md divergence

| File | Location | Purpose |
|------|----------|---------|
| `base.md` | Repo `.agents/rules/` | Full rulebook: 246 lines, includes Makefile targets, pytest, doublex, OOP, security |
| `base.md` | `~/.cursor/.agents/rules/` | **COPY** of repo's base.md ❌ |
| `base.mdc` | `~/.cursor/rules/` | Cursor wrapper: 103 lines, core principles only, no project-specific sections |

**Key difference**: `base.md` has 13+ sections (including Makefile, testing tools, OOP, security). `base.mdc` has 7 sections (generic principles only). They are NOT the same content.

### Skills — PARTIAL DUPLICATION

| Skill | Repo | `~/.cursor/skills/` | `~/.cursor/skills-cursor/` |
|-------|------|---------------------|---------------------------|
| test-doubles-first | ✅ | ✅ identical ❌ | — |
| cwv-improvement-planner | ✅ | ❌ | — |
| ownership-routing | ❌ | ✅ | — |
| create-rule | ❌ | ❌ | ✅ |
| create-skill | ❌ | ❌ | ✅ |
| create-subagent | ❌ | ❌ | ✅ |
| migrate-to-skills | ❌ | ❌ | ✅ |
| update-cursor-settings | ❌ | ❌ | ✅ |

### .agents/rules/ — DUPLICATION

| File | Repo | `~/.cursor/.agents/rules/` |
|------|------|---------------------------|
| base.md | ✅ | ✅ identical ❌ |
| ai-feedback-learning-loop.md | ✅ | ✅ identical ❌ |
| react-best-practices.md | ✅ | ✅ identical ❌ |

---

## 3. Symlink Analysis

### Existing Symlinks (in repo) ✅

- `.cursor/commands` → `../.agents/commands/`
- `.claude/commands` → `../.agents/commands/`
- `AGENTS.md` → `.agents/rules/base.md`
- `CLAUDE.md` → `.agents/rules/base.md`
- `GEMINI.md` → `.agents/rules/base.md`

### Missing Symlinks (at `~`) ❌

- `~/.cursor/commands/` — regular directory (should be symlink to repo)
- `~/.cursor/rules/` — regular directory (should be symlink to repo)
- `~/.cursor/skills/` — regular directory (no connection to repo)
- `~/.cursor/.agents/` — regular directory (should be symlink to repo)
- `~/.gemini/GEMINI.md` — empty file (could symlink to repo)

---

## 4. Sync Script Limitations

Current `sync-cursor-config.sh` behavior:

| What it syncs | Direction | Method |
|---------------|-----------|--------|
| `.agents/commands` ↔ `.cursor/commands` (repo internal) | Bidirectional | File copy |
| `.cursor/commands` ↔ `~/.cursor/commands` | Bidirectional | File copy |
| `.cursor/rules` ↔ `~/.cursor/rules` | Bidirectional | File copy |

**What it does NOT sync:**
- `.cursor/skills/` ↔ `~/.cursor/skills/`
- `.agents/rules/` ↔ `~/.cursor/.agents/rules/`
- `skills-cursor/` (not in repo at all)
- `.agent/workflows/` (Antigravity-specific, not synced)
- Any other AI tool configs (codex, kiro, gemini)

---

## 5. Tool Interoperability Analysis

### How each tool reads config

| Tool | Rules/Instructions | Commands/Prompts | Skills |
|------|-------------------|-----------------|--------|
| **Cursor** | `.cursor/rules/*.mdc` (global + project) | `.cursor/commands/*.md` | `.cursor/skills/*/SKILL.md` |
| **Claude Code** | `CLAUDE.md` at project root | `.claude/commands/*.md` | N/A (uses CLAUDE.md) |
| **Codex** | `AGENTS.md` at project root | N/A | `.codex/skills/*/SKILL.md` |
| **Gemini** | `GEMINI.md` at project root | N/A | N/A |
| **Antigravity** | `.agent/workflows/*.md` + rules | N/A | N/A |
| **Kiro** | `.kiro/steering/` + `.kiro/powers/` | N/A | `.kiro/skills/` |

### Common denominator: `.agents/` convention

The `.agents/` directory is the emerging cross-tool standard:
- `AGENTS.md` is read by Codex (and potentially others)
- `.agents/rules/base.md` is the canonical rulebook
- `.agents/commands/` is the canonical command source

### Skills portability

Skills using `SKILL.md` format are compatible with:
- Cursor (`.cursor/skills/*/SKILL.md`)
- Codex (`.codex/skills/*/SKILL.md`)
- Potentially Kiro (`.kiro/skills/*/SKILL.md`)

---

## 6. Identified Problems

### P1: No symlinks from `~` to repo
Everything at `~` is a COPY, not a symlink. Any edit in `~/.cursor/` requires running sync script to propagate to repo (and vice versa). This is error-prone and leads to drift.

### P2: Commands are duplicated 3x at `~`
Both `~/.cursor/commands/` and `~/.cursor/.agents/commands/` are independent copies with 16 files each (32 total copies of 16 originals).

### P3: Rules are duplicated 2x
11 identical `.mdc` files exist in both repo and `~/.cursor/rules/`.

### P4: Skills not synced
`test-doubles-first` is duplicated manually. `cwv-improvement-planner` is repo-only. `ownership-routing` and `skills-cursor/` are global-only.

### P5: base.mdc and base.md have diverged
`base.mdc` (Cursor wrapper) is a subset of `base.md` (full rulebook). They serve different purposes but the relationship is unclear and hard to maintain.

### P6: Other AI tools are disconnected
Codex, Kiro, Antigravity, Gemini have no connection to the repo. Config for these tools is either empty or manually maintained.

### P7: Sync script uses copies, not symlinks
The sync script copies files bidirectionally using modification time. This approach:
- Creates drift risk
- Requires manual sync runs
- Doubles disk usage (trivial but conceptually messy)

### P8: skills-cursor/ not tracked in repo
5 Cursor-specific skills (create-rule, create-skill, create-subagent, migrate-to-skills, update-cursor-settings) are not in the repo at all.

---

## 7. Constraints & Considerations

### Symlink limitations
- **Cursor global rules**: `~/.cursor/rules/` can be a symlink to a directory, but Cursor must be able to read files from it. Symlinks to directories generally work on macOS.
- **Git + symlinks**: Git tracks symlinks as text files containing the target path. When cloning on another machine, symlinks point to absolute paths that may not exist.
- **Bidirectional editing**: With symlinks, edits in `~/.cursor/rules/foo.mdc` directly modify the repo file. This is the desired behavior but means accidental edits propagate immediately.

### base.mdc vs base.md
- `base.mdc` has Cursor-specific frontmatter (`alwaysApply: true`, `globs`, `description`)
- `base.md` has project-specific sections (Makefile, pytest, doublex) that don't apply globally
- These genuinely need to be separate files with different content
- `use-base-rules.mdc` already points Cursor to `base.md` for project-level use

### What CAN be symlinked vs what needs copies
- **Can symlink**: commands/, rules/ (whole directories)
- **Cannot symlink**: base.mdc (unique to ~/.cursor/rules/, not in repo)
- **Needs careful handling**: skills/ (some are global-only, some repo-only)

---

## 8. Summary of Duplication

| Category | Duplicated files | Total copies | Could eliminate via symlinks |
|----------|-----------------|-------------|----------------------------|
| Commands at `~` | 16 × 2 locations | 32 files | Yes → symlink to repo |
| Rules at `~` | 11 .mdc files | 11 files | Yes → symlink to repo |
| .agents/rules at `~` | 3 .md files | 3 files | Yes → symlink to repo |
| Skills (test-doubles) | 4 files | 4 files | Yes → symlink to repo |
| **Total duplicated** | | **~50 files** | **All eliminable** |

---

## 9. Decisions (resolved in Q&A session)

### Q1: `~/.cursor/rules/` strategy
**Decision**: Directory symlink `~/.cursor/rules/` → repo `.cursor/rules/`.
Rename one of the `base` files to avoid conflict (handled as separate step).

### Q2: `~/.cursor/.agents/` strategy
**Decision**: Symlink `~/.cursor/.agents/` → repo `.agents/`.

### Q3: `skills-cursor/` tracking
**Decision**: Add `skills-cursor/` to repo. Symlink `~/.cursor/skills-cursor/` → repo `.cursor/skills-cursor/`.

### Q4: Global-only skills (`ownership-routing`)
**Decision**: Move all skills into repo. Symlink `~/.cursor/skills/` → repo `.cursor/skills/`. Add `.venv/` to `.gitignore`.

### Q5: Other AI tools (Codex, Kiro, Claude Code, Gemini)
**Decision**: Create symlinks at `~` for tools that support global config:
- `~/CLAUDE.md` → repo `CLAUDE.md` (→ `.agents/rules/base.md`)
- `~/.claude/` → repo `.claude/` (has `commands/` → `.agents/commands/`)
- `~/AGENTS.md` → repo `AGENTS.md` (→ `.agents/rules/base.md`)
- `~/GEMINI.md` → repo `GEMINI.md` (→ `.agents/rules/base.md`)
- Leave Codex `config.toml` and Kiro as-is (tool-specific settings).

### Q6: Sync script future
**Decision**: Repurpose into:
1. **Setup**: Create all symlinks (install on new machine)
2. **Validation**: Verify symlinks are intact
3. **Git helper**: Stage, commit, push config changes
Remove copy/watch logic.

### Q7: `base.mdc` vs `base.md` split
**Decision**: Split `base.md` into layers:
1. `base.md` → universal principles only (what applies everywhere)
2. `python-project.md` (new) → extract Python-specific sections (Makefile, pytest, doublex, OOP, pre-commit)
3. Eliminate `base.mdc` redundancy (either rename or let `use-base-rules.mdc` handle it)

---

## 10. Target Architecture (after implementation)

```
~/saski/augmentedcode-configuration/          # SINGLE SOURCE OF TRUTH
├── .agents/
│   ├── commands/                             # Canonical commands (16 files)
│   └── rules/
│       ├── base.md                           # Universal principles (trimmed)
│       ├── python-project.md                 # Python-specific rules (new)
│       ├── ai-feedback-learning-loop.md
│       └── react-best-practices.md
├── .cursor/
│   ├── commands → ../.agents/commands/       # Existing symlink
│   ├── rules/                                # 11-12 .mdc files (Cursor wrappers)
│   ├── skills/                               # All skills consolidated
│   │   ├── test-doubles-first/
│   │   ├── cwv-improvement-planner/
│   │   └── ownership-routing/                   # Moved from global-only
│   └── skills-cursor/                        # Meta-skills (moved from global-only)
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
└── sync-cursor-config.sh                     # Repurposed: setup/validate/git

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

**Result**: ~50 duplicated files eliminated. Single edit point fans out to Cursor, Claude Code, Codex, and Gemini via symlink chains.
