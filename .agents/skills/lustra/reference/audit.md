# audit

**Purpose:** the meta-command. One aggregated health report across every Lustra
dimension — the answer to "I inherited this code, what's here?" and to "is everything in
order?" (technical due diligence).

## Detect

Execute the other commands in **diagnostic mode only — detect and triage, do not fix
anything**, in this order, and collect their findings:

1. **Legal / risk:** `security`, `license`
2. **Supply chain:** `deps`
3. **Reliability:** `types`, `tests`
4. **Maintainability:** `deadcode`, `analyze`, `review`, `design`, `perf`
5. **Bus factor / ops:** `structure`, `docs`, `observability`, `ci`

Each runs over the whole target. Skip a dimension only if its tooling/stack is absent,
and record the skip explicitly — a gap is a due-diligence finding, not a blank. If a
dimension errors or times out, record it as Skipped with the reason and continue; a
partial audit is reported as partial, never as a pass.

`baseline` and `migrate` are **not** part of audit (they are generative, not
diagnostic). If `baseline` would have lots to do, note "no project guardrails" under
maintainability instead.

## Triage

Per dimension, assign a grade — **pass / concerns / fail** — with the one or two findings
that drove it. Surface every **blocking** item (exploitable security, copyleft
contamination, a green-but-fake test suite, a pipeline that gates nothing) at the top,
above the per-dimension detail. Do not average a fail away into a "B".

## Fix policy

Audit **never edits**. It ends by offering to drill into any single dimension with that
command (which then applies its own fix policy). One report, zero changes.

## Report

```
Lustra audit — <target>

Blocking
  - <dimension>: <finding>

Scorecard
  Legal/risk        pass|concerns|fail   <driver>
  Supply chain      ...
  Reliability       ...
  Maintainability   ...
  Bus factor/ops    ...

Detail
  <per-dimension findings, each: file:line — finding — recommended command>

Skipped
  <dimension> — <why>
```

End with the recommended next command(s), highest-risk first.
