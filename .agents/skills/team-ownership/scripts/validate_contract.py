#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parent.parent
SCHEMAS_DIR = ROOT / "schemas"
EXAMPLES_DIR = ROOT / "examples"


class ValidationError(Exception):
    pass


def _is_type(value: Any, expected: str) -> bool:
    mapping = {
        "object": isinstance(value, dict),
        "array": isinstance(value, list),
        "string": isinstance(value, str),
        "number": isinstance(value, (int, float)) and not isinstance(value, bool),
        "integer": isinstance(value, int) and not isinstance(value, bool),
        "boolean": isinstance(value, bool),
        "null": value is None,
    }
    return mapping.get(expected, False)


def _validate_type(value: Any, schema: dict[str, Any], path: str) -> None:
    expected = schema.get("type")
    if expected is None:
        return
    if isinstance(expected, list):
        if any(_is_type(value, type_name) for type_name in expected):
            return
        raise ValidationError(f"{path}: expected one of {expected}, got {type(value).__name__}")
    if not _is_type(value, expected):
        raise ValidationError(f"{path}: expected {expected}, got {type(value).__name__}")


def validate_instance(value: Any, schema: dict[str, Any], path: str = "$") -> None:
    _validate_type(value, schema, path)

    if "enum" in schema and value not in schema["enum"]:
        raise ValidationError(f"{path}: value {value!r} not in enum {schema['enum']!r}")

    if isinstance(value, str):
        min_length = schema.get("minLength")
        if min_length is not None and len(value) < min_length:
            raise ValidationError(f"{path}: string shorter than minLength={min_length}")

    if isinstance(value, (int, float)) and not isinstance(value, bool):
        minimum = schema.get("minimum")
        maximum = schema.get("maximum")
        if minimum is not None and value < minimum:
            raise ValidationError(f"{path}: {value} < minimum {minimum}")
        if maximum is not None and value > maximum:
            raise ValidationError(f"{path}: {value} > maximum {maximum}")

    if isinstance(value, dict):
        required = schema.get("required", [])
        for key in required:
            if key not in value:
                raise ValidationError(f"{path}: missing required property {key!r}")

        properties = schema.get("properties", {})
        allow_extra = schema.get("additionalProperties", True)
        for key, item in value.items():
            if key in properties:
                validate_instance(item, properties[key], f"{path}.{key}")
            elif not allow_extra:
                raise ValidationError(f"{path}: unexpected property {key!r}")

    if isinstance(value, list):
        item_schema = schema.get("items")
        if item_schema is None:
            return
        for index, item in enumerate(value):
            validate_instance(item, item_schema, f"{path}[{index}]")


def _load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _validate_dir(schema_path: Path, examples_path: Path) -> None:
    schema = _load_json(schema_path)
    files = sorted(examples_path.glob("*.json"))
    if not files:
        raise ValidationError(f"No example files found in {examples_path}")
    for file_path in files:
        instance = _load_json(file_path)
        validate_instance(instance, schema)
        print(f"validated {file_path.name}")


def main() -> int:
    _validate_dir(SCHEMAS_DIR / "input.schema.json", EXAMPLES_DIR / "input")
    _validate_dir(SCHEMAS_DIR / "output.schema.json", EXAMPLES_DIR / "output")
    print("contract validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
