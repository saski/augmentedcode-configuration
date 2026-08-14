# Codex, Orca, Hermes, and OmniRoute runtime boundaries

**Verified locally:** 2026-08-14

## Decision

Codex's global runtime and Orca Desktop's Codex runtime remain separate. The
duplication is justified by runtime isolation and must not be removed by
symlinking or merging the directories.

The top-level `model` and `model_reasoning_effort` values in the
[versioned Codex template](../templates/codex/config.toml) are the canonical
shared defaults. Synchronize those preferences deliberately across both local
configuration files, but do not treat the rest of either file as
interchangeable. This document intentionally does not duplicate their current
values.

## Local paths

| Surface | Path | Role |
|---|---|---|
| Codex global runtime | `/Users/saski/.codex` | Codex CLI and the normal Codex runtime |
| Orca Codex runtime | `/Users/saski/Library/Application Support/orca/codex-runtime-home/home` | Codex processes launched from Orca |
| Hermes | `/Users/saski/.hermes` | Hermes configuration, provider profiles, credentials, and runtime state |
| OmniRoute | Local provider gateway, currently `http://localhost:20128/v1` | Provider/data-plane routing; independent of Codex's default model preference |

## Why Orca has its own Codex home

Orca's shell-ready configuration contains the following boundary:

```bash
# Why: Codex must keep using Orca's runtime CODEX_HOME after profile scripts.
[[ -n "${ORCA_CODEX_HOME:-}" ]] && export CODEX_HOME="${ORCA_CODEX_HOME}"
```

The Orca runtime contains more than `config.toml`: hooks, hook trust
provenance, session/memory/state databases, and app-specific runtime metadata.
Its `config.toml` also differs from the global file in hook paths, application
permissions, environment policy, marketplace freshness, and other runtime
state. These differences are operational, not mere formatting noise.

## Safe change protocol

When changing a Codex default:

1. Inspect both `config.toml` files and confirm whether `ORCA_CODEX_HOME` is
   active for the relevant process.
2. Read the intended defaults from `templates/codex/config.toml` and
   synchronize only `model` and `model_reasoning_effort`.
3. Preserve Orca-specific hooks, trust metadata, permissions, databases, and
   environment settings.
4. Do not symlink, delete, or merge the Orca runtime without an explicit,
   runtime-contract-based migration plan and a recoverable backup.
5. Verify the CLI and the app runtime separately after restarting the relevant
   app/process.

## Boundary with Hermes and OmniRoute

Hermes has its own model/provider configuration and may route ordinary text
through OmniRoute or use an explicit OpenAI/Codex lane. A Codex default change
does not change Hermes' default route, and neither Codex nor Orca should be
used as an implicit source of truth for OmniRoute's free-route policy.

Orca is an optional workspace/terminal surface. Its isolated Codex runtime is
not evidence of a Hermes-to-Orca bridge or of automatic OmniRoute routing.
