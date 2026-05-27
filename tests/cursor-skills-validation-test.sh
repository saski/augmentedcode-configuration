#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VALIDATOR="$REPO_DIR/validate-cursor-skills.sh"

assert_contains() {
    local haystack="$1"
    local needle="$2"

    if [[ "$haystack" != *"$needle"* ]]; then
        echo "expected output to contain: $needle" >&2
        echo "--- output ---" >&2
        echo "$haystack" >&2
        exit 1
    fi
}

test_detects_missing_cursor_index_entry() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    trap 'rm -rf "$fixture_dir"' RETURN

    mkdir -p "$fixture_dir/.cursor/skills-cursor/unlisted-skill" "$fixture_dir/.agents/docs"
    cat > "$fixture_dir/.cursor/skills-cursor/unlisted-skill/SKILL.md" <<'EOF'
---
name: unlisted-skill
description: Example
---
EOF
    cat > "$fixture_dir/.agents/docs/cursor-skills.md" <<'EOF'
| Skill | Category | Purpose |
|-------|----------|---------|
| listed-skill | ide | Example |
EOF

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for missing Cursor index entry" >&2
        exit 1
    fi

    assert_contains "$output" "missing from Cursor skills index"
    assert_contains "$output" "unlisted-skill"
}

test_detects_missing_cursor_index_entry
