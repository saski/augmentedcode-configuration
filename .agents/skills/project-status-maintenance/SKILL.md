---
name: project-status-maintenance
description: Maintain or create PROJECT_STATUS.md files at the repository root with the canonical structure (Executive Summary, Completed Components, In Progress, Next Steps, Known Issues, Notes). Use when starting or finishing work on a project, when the user asks to update or create PROJECT_STATUS.md, when a session involves significant changes that should be reflected in the project status file, or when reviewing project state before committing.
---

# Project Status Maintenance

Every active project repository should maintain a `PROJECT_STATUS.md` at the root level. It is a living document tracking current state, completed work, and next steps.

## When to update

Update `PROJECT_STATUS.md` after any significant change: new features, bug fixes, tests added, dependencies changed, documentation modified, project structure changes. Do not let it drift — outdated status files are worse than no file.

## Canonical template

Use this structure when creating or rewriting `PROJECT_STATUS.md`:

```markdown
# [Project Name] - Project Status

**Last Updated**: YYYY-MM-DD
**Overall Status**: [Status Emoji] **[Percentage]% Complete** - [Brief Status]

---

## Executive Summary

| Component | Status | Progress | Blocking |
|-----------|--------|----------|----------|
| Component 1 | ✅ Complete | 100% | - |
| Component 2 | 🟡 In Progress | 50% | - |
| Component 3 | ⚠️ Pending | 0% | No |

**Current Readiness**: [Status] - [Brief description]

---

## ✅ Completed Components

[List of completed work with dates and details]

---

## 🚧 In Progress

[Current work items with progress indicators]

---

## 📋 Next Steps

1. [First priority task]
2. [Second priority task]
3. [Third priority task]

---

## 🐛 Known Issues

[Any known bugs or limitations]

---

## 📝 Notes

[Additional context, decisions, or important information]
```

## Status indicators

Use consistent indicators across the file:

- **✅ Complete** — finished and tested
- **🟡 In Progress** — actively being worked on
- **⚠️ Pending** — planned but not started
- **🟢 Ready** — ready for next phase
- **🔴 Blocked** — blocked by dependencies or issues
- **❌ Cancelled** — planned but cancelled

## Update process

1. Update the **Last Updated** date.
2. Refresh the **Overall Status** percentage and brief description.
3. Move items from **In Progress** to **Completed Components** when done.
4. Update progress percentages for in-progress work.
5. Revise **Next Steps** based on current priorities.
6. Add any new issues to **Known Issues**.
7. Document significant decisions in **Notes**.

## Best practices

- **Be specific**: include dates, commit hashes, or PR numbers when relevant.
- **Be honest**: do not inflate progress percentages.
- **Be actionable**: next steps should be clear and prioritized.
- **Be concise**: keep it readable, not exhaustive.
- **Be current**: update regularly, not only at milestones.

## Anti-patterns

- Creating the file but never updating it.
- Using vague status descriptions.
- Forgetting to update the **Last Updated** date.
- Leaving stale information in the file.
- Making the file too verbose or too sparse.

## Integration with workflow

- Before starting work: review `PROJECT_STATUS.md` to understand current state.
- During work: update status as progress is made.
- Before committing: ensure `PROJECT_STATUS.md` reflects the changes in the commit.
