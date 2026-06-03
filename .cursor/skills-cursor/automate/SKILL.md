---
name: automate
description: Use this skill to create Cursor Automations.
environments:
  - local
---
# Create Automation (Interactive)

Use this skill when the user explicitly wants to make, build, set up, or create a new **Cursor Automation** — for example "create a Cursor automation", "open the Automations editor with this draft", or "set up a scheduled Cursor agent".

**Disambiguation.** "Automation" in a user workspace can mean many things (`.github/workflows`, CI pipelines, scheduled jobs, scripts, dbt, browser automation, shell scripts, workflow engines). Do **not** assume generic phrases like "automate this", "help me automate my deploys", or "make an automation" mean **Cursor Automation**. Route to the named surface when the user mentions one, use normal repo/product exploration when the context points elsewhere, or ask a short clarifying question when the target surface is ambiguous. Start this spine only when the user explicitly asks for Cursor Automations or confirms that Cursor Automations is the intended surface.

## Execution spine (every run)

1. **Finish-path check.** First, check whether the in-app Automations editor handoff is available (see **Finish availability** below). If neither the Automations editor tool nor the resource opener is available, immediately say "Please use this skill in the Agents Window." and stop.
2. **Capture intent + proactive integration discovery.** After the finish-path check passes, if the prompt is missing 2+ of {what kicks it off, what should happen, what outcome}, send one short plain-chat message asking for a 1–2 sentence description and wait. Skip when the prompt already names trigger + action + outcome. Proactively run discovery for any integration the user named or implied — `gh repo view` on cwd; Slack MCP channels; PagerDuty MCP services; Linear/Sentry MCP teams/projects. Use the results to skip questions later.
3. **Completeness gates.** Work through the trigger, tool, prompt, naming, and PCD checks below. Do not jump to a summary while required picker-backed fields are still unknown unless the user explicitly deferred them to the Automations editor.
4. **One consolidated question.** Ask inline for whatever integration discovery couldn't resolve — trigger details, repo / channel / service when ambiguous, tools when not obvious. Default to plain-chat inline. Only escalate to `AskQuestion` for (a) the tools multi-select and (b) integration discovery candidate lists with 3+ matches.
5. **Draft table → approval → finish handoff.** Show a compact Markdown table (plain language, no YAML) recapping name / description, trigger, tools, instructions, resolved settings, and "to finish in editor". User approves, then ask whether they are ready for you to open the Automations editor so they can finish any deferred values there. When they say yes, use the finish path from the availability check.

---

## House rules

- **Plain language only.** Never show or talk about MCP / tool / proto names, request types, enum values, stage labels, or raw CLI output in user-visible chat. Say "open the editor with the draft", "the Slack channel", "the repo and branch". Exception: the user explicitly asks to see internals.
- **No YAML in finalization.** The draft table = compact Markdown only in plain language. Build and validate YAML / JSON internally; surface the wire payload only when the user asks for it.
- **No automatic fallbacks.** Never submit, open a URL, paste a browser prefill link, or switch buckets. The only finish path is the reviewed draft table, user approval, user readiness confirmation, then opening the Automations editor. If neither the Automations editor tool nor the resource opener is available, stop immediately and tell the user to use this skill in the Agents Window.
- **Creation-only.** This skill prepares new automations only. Do not list, get, inspect, update, or search existing Cursor Automations from chat.
- **Integration discovery is allowed.** Use connected integration MCP read / list / search tools for picker-backed integration values such as Slack channels, PagerDuty services, Linear teams, and Sentry projects. This does **not** include backend automation tools that list, get, inspect, create, update, finish, or prefill Cursor Automations.

---

## PCD — Portal completeness & deferral

Use these checks to keep the draft complete before opening the editor. Do not show the ids to the user.

