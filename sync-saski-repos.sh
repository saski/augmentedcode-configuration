#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "$script_dir/.." && pwd)"
manifest="$script_dir/saski-github-repos.tsv"
max_depth=3
apply=0
fetch=1
push_after_update=0
discover=0

usage() {
    cat <<'USAGE'
Usage:
  sync-saski-repos.sh [options]

Default behavior fetches the manifest's source refs and reports what would
fast-forward. It does not change working trees unless --apply is passed.

Options:
  --apply              Fast-forward eligible repos.
  --push               After --apply, push updated fork branches when the
                       manifest has a push_remote other than "-".
  --no-fetch           Use existing remote refs only.
  --manifest PATH      Use a different manifest file.
  --root PATH          Use a different workspace root.
  --discover           Print candidate manifest lines discovered under root.
  --max-depth N        Discovery depth for .git markers. Default: 3.
  -h, --help           Show this help.

Manifest columns:
  path source_remote source_branch update_branch push_remote
USAGE
}

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --apply)
            apply=1
            ;;
        --push)
            push_after_update=1
            ;;
        --no-fetch)
            fetch=0
            ;;
        --manifest)
            [ "$#" -ge 2 ] || die '--manifest requires a path'
            manifest="$2"
            shift
            ;;
        --root)
            [ "$#" -ge 2 ] || die '--root requires a path'
            root_dir="$2"
            shift
            ;;
        --discover)
            discover=1
            ;;
        --max-depth)
            [ "$#" -ge 2 ] || die '--max-depth requires a number'
            max_depth="$2"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown option: $1"
            ;;
    esac
    shift
done

[ "$push_after_update" -eq 0 ] || [ "$apply" -eq 1 ] || die '--push requires --apply'

github_ssh_alias_url() {
    case "$1" in
        git@github.com:*)
            printf 'git@github.com-saski:%s\n' "${1#git@github.com:}"
            ;;
        *)
            printf '%s\n' "$1"
            ;;
    esac
}

