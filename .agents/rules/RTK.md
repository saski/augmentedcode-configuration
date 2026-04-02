# RTK - Rust Token Killer

Use `rtk` as the default command wrapper for shell operations whenever available.

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
