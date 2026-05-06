# Skill-foundry and repository skills — alignment plan

## Overview

Close the **governance gap** described in [research: skill-foundry vs repo skills](../research/2026-03-26-skill-foundry-vs-repo-skills.md): skill-foundry defines extended metadata, `catalog.yaml`, and lifecycle expectations, while most skills only expose `name` + `description` and there is **no** repo-wide catalog. This plan keeps **agent loading behavior** unchanged (tools still read `SKILL.md` with minimal frontmatter), adds an **optional** machine-readable library catalog, documents the **two-layer** model, and adds **lightweight validation** so the catalog cannot silently drift from on-disk skills.

## Current state analysis

- **Rulebook** (`.agents/rules/base.md` §10, lines 82–88): canonical path `.agents/skills/`; format requires frontmatter **`name`** and **`description`** only.
- **Skill-foundry** (`.agents/skills/skill-foundry/`): taxonomy in `agents/taxonomy.md`, template catalog in `agents/catalog.yaml` with **one** skill entry (`skill-foundry`), rich templates under `agents/skills/skill-foundry/assets/`.
- **Discovery for humans/agents**: `.agents/docs/skill-factory-skills.md` is a **markdown table** for skill-factory-synced skills; it does not cover all native skills and is not the same schema as `catalog.yaml`.
- **Sync integrity**: `skills-lock.json` records `source` / `computedHash` for externally versioned skills; it does **not** carry taxonomy or lifecycle fields.
- **Sync mechanics**: `sync-skill-factory.sh` symlinks from `skill-factory/output_skills` into `.agents/skills/` when the target name is absent; `pull-and-sync-skills.sh` wraps pull + sync.

**Constraints**

- Do not require every skill to adopt full `metadata` blocks immediately (high churn, easy to stall).
- Do not break Cursor/Codex/Claude skill discovery that depends on `name` + `description` in `SKILL.md`.
- Repository has **no** `Makefile` or centralized automated test target; verification must use script checks and documented commands.

## Desired end state

1. **Documented contract**: `base.md` states required vs optional frontmatter; points to the library catalog and skill-foundry for governance workflows.
2. **Single repo-wide catalog file** listing every **top-level** skill package under `.agents/skills/` (see **Locked decisions**: default rule is `./SKILL.md` present; `skill-foundry` uses the documented bundle exception), with provenance and minimal governance fields.
3. **Validation script** that fails CI/local check if a top-level skill directory is missing from the catalog or if catalog lists a non-existent path.
4. **Skill-foundry bundle** unchanged in purpose: its nested `agents/catalog.yaml` remains the **bundle’s** catalog; the new file is the **whole library** index (clear separation).

**Verification**

- `bash -n` on any new bash scripts.
- `./scripts/validate-skills-library.sh` (name TBD) exits `0` on a clean tree.
- Manual spot-check: pick three skills (native, symlinked skill-factory, plugin-lock) and confirm catalog rows match `SKILL.md` `name` and actual directory name.

## What we're NOT doing

- Bulk-editing all ~46 `SKILL.md` files to add full `metadata` / `compatibility` blocks.
- Replacing `skill-factory-skills.md` with generated output in phase 1 (optional later).
- Merging `skills-lock.json` and the new catalog into one file.
- Changing `sync-skill-factory.sh` overwrite policy or symlink layout.
- Adding PyYAML or other non-stdlib Python dependencies for v1 (catalog is **JSON**, validated with **stdlib** `json` module only).

### Locked decisions (from research open questions)

| Topic | Decision |
|-------|----------|
| Aggregated catalog location | **`.agents/skills/library-catalog.json`** (repo-wide index; separate from `.agents/skills/skill-foundry/agents/catalog.yaml`, which stays the bundle catalog for the meta-skill). |
| Native vs skill-factory vs plugin | **`provenance`** field on each catalog row: `native`, `skill-factory`, or `external-lock`. Cross-check `external-lock` keys against `skills-lock.json` in the validator (warn or fail if mismatched). |
| Catalog format | **JSON v1** for zero extra dependencies; validate with Python 3 stdlib. |
| Skill package definition | Default: directory `D` under `.agents/skills/` with **`.agents/skills/D/SKILL.md`**. **Exception:** `skill-foundry` has **no** top-level `SKILL.md`; canonical meta skill is at `.agents/skills/skill-foundry/agents/skills/skill-foundry/SKILL.md` — validator encodes this single bundle exception. |

