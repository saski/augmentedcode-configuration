## FIC Validate Plan - Verify Implementation Completeness

Act as a **Senior XP Developer** validating that an implementation plan was correctly executed.

### Task

**Plan Path**: $ARGUMENTS

If no path provided, search recent thoughts/shared/plans/ for the latest plan.

### Validation Process

#### Step 1: Context Discovery

1. **Read the implementation plan** completely

2. **Identify what should have changed**
   - List all files that should be modified
   - Note all success criteria
   - Identify key functionality to verify

3. **Gather implementation evidence**
   ```bash
   # Check recent commits
   git log --oneline -n 20

   # Check what changed
   git diff HEAD~5..HEAD --stat

   # Run comprehensive checks
   make check test
   ```

#### Step 2: Systematic Validation

For each phase in the plan:

1. **Check completion status**
   - Look for checkmarks in plan (- [x])
   - Verify actual code matches claimed completion

2. **Run automated verification**
   - Execute each command from success criteria
   - Document pass/fail status
   - Investigate any failures

3. **Assess manual criteria**
   - List what needs manual testing
   - Provide clear steps for verification

4. **Think about edge cases**
   - Were error conditions handled?
   - Are there missing validations?
   - Could this break existing functionality?

#### Step 3: Generate Validation Report

```markdown
## Validation Report: [Plan Name]

### Implementation Status
✓ Phase 1: [Name] - Fully implemented
✓ Phase 2: [Name] - Fully implemented
⚠️ Phase 3: [Name] - Partially implemented (see issues)

### Automated Verification Results
✓ Build passes: `make build`
✓ Tests pass: `make test`
✗ Linting issues: `make lint` (3 warnings)

### Code Review Findings

#### Matches Plan:
- Database migration correctly adds [table]
- API endpoints implement specified methods
- Error handling follows plan

#### Deviations from Plan:
- Used different variable names in [file:line]
- Added extra validation in [file:line] (improvement)

#### Potential Issues:
- Missing index on foreign key
- No rollback handling in migration

### Manual Testing Required:
1. UI functionality:
   - [ ] Verify [feature] appears correctly
   - [ ] Test error states

2. Integration:
   - [ ] Confirm works with existing [component]
   - [ ] Check performance with large datasets

### Recommendations:
- Address linting warnings before merge
- Consider adding integration test for [scenario]
- Document new API endpoints
```

### Validation Checklist

Always verify:
- [ ] All phases marked complete are actually done
- [ ] Automated tests pass
- [ ] Code follows existing patterns
- [ ] No regressions introduced
- [ ] Error handling is robust
- [ ] Documentation updated if needed
- [ ] Manual test steps are clear

### Completion

```
✓ Validation complete: [Plan Name]

Status: [Summary]
- ✓ [Items that passed]
- ⚠️ [Items needing attention]

Next steps:
- Address any identified issues
- Create git commits for the changes
- Plan is ready for PR

💡 Tip: Clear context before starting next task
```

### Remember
- Be thorough but practical
- Run all automated checks
- Document everything
- Think critically about whether implementation truly solves the problem
- Consider long-term maintainability
- Good validation catches issues before production

