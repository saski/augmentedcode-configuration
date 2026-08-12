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

assert_symlink_target() {
    local path="$1"
    local expected="$2"

    if [[ ! -L "$path" ]]; then
        echo "expected symlink: $path" >&2
        exit 1
    fi

    local actual
    actual="$(readlink "$path")"
    if [[ "$actual" != "$expected" ]]; then
        echo "expected $path to point to $expected, got: $actual" >&2
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

test_repository_rule_scope_contract() {
    local rules="$REPO_DIR/.agents/rules/repository.md"
    local cursor_wrapper="$REPO_DIR/.cursor/rules/use-base-rules.mdc"

    assert_file_exists "$rules"
    assert_contains "$rules" "A portable operating layer for AI-assisted development"
    assert_contains "$rules" 'Read and follow `.agents/rules/base.md`'
    assert_contains "$rules" '`make check`'
    assert_contains "$rules" '`make ci-check`'
    assert_contains "$cursor_wrapper" '@.agents/rules/repository.md'
}

test_global_and_repository_rule_wiring_contract() {
    local setup="$REPO_DIR/setup-symlinks.sh"

    assert_symlink_target "$REPO_DIR/AGENTS.md" ".agents/rules/repository.md"
    assert_symlink_target "$REPO_DIR/CLAUDE.md" ".agents/rules/repository.md"
    assert_symlink_target "$REPO_DIR/GEMINI.md" ".agents/rules/repository.md"
    assert_contains "$setup" 'ln -sfn "$REPO_DIR/.agents/rules/base.md" ~/AGENTS.md'
    assert_contains "$setup" 'ln -sfn "$REPO_DIR/.agents/rules/base.md" ~/CLAUDE.md'
    assert_contains "$setup" 'ln -sfn "$REPO_DIR/.agents/rules/base.md" ~/GEMINI.md'
    assert_contains "$setup" 'ln -sfn "$REPO_DIR/.agents/rules/base.md" "$HOME/.gemini/GEMINI.md"'
    assert_contains "$setup" '~/$config should point to .agents/rules/base.md'
}

test_documented_make_targets_exist() {
    local makefile="$REPO_DIR/Makefile"
    local repository_rules="$REPO_DIR/.agents/rules/repository.md"
    local makefile_rules="$REPO_DIR/.agents/rules/makefile-project.md"

    while IFS= read -r target; do
        if ! grep -Eq "^${target}:" "$makefile"; then
            echo "documented make target does not exist: $target" >&2
            exit 1
        fi
    done < <(
        grep -hEo '`make [[:alnum:]_-]+`' "$repository_rules" "$makefile_rules" |
            sed -E 's/`make ([[:alnum:]_-]+)`/\1/' |
            sort -u
    )
}

test_documentation_lookup_routing_contract() {
    local base_rules="$REPO_DIR/.agents/rules/base.md"
    local skill="$REPO_DIR/.agents/skills/documentation-lookup/SKILL.md"
    local mcp_config="$REPO_DIR/.agents/mcp.json"

    assert_contains "$base_rules" "documentation-lookup"
    assert_not_contains "$base_rules" "npx ctx7@latest"
    assert_contains "$skill" "Prefer the Context7 MCP tools when they are available."
    assert_contains "$skill" 'npx ctx7@latest library'
    assert_contains "$skill" 'npx ctx7@latest docs'
    assert_contains "$mcp_config" '"context7"'
}

test_explicit_delegation_routing_contract() {
    local base_rules="$REPO_DIR/.agents/rules/base.md"

    assert_not_contains "$base_rules" "Spawn agents with smaller, lighter models"
    assert_contains "$base_rules" "launching-agent-teams"
    assert_contains "$base_rules" "When the user explicitly requests a bounded, non-sensitive free worker"
}

test_global_rule_budget_contract() {
    local base_rules="$REPO_DIR/.agents/rules/base.md"
    local max_words=900
    local word_count

    assert_not_contains "$base_rules" "catalog-engineering.yaml"
    assert_not_contains "$base_rules" "./validate-skill-library.sh"
    assert_not_contains "$base_rules" "#### Resolution Order"

    word_count="$(wc -w < "$base_rules" | tr -d ' ')"
    if ((word_count > max_words)); then
        echo "base.md exceeds the ${max_words}-word instruction budget: $word_count" >&2
        exit 1
    fi
}

test_skill_inventory_guidance_contract() {
    local rules="$REPO_DIR/.agents/rules/repository.md"

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
    assert_contains "$rules" "### RTK"
    assert_contains "$rules" "documentation-lookup"
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
test_repository_rule_scope_contract
test_global_and_repository_rule_wiring_contract
test_documented_make_targets_exist
test_documentation_lookup_routing_contract
test_explicit_delegation_routing_contract
test_global_rule_budget_contract
test_skill_inventory_guidance_contract
test_base_rule_compaction_contract
test_managed_tool_path_contract
