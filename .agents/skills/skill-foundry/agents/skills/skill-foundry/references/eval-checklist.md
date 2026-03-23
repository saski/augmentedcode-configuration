# Eval checklist

Use this checklist when evaluating a skill.

## Coverage
- Does the test set cover common use cases?
- Does it include edge cases?
- Does it include negative prompts where the skill should not activate?

## Output quality
- Does the output follow the requested structure?
- Does it follow formatting constraints?
- Does it keep the expected tone and level of detail?
- Does it avoid hallucinating requirements not present in the input?

## Reliability
- Does the skill behave consistently across multiple prompts in the same category?
- Does performance degrade for longer or more complex inputs?
- Are failure modes visible and diagnosable?

## Comparison
- Is the skill better than baseline?
- Is the new version better than the previous version?
- Is any gain large enough to justify keeping the skill?

## Triggering
- Does the skill activate when it should?
- Does it stay quiet when it should not be used?
