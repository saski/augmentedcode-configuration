---
trigger: always_on
---

<!-- last_updated: 2026-08-12 -->
<!-- version: 1.0 -->
# Augmented Code Configuration

A portable operating layer for AI-assisted development across supported coding tools.

Read and follow `.agents/rules/base.md`; this repository rulebook extends it with narrower instructions.

## Contextual Rules

- When the repository contains Python source, read `.agents/rules/python-project.md`.
- When the repository contains a `Makefile`, read `.agents/rules/makefile-project.md`.
- When the repository contains React or TSX source, read `.agents/rules/react-best-practices.md`.
- Contextual rules extend the universal rules; missing contextual files are optional.

## Canonical Validation

- Use `make check` for the complete local validation suite.
- Use `make ci-check` for the CI-portable subset.

## Skill Library Changes

- Route task-specific work through `.agents/docs/skill-factory-skills.md` before reading a matching `SKILL.md`.
- Adding, removing, renaming, or moving any skill must update the skill index and the relevant governance catalog: `.agents/skills/skill-foundry/agents/catalog-engineering.yaml`, `.agents/skills/skill-foundry/agents/catalog-product-management.yaml`, or `.agents/skills/skill-foundry/agents/catalog.yaml`.
- Update `.agents/docs/skill-domain-routing.md`, `README.md`, `PROJECT_STATUS.md`, and provenance locks when routing, user-facing inventory, status, or ownership changes.
- Run `./validate-skill-library.sh` for shared skill inventory changes and `./validate-cursor-skills.sh` for Cursor-only skill changes.
