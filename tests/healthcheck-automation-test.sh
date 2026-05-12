#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

assert_file_exists() {
    local path="$1"

    if [[ ! -e "$path" ]]; then
        echo "expected file to exist: $path" >&2
        exit 1
    fi
}

assert_executable() {
    local path="$1"

    if [[ ! -x "$path" ]]; then
        echo "expected file to be executable: $path" >&2
        exit 1
    fi
}

assert_contains() {
    local path="$1"
    local expected="$2"

    if ! grep -Fq "$expected" "$path"; then
        echo "expected $path to contain: $expected" >&2
        exit 1
    fi
}

test_healthcheck_automation_contract() {
    local makefile="$REPO_DIR/Makefile"
    local hook="$REPO_DIR/hooks/pre-commit"

    assert_file_exists "$makefile"
    assert_contains "$makefile" "check:"
    assert_contains "$makefile" "test:"
    assert_contains "$makefile" "lint-shell:"
    assert_contains "$makefile" "validate-skills:"
    assert_contains "$makefile" "validate-openspec:"
    assert_contains "$makefile" "validate-symlinks:"
    assert_contains "$makefile" "check-tracked-ignored:"
    assert_contains "$makefile" "install-hooks:"
    assert_contains "$makefile" "git rev-parse --git-path hooks/pre-commit"

    assert_file_exists "$hook"
    assert_executable "$hook"
    assert_contains "$hook" "git rev-parse --show-toplevel"
    assert_contains "$hook" "make check"
}

test_skill_inventory_guidance_contract() {
    local rules="$REPO_DIR/.agents/rules/base.md"

    assert_file_exists "$rules"
    assert_contains "$rules" "Adding, removing, renaming, or moving any skill"
    assert_contains "$rules" ".agents/docs/skill-factory-skills.md"
    assert_contains "$rules" ".agents/skills/skill-foundry/agents/catalog-engineering.yaml"
    assert_contains "$rules" ".agents/skills/skill-foundry/agents/catalog-product-management.yaml"
    assert_contains "$rules" "./validate-skill-library.sh"
}

test_healthcheck_automation_contract
test_skill_inventory_guidance_contract
