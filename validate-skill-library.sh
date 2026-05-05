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

broken_symlinks_file="$(mktemp)"
absolute_symlinks_file="$(mktemp)"
invalid_frontmatter_file="$(mktemp)"
trap 'rm -f "$broken_symlinks_file" "$absolute_symlinks_file" "$invalid_frontmatter_file"' EXIT

find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type l ! -exec test -e {} \; -print | sort > "$broken_symlinks_file"
(
    while IFS= read -r path; do
        target="$(readlink "$path")"
        if [[ "$target" = /* ]]; then
            echo "$path"
        fi
    done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type l | sort)
) > "$absolute_symlinks_file"
(
    ruby -ryaml -e '
skills_dir = ARGV.fetch(0)

Dir.glob(File.join(skills_dir, "*", "SKILL.md")).sort.each do |path|
  text = File.read(path)
  unless text.start_with?("---\n")
    puts "#{path}\tmissing YAML frontmatter"
    next
  end

  parts = text.split(/^---\s*$/, 3)
  unless parts.length >= 3
    puts "#{path}\tmissing closing YAML frontmatter delimiter"
    next
  end

  begin
    YAML.safe_load(parts.fetch(1), aliases: true)
  rescue Psych::Exception => e
    message = e.message.lines.first&.strip || e.class.name
    puts "#{path}\t#{message}"
  end
end
' "$SKILLS_DIR"
) > "$invalid_frontmatter_file"
failed=0

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

skill_names_file="$(mktemp)"
catalog_names_file="$(mktemp)"
missing_catalog_entries_file="$(mktemp)"
trap 'rm -f "$broken_symlinks_file" "$absolute_symlinks_file" "$invalid_frontmatter_file" "$skill_names_file" "$catalog_names_file" "$missing_catalog_entries_file"' EXIT

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

comm -23 "$skill_names_file" "$catalog_names_file" > "$missing_catalog_entries_file"

if [[ -s "$missing_catalog_entries_file" ]]; then
    echo "missing from governance catalogs:"
    cat "$missing_catalog_entries_file"
    failed=1
fi

index_names_file="$(mktemp)"
missing_index_entries_file="$(mktemp)"
trap 'rm -f "$broken_symlinks_file" "$absolute_symlinks_file" "$invalid_frontmatter_file" "$skill_names_file" "$catalog_names_file" "$missing_catalog_entries_file" "$index_names_file" "$missing_index_entries_file"' EXIT

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

comm -23 "$skill_names_file" "$index_names_file" > "$missing_index_entries_file"

if [[ -s "$missing_index_entries_file" ]]; then
    echo "missing from skills index:"
    cat "$missing_index_entries_file"
    failed=1
fi

if [[ $failed -ne 0 ]]; then
    exit 1
fi

echo "skill library validation passed"
