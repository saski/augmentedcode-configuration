# Context: base.md Split into Universal + Python-Specific

## Purpose

This document provides all context needed for a future agent to split `.agents/rules/base.md` into universal principles and Python-specific sections. This work is separate from the symlink deduplication effort.

**Related work**: See `thoughts/shared/plans/2026-03-06-config-deduplication-symlinks.md` for the symlink migration plan.

---

## Current Situation

### File Comparison

| File | Location | Lines | Purpose | Content |
|------|----------|-------|---------|---------|
| **base.md** | `.agents/rules/base.md` | 246 | Full development rulebook | Universal principles + Python/pytest/Makefile specifics |
| **base.mdc** | `~/.cursor/rules/base.mdc` | 103 | Cursor global wrapper | Universal principles only (subset of base.md) |

### The Problem

**base.md contains TWO types of content:**

1. **Universal principles** (applicable to all projects, all languages):
   - Baby steps, TDD, progressive revelation
   - Code quality standards (simplicity, small functions, clear naming)
   - Communication style (contemplation, output format)
   - Mental preparation, language standards
   - Self-documenting code

2. **Python-specific implementation** (only applicable to Python projects):
   - Makefile targets (make validate, make test-unit, etc.)
   - pytest as test runner
   - expects library for assertions
   - doublex for mocking
   - OOP design requirements
   - Pre-commit checks (mypy, black, flake8)
   - Type hints everywhere

**Current state**: Both types are mixed together in base.md, making it:
- Hard to use for non-Python projects
- Confusing for AI agents (which rules apply when?)
- Difficult to maintain (changes to universal principles buried in Python-specific sections)

### base.mdc vs base.md

**base.mdc** (103 lines) is essentially what **base.md** should become after the split:
- Contains only universal principles
- No Makefile, pytest, doublex, or Python-specific content
- Has Cursor-specific frontmatter (alwaysApply: true, globs)
- Currently lives ONLY at `~/.cursor/rules/` (not in repo)

**Decision from research Q7**: Split base.md into:
1. `base.md` → universal principles only (similar to current base.mdc)
2. `python-project.md` (new) → extract Python-specific sections

---

## Research Decision Q7 (Resolved)

**Decision**: Split `base.md` into layers:
1. `base.md` → universal principles only (what applies everywhere)
2. `python-project.md` (new) → extract Python-specific sections (Makefile, pytest, doublex, OOP, pre-commit)
3. Eliminate `base.mdc` redundancy (either rename or let `use-base-rules.mdc` handle it)

**Rationale**:
- Separates universal from language-specific concerns
- Makes base.md reusable across different project types
- Python projects can include both base.md + python-project.md
- Non-Python projects only need base.md

---

## Content Analysis

### Universal Sections (Keep in base.md)

From current `base.md:1:246`, these sections are universal:

1. **Core Principles** (lines 6-17)
   - Baby steps, TDD, progressive revelation, type safety
   - Simplicity first, small components, clear naming
   - Incremental changes, question assumptions
   - Refactoring awareness, pattern detection

2. **Style Guidelines** (lines 33-39)
   - Natural expression, progressive building
   - Simple communication, avoid rushing
   - Seek clarification

3. **Output Format Requirements** (lines 41-47)
   - Contemplation phase, final answer structure
   - No skipping, no moralizing
   - Progress indicators, auto mode disclosure

4. **Process & Key Requirements** (lines 49-56)
   - Extensive contemplation, show work
   - Embrace uncertainty, persistence
   - Sequential questions

5. **Mental Preparation** (lines 58-62)
   - Contemplative walk before responses

6. **Language Standards** (lines 64-75)
   - English-only artifacts (code, docs, commits)
   - Communication flexibility (Spanish/English for team)

7. **Documentation Standards** (lines 77-90)
   - User-focused README, separate dev docs
   - README maintenance, rules maintenance

8. **Development Best Practices** (partial, lines 92-116)
   - Error handling & debugging
   - Code review & collaboration
   - Security considerations
   - Testing strategy distinction (unit/integration/E2E - universal concept)

9. **Quick Reference** (lines 217-232)
   - Summary of core practices

### Python-Specific Sections (Extract to python-project.md)

These sections are Python/project-specific:

1. **Code Quality & Coverage** (lines 19-29)
   - MANDATORY make validate requirement
   - Pre-commit checks: make check-typing, make check-format, make check-style
   - High coverage requirement

2. **Test-Driven Development Rules** (lines 118-166)
   - pytest as test runner
   - expects library for assertions
   - doublex for mocking
   - Type hints requirement
   - Strategic mocking rule (@patch vs doublex)
   - Test reference guides (expects_guide.md, doublex_guide.md)

3. **Makefile Targets Usage** (lines 168-206)
   - Complete list of make targets
   - Usage rules (never call pytest/black/mypy directly)
   - Good vs bad examples

