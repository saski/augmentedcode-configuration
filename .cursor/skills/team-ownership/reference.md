# Team Ownership Determination Reference

## Canonical Sources
- Features DB: `https://eventbrite.atlassian.net/wiki/spaces/PLAT/database/17302356081`
- Services DB: `https://eventbrite.atlassian.net/wiki/spaces/PLAT/database/17319362720`
- APIv3 DB: `https://eventbrite.atlassian.net/wiki/spaces/PLAT/database/17319100531`
- Teams DB: `https://eventbrite.atlassian.net/wiki/spaces/PLAT/database/17305108532`
- Triage runbook: `https://eventbrite.atlassian.net/wiki/spaces/QA/pages/15010170370/How+to+Triage+a+Bug+-+Runbook`
- Incident runbook: `https://eventbrite.atlassian.net/wiki/spaces/SRE/pages/12330959334/Reporting+a+site+issue`

## Input Contract (Normalized)

```json
{
  "issue": {
    "id": "string|null",
    "source": "jira|slack|email|zendesk|other",
    "summary": "string",
    "description": "string",
    "reporter": "string|null",
    "links": ["string"],
    "artifacts": {
      "endpoint_paths": ["string"],
      "service_names": ["string"],
      "feature_terms": ["string"],
      "error_signals": ["string"],
      "environment": "prod|stage|qa|unknown"
    }
  },
  "execution": {
    "mode": "determine_owner|determine_owner_and_route",
    "allow_incident_gate": true,
    "max_candidates": 5
  },
  "context": {
    "domain_hint": "listings|payments|core|unknown",
    "known_team": "string|null",
    "channels": {
      "help_service_catalog": "#help-service-catalog",
      "eng": "#eng",
      "feature_mapping": "#feature-mapping",
      "critical_incidents": "#critical-site-incidents-and-customer-bugs"
    }
  }
}
```

## Output Contract (Normalized)

```json
{
  "decision": {
    "status": "owner_determined|needs_confirmation|incident_path|unowned",
    "owner_team": "string|null",
    "owner_pillar": "string|null",
    "owner_theme": "string|null",
    "confidence": 0.0,
    "reasoning_summary": "string"
  },
  "classification": {
    "issue_type": "bug|incident|request|unknown",
    "incident_gate_triggered": true,
    "incident_gate_reason": "string|null"
  },
  "evidence": [
    {
      "source_type": "features_db|services_db|apiv3_db|teams_db|runbook|jira_history|other",
      "source_ref": "url-or-id",
      "matched_on": "feature|service|endpoint|team|keyword|component",
      "matched_value": "string",
      "weight": 0.0
    }
  ],
  "candidates": [
    {
      "team": "string",
      "score": 0.0,
      "why": "string"
    }
  ],
  "actions": {
    "routing_recommendation": {
      "project": "string|null",
      "team_field": "string|null",
      "component": "string|null"
    },
    "ambiguity_resolution": {
      "required": true,
      "channel": "#help-service-catalog|#eng|#feature-mapping|null",
      "message_template": "string|null"
    },
    "map_update_needed": true
  }
}
```

## Decision Statuses
- `owner_determined`: confidence is high and top candidate is coherent.
- `needs_confirmation`: medium confidence or contradictory evidence.
- `incident_path`: incident gate triggered; normal ownership flow is bypassed.
- `unowned`: no reliable owner candidate.

## Scoring Weights
- Endpoint exact match: `+0.45`
- Service exact match: `+0.35`
- Feature exact match: `+0.30`
- Component/Jira historical alignment: `+0.20`
- Domain hint alignment: `+0.10`
- Contradiction penalty (conflicting top-level owners): `-0.25`

Score normalization rule: clamp each candidate score to `[0.0, 1.0]`.

## Confidence Thresholds
- `confidence >= 0.75` -> `owner_determined`
- `0.45 <= confidence < 0.75` -> `needs_confirmation`
- `confidence < 0.45` -> `unowned`

## Channel Rules
- Ambiguity first channel: `#help-service-catalog`
- Broad fallback: `#eng`
- Mapping update and ownership-map gaps: `#feature-mapping`
- Incident route: `#critical-site-incidents-and-customer-bugs`

## Deterministic Decision Algorithm
1. Parse issue signals from summary, description, artifacts, and links.
2. Determine `issue_type` using explicit terms:
   - Incident signals: site-wide outage, severe customer impact, major degradation, severity S1/S2 language.
   - Request signals: enhancement, feature request, non-bug change request.
   - Default to `bug` when defect language is present.
3. Apply incident gate when `execution.allow_incident_gate` is `true`.
   - If triggered, set `decision.status=incident_path`, `classification.incident_gate_triggered=true`, and skip normal candidate ranking.
4. Run lookup ordering for non-incident flow:
   - Endpoint path matches first.
   - Service name matches second.
   - Feature/workflow term matches third.
   - Team enrichment for candidate metadata last.
5. Build candidate score per team by summing matched weights and subtracting contradiction penalties.
6. Clamp candidate score to `[0.0, 1.0]`.
7. Sort candidates by score desc, break ties by:
   - higher count of exact matches;
   - then lexical team name for deterministic ordering.
8. Set confidence as the top candidate score.
9. Map confidence to status thresholds:
   - `>= 0.75` => `owner_determined`
   - `0.45..0.74` => `needs_confirmation`
   - `< 0.45` => `unowned`
10. Emit output payload including evidence attribution and action policy.

## Contradictions
- A contradiction exists when high-signal evidence points to different top-level owning teams.
- Apply `-0.25` once per contradictory source pair impacting the same candidate comparison.
- Contradictions force `needs_confirmation` when confidence remains in medium band.

## Ambiguity Prompt Template

```text
Hypothesis: this belongs to <TEAM> because <TOP_EVIDENCE>.
Could you confirm/correct ownership? If incorrect, what is the right owner so we can update the ownership map?
```
