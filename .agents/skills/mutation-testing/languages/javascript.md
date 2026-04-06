# JavaScript/TypeScript Specific Mutation Operators

This document covers mutation operators specific to JavaScript and TypeScript beyond the universal operators covered in SKILL.md.

## Optional Chaining Mutations

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `foo?.bar` | `foo.bar` | Null/undefined handling |
| `foo?.[i]` | `foo[i]` | Null/undefined handling |
| `foo?.()` | `foo()` | Null/undefined handling |

**Example Analysis:**

```typescript
// Production code
const getUserName = (user?: User): string => {
  return user?.name ?? "Anonymous";
};

// Mutant: user.name (removes optional chaining)
// Question: Would tests fail if ?. became . ?

// ❌ WEAK TEST - Would NOT catch mutant
it('returns name for valid user', () => {
  expect(getUserName({ name: "Alice" })).toBe("Alice");
});

// ✅ STRONG TEST - Would catch mutant
it('returns Anonymous for null user', () => {
  expect(getUserName(null)).toBe("Anonymous");  // Would crash without ?.
});
```

## Nullish Coalescing Mutations

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `a ?? b` | `a && b` | Nullish coalescing behavior |
| `a ?? b` | `a \|\| b` | Difference between nullish and falsy |

**Example Analysis:**

```typescript
// Production code
const getPort = (port?: number): number => {
  return port ?? 3000;
};

// Mutant: port || 3000
// Question: Would tests fail if ?? became || ?

// ❌ WEAK TEST - Would NOT catch mutant
it('returns provided port', () => {
  expect(getPort(8080)).toBe(8080);  // Works for both ?? and ||
});

// ✅ STRONG TEST - Would catch mutant
it('returns default for 0', () => {
  expect(getPort(0)).toBe(0);  // 0 ?? 3000 = 0, but 0 || 3000 = 3000 (DIFFERENT!)
});
```

## Method Expression Mutations

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `startsWith()` | `endsWith()` | Correct string position |
| `endsWith()` | `startsWith()` | Correct string position |
| `toUpperCase()` | `toLowerCase()` | Case transformation |
| `toLowerCase()` | `toUpperCase()` | Case transformation |
| `some()` | `every()` | Partial vs full match |
| `every()` | `some()` | Full vs partial match |
| `filter()` | (removed) | Filtering is necessary |
| `reverse()` | (removed) | Order matters |
| `sort()` | (removed) | Ordering is necessary |
| `min()` | `max()` | Correct extremum |
| `max()` | `min()` | Correct extremum |
| `trim()` | `trimStart()` | Correct trim behavior |

**Example Analysis - Array methods:**

```typescript
// Production code
const hasActiveUser = (users: User[]): boolean => {
  return users.some(u => u.isActive);
};

// Mutant: users.every(u => u.isActive)
// Question: Would tests fail if some became every?

// ❌ WEAK TEST - Would NOT catch mutant
it('returns true when all active', () => {
  const users = [{ isActive: true }, { isActive: true }];
  expect(hasActiveUser(users)).toBe(true);  // some = true, every = true (SAME!)
});

// ✅ STRONG TEST - Would catch mutant
it('returns true when one active', () => {
  const users = [{ isActive: true }, { isActive: false }];
  expect(hasActiveUser(users)).toBe(true);  // some = true, every = false (DIFFERENT!)
});
```

**Example Analysis - String methods:**

```typescript
// Production code
const isImageFile = (filename: string): boolean => {
  return filename.toLowerCase().endsWith('.png');
};

// Possible mutants:
// - toLowerCase() → toUpperCase()
// - endsWith() → startsWith()

// ❌ WEAK TEST - Would NOT catch case mutant
it('validates image file', () => {
  expect(isImageFile('photo.PNG')).toBe(true);  // Relies on toLowerCase
});

// ✅ STRONG TEST - Would catch both mutants
it('validates lowercase extension', () => {
  expect(isImageFile('photo.png')).toBe(true);   // Catches toLowerCase mutant
});

it('validates extension at end', () => {
  expect(isImageFile('png.photo.png')).toBe(true); // Catches endsWith mutant
  expect(isImageFile('.png-photo')).toBe(false);    // Would fail if startsWith
});
```

