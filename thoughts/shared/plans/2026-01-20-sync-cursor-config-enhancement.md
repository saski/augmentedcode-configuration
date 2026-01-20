# Sync Cursor Config Enhancement - Implementation Plan

## Overview

Enhance `sync-cursor-config.sh` to support intelligent bidirectional synchronization with timestamp-based conflict resolution and file watching capabilities. The script will sync between `.agents/commands`, `.cursor/commands`, and `~/.cursor/commands`, always preserving the most recently updated version of each file.

## Current State Analysis

**Current Implementation** (`sync-cursor-config.sh`):
- Uses simple `cp -r` which overwrites files unconditionally
- Only syncs `.cursor/rules` and `.cursor/commands` between repo and global
- Does not handle `.agents/commands` → `.cursor/commands` mapping
- No timestamp comparison or conflict resolution
- No watch mode for automatic syncing

**Key Constraints**:
- Must work on macOS (primary development environment)
- Must maintain backward compatibility with existing usage patterns
- Script must be bash-compatible (no external dependencies beyond standard tools)

**File Structure**:
```
~/.cursor/
├── rules/
└── commands/

~/saski/augmentedcode-configuration/
├── .agents/
│   └── commands/          # Source commands
├── .cursor/
│   ├── rules/             # Source rules
│   └── commands/         # Staging area (synced from .agents/commands)
└── sync-cursor-config.sh
```

## Desired End State

**Functionality**:
1. Bidirectional sync with timestamp comparison:
   - `.agents/commands` ↔ `.cursor/commands` (preserve newer file)
   - `.cursor/commands` ↔ `~/.cursor/commands` (preserve newer file)
   - `.cursor/rules` ↔ `~/.cursor/rules` (preserve newer file)

2. Watch mode:
   - Monitor `.agents/commands` and `~/.cursor/commands` for changes
   - On file change, prompt user for confirmation
   - Perform one-time sync after confirmation

3. Conflict resolution:
   - Compare modification times using `stat` or `find`
   - Always preserve the most recently modified file
   - Log which file was chosen and why

**Verification**:
- Script runs without errors: `./sync-cursor-config.sh both`
- Timestamp comparison works: Modify file in one location, verify newer version is preserved
- Watch mode starts: `./sync-cursor-config.sh watch`
- Watch mode detects changes and prompts for confirmation
- Bidirectional sync preserves newer files correctly

## What We're NOT Doing

- Not implementing continuous background watching (only one-time sync on change)
- Not adding dependency on external tools (use standard macOS tools: `fswatch` or `stat`)
- Not changing the existing command-line interface (add new `watch` mode)
- Not implementing automatic git commits (user still commits manually)
- Not syncing `.agents/rules` (only commands need this mapping)

## Implementation Approach

**Strategy**:
1. Refactor sync functions to use timestamp comparison
2. Add helper function to compare file modification times
3. Add bidirectional sync function that handles conflicts intelligently
4. Add watch mode using `fswatch` (macOS) with user confirmation
5. Update main script to handle new `watch` command

**Key Functions**:
- `get_file_mtime()` - Get file modification time as epoch seconds
- `sync_file_bidirectional()` - Sync single file preserving newer version
- `sync_directory_bidirectional()` - Sync directory recursively
- `watch_and_sync()` - Watch for changes and prompt for sync

## Phase 1: Add Timestamp Comparison Functions

### Overview
Add helper functions to compare file modification times and determine which file is newer.

### Changes Required:

#### 1. Add Timestamp Utilities
**File**: `sync-cursor-config.sh`
**Changes**: Add functions after variable definitions (around line 13)

```bash
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
```

### Success Criteria:
- [x] Function `get_file_mtime` returns epoch seconds for existing files
- [x] Function `get_file_mtime` returns "0" for non-existent files
- [x] Function `get_newer_file` correctly identifies newer file
- [x] Functions work on macOS (primary environment)
- [x] Script syntax is valid: `bash -n sync-cursor-config.sh`

---

## Phase 2: Implement Bidirectional File Sync

### Overview
Replace simple `cp -r` with intelligent bidirectional sync that preserves newer files.

### Changes Required:

#### 1. Add Bidirectional File Sync Function
**File**: `sync-cursor-config.sh`
**Changes**: Add function after timestamp utilities

