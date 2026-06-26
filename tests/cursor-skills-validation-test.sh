#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VALIDATOR="$REPO_DIR/validate-cursor-skills.sh"

_CLEANUP_DIRS=()
_cleanup() {
    for d in ${_CLEANUP_DIRS[@]+"${_CLEANUP_DIRS[@]}"}; do rm -rf "$d"; done
}
trap _cleanup EXIT

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
    _CLEANUP_DIRS+=("$fixture_dir")

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

test_detects_stale_cursor_index_entry() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    mkdir -p "$fixture_dir/.cursor/skills-cursor/real-skill" "$fixture_dir/.agents/docs"
    cat > "$fixture_dir/.cursor/skills-cursor/real-skill/SKILL.md" <<'EOF'
---
name: real-skill
description: Example
---
EOF
    cat > "$fixture_dir/.agents/docs/cursor-skills.md" <<'EOF'
| Skill | Category | Purpose |
|-------|----------|---------|
| real-skill | ide | Example |
| ghost-skill | ide | Stale entry |
EOF

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for stale Cursor skills index entry" >&2
        exit 1
    fi

    assert_contains "$output" "stale"
    assert_contains "$output" "ghost-skill"
}

test_detects_untracked_cursor_skill_dir() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    mkdir -p "$fixture_dir/.cursor/skills-cursor/tracked-skill" \
             "$fixture_dir/.cursor/skills-cursor/rogue-skill" \
             "$fixture_dir/.agents/docs"
    cat > "$fixture_dir/.cursor/skills-cursor/tracked-skill/SKILL.md" <<'EOF'
---
name: tracked-skill
description: Example
---
EOF
    cat > "$fixture_dir/.cursor/skills-cursor/rogue-skill/SKILL.md" <<'EOF'
---
name: rogue-skill
description: Example
---
EOF
    cat > "$fixture_dir/.agents/docs/cursor-skills.md" <<'EOF'
| Skill | Category | Purpose |
|-------|----------|---------|
| tracked-skill | ide | Example |
| rogue-skill | ide | Example |
EOF

    git -C "$fixture_dir" init -q
    git -C "$fixture_dir" add .cursor/skills-cursor/tracked-skill .agents/docs

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for untracked Cursor skill directory" >&2
        exit 1
    fi

    assert_contains "$output" "untracked"
    assert_contains "$output" "rogue-skill"
}

test_detects_missing_cursor_index_entry
test_detects_stale_cursor_index_entry
test_detects_untracked_cursor_skill_dir