is_github_url() {
    case "$1" in
        *github.com*|git@github.com:*|git@github.com-saski:*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

current_branch_for() {
    git -C "$1" symbolic-ref --quiet --short HEAD 2>/dev/null || true
}

discover_repos() {
    printf '# path source_remote source_branch update_branch push_remote\n'
    while IFS= read -r git_marker; do
        repo="${git_marker%/.git}"
        rel="${repo#"$root_dir"/}"
        branch="$(current_branch_for "$repo")"
        [ -n "$branch" ] || branch='main'

        upstream_url="$(git -C "$repo" config --get remote.upstream.url 2>/dev/null || true)"
        origin_url="$(git -C "$repo" config --get remote.origin.url 2>/dev/null || true)"

        if [ -n "$upstream_url" ] && is_github_url "$upstream_url"; then
            printf '%s upstream %s %s origin\n' "$rel" "$branch" "$branch"
        elif [ -n "$origin_url" ] && is_github_url "$origin_url"; then
            printf '%s origin %s %s -\n' "$rel" "$branch" "$branch"
        else
            printf '# %s # no GitHub remote found\n' "$rel"
        fi
    done < <(find "$root_dir" -maxdepth "$max_depth" \( -name .git -type d -o -name .git -type f \) -print 2>/dev/null || true)
}

if [ "$discover" -eq 1 ]; then
    discover_repos
    exit 0
fi

[ -f "$manifest" ] || die "manifest not found: $manifest"

total=0
current=0
would_update=0
updated=0
skipped=0
failed=0
pushed=0

report() {
    printf '%-12s %-38s %s\n' "$1" "$2" "$3"
}

fetch_source_ref() {
    repo="$1"
    remote="$2"
    branch="$3"
    remote_url="$(git -C "$repo" config --get "remote.$remote.url" 2>/dev/null || true)"

    [ -n "$remote_url" ] || return 2

    fetch_target="$remote"
    if [ "$(github_ssh_alias_url "$remote_url")" != "$remote_url" ]; then
        fetch_target="$(github_ssh_alias_url "$remote_url")"
    fi

    git -C "$repo" fetch --quiet --tags "$fetch_target" "+refs/heads/$branch:refs/remotes/$remote/$branch"
}

push_branch() {
    repo="$1"
    remote="$2"
    branch="$3"
    remote_url="$(git -C "$repo" config --get "remote.$remote.url" 2>/dev/null || true)"

    [ -n "$remote_url" ] || return 2

    push_target="$remote"
    if [ "$(github_ssh_alias_url "$remote_url")" != "$remote_url" ]; then
        push_target="$(github_ssh_alias_url "$remote_url")"
    fi

    git -C "$repo" push "$push_target" "HEAD:refs/heads/$branch"
}

sync_repo() {
    rel_path="$1"
    source_remote="$2"
    source_branch="$3"
    update_branch="$4"
    push_remote="$5"
    repo="$root_dir/$rel_path"
    remote_ref="refs/remotes/$source_remote/$source_branch"

    total=$((total + 1))

    if ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        report 'skip' "$rel_path" 'not a Git repo directory'
        skipped=$((skipped + 1))
        return
    fi

    branch="$(current_branch_for "$repo")"
    if [ -z "$branch" ]; then
        report 'skip' "$rel_path" 'detached HEAD'
        skipped=$((skipped + 1))
        return
    fi

    if [ "$branch" != "$update_branch" ]; then
        report 'skip' "$rel_path" "on $branch, expected $update_branch"
        skipped=$((skipped + 1))
        return
    fi

    git -C "$repo" update-index -q --refresh >/dev/null 2>&1 || true
    status="$(git -C "$repo" status --porcelain=v1 2>/dev/null || true)"
    if [ -n "$status" ]; then
        report 'skip' "$rel_path" 'dirty worktree'
        skipped=$((skipped + 1))
        return
    fi

    if [ "$fetch" -eq 1 ]; then
        if ! fetch_source_ref "$repo" "$source_remote" "$source_branch"; then
            report 'error' "$rel_path" "fetch failed from $source_remote/$source_branch"
            failed=$((failed + 1))
            return
        fi
    fi

    if ! git -C "$repo" rev-parse --verify --quiet "$remote_ref^{commit}" >/dev/null; then
        report 'skip' "$rel_path" "missing remote ref $source_remote/$source_branch"
        skipped=$((skipped + 1))
        return
    fi

    local_head="$(git -C "$repo" rev-parse HEAD 2>/dev/null)" || {
        report 'error' "$rel_path" 'failed to resolve local HEAD'
        failed=$((failed + 1))
        return
    }
    remote_head="$(git -C "$repo" rev-parse "$remote_ref" 2>/dev/null)" || {
        report 'error' "$rel_path" "failed to resolve $remote_ref"
        failed=$((failed + 1))
        return
    }

    if [ "$local_head" = "$remote_head" ]; then
        report 'current' "$rel_path" "$update_branch matches $source_remote/$source_branch"
        current=$((current + 1))
        return
    fi

    if git -C "$repo" merge-base --is-ancestor HEAD "$remote_ref"; then
        if [ "$apply" -eq 0 ]; then
            report 'would-ff' "$rel_path" "${local_head:0:8} -> ${remote_head:0:8}"
            would_update=$((would_update + 1))
            return
        fi

        if ! git -C "$repo" merge --quiet --ff-only "$remote_ref"; then
            report 'error' "$rel_path" 'fast-forward failed'
            failed=$((failed + 1))
            return
        fi

        updated=$((updated + 1))
        if [ "$push_after_update" -eq 1 ] && [ "$push_remote" != '-' ]; then
            if push_branch "$repo" "$push_remote" "$update_branch"; then
                pushed=$((pushed + 1))
                report 'updated' "$rel_path" "${local_head:0:8} -> ${remote_head:0:8}; pushed $push_remote"
            else
                report 'error' "$rel_path" "updated locally, push to $push_remote failed"
                failed=$((failed + 1))
            fi
        else
            report 'updated' "$rel_path" "${local_head:0:8} -> ${remote_head:0:8}"
        fi
        return
    fi

    if git -C "$repo" merge-base --is-ancestor "$remote_ref" HEAD; then
        report 'skip' "$rel_path" "local branch is ahead of $source_remote/$source_branch"
    else
        report 'skip' "$rel_path" "local branch diverged from $source_remote/$source_branch"
    fi
    skipped=$((skipped + 1))
}

while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        ''|\#*)
            continue
            ;;
    esac

    IFS=$'\t' read -r rel_path source_remote source_branch update_branch push_remote extra <<< "$line" || true
    if [ -z "${rel_path:-}" ] || [ -z "${update_branch:-}" ]; then
        report 'error' "$line" 'manifest row needs at least 4 columns'
        failed=$((failed + 1))
        continue
    fi
    push_remote="${push_remote:--}"

    sync_repo "$rel_path" "$source_remote" "$source_branch" "$update_branch" "$push_remote"
done < "$manifest"

printf '\n'
printf 'Summary: total=%s current=%s would_ff=%s updated=%s pushed=%s skipped=%s failed=%s\n' \
    "$total" "$current" "$would_update" "$updated" "$pushed" "$skipped" "$failed"

[ "$failed" -eq 0 ]
