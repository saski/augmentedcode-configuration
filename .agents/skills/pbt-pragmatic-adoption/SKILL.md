---
name: pbt-pragmatic-adoption
description: Pragmatic property-based testing review and first-wave adoption for this listings-webapp monorepo (Jest + fast-check, unit tests only).
---

# Pragmatic PBT Adoption Skill (listings-webapp)

## Purpose
Use this skill to find and introduce high-signal property-based tests (PBT) in this repository without destabilizing CI, over-abstracting tests, or replacing clear example-based tests.

Primary goal: strengthen logic-heavy unit tests with a small number of meaningful invariants.

## When to use
- You are reviewing unit test quality in `app/`, `packages/*`, or `cdk/`.
- You see repeated example-based tests over combinatorial inputs.
- The code under test is deterministic and mostly pure.
- You need stronger regression protection for filters, mappers, parsers, validators, ranking, ordering, or state calculations.

## When not to use
- Playwright or browser-flow tests in `e2e-tests/`.
- Snapshot-heavy UI rendering assertions.
- Highly mocked async integration flows where failures are mostly orchestration/network issues.
- Timezone/clock-sensitive formatting logic unless inputs are tightly constrained and clocks are controlled.

## Repository map for PBT decisions
- `app/src/components/**`: mostly UI tests; only target pure helper modules.
- `app/src/utils/**` and `app/src/pages/**/utils.ts`: strongest PBT zone.
- `packages/*/src/**`: mixed; use PBT for pure format/order helpers, not component rendering.
- `cdk/test/**`: infrastructure assertions; PBT usually lower value here.

## Good candidate heuristics in this repo
Prefer modules that satisfy most of these:
- Pure function, deterministic output.
- No network, no timers, no DOM requirement.
- Input space is broad (arrays, query params, optional fields, IDs).
- Existing tests enumerate many examples that encode one invariant.
- Failure can be explained as business rule breakage.

Strong candidates identified:
- `app/src/utils/arrayUtils.ts`
- `app/src/pages/validation/slug.ts`
- `app/src/pages/api/[eventId]/utils.ts` (`hasOnlyDonationTicketsAvailable`, `hasEarlyBirdTickets`, `isValidEventId`)
- `app/src/components/Body/hooks/useTrackingBeacons/transform.ts`
- `app/src/components/MoreOrganizerEvents/utils.ts` (`getEventsToShow`, `getMoreEventsFromThisOrganizerFiltered`)
- `app/src/components/SEOTags/getBaseDeepLinkAppUrl.ts`
- `app/src/utils/correlationId.ts`

Possible candidates (use care):
- `app/src/utils/eventAuth.ts` (crypto roundtrips are valid but can be heavier).
- `packages/good-to-know/src/sections/Highlights/formatDuration.ts` (valid but low business value).

Bad fit candidates:
- Component snapshots and layout assertions under `app/src/components/**`.
- Playwright specs and visual behavior.
- API handler end-to-end behavior with many mocked services (keep mostly example-based).

## How to write good properties with Jest + fast-check
1. Express a domain invariant, not implementation details.
2. Generate valid, meaningful data ranges (avoid unconstrained garbage).
3. Keep properties small and local to the module under test.
4. Use deterministic config for CI stability in this repo:
   - `numRuns: 100`
   - fixed `seed` per test file for reproducibility.
5. Keep existing example tests; add 1-3 properties per module for coverage of broad spaces.

Minimal pattern:

```ts
import fc from 'fast-check';

const PROPERTY_CONFIG = { numRuns: 100, seed: 20260319 };

it('matches domain invariant', () => {
  fc.assert(
    fc.property(arbitraryInput, (input) => {
      const result = fn(input);
      expect(result).toEqual(expectedFromInvariant(input));
    }),
    PROPERTY_CONFIG,
  );
});
```

## Readability and reproducibility rules
- One property = one invariant.
- Use simple names (`availableTickets`, `expected`, `eventId`).
- Avoid complex custom arbitraries until basic invariants are exhausted.
- Keep failure messages actionable by computing clear expected values inline.
- Prefer `--runTestsByPath` for targeted execution while adopting.

## Step-by-step workflow for future agents
1. Inspect Jest setup and test distribution (`app`, `packages`, `cdk`).
2. List pure helper modules with combinatorial inputs.
3. Mark each as `good candidate`, `possible candidate`, or `bad fit`.
4. Pick first wave: 3-7 total properties across 2-4 files max.
5. Add `fast-check` only in the package where tests are added.
6. Add one property at a time and run affected tests after each change.
7. Stop when signal is clearly improved; do not broaden scope in same pass.

## Repo-specific examples (already adopted)
- `app/src/utils/arrayUtils.test.ts`
  - Property: interleaving preserves total count and per-source ordering.
- `app/src/pages/validation/slug.test.ts`
  - Property: IDs divisible by `1003` are accepted; non-divisible are rejected.
- `app/src/pages/api/[eventId]/utils.test.ts`
  - Property: `hasOnlyDonationTicketsAvailable` equals:
    `available.length > 0 && available.every(category === 'donation')`.

## First adoption playbook
1. Start with deterministic pure functions:
   - `arrayUtils`, `slug`, ticket classification utils.
2. Next wave:
   - `transformTrackingBeacons` grouping/order invariants.
   - `getEventsToShow` and organizer filtering subset/limit invariants.
3. Later wave:
   - query mapping/normalization (`getBaseDeepLinkAppUrl`, parsing helpers).
4. Keep each wave small; validate test runtime impact before expanding.

## Do not do
- Do not add PBT to Playwright.
- Do not replace readable example tests that already communicate behavior well.
- Do not generate extremely large arrays or huge strings by default.
- Do not introduce shared PBT helper abstractions early.
- Do not assert trivial tautologies (for example, “result is array”).
- Do not make properties depend on unstable clock/network/global mutable state unless fully controlled.