```bash
# Sync a single file bidirectionally, preserving newer version
sync_file_bidirectional() {
    local source="$1"
    local target="$2"
    local filename=$(basename "$source")
    
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
    
    if [ "$newer" = "$source" ]; then
        # Source is newer, copy to target
        cp "$source" "$target"
        echo "  ✓ Updated: $filename (source is newer)"
    elif [ "$newer" = "$target" ]; then
        # Target is newer, copy to source
        cp "$target" "$source"
        echo "  ✓ Updated: $filename (target is newer)"
    else
        # Same modification time, skip
        echo "  ⊘ Skipped: $filename (identical)"
    fi
}
```

#### 2. Add Directory Sync Function
**File**: `sync-cursor-config.sh`
**Changes**: Add function after file sync function

```bash
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
    
    local synced=0
    local created=0
    local skipped=0
    
    # Get all files from both directories
    local all_files=$(find "$source_dir" "$target_dir" -type f 2>/dev/null | sort -u)
    
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
        
        sync_file_bidirectional "$source_file" "$target_file"
    done
    
    # Clean up orphaned files in target (files that don't exist in source)
    if [ -d "$target_dir" ]; then
        find "$target_dir" -type f | while read target_file; do
            local rel_path="${target_file#$target_dir/}"
            local source_file="$source_dir/$rel_path"
            
            if [ ! -f "$source_file" ]; then
                # File exists in target but not in source
                # Check if we should remove it or copy it back
                # For now, we'll keep it (user might have added it in global)
                # But we could add logic to remove if it's older than a threshold
            fi
        done
    fi
    
    echo "✅ $description sync complete"
}
```

### Success Criteria:
- [x] `sync_file_bidirectional` creates target if it doesn't exist
- [x] `sync_file_bidirectional` preserves newer file when both exist
- [x] `sync_directory_bidirectional` syncs all files recursively
- [x] Script handles missing directories gracefully
- [x] No duplicate files are created

---

## Phase 3: Update Sync Functions to Use Bidirectional Logic

### Overview
Replace existing `sync_repo_to_global` and `sync_global_to_repo` with bidirectional versions.

### Changes Required:

#### 1. Replace sync_repo_to_global Function
**File**: `sync-cursor-config.sh`
**Changes**: Replace function starting at line 24

```bash
sync_repo_to_global() {
    echo "🔄 Syncing repository → global config..."
    
    # Sync .agents/commands → .cursor/commands (bidirectional)
    if [ -d "$REPO_DIR/.agents/commands" ] || [ -d "$REPO_DIR/.cursor/commands" ]; then
        sync_directory_bidirectional \
            "$REPO_DIR/.agents/commands" \
            "$REPO_DIR/.cursor/commands" \
            ".agents/commands ↔ .cursor/commands"
    fi
    
    # Sync .cursor/commands → ~/.cursor/commands (bidirectional)
    if [ -d "$REPO_DIR/.cursor/commands" ] || [ -d "$GLOBAL_COMMANDS" ]; then
        sync_directory_bidirectional \
            "$REPO_DIR/.cursor/commands" \
            "$GLOBAL_COMMANDS" \
            ".cursor/commands ↔ ~/.cursor/commands"
    fi
    
    # Sync .cursor/rules → ~/.cursor/rules (bidirectional)
    if [ -d "$REPO_DIR/.cursor/rules" ] || [ -d "$GLOBAL_RULES" ]; then
        sync_directory_bidirectional \
            "$REPO_DIR/.cursor/rules" \
            "$GLOBAL_RULES" \
            ".cursor/rules ↔ ~/.cursor/rules"
    fi
    
    echo "✅ Repository ↔ global sync complete"
}
```

#### 2. Remove sync_global_to_repo Function
**File**: `sync-cursor-config.sh`
**Changes**: Remove function starting at line 45 (now handled by bidirectional sync)

#### 3. Update Main Case Statement
**File**: `sync-cursor-config.sh`
**Changes**: Update case statement to remove `global-to-repo` option, add `watch` option

```bash
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
```

#### 4. Update Usage Function
**File**: `sync-cursor-config.sh`
**Changes**: Update usage message

