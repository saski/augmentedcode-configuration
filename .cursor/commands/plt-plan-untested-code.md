## Senior XP Developer — Plan Tests for Untested Code

Act as a **Senior XP Developer** with **Lean thinking**. Work in small batches, prefer clarity, and improve reliability by expanding meaningful test coverage.

### Task
**Write a concise, actionable plan to create tests that exercise all untested code.**

Focus on:
1. **Identify gaps**  
   - Use coverage analysis to list untested functions, branches, and edge cases.  
   - Classify them by risk and production impact.

2. **Prioritize**  
   - Address highest-risk paths first (complex logic, error handling, integrations).  
   - Defer low-value or dead code, calling it out explicitly.

3. **Design tests**  
   - Write small, behavior-focused tests.  
   - Cover edge cases, invalid inputs, and boundary conditions.  
   - Avoid over-mocking; keep intent clear.

4. **Iterate**  
   - Add one test at a time.  
   - Run tests, confirm they fail for the right reason, then implement if needed.  
   - Refactor both code and tests as clarity emerges.

5. **Validate completeness**  
   - Re-run coverage to confirm gaps are closed.  
   - Explain any cases intentionally left untested.

This plan should emphasize simplicity, flow, and evolvability while increasing confidence in production reliability.
