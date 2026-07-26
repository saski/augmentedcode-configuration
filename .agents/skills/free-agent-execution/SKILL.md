---
name: free-agent-execution
description: Run an explicitly requested, bounded, non-sensitive coding task through the local free-worker adapter using a verified free OpenCode model. Use only when the user asks to execute a free worker or free agent and accepts the external-model safety boundary.
---

# Free Agent Execution

Use the bundled `scripts/run-free-worker` adapter to execute one bounded worker task. The frontier agent remains responsible for preparing the contract, reviewing the result, and deciding what to keep.

Do not invoke the adapter unless the user explicitly authorizes free-agent execution. Never include secrets, credentials, personal data, or other sensitive material in the requirement or working tree.

## Invocation

Pass one JSON contract file:

```bash
.agents/skills/free-agent-execution/scripts/run-free-worker /absolute/path/to/contract.json
```

The adapter writes one JSON result to standard output. A missing or unreadable contract is a usage error with exit status `2`. Contract, model, worker, scope, and validation failures are returned as JSON with `status: "failed"`.

## Input contract

Use this shape:

```json
{
  "contract_version": "1",
  "mode": "free",
  "execution_role": "worker",
  "parent_role": "frontier",
  "parent_run_id": "run-123",
  "delegation_depth": 1,
  "task_id": "task-1.1",
  "task_class": "bounded_code",
  "sensitivity": "non_sensitive",
  "working_directory": "/absolute/path/to/git-worktree",
  "requirement": "Implement one precise, bounded change.",
  "allowed_files": [
    "relative/path/to/file"
  ],
  "validation": {
    "command": [
      "make",
      "test"
    ]
  },
  "model": "omniroute/oc/deepseek-v4-flash-free",
  "timeout_seconds": 30
}
```

The adapter requires these values and types:

- `contract_version`: exactly `"1"`.
- `mode`: exactly `"free"`.
- `execution_role`: exactly `"worker"`.
- `parent_role`: exactly `"frontier"`.
- `sensitivity`: exactly `"non_sensitive"`.
- `working_directory`: a non-empty absolute path inside a Git worktree. Prefer the worktree root so Git paths match `allowed_files`.
- `requirement`: a non-empty string containing one bounded implementation task.
- `allowed_files`: an array of worktree-relative file paths. Use exact Git path spelling.
- `validation.command`: a non-empty array of executable and argument strings. It is executed directly, without shell interpolation.
- `model`: one of the verified models below.

The remaining fields in the example are trace metadata. Preserve them for auditability, but note that adapter version 1 does not currently validate or enforce them. In particular, `timeout_seconds` is informational and does not stop a long-running worker.

## Verified free models

Only these model identifiers are accepted:

- `omniroute/oc/deepseek-v4-flash-free`
- `omniroute/oc/big-pickle`

Do not substitute aliases or newly advertised free models without updating and validating the adapter allowlist.

## Result contract

A completed adapter run returns:

```json
{
  "status": "succeeded",
  "model": "omniroute/oc/deepseek-v4-flash-free",
  "summary": "Implemented the bounded task.",
  "changed_files": [
    "relative/path/to/file"
  ],
  "validation": {
    "command": [
      "make",
      "test"
    ],
    "status": "passed"
  },
  "usage": {
    "input_tokens": 10,
    "output_tokens": 20
  }
}
```

`status` is `"succeeded"` only when OpenCode exits successfully, returns usable final text, changes no newly dirty paths outside `allowed_files`, and the validation command passes. The preferred final format is `FREE_AGENT_RESULT` because it gives a concise structured summary; ordinary non-empty final text is retained as the summary when the worker does not follow that format. Failed runs include a `diagnostic` when the adapter reaches normal result assembly.

`changed_files` contains paths that are dirty after the worker but were not dirty immediately before it ran. Pre-existing tracked and untracked changes are intentionally excluded.

## Safety boundaries

- The adapter configures the worker with delegation (`task`) and shell (`bash`) denied. The frontier agent performs validation after the worker returns.
- `allowed_files` is a post-execution check, not a write sandbox. An out-of-scope change fails the result but is not reverted.
- The Git comparison is path-based. A worker change to a path that was already dirty before execution is not attributed or scope-checked. Use a clean worktree for stronger attribution, especially for allowed files.
- The validation command is trusted local code and runs with the adapter caller's permissions even when the worker fails. Review the array before execution.
- The adapter does not provide filesystem, network, process, resource, or time isolation. OpenCode and the selected external model remain outside this contract.
- Free-model prompts and accessible code must be non-sensitive. Stop if the task needs secrets, production data, private credentials, or broad repository access.
- Review `changed_files`, the Git diff, the diagnostic, and validation evidence before accepting the worker's changes.
