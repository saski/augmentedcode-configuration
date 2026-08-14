---
name: agent-config-hygiene
description: Audit and simplify agent configuration, AGENTS.md hierarchies, always-loaded rules, skill routing, client wrappers, and local runtime boundaries. Use when the user asks to review, slim, deduplicate, or clean up agentic configuration or reduce instruction/context bloat.
---

# Agent Configuration Hygiene

Audit first. Do not modify configuration unless the user explicitly asks for
changes. Preserve unrelated worktree changes and distinguish repository state
from mutable local runtime state.

## Review workflow

1. Identify the instruction surfaces that the active clients actually load:
   global instructions, repository instructions, directory rules, client
   wrappers, selected skills, templates, and local runtime configuration.
2. Classify each artifact as one of:
   - universal invariant;
   - repository contract;
   - task- or language-specific instruction;
   - explicit skill or workflow;
   - maintainer documentation;
   - mutable local runtime state.
3. Measure the always-loaded and routed word counts. Count transitive includes
   and pointers when they instruct the client to load another file.
4. Look for duplicate loading paths, broad triggers, unreferenced rules,
   machine-specific values in portable rules, and multiple sources of truth.
5. Prefer deletion, a narrower trigger, or an existing artifact before adding
   a new rule, skill, wrapper, or script.
6. Put deterministic invariants in the repository's existing validation suite.
   Keep judgment and trade-off analysis in this skill.
7. Run focused checks while iterating and the repository's canonical validation
   after meaningful changes.

## Decision rules

- Always-loaded rules contain only behavior needed across most tasks.
- Repository rules contain only project-specific entry points and invariants.
- Language guidance loads when the task touches that language, not because a
  vendored example happens to use it.
- Skills load from the active client's catalog. A full inventory is a
  maintenance artifact, not a routine routing prerequisite.
- Runtime paths, credentials, sessions, trust data, and mutable preferences stay
  local. Versioned templates define portable defaults without absorbing local
  runtime state.
- A safety boundary belongs in documentation plus a targeted workflow unless it
  must affect most tasks.

## Report

Lead with prioritized findings and cite exact files and lines. For each finding,
state the observed loading path, its ongoing cost, and the smallest reversible
improvement. Separate verified facts from client-behavior assumptions. End with
the checks run, skipped validation, and whether current changes are ready to
commit.

Do not turn this skill into an always-loaded rule. Its value comes from explicit,
occasional review.