4. **Pre-Commit Validation (MANDATORY)** (lines 208-215)
   - make validate before every commit
   - Zero tolerance policy

5. **OOP Design** (from line 29)
   - OOP requirement for all components

6. **Antigravity Workflows** (lines 234-246) - OPTIONAL
   - May be project-specific, not universal
   - Could stay in base.md or move to antigravity-specific rule

---

## File References

### Current base.md
**Path**: `.agents/rules/base.md`
**Lines**: 246 total
**Status**: Canonical source, in repo, symlinked by AGENTS.md, CLAUDE.md, GEMINI.md

### Current base.mdc
**Path**: `~/.cursor/rules/base.mdc` (NOT in repo)
**Lines**: 103 total
**Status**: Cursor-specific wrapper, universal principles only

**After symlink migration**: `base.mdc` will be copied into repo at `.cursor/rules/base.mdc` so it's version controlled.

### Proposed python-project.md
**Path**: `.agents/rules/python-project.md` (new file)
**Lines**: ~80-100 (extracted from base.md)
**Status**: To be created during split work

---

## Implementation Guidance for Future Agent

### Step 1: Read Both Files

```bash
# Read full base.md to understand all content
cat ~/saski/augmentedcode-configuration/.agents/rules/base.md

# Read base.mdc to see what universal-only looks like
cat ~/.cursor/rules/base.mdc
# Or after symlink migration:
cat ~/saski/augmentedcode-configuration/.cursor/rules/base.mdc
```

### Step 2: Extract Content

Create `python-project.md` with sections:
1. Code Quality & Coverage (from base.md lines 19-29)
2. Test-Driven Development Rules (lines 118-166)
3. Makefile Targets Usage (lines 168-206)
4. Pre-Commit Validation (lines 208-215)
5. OOP Design requirements

### Step 3: Update base.md

Trim base.md to only universal content:
- Keep: Core Principles, Style Guidelines, Output Format, Process, Mental Prep, Language, Docs, Dev Best Practices (universal parts), Quick Reference
- Remove: All Python-specific sections (moved to python-project.md)
- Result: base.md should be ~120-150 lines (similar length to base.mdc)

### Step 4: Handle base.mdc

**Option A**: Delete base.mdc (replaced by trimmed base.md)
**Option B**: Rename base.mdc to something else if it has unique Cursor metadata
**Option C**: Keep both if there's Cursor-specific frontmatter value

**Recommendation**: Compare base.mdc frontmatter with other .mdc files. If the frontmatter is the only difference, delete base.mdc and rely on base.md. If frontmatter is significant, keep base.mdc as a wrapper that points to base.md.

### Step 5: Update References

Files that reference base.md or base.mdc:
- `.cursor/rules/use-base-rules.mdc` (already points to base.md for projects)
- `AGENTS.md` (symlink to base.md)
- `CLAUDE.md` (symlink to base.md)
- `GEMINI.md` (symlink to base.md)
- Any Python projects should explicitly include python-project.md in their rules

### Step 6: Create Usage Pattern

For **Python projects**:
```markdown
# In project's .cursor/rules/python-project.mdc or similar
---
description: Python project development rules
---

Follow both:
- Universal rules: `.agents/rules/base.md`
- Python-specific rules: `.agents/rules/python-project.md`
```

For **Non-Python projects**:
```markdown
# Just reference base.md
Follow: `.agents/rules/base.md`
```

---

## Questions to Resolve During Implementation

1. **Antigravity workflows section** (lines 234-246):
   - Keep in base.md (universal)?
   - Move to python-project.md (project-specific)?
   - Create separate antigravity-workflow.md?

2. **Testing strategy distinction** (lines 114-116):
   - Keep in base.md (universal concept: unit/integration/E2E pyramid)?
   - Move to python-project.md (because it mentions pytest)?
   - **Recommendation**: Keep in base.md - the pyramid concept is universal, even if examples use pytest

3. **Boy-scout rule** (line 156):
   - Universal concept (always review before adding)?
   - Python-specific (mentions "fragile code")?
   - **Recommendation**: Keep in base.md - universal principle

4. **base.mdc fate**:
   - Delete (redundant after split)?
   - Keep as Cursor wrapper with specific frontmatter?
   - Rename to cursor-wrapper.mdc?
   - **Decision point**: Check if frontmatter has value beyond alwaysApply

5. **Documentation of split**:
   - Update README.md to explain base.md vs python-project.md?
   - Add comment at top of python-project.md referencing base.md?
   - Update PROJECT_STATUS.md?

---

## Success Criteria for Split Work

