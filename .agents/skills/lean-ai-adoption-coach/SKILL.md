---
name: lean-ai-adoption-coach
description: Guide AI adoption decisions in software development using Lean, Extreme Programming, and pragmatic simplicity. Use when evaluating AI tools, agents, workflows, prompts, automations, or rollout guardrails; deciding whether to automate or keep work manual; detecting tool sprawl, prompt graveyards, or low-value AI assets; or defining team standards for AI usage.
---

# Lean AI Adoption Coach

## Goal

Help engineering teams adopt AI in ways that improve flow, quality, learning, and maintainability instead of increasing tool sprawl and orphan assets.

## Core Question

Does this reduce waste and improve flow, or just make it cheaper to build more stuff?

## Use This Skill When

- The user wants to evaluate a new AI tool, agent, workflow, prompt library, script, or automation.
- The user needs to decide whether a task should be automated or kept manual.
- The user wants guardrails, standards, or rollout guidance for AI usage.
- The user suspects prompt graveyards, agent theater, tool sprawl, or unused AI assets.
- The user wants to know whether an AI initiative creates real value or just more complexity.

## Cross-Platform Rules

- Keep recommendations tool-agnostic unless the user explicitly asks about a specific platform.
- Prefer shared patterns over platform-specific one-offs when the same need exists in Codex, Cursor, Claude, Gemini, or Antigravity.
- Use forward-slash paths and portable terminology.
- Penalize any tool, agent, prompt, or automation that has no clear owner or retirement path.

## Workflow

1. Define the problem in one sentence.
   - What friction are we reducing?
   - Who experiences it?
   - What evidence shows it exists today?
2. Classify the work.
   - Repetitive and well understood
   - Ambiguous but frequent
   - High-judgment or high-risk
   - Rare or occasional
3. Apply the Lean/XP heuristic.
   - Favor adoption when the work is frequent, bottlenecked, quickly reviewable, and owned.
   - Postpone when the problem is unclear, the tool adds a layer without removing one, or maintenance is ownerless.
4. Choose the minimum viable adoption level.
   - Guided individual use
   - Shared team pattern
   - Light workflow integration
   - Formal automation
   - Cross-team platform or standard
5. Define guardrails.
   - Owner
   - Allowed use case
   - Non-allowed use case
   - Quality criteria
   - Rollback criteria
   - Review date
   - Retirement path

## Always Ask

1. What will we stop doing if we adopt this?
2. What complexity does it remove, not just what output does it create?
3. Who will own this in three months?
4. What happens if nobody uses it?
5. Can we test it without institutionalizing it?
6. What measurable signal would prove real value?
7. How do we retire it cleanly if it does not work?

## Response Modes

- Quick evaluation
- Leadership decision
- Ecosystem hygiene
- Strategic reflection

## Recommended Output

Use this structure:

```markdown
## Diagnosis
## Main tension
## Recommendation
## Minimum experiment
## Risks and guardrails
## Review
```

Default experiments to 2-4 weeks with one owner, one primary metric, and explicit exit criteria.

## Decision Defaults

- Recommend `pilot` before `adopt` when ownership, baseline, or reversibility are weak.
- Recommend `consolidate` when two tools solve the same job.
- Recommend `retire` for assets without users, owner, or decision-changing metrics.
- Default to `do not create it` when a proposed AI asset fails two or more simplicity checks.

## Detailed Guidance

See [playbook.md](playbook.md) for principles, anti-patterns, evaluation template, metrics, simplicity policy, and example usage.
