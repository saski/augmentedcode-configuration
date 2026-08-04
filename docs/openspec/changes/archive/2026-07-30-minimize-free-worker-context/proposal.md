## Why

The successful bounded free-worker smoke consumed approximately 90,000 input
tokens for a trivial one-file edit. The handoff contract was small and the
worktree was clean, so the likely fixed cost is OpenCode's generic agent and
tool context rather than task content.

## What Changes

- Configure the ephemeral `free-worker` agent with a concise purpose prompt,
  a three-step cap, and an explicit `read`/`edit` tool allowlist.
- Deny shell, network, delegation, discovery, interactive, and skill tools in
  both the tool configuration and permission policy.
- Preserve the adapter's external file-scope and validation checks.
- Establish a measured smoke-test baseline before considering any input-token
  budget gate or a separate direct-completion execution path.

## Implementation Result

On 2026-07-30, three bounded smokes against
`omniroute/oc/deepseek-v4-flash-free` used 20,082, 20,134, and 20,509 input
tokens, versus the 90,297-token baseline (a 77.3–77.8% reduction). They
returned structured results, changed only allowed files, and passed declared
validation. The narrow 427-token range confirms the minimal-agent direction.
The configuration is retained as the worker default; a hard budget remains out
of scope because usage is available only after execution and real tasks may
legitimately require more reading.

## Out of Scope

- Replacing bounded code workers with a direct OmniRoute completion client.
- Changing model allowlists, paid fallback policy, or routing ownership.
- Promising a token threshold before an A/B measurement is available.
