# Python Specific Mutation Operators

This document covers mutation operators specific to Python beyond the universal operators covered in SKILL.md.

## Python-Specific Arithmetic Operators

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `a // b` | `a / b` | Integer division behavior |
| `a / b` | `a // b` | Float division behavior |
| `a ** b` | `a * b` | Exponentiation behavior |

**Example Analysis:**

```python
# Production code
def calculate_pages(total_items: int, per_page: int) -> int:
    return total_items // per_page

# Mutant: total_items / per_page (returns float instead of int)
# Question: Would tests fail if // became /?

# ❌ WEAK TEST - Would NOT catch mutant (in some cases)
def test_calculates_pages():
    assert calculate_pages(10, 5) == 2  # 10 // 5 = 2, 10 / 5 = 2.0 (type different but value same)

# ✅ STRONG TEST - Would catch mutant
def test_calculates_pages_with_remainder():
    assert calculate_pages(10, 3) == 3  # 10 // 3 = 3, 10 / 3 = 3.33 (DIFFERENT!)
    assert isinstance(calculate_pages(10, 3), int)  # Verifies type
```

## Identity Operators

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `a is b` | `a is not b` | Identity check (especially for None) |
| `a is not b` | `a is b` | Identity check |
| `a is None` | `a == None` | Identity vs equality for None |

**Example Analysis:**

```python
# Production code
def process(value):
    if value is None:
        return "default"
    return value

# Mutant: if value == None

# ✅ STRONG TEST - Should verify is vs ==
def test_process_with_none():
    assert process(None) == "default"

def test_process_with_empty_string():
    # This catches the difference: "" is not None, but "" == None would fail differently
    assert process("") == ""

# Note: is and == behave differently with custom __eq__ implementations
class AlwaysEqual:
    def __eq__(self, other): return True

def test_process_with_custom_equality():
    obj = AlwaysEqual()
    # obj == None is True (due to __eq__)
    # obj is None is False (identity check)
    result = process(obj)
    assert result == obj  # Should return obj, not "default"
```

## Membership Operators

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `a in b` | `a not in b` | Membership testing |
| `a not in b` | `a in b` | Membership testing |

**Example Analysis:**

```python
# Production code
def has_permission(user: User, permission: str) -> bool:
    return permission in user.permissions

# Mutant: permission not in user.permissions

# ❌ WEAK TEST - Would NOT catch mutant
def test_has_permission_when_present():
    user = User(permissions=["read", "write"])
    assert has_permission(user, "read") is True  # Both in and not in give different results

# ✅ STRONG TEST - Would catch mutant
def test_has_permission_when_present():
    user = User(permissions=["read", "write"])
    assert has_permission(user, "read") is True

def test_has_permission_when_absent():
    user = User(permissions=["read"])
    assert has_permission(user, "write") is False  # Would be True if mutated
```

## Assignment Operator Mutations

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `a += b` | `a -= b` | Addition assignment |
| `a -= b` | `a += b` | Subtraction assignment |
| `a *= b` | `a /= b` | Multiplication assignment |
| `a /= b` | `a *= b` | Division assignment |

**Example Analysis:**

```python
# Production code
def accumulate_score(current: int, points: int) -> int:
    current += points
    return current

# Mutant: current -= points

# ✅ STRONG TEST - Would catch mutant
def test_accumulate_score():
    assert accumulate_score(10, 5) == 15  # 10 + 5 = 15, 10 - 5 = 5 (DIFFERENT!)
```

## Control Flow Mutations

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `break` | `continue` | Loop termination behavior |
| `continue` | `break` | Loop iteration behavior |

**Example Analysis:**

```python
# Production code
def find_first_negative(numbers: list[int]) -> int | None:
    for num in numbers:
        if num < 0:
            return num
    return None

# If using break instead of return:
def collect_until_negative(numbers: list[int]) -> list[int]:
    result = []
    for num in numbers:
        if num < 0:
            break
        result.append(num)
    return result

# Mutant: continue instead of break

# ✅ STRONG TEST - Would catch mutant
def test_collect_until_negative():
    assert collect_until_negative([1, 2, -3, 4]) == [1, 2]  # Stops at -3
    # If continue: [1, 2, 4] (DIFFERENT!)
```

## Python-Specific Method Mutations

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `.startswith()` | `.endswith()` | Correct string position |
| `.endswith()` | `.startswith()` | Correct string position |
| `.upper()` | `.lower()` | Case transformation |
| `.lower()` | `.upper()` | Case transformation |
| `.strip()` | `.lstrip()` | Correct trim behavior |
| `.strip()` | `.rstrip()` | Correct trim behavior |
| `.append()` | (removed) | List modification matters |
| `.extend()` | `.append()` | Correct list operation |
| `any()` | `all()` | Partial vs full match |
| `all()` | `any()` | Full vs partial match |
| `min()` | `max()` | Correct extremum |
| `max()` | `min()` | Correct extremum |
| `.get()` | `[]` (indexing) | Dictionary key handling |

**Example Analysis - any() vs all():**

