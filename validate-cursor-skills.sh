#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="${1:-$(cd "$(dirname "$0")" && pwd)}"
CURSOR_SKILLS_DIR="$REPO_DIR/.cursor/skills-cursor"
INDEX_PATH="$REPO_DIR/.agents/docs/cursor-skills.md"

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
missing_index_entries_file="$(mktemp)"
trap 'rm -f "$invalid_frontmatter_file" "$skill_names_file" "$index_names_file" "$missing_index_entries_file"' EXIT

(
    ruby -ryaml -e '
Encoding.default_external = Encoding::UTF_8
skills_dir = ARGV.fetch(0)

Dir.glob(File.join(skills_dir, "*", "SKILL.md")).sort.each do |path|
  text = File.read(path, mode: "r:UTF-8")
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
' "$CURSOR_SKILLS_DIR"
) > "$invalid_frontmatter_file"

while IFS= read -r path; do
    if [[ -f "$path/SKILL.md" ]]; then
        basename "$path"
    fi
done < <(find "$CURSOR_SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d | sort) > "$skill_names_file"

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

failed=0

if [[ -s "$invalid_frontmatter_file" ]]; then
    echo "invalid Cursor SKILL.md frontmatter:"
    while IFS=$'\t' read -r path message; do
        echo "$(basename "$(dirname "$path")"): $message"
    done < "$invalid_frontmatter_file"
    failed=1
fi

if [[ -s "$missing_index_entries_file" ]]; then
    echo "missing from Cursor skills index ($INDEX_PATH):"
    cat "$missing_index_entries_file"
    failed=1
fi

if [[ $failed -ne 0 ]]; then
    exit 1
fi

echo "Cursor skills validation passed"
