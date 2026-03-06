---
name: team-ownership-determination
description: Determine owning team for a reported issue using evidence from ownership sources, incident gating, and deterministic confidence-based routing output.
---

# Team Ownership Determination

Use this skill when you need to identify the likely owning team for a bug, incident, or request and emit a portable JSON decision payload.

## Use This Skill When
- You need ownership determination for a Jira, Slack, Zendesk, or email report.
- You need incident-vs-bug gating before normal ownership routing.
- You need candidate teams ranked with deterministic confidence thresholds.
- You need explicit evidence objects and ambiguity follow-up guidance.

## Workflow
1. Normalize issue input into the portable contract.
2. Run incident gate if enabled.
3. Collect ownership evidence from endpoint, service, feature, and team sources.
4. Score and rank candidate teams deterministically.
5. Emit output with `decision`, `classification`, `evidence`, `candidates`, and `actions`.

## Guardrails
- Always return portable JSON matching the schemas in `schemas/`.
- Never emit ownership without supporting evidence.
- For ambiguous outcomes, require a confirmation action and channel.

## Invocation Triggers
- "Who owns this bug?"
- "Determine owner and route this issue."
- "Is this an incident or a normal ownership lookup?"
- "Rank likely owner teams with confidence and evidence."

## QA Checklist
- Output validates against `schemas/output.schema.json`.
- Decision evidence references canonical ownership/runbook sources.
- Ambiguous results include hypothesis confirmation prompt.
- Incident results route to `#critical-site-incidents-and-customer-bugs`.

## References
- Contract and policy: `reference.md`
- Connector playbook: `connectors.md`
- Routing rules: `routing.md`
- Schemas: `schemas/input.schema.json`, `schemas/output.schema.json`
- Examples: `examples.md`
