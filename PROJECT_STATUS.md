# Augmentedcode Configuration - Project Status

**Last Updated**: 2026-05-12
**Overall Status**: 🟢 Ready - OpenSpec docs-first installation, shared skill availability, local healthcheck automation, skill validator, governance catalogs, and symlink layout verified

---

## Recent Changes

### 2026-05-12: RTK global availability via `~/.agents` ✅

- Added canonical shared RTK hook at `.agents/hooks/rtk-rewrite.sh` with deterministic binary resolution order: `PATH` -> `~/.agents/bin/rtk` -> `/opt/homebrew/bin/rtk`.
- Converted `.claude/hooks/rtk-rewrite.sh` and `.claude/RTK.md` to symlinks pointing at canonical RTK sources under `.agents`.
- Extended `setup-symlinks.sh` to manage `~/.agents/bin` and link `~/.agents/bin/rtk` to Homebrew RTK when available; validation now reports status for this link.
- Added `tests/rtk-global-contract-test.sh` and wired it into `Makefile` to enforce the RTK global contract and fallback behavior under constrained `PATH`.
- Updated README architecture docs to document the shared RTK layout and hook resolution behavior.

### 2026-05-12: OpenSpec docs-first installation ✅

- Initialized this tooling repo with OpenSpec artifacts under `docs/openspec/` and a root `openspec` symlink for CLI compatibility.
- Added a shared `openspec` skill installer that projects can run through `~/.agents/skills/openspec/scripts/install-openspec`.
- Updated healthchecks, skill routing docs, README, development guide, and governance notes so docs/thoughts-first OpenSpec placement is explicit and validated.

### 2026-05-07: OpenSpec shared skill availability ✅

- Added native `openspec` skill guidance for OpenSpec/OPSX spec-driven development workflows.
- Registered the skill in the discovery index, domain routing guide, README, and engineering governance catalog.
- Confirmed the existing `~/.agents` symlink path exposes repo `.agents/skills/` to the configured tools.

### 2026-05-07: Skill inventory maintenance guidance ✅

- Updated the base agent rules so skill additions, removals, renames, and moves require same-change updates to the discovery index and relevant governance catalog.
- Added a healthcheck regression to keep that always-loaded guidance present.
- Clarified maintainer docs for routing, README, status, and provenance updates when skill inventory changes affect those surfaces.

### 2026-05-06: Symlink/docs hygiene follow-up ✅

- Revalidated the global symlink layout, including `~/.agents`, Codex, Claude, Cursor, Gemini, Antigravity, and Langflow paths.
- Corrected Gemini documentation so `~/.gemini/GEMINI.md` points to the repo-root `GEMINI.md` shim.
- Restored the shared Claude RTK hook expected by the Claude settings template.
- Moved generated Cursor manifests and Claude project logs out of version control while keeping shared `thoughts/` artifacts trackable.

### 2026-05-06: Local healthcheck automation ✅

- Added root `Makefile` with canonical `make check`, test, shell lint, skill validation, symlink validation, tracked-ignored reporting, and hook installation targets.
- Added tracked `hooks/pre-commit` template that runs `make check` before commits.
- Added `tests/healthcheck-automation-test.sh` to keep the healthcheck and hook contract explicit.
- Documented the workflow in `README.md` and `docs/development-guide.md`.

### 2026-05-06: Vault artifact toolchain awareness ✅

- Added `vault-artifact-toolchain` as a shared skill for Mermaid, Marp, Excalidraw, `notebooklm-py`, `yt-dlp`, `markitdown`, and Makefile-wrapped vault workflows.
- Registered the skill in the discovery index and engineering governance catalog.

### 2026-05-05: small-safe-steps frontmatter remediation ✅

- Fixed `.agents/skills/small-safe-steps/SKILL.md` by converting the YAML `description` value to a folded scalar, preserving the trigger text while making the embedded colon parser-safe.
- Verified `./validate-skill-library.sh`, `./tests/validate-skill-library-test.sh`, and shell syntax checks pass after the fix.
- Documented the remaining upstream `skill-factory` source follow-up because the sibling checkout is outside this workspace's writable roots and has unrelated local modifications.

### 2026-05-05: Skill validator frontmatter check ✅

- Added `SKILL.md` YAML frontmatter parsing to `validate-skill-library.sh` so loader-breaking skill metadata errors fail validation.
- Added a regression test for unquoted colon values in skill descriptions.
- Added a domain routing guide for shared skills with tags and usage notes.

### 2026-04-29: Matt Pocock skills compatibility pass ✅

- Registered `mattpocock/skills` in the shared discovery index and engineering governance catalog.
- Kept `tdd` owned by the Matt Pocock provenance in `skills-lock.json` and removed it from the skill-factory upstream lock so future skill-factory syncs skip it instead of overwriting it.
- Verified the global `~` symlink layout still exposes repo `.agents/skills/` to Cursor, Codex, Claude, Gemini, Antigravity, and Langflow.

### 2026-04-28: Personal knowledge vault routing ✅

- Added `personal-knowledge-routing` so durable personal context and reusable knowledge are stored in the personal vault instead of always-loaded rules.
- Updated base rules with a small persistence pointer and context-loading boundary for the vault.
- Registered the routing skill in the discovery index, README, and skill governance catalog.

