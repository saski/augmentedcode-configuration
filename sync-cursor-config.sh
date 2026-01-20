#!/bin/bash

# Sync Cursor Configuration
# Bidirectional sync between ~/.cursor/ and ~/saski/augmentedcode-configuration/.cursor/

set -e

REPO_DIR="$HOME/saski/augmentedcode-configuration"
GLOBAL_RULES="$HOME/.cursor/rules"
GLOBAL_COMMANDS="$HOME/.cursor/commands"
REPO_RULES="$REPO_DIR/.cursor/rules"
REPO_COMMANDS="$REPO_DIR/.cursor/commands"

VERBOSE=false

# Check for verbose flag
if [[ "$1" == "-v" ]] || [[ "$1" == "--verbose" ]]; then
    VERBOSE=true
    shift
fi

# Verbose logging function
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "  [DEBUG] $1"
    fi
}

# Get file modification time as epoch seconds
get_file_mtime() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi
    
    # macOS: use stat -f %m
    # Linux: use stat -c %Y
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f %m "$file" 2>/dev/null || echo "0"
    else
        stat -c %Y "$file" 2>/dev/null || echo "0"
    fi
}

# Compare two files and return path to newer one
get_newer_file() {
    local file1="$1"
    local file2="$2"
    
    local mtime1=$(get_file_mtime "$file1")
    local mtime2=$(get_file_mtime "$file2")
    
    if [ "$mtime1" -gt "$mtime2" ]; then
        echo "$file1"
    elif [ "$mtime2" -gt "$mtime1" ]; then
        echo "$file2"
    else
        # Same modification time, prefer source (first argument)
        echo "$file1"
    fi
}

# Sync a single file bidirectionally, preserving newer version
sync_file_bidirectional() {
    local source="$1"
    local target="$2"
    local filename=$(basename "$source")
    
    # Validate inputs
    if [ -z "$source" ] || [ -z "$target" ]; then
        echo "  ❌ Error: Missing source or target path"
        return 1
    fi
    
    # If source doesn't exist, skip
    if [ ! -f "$source" ]; then
        return 0
    fi
    
    # If target doesn't exist, copy source to target
    if [ ! -f "$target" ]; then
        mkdir -p "$(dirname "$target")"
        cp "$source" "$target"
        echo "  ✓ Created: $filename"
        return 0
    fi
    
    # Both exist, compare timestamps
    local newer=$(get_newer_file "$source" "$target")
    local mtime1=$(get_file_mtime "$source")
    local mtime2=$(get_file_mtime "$target")
    
    # If modification times are equal, check if files are actually different
    if [ "$mtime1" -eq "$mtime2" ]; then
        if cmp -s "$source" "$target" 2>/dev/null; then
            # Files are identical, skip
            echo "  ⊘ Skipped: $filename (identical)"
            return 0
        fi
        # Same mtime but different content - prefer source
        cp "$source" "$target" 2>/dev/null
        echo "  ✓ Updated: $filename (same mtime, synced from source)"
        return 0
    fi
    
    if [ "$newer" = "$source" ]; then
        # Source is newer, copy to target
        cp "$source" "$target" 2>/dev/null
        echo "  ✓ Updated: $filename (source is newer)"
    elif [ "$newer" = "$target" ]; then
        # Target is newer, copy to source
        cp "$target" "$source" 2>/dev/null
        echo "  ✓ Updated: $filename (target is newer)"
    fi
}

