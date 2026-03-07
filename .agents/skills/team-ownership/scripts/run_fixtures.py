#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from validate_contract import ValidationError, validate_instance


ROOT = Path(__file__).resolve().parent.parent
INPUT_DIR = ROOT / "examples" / "input"
OUTPUT_DIR = ROOT / "examples" / "output"
INPUT_SCHEMA = ROOT / "schemas" / "input.schema.json"
OUTPUT_SCHEMA = ROOT / "schemas" / "output.schema.json"


def _load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _expected_status(confidence: float) -> str:
    if confidence >= 0.75:
        return "owner_determined"
    if confidence >= 0.45:
        return "needs_confirmation"
    return "unowned"


def _assert_confirmation_payload(output: dict[str, Any]) -> None:
    ambiguity = output["actions"]["ambiguity_resolution"]
    if not ambiguity["required"]:
        raise ValidationError("expected ambiguity_resolution.required=true")
    if not ambiguity["channel"]:
        raise ValidationError("expected ambiguity_resolution.channel for ambiguous cases")
    template = ambiguity["message_template"] or ""
    if "Hypothesis:" not in template:
        raise ValidationError("expected Hypothesis prompt in ambiguity_resolution.message_template")


def _validate_fixture_pair(name: str, input_schema: dict[str, Any], output_schema: dict[str, Any]) -> None:
    input_payload = _load_json(INPUT_DIR / f"{name}.json")
    output_payload = _load_json(OUTPUT_DIR / f"{name}.json")

    validate_instance(input_payload, input_schema)
    validate_instance(output_payload, output_schema)

    status = output_payload["decision"]["status"]
    confidence = float(output_payload["decision"]["confidence"])

    if status == "incident_path":
        if output_payload["classification"]["incident_gate_triggered"] is not True:
            raise ValidationError(f"{name}: incident_path must set incident_gate_triggered=true")
        return

    expected = _expected_status(confidence)
    if status != expected:
        raise ValidationError(f"{name}: status {status!r} does not match confidence policy ({expected!r})")

    if status in {"needs_confirmation", "unowned"}:
        _assert_confirmation_payload(output_payload)


def main() -> int:
    input_schema = _load_json(INPUT_SCHEMA)
    output_schema = _load_json(OUTPUT_SCHEMA)

    input_names = {path.stem for path in INPUT_DIR.glob("*.json")}
    output_names = {path.stem for path in OUTPUT_DIR.glob("*.json")}
    if input_names != output_names:
        raise ValidationError(f"fixture names do not match: input={sorted(input_names)} output={sorted(output_names)}")

    for name in sorted(input_names):
        _validate_fixture_pair(name, input_schema, output_schema)
        print(f"fixture passed: {name}")

    print("all fixtures passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
