# Base Rule Context Split — Implementation Plan

## Overview

Extract Python-specific and Makefile-specific instructions out of `.agents/rules/base.md` so the core rulebook stays universal across repos and tools. Keep `base.md` as the canonical cross-tool entry point, but limit it to general principles plus a short contextual-loading directive that tells agents when to also read Python and Makefile rule modules.

## Current State

- `.agents/rules/base.md` currently mixes universal guidance with repo-type-specific rules:
  - Python testing/tooling rules live in `.agents/rules/base.md:128-177`.
  - Makefile execution policy and mandatory `make` commands live in `.agents/rules/base.md:179-226`.
  - Project-specific `make validate` requirements also appear in `.agents/rules/base.md:21-31` and the quick reference at `.agents/rules/base.md:228-244`.
- `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` are symlinks to `.agents/rules/base.md`, so any tool that reads the repo root gets the mixed rule set by default.
- `.cursor/rules/use-base-rules.mdc` still says `base.md` is the complete rulebook and that agents should not follow other rule files.
- `.cursor/rules/python-dev.mdc` duplicates Python and Makefile content instead of pointing at a canonical `.agents/rules/*` file.
- The March 6 research document on this split is partially stale: it assumes `.cursor/rules/base.mdc` exists, but the current repo entry point is `.cursor/rules/use-base-rules.mdc`.
- `.agents/rules/base.md` references `docs/testing/expects_guide.md`, `docs/testing/doublex_guide.md`, and `docs/testing/doublex_expects_guide.md`, but `docs/testing/` does not exist in this repo.

## Desired End State

1. `.agents/rules/base.md` contains only universal rules plus a short section describing when to load contextual rule modules.
2. `.agents/rules/python-project.md` contains Python-only guidance:
   - pytest, expects, doublex, `@patch` boundary
   - Python-specific typing/test conventions
   - Any remaining Python-only project policy that should not live in base
3. `.agents/rules/makefile-project.md` contains Makefile-only workflow guidance:
   - prefer `make` targets over direct tool calls
   - project validation expectations when a Makefile exists
   - example target usage
4. Cursor uses thin `.mdc` wrappers that point to the canonical `.agents/rules/*.md` files instead of duplicating the rules.
5. AGENTS-based tools remain workable through `base.md` alone because `base.md` explicitly tells them when to load the contextual rule files.
6. No rule file points to missing documentation.

## Out of Scope

