#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/saski/augmentedcode-configuration}"
TEMPLATES_DIR="$REPO_DIR/templates"
CODEX_CONFIG_TEMPLATE="$TEMPLATES_DIR/codex/config.toml"
CLAUDE_SETTINGS_TEMPLATE="$TEMPLATES_DIR/claude/settings.json"

# Dev/AI tools under ~ that get a direct "$HOME/$tool/skills" symlink.
# Cursor and Codex are handled separately due tool-specific directory layouts.
# Add or remove dot-dir names to cover any dev tool config (e.g. .copilot, .kiro).
TOOLS_WITH_SKILLS=".antigravity .gemini .langflow"

usage() {
    cat << EOF
Usage: $(basename $0) [command]

Commands:
  setup     - Create all symlinks (first-time setup or repair)
  validate  - Verify all symlinks are correct
  status    - Show git status of config changes
  commit    - Stage, commit, and push config changes
  help      - Show this help message

Examples:
  $(basename $0) setup      # Initial setup on new machine
  $(basename $0) validate   # Check symlinks are intact
  $(basename $0) commit     # Commit and push config changes
EOF
    exit 1
}

# Verify we're in the right place
check_environment() {
    if [ ! -d "$REPO_DIR" ]; then
        echo "❌ Repository not found at $REPO_DIR"
        exit 1
    fi

    if [ ! -d "$REPO_DIR/.cursor" ]; then
        echo "❌ .cursor directory not found in repo"
        exit 1
    fi

    if [ ! -f "$REPO_DIR/.agents/mcp.json" ]; then
        echo "❌ .agents/mcp.json not found in repo"
        exit 1
    fi

    if [ ! -f "$REPO_DIR/.cursor/cli-config.json" ]; then
        echo "❌ .cursor/cli-config.json not found in repo"
        exit 1
    fi

    if [ ! -f "$CODEX_CONFIG_TEMPLATE" ]; then
        echo "❌ templates/codex/config.toml not found in repo"
        exit 1
    fi

    if [ ! -f "$REPO_DIR/.agents/rules/codex-default.rules" ]; then
        echo "❌ .agents/rules/codex-default.rules not found in repo"
        exit 1
    fi

    if [ ! -f "$REPO_DIR/GEMINI.md" ]; then
        echo "❌ GEMINI.md not found in repo"
        exit 1
    fi

    if [ ! -d "$REPO_DIR/.claude/hooks" ]; then
        echo "❌ .claude/hooks directory not found in repo"
        exit 1
    fi

    if [ ! -f "$CLAUDE_SETTINGS_TEMPLATE" ]; then
        echo "❌ templates/claude/settings.json not found in repo"
        exit 1
    fi
}

ensure_local_directory() {
    local path="$1"

    if [ -L "$path" ]; then
        rm "$path"
    fi

    mkdir -p "$path"
}

install_template_file() {
    local template_path="$1"
    local destination_path="$2"

    mkdir -p "$(dirname "$destination_path")"

    if [ -L "$destination_path" ]; then
        rm "$destination_path"
    fi

    if [ ! -f "$destination_path" ]; then
        cp "$template_path" "$destination_path"
    fi
}

link_managed_path() {
    local source_path="$1"
    local destination_path="$2"

    mkdir -p "$(dirname "$destination_path")"
    ln -sfn "$source_path" "$destination_path"
}

setup_claude_config() {
    ensure_local_directory "$HOME/.claude"

    link_managed_path "$REPO_DIR/.agents/commands" "$HOME/.claude/commands"
    link_managed_path "$REPO_DIR/.agents/skills" "$HOME/.claude/skills"
    link_managed_path "$REPO_DIR/.claude/hooks" "$HOME/.claude/hooks"
    link_managed_path "$REPO_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    link_managed_path "$REPO_DIR/.claude/RTK.md" "$HOME/.claude/RTK.md"

    install_template_file "$CLAUDE_SETTINGS_TEMPLATE" "$HOME/.claude/settings.json"
}

