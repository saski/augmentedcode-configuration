# mutmut - Mutation Testing for Python

mutmut is an automated mutation testing framework for Python projects.

## Installation

```bash
pip install mutmut
```

## Configuration

mutmut can be configured via `pyproject.toml`, `setup.cfg`, or command-line arguments.

### pyproject.toml

```toml
[tool.mutmut]
paths_to_mutate = "src/"
backup = false
runner = "pytest -x"
tests_dir = "tests/"
dict_synonyms = "Struct, NamedStruct"
```

### setup.cfg

```ini
[mutmut]
paths_to_mutate=src/
backup=False
runner=pytest -x
tests_dir=tests/
dict_synonyms=Struct, NamedStruct
```

### Configuration Options

**paths_to_mutate**: Directory or file to mutate
- Example: `"src/"` or `"src/mymodule.py"`

**backup**: Whether to backup original files
- `false` (recommended) - uses git, no backup files created
- `true` - creates `.bak` files

**runner**: Command to run tests
- `"pytest -x"` - stops on first failure (faster)
- `"pytest"` - runs all tests
- `"python -m pytest tests/"` - explicit path

**tests_dir**: Location of test files
- Used to exclude test files from mutation

**dict_synonyms**: Custom dict-like types to mutate

## Running mutmut

### Full Mutation Testing

```bash
mutmut run
```

Runs mutation testing on all configured paths.

### Specific Paths

```bash
mutmut run --paths-to-mutate=src/utils.py
```

Only mutates specified file.

### Parallel Execution

```bash
mutmut run --use-coverage --threads=4
```

Uses coverage to skip irrelevant tests and runs in parallel.

## Workflow

### 1. Run Mutation Testing

```bash
mutmut run
```

Output:
```
- Killed mutants: 85
- Survived mutants: 12
- Suspicious mutants: 1
- Timeout mutants: 2
```

### 2. Check Results

```bash
mutmut results
```

Shows summary of all mutants.

### 3. View Survived Mutants

```bash
mutmut show survived
```

Lists IDs of survived mutants.

### 4. View Specific Mutant

```bash
mutmut show 5
```

Shows the exact mutation:

```diff
- if age >= 18:
+ if age > 18:
```

### 5. Apply Mutant (for testing)

```bash
mutmut apply 5
```

Applies the mutation to your code so you can run tests manually.

### 6. Verify and Reset

```bash
# Test the mutation manually
pytest

# Reset to original code
git checkout -- src/
```

### 7. Fix Tests and Re-run

After improving tests:

```bash
mutmut run
```

## Branch Workflow

For analyzing code changes on a branch:

```bash
# 1. Get changed Python files
git diff main...HEAD --name-only | grep '\.py$' | grep -v 'test_' > changed_files.txt

# 2. Run mutmut on each changed file
while read file; do
  echo "Mutating $file..."
  mutmut run --paths-to-mutate="$file"
done < changed_files.txt

# 3. Check results
mutmut results
```

Or create a temporary config:

```bash
# Extract changed files
CHANGED=$(git diff main...HEAD --name-only | grep '\.py$' | grep -v 'test_' | tr '\n' ',' | sed 's/,$//')

# Run with specific paths
mutmut run --paths-to-mutate="$CHANGED"
```

## Using Coverage for Speed

```bash
# 1. Generate coverage data
pytest --cov=src --cov-report=

# 2. Run mutmut with coverage
mutmut run --use-coverage
```

This skips tests that don't execute the mutated code, significantly speeding up the process.

## Reading Results

### Result States

**Killed**: Tests failed with this mutation (good)
- Your tests caught this potential bug

**Survived**: Tests passed with this mutation (bad)
- Your tests would miss this bug
- **Action required**: Add or strengthen tests

**Suspicious**: Mutant exited with different error
- Often indicates test infrastructure issues
- Review these manually

**Timeout**: Tests took too long
- Counted as killed
- Usually indicates infinite loop mutation