| Id | Scope |
|----|-------|
| **PCD:slack-trigger** | `slackTrigger` channel selection. Ask whether to specify channel(s) now or pick them in the Automations UI; discovery or explicit UI deferral must happen before the draft table. |
| **PCD:slack-actions** | `slack` / `readSlack` actions. Ask for the destination or explicit editor deferral before the draft table. |
| **PCD:git-scope** | `git` PR / push / CI triggers. Repo/org/branch scope must be resolved or explicitly deferred to the editor. |
| **PCD:workflow-gitpr** | Non-`git` trigger plus `gitPr` action. `workflow.gitConfig` needs repo + branch, or the user must explicitly defer repo + branch to the editor. |
| **PCD:universal** | Every intentional gap appears in the draft table's "To finish in editor" row and is repeated in the final handoff note. |

### PCD matrix

| Scope | Before opening editor unless deferred |
|-------|---------------------------------------|
| **PCD:slack-trigger** | Slack channel ids are resolved, or user chose to pick channels in the Automations UI. Empty channels are valid only for explicit UI deferral. |
| **PCD:slack-actions** | `slack.channel` / readSlack scope is resolved, or user chose **Select channels** in the editor. IDs must be `C…` / `G…` / `D…`, never `U…`. |
| **PCD:git-scope** | PR triggers have repos/orgs; push triggers have repo + branch; CI triggers have repo scope. Use scoped repo discovery only after the user identifies the target. |
| **PCD:workflow-gitpr** | `workflow.gitConfig` is filled when repo + branch are known; otherwise defer repo + branch to the editor and say so in the draft table. |

### PCD notes

- Slack trigger and Slack action destinations are separate questions. A Slack trigger does not imply a Slack action destination, and a Slack action does not imply a Slack trigger channel.
- Do not prefill empty Slack channel values after the user chose "specify now" unless discovery ran or the user explicitly switched to editor deferral.
- For Slack replies, offer "respond in the triggering thread" separately from "send to a specific channel or DM".
- When `mcp` is enabled, the server must pass the **MCP existence gate** below. Prefer discovering and selecting the exact catalog server name yourself; ask the user only when multiple usable catalog matches fit the request or the requested integration is ambiguous. Do not call it a Cursor plugin. Do not invent server names.

### MCP existence gate

An MCP server is eligible only when the current user's available MCP/tool catalog proves it exists and is usable in this session. Before using an MCP for integration discovery or adding an `mcp` action to the draft, inspect the actual catalog exposed to the agent session and pick the right value to put into `mcp.server.name`.

**Read the right field from the catalog.** Each agent-side catalog entry lives at `~/.cursor/mcps/<folder>/SERVER_METADATA.json` and carries two distinct values:

- `serverIdentifier` — the scoped folder name the agent runtime uses (e.g. `dashboard-team-1-Linear`, `plugin-pagerduty-pagerduty-mcp`, `cursor-app-control`).
- `serverName` — the plain name the user configured on cursor.com (e.g. `Linear`, `pagerduty-mcp`, `Databricks SQL`).

Write `serverName` into `workflow.actions[].mcp.server.name` and any `@[MCP: ...]` prompt mentions. Never write `serverIdentifier` / the folder name, never invent or paraphrase a prefix (`team-…`, `user-…`, `<orgId>-…`), and never hand-strip prefixes from the folder name — many `serverName`s contain spaces (e.g. `Databricks SQL`, `statsig read only console`), so string-munging the identifier is fragile. The Automations editor matches on trim + lowercase, so casing does not matter, but pass the exact `serverName` from `SERVER_METADATA.json` anyway. When you have a useful URL, you may also pass `templateMcpHints: [{ name: <serverName>, url: <serverUrl> }]` so a URL match can rescue a name drift.

**Eligibility — dashboard-backed servers only.** Only dashboard-backed servers appear in the Automations editor's `GetAvailableMcpServers` response, which is what the editor uses to resolve a prefilled `mcp` action to a connected server. Their `serverIdentifier` always begins with one of these prefixes:

- `dashboard-team-<teamId>-` (team-shared servers)
- `dashboard-` (personal user-configured servers on cursor.com)
- `plugin-<slug>-` (marketplace plugin servers)

