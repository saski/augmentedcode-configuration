# Augmentedcode Configuration - Project Status

**Last Updated**: 2026-04-13
**Overall Status**: 🟢 Ready - self-contained skill library and validation are in place

---

## Recent Changes

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
- Validator now checks for broken imported skills, missing governance catalog entries, missing discovery-index entries, and absolute skill symlinks.
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
| Local setup scripts | ✅ Complete | Path-portable defaults in place |
| Maintainer docs | ✅ Complete | Split from the user-facing README |

---

## Next Steps

1. Benchmark monitored skills (`pbt-pragmatic-adoption`, `creating-hooks`, `writing-statuslines`) after the next major model update.
2. Upstream any skill-factory improvements that should be shared back to the source repository.
3. Keep `components.lock.json`, the discovery index, and the skill-foundry catalogs aligned whenever skills change.
