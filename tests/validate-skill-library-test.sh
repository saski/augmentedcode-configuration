#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VALIDATOR="$REPO_DIR/validate-skill-library.sh"

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

create_fixture() {
    local fixture_dir="$1"

    mkdir -p "$fixture_dir/.agents/skills" \
        "$fixture_dir/.agents/docs" \
        "$fixture_dir/.agents/skills/skill-foundry/agents"
    ln -s missing-skill "$fixture_dir/.agents/skills/sample-skill"
    cat > "$fixture_dir/.agents/docs/skill-factory-skills.md" <<'EOF'
| Skill | Category | Purpose |
|-------|----------|---------|
| sample-skill | testing | Example |
EOF
    cat > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog.yaml" <<'EOF'
skills:
  - name: sample-skill
    category: skill-governance
EOF
    : > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog-engineering.yaml"
    : > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog-product-management.yaml"
}

create_local_skill_fixture() {
    local fixture_dir="$1"
    local skill_name="$2"
    local include_index="${3:-yes}"
    local include_catalog="${4:-yes}"

    mkdir -p "$fixture_dir/.agents/skills/$skill_name" \
        "$fixture_dir/.agents/docs" \
        "$fixture_dir/.agents/skills/skill-foundry/agents"
    cat > "$fixture_dir/.agents/skills/$skill_name/SKILL.md" <<EOF
---
name: $skill_name
description: Example
---
EOF
    if [[ "$include_index" == "yes" ]]; then
        cat > "$fixture_dir/.agents/docs/skill-factory-skills.md" <<EOF
| Skill | Category | Purpose |
|-------|----------|---------|
| $skill_name | testing | Example |
EOF
    else
        cat > "$fixture_dir/.agents/docs/skill-factory-skills.md" <<'EOF'
| Skill | Category | Purpose |
|-------|----------|---------|
EOF
    fi
    if [[ "$include_catalog" == "yes" ]]; then
        cat > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog.yaml" <<EOF
skills:
  - name: $skill_name
    category: skill-governance
EOF
    else
        cat > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog.yaml" <<'EOF'
skills: []
EOF
    fi
    cat > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog-engineering.yaml" <<'EOF'
skills: []
EOF
    cat > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog-product-management.yaml" <<'EOF'
skills: []
EOF
}

test_detects_broken_skill_symlink() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    trap 'rm -rf "$fixture_dir"' RETURN

    create_fixture "$fixture_dir"

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for broken skill symlink" >&2
        exit 1
    fi

    assert_contains "$output" "broken skill symlinks"
    assert_contains "$output" "sample-skill"
}

test_detects_missing_catalog_entry() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    trap 'rm -rf "$fixture_dir"' RETURN

    create_local_skill_fixture "$fixture_dir" "uncataloged-skill" "yes" "no"

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for missing catalog entry" >&2
        exit 1
    fi

    assert_contains "$output" "missing from governance catalogs"
    assert_contains "$output" "uncataloged-skill"
}

test_detects_missing_index_entry() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    trap 'rm -rf "$fixture_dir"' RETURN

    create_local_skill_fixture "$fixture_dir" "unindexed-skill" "no" "yes"

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for missing index entry" >&2
        exit 1
    fi

    assert_contains "$output" "missing from skills index"
    assert_contains "$output" "unindexed-skill"
}

test_detects_absolute_symlink() {
    local fixture_dir
    local target_dir
    fixture_dir="$(mktemp -d)"
    trap 'rm -rf "$fixture_dir"' RETURN

    create_local_skill_fixture "$fixture_dir" "portable-skill" "yes" "yes"
    target_dir="$fixture_dir/portable-target"
    mkdir -p "$target_dir"
    cat > "$target_dir/SKILL.md" <<'EOF'
---
name: portable-skill
description: Example
---
EOF
    rm -rf "$fixture_dir/.agents/skills/portable-skill"
    ln -s "$target_dir" "$fixture_dir/.agents/skills/portable-skill"

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for absolute symlink" >&2
        exit 1
    fi

    assert_contains "$output" "absolute symlinks"
    assert_contains "$output" "portable-skill"
}

test_detects_broken_skill_symlink
test_detects_missing_catalog_entry
test_detects_missing_index_entry
test_detects_absolute_symlink
