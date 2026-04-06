---
name: github-host-alias
description: Use when running git clone, git remote add, or suggesting git commands interacting with GitHub to ensure the correct SSH host alias is used based on the local workspace path (~/work vs non-work paths).
---

# GitHub Host Alias Selection

## Goal

Ensure the correct GitHub account is used when authenticating via SSH, by applying the appropriate host alias configured in the user's `~/.ssh/config`.

## Use This Skill When

- Cloning a repository from GitHub.
- Adding or modifying a git remote.
- Suggesting or running `git` commands that involve fetching, pulling, pushing, or cloning over SSH.
- Working in a work-related directory versus a personal one.

## SSH Host Aliases Context

The environment has multiple GitHub accounts configured via `~/.ssh/config`:

- **`github.com`** (default):
  - Authenticates as `saski` (personal account).
  - Has NO access to the work organization.
  - **Path trigger**: Use this for any path outside `~/work/*`.
  
- **`github.com-work`**:
  - Uses `~/.ssh/id_ed25519_work` for authentication (work account).
  - Has access to work organization repositories.
  - **Path trigger**: Use this ALWAYS for work under `~/work/*`.

## Workflow & Examples

1. **Check the local path**: Identify whether the target directory for the repository is under the `work` folder or outside it.
2. **Format the SSH URL**:
   - If work, the SSH URL must use `@github.com-work:`.
   - If personal, the SSH URL must use `@github.com:`.

### Example: Cloning

**Personal repo (outside `~/work/*`)**
```bash
git clone git@github.com:saski/my-personal-repo.git
```

**Work repo (under `~/work/*`)**
```bash
git clone git@github.com-work:work-org/some-internal-repo.git
```

### Example: Fixing an Existing Remote

If a work repository was cloned with the default host alias and authentication fails, update the remote URL:
```bash
git remote set-url origin git@github.com-work:work-org/repository-name.git
```

## Cross-Platform Rules

- Treat this as a universal rule for any AI coding assistant suggesting or running git commands in this environment. 
- Do not attempt to modify the `~/.ssh/config` file; rely on these aliases being present.
- Always verify the workspace path before presenting a git URL.
