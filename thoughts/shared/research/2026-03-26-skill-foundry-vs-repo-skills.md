---
date: 2026-03-26
researcher: saski
topic: "Skill-foundry proposal vs current .agents/skills library"
tags: [research, skills, skill-foundry, governance]
status: complete
---

# Research: Skill-foundry proposal vs current repository skills

## Summary

The **skill-foundry** bundle under `.agents/skills/skill-foundry/` documents a governance model: taxonomy (categories and patterns), rich YAML frontmatter (`metadata` with category, pattern, owner, status, review cycle, etc.), optional `compatibility`, central **`catalog.yaml`** entries, **`references/`** for long-form material, **`assets/`** for templates, and lifecycle steps (evaluate, benchmark, optimize description, publish to catalog, retire).

The **rest of the skills library** in `.agents/skills/` (on the order of **46** top-level skill packages with `SKILL.md` at `SKILL.md` depth-two paths, per `find` on this workspace) follows the **minimal** contract defined in `.agents/rules/base.md`: each skill is a directory with `SKILL.md` whose frontmatter includes **`name`** and **`description`** only. A **`rg` search** for `^metadata:` under `.agents/skills/**/SKILL.md` matches **one** file: the nested skill-foundry `SKILL.md`.

**skills-lock.json** at repo root records **source repository and content hash** for skills synced from external packages (e.g. `pmprompt/claude-plugin-product-management`); it does **not** duplicate skill-foundry’s governance fields (category, pattern, owner, lifecycle, platforms, overlap).

**Factual delta**: the repository’s rulebook and on-disk skills align with a **lightweight** skill format; skill-foundry describes an **extended** format and a **single-skill** `catalog.yaml` today. Whether to bridge that gap is outside pure “what exists” documentation; this note records **alignment** and **differences** only.

## Detailed Findings

### Skill-foundry proposal (source of criteria)

- **Main instructions** live at `.agents/skills/skill-foundry/agents/skills/skill-foundry/SKILL.md` ([lines 21–195](.agents/skills/skill-foundry/agents/skills/skill-foundry/SKILL.md)). They define: small composable skills; description as routing; `references/` and `assets/` usage; pattern types (`tool-wrapper`, `generator`, `reviewer`, `inversion`, `pipeline`); workflow from intake through benchmark and catalog organization; output modes for create / audit / improve.
- **Taxonomy** is listed in `.agents/skills/skill-foundry/agents/taxonomy.md` ([lines 5–59](.agents/skills/skill-foundry/agents/taxonomy.md)) and mirrored in YAML keys in `.agents/skills/skill-foundry/agents/catalog.yaml` ([lines 1–16](.agents/skills/skill-foundry/agents/catalog.yaml)).
- **Lifecycle** expectations appear in `.agents/skills/skill-foundry/agents/skills/skill-foundry/references/lifecycle-playbook.md` ([lines 1–24](.agents/skills/skill-foundry/agents/skills/skill-foundry/references/lifecycle-playbook.md)), including “Add the skill to the catalog with category, pattern, owner, lifecycle state, and review metadata.”
- **Scaffolding templates**: `assets/skill-template.md` ([lines 1–35](.agents/skills/skill-foundry/agents/skills/skill-foundry/assets/skill-template.md)) shows frontmatter with `metadata.category`, `metadata.pattern`, `metadata.owner`, `metadata.status`, `metadata.review_cycle_days`, and `compatibility`. `assets/catalog-entry-template.yaml` ([lines 1–14](.agents/skills/skill-foundry/agents/skills/skill-foundry/assets/catalog-entry-template.yaml)) lists catalog fields including `benchmark_after_model_update`, `platforms`, `overlap_with`, `notes`.
- **Bundled catalog** `.agents/skills/skill-foundry/agents/catalog.yaml` ([lines 25–38](.agents/skills/skill-foundry/agents/catalog.yaml)) currently lists **one** skill under `skills:` — `skill-foundry` itself — with full governance metadata.

### Repository rulebook for skills

- `.agents/rules/base.md` section **“10. Skills (Canonical Location and Use)”** ([lines 82–88](.agents/rules/base.md)) states: canonical path `.agents/skills/`; native vs skill-factory sync; pointer to `.agents/docs/skill-factory-skills.md` for matching; trigger-based use; **format**: frontmatter **`name`** and **`description`** only.

### Current skill frontmatter patterns (sample)

