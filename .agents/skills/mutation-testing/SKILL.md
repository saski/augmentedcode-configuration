---
name: mutation-testing
description: Finds weak or missing tests by analyzing if code changes would be caught. Use when verifying test effectiveness, strengthening test suites, or validating TDD workflows.
---

STARTER_CHARACTER = 🧬🔬

# Mutation Testing

Mutation testing answers the question: **"Are my tests actually catching bugs?"**

Code coverage tells you what code your tests execute. Mutation testing tells you if your tests would **detect changes** to that code. A test suite with 100% coverage can still miss 40% of potential bugs.

---

## Core Concept

**The Mutation Testing Process:**

1. **Generate mutants**: Introduce small bugs (mutations) into production code
2. **Run tests**: Execute your test suite against each mutant
3. **Evaluate results**: If tests fail, the mutant is "killed" (good). If tests pass, the mutant "survived" (bad - your tests missed the bug)

**The Insight**: A surviving mutant represents a bug your tests wouldn't catch.

---

## When to Use

Use mutation testing analysis when:

- Reviewing code changes on a branch
- Verifying test effectiveness after TDD
- Identifying weak tests that appear to have coverage
- Finding missing edge case tests
- Validating that refactoring didn't weaken test suite

**Integration with TDD:**

```
TDD Workflow                    Mutation Testing Validation
┌─────────────────┐             ┌─────────────────────────────┐
│ RED: Write test │             │                             │
│ GREEN: Pass it  │──────────►  │ After GREEN: Verify tests   │
│ REFACTOR        │             │ would kill relevant mutants │
└─────────────────┘             └─────────────────────────────┘
```

---

## Systematic Branch Analysis Process

Follow this systematic process when analyzing code on a branch:

### Step 1: Identify Changed Code

```bash
# For JavaScript/TypeScript
git diff main...HEAD --name-only | grep -E '\.(ts|js|tsx|jsx)$' | grep -v '\.test\.'

# For Python
git diff main...HEAD --name-only | grep '\.py$' | grep -v 'test_'

# Get detailed diff for analysis
git diff main...HEAD -- src/
```

### Step 2: Generate Mental Mutants

For each changed function/method, mentally apply mutation operators (see Language-Specific Operators below).

### Step 3: Verify Test Coverage

For each potential mutant, ask:

1. **Is there a test that exercises this code path?**
2. **Would that test FAIL if this mutation were applied?**
3. **Is the assertion specific enough to catch this change?**

### Step 4: Document Findings

Categorize findings:

| Category | Description | Action Required |
|----------|-------------|-----------------|
| Killed | Test would fail if mutant applied | None - tests are effective |
| Survived | Test would pass with mutant | Add/strengthen test |
| No Coverage | No test exercises this code | Add behavior test |
| Equivalent | Mutant produces same behavior | None - not a real bug |

---

## Universal Mutation Operators

These mutation operators apply across most languages:

### Arithmetic Operators

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `a + b` | `a - b` | Addition behavior |
| `a - b` | `a + b` | Subtraction behavior |
| `a * b` | `a / b` | Multiplication behavior |
| `a / b` | `a * b` | Division behavior |
| `a % b` | `a * b` | Modulo behavior |

**Key Pattern:**

```
// ❌ WEAK TEST - Would NOT catch mutant
calculate(10, 1)  // 10 * 1 = 10, 10 / 1 = 10 (SAME!)

// ✅ STRONG TEST - Would catch mutant
calculate(10, 3)  // 10 * 3 = 30, 10 / 3 = 3.33 (DIFFERENT!)
```

### Conditional Expressions

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `a < b` | `a <= b` | Boundary value at equality |
| `a < b` | `a >= b` | Both sides of condition |
| `a <= b` | `a < b` | Boundary value at equality |
| `a > b` | `a >= b` | Boundary value at equality |
| `a >= b` | `a > b` | Boundary value at equality |

**Key Pattern:**

```
// ❌ WEAK TEST - Would NOT catch boundary mutant
isAdult(25)  // 25 >= 18 = true, 25 > 18 = true (SAME!)

// ✅ STRONG TEST - Would catch boundary mutant
isAdult(18)  // 18 >= 18 = true, 18 > 18 = false (DIFFERENT!)
```

