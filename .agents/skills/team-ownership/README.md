# Team Ownership Determination Skill

## Location
Install path:
- `/Users/ignacio.viejo/.cursor/skills/team-ownership-determination`

## What It Does
- Classifies issue reports for ownership determination.
- Applies incident gating before ownership ranking.
- Produces deterministic, portable JSON with confidence and evidence.

## Invocation Examples
- "Determine ownership for this issue and suggest routing."
- "Classify whether this is an incident and who should own it."
- "Rank likely owner teams from endpoint and service evidence."

## Validation Commands

```bash
python3 /Users/ignacio.viejo/.codex/skills/.system/skill-creator/scripts/quick_validate.py /Users/ignacio.viejo/.cursor/skills/team-ownership-determination
python3 /Users/ignacio.viejo/.cursor/skills/team-ownership-determination/scripts/validate_contract.py
python3 /Users/ignacio.viejo/.cursor/skills/team-ownership-determination/scripts/run_fixtures.py
```

## Key Docs
- `SKILL.md`
- `reference.md`
- `connectors.md`
- `routing.md`
- `examples.md`