When complete, verify:
- [ ] `base.md` contains only universal principles (~120-150 lines)
- [ ] `python-project.md` exists with all Python-specific content (~80-100 lines)
- [ ] No content duplication between files
- [ ] All original base.md content preserved (split, not deleted)
- [ ] base.mdc handled (deleted or rationalized)
- [ ] use-base-rules.mdc updated if needed
- [ ] README documents the split
- [ ] PROJECT_STATUS.md reflects the change
- [ ] Python projects can reference both files
- [ ] Non-Python projects can use just base.md

---

## Related Decisions & Files

### Research Document
**Path**: `thoughts/shared/research/2026-03-06-config-deduplication-symlinks.md`
**Relevant section**: Q7 decision (lines 247-282)

### Symlink Migration Plan
**Path**: `thoughts/shared/plans/2026-03-06-config-deduplication-symlinks.md`
**Status**: In progress (separate from this work)
**Impact**: After symlink migration, base.mdc will be in repo at `.cursor/rules/base.mdc`

### Current use-base-rules.mdc
**Path**: `.cursor/rules/use-base-rules.mdc`
**Content**: Points projects to use `.agents/rules/base.md`
```markdown
# Use Base Development Rules

All AI agents working on this project must follow the comprehensive development rules and guidelines defined in:

**📋 [.agents/rules/base.md](.agents/rules/base.md)**
```

After split, this might need to reference both base.md and python-project.md.

---

## Why This Split Matters

**Before split:**
- AI agent receives base.md (246 lines) for a JavaScript project
- Gets confused by Python-specific content (pytest, doublex, Makefile)
- Tries to apply Python rules to non-Python code
- Developer has to clarify "ignore the Python parts"

**After split:**
- AI agent receives base.md (universal, ~120 lines) for ANY project
- JavaScript project: just base.md
- Python project: base.md + python-project.md
- Clear, focused rules for each context
- No confusion about what applies where

---

## Next Steps for Implementation Agent

1. **Read this context document fully**
2. **Read both current files** (base.md, base.mdc)
3. **Create implementation plan** following FIC workflow:
   - Analyze content in both files
   - Determine exact split points
   - Decide on base.mdc fate
   - Plan reference updates
4. **Execute split in phases**:
   - Phase 1: Create python-project.md
   - Phase 2: Trim base.md
   - Phase 3: Handle base.mdc
   - Phase 4: Update references
   - Phase 5: Documentation
5. **Validate split**:
   - No duplication
   - All content preserved
   - Clear usage patterns
   - References updated

---

## File Inventory for Reference

Current state (before split):

```
.agents/rules/
├── base.md                           # 246 lines (universal + python)
├── ai-feedback-learning-loop.md
└── react-best-practices.md

.cursor/rules/
├── use-base-rules.mdc                # Points to base.md
├── python-dev.mdc
├── tdd-workflow.mdc
├── refactoring.mdc
├── debugging.mdc
├── fic-workflow.mdc
├── project-status-maintenance.mdc
├── cursor-config-management.mdc
├── ai-feedback-learning-loop.mdc
├── react-best-practices.mdc
└── tlz-connection.mdc

~/.cursor/rules/
└── base.mdc                          # 103 lines (universal only, not in repo yet)
```

Target state (after split):

```
.agents/rules/
├── base.md                           # ~120-150 lines (universal only)
├── python-project.md                 # ~80-100 lines (new, Python-specific)
├── ai-feedback-learning-loop.md
└── react-best-practices.md

.cursor/rules/
├── base.mdc                          # Decision: keep, delete, or rename?
├── use-base-rules.mdc                # Updated to reference both files?
├── python-dev.mdc
└── ... (other .mdc files unchanged)
```

---

## Additional Context: Testing Libraries

The Python-specific content heavily references:

### pytest
- Test runner for Python
- Referenced in: lines 127, 204
- Guides: `docs/testing/` (if they exist)

### expects
- BDD-style assertion library
- Referenced in: line 127
- Guide: `docs/testing/expects_guide.md` (if exists)

### doublex
- Mocking library for Python
- Referenced in: lines 128, 133
- Guides: `docs/testing/doublex_guide.md`, `docs/testing/doublex_expects_guide.md`

### Makefile Targets
Full list at lines 173-187:
- make help, local-setup, build, update, add-package
- make up, down
- make check-typing, check-format, check-style, reformat
- make test-unit, test-e2e
- make validate (critical - runs all checks)

All of these are Python project infrastructure, not universal principles.

---

## End of Context Document

This document provides everything a future agent needs to complete the base.md split work. The agent should:
1. Create a detailed implementation plan (using `/fic-create-plan`)
2. Execute the split in careful phases
3. Validate no content is lost
4. Update all references
5. Document the new structure

**Timeline**: This work is independent of the symlink migration and can be done before, during, or after. However, it may be easier to do AFTER symlink migration so there's only one place to edit (the repo).