- Converting these repo-type rules into skills.
- Changing React, TLZ, debugging, refactoring, or FIC rule behavior beyond any wording needed to stay consistent with the split.
- Reworking symlink topology for `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, or Codex defaults.
- Adding new testing guides under `docs/testing/` as part of this split. Broken references should be removed rather than replaced with invented docs.

## Design Options

### Option 1: Layered Rule Files in `.agents/rules/` with Thin Cursor Wrappers

- Keep `.agents/rules/base.md` as the universal entry point.
- Add `.agents/rules/python-project.md` and `.agents/rules/makefile-project.md`.
- Update Cursor `.mdc` files so they point to these canonical rule files.
- Add a small contextual-loading section in `base.md` so AGENTS-based tools know when to read the extra files.

**Pros**

- Matches the existing architecture: `.agents/rules/` is already the canonical shared rule location.
- Works across Cursor, Codex, Claude, and Gemini without forcing a skills-based workflow.
- Removes duplication from `.cursor/rules/python-dev.mdc`.
- Separates Python concerns from Makefile concerns so repos can opt into one or both.

**Cons**

- Requires rewiring `use-base-rules.mdc` because it currently declares `base.md` is the only rule file.
- Requires careful editing so `base.md` stays universal without losing important general TDD guidance.

### Option 2: Move the Extracted Content into Skills

- Create one or two skills for Python and Makefile workflows.
- Keep `base.md` universal and tell agents to use skills when applicable.

**Pros**

- Uses the existing skill system.
- Keeps contextual behavior out of the rulebook.

**Cons**

- Skills in this repo are task-triggered, not repo-context-triggered.
- This would be a bigger behavioral change than the user asked for.
- Cursor already has contextual rule wrappers, so skills-first would fight the current shape of the repo.

## Chosen Approach

Use **Option 1**. This keeps `.agents/rules/` as the canonical source, gives Cursor an auto-apply path, and still lets AGENTS-based tools discover the extra rule files through `base.md`.

## Implementation Approach

1. Create two canonical contextual rule files in `.agents/rules/`: one for Python, one for Makefile-driven workflows.
2. Trim `base.md` to universal guidance only, and replace direct Python/Makefile instructions with a short "Contextual Rule Loading" section.
3. Convert Cursor rule wrappers to reference the canonical contextual files instead of duplicating content.
4. Update repo docs to describe the layered model and record the change in project status.

---

## Phase 1: Create Canonical Contextual Rule Files

### Overview

Introduce explicit rule modules for Python and Makefile contexts before trimming `base.md`. This preserves all current behavior while making the later extraction straightforward.

### Files to Modify

- New: `.agents/rules/python-project.md`
- New: `.agents/rules/makefile-project.md`

### Changes Required

#### 1. Create `.agents/rules/python-project.md`

Add a canonical Python rule file that contains only Python-specific material currently embedded in `base.md`, rewritten as a coherent module. Expected content:

- Python testing/tooling choices now in `.agents/rules/base.md:136-145`
- Any Python-specific typing/test language currently mixed into `.agents/rules/base.md:146-177`
- The OOP requirement currently in `.agents/rules/base.md:31`, because it is not universal across all repo types

Keep the file focused on Python repo conventions. Do not carry over Makefile-specific command lists.

#### 2. Create `.agents/rules/makefile-project.md`

Add a canonical Makefile rule file that contains only Makefile-driven workflow policy. Expected content:

- The current `make validate` / `make check-*` expectations from `.agents/rules/base.md:23-29`
- The full Makefile policy from `.agents/rules/base.md:179-226`
- Any quick-reference wording that should remain contextual rather than universal

Write this file so it applies to any repo with a `Makefile`, not just Python repos.

#### 3. Do not propagate broken testing-guide references

Do not copy the missing `docs/testing/*` links into the new files. If those references are still useful, leave them for a separate documentation task; this split should not preserve broken links.

### Automated Success Criteria

- `test -f .agents/rules/python-project.md`
- `test -f .agents/rules/makefile-project.md`
- `rg -n 'pytest|expects|doublex|@patch|Object-Oriented Programming' .agents/rules/python-project.md`
- `rg -n 'make validate|make test-unit|make check-typing|make check-format|make check-style' .agents/rules/makefile-project.md`
- `! rg -n 'docs/testing/(expects_guide|doublex_guide|doublex_expects_guide)' .agents/rules/python-project.md .agents/rules/makefile-project.md`

---

## Phase 2: Trim `base.md` to Universal Rules Plus Context Loading

### Overview

Rewrite `base.md` so it stays the only always-loaded rulebook, but no longer contains Python or Makefile implementation details.

### Files to Modify

- `.agents/rules/base.md`

### Changes Required

#### 1. Add a short contextual-loading section

Add a section near the top of `base.md` stating:

- When the repo contains Python source or Python project markers, also read `.agents/rules/python-project.md`
- When the repo contains a `Makefile`, also read `.agents/rules/makefile-project.md`
- These contextual rules extend, not replace, the universal rules in `base.md`

This is the bridge that keeps AGENTS-based tools working without a separate wrapper file.

#### 2. Remove direct Python and Makefile details from `base.md`

Edit the current sections so only universal guidance remains:

- In `## 2. Code Quality & Coverage`, keep universal expectations such as quality and coverage, but move explicit `make` validation and pre-commit command lists out to `makefile-project.md`
- In `## 11. Test-Driven Development Rules`, keep universal TDD guidance, but move Python-only framework/tool choices and Python typing details to `python-project.md`
- Replace “run the relevant tests using the appropriate Makefile target” with universal language such as “run the repo’s canonical automated checks”
- Remove or rewrite quick-reference bullets that hard-code `make` usage

#### 3. Remove stale testing-guide links

Delete the missing `docs/testing/*` references from `base.md` instead of moving them elsewhere.

#### 4. Refresh section numbering and metadata

Update section numbers, `last_updated`, and `version` so the document reads cleanly after the extraction.

### Automated Success Criteria

- `rg -n 'python-project\\.md|makefile-project\\.md' .agents/rules/base.md`
- `! rg -n 'make validate|make test-unit|make check-typing|make check-format|make check-style|pytest as the test runner|expects library|doublex' .agents/rules/base.md`
- `! rg -n 'docs/testing/(expects_guide|doublex_guide|doublex_expects_guide)' .agents/rules/base.md`
- `rg -n 'canonical automated checks|contextual|extends the universal rules' .agents/rules/base.md`

---

## Phase 3: Rewire Cursor Entry Points to the Canonical Rule Files

### Overview

Make Cursor follow the same layered model as AGENTS-based tools. After this phase, `.cursor/rules/` should contain wrappers and activation rules, not duplicated Python/Makefile policy.

### Files to Modify

- `.cursor/rules/use-base-rules.mdc`
- `.cursor/rules/python-dev.mdc`
- New: `.cursor/rules/makefile-dev.mdc`

### Changes Required

#### 1. Update `.cursor/rules/use-base-rules.mdc`

Change the wording so it no longer claims:

- `base.md` is the complete rulebook for every context
- agents must not follow other rule files

Replace that with:

- `base.md` is the universal rulebook
- contextual rules may extend it for Python and Makefile repos
- Cursor auto-activates the relevant wrappers when those contexts are present

#### 2. Convert `.cursor/rules/python-dev.mdc` into a thin wrapper

Replace the duplicated detailed content with a short pointer to:

- `.agents/rules/base.md`
- `.agents/rules/python-project.md`

Broaden the globs so Python repo context is detected from more than `*.py` alone. Include common Python project markers such as:

- `*.py`
- `pyproject.toml`
- `pytest.ini`
- `conftest.py`
- `requirements*.txt`
- `uv.lock`
- `poetry.lock`

#### 3. Add `.cursor/rules/makefile-dev.mdc`

Create a new wrapper that activates when a repo uses Makefiles and points to:

- `.agents/rules/base.md`
- `.agents/rules/makefile-project.md`

Use Makefile-oriented globs such as:

- `Makefile`
- `**/Makefile`
- `makefile`
- `*.mk`
- `*.mak`

### Automated Success Criteria

- `test -f .cursor/rules/makefile-dev.mdc`
- `rg -n '\\.agents/rules/python-project\\.md' .cursor/rules/python-dev.mdc`
- `rg -n '\\.agents/rules/makefile-project\\.md' .cursor/rules/makefile-dev.mdc`
- `rg -n 'pyproject\\.toml|pytest\\.ini|requirements\\*\\.txt|uv\\.lock|poetry\\.lock' .cursor/rules/python-dev.mdc`
- `rg -n 'Makefile|\\.mk|\\.mak' .cursor/rules/makefile-dev.mdc`
- `! rg -n 'Do not reference or follow other rule files|Testing implementation rules \\(pytest, expects, doublex\\)|Makefile targets usage' .cursor/rules/use-base-rules.mdc`

---

## Phase 4: Update Repository Documentation and Status

### Overview

Document the new layering so future changes use the same structure, and record the split in the repo status file.

### Files to Modify

- `README.md`
- `PROJECT_STATUS.md`

### Changes Required

#### 1. Update `README.md`

Adjust the rules documentation so it matches the new design:

- Describe `.agents/rules/base.md` as the universal rulebook, not the all-in-one rulebook
- Add `.agents/rules/python-project.md` and `.agents/rules/makefile-project.md` to the documented rule structure
- Add `.cursor/rules/makefile-dev.mdc` to the Cursor rules table
- Clarify that Python and Makefile wrappers extend base rather than replacing it

#### 2. Update `PROJECT_STATUS.md`

Add a short dated entry noting:

- the base rulebook split into universal + contextual modules
- new canonical contextual rule files
- Cursor wrapper alignment

Refresh `Last Updated` to the implementation date.

### Automated Success Criteria

- `rg -n 'python-project\\.md|makefile-project\\.md|makefile-dev\\.mdc' README.md`
- `rg -n 'universal rulebook|contextual' README.md`
- `rg -n 'base rulebook split|python-project\\.md|makefile-project\\.md' PROJECT_STATUS.md`

---

## Testing and Verification Strategy

- This is a docs/rules refactor, so verification is file- and text-based rather than test-suite-based.
- Use the phase success-criteria commands as the primary automated checks.
- Final verification pass:
  - `git diff -- .agents/rules .cursor/rules README.md PROJECT_STATUS.md`
  - `rg -n 'make validate|pytest as the test runner|doublex|expects' .agents/rules/base.md .cursor/rules/use-base-rules.mdc`
  - `rg -n 'python-project\\.md|makefile-project\\.md' .agents/rules/base.md .cursor/rules README.md`

## Expected File Set After Implementation

- Modified: `.agents/rules/base.md`
- New: `.agents/rules/python-project.md`
- New: `.agents/rules/makefile-project.md`
- Modified: `.cursor/rules/use-base-rules.mdc`
- Modified: `.cursor/rules/python-dev.mdc`
- New: `.cursor/rules/makefile-dev.mdc`
- Modified: `README.md`
- Modified: `PROJECT_STATUS.md`

## References

- Current rulebook: `.agents/rules/base.md`
- Cursor base entry point: `.cursor/rules/use-base-rules.mdc`
- Existing Python wrapper: `.cursor/rules/python-dev.mdc`
- Prior research: `thoughts/shared/research/2026-03-06-base-md-split-context.md`
- Current project status: `PROJECT_STATUS.md`

## Phase List

1. [x] Create canonical contextual rule files.
2. [x] Trim `base.md` to universal rules plus context loading.
3. [x] Rewire Cursor entry points to the canonical rule files.
4. [x] Update repository documentation and status.

## Next Step

`fic-implement-plan thoughts/shared/plans/2026-03-19-base-rule-context-split.md`
