# license

**Purpose:** the legal/IP leg of due diligence — does the dependency tree put the
project's own license at risk.

## Detect

1. Read the project's declared license from the manifest. If absent, that is itself a
   top finding.
2. Enumerate dependency licenses (including transitive) with the stack's tool (SKILL.md
   § Stack detection). If none is present, read manifests and state the result is partial:

   | Stack | Tool |
   | --- | --- |
   | JS/TS | `npx -y license-checker --json` (or the pnpm/yarn equivalent) |
   | Python | `pip-licenses --format=json` |
   | Go | `go-licenses report ./...` |
   | Rust | `cargo about generate` (or `cargo-license`) |
3. Flag: copyleft (GPL/AGPL/LGPL) reaching a proprietary or permissively-licensed
   project, packages with **no** license or `UNLICENSED`, custom/unrecognized licenses,
   and missing attribution for licenses that require it (BSD/MIT/Apache NOTICE).

## Triage

Rank by legal exposure: AGPL/GPL contamination of a distributed proprietary product is
**blocking**; LGPL via dynamic linking is conditional; missing attribution is fixable;
permissive-on-permissive is clear. Distinguish runtime deps (contaminating) from
dev-only deps (generally not). Never give a legal conclusion — surface the risk and
recommend counsel for blocking cases.

## Fix policy

- Auto: nothing. License changes are decisions, not edits.
- Present remediable items as an itemized checklist — per item: the package, its license,
  the risk, and the proposed action (replace with a named compatibly-licensed equivalent,
  or add the required attribution/NOTICE entry). Apply only approved items; Confirmation
  flow per SKILL.md. Blocking legal-exposure items are flagged for counsel, not "fixed".

## Report

```
License — <target>

Project license: <id or "MISSING — top finding">

Blocking
  - <package> <license> — <exposure> — needs legal review

Matrix (grouped by risk tier)
  Copyleft/risk   <package> <license> runtime|dev   <action>
  Attribution     ...
  Clear           <count> permissive-on-permissive

Coverage gaps: <what could not be enumerated and why>
```