## Implementation approach

**Strategy:** Two-layer model — **runtime** (unchanged `SKILL.md` contract) + **governance** (new `library-catalog.json` + validator + docs). Incrementally fill catalog rows; start with `category` and `provenance` only, expand to skill-foundry fields (`pattern`, `owner`, `review_cycle_days`) as needed.

## Phase 1: Documentation and rule updates

### Overview

Make the dual layer explicit in the rulebook and developer docs so future skill work does not contradict skill-foundry.

### Changes required

#### 1. `.agents/rules/base.md` (§10 Skills)

**File**: `.agents/rules/base.md`
**Changes**:

- Keep **required** format: `name`, `description` in `SKILL.md` frontmatter.
- Add bullets: **Optional** extended frontmatter (`metadata`, `compatibility`) is allowed when following the skill-foundry workflow; agents **must not** assume those keys exist on every skill.
- Add pointer to **library catalog**: `.agents/skills/library-catalog.json` (whole-repo index).
- Add pointer to **skill-foundry** meta-skill path for create/audit/benchmark workflows.

#### 2. New developer doc (optional but recommended)

**File**: `.agents/docs/skills-library-governance.md` (new)
**Changes**:

- Summarize research conclusions in 1–2 paragraphs (link to research file under `thoughts/` for local use; if `thoughts/` is gitignored, note "local research path" or duplicate minimal summary).
- Table: **Artifact** | **Purpose** — `SKILL.md`, `library-catalog.json`, `skills-lock.json`, `skill-factory-skills.md`, `skill-foundry/.../catalog.yaml`.
- Maintenance rule: when adding a top-level skill directory, update `library-catalog.json` and run validator.

### Success criteria

- [ ] `base.md` §10 reads clearly for both minimal and extended skills.
- [ ] New doc exists and is linked from `README.md` **only if** README already has a dev docs section (per project rules: user-focused README; link to dev guide). If no dev guide exists, link from `base.md` only to avoid unsolicited README churn.

---

## Phase 2: Library catalog bootstrap

### Overview

Introduce `.agents/skills/library-catalog.json` as the canonical list of top-level skills with provenance and minimal governance fields.

### Schema (v1)

```json
{
  "version": 1,
  "skills": [
    {
      "id": "tdd",
      "name": "tdd",
      "provenance": "skill-factory",
      "category": "testing",
      "pattern": "pipeline",
      "status": "active",
      "notes": "Optional free text"
    }
  ]
}
```

**Field definitions (v1)**

| Field | Required | Description |
|-------|----------|-------------|
| `id` | yes | Directory name under `.agents/skills/` (must equal basename of skill root) |
| `name` | yes | Typically same as `name` in `SKILL.md` frontmatter |
| `provenance` | yes | `native` \| `skill-factory` \| `external-lock` (if listed in `skills-lock.json`) |
| `category` | yes | One of skill-foundry taxonomy strings or `uncategorized` |
| `pattern` | no | One of skill-foundry patterns or omit |
| `status` | yes | `draft` \| `active` \| `monitor` \| `deprecated` \| `retired` |
| `notes` | no | Short string |

**Bootstrap steps**

1. List immediate subdirectories of `.agents/skills/` (ignore dotfiles, ignore files).
2. For each directory `D`, treat as a skill package if:
   - `.agents/skills/D/SKILL.md` exists, **or**
   - `D` is exactly `skill-foundry` and `.agents/skills/skill-foundry/agents/skills/skill-foundry/SKILL.md` exists.
3. Build initial `library-catalog.json`: one object per package; set `provenance` using `skills-lock.json` keys (`external-lock`) vs names listed in `.agents/docs/skill-factory-skills.md` (`skill-factory`) vs default `native`.
4. Set `category` from skill-foundry taxonomy where obvious; else `uncategorized` (backfill in later PRs).
5. Commit the catalog with complete coverage (validator must pass).

