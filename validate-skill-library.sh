#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="${1:-$(cd "$(dirname "$0")" && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO_DIR/.agents/skills"
SKILL_FOUNDRY_DIR="$SKILLS_DIR/skill-foundry/agents"
INDEX_PATH="$REPO_DIR/.agents/docs/skill-factory-skills.md"
ROUTING_PATH="$REPO_DIR/.agents/docs/skill-domain-routing.md"

# shellcheck source=lib/validate-skill-frontmatter.sh
. "$SCRIPT_DIR/lib/validate-skill-frontmatter.sh"

if ! command -v ruby >/dev/null 2>&1; then
    echo "ruby is required to validate SKILL.md frontmatter" >&2
    exit 1
fi

if [[ ! -d "$SKILLS_DIR" ]]; then
    echo "missing skills directory: $SKILLS_DIR" >&2
    exit 1
fi

broken_symlinks_file="$(mktemp)"
absolute_symlinks_file="$(mktemp)"
invalid_frontmatter_file="$(mktemp)"
skill_names_file="$(mktemp)"
catalog_names_file="$(mktemp)"
index_names_file="$(mktemp)"
routing_names_file="$(mktemp)"
diff_file="$(mktemp)"
untracked_skills_file="$(mktemp)"
trap 'rm -f "$broken_symlinks_file" "$absolute_symlinks_file" "$invalid_frontmatter_file" "$skill_names_file" "$catalog_names_file" "$index_names_file" "$routing_names_file" "$diff_file" "$untracked_skills_file"' EXIT

failed=0

find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type l ! -exec test -e {} \; -print | sort > "$broken_symlinks_file"
(
    while IFS= read -r path; do
        target="$(readlink "$path")"
        if [[ "$target" = /* ]]; then
            echo "$path"
        fi
    done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type l | sort)
) > "$absolute_symlinks_file"
validate_skill_frontmatter "$SKILLS_DIR" > "$invalid_frontmatter_file"

if [[ -s "$broken_symlinks_file" ]]; then
    echo "broken skill symlinks:"
    while IFS= read -r path; do
        basename "$path"
    done < "$broken_symlinks_file"
    failed=1
fi

if [[ -s "$absolute_symlinks_file" ]]; then
    echo "absolute symlinks:"
    while IFS= read -r path; do
        basename "$path"
    done < "$absolute_symlinks_file"
    failed=1
fi

if [[ -s "$invalid_frontmatter_file" ]]; then
    echo "invalid SKILL.md frontmatter:"
    while IFS=$'\t' read -r path message; do
        echo "$(basename "$(dirname "$path")"): $message"
    done < "$invalid_frontmatter_file"
    failed=1
fi

while IFS= read -r path; do
    if [[ -f "$path/SKILL.md" ]]; then
        basename "$path"
    fi
done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 \( -type d -o -type l \) | sort) > "$skill_names_file"

catalog_files=(
    "$SKILL_FOUNDRY_DIR/catalog.yaml"
    "$SKILL_FOUNDRY_DIR/catalog-engineering.yaml"
    "$SKILL_FOUNDRY_DIR/catalog-product-management.yaml"
)
for catalog in "${catalog_files[@]}"; do
    if [[ ! -f "$catalog" ]]; then
        echo "missing governance catalog: $catalog" >&2
        failed=1
    fi
done

(
    grep -hE '^  - name: ' "${catalog_files[@]}" 2>/dev/null || true
) | sed 's/^  - name: //' | sort -u > "$catalog_names_file"

comm -23 "$skill_names_file" "$catalog_names_file" > "$diff_file"
if [[ -s "$diff_file" ]]; then
    echo "missing from governance catalogs:"
    cat "$diff_file"
    failed=1
fi

comm -13 "$skill_names_file" "$catalog_names_file" > "$diff_file"
if [[ -s "$diff_file" ]]; then
    echo "stale entries in governance catalogs:"
    cat "$diff_file"
    failed=1
fi

if [[ ! -f "$INDEX_PATH" ]]; then
    echo "missing skills index: $INDEX_PATH" >&2
    failed=1
else
    awk -F'|' '
        /^\|/ {
            name = $2
            gsub(/`/, "", name)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
            if (name ~ /^[a-z0-9][a-z0-9-]*$/) {
                print name
            }
        }
    ' "$INDEX_PATH" | sort -u > "$index_names_file"

    comm -23 "$skill_names_file" "$index_names_file" > "$diff_file"
    if [[ -s "$diff_file" ]]; then
        echo "missing from skills index:"
        cat "$diff_file"
        failed=1
    fi

    comm -13 "$skill_names_file" "$index_names_file" > "$diff_file"
    if [[ -s "$diff_file" ]]; then
        echo "stale entries in skills index:"
        cat "$diff_file"
        failed=1
    fi
fi

if [[ ! -f "$ROUTING_PATH" ]]; then
    echo "missing domain routing guide: $ROUTING_PATH" >&2
    failed=1
else
    { grep -oE '`[a-z0-9][a-z0-9-]*`' "$ROUTING_PATH" || true; } | tr -d '`' | sort -u > "$routing_names_file"

    comm -23 "$index_names_file" "$routing_names_file" > "$diff_file"
    if [[ -s "$diff_file" ]]; then
        echo "missing from domain routing guide ($ROUTING_PATH):"
        cat "$diff_file"
        failed=1
    fi
fi

if git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    : > "$untracked_skills_file"
    while IFS= read -r name; do
        if ! git -C "$REPO_DIR" ls-files --error-unmatch ".agents/skills/$name" >/dev/null 2>&1; then
            echo "$name"
        fi
    done < "$skill_names_file" >> "$untracked_skills_file"
    if [[ -s "$untracked_skills_file" ]]; then
        echo "untracked skill directories (not committed to git):"
        cat "$untracked_skills_file"
        failed=1
    fi
else
    echo "not a git work tree; skipping git-tracking check" >&2
fi

if [[ $failed -ne 0 ]]; then
    exit 1
fi

echo "skill library validation passed"
