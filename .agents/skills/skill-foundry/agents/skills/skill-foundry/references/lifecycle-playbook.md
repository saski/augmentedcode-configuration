# Skill lifecycle playbook

Use this lifecycle for every shared skill.

## 1. Create
Create a skill only when the workflow is repeated, costly, or benefits from domain-specific instructions.

## 2. Evaluate
Test the skill across multiple prompts, including edge cases and negative activation cases.

## 3. Benchmark
Compare the skill against baseline behavior and, when relevant, compare the current version against the proposed version.

## 4. Optimize description
Improve the description so the skill activates for in-scope tasks and stays inactive for out-of-scope prompts.

## 5. Publish
Add the skill to the catalog with category, pattern, owner, lifecycle state, and review metadata.

## 6. Re-benchmark after model updates
Model improvements can make old skills obsolete or harmful.

## 7. Retire or downgrade
Use `monitor`, `deprecated`, or `retired` when the skill no longer beats baseline or overlaps heavily with stronger skills.