Everything else in the agent catalog — `cursor-ide-browser`, `cursor-app-control`, `extension-…`, project `mcp.json` servers, and other local servers — does NOT appear in the dashboard catalog. Treat those as ineligible for the `mcp` action: do not add them to `workflow.actions`, do not reference them in `@[MCP: ...]` prompt mentions, and do not assume they will resolve when the editor opens. Prefilling an ineligible server lands the row in the blocked "Set up MCP" state and prevents the user from saving.

If one usable, dashboard-eligible catalog server clearly matches the user's requested integration, use it without asking the user to spell the server name. A name from the user prompt, a screenshot, a skill file, a workflow template, marketplace docs, or company convention is not proof.

If the catalog does not contain a usable, dashboard-eligible server, do not call that MCP, do not add an `mcp` action for it, and do not include `@[MCP: ...]` prompt mentions. Servers that are missing, disabled, still need setup, or require auth count as unavailable for prefill. Ask the user to set it up first, or leave the MCP out of the draft and record "Set up/select <integration> in the Automations editor" in **To finish in editor**. Unknown MCP server names are not valid deferred tool rows because prefilled missing MCPs block save.

---

## Procedure

### Stage 0 — Finish availability (must run before intent capture)

**Finish availability** (check once per run; this is the agent-internal decision — never quote tool names back to the user). Do not mention this check to the user. Do not say anything like "I'll first check whether the Automations editor handoff is available in this session." Do not inspect Cursor backend automation tools. Do not inspect Cursor backend automation tool descriptors to recover an old finish path.

| Bucket | Signal | Default finish |
|--------|--------|----------------|
| **Automations editor** | `cursor-app-control.open_automation` listed | Open the Automations editor with the reviewed draft |
| **Agents Window required** | Neither `cursor-app-control.open_automation` nor `cursor-app-control.open_resource` listed | Stop immediately — say "Please use this skill in the Agents Window." |

The Automations editor path uses `open_automation` directly with the reviewed draft. Do not inspect or call backend automation finish tools, build or paste a browser prefill URL, call `open_resource`, or build a `cursor://` deeplink.

If neither `cursor-app-control.open_automation` nor `cursor-app-control.open_resource` is available, do not continue the automation-drafting flow, do not generate a browser prefill URL, and do not ask follow-up questions. Immediately tell the user: "Please use this skill in the Agents Window."

### Stage 1 — Capture intent (plain chat, no AskQuestion)

Run this stage only after the finish availability check passes. If the user's prompt is thin, send one short plain-chat message and **wait**:

> "Before we dive in, what do you want this automation to do? What kicks it off, what should happen, and what's the outcome? A sentence or two is plenty. Let me know if you want some examples of what you can build."

Skip when the prompt already covers trigger + action + outcome, or the user said something similar to "walk me through it". The answer is freeform — never wrap this question in `AskQuestion`. Don't run repo discovery before Stage 1 fires or is deliberately skipped.

### Stage 2 — Authoring funnel

Existing automation edits are not supported in this flow. Do not list, get, inspect, update, or search existing automations through backend automation tools. Do not search by automation name or description. If the user wants to change an existing automation, ask them to edit it directly in the Automations UI or create a new replacement automation. Do not claim changes were saved from chat.

Work in Automations UI order: trigger → tools → prompt → name/description → draft table. Fill gaps from prior messages. Do not jump straight to YAML unless the user's prompt already covers the needed fields and PCD gates are satisfied or explicitly deferred.

#### Trigger

Use the **Appendix — Trigger selection tables** to pick the trigger and follow-ups. Resolve picker-backed values via integration discovery before asking; ask only for fields not already answered. A cron trigger without a resolved schedule is invalid for direct save; webhook triggers always come back to the editor after save for URL / auth.

#### Scheduled times

