---
name: openspec
description: >
  Spec-driven development with OpenSpec. Use when the user mentions OpenSpec, OPSX,
  spec-driven development, SDD, change proposals, delta specs, /opsx commands,
  or wants structured planning for features, migrations, refactors, or bug fixes.
metadata:
  category: workflow-automation
  pattern: pipeline
  owner: engineering
  status: active
  review_cycle_days: 90
  benchmark_after_model_update: true
  outputs:
    - change-proposal
    - delta-spec
    - design
    - task-list
    - implementation-verification
compatibility: Portable Agent Skills core; OpenSpec CLI is optional but preferred when installed.
---

# OpenSpec

Use OpenSpec as the planning layer when work needs durable requirements, reviewable intent, or a multi-session implementation trail. Keep the repository's normal engineering rules active: start implementation with tests where applicable, work in small steps, and run the project's canonical checks.

## Before You Start

1. Check whether the current repository already has an `openspec/` directory.
2. Check whether the CLI is available with `openspec --version`.
3. If OpenSpec is missing and the user asked to adopt it, initialize only after confirming the target repository and tool set.
4. If OpenSpec is present, read `openspec/config.yaml`, relevant `openspec/specs/*/spec.md`, and any active `openspec/changes/<change>/` artifacts before proposing edits.
5. Treat OpenSpec artifacts as source files: update them with the same care as code, keep language precise, and include them in validation.

## Default Workflow

Use the core OPSX path for most changes:

1. Explore unclear requirements before creating artifacts.
2. Propose the change and generate planning artifacts.
3. Review and refine `proposal.md`, delta specs, `design.md`, and `tasks.md`.
4. Apply tasks one at a time, checking off completed items in `tasks.md`.
5. Verify implementation against the proposal, specs, design, and tasks.
6. Sync and archive the change when the implementation is complete.

If slash commands are available in the active tool, prefer:

- `/opsx:explore` for investigation before committing to a change.
- `/opsx:propose <change>` for the default proposal-to-tasks path.
- `/opsx:apply <change>` for implementation.
- `/opsx:verify <change>` when the expanded workflow is enabled.
- `/opsx:sync <change>` to merge delta specs into canonical specs when needed.
- `/opsx:archive <change>` to finalize completed work.

If the tool does not expose slash commands, perform the same workflow directly in files under `openspec/changes/<change>/`.

## CLI Use

Prefer CLI commands for repository state and validation when available:

```bash
openspec list
openspec list --specs
openspec show <change-or-spec>
openspec status <change>
openspec validate --all
```

Use `--json` for agent-readable output when the command supports it. Do not build long-lived automation on beta workspace commands unless the user explicitly asks for experimental workspace setup.

## Artifact Standards

- Name change folders in kebab-case and avoid generic names like `update` or `wip`.
- Write requirements with `SHALL` statements and concrete scenarios.
- Keep scenarios in `GIVEN`, `WHEN`, `THEN`, and optional `AND` form.
- Keep tasks small enough to implement and verify independently.
- Update the design when implementation decisions change.
- Run OpenSpec validation and the repository's canonical validation before claiming completion.

## Brownfield Repositories

OpenSpec works incrementally. Do not try to generate a full specification library upfront unless the user asks for a documentation pass. For mature codebases, create or update specs around the change being made, then let the spec library grow through real work.

## Setup Guidance

When initializing OpenSpec, choose the smallest tool scope that matches the user's request:

```bash
openspec init
openspec init --tools claude,cursor,codex
openspec init --tools all
openspec update
```

After upgrading the CLI, run `openspec update` in initialized repositories so generated tool instructions stay current.