**Skipped**: Mutation was skipped
- Often for equivalent mutants

### HTML Report

```bash
mutmut html
```

Generates HTML report in `html/` directory.

```bash
# Open in browser
open html/index.html
```

Features:
- File-by-file breakdown
- Source code with mutations highlighted
- Filter by status

## Example Complete Workflow

```bash
# 1. Ensure tests pass
pytest

# 2. Run mutation testing
mutmut run --use-coverage

# 3. View summary
mutmut results

# 4. Investigate survived mutants
mutmut show survived

# 5. Look at specific mutant
mutmut show 7
# Output:
# --- src/calculator.py
# +++ src/calculator.py
# @@ -5,7 +5,7 @@
#  def multiply(a, b):
# -    return a * b
# +    return a / b

# 6. Write test to kill this mutant
# In test_calculator.py:
def test_multiply():
    assert multiply(10, 3) == 30  # Would fail if * became /

# 7. Re-run to verify
mutmut run --use-coverage

# 8. Generate report
mutmut html
open html/index.html
```

## Integration with CI/CD

### GitHub Actions

```yaml
name: Mutation Testing

on:
  pull_request:
    branches: [main]

jobs:
  mutation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install mutmut pytest

      - name: Run mutation testing
        run: |
          mutmut run --use-coverage

      - name: Check results
        run: |
          mutmut results
          # Fail if survival rate too high
          SURVIVED=$(mutmut results | grep "Survived" | awk '{print $3}')
          if [ "$SURVIVED" -gt 5 ]; then
            echo "Too many survived mutants: $SURVIVED"
            exit 1
          fi

      - name: Generate HTML report
        if: always()
        run: mutmut html

      - name: Upload report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: mutation-report
          path: html/
```

## Advanced Features

### Custom Mutators

Create `.mutmut_config.py`:

```python
def pre_mutation(context):
    """Called before each mutation"""
    if 'test_' in context.filename:
        # Skip test files
        context.skip = True

def post_mutation(context):
    """Called after each mutation"""
    pass
```

### Caching Results

mutmut stores results in `.mutmut-cache`. This enables:

1. Incremental runs (only test new/changed mutants)
2. Fast re-runs
3. Persistent results across sessions

```bash
# Clear cache to start fresh
rm -rf .mutmut-cache
mutmut run
```

## Performance Tips

### 1. Use Coverage

```bash
mutmut run --use-coverage
```

Dramatically reduces test execution time.

### 2. Run in Parallel

```bash
mutmut run --threads=4
```

Uses multiple CPU cores.

### 3. Stop on First Failure

In config:

```toml
[tool.mutmut]
runner = "pytest -x"  # -x stops on first failure
```

### 4. Limit Paths

```bash
mutmut run --paths-to-mutate=src/critical_module.py
```

Focus on critical code first.

### 5. Exclude Files

In `pyproject.toml`:

```toml
[tool.mutmut]
paths_to_exclude = "src/generated/, src/migrations/"
```

## Common Issues

### "Tests failed without mutation"

Your test suite is failing. Fix tests before running mutmut.

```bash
pytest  # Should pass before mutation testing
```

### "Suspicious mutant"

Usually test infrastructure issues:

```bash
mutmut show <id>
mutmut apply <id>
pytest -v  # See actual error
git checkout -- .
```

### High survival rate

Tests are weak. Focus on survived mutants:

```bash
mutmut show survived
```

Add tests to kill these mutants.

### Slow execution

Use coverage and parallel execution:

```bash
pytest --cov=src --cov-report=
mutmut run --use-coverage --threads=4
```

## Ignoring Code

Use pragma comments to skip mutation:

```python
def debug_only():  # pragma: no mutate
    print("Debug info")

# or
x = 42  # noqa: mutmut
```

## References

- GitHub: https://github.com/boxed/mutmut
- PyPI: https://pypi.org/project/mutmut/
- Documentation: https://mutmut.readthedocs.io/
