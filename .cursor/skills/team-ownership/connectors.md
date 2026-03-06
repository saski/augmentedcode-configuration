# Atlassian Connector Playbook

This document defines a reproducible lookup sequence using the available Atlassian MCP tools.

## Required Tool Inputs
- `search`: `{ "query": "<text>" }`
- `searchConfluenceUsingCql`: `{ "cloudId": "<id-or-url>", "cql": "<query>" }`
- `fetch`: `{ "id": "<ari>" }`
- `getConfluencePage`: `{ "cloudId": "<id-or-url>", "pageId": "<page-id>", "contentFormat": "markdown" }`

## Lookup Sequence
1. **Broad discovery with search**
   - Query for candidate matches across issue summary, endpoints, service names, and feature terms.
   - Collect ARIs and page references for ownership map content and runbooks.
2. **Targeted narrowing with CQL**
   - Use `searchConfluenceUsingCql` for deterministic filtering by title, labels, and space.
   - Prefer ownership DB pages and runbook pages first.
3. **Content retrieval**
   - Use `fetch` for ARI-based resources returned by search.
   - Use `getConfluencePage` for explicit page IDs and markdown extraction.
4. **Evidence normalization**
   - Convert each matched signal to an evidence object.
   - Store the exact matched field/value and scoring weight.
5. **Ranking feed**
   - Pass normalized evidence to candidate scoring logic in `reference.md`.

## Database Entity Fallback Strategy
Confluence database entities may not always be retrievable as regular pages.

When an ownership DB URL does not resolve as page content:
1. Use `search` with row-like keywords (service name, endpoint, feature phrase).
2. Use `searchConfluenceUsingCql` constrained by the relevant space and title patterns.
3. If only metadata is available, keep provenance in `source_ref` and mark `matched_on=keyword` when needed.
4. Continue with available evidence and downgrade confidence when direct row-level evidence is missing.
5. Set `actions.map_update_needed=true` when ownership appears stale or absent.

## Evidence Attribution Format
Each retrieved signal must be emitted as:

```json
{
  "source_type": "features_db|services_db|apiv3_db|teams_db|runbook|jira_history|other",
  "source_ref": "url-or-id",
  "matched_on": "feature|service|endpoint|team|keyword|component",
  "matched_value": "string",
  "weight": 0.0
}
```

## Source Priority
1. APIv3 endpoint matches
2. Service ownership matches
3. Feature ownership matches
4. Team enrichment records
5. Runbooks and historical Jira cues