# Sync directory bidirectionally
sync_directory_bidirectional() {
    local source_dir="$1"
    local target_dir="$2"
    local description="$3"
    
    if [ ! -d "$source_dir" ] && [ ! -d "$target_dir" ]; then
        echo "⚠️  Both directories missing: $description"
        return 1
    fi
    
    mkdir -p "$source_dir" "$target_dir"
    
    echo "🔄 Syncing $description..."
    
    log_verbose "Source: $source_dir"
    log_verbose "Target: $target_dir"
    
    # Get all files from both directories
    local all_files=$(find "$source_dir" "$target_dir" -type f 2>/dev/null | sort -u)
    local file_count=$(echo "$all_files" | grep -c . || echo "0")
    
    log_verbose "Found $file_count files to sync"
    
    local processed=0
    for file in $all_files; do
        # Determine relative path
        local rel_path=""
        if [[ "$file" == "$source_dir"/* ]]; then
            rel_path="${file#$source_dir/}"
        else
            rel_path="${file#$target_dir/}"
        fi
        
        local source_file="$source_dir/$rel_path"
        local target_file="$target_dir/$rel_path"
        
        log_verbose "Processing: $rel_path"
        sync_file_bidirectional "$source_file" "$target_file"
        processed=$((processed + 1))
    done
    
    echo "✅ $description sync complete ($processed files processed)"
}

usage() {
    echo "Usage: $0 [repo-to-global|global-to-repo|both|watch]"
    echo ""
    echo "  repo-to-global  - Sync repository to global (bidirectional)"
    echo "  global-to-repo   - Alias for repo-to-global (bidirectional)"
    echo "  both            - Sync both directions (default, bidirectional)"
    echo "  watch           - Watch for file changes and sync on confirmation"
    echo ""
    exit 1
}

sync_repo_to_global() {
    echo "🔄 Syncing repository ↔ global config (bidirectional)..."
    
    # Sync .agents/commands ↔ .cursor/commands (bidirectional)
    if [ -d "$REPO_DIR/.agents/commands" ] || [ -d "$REPO_DIR/.cursor/commands" ]; then
        sync_directory_bidirectional \
            "$REPO_DIR/.agents/commands" \
            "$REPO_DIR/.cursor/commands" \
            ".agents/commands ↔ .cursor/commands"
    fi
    
    # Sync .cursor/commands ↔ ~/.cursor/commands (bidirectional)
    if [ -d "$REPO_DIR/.cursor/commands" ] || [ -d "$GLOBAL_COMMANDS" ]; then
        sync_directory_bidirectional \
            "$REPO_DIR/.cursor/commands" \
            "$GLOBAL_COMMANDS" \
            ".cursor/commands ↔ ~/.cursor/commands"
    fi
    
    # Sync .cursor/rules ↔ ~/.cursor/rules (bidirectional)
    if [ -d "$REPO_DIR/.cursor/rules" ] || [ -d "$GLOBAL_RULES" ]; then
        sync_directory_bidirectional \
            "$REPO_DIR/.cursor/rules" \
            "$GLOBAL_RULES" \
            ".cursor/rules ↔ ~/.cursor/rules"
    fi
    
    echo "✅ Repository ↔ global sync complete"
}

sync_global_to_repo() {
    # Now handled by bidirectional sync in sync_repo_to_global
    sync_repo_to_global
}

watch_and_sync() {
    echo "👀 Starting watch mode..."
    echo "   Monitoring:"
    echo "   - $REPO_DIR/.agents/commands"
    echo "   - $GLOBAL_COMMANDS"
    echo ""
    echo "   Press Ctrl+C to stop"
    echo ""
    
    # Check if fswatch is available (macOS)
    if ! command -v fswatch &> /dev/null; then
        echo "❌ fswatch not found. Install with: brew install fswatch"
        exit 1
    fi
    
    # Watch both directories
    fswatch -o "$REPO_DIR/.agents/commands" "$GLOBAL_COMMANDS" | while read; do
        echo ""
        echo "📝 File change detected!"
        echo ""
        read -p "Sync now? (y/n): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            sync_repo_to_global
            echo ""
            echo "👀 Watching for changes..."
        else
            echo "⏭️  Skipped sync"
        fi
    done
}

# Main
DIRECTION="${1:-both}"

case "$DIRECTION" in
    repo-to-global)
        sync_repo_to_global
        ;;
    global-to-repo)
        # Now handled by bidirectional sync in repo-to-global
        echo "ℹ️  Use 'both' for bidirectional sync, or 'repo-to-global'"
        sync_repo_to_global
        ;;
    both)
        sync_repo_to_global
        ;;
    watch)
        watch_and_sync
        ;;
    *)
        usage
        ;;
esac

echo ""
echo "💡 Tip: After syncing, commit changes in the repository:"
echo "   cd $REPO_DIR && git add .cursor/ && git commit -m 'Sync cursor config' && git push"