### 2026-04-28: Obsidian wiki skills compatibility pass ✅

- Registered locally installed `Ar9av/obsidian-wiki` skills in the discovery index and engineering governance catalog.
- Added overlap warnings for URL ingest, conversation capture, dashboards, web research, synthesis, and graph colorizing so routing collisions stay explicit.
- Removed unsupported `hermes`/`openclaw` routes from `wiki-history-ingest`; only installed `claude` and `codex` history ingesters are advertised.
- Preserved native `skill-creator` ownership by removing the generated `Ar9av/obsidian-wiki` lock entry for that existing skill.

### 2026-04-27: Repo hygiene (tracked noise, portable defaults) ✅

- Removed `.obsidian/workspace.json` from version control so it matches `.gitignore` and Obsidian UI state stays local.
- Restored canonical `.agents/mcp.json`, `.agents/rules/codex-default.rules`, and `templates/codex/config.toml` (no machine-specific paths or personal Codex sandbox rules in the shared tree).
- Quoted YAML `description` frontmatter in `google-adk-agent-patterns`, `google-adk-setup`, and `small-safe-steps` skills for safer parsing.

### 2026-04-27: Maintenance pass (governance, symlinks, Cursor skills) ✅

- Registered `corporate-aws-cli` in `.agents/skills/skill-foundry/agents/catalog-engineering.yaml` so `./validate-skill-library.sh` stays aligned with filesystem skills (index already listed it).
- Ran `./setup-symlinks.sh setup` to restore `~/.cursor/cli-config.json` as a symlink to repo `.cursor/cli-config.json`; `./setup-symlinks.sh validate` is clean.
- Tracked `.cursor/skills-cursor/` (canvas SDK stubs, split-to-prs, manifests, and existing Cursor-only skills) so the tree matches the documented `~/.cursor/skills-cursor` symlink target.

### 2026-04-13: MCP, skill governance, and symlink hygiene ✅

- Canonical `.agents/mcp.json` Atlassian endpoint updated to `https://mcp.atlassian.com/v1/mcp` (streamable HTTP per vendor guidance).
- `catalog-engineering.yaml` and `.agents/docs/skill-factory-skills.md` now cover the Obsidian LLM Wiki stack, `skill-creator`, and Google ADK native skills so `validate-skill-library.sh` passes.
- Re-ran `./setup-symlinks.sh setup` so `~/.cursor/cli-config.json` and `~/.gemini/skills` match the documented symlink layout on this machine.

### 2026-04-13: Codex RTK symlink ✅

- `setup-symlinks.sh` now links `~/.codex/RTK.md` to `.agents/rules/RTK.md` so `AGENTS.md` `@RTK.md` embeds resolve for Codex CLI.
- Validation checks the new symlink; README and `cursor-config-management.mdc` document it.

### 2026-04-06: Skill library made self-contained ✅

- Replaced broken skill-factory symlinks in `.agents/skills/` with tracked local directories.
- Added `.agents/upstreams/skill-factory/components.lock.json` to record upstream provenance for imported skills.
- Removed tracked `.cursor/skills/` duplicates so `.agents/skills/` is the only shared skill source in the repo.
- Replaced the absolute `.claude/skills` symlink with a relative repo-local symlink.

### 2026-04-06: Repository validation and portability cleanup ✅

- Added `validate-skill-library.sh` and `tests/validate-skill-library-test.sh`.
- Validator now checks for broken imported skills, invalid `SKILL.md` frontmatter, missing governance catalog entries, missing discovery-index entries, and absolute skill symlinks.
- `setup-symlinks.sh` now derives `REPO_DIR` from the script location by default.
- `sync-skill-factory.sh` now imports tracked directories instead of creating external symlinks.

### 2026-04-06: Docs aligned to current architecture ✅

- Rewrote `README.md` as a user-focused quick-start document.
- Added `docs/development-guide.md` for maintainer and infrastructure documentation.
- Updated discovery/governance metadata for `documentation-lookup`, `strategic-compact`, and `verification-loop`.
- Generalized path-specific guidance that assumed a `~/saski` clone layout.

---

## Executive Summary

| Component | Status | Notes |
| ----- | ----- | ----- |
| Shared rules | ✅ Complete | Canonical under `.agents/rules/` |
| Shared skills | ✅ Complete | Self-contained and tracked in repo |
| Skill governance | ✅ Complete | Index and catalogs are validated |
| Local healthchecks | ✅ Complete | `make check` covers tests, shell syntax, skill validation, symlink validation, and tracked-ignored reporting |
| Local setup scripts | ✅ Complete | Path-portable defaults in place |
| Maintainer docs | ✅ Complete | Split from the user-facing README |

---

## Next Steps

1. Benchmark monitored skills (`pbt-pragmatic-adoption`, `creating-hooks`, `writing-statuslines`) after the next major model update.
2. Upstream any skill-factory improvements that should be shared back to the source repository.
3. Keep `components.lock.json`, the discovery index, and the skill-foundry catalogs aligned whenever skills change.
