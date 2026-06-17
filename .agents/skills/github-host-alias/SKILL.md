---
name: github-host-alias
description: Use when running git clone, git remote add, git remote set-url, or suggesting GitHub SSH commands to ensure all GitHub access uses the saski SSH host alias.
---

# GitHub Host Alias

## Goal

Ensure every GitHub SSH operation in this environment uses the single configured account: `saski`.

## Use This Skill When

- Cloning a repository from GitHub.
- Adding or modifying a git remote.
- Suggesting or running `git` commands that involve fetching, pulling, pushing, or cloning over SSH.
- Troubleshooting GitHub auth where SSH aliases and `gh auth login` are being conflated.

## SSH Host Alias Context

All GitHub access should use:

```text
git@github.com-saski:
```

Do not use bare `git@github.com:` in this environment. If a command, remote, or example uses bare GitHub SSH, rewrite it to `git@github.com-saski:`.

## GitHub CLI Caveat

- `github.com-saski` is an SSH alias from `~/.ssh/config`, not a separate GitHub CLI host.
- Do not use `gh auth login` to choose Git-over-SSH identity.
- Only use `gh auth login` when a GitHub CLI command on `github.com` truly requires API authentication.
- Before suggesting `gh auth login`, inspect whether `GITHUB_TOKEN` is set.
- If `GITHUB_TOKEN` is set, `gh auth login` will authenticate from that environment variable and will not store interactive credentials. For a stored login, run `env -u GITHUB_TOKEN gh auth login` or unset `GITHUB_TOKEN` in that shell first.
- Confirm CLI auth separately with `gh auth status`.

## Workflow

1. Check whether the target URL is a GitHub SSH URL.
2. Normalize bare GitHub SSH URLs:
   - `git@github.com:owner/repo.git`
   - becomes `git@github.com-saski:owner/repo.git`
3. Leave already-correct `git@github.com-saski:` URLs unchanged.
4. For HTTPS GitHub remotes that should use SSH, replace them with `git@github.com-saski:owner/repo.git`.

### Example: Cloning

```bash
git clone git@github.com-saski:saski/my-repo.git
```

### Example: Fixing an Existing Remote

If a repository was cloned with the default GitHub SSH host or HTTPS and authentication fails, update the remote URL:
```bash
git remote set-url origin git@github.com-saski:owner/repository-name.git
```

## Cross-Platform Rules

- Treat `github.com-saski` as the universal GitHub SSH alias for this environment.
- Do not choose GitHub SSH identity based on local workspace path.
- Do not attempt to modify the `~/.ssh/config` file; rely on these aliases being present.
