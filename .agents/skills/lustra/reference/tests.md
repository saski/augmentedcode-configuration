# tests

**Purpose:** prove the code is actually tested — not that test files merely exist.

## Detect

1. Identify the runner from the manifest (jest/vitest/mocha/pytest/go test/cargo test).
   Run it. If it cannot run, report that as the top finding — untestable is worse than failing.
2. Coverage **on the change**, not globally: diff against the merge base and check which
   added/changed lines have no covering test. Global % hides slop.
3. Read the test files in the target for fake assurance — the AI-slop signature:
   - Assertions that cannot fail (`expect(true).toBe(true)`, snapshot of a mock).
   - Tests that exercise the mock, not the unit.
   - `skip`/`only`/`xit` left in, empty test bodies, `assert(result)` with no expectation.
   - One happy path, zero error/edge cases.

## Triage

Rank: failing tests > changed code with no coverage > fake/empty tests > thin coverage of
critical paths. A green suite full of fake assertions is a **red** finding, stated plainly.

## Fix policy

- Auto: nothing. Tests are semantic.
- Present an itemized checklist: each proposed new test case (target file, the behavior
  it asserts, error/edge path covered) and each fake/skipped test to remove with its
  reason. Apply only approved items; Confirmation flow per SKILL.md.

## Report

```
Tests — <target>

Suite: pass|fail|cannot-run   <counts or the blocking reason>

Uncovered changed lines
  <file:line> — <what is untested>

Fake/skipped
  <file:line> — <evidence>

Proposed additions (ranked by risk)
  <target> — <behavior to assert>
```
