# Routing Policy Mapping

## Routing Output Contract
Populate:
- `actions.routing_recommendation.project`
- `actions.routing_recommendation.team_field`
- `actions.routing_recommendation.component`

When confidence is insufficient, keep these fields nullable and require ambiguity resolution.

## Team Recommendation Rules
1. If `decision.status=incident_path`:
   - Route operational escalation to `#critical-site-incidents-and-customer-bugs`.
   - Keep Jira routing fields nullable until incident commander or owning on-call confirms.
2. If top candidate confidence is high (`owner_determined`):
   - Set `team_field` to top candidate team.
   - Set `component` when component evidence is present.
   - Set `project` when historical routing or ownership map provides project mapping.
3. If medium confidence (`needs_confirmation`):
   - Preserve top candidate as hypothesis in summary.
   - Require `ambiguity_resolution.required=true`.
   - Use `#help-service-catalog` first, then `#eng` fallback.
4. If low confidence (`unowned`):
   - Keep routing recommendation nullable.
   - Require confirmation via `#eng` or `#feature-mapping`.

## Incident Escalation Path
Incident route is separate from ownership lookup and takes precedence.

Trigger path when issue indicates site-wide or severe customer impact:
- Set `decision.status=incident_path`
- Set `classification.issue_type=incident`
- Set `classification.incident_gate_triggered=true`
- Set `actions.ambiguity_resolution.required=false`
- Recommend escalation channel `#critical-site-incidents-and-customer-bugs`

## Map Update Policy
Set `actions.map_update_needed=true` when:
- no owner can be determined;
- evidence indicates stale or contradictory ownership entries;
- endpoint/service/feature used in the issue is missing in ownership sources.
