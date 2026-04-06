# Stryker - Mutation Testing for JavaScript/TypeScript

Stryker is an automated mutation testing framework for JavaScript and TypeScript projects.

## Installation

```bash
npm init stryker
```

This interactive command will:
- Install Stryker and necessary plugins
- Detect your test runner (Jest, Mocha, etc.)
- Generate a configuration file

### Manual Installation

```bash
npm install --save-dev @stryker-mutator/core

# For Jest
npm install --save-dev @stryker-mutator/jest-runner

# For Mocha
npm install --save-dev @stryker-mutator/mocha-runner
```

## Configuration

Create `stryker.conf.json` in your project root:

```json
{
  "$schema": "./node_modules/@stryker-mutator/core/schema/stryker-schema.json",
  "testRunner": "jest",
  "coverageAnalysis": "perTest",
  "mutate": [
    "src/**/*.ts",
    "src/**/*.js",
    "!src/**/*.test.ts",
    "!src/**/*.spec.js"
  ],
  "reporters": ["html", "clear-text", "progress"],
  "maxConcurrentTestRunners": 4,
  "timeoutMS": 60000
}
```

### Configuration Options

**testRunner**: Test framework to use
- `"jest"` - Jest test runner
- `"mocha"` - Mocha test runner
- `"karma"` - Karma test runner

**coverageAnalysis**: How Stryker analyzes test coverage
- `"perTest"` - Most accurate, runs each test individually (recommended)
- `"all"` - Faster, runs all tests for each mutant
- `"off"` - Fastest, no coverage analysis

**mutate**: Glob patterns for files to mutate
- Include: `"src/**/*.ts"`
- Exclude: `"!src/**/*.test.ts"`

**reporters**: Output formats
- `"html"` - HTML report in `reports/mutation/html/`
- `"clear-text"` - Console output
- `"progress"` - Progress bar
- `"json"` - JSON report

**maxConcurrentTestRunners**: Number of parallel test processes
- Default: number of CPU cores - 1
- Lower for memory-constrained environments

**timeoutMS**: Maximum time per mutant test (milliseconds)
- Default: 60000 (1 minute)
- Increase for slow test suites

## Running Stryker

### Full Mutation Testing

```bash
npx stryker run
```

Runs mutation testing on all configured files.

### Incremental Mode

```bash
npx stryker run --incremental
```

Only tests changes since last run. Stores results in `.stryker-tmp/incremental.json`.

### Specific Files

```bash
npx stryker run --mutate "src/utils/*.ts"
```

Only mutates specified files.

### With Different Config

```bash
npx stryker run --configFile stryker-branch.conf.json
```

## Branch Workflow

For analyzing code changes on a branch:

```bash
# 1. Get changed files
CHANGED_FILES=$(git diff main...HEAD --name-only | grep -E '\.(ts|js)$' | grep -v '\.test\.' | tr '\n' ',')

# 2. Run Stryker only on changed files
npx stryker run --mutate "$CHANGED_FILES"
```

Or create a branch-specific config:

```json
{
  "extends": "./stryker.conf.json",
  "mutate": [
    "src/feature-x/**/*.ts"
  ]
}
```

```bash
npx stryker run --configFile stryker-branch.conf.json
```

## Reading Results

### Console Output

```
✅ Killed: Test suite caught this mutation
✔️  Survived: Test suite missed this mutation (BAD)
⌛ Timeout: Tests timed out (counted as detected)
🙈 No coverage: No test exercises this code
🤷‍♂️ Equivalent: Mutation doesn't change behavior
```

### HTML Report

Open `reports/mutation/html/index.html` in a browser.

Features:
- Mutation score per file
- Color-coded source code (red = survived, green = killed)
- Click mutations to see details
- Filter by status (survived, killed, etc.)

### Understanding Output

```
Mutation score: 85.5%
  Killed: 123
  Survived: 21
  No coverage: 0
  Timeout: 1
```

**Mutation score**: `(killed + timeout) / (total - equivalent) * 100`

**Focus on**: Survived mutants - these represent bugs your tests would miss.

## Example Workflow

```bash
# 1. Run mutation testing
npx stryker run

# 2. Open HTML report
open reports/mutation/html/index.html

# 3. Find survived mutants
#    - Look for red-highlighted code in report
#    - These are mutations that tests didn't catch

# 4. Write or strengthen tests to kill survived mutants

# 5. Re-run to verify
npx stryker run --incremental
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
      - uses: actions/setup-node@v3
        with:
          node-version: '18'

      - run: npm ci
      - run: npx stryker run --incremental

      - name: Upload report
        uses: actions/upload-artifact@v3
        with:
          name: mutation-report
          path: reports/mutation/html/
```

### Enforcing Mutation Score

In `stryker.conf.json`:

```json
{
  "thresholds": {
    "high": 90,
    "low": 80,
    "break": 70
  }
}
```

- **high**: Mutation score considered excellent
- **low**: Warning threshold
- **break**: Exit with error if below this (fails CI)

## Performance Tips

### 1. Use Coverage Analysis

```json
{
  "coverageAnalysis": "perTest"
}
```

Skips tests that don't cover the mutated code.

### 2. Ignore Large Files

```json
{
  "mutate": [
    "src/**/*.ts",
    "!src/generated/**",
    "!src/vendor/**"
  ]
}
```

### 3. Adjust Concurrency

```json
{
  "maxConcurrentTestRunners": 2
}
```

Lower for memory issues, higher for faster machines.

### 4. Ignore Specific Mutators

```json
{
  "mutator": {
    "excludedMutations": [
      "StringLiteral",
      "BlockStatement"
    ]
  }
}
```

Useful for excluding noisy mutants.

### 5. Use Incremental Mode

```bash
npx stryker run --incremental
```

Only tests changed mutants.

## Common Issues

### "Tests failed without mutant"

Your test suite is flaky or failing. Fix tests before running mutation testing.

### "Timeout"

Increase `timeoutMS` in config:

```json
{
  "timeoutMS": 120000
}
```

### High memory usage

Lower `maxConcurrentTestRunners`:

```json
{
  "maxConcurrentTestRunners": 2
}
```

### Too many equivalent mutants

Configure mutator to exclude:

```json
{
  "mutator": {
    "excludedMutations": ["StringLiteral"]
  }
}
```

## References

- Official docs: https://stryker-mutator.io/
- Mutators: https://stryker-mutator.io/docs/mutation-testing-elements/supported-mutators/
- Configuration: https://stryker-mutator.io/docs/stryker-js/configuration/
