# deps

**Purpose:** a clear, risk-ranked picture of dependency **health and upgrades** —
outdated, deprecated, duplicated. This command reports; it does not own the fixes that
belong elsewhere: unused-dependency *deletion* is `deadcode`, vulnerability *remediation*
is `security`, and executing a major upgrade is `migrate`. `deps` flags those and hands
off; it only applies safe patch/minor bumps itself.

## Detect

Detect the stack (SKILL.md § Stack detection), then run its dependency tools:

| Stack | Outdated | Advisories |
| --- | --- | --- |
| Node | `npm outdated --json` (or the pnpm/yarn equivalent for the lockfile) | `npm audit --json` |
| Python | `pip list --outdated --format json` (or `uv pip list --outdated`) | `pip-audit` |
| Go | `go list -u -m -json all` | `govulncheck ./...` |
| Rust | `cargo outdated` | `cargo audit` |

If no tool exists for the stack, read the manifest/lockfile directly and say the result
is partial. Then inspect the manifest for deprecated packages (the package manager marks
these), two packages solving the same job, and pinned-but-ancient versions.

## Triage

Group every dependency into one of:

- **Safe** — patch/minor with no breaking notes; batch these.
- **Review** — minor with behavior changes, or a transitive security bump.
- **Major** — semver-major; report it and recommend `migrate` (one at a time).
- **Unused** — report only; `deadcode` owns the deletion decision.
- **Replace** — deprecated or duplicated; name the recommended successor.

Advisories are surfaced with their severity but are `security`'s call to remediate — note
them, do not bump them here unless the bump is also a Safe one.

## Fix policy

- Present the **Safe** group as a checklist (each package + version delta); apply only
  the approved items, only with a lockfile. Confirmation flow per SKILL.md.
- Everything else is report-and-hand-off, not edited here: Review/Replace as a proposal,
  Major → `migrate`, Unused → `deadcode`, advisories → `security`.

## Report

The five groups above. For majors, link/quote the relevant changelog breaking changes and
point to `migrate`. End with skipped items and the command that owns each handoff.
