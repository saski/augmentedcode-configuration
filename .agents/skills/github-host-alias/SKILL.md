---
name: github-host-alias
description: Use when running git clone, git remote add, or suggesting git commands interacting with GitHub to ensure the correct SSH host alias is used based on the local workspace path (~/eventbrite vs ~/saski).
---

# GitHub Host Alias Selection

## Goal

Ensure the correct GitHub account is used when authenticating via SSH, by applying the appropriate host alias configured in the user's `~/.ssh/config`.

## Use This Skill When

- Cloning a repository from GitHub.
- Adding or modifying a git remote.
- Suggesting or running `git` commands that involve fetching, pulling, pushing, or cloning over SSH.
- Working in an Eventbrite-related directory versus a personal one.

## SSH Host Aliases Context

The environment has multiple GitHub accounts configured via `~/.ssh/config`:

- **`github.com`** (default):
  - Authenticates as `saski` (personal account).
  - Has NO access to the Eventbrite organization.
  - **Path trigger**: Use this for work under `~/saski/*` or general personal paths.
  
- **`github.com-eventbrite`**:
  - Uses `~/.ssh/id_ed25519_eventbrite` for authentication (Eventbrite account).
  - Has access to Eventbrite organization repositories.
  - **Path trigger**: Use this ALWAYS for work under `~/eventbrite/*` or `~/evenrbrite/*`.

## Workflow & Examples

1. **Check the local path**: Identify whether the target directory for the repository is under the `evenrbrite`/`eventbrite` folder or the `saski` folder.
2. **Format the SSH URL**:
   - If Eventbrite, the SSH URL must use `@github.com-eventbrite:`.
   - If personal, the SSH URL must use `@github.com:`.

### Example: Cloning

**Personal repo (under `~/saski/*`)**
```bash
git clone git@github.com:saski/my-personal-repo.git
```

**Eventbrite repo (under `~/eventbrite/*` or `~/evenrbrite/*`)**
```bash
git clone git@github.com-eventbrite:eventbrite/some-internal-repo.git
```

### Example: Fixing an Existing Remote

If an Eventbrite repository was cloned with the default host alias and authentication fails, update the remote URL:
```bash
git remote set-url origin git@github.com-eventbrite:eventbrite/repository-name.git
```

## Cross-Platform Rules

- Treat this as a universal rule for any AI coding assistant suggesting or running git commands in this environment. 
- Do not attempt to modify the `~/.ssh/config` file; rely on these aliases being present.
- Always verify the workspace path before presenting a git URL.
