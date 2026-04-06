#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="${1:-$(cd "$(dirname "$0")" && pwd)}"
SKILLS_DIR="$REPO_DIR/.agents/skills"
SKILL_FOUNDRY_DIR="$SKILLS_DIR/skill-foundry/agents"
INDEX_PATH="$REPO_DIR/.agents/docs/skill-factory-skills.md"

if [[ ! -d "$SKILLS_DIR" ]]; then
    echo "missing skills directory: $SKILLS_DIR" >&2
    exit 1
fi

mapfile -t broken_symlinks < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type l ! -exec test -e {} \; -print | sort)
mapfile -t absolute_symlinks < <(
    while IFS= read -r path; do
        target="$(readlink "$path")"
        if [[ "$target" = /* ]]; then
            echo "$path"
        fi
    done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type l | sort)
)
failed=0

if [[ ${#broken_symlinks[@]} -gt 0 ]]; then
    echo "broken skill symlinks:"
    for path in "${broken_symlinks[@]}"; do
        basename "$path"
    done
    failed=1
fi

if [[ ${#absolute_symlinks[@]} -gt 0 ]]; then
    echo "absolute symlinks:"
    for path in "${absolute_symlinks[@]}"; do
        basename "$path"
    done
    failed=1
fi

skill_names_file="$(mktemp)"
catalog_names_file="$(mktemp)"
trap 'rm -f "$skill_names_file" "$catalog_names_file"' EXIT

while IFS= read -r path; do
    if [[ -f "$path/SKILL.md" ]]; then
        basename "$path"
    fi
done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 \( -type d -o -type l \) | sort) > "$skill_names_file"
(
    grep -hE '^  - name: ' \
        "$SKILL_FOUNDRY_DIR/catalog.yaml" \
        "$SKILL_FOUNDRY_DIR/catalog-engineering.yaml" \
        "$SKILL_FOUNDRY_DIR/catalog-product-management.yaml" || true
) | sed 's/^  - name: //' | sort -u > "$catalog_names_file"

mapfile -t missing_catalog_entries < <(comm -23 "$skill_names_file" "$catalog_names_file")

if [[ ${#missing_catalog_entries[@]} -gt 0 ]]; then
    echo "missing from governance catalogs:"
    printf '%s\n' "${missing_catalog_entries[@]}"
    failed=1
fi

index_names_file="$(mktemp)"
trap 'rm -f "$skill_names_file" "$catalog_names_file" "$index_names_file"' EXIT

awk -F'|' '
    /^\|/ {
        name = $2
        gsub(/`/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        if (name != "" && name != "Skill" && name != "-------") {
            print name
        }
    }
' "$INDEX_PATH" | sort -u > "$index_names_file"

mapfile -t missing_index_entries < <(comm -23 "$skill_names_file" "$index_names_file")

if [[ ${#missing_index_entries[@]} -gt 0 ]]; then
    echo "missing from skills index:"
    printf '%s\n' "${missing_index_entries[@]}"
    failed=1
fi

if [[ $failed -ne 0 ]]; then
    exit 1
fi

echo "skill library validation passed"
