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

assert_not_contains() {
    local path="$1"
    local unexpected="$2"

    if grep -Fq "$unexpected" "$path"; then
        echo "expected $path not to contain: $unexpected" >&2
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

test_base_rule_compaction_contract() {
    local rules="$REPO_DIR/.agents/rules/base.md"

    assert_file_exists "$rules"
    assert_contains "$rules" "Think Before Acting"
    assert_contains "$rules" "Simplest Surgical Change"
    assert_contains "$rules" "Goal-Driven Verification"
    assert_contains "$rules" "Checkpoint and Escalate"
    assert_contains "$rules" ".agents/rules/python-project.md"
    assert_contains "$rules" ".agents/rules/makefile-project.md"
    assert_contains "$rules" "git@github.com-saski:"
    assert_not_contains "$rules" "git@github.com-eventbrite:"
    assert_contains "$rules" ".agents/docs/skill-factory-skills.md"
    assert_contains "$rules" ".agents/skills/skill-foundry/agents/catalog-engineering.yaml"
    assert_contains "$rules" ".agents/skills/skill-foundry/agents/catalog-product-management.yaml"
    assert_contains "$rules" "./validate-skill-library.sh"
    assert_contains "$rules" "### RTK"
    assert_contains "$rules" "ctx7"
    assert_contains "$rules" "personal-knowledge-routing"
    assert_not_contains "$rules" ".agents/rules/pyth![[REDIS_AUTH_REMEDIATION_HANDOFF]]on-project.md"
}

test_managed_tool_path_contract() {
    local gitignore="$REPO_DIR/.gitignore"
    local makefile="$REPO_DIR/Makefile"
    local readme="$REPO_DIR/README.md"
    local setup="$REPO_DIR/setup-symlinks.sh"
    local development_guide="$REPO_DIR/docs/development-guide.md"

    assert_file_exists "$gitignore"
    assert_file_exists "$makefile"
    assert_file_exists "$readme"
    assert_file_exists "$setup"
    assert_file_exists "$development_guide"

    assert_contains "$gitignore" ".agents/bin/"
    assert_contains "$makefile" '$(HOME)/.agents/bin'
    assert_contains "$makefile" '$(HOME)/.bun/bin'
    assert_contains "$makefile" "/opt/homebrew/bin"
    assert_contains "$setup" 'link_managed_binary "rtk"'
    assert_contains "$setup" 'link_managed_binary "openspec"'
    assert_contains "$setup" 'validate_managed_binary "rtk"'
    assert_contains "$setup" 'validate_managed_binary "openspec"'
    assert_contains "$readme" "~/.agents/bin/openspec"
    assert_contains "$development_guide" "~/.agents/bin/openspec"
}

test_healthcheck_automation_contract
test_skill_inventory_guidance_contract
test_base_rule_compaction_contract
test_managed_tool_path_contract
