---
name: code-notify
description: Use when a task should trigger a local completion notification through code-notify, or when configuring cross-tool notification behavior for Codex, Cursor, Claude, Gemini, or similar agent workflows. Verify the installed command or existing local integration before relying on it.
---

# Code Notify

## Goal

Make supported AI tools finish noisy terminal work with a local notification instead of requiring manual polling.

## Use This Skill When

- The user asks to enable or wire completion notifications for an AI coding tool.
- A workflow should notify when a long-running task finishes or needs attention.
- You are documenting shared agent capabilities in a cross-tool setup.

## Cross-Platform Rules

- Treat `code-notify` as an optional local dependency managed outside this repository.
- Verify the installed command, wrapper, hook, or config before using it.
- Prefer shared wording and forward-slash paths so the guidance works across macOS, Linux, and Windows-compatible shells.
- Keep the integration additive. Do not replace existing hooks or notification settings unless the user asks.

## Workflow

1. Detect whether the current tool already has a notification hook or wrapper configured.
2. Look for a local `code-notify` command, alias, script, or documented install path before assuming invocation details.
3. If present, use it for end-of-task or attention-needed notifications only.
4. If missing, tell the user the integration is unavailable in the current shell and continue without blocking the main task.

## Output Guidance

- Mention that `code-notify` is available only after verifying the local installation.
- Keep notification instructions tool-agnostic unless the user asks for a specific platform.
- Prefer concise setup notes over tool-specific prose duplication.
