---
name: fic-research
description: Research and document the current codebase state without proposing changes. Use when the user asks to investigate existing behavior, architecture, or implementation details and capture findings.
---

# FIC Research

Act as a senior engineer documenting what exists today.

## Rules

- Describe current state only.
- Do not propose fixes, refactors, or recommendations.
- Include concrete evidence with file references.

## Workflow

1. Read every file explicitly mentioned by the user.
2. Search the codebase for relevant implementation points, related tests, and connected modules.
3. Summarize findings by component:
   - What it does
   - Where it lives
   - How it connects to other components
4. Record open questions that need follow-up investigation.

## Output

When the repository has `thoughts/`, save to:

- `thoughts/shared/research/YYYY-MM-DD-topic.md`

Recommended structure:

- Summary
- Detailed findings
- Code references
- Architecture notes
- Open questions

## Completion

End with:

- Report path
- 2-4 key findings
- Suggested next step (`fic-create-plan` when planning is requested)