Cron stores a single expression, not a separate timezone field. If the user gives a schedule that maps cleanly to cron fields (for example "every weekday at 3am", "daily at 9am", or "Mondays at 9am"), include the cron trigger in the editor prefill. Treat "my timezone" or "local time" as the user's desired display-time intent when the hour/day pattern itself is expressible as cron. Do not put a schedule only in the prompt while leaving `workflow.triggers` empty.

For user-stated local times that cannot be encoded exactly as the Automations editor will display, do not pass a raw cron plus a timezone hint. Ask one more schedule question before opening the editor; do not open a scheduled automation with no trigger. Do not prefill `cron: {}`. It is invalid.

Valid cron examples:

```yaml
# Every hour
cron: { cron: "0 * * * *" }

# Every day at 9:00
cron: { cron: "0 9 * * *" }

# Every Monday at 9:00
cron: { cron: "0 9 * * 1" }

# Weekdays at 9:00
cron: { cron: "0 9 * * 1-5" }
```

#### Tools

Ask with structured multi-select when the tools are not obvious:

| Label | YAML |
|-------|------|
| Open or update PRs | `gitPr` |
| Comment on PRs | `prComment` |
| Post to Slack | `slack` |
| Read Slack | `readSlack` |
| Request reviewers | `requestReviewers` |
| Manage check runs | `manageCheckRun` |
| Use MCP server | `mcp` |

When `slack` / `readSlack` is enabled, resolve the channel via Slack MCP discovery before drafting or document UI deferral. When `mcp` is enabled, run the MCP existence gate first; only exact, usable catalog matches may be added to `workflow.actions`, and `mcp.server.name` MUST be the `serverName` value from the matched entry's `SERVER_METADATA.json` — never the folder / `serverIdentifier`. If a requested MCP is not available, do not prefill it. Ask the user to set it up now or defer setup/selection to the editor, and keep the MCP out of the Tools list until it exists. When a non-`git` trigger pairs with `gitPr`, resolve repo + branch via scoped `gh` discovery before drafting or document UI deferral. Same bar as the trigger — integration discovery first, then either fill the YAML or note the deferral in the draft table.

#### Prompt + name

Ask "What should the agent do when [trigger]?" Default one tight paragraph; match the user's length if they gave more. Cloud compute is configured in the [Cloud Agent dashboard](https://cursor.com/dashboard?tab=cloud-agents). Suggest a name + 1–2 sentence description from prior answers.

#### Fast-path

If confidence is high and required fields are present, you may skip straight to the draft table. Do not use fast-path to skip Slack channel choices, Git repo/branch scope, non-`git` trigger + `gitPr` repo/branch, `mcp.server.name`, or an unresolved schedule. When uncertain, ask one focused question rather than replaying the full questionnaire.

### Stage 3 — Draft table, validation, finish

Recap the draft as a compact Markdown table in plain language. Don't write a planning document, checklist, or "steps I'll take":

| Draft field | What will open in the editor |
|-------------|------------------------------|
| Name / description | Short plain-language value |
| Trigger | What starts the automation |
| Tools | Enabled capabilities |
| Instructions | The prompt behavior, summarized |
| Resolved settings | Repo / branch, Slack channel, service / project, schedule, and other picker-backed values |
| To finish in editor | Settings deferred to the Automations UI; write "None" if nothing is deferred |

End with "Does this look correct?" Do not append a YAML or JSON block. After approval, run the internal **Validation check**, then send the finish handoff confirmation. A plain "yes" to the draft approves the draft, but it does not replace the final readiness confirmation.

#### Glass finish path (compliance)

When `cursor-app-control.open_automation` is available, there is exactly one finish path:

1. Show the Markdown draft table.
2. Wait for the user to approve it.
3. Tell the user which values, setup, or webhook/auth details must be finished in the Automations editor. Ask a direct readiness question, such as "Are you ready for me to open it for you?"
4. After they confirm, open the Automations editor with the reviewed draft.

Do not offer save, browser, paste-link, skip, or fallback choices.

### Post-finish actions (agent-internal)

