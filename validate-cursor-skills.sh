#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="${1:-$(cd "$(dirname "$0")" && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CURSOR_SKILLS_DIR="$REPO_DIR/.cursor/skills-cursor"
INDEX_PATH="$REPO_DIR/.agents/docs/cursor-skills.md"

# shellcheck source=lib/validate-skill-frontmatter.sh
. "$SCRIPT_DIR/lib/validate-skill-frontmatter.sh"

if ! command -v ruby >/dev/null 2>&1; then
    echo "ruby is required to validate SKILL.md frontmatter" >&2
    exit 1
fi

if [[ ! -d "$CURSOR_SKILLS_DIR" ]]; then
    echo "missing Cursor skills directory: $CURSOR_SKILLS_DIR" >&2
    exit 1
fi

if [[ ! -f "$INDEX_PATH" ]]; then
    echo "missing Cursor skills index: $INDEX_PATH" >&2
    exit 1
fi

invalid_frontmatter_file="$(mktemp)"
skill_names_file="$(mktemp)"
index_names_file="$(mktemp)"
diff_file="$(mktemp)"
untracked_skills_file="$(mktemp)"
trap 'rm -f "$invalid_frontmatter_file" "$skill_names_file" "$index_names_file" "$diff_file" "$untracked_skills_file"' EXIT

validate_skill_frontmatter "$CURSOR_SKILLS_DIR" > "$invalid_frontmatter_file"

while IFS= read -r path; do
    if [[ -f "$path/SKILL.md" ]]; then
        basename "$path"
    fi
done < <(find "$CURSOR_SKILLS_DIR" -maxdepth 1 -mindepth 1 \( -type d -o -type l \) | sort) > "$skill_names_file"

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

failed=0

if [[ -s "$invalid_frontmatter_file" ]]; then
    echo "invalid Cursor SKILL.md frontmatter:"
    while IFS=$'\t' read -r path message; do
        echo "$(basename "$(dirname "$path")"): $message"
    done < "$invalid_frontmatter_file"
    failed=1
fi

comm -23 "$skill_names_file" "$index_names_file" > "$diff_file"
if [[ -s "$diff_file" ]]; then
    echo "missing from Cursor skills index ($INDEX_PATH):"
    cat "$diff_file"
    failed=1
fi

comm -13 "$skill_names_file" "$index_names_file" > "$diff_file"
if [[ -s "$diff_file" ]]; then
    echo "stale entries in Cursor skills index ($INDEX_PATH):"
    cat "$diff_file"
    failed=1
fi

if git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    : > "$untracked_skills_file"
    while IFS= read -r name; do
        if ! git -C "$REPO_DIR" ls-files --error-unmatch ".cursor/skills-cursor/$name" >/dev/null 2>&1; then
            echo "$name"
        fi
    done < "$skill_names_file" >> "$untracked_skills_file"
    if [[ -s "$untracked_skills_file" ]]; then
        echo "untracked Cursor skill directories (not committed to git):"
        cat "$untracked_skills_file"
        failed=1
    fi
else
    echo "not a git work tree; skipping git-tracking check" >&2
fi

if [[ $failed -ne 0 ]]; then
    exit 1
fi

echo "Cursor skills validation passed"
