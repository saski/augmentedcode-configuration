# perf

**Purpose:** find code that is correct but wasteful — the slop that works and is slow.

## Detect

Static reading of the target (no synthetic benchmarking unless the user asks):

- N+1 queries / calls in a loop, awaits serialized inside a loop that could batch.
- Synchronous or blocking IO on a hot/request path.
- Unbounded growth: loading a whole collection to use one item, missing pagination,
  caches with no eviction, recursion without a bound.
- Repeated work: recomputation that could be hoisted/memoized, redundant re-renders
  (framework-specific), O(n²) where O(n) is trivial.
- Bundle weight (front-end stacks only, and only if a build output exists): a heavy
  dependency used for one helper, a missing dynamic import on a large rarely-used path.

| Stack | Bundle inspector |
| --- | --- |
| Webpack | `webpack-bundle-analyzer` on existing stats |
| Vite/Rollup | `rollup-plugin-visualizer` output |
| Any with source maps | `npx -y source-map-explorer` |

Skip this step entirely for non-front-end stacks and say so.

## Triage

Rank by `frequency of the path × cost of the waste`. A slow startup script is not a slow
request handler. Skip micro-optimizations with no measurable impact — say so rather than
listing them. Flag only what you can name concretely (the loop, the query, the import).

## Fix policy

- Auto: nothing — perf changes alter behavior risk.
- Present the transforms as an itemized checklist, one per finding: the specific change
  (batch, hoist, paginate, lazy-load), why it is faster, and any correctness caveat.
  Apply only approved items; Confirmation flow per SKILL.md.

## Report

Findings ranked by impact: `file:line` — the waste — the hot path it sits on — proposed fix.