```python
# Production code
def has_valid_email(users: list[User]) -> bool:
    return any(user.email for user in users)

# Mutant: all(user.email for user in users)

# ❌ WEAK TEST - Would NOT catch mutant
def test_has_valid_email_all_present():
    users = [User(email="a@b.com"), User(email="c@d.com")]
    assert has_valid_email(users) is True  # any = True, all = True (SAME!)

# ✅ STRONG TEST - Would catch mutant
def test_has_valid_email_one_present():
    users = [User(email="a@b.com"), User(email=None)]
    assert has_valid_email(users) is True  # any = True, all = False (DIFFERENT!)
```

**Example Analysis - dict.get() vs []:**

```python
# Production code
def get_config(key: str, default=None):
    config = {"timeout": 30}
    return config.get(key, default)

# Mutant: config[key] (raises KeyError for missing keys)

# ❌ WEAK TEST - Doesn't test missing key case
def test_get_config():
    assert get_config("timeout") == 30

# ✅ STRONG TEST - Tests both paths
def test_get_config_existing_key():
    assert get_config("timeout") == 30

def test_get_config_missing_key():
    assert get_config("missing", "default") == "default"  # Would raise KeyError if mutated
```

## List/Dict/Set Mutations

| Original | Mutated | Test Should Verify |
|----------|---------|-------------------|
| `[1, 2, 3]` | `[]` | Non-empty list behavior |
| `{}` (dict) | `{None: None}` | Empty dict behavior |
| `{1, 2, 3}` | `set()` | Non-empty set behavior |

**Example Analysis:**

```python
# Production code
def get_default_tags() -> list[str]:
    return ["python", "testing"]

# Mutant: return []

# ❌ WEAK TEST - Would NOT catch mutant
def test_returns_list():
    result = get_default_tags()
    assert isinstance(result, list)  # Empty list is still a list!

# ✅ STRONG TEST - Would catch mutant
def test_returns_default_tags():
    assert get_default_tags() == ["python", "testing"]
```

## List Comprehensions and Generator Expressions

List comprehensions are particularly important in Python:

```python
# Production code
def get_even_squares(numbers: list[int]) -> list[int]:
    return [n ** 2 for n in numbers if n % 2 == 0]

# Possible mutants:
# - n ** 2 → n * 2
# - n % 2 == 0 → n % 2 != 0
# - [... for n in numbers] → [] (empty list)

# ✅ STRONG TEST - Would catch all mutants
def test_get_even_squares():
    result = get_even_squares([1, 2, 3, 4, 5])
    assert result == [4, 16]  # 2**2=4, 4**2=16
    # Would fail if:
    # - n*2 was used: [4, 8]
    # - % != was used: [1, 9, 25]
    # - [] returned: []
```

## Exception Handling

```python
# Production code
def divide(a: float, b: float) -> float:
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

# Mutant: if b != 0 (inverts condition)

# ❌ WEAK TEST - Only tests happy path
def test_divide():
    assert divide(10, 2) == 5

# ✅ STRONG TEST - Tests both paths
def test_divide_normal():
    assert divide(10, 2) == 5

def test_divide_by_zero_raises():
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)
```

## Decorator Mutations

```python
# Production code
@cache
def expensive_calculation(n: int) -> int:
    return n ** 2

# Mutant: Removes @cache decorator

# ✅ Test should verify caching behavior
def test_caching_works(mocker):
    spy = mocker.spy(expensive_calculation, '__wrapped__')

    expensive_calculation(5)
    expensive_calculation(5)  # Should use cache

    assert spy.call_count == 1  # Only called once due to cache
```

## Python-Specific Patterns to Test

### Pattern 1: None vs Empty Collections

```python
# Weak - doesn't distinguish None from empty
def test_get_users():
    users = get_users()
    assert users is not None

# Strong - tests specific behavior
def test_get_users_returns_empty_list():
    assert get_users() == []

def test_get_users_never_returns_none():
    result = get_users()
    assert result is not None
    assert isinstance(result, list)
```

### Pattern 2: Type Checking

```python
# Production code
def process_value(value: int | str) -> str:
    if isinstance(value, int):
        return str(value)
    return value.upper()

# Mutant: if isinstance(value, str)

# ✅ STRONG TEST - Tests both branches
def test_process_int():
    assert process_value(42) == "42"

def test_process_string():
    assert process_value("hello") == "HELLO"
```

### Pattern 3: Slice Mutations

```python
# Production code
def get_first_three(items: list) -> list:
    return items[:3]

# Mutant: items[3:] or items[:2] or items[1:3]

# ✅ STRONG TEST
def test_get_first_three():
    assert get_first_three([1, 2, 3, 4, 5]) == [1, 2, 3]
    assert get_first_three([1, 2]) == [1, 2]  # Tests edge case
```

## Python-Specific Red Flags

- Tests don't distinguish `is None` from `== None`
- Tests don't verify `in` vs `not in` for both cases
- Tests use identity values for `//`, `%`, `**`
- Tests don't verify exception handling paths
- List comprehension tests only check length, not contents
- Tests don't verify `any()` vs `all()` differences
- Dictionary tests only check existing keys, not missing ones
- Tests don't verify empty vs None for collections
- Tests don't check both branches of type checking
