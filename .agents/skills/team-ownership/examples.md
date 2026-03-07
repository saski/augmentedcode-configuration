# Examples and Quick Start

## Fixture Cases
- `owner_determined`: high-confidence owner identified.
- `needs_confirmation`: medium confidence with confirmation required.
- `incident_path`: incident gate triggered and escalated.
- `unowned`: low confidence, no reliable owner.

## Validate Contract

```bash
python3 /Users/ignacio.viejo/.cursor/skills/team-ownership-determination/scripts/validate_contract.py
```

Expected result:
- all input fixtures pass `input.schema.json`
- all output fixtures pass `output.schema.json`

## Run Fixture Policy Checks

```bash
python3 /Users/ignacio.viejo/.cursor/skills/team-ownership-determination/scripts/run_fixtures.py
```

Expected result:
- fixture names are paired between input and output
- status follows confidence thresholds
- ambiguous statuses include hypothesis confirmation prompts