### Success criteria

- [ ] `library-catalog.json` exists and `python3 -m json.tool .agents/skills/library-catalog.json` succeeds.
- [ ] Every on-disk top-level skill package has exactly one catalog row with matching `id`.
- [ ] `skill-foundry` row exists and passes bundle-path validation.

---

## Phase 3: Validation script

### Overview

Add a maintainer-facing script so the catalog and filesystem cannot drift.

### Changes required

#### 1. `scripts/validate-skills-library.py` (or `.sh` invoking inline Python)

**File**: `scripts/validate-skills-library.py` (new)
**Changes**:

- Load `.agents/skills/library-catalog.json` (path relative to repo root via `Path(__file__).resolve().parents[1]`).
- Compute expected package ids from filesystem using Phase 2 rules (including `skill-foundry` exception).
- Fail with non-zero exit if:
  - any package on disk lacks a catalog `id`;
  - any catalog `id` has no matching package or missing `SKILL.md` (per rules);
  - duplicate `id` values;
  - unknown `provenance` enum;
  - optional: catalog `id` in `skills-lock.json` but `provenance` is not `external-lock`.
- Print concise stderr messages for each error.

#### 2. Thin wrapper (optional)

**File**: `scripts/validate-skills-library.sh` (new)
**Changes**: `#!/usr/bin/env bash`; `cd` to repo root; `python3 scripts/validate-skills-library.py`; `bash -n` on itself in docs.

### TDD note (validator only)

This repo has no shared test runner. For the validator, use **one** automated check before calling the feature complete: e.g. a tiny `scripts/test_validate_skills_library.py` that runs the validator against (1) repo root — expect success — and (2) a **temporary** copy of `library-catalog.json` with one `id` removed — expect failure; or a shell script that applies a patch and restores. Alternatively, document a **required manual negative test** once if adding pytest is out of scope.

### Success criteria

- [ ] `bash -n scripts/validate-skills-library.sh` (if wrapper exists).
- [ ] `python3 scripts/validate-skills-library.py` exits `0` after Phase 2 bootstrap.
- [ ] One negative-path check (automated mini-test or documented manual step) proves a missing catalog row is detected.

---

## Phase 4: Optional follow-ups (out of strict MVP)

Track as separate tasks if desired after Phases 1–3:

1. **Generate** `.agents/docs/skill-factory-skills.md` from catalog rows where `provenance=skill-factory` (reduces dual maintenance).
2. **CI**: If GitHub Actions (or other) exists for this repo, add a job running `python3 scripts/validate-skills-library.py`; if no CI, document the command in `skills-library-governance.md` only.
3. **Gradual frontmatter**: When touching a skill for other reasons, optionally add skill-foundry `metadata` per `assets/skill-template.md`; do not mass-migrate.

---

## Testing strategy

### Automated

- **JSON validity**: `python3 -m json.tool .agents/skills/library-catalog.json`
- **Validator**: `python3 scripts/validate-skills-library.py` on clean tree; one negative test (orphan directory) during development.

### Manual

- Spot-check three skills: one `native`, one skill-factory symlink (if present in workspace), one `skills-lock.json` entry — `id`, `name`, and `provenance` look right.

### Not applicable

- Unit test framework is not present in this repository; do not block the MVP on introducing pytest/Makefile unless you explicitly expand scope.

---

## References

- Research: `thoughts/shared/research/2026-03-26-skill-foundry-vs-repo-skills.md`
- Rules: `.agents/rules/base.md` (§10, lines 82–88)
- Skill-foundry meta: `.agents/skills/skill-foundry/agents/skills/skill-foundry/SKILL.md`
- Bundle catalog (unchanged role): `.agents/skills/skill-foundry/agents/catalog.yaml`
- Sync: `sync-skill-factory.sh` (lines 54–77: symlink loop from `output_skills`)
- Lockfile: `skills-lock.json`