setup_symlinks() {
    echo "🔗 Setting up symlinks..."

    # Backup existing if not symlinks
    if [ -d ~/.cursor/rules ] && [ ! -L ~/.cursor/rules ]; then
        echo "⚠️  Found existing ~/.cursor/rules (not a symlink)"
        echo "   Create backup with: ./backup-cursor-config.sh"
        exit 1
    fi

    # Create .cursor symlinks (skills → canonical .agents/skills)
    mkdir -p ~/.cursor
    ln -sfn "$REPO_DIR/.cursor/rules" ~/.cursor/rules
    ln -sfn "$REPO_DIR/.cursor/commands" ~/.cursor/commands
    ln -sfn "$REPO_DIR/.agents/skills" ~/.cursor/skills
    ln -sfn "$REPO_DIR/.cursor/skills-cursor" ~/.cursor/skills-cursor
    ln -sfn "$REPO_DIR/.agents" ~/.cursor/.agents
    ln -sfn "$REPO_DIR/.agents/mcp.json" ~/.cursor/mcp.json
    ln -sfn "$REPO_DIR/.cursor/cli-config.json" ~/.cursor/cli-config.json

    # Codex keeps local system skills under ~/.codex/skills/.system.
    # Link shared skills and shared rules into ~/.codex.
    mkdir -p "$HOME/.codex/skills" "$HOME/.codex/rules"
    ln -sfn "$REPO_DIR/.agents/skills" "$HOME/.codex/skills/skills"
    install_template_file "$CODEX_CONFIG_TEMPLATE" "$HOME/.codex/config.toml"
    ln -sfn "$REPO_DIR/.agents/rules/codex-default.rules" "$HOME/.codex/rules/default.rules"
    ln -sfn "$REPO_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"

    # Other dev/AI tools: point skills at canonical .agents/skills
    for tool in $TOOLS_WITH_SKILLS; do
        mkdir -p "$HOME/$tool"
        ln -sfn "$REPO_DIR/.agents/skills" "$HOME/$tool/skills"
    done

    # Gemini: use shared MCP config, commands, and workflows from canonical .agents path.
    mkdir -p "$HOME/.gemini/antigravity"
    ln -sfn "$REPO_DIR/.agents/mcp.json" "$HOME/.gemini/antigravity/mcp_config.json"
    ln -sfn "$REPO_DIR/GEMINI.md" "$HOME/.gemini/GEMINI.md"
    ln -sfn "$REPO_DIR/.agents/workflows" "$HOME/.gemini/antigravity/workflows"
    ln -sfn "$REPO_DIR/.agents/commands" "$HOME/.gemini/antigravity/commands"

    # Home-level .agents should always resolve to canonical repo .agents
    # so there is no divergent local skill source.
    if [ -d "$HOME/.agents" ] && [ ! -L "$HOME/.agents" ]; then
        echo "⚠️  Found existing ~/.agents directory (not a symlink)"
        echo "   Please move it to a backup location, then rerun setup."
        exit 1
    fi
    ln -sfn "$REPO_DIR/.agents" "$HOME/.agents"

    setup_claude_config

    # Create root-level config symlinks
    ln -sfn "$REPO_DIR/CLAUDE.md" ~/CLAUDE.md
    ln -sfn "$REPO_DIR/AGENTS.md" ~/AGENTS.md
    ln -sfn "$REPO_DIR/GEMINI.md" ~/GEMINI.md

    echo "✅ Symlinks created"
}