Before opening the editor or otherwise moving the user away from chat, send one short final handoff note with every deferred field and caveat the user needs after the handoff. Include all "To finish in editor" rows, integration setup notes, webhook/auth follow-ups, Slack DM/channel picker confirmations, Cloud compute notes, and any schedule that was intentionally left for the editor picker. End with a direct readiness question, such as "Are you ready for me to open it for you?" When the user says yes, use the selected finish path. Do not put these reminders after the open step; the user may not see chat once they leave.

- **Open the Automations editor with the draft** (Automations editor). Use only for new automations. Call `cursor-app-control.open_automation` with the reviewed WorkflowData JSON as `prefillWorkflowData`. Do not call backend automation tools, `open_resource`, a browser URL builder, or a `cursor://` URL for this bucket. If `open_automation` fails, explain the failure in plain language and stop.
- **Agents Window required**. If neither `cursor-app-control.open_automation` nor `cursor-app-control.open_resource` is available, say "Please use this skill in the Agents Window." Do not draft, submit, paste a browser prefill URL, or switch paths automatically.

---

## Reference

### Discover before ask

Before asking the user for a picker-backed value (repo, Slack channel / DM, GitHub/GitLab PR / comment scope, PagerDuty service, Linear team, Sentry project, …), proactively check whether the associated integration MCP or CLI is available and authenticated, then fetch the relevant records. For MCP-backed integrations, the availability check must be the current user's actual MCP/tool catalog, not a remembered or guessed server name. Use the result to inform the next question: **1 match → inline confirm; 2 → inline either/or; 3+ → `AskQuestion` single-select.** Only ask freeform after scoped integration discovery is exhausted or the user picks deferral to the automations editor.

**Auth boundary.** Call integration list / search / read tools, `gh`, or `glab` when connected and authenticated. Do not use this path to list, get, inspect, create, update, finish, or prefill Cursor Automations. If the relevant integration or CLI is missing, unavailable, or not authenticated, ask whether the user wants to set it up before continuing. If they say yes, guide setup and retry discovery after they confirm it is ready. If they say no, continue with the draft and say the user will need to finish that integration setup in the Automations editor afterwards. Do not call `mcp_auth` without an explicit **Retry after setup** confirmation.

#### GitHub / GitLab repo scope

Accept natural repo nicknames; do not ask for `owner/repo` format first, and do not ask the user to list repos before trying scoped CLI discovery. Order:

1. **Exact or current repo.** If the user gave exact `owner/repo`, said "this repo", or the current checkout is the obvious target, use `gh repo view owner/repo --json defaultBranchRef,nameWithOwner` or `gh repo view --json defaultBranchRef,nameWithOwner` to fetch repo + default branch. For GitLab, use the equivalent `glab repo view` / project view command when available. Run auth status only if the exact lookup fails due to auth.
2. **Several named candidates.** If the user named several repo candidates, do not run an unscoped search. Resolve exact `owner/repo` candidates with lookup, or run scoped discovery only when a shared owner/org/namespace, current checkout, or product context narrows the search. If no scoped lookup is available, use `AskQuestion` over the user-named repos plus **Pick in Automations UI** before any CLI lookup.
3. **User needs to choose.** If the user needs to select a repo and the owner/org/namespace, nickname, current checkout, or product context scopes the search, proactively fetch candidates before asking: `gh search repos "<nickname> in:name" --json fullName,description --limit 10`, scoped `gh repo list <owner-or-org> --json nameWithOwner,description --limit 20`, or the equivalent scoped `glab repo list` / project search. Do this even when the next step is asking the user to pick one.
4. **Present candidates.** Use discovery results or user-named candidate sets in the next question: 1 match → inline confirm; 2 → inline either/or; 3+ → `AskQuestion` over the returned or named repos plus **Pick in Automations UI**. When repo choice is ambiguous after search/list discovery, use `AskQuestion` over partial matches + UI deferral instead of a freeform repo question.
5. **Confirm branch.** Use the lookup's default branch when available. If the automation requires a specific branch and discovery did not resolve it, ask for branch or offer the default branch explicitly.
6. **Discovery failed or unavailable.** If `gh` / `glab` is missing, unauthenticated, unavailable, or the scoped lookup/search/list fails, then ask the user what repo and branch to use or whether to pick them in the Automations UI. Do not block on CLI setup unless the user chooses **Retry after setup**.

