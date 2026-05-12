# RTK - Rust Token Killer

Use `rtk` as the default command wrapper for shell operations whenever available.

## Resolution Order

When a tool hook needs to find RTK, resolve binaries in this order:

1. `rtk` from `PATH`
2. `~/.agents/bin/rtk`
3. `/opt/homebrew/bin/rtk`

## Quick Check

Run this once per session if shell usage is expected:

```bash
rtk --version
```

If `rtk` is not available, continue with normal shell commands.

## Preferred Usage

- Prefer `rtk <command>` over raw `<command>` for common CLI tasks.
- Keep direct `rtk` meta commands available for diagnostics:
  - `rtk gain`
  - `rtk gain --history`
  - `rtk discover`
  - `rtk proxy <command>`

## Notes

- This file is intentionally tool-agnostic so shared rule loaders (Cursor, Codex, Claude) can all consume the same guidance.
- If no compatible RTK binary is available, hooks should fail open and continue with normal shell commands.