# Validate all symlinks
validate_symlinks() {
    echo "🔍 Validating symlinks..."

    local errors=0

    # Check .cursor symlinks
    for link in rules commands skills skills-cursor .agents; do
        local path="$HOME/.cursor/$link"
        if [ ! -L "$path" ]; then
            echo "❌ $path is not a symlink"
            errors=$((errors + 1))
        elif [ ! -e "$path" ]; then
            echo "❌ $path is a broken symlink"
            errors=$((errors + 1))
        else
            local target
            target=$(readlink "$path")
            if [ "$link" = "skills" ] && [[ "$target" != *".agents/skills" ]]; then
                echo "❌ $path should point to .agents/skills, got: $target"
                errors=$((errors + 1))
            else
                echo "✓ ~/.cursor/$link → $target"
            fi
        fi
    done

    # Check Cursor managed config files
    for file in cli-config.json; do
        local path="$HOME/.cursor/$file"
        if [ ! -L "$path" ]; then
            echo "❌ $path is not a symlink"
            errors=$((errors + 1))
        elif [ ! -e "$path" ]; then
            echo "❌ $path is a broken symlink"
            errors=$((errors + 1))
        else
            local target
            target=$(readlink "$path")
            if [[ "$target" != *".cursor/$file" ]]; then
                echo "❌ $path should point to repo .cursor/$file, got: $target"
                errors=$((errors + 1))
            else
                echo "✓ $path → $target"
            fi
        fi
    done

    # Check Cursor shared MCP config symlink
    local cursor_mcp_path="$HOME/.cursor/mcp.json"
    if [ ! -L "$cursor_mcp_path" ]; then
        echo "❌ $cursor_mcp_path is not a symlink"
        errors=$((errors + 1))
    elif [ ! -e "$cursor_mcp_path" ]; then
        echo "❌ $cursor_mcp_path is a broken symlink"
        errors=$((errors + 1))
    else
        local cursor_mcp_target
        cursor_mcp_target=$(readlink "$cursor_mcp_path")
        if [[ "$cursor_mcp_target" != *".agents/mcp.json" ]]; then
            echo "❌ $cursor_mcp_path should point to repo .agents/mcp.json, got: $cursor_mcp_target"
            errors=$((errors + 1))
        else
            echo "✓ $cursor_mcp_path → $cursor_mcp_target"
        fi
    fi

    # Check Codex skills symlink (nested path due ~/.codex/skills/.system)
    local codex_path="$HOME/.codex/skills/skills"
    if [ ! -L "$codex_path" ]; then
        echo "❌ $codex_path is not a symlink"
        errors=$((errors + 1))
    elif [ ! -e "$codex_path" ]; then
        echo "❌ $codex_path is a broken symlink"
        errors=$((errors + 1))
    else
        local codex_target
        codex_target=$(readlink "$codex_path")
        if [[ "$codex_target" != *".agents/skills" ]]; then
            echo "❌ $codex_path should point to .agents/skills, got: $codex_target"
            errors=$((errors + 1))
        else
            echo "✓ $codex_path → .agents/skills"
        fi
    fi

    # Check Codex managed config file
    local codex_config_path="$HOME/.codex/config.toml"
    if [ ! -f "$codex_config_path" ]; then
        echo "❌ $codex_config_path is missing"
        errors=$((errors + 1))
    elif [ -L "$codex_config_path" ]; then
        echo "❌ $codex_config_path should be a local file, not a symlink"
        errors=$((errors + 1))
    else
        echo "✓ $codex_config_path is a local managed file"
    fi

    # Check Codex shared rules symlink
    local codex_rules_path="$HOME/.codex/rules/default.rules"
    if [ ! -L "$codex_rules_path" ]; then
        echo "❌ $codex_rules_path is not a symlink"
        errors=$((errors + 1))
    elif [ ! -e "$codex_rules_path" ]; then
        echo "❌ $codex_rules_path is a broken symlink"
        errors=$((errors + 1))
    else
        local codex_rules_target
        codex_rules_target=$(readlink "$codex_rules_path")
        if [[ "$codex_rules_target" != *".agents/rules/codex-default.rules" ]]; then
            echo "❌ $codex_rules_path should point to repo .agents/rules/codex-default.rules, got: $codex_rules_target"
            errors=$((errors + 1))
        else
            echo "✓ $codex_rules_path → $codex_rules_target"
        fi
    fi

    # Check Codex instructions symlink
    local codex_agents_path="$HOME/.codex/AGENTS.md"
    if [ ! -L "$codex_agents_path" ]; then
        echo "❌ $codex_agents_path is not a symlink"
        errors=$((errors + 1))
    elif [ ! -e "$codex_agents_path" ]; then
        echo "❌ $codex_agents_path is a broken symlink"
        errors=$((errors + 1))
    else
        local codex_agents_target
        codex_agents_target=$(readlink "$codex_agents_path")
        if [[ "$codex_agents_target" != *"/AGENTS.md" ]]; then
            echo "❌ $codex_agents_path should point to repo AGENTS.md, got: $codex_agents_target"
            errors=$((errors + 1))
        else
            echo "✓ $codex_agents_path → $codex_agents_target"
        fi
    fi

    # Check skills symlinks for other dev tools (must point to repo .agents/skills)
    for tool in $TOOLS_WITH_SKILLS; do
        local path="$HOME/$tool/skills"
        if [ ! -L "$path" ]; then
            echo "❌ $path is not a symlink"
            errors=$((errors + 1))
        elif [ ! -e "$path" ]; then
            echo "❌ $path is a broken symlink"
            errors=$((errors + 1))
        else
            local target
            target=$(readlink "$path")
            if [[ "$target" != *".agents/skills" ]]; then
                echo "❌ $path should point to .agents/skills, got: $target"
                errors=$((errors + 1))
            else
                echo "✓ $path → .agents/skills"
            fi
        fi
    done

    # Check .claude managed layout
    if [ ! -d "$HOME/.claude" ] || [ -L "$HOME/.claude" ]; then
        echo "❌ ~/.claude should be a local directory"
        errors=$((errors + 1))
    else
        echo "✓ ~/.claude is a local directory"
    fi

    for path in commands skills hooks CLAUDE.md RTK.md; do
        local claude_path="$HOME/.claude/$path"
        if [ ! -L "$claude_path" ]; then
            echo "❌ $claude_path is not a symlink"
            errors=$((errors + 1))
        elif [ ! -e "$claude_path" ]; then
            echo "❌ $claude_path is a broken symlink"
            errors=$((errors + 1))
        else
            echo "✓ $claude_path → $(readlink "$claude_path")"
        fi
    done

    local claude_settings_path="$HOME/.claude/settings.json"
    if [ ! -f "$claude_settings_path" ]; then
        echo "❌ $claude_settings_path is missing"
        errors=$((errors + 1))
    elif [ -L "$claude_settings_path" ]; then
        echo "❌ $claude_settings_path should be a local file, not a symlink"
        errors=$((errors + 1))
    else
        echo "✓ $claude_settings_path is a local managed file"
    fi

    # Check Gemini MCP config symlink
    local gemini_mcp_path="$HOME/.gemini/antigravity/mcp_config.json"
    if [ ! -L "$gemini_mcp_path" ]; then
        echo "❌ $gemini_mcp_path is not a symlink"
        errors=$((errors + 1))
    elif [ ! -e "$gemini_mcp_path" ]; then
        echo "❌ $gemini_mcp_path is a broken symlink"
        errors=$((errors + 1))
    else
        local gemini_mcp_target
        gemini_mcp_target=$(readlink "$gemini_mcp_path")
        if [[ "$gemini_mcp_target" != *".agents/mcp.json" ]]; then
            echo "❌ $gemini_mcp_path should point to repo .agents/mcp.json, got: $gemini_mcp_target"
            errors=$((errors + 1))
        else
            echo "✓ $gemini_mcp_path → $gemini_mcp_target"
        fi
    fi

    # Check Gemini commands and workflows symlinks
    for dir in workflows commands; do
        local path="$HOME/.gemini/antigravity/$dir"
        if [ ! -L "$path" ]; then
            echo "❌ $path is not a symlink"
            errors=$((errors + 1))
        elif [ ! -e "$path" ]; then
            echo "❌ $path is a broken symlink"
            errors=$((errors + 1))
        else
            local target
            target=$(readlink "$path")
            if [[ "$target" != *".agents/$dir" ]]; then
                echo "❌ $path should point to repo .agents/$dir, got: $target"
                errors=$((errors + 1))
            else
                echo "✓ $path → $target"
            fi
        fi
    done

    # Check Gemini instructions symlink
    local gemini_rules_path="$HOME/.gemini/GEMINI.md"
    if [ ! -L "$gemini_rules_path" ]; then
        echo "❌ $gemini_rules_path is not a symlink"
        errors=$((errors + 1))
    elif [ ! -e "$gemini_rules_path" ]; then
        echo "❌ $gemini_rules_path is a broken symlink"
        errors=$((errors + 1))
    else
        local gemini_rules_target
        gemini_rules_target=$(readlink "$gemini_rules_path")
        if [[ "$gemini_rules_target" != *"/GEMINI.md" ]]; then
            echo "❌ $gemini_rules_path should point to repo GEMINI.md, got: $gemini_rules_target"
            errors=$((errors + 1))
        else
            echo "✓ $gemini_rules_path → $gemini_rules_target"
        fi
    fi

    # Check ~/.agents canonical link
    if [ ! -L "$HOME/.agents" ]; then
        echo "❌ ~/.agents is not a symlink"
        errors=$((errors + 1))
    elif [ ! -e "$HOME/.agents" ]; then
        echo "❌ ~/.agents is a broken symlink"
        errors=$((errors + 1))
    else
        local agents_target
        agents_target=$(readlink "$HOME/.agents")
        if [[ "$agents_target" != *"augmentedcode-configuration/.agents" ]]; then
            echo "❌ ~/.agents should point to repo .agents, got: $agents_target"
            errors=$((errors + 1))
        else
            echo "✓ ~/.agents → $agents_target"
        fi
    fi

    # Check root configs
    for config in CLAUDE.md AGENTS.md GEMINI.md; do
        local path="$HOME/$config"
        if [ ! -L "$path" ]; then
            echo "❌ ~/$config is not a symlink"
            errors=$((errors + 1))
        else
            echo "✓ ~/$config → $(readlink $path)"
        fi
    done

    if [ $errors -eq 0 ]; then
        echo ""
        echo "✅ All symlinks valid"
        return 0
    else
        echo ""
        echo "❌ Found $errors symlink issues"
        return 1
    fi
}