### Equality Operators

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `a == b` | `a != b` | Both equal and not equal cases |
| `a != b` | `a == b` | Both equal and not equal cases |

### Logical Operators

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `a AND b` | `a OR b` | Case where one is true, other is false |
| `a OR b` | `a AND b` | Case where one is true, other is false |
| `NOT a` | `a` | Negation is necessary |

**Key Pattern:**

```
// ❌ WEAK TEST - Would NOT catch mutant
canAccess(true, true)  // true OR true = true AND true (SAME!)

// ✅ STRONG TEST - Would catch mutant
canAccess(true, false)  // true OR false = true, true AND false = false (DIFFERENT!)
```

### Boolean Literals

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `true` | `false` | Both true and false outcomes |
| `false` | `true` | Both true and false outcomes |

### Block Statements

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| Function body | Empty function | Side effects of the function |

**Key Pattern:**

```
// ❌ WEAK TEST - Would NOT catch mutant
processOrder(order)  // No assertions - empty function also doesn't throw!

// ✅ STRONG TEST - Would catch mutant
processOrder(order)
verifyOrderWasSaved(order)  // Verifies side effect
```

### String Literals

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `"text"` | `""` | Non-empty string behavior |
| `""` | `"XX"` | Empty string behavior |

### Collection Literals

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `[1, 2, 3]` | `[]` | Non-empty collection behavior |
| `{}` | Empty or mutated | Empty collection behavior |

---

## Language-Specific Operators

Different languages have specific mutation operators beyond the universal ones:

- **JavaScript/TypeScript**: See [languages/javascript.md](languages/javascript.md) for optional chaining (`?.`), nullish coalescing (`??`), and JS-specific methods
- **Python**: See [languages/python.md](languages/python.md) for identity operators (`is`), membership (`in`), floor division (`//`), and Python-specific patterns

---

## Mutant States and Metrics

### Mutant States

| State | Meaning | Action |
|-------|---------|--------|
| **Killed** | Test failed when mutant applied | Good - tests are effective |
| **Survived** | Tests passed with mutant active | Bad - add/strengthen test |
| **No Coverage** | No test exercises this code | Add behavior test |
| **Timeout** | Tests timed out (infinite loop) | Counted as detected |
| **Equivalent** | Mutant produces same behavior | No action - not a real bug |

### Metrics

- **Mutation Score**: `killed / valid * 100` - The higher, the better
- **Detected**: `killed + timeout`
- **Undetected**: `survived + no coverage`

### Target Mutation Score

| Score | Quality |
|-------|---------|
| < 60% | Weak test suite - significant gaps |
| 60-80% | Moderate - many improvements possible |
| 80-90% | Good - but still gaps to address |
| > 90% | Strong - but watch for equivalent mutants |

---

## Equivalent Mutants

Equivalent mutants produce the same behavior as the original code. They cannot be killed because there is no observable difference.

### Common Equivalent Mutant Patterns

**Pattern 1: Operations with identity elements**

```
// Mutant in conditional where both branches have same effect
if (whatever) {
  number += 0  // Can mutate to -= 0, *= 1, /= 1 - all equivalent!
} else {
  number += 0
}
```

**Pattern 2: Boundary conditions that don't affect outcome**

```
// When max equals min, condition doesn't matter
max = max(a, b)
min = min(a, b)
if (a >= b) {  // Mutating to <= or < has no effect when a == b
  result = 10 ** (max - min)  // 10 ** 0 = 1 regardless
}
```

**Pattern 3: Dead code paths**

```
// If this path is never reached, mutations don't matter
if (impossibleCondition) {
  doSomething()  // Mutating this won't affect behavior
}
```

### Handle Equivalent Mutants

1. **Identify**: Analyze if mutation truly changes observable behavior
2. **Document**: Note why mutant is equivalent
3. **Accept**: 100% mutation score may not be achievable
4. **Consider refactoring**: Sometimes equivalent mutants indicate unclear code

---

## Branch Analysis Checklist

When analyzing code changes on a branch:

