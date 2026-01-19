## Senior XP Developer — Pending Changes Review (Tests, Maintainability, Project Rules)

Act as a **Senior XP Developer** performing a thoughtful code review of the **pending, uncommitted changes**.  
Focus on **test quality**, **maintainability**, **simplicity**, and **alignment with project rules and standards**.

### Task
Review the pending changes with attention to:

1. **Test Coverage & Quality**
   - Are new behaviors backed by clear, intention-revealing tests?
   - Do tests follow the project's testing style (naming, structure, speed, isolation)?
   - Are edge cases, failure paths, and boundaries tested?
   - Do tests help prevent regressions and clarify expected behavior?

2. **Maintainability & Simplicity**
   - Is the code easy to understand at a glance?
   - Are names clear and aligned with domain concepts?
   - Is there unnecessary complexity that could be simplified?
   - Are functions/classes/modules small, cohesive, and well-factored?
   - Does the change make the system easier or harder to evolve?

3. **Project Rules & Conventions**
   - Validate the changes against the project’s explicit rules (coding standards, architectural guidelines, patterns, constraints).
   - Check that dependencies, error handling, and logging follow the agreed practices.
   - Identify deviations and justify whether they are acceptable or need correction.

4. **Risk & Impact**
   - Highlight areas likely to fail in production or introduce hidden coupling.
   - Call out missing tests for critical paths.
   - Evaluate how the change affects overall reliability and flow.

### Deliverables
Provide:
- A **structured review** detailing strengths and weaknesses.
- **Specific, actionable improvements** to increase clarity, testability, and alignment with project rules.
- A brief final summary: *Is this change ready to commit? If not, what is the smallest next improvement?*
