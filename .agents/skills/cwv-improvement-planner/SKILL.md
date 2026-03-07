---
name: cwv-improvement-planner
description: Build and prioritize Core Web Vitals improvement plans for web apps with a focus on LCP, INP, and TTFB. Use when users mention CWV, Lighthouse, PageSpeed, performance budgets, render blocking, hydration, image prioritization, CDN caching/compression, CloudFront, or Next.js web performance tuning.
---

# CWV Improvement Planner

## Goal

Turn performance findings into a prioritized, measurable rollout plan that improves field Core Web Vitals without platform-specific assumptions.

## Use This Skill When

- The user asks for a CWV plan, optimization roadmap, or performance triage.
- The context includes LCP, INP, CLS, TTFB, render-blocking resources, hydration, or preload strategy.
- The stack mentions Next.js, React, CDN/edge caching (including CloudFront), or page-speed regressions.

## Cross-Platform Rules

- Use forward-slash paths only.
- Avoid OS-specific command syntax unless the repository already standardizes it.
- Keep recommendations tool-agnostic first, then add stack-specific examples when context confirms the stack.

## Workflow

1. Establish baseline
   - Capture field metrics (RUM/CrUX) and lab traces (Lighthouse/WebPageTest/DevTools).
   - Identify highest-impact templates and user journeys (for example, list -> detail -> checkout).
2. Prioritize fundamentals first
   - Compression and caching correctness at the edge.
   - TTFB contributors and redirect chains.
   - LCP resource discovery, eager loading, and prioritization.
   - Render-blocking CSS/JS and hydration pressure.
3. Convert findings into implementation slices
   - For each issue: why it matters, what to inspect, recommended change, risk, estimated impact.
   - Add acceptance criteria and rollback notes.
4. Gate advanced experiments
   - Treat 103 Early Hints and Speculation Rules as measured experiments with explicit guardrails.
5. Define verification
   - Add before/after checks in CI and post-release monitoring thresholds.

## Output Template

Use this structure when generating a plan:

```markdown
# Core Web Vitals Improvement Plan

## Baseline
- Field baseline: LCP, INP, CLS, TTFB by device/network/route.
- Lab baseline: trace links and key waterfall observations.

## Prioritized Work
1. [High] <topic>
   - Why
   - Inspect
   - Change
   - Risks
   - Expected impact

2. [Medium] <topic>
...

## Experiments
- Hypothesis
- Scope
- Success metric
- Stop conditions

## Validation
- CI assertions
- Release checks
- RUM watch window and thresholds
```

## Detailed Guidance

See [playbook.md](playbook.md) for the topic-by-topic checklist and prioritization model.
