#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VALIDATOR="$REPO_DIR/validate-skill-library.sh"

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
    cat > "$fixture_dir/.agents/docs/skill-domain-routing.md" <<'EOF'
# Routing

- `sample-skill` - Example
EOF
    cat > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog.yaml" <<'EOF'
skills:
  - name: sample-skill
    category: skill-governance
EOF
    cat > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog-engineering.yaml" <<'EOF'
skills: []
EOF
    cat > "$fixture_dir/.agents/skills/skill-foundry/agents/catalog-product-management.yaml" <<'EOF'
skills: []
EOF
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
        cat > "$fixture_dir/.agents/docs/skill-domain-routing.md" <<EOF
# Routing

- \`$skill_name\` - Example
EOF
    else
        cat > "$fixture_dir/.agents/docs/skill-factory-skills.md" <<'EOF'
| Skill | Category | Purpose |
|-------|----------|---------|
EOF
        cat > "$fixture_dir/.agents/docs/skill-domain-routing.md" <<'EOF'
# Routing
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
    _CLEANUP_DIRS+=("$fixture_dir")

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
    _CLEANUP_DIRS+=("$fixture_dir")

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

test_detects_missing_routing_entry() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    create_local_skill_fixture "$fixture_dir" "unrouted-skill" "yes" "yes"
    cat > "$fixture_dir/.agents/docs/skill-domain-routing.md" <<'EOF'
# Routing
EOF

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for missing routing entry" >&2
        exit 1
    fi

    assert_contains "$output" "missing from domain routing guide"
    assert_contains "$output" "unrouted-skill"
}

test_detects_missing_index_entry() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

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
    _CLEANUP_DIRS+=("$fixture_dir")

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

test_detects_invalid_skill_frontmatter() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    create_local_skill_fixture "$fixture_dir" "invalid-yaml-skill" "yes" "yes"
    cat > "$fixture_dir/.agents/skills/invalid-yaml-skill/SKILL.md" <<'EOF'
---
name: invalid-yaml-skill
description: Invalid YAML: unquoted colon
---
EOF

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for invalid skill frontmatter" >&2
        exit 1
    fi

    assert_contains "$output" "invalid SKILL.md frontmatter"
    assert_contains "$output" "invalid-yaml-skill"
}

test_validates_utf8_frontmatter_under_ascii_locale() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    create_local_skill_fixture "$fixture_dir" "utf8-skill" "yes" "yes"
    printf -- '---\nname: utf8-skill\ndescription: Caf\303\251 workflow\n---\n' > "$fixture_dir/.agents/skills/utf8-skill/SKILL.md"

    local output
    set +e
    output="$(LC_ALL=C "$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -ne 0 ]]; then
        echo "expected validator to accept UTF-8 skill frontmatter under ASCII locale" >&2
        echo "--- output ---" >&2
        echo "$output" >&2
        exit 1
    fi

    assert_contains "$output" "skill library validation passed"
}

test_detects_stale_index_entry() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    create_local_skill_fixture "$fixture_dir" "real-skill" "yes" "yes"
    printf -- '| ghost-skill | testing | Stale entry |\n' >> "$fixture_dir/.agents/docs/skill-factory-skills.md"
    printf -- '- `ghost-skill` - Stale entry\n' >> "$fixture_dir/.agents/docs/skill-domain-routing.md"
    cat >> "$fixture_dir/.agents/skills/skill-foundry/agents/catalog.yaml" <<'EOF'
  - name: ghost-skill
    category: skill-governance
EOF

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for stale skills index entry" >&2
        exit 1
    fi

    assert_contains "$output" "stale"
    assert_contains "$output" "ghost-skill"
}

test_detects_stale_catalog_entry() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    create_local_skill_fixture "$fixture_dir" "real-skill" "yes" "yes"
    cat >> "$fixture_dir/.agents/skills/skill-foundry/agents/catalog.yaml" <<'EOF'
  - name: ghost-skill
    category: skill-governance
EOF

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for stale governance catalog entry" >&2
        exit 1
    fi

    assert_contains "$output" "stale"
    assert_contains "$output" "ghost-skill"
}

test_detects_untracked_skill_dir() {
    local fixture_dir
    fixture_dir="$(mktemp -d)"
    _CLEANUP_DIRS+=("$fixture_dir")

    create_local_skill_fixture "$fixture_dir" "tracked-skill" "yes" "yes"
    mkdir -p "$fixture_dir/.agents/skills/rogue-skill"
    cat > "$fixture_dir/.agents/skills/rogue-skill/SKILL.md" <<'EOF'
---
name: rogue-skill
description: Example
---
EOF
    printf -- '| rogue-skill | testing | Example |\n' >> "$fixture_dir/.agents/docs/skill-factory-skills.md"
    printf -- '- `rogue-skill` - Example\n' >> "$fixture_dir/.agents/docs/skill-domain-routing.md"
    cat >> "$fixture_dir/.agents/skills/skill-foundry/agents/catalog.yaml" <<'EOF'
  - name: rogue-skill
    category: skill-governance
EOF

    git -C "$fixture_dir" init -q
    git -C "$fixture_dir" add .agents/skills/tracked-skill .agents/docs .agents/skills/skill-foundry

    local output
    set +e
    output="$("$VALIDATOR" "$fixture_dir" 2>&1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo "expected validator to fail for untracked skill directory" >&2
        exit 1
    fi

    assert_contains "$output" "untracked"
    assert_contains "$output" "rogue-skill"
}

test_detects_broken_skill_symlink
test_detects_missing_catalog_entry
test_detects_missing_routing_entry
test_detects_missing_index_entry
test_detects_absolute_symlink
test_detects_invalid_skill_frontmatter
test_validates_utf8_frontmatter_under_ascii_locale
test_detects_stale_index_entry
test_detects_stale_catalog_entry
test_detects_untracked_skill_dir