### For Each Function/Method Changed:

- [ ] **Arithmetic operators**: Would changing +, -, *, / be detected?
- [ ] **Conditionals**: Are boundary values tested (>=, <=)?
- [ ] **Boolean logic**: Are all branches of AND, OR tested?
- [ ] **Return statements**: Would changing return value be detected?
- [ ] **Method calls**: Would removing or swapping methods be detected?
- [ ] **String literals**: Would empty strings be detected?
- [ ] **Collections**: Would empty collections be detected?

### Red Flags (Likely Surviving Mutants):

- [ ] Tests only verify "no error thrown"
- [ ] Tests only check one side of a condition
- [ ] Tests use identity values (0, 1, empty string)
- [ ] Tests only verify function was called, not with what
- [ ] Tests don't verify return values
- [ ] Boundary values not tested

### Questions to Ask:

1. "If I changed this operator, would a test fail?"
2. "If I negated this condition, would a test fail?"
3. "If I removed this line, would a test fail?"
4. "If I returned early here, would a test fail?"

---

## Strengthening Weak Tests

### Pattern: Add Boundary Value Tests

```
// Original weak test
test('validates age', () => {
  assert(isAdult(25) === true)
  assert(isAdult(10) === false)
})

// Strengthened with boundary values
test('validates age at boundary', () => {
  assert(isAdult(17) === false)  // Just below
  assert(isAdult(18) === true)   // Exactly at boundary
  assert(isAdult(19) === true)   // Just above
})
```

### Pattern: Test Both Branches of Conditions

```
// Original weak test - only tests one branch
test('returns access result', () => {
  assert(canAccess(true, true) === true)
})

// Strengthened - tests all meaningful combinations
test('grants access when admin', () => {
  assert(canAccess(true, false) === true)
})

test('grants access when owner', () => {
  assert(canAccess(false, true) === true)
})

test('denies access when neither', () => {
  assert(canAccess(false, false) === false)
})
```

### Pattern: Avoid Identity Values

```
// Weak - uses identity values
test('calculates', () => {
  assert(multiply(10, 1) === 10)  // x * 1 = x / 1
  assert(add(5, 0) === 5)         // x + 0 = x - 0
})

// Strong - uses values that reveal operator differences
test('calculates', () => {
  assert(multiply(10, 3) === 30)  // 10 * 3 != 10 / 3
  assert(add(5, 3) === 8)         // 5 + 3 != 5 - 3
})
```

### Pattern: Verify Side Effects

```
// Weak - no verification of side effects
test('processes order', () => {
  processOrder(order)
  // No assertions!
})

// Strong - verifies observable outcomes
test('processes order', () => {
  processOrder(order)
  verifyOrderSaved(order)
  verifyEmailSent(order.customerEmail)
})
```

---

## Tool Setup

Mutation testing tools automate the mutation generation and test execution:

- **Stryker (JavaScript/TypeScript)**: See [tools/stryker.md](tools/stryker.md)
- **mutmut (Python)**: See [tools/mutmut.md](tools/mutmut.md)

---

## Summary: Mutation Testing Mindset

**The key question for every line of code:**

> "If I introduced a bug here, would my tests catch it?"

**For each test, verify it would catch:**
- Arithmetic operator changes
- Boundary condition shifts
- Boolean logic inversions
- Removed statements
- Changed return values

**Remember:**
- Coverage measures execution, mutation testing measures detection
- A test that doesn't make assertions can't kill mutants
- Boundary values are critical for conditional mutations
- Avoid identity values that make operators interchangeable

---

## Quick Reference

### Operators Most Likely to Have Surviving Mutants

1. `>=` vs `>` (boundary not tested)
2. `AND` vs `OR` (only tested when both true/false)
3. `+` vs `-` (only tested with 0)
4. `*` vs `/` (only tested with 1)

### Test Values That Kill Mutants

| Avoid | Use Instead |
|-------|-------------|
| 0 (for +/-) | Non-zero values |
| 1 (for */) | Values > 1 |
| Empty collections | Collections with multiple items |
| Identical values for comparisons | Distinct values |
| All true/false for logical ops | Mixed true/false |