# Show git status
show_status() {
    echo "📊 Configuration changes:"
    cd "$REPO_DIR"
    git status --short .cursor/ .claude/ .gemini/ .agents/ templates/ *.md 2>/dev/null || true
}

# Commit and push changes
commit_changes() {
    cd "$REPO_DIR"

    if git diff --quiet .cursor/ .claude/ .gemini/ .agents/ templates/ *.md 2>/dev/null; then
        echo "ℹ️  No config changes to commit"
        exit 0
    fi

    echo "📝 Changes to commit:"
    git status --short .cursor/ .claude/ .gemini/ .agents/ templates/ *.md
    echo ""

    read -p "Commit message: " -r message

    if [ -z "$message" ]; then
        echo "❌ Commit message required"
        exit 1
    fi

    git add .cursor/ .claude/ .gemini/ .agents/ templates/ *.md
    git commit -m "$message"

    read -p "Push to remote? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push
        echo "✅ Changes pushed"
    else
        echo "ℹ️  Changes committed locally (not pushed)"
    fi
}

# Main
check_environment

case "${1:-help}" in
    setup)
        setup_symlinks
        ;;
    validate)
        validate_symlinks
        ;;
    status)
        show_status
        ;;
    commit)
        commit_changes
        ;;
    help|*)
        usage
        ;;
esac