## Unary Operator Mutations

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `+a` | `-a` | Sign matters |
| `-a` | `+a` | Sign matters |
| `++a` | `--a` | Increment vs decrement |
| `a++` | `a--` | Increment vs decrement |

**Example Analysis:**

```typescript
// Production code
const getBalance = (amount: number): number => {
  return -amount;  // Negative balance
};

// Mutant: +amount
// Question: Would tests fail if - became +?

// ❌ WEAK TEST - Would NOT catch mutant
it('returns balance for 0', () => {
  expect(getBalance(0)).toBe(0);  // -0 = +0 (SAME!)
});

// ✅ STRONG TEST - Would catch mutant
it('returns negative balance', () => {
  expect(getBalance(100)).toBe(-100);  // -100 != +100 (DIFFERENT!)
});
```

## Array Declaration Mutations

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `[1, 2, 3]` | `[]` | Non-empty array behavior |
| `new Array(1, 2)` | `new Array()` | Array contents matter |

**Example Analysis:**

```typescript
// Production code
const getDefaultCategories = (): string[] => {
  return ["tech", "design", "business"];
};

// Mutant: return []
// Question: Would tests fail if array was empty?

// ❌ WEAK TEST - Would NOT catch mutant
it('returns array', () => {
  const result = getDefaultCategories();
  expect(Array.isArray(result)).toBe(true);  // Empty array is still an array!
});

// ✅ STRONG TEST - Would catch mutant
it('returns default categories', () => {
  expect(getDefaultCategories()).toEqual(["tech", "design", "business"]);
});
```

## TypeScript-Specific Patterns

### Type Assertions and Non-null Assertions

```typescript
// Production code
const getName = (user: User | null): string => {
  return user!.name;  // Non-null assertion
};

// Mutant: user.name (removes !)
// Note: In runtime, both are same - ! is compile-time only
// But the assertion indicates intention

// ✅ Test should verify null is never passed
it('throws when user is null', () => {
  expect(() => getName(null)).toThrow();
});
```

### Enum Mutations

```typescript
enum Status {
  Active = "ACTIVE",
  Inactive = "INACTIVE"
}

const isActive = (status: Status): boolean => {
  return status === Status.Active;
};

// Mutant: status === Status.Inactive

// ✅ STRONG TEST - Tests both values
it('returns true for Active', () => {
  expect(isActive(Status.Active)).toBe(true);
});

it('returns false for Inactive', () => {
  expect(isActive(Status.Inactive)).toBe(false);
});
```

## Common Weak Test Patterns in JavaScript/TypeScript

### Pattern 1: Not testing falsy vs nullish

```typescript
// Weak
it('uses default', () => {
  expect(getValue(undefined)).toBe("default");
});

// Strong - tests all falsy values
it('uses default for null/undefined only', () => {
  expect(getValue(null)).toBe("default");
  expect(getValue(undefined)).toBe("default");
  expect(getValue(0)).toBe(0);          // Not nullish
  expect(getValue("")).toBe("");        // Not nullish
  expect(getValue(false)).toBe(false);  // Not nullish
});
```

### Pattern 2: Not testing array method logic

```typescript
// Weak
it('filters items', () => {
  expect(filter([1, 2, 3], x => x > 0).length).toBeGreaterThan(0);
});

// Strong
it('filters items correctly', () => {
  expect(filter([1, -2, 3, -4], x => x > 0)).toEqual([1, 3]);
});
```

### Pattern 3: Not testing method chaining

```typescript
// Weak
it('processes names', () => {
  expect(processName("  ALICE  ")).toBe("Alice");
});

// Strong - tests each transformation
it('trims whitespace', () => {
  expect(processName("  Alice  ")).toBe("Alice");
});

it('capitalizes first letter', () => {
  expect(processName("alice")).toBe("Alice");
});

it('lowercases rest', () => {
  expect(processName("ALICE")).toBe("Alice");
});
```

## JavaScript/TypeScript Specific Red Flags

- Tests don't verify optional chaining with null/undefined
- Tests use only truthy/falsy without testing actual null/undefined
- Tests don't distinguish between `??` and `||`
- Tests use `0`, `""`, `false` when verifying defaults (makes `??` and `||` equivalent)
- Array tests only check length, not contents
- String tests don't verify case transformations
- Tests don't verify correct array method (some vs every, filter vs map)
