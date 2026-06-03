# types

**Purpose:** make the type checker pass honestly — not by silencing it.

## Detect

1. Run the project's type checker: `npx -y tsc --noEmit` (honor the existing `tsconfig`),
   or `mypy`/`pyright`, `go vet`, `cargo check` for the detected stack.
2. Sweep the target for type-system evasion — the AI-slop signature:
   - `any`, `as any`, `as unknown as`, `@ts-ignore`/`@ts-expect-error` with no reason,
     `# type: ignore`, non-null `!` used to mute an error rather than express an invariant.
   - `strict`/`noImplicitAny` disabled to make errors disappear.

## Triage

Real type errors first, ranked by how much they hide (a wrong return type beats an unused
`@ts-ignore`). Distinguish a legitimate escape hatch (documented external boundary) from
slop (a silenced error). Do not raise pre-existing config-level looseness as if the change
introduced it — note it separately.

## Fix policy

- Auto: nothing — narrowing a type is a semantic change.
- Propose (diff + ask): the correct type/narrowing that removes the error at the source.
  Never "fix" by adding `any`, casting, or widening a signature. Never tighten global
  config as a side effect of a targeted command (rule 1).

## Report

Type-checker errors (`file:line`, message, proposed real fix) and evasion sites
(`file:line`, what is being hidden).