- **Typical**: `name` + `description` — e.g. `.agents/skills/tdd/SKILL.md` ([lines 1–4](.agents/skills/tdd/SKILL.md)), `.agents/skills/fic-research/SKILL.md` ([lines 1–4](.agents/skills/fic-research/SKILL.md)).
- **Extra non-metadata field**: `.agents/skills/prd-writer/SKILL.md` adds `argument-hint` ([lines 1–5](.agents/skills/prd-writer/SKILL.md)).
- **Full skill-foundry-style metadata**: only `.agents/skills/skill-foundry/agents/skills/skill-foundry/SKILL.md` ([lines 1–19](.agents/skills/skill-foundry/agents/skills/skill-foundry/SKILL.md)) includes `metadata` (category, pattern, owner, status, review_cycle_days, benchmark_after_model_update, outputs) and `compatibility`.

### references/ and assets/ usage outside skill-foundry

- **`references/`** subdirectories under `.agents/skills/`: **planning-with-files/references/** (template-style files: `findings.md`, `task_plan.md`, `progress.md`) and **skill-foundry/.../references/** (eval, anti-patterns, description heuristics, lifecycle). No broad adoption of `references/` across other skills.
- **`assets/`** under `.agents/skills/`: only within the skill-foundry nested skill path (templates as listed above).

### Skill discovery and sync mechanics

- **`.agents/docs/skill-factory-skills.md`** ([lines 1–36](.agents/docs/skill-factory-skills.md)) is a **markdown table** of skill names, a coarse **Category** column, and **Purpose** text — parallel in *function* to part of a catalog (routing hints) but **not** the same schema as `catalog.yaml`.
- **`skills-lock.json`** ([lines 1–80](skills-lock.json)) maps skill keys to `source`, `sourceType`, `computedHash` for externally synced skills; it does not encode taxonomy `pattern`, `owner`, or lifecycle statuses from skill-foundry.

### Inventory note

- A workspace `find` command enumerated **46** paths matching `.agents/skills/*/SKILL.md` (depth-two `SKILL.md` files). A separate nested `SKILL.md` exists for the meta skill at `.agents/skills/skill-foundry/agents/skills/skill-foundry/SKILL.md`. Exact counts may change as directories are added or removed; the structural finding is **many** sibling skill packages vs **one** governed catalog entry.

## Code References

- `.agents/skills/skill-foundry/agents/skills/skill-foundry/SKILL.md:1-195` — Skill-foundry role, principles, patterns, workflow, guardrails.
- `.agents/skills/skill-foundry/agents/taxonomy.md:1-60` — Category and pattern definitions; governance fields to track per skill.
- `.agents/skills/skill-foundry/agents/catalog.yaml:1-38` — Taxonomy keys, lifecycle_statuses list, single `skills:` entry.
- `.agents/skills/skill-foundry/agents/skills/skill-foundry/assets/skill-template.md:1-35` — Recommended frontmatter shape for new skills.
- `.agents/rules/base.md:82-88` — Canonical minimal skill format for this repo.
- `.agents/skills/tdd/SKILL.md:1-4` — Representative minimal frontmatter.
- `.agents/skills/prd-writer/SKILL.md:1-5` — Minimal frontmatter plus `argument-hint`.
- `.agents/docs/skill-factory-skills.md:1-36` — Human-readable skill index for routing.
- `skills-lock.json:1-80` — Sync provenance and hashes for subset of skills.

## Architecture

- **Dual documentation layers**: (1) **Operational** — agents load `SKILL.md` from `.agents/skills/<skill>/` per rules; (2) **Governance / scaffolding** — skill-foundry bundle provides templates and a **partial** catalog (self-entry only). **skills-lock.json** serves **sync integrity**, not taxonomy.
- **No repo-wide YAML catalog** was found that lists all `.agents/skills/*` packages with skill-foundry’s per-skill metadata fields.

## Open Questions

- Whether a future **aggregated catalog** would live next to `skill-foundry/agents/catalog.yaml`, at repo root, or elsewhere is **not specified** in the files reviewed.
- How **native** vs **skill-factory-synced** skills would share one catalog schema (if at all) is **not defined** in `base.md` or `skill-factory-skills.md`.

## Relation to the user’s “evaluate if it should be improved” phrasing

Under **FIC research** constraints, this document does **not** prescribe changes. It states that **skill-foundry’s written criteria** include catalog entries, extended metadata, and folder conventions that **are largely absent** from the bulk of skills and **absent** from `base.md`’s required format, while **coexisting** with a separate **markdown table** and **lockfile** that already partially address discovery and sync.
