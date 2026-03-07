# CWV Playbook

Use this checklist to convert observations into actionable work items.

## High-Priority Fundamentals

### 1) Compression Correctness
- Verify HTML/CSS/JS/JSON/SVG return `content-encoding: br` or `gzip`.
- Ensure CDN compression is enabled and cache policy normalizes `Accept-Encoding`.
- Fix incorrect `Content-Type` values that block optimal compression behavior.
- Add CI checks that fail when critical response types are uncompressed.

### 2) TTFB
- Remove redirect chains and keep canonicalization to one redirect.
- Measure CDN hit/miss behavior and tune cache key variance.
- Instrument server paths with `Server-Timing` to isolate backend hotspots.
- Cache HTML/data safely where personalization boundaries allow.

### 3) LCP Resource Pipeline
- Identify the actual LCP candidate per key template.
- Ensure LCP image is discoverable early and not lazy-loaded.
- Use responsive sizing (`srcset/sizes` or framework equivalent) to avoid oversized downloads.
- Prefer modern formats and avoid CSS backgrounds for above-the-fold hero media.

### 4) LCP Prioritization
- Apply `fetchpriority="high"` only to the single most likely LCP image.
- Use framework-native preload/priority hooks where available.
- Validate priority and request start time in network waterfalls.

### 5) Render-Blocking Resources
- Reduce global CSS and unused route CSS.
- Move non-critical third-party scripts off the critical path.
- Remove synchronous head scripts unless explicitly required.

### 6) JS/Hydration and INP
- Analyze bundles and split large client dependencies.
- Reduce client-side scope (smaller interactive islands, less hydration work).
- Break long main-thread tasks and profile interaction handlers.
- Virtualize long lists and defer non-critical modules.

## Medium-Priority Optimization

### 7) Preload Scanner Misses
- Make critical assets discoverable in initial HTML.
- Minimize large inline CSS/JS that bloats HTML.
- Use targeted preloads for scanner-hard resources only.

### 8) Preload Correctness
- Verify `as`, `type`, and `crossorigin` match actual requests.
- Confirm preloads are reused and not duplicated.
- For responsive images, ensure preload hints include responsive attributes.

### 9) Preload Budget
- Keep preload set minimal per template.
- Remove unused preloads that compete with truly critical resources.
- Add budget checks in CI where possible.

### 10) Video Poster and Media Strategy
- Add `poster` for above-the-fold videos that may become LCP.
- Keep initial video loading lightweight when autoplay is not essential.

### 11) HTTP/3
- Enable HTTP/3 at the CDN edge when available and monitor fallback behavior.

## Experimental / Guarded

### 12) HTTP 103 Early Hints
- Start with a narrow route and 1-3 hints.
- A/B test by device/network class.
- Stop if mobile regressions or bandwidth waste appears.

### 13) Speculation Rules
- Start with conservative prefetch for highly probable next navigation.
- Promote to prerender only for very high-confidence flows.
- Track origin load and cache impact as first-class metrics.

## Ticket Slice Template

For each item, create a ticket with:

1. Why this matters
2. What to inspect
3. Proposed change
4. Risk and rollback
5. Validation steps
6. Expected impact level (High/Medium/Low)

## Verification Strategy

- Compare before/after traces on representative routes.
- Validate field metrics on a rolling window (mobile and desktop separately).
- Keep a regression watchlist for LCP, INP, TTFB, transfer size, and cache hit ratio.