Guardrails: do not run broad private repo inventory or unscoped account/org sweeps. Keep `gh repo list` / `glab repo list` scoped to an owner/org/namespace or similarly narrow context. Do not use raw `git remote` output as the only source of truth.

#### Slack

Slack MCP discovery before channel question, every time `slackTrigger` / `slack` / `readSlack` is involved. **Specify now** means the agent runs discovery first — not "ask the user for IDs". 1 channel → inline confirm; 2 → inline either/or; 3+ → `AskQuestion` over returned channels (+ **Pick in Automations UI**). **Do not prefill with empty channels after Specify now without discovery or continue-without.** If discovery is blocked → **Retry after setup** / **Continue without MCP** / **Pick in Automations UI** inline.

Slack `channel` accepts `C…` / `G…` / `D…` IDs only — never `U…` member IDs. For Slack replies, offer **respond in the triggering thread** separately from **send to a specific channel or DM**. Empty `{}` actions are valid when the user picks **Select channels** in the editor; record the deferral in the draft table.

#### PagerDuty / Linear / Sentry

PagerDuty MCP list services before `serviceIds` scope: 1/2 inline; 3+ → `AskQuestion` over services. **Optional `serviceIds`** — otherwise defer to UI. Linear teams / projects and Sentry projects follow the same pattern: discover when MCP is connected; otherwise defer to the editor.

### YAML output shape (agent-internal)

Wire format matches the reviewed Automations draft passed to `open_automation` as `prefillWorkflowData` — canonical proto JSON with full enum names (e.g. `GIT_PULL_REQUEST_ACTION_OPENED`). PR scope lives on `git.pullRequest` (`repos` / `orgs`); `workflow.gitConfig` holds `repo` + `branch` for non-`git` triggers that need a checkout. Use `ignoreDraftPrs`, not `ignoreDraftPr`. Slack channel / DM IDs: `C…` / `G…` / `D…`.

Skeleton:

```yaml
name: "My automation"
description: "Optional description"
workflow:
  triggers: []
  actions: []
  prompts: []
  model: ""
  agentOptions:
    skipInstall: false
  memoryEnabled: true
```

Full pattern — non-`git` trigger + `gitPr` + scoped service:

```yaml
name: "Incident response PR"
description: "When PagerDuty fires for a scoped service, investigate and open a PR."
workflow:
  triggers:
    - pagerduty:
        incidentTriggered: {}
        serviceIds:
          - "P247HKL"
  actions:
    - gitPr: {}
  prompts:
    - prompt: |
        Use incident title, urgency, and service from the trigger. Investigate the
        configured repo, propose a minimal fix, and open a PR with rationale.
  model: ""
  gitConfig:
    repo: "acme/runbooks"
    branch: "main"
  agentOptions:
    skipInstall: false
  memoryEnabled: false
```

Prompts use `|` block scalar (`>-` folding breaks bullets). Empty `{}` actions are valid when the field is UI-only. `mcp.server.name` is required when `mcp` is enabled, and the name must be the `serverName` field from the matched entry's `SERVER_METADATA.json` — not the folder / `serverIdentifier`. See the MCP existence gate for the eligibility filter and the no-prefix-invention rule.

### Validation check (agent-internal)

After draft table approval: validate YAML vs checklist + proto (PR enums, `ignoreDraftPrs`, Slack ID prefixes, `gitConfig` presence when needed, `mcp.server.name` when `mcp` is enabled, MCP actions backed by usable catalog matches, and description text free of `__securitybot_metadata__` / `customInstruction` metadata markers). **Do not invent inline JSON-schema validators** or shell snippets for automation YAML — they drift from proto shape and can falsely fail valid drafts. If validation fails, explain the issue in plain language and ask what to change; do not paste the full YAML unless the user explicitly asked. **Do not use backend automation tools and do not shell out to repo-local scripts** — use `open_automation` for Automations editor handoff only.

