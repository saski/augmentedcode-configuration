#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FACTORY="${SKILL_FACTORY:-$REPO_DIR/../skill-factory}"
OUTPUT_SKILLS="$SKILL_FACTORY/output_skills"
CANONICAL_SKILLS="$REPO_DIR/.agents/skills"
LOCK_PATH="$REPO_DIR/.agents/upstreams/skill-factory/components.lock.json"

usage() {
    cat << EOF
Usage: $(basename "$0") [--dry-run]

Imports skill-factory output_skills into this repo's .agents/skills/ as tracked
directories. Native skills are preserved. Previously imported skill-factory
skills are refreshed in place and the provenance lock file is regenerated.

  SKILL_FACTORY  Default: \$REPO/../skill-factory (sibling directory)
  --dry-run      List what would be refreshed or imported without writing files

Example:
  SKILL_FACTORY=/path/to/skill-factory ./sync-skill-factory.sh
EOF
    exit 0
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
fi

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

if [[ ! -d "$OUTPUT_SKILLS" ]]; then
    echo "❌ skill-factory output_skills not found: $OUTPUT_SKILLS"
    echo "   Set SKILL_FACTORY to the skill-factory repo root, or clone it as a sibling."
    exit 1
fi

if [[ ! -d "$CANONICAL_SKILLS" ]]; then
    echo "❌ Canonical skills dir not found: $CANONICAL_SKILLS"
    exit 1
fi

mkdir -p "$(dirname "$LOCK_PATH")"

previous_imports_file="$(mktemp)"
current_imports_file="$(mktemp)"
trap 'rm -f "$previous_imports_file" "$current_imports_file"' EXIT

python3 - <<'PY' "$LOCK_PATH" > "$previous_imports_file"
import json
import sys
from pathlib import Path

lock_path = Path(sys.argv[1])
if not lock_path.exists():
    raise SystemExit(0)

payload = json.loads(lock_path.read_text())
for name in sorted(payload.get("skills", {})):
    print(name)
PY

added=0
refreshed=0
skipped=0

while IFS= read -r -d '' skill_md; do
    skill_dir="$(dirname "$skill_md")"
    name="$(basename "$skill_dir")"
    target="$CANONICAL_SKILLS/$name"

    if [[ -e "$target" && ! -L "$target" ]] && ! grep -qx "$name" "$previous_imports_file"; then
        ((skipped++)) || true
        if [[ "$DRY_RUN" == true ]]; then
            echo "  skip (native/custom) $name"
        fi
        continue
    fi

    printf '%s\n' "$name" >> "$current_imports_file"

    if [[ "$DRY_RUN" == true ]]; then
        if grep -qx "$name" "$previous_imports_file"; then
            echo "  refresh $name"
            ((refreshed++)) || true
        else
            echo "  import $name"
            ((added++)) || true
        fi
        continue
    fi

    rm -rf "$target"
    cp -R "$skill_dir" "$target"
    if grep -qx "$name" "$previous_imports_file"; then
        echo "  ~ $name"
        ((refreshed++)) || true
    else
        echo "  + $name"
        ((added++)) || true
    fi
done < <(find "$OUTPUT_SKILLS" -name "SKILL.md" -type f -print0 2>/dev/null | sort -z)

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo "Dry run: would import $added skill(s), refresh $refreshed, skip $skipped."
    exit 0
fi

source_commit="$(git -C "$SKILL_FACTORY" rev-parse HEAD)"

python3 - <<'PY' "$OUTPUT_SKILLS" "$LOCK_PATH" "$current_imports_file" "$source_commit"
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

output_skills = Path(sys.argv[1])
lock_path = Path(sys.argv[2])
imports_file = Path(sys.argv[3])
source_commit = sys.argv[4]
skill_names = [line.strip() for line in imports_file.read_text().splitlines() if line.strip()]

skills = {}
for name in sorted(set(skill_names)):
    matches = list(output_skills.glob(f"**/{name}/SKILL.md"))
    if not matches:
        continue
    source_dir = matches[0].parent
    digest = hashlib.sha256()
    for path in sorted(source_dir.rglob("*")):
        if path.is_file():
            digest.update(str(path.relative_to(source_dir)).encode())
            digest.update(path.read_bytes())
    skills[name] = {
        "source": "saski/skill-factory",
        "sourceType": "github",
        "sourceCommit": source_commit,
        "sourcePath": str(source_dir.relative_to(output_skills.parent)).replace("\\", "/"),
        "computedHash": digest.hexdigest(),
        "syncedAt": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
    }

payload = {
    "version": 1,
    "source": {
        "repository": "saski/skill-factory",
        "sourceType": "github",
        "sourceCommit": source_commit,
    },
    "skills": skills,
}
lock_path.write_text(json.dumps(payload, indent=2) + "\n")
PY

echo ""
echo "✅ Synced: imported $added skill(s), refreshed $refreshed, skipped $skipped."
