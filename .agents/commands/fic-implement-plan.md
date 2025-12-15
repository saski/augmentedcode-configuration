## FIC Implement Plan - Execute Plans Phase by Phase

Act as a **Senior XP Developer** implementing an approved technical plan from `thoughts/shared/plans/`.

### Task

**Plan Path**: $ARGUMENTS

If no path provided, ask: "Which plan should I implement? (e.g., thoughts/shared/plans/2025-01-08-feature.md)"

### Implementation Process

#### Step 1: Read and Understand

1. **Read the plan completely**
   - Check for existing checkmarks (- [x])
   - Understand all phases and success criteria

2. **Read referenced files**
   - Original ticket if mentioned
   - Research documents
   - All files mentioned in the plan

3. **Create todo list** to track progress

#### Step 2: Implement Phase by Phase

For each phase:

1. **Implement the changes**
   - Follow the plan's specifications
   - Adapt to what you find (plans are guides, not scripts)
   - If something doesn't match, STOP and communicate:
     ```
     Issue in Phase [N]:
     Expected: [what plan says]
     Found: [actual situation]
     Why this matters: [explanation]

     How should I proceed?
     ```

2. **Run automated verification**
   - Execute all success criteria commands
   - Fix any issues before proceeding

3. **Update progress**
   - Check off completed items in the plan
   - Update todo list

4. **Pause for manual verification (only if plan has manual criteria)**
   - If no manual verification in plan → Continue to next phase
   - If manual verification exists:
     ```
     Phase [N] Complete - Ready for Manual Verification

     Automated verification passed:
     - [List checks that passed]

     Please perform manual verification:
     - [List manual items from plan]

     Let me know when complete so I can proceed.
     ```

#### Step 3: Handle Mismatches

When things don't match the plan:
- Think about WHY
- The plan captures intent, but reality can differ
- Communicate clearly before deviating
- Document deviations in the plan

#### Step 4: Resume Partial Work

If plan has existing checkmarks:
- Trust that completed work is done
- Pick up from first unchecked item
- Verify previous work only if something seems off

### Context Management

**Critical**: Implementation can fill context quickly.

- Implement ONE phase at a time
- After each phase, consider: "Is context getting large?"
- If yes, complete current phase, save progress, suggest clearing
- Reference the plan file after clearing

### Completion

When all phases are complete:

1. **Run final verification**
   ```bash
   make check test  # Or project-specific command
   ```

2. **Update plan file**
   - Ensure all checkboxes marked
   - Note any deviations

3. **Report completion**
   ```
   ✓ Implementation complete: [Plan Name]

   All phases implemented and verified:
   - [Key accomplishments]

   Next steps:
   - Use `/fic-validate-plan` to verify completeness
   - Use `/commit` to create git commits
   - Consider clearing context before validation

   💡 Tip: Clear context now before validation
   ```

### Remember
- You're implementing a solution, not just checking boxes
- Keep the end goal in mind
- Maintain forward momentum
- The plan is your guide, but your judgment matters
- One phase at a time
- Clear context between phases if needed