---

## Appendix — Trigger selection tables

These labels are agent-only — never show ids to users. If a future structured picker is used, split rows before any option cap.

### Trigger category

**Prompt:** "When should this automation run?"

| Option label | Option id | Proto / YAML |
|--------------|-----------|----------------|
| On a schedule | `cron` | `cron` |
| On a GitHub / GitLab event | `git` | `git` → specific event |
| On a Slack event | `slack` | specific event: `slackTrigger` vs `slackChannelCreated` |
| On a Linear event | `linear` | `linear` → specific event |
| On a PagerDuty incident event | `pagerduty` | `pagerduty` → specific event |
| On a Sentry issue event | `sentry` | `sentry` → specific event |
| On an incoming HTTP webhook | `webhook` | `webhook` |

### Specific event (per category)

**`cron`** — Prompt: "Which schedule shape?"

| Option label | Option id | Notes |
|--------------|-----------|-------|
| Every hour | `cron_every_hour` | UI preset |
| Every day | `cron_every_day` | preset |
| Every week | `cron_every_week` | preset |
| Custom cron expression | `cron_custom` | user supplies full cron |

**`git`** — Prompt: "Which Git event?"

| Option label | Option id | Maps to |
|--------------|-----------|---------|
| Draft pull request opened | `git_draft_opened` | `DRAFT_OPENED` |
| Pull request opened | `git_pr_opened` | `OPENED` |
| Code pushed to a pull request | `git_pr_pushed` | `PUSHED` |
| Pull request merged | `git_pr_merged` | `MERGED` |
| Comment added on pull request | `git_pr_commented` | `COMMENTED` |
| Label change | `git_label` | label trigger |
| New push to branch | `git_push` | push |
| Checks completed | `git_ci` | `ciCompleted` |

**`slack`** — Prompt: "Which Slack trigger?"

| Option label | Option id | YAML |
|--------------|-----------|------|
| New message in channel | `slack_message` | `slackTrigger` |
| Channel created | `slack_channel_created` | `slackChannelCreated` |

**`linear`** — Prompt: "Which Linear event?"

| Option label | Option id | Proto JSON |
|--------------|-----------|------------|
| Issue created | `linear_created` | `linear.issueCreated` |
| Issue status changed | `linear_status` | `linear.statusChanged` |
| End of cycle | `linear_cycle` | `linear.endOfCycle` |

**`pagerduty`** — Prompt: "Which PagerDuty incident event?"

| Option label | Option id | Proto JSON |
|--------------|-----------|------------|
| Incident triggered | `pagerduty_triggered` | `incidentTriggered: {}` |
| Incident acknowledged | `pagerduty_ack` | `incidentAcknowledged: {}` |
| Incident resolved | `pagerduty_resolved` | `incidentResolved: {}` |
| Any incident event | `pagerduty_any` | `incidentAny: {}` |

Optional `serviceIds`. Proto may include `incidentEscalated` — only if user asks.

**`sentry`** — Prompt: "Which Sentry issue event?"

| Option label | Option id | Proto JSON |
|--------------|-----------|------------|
| Issue created | `sentry_created` | `issueCreated: {}` |
| Issue resolved | `sentry_resolved` | `issueResolved: {}` |
| Issue assigned | `sentry_assigned` | `issueAssigned: {}` |
| Issue archived | `sentry_archived` | `issueArchived: {}` |
| Issue unresolved | `sentry_unresolved` | `issueUnresolved: {}` |
| Any issue event | `sentry_any` | `issueAny: {}` |

Optional `projectIds`.

**`webhook`** — skip specific-event; `webhook: {}`; user gets URL/auth after save.

---