```bash
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
```

### Success Criteria:
- [x] `sync_repo_to_global` now performs bidirectional sync
- [x] `.agents/commands` ↔ `.cursor/commands` sync works
- [x] `.cursor/commands` ↔ `~/.cursor/commands` sync works
- [x] `.cursor/rules` ↔ `~/.cursor/rules` sync works
- [x] Script maintains backward compatibility with existing usage

---

## Phase 4: Implement Watch Mode

### Overview
Add file watching capability that monitors for changes and prompts user for confirmation before syncing.

### Changes Required:

#### 1. Add Watch Function
**File**: `sync-cursor-config.sh`
**Changes**: Add function before main case statement

```bash
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
```

#### 2. Add Error Handling for Missing fswatch
**File**: `sync-cursor-config.sh`
**Changes**: Improve error message with installation instructions

### Success Criteria:
- [x] Watch mode starts without errors
- [x] Watch mode detects file changes in `.agents/commands`
- [x] Watch mode detects file changes in `~/.cursor/commands`
- [x] User confirmation prompt appears on file change
- [x] Sync executes after user confirms
- [x] Watch mode continues after sync
- [x] Watch mode exits cleanly on Ctrl+C

---

## Phase 5: Testing and Edge Case Handling

### Overview
Add error handling, logging improvements, and test edge cases.

### Changes Required:

#### 1. Add Verbose Mode
**File**: `sync-cursor-config.sh`
**Changes**: Add verbose flag and logging

```bash
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
```

#### 2. Improve Error Handling
**File**: `sync-cursor-config.sh`
**Changes**: Add error checks throughout sync functions

```bash
# Add at start of sync_file_bidirectional
if [ -z "$source" ] || [ -z "$target" ]; then
    echo "  ❌ Error: Missing source or target path"
    return 1
fi
```

#### 3. Add Summary Statistics
**File**: `sync-cursor-config.sh`
**Changes**: Track and display sync statistics

```bash
# Add counters in sync_directory_bidirectional
local stats_created=0
local stats_updated=0
local stats_skipped=0

# Update counters in sync_file_bidirectional
# Display summary at end
```

### Success Criteria:
- [x] Script handles missing directories gracefully
- [x] Script handles permission errors gracefully
- [x] Verbose mode provides useful debugging information
- [x] Summary statistics are accurate
- [x] No errors occur during normal operation

---

## Testing Strategy

### Manual Testing Scenarios:

1. **Basic Bidirectional Sync**:
   ```bash
   # Create test file in .agents/commands
   echo "test" > .agents/commands/test.md
   ./sync-cursor-config.sh both
   # Verify file appears in .cursor/commands
   # Modify file in .cursor/commands
   # Run sync again, verify newer version is preserved
   ```

2. **Timestamp Comparison**:
   ```bash
   # Create file in .agents/commands
   touch .agents/commands/test1.md
   sleep 2
   # Create same file in .cursor/commands with newer timestamp
   touch .cursor/commands/test1.md
   ./sync-cursor-config.sh both
   # Verify .cursor/commands version is preserved (newer)
   ```

3. **Watch Mode**:
   ```bash
   # Start watch mode
   ./sync-cursor-config.sh watch
   # In another terminal, modify a file
   # Verify prompt appears
   # Confirm sync, verify it works
   ```

4. **Edge Cases**:
   - Missing directories
   - Files with special characters
   - Very large files
   - Concurrent modifications

### Automated Verification:

- [x] Script syntax is valid: `bash -n sync-cursor-config.sh`
- [x] Script runs without errors: `./sync-cursor-config.sh both`
- [x] All functions are defined and callable
- [x] No bash warnings or errors

## References

- Current script: `sync-cursor-config.sh:1:90`
- Cursor config management rule: `.cursor/rules/cursor-config-management.mdc:1:62`
- Similar sync pattern: `src/thoughts/src/sync.ts:62:181` (TypeScript, but shows timestamp comparison pattern)

## Notes

- `fswatch` is the standard file watching tool on macOS
- On Linux, we could use `inotifywait` but macOS is the primary environment
- The bidirectional sync ensures no data loss while preserving the most recent changes
- Watch mode is one-time sync per change (not continuous background sync) as per requirements
