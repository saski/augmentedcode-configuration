# Install Command

**Command**: `/install-command [template-name]`

Installs and customizes command templates for your specific repository. Run without arguments to see available templates.

## What This Command Does

This command helps you adapt generic command templates to your specific repository:
1. **Lists available templates** (if no template specified)
2. **Asks customization questions** about your repo
3. **Generates a customized version** with repo-specific details
4. **Saves the command** to your local `.cursor/commands/` directory
5. **Validates the installation** and confirms it's ready to use

## Usage

### List Available Templates

Run without arguments to see what's available:

```
/install-command
```

This will scan `/Users/[username]/eventbrite/cursor-prompts/templates/` and show:
- Template name
- Description
- What it does
- Prerequisites

### Install a Specific Template

```
/install-command review-pr
```

## Available Templates

The command will scan the templates directory and display available templates with their descriptions. Templates should include metadata at the top:

```markdown
<!-- 
template-name: review-pr
description: Interactive PR review workflow with AI assistance
languages: all
requires: gh CLI, git
-->
```

## Workflow Steps

### When No Template Specified (List Mode)

```
1. Scan /Users/[username]/eventbrite/cursor-prompts/templates/
2. Read each .md file
3. Extract metadata or first description
4. Display formatted list:

=== Available Command Templates ===

📝 review-pr
   Interactive PR review workflow with AI assistance
   
   Features:
   - Checkout and analyze PR changes
   - Interactive walkthrough of all files
   - Post comments via GitHub CLI
   - Track review metrics
   - Optional fix implementation
   
   Prerequisites: gh CLI, git
   Languages: All
   
   Install: /install-command review-pr

[Additional templates listed here]

===================================

Which template would you like to install? [name or 'cancel']
```

### When Template Specified (Install Mode)

#### Phase 1: Load Template
```
- Verify template exists in templates directory
- Read template content
- Extract metadata and customization points
- Display template description
```

#### Phase 2: Repository Discovery
```
Automatically detect repo configuration:
- Language(s): Check files, package manifests
- Test framework: pytest, jest, go test, cargo test, etc.
- Linting tools: ruff, eslint, golangci-lint, clippy, etc.
- Formatters: black, prettier, gofmt, rustfmt, etc.
- Build system: poetry, npm, go mod, cargo, maven, gradle, etc.
- CI/CD: .github/workflows/, .gitlab-ci.yml, etc.
- Code standards: .cursor/rules/*.mdc, CONTRIBUTING.md, etc.
```

#### Phase 3: Interactive Customization
```
Ask user for repo-specific customizations based on template variables:

Common variables:
- {{REPO_NAME}} - Auto-detected from git remote
- {{LANGUAGE}} - Auto-detected, confirm with user
- {{TEST_COMMAND}} - Auto-detected, allow override
- {{LINT_COMMAND}} - Auto-detected, allow override
- {{FORMAT_COMMAND}} - Auto-detected, allow override
- {{BUILD_COMMAND}} - Ask if not detected
- {{COVERAGE_COMMAND}} - Auto-detected, allow override
- {{PR_DOC_NAME}} - Ask user
- {{CODE_STANDARDS_DOC}} - Auto-detected, allow override
- {{COMPLEXITY_LINES}} - Ask user (default: language-specific, see below)
- {{COMPLEXITY_CYCLO}} - Ask user (default: 10)
- {{COMPLEXITY_FUNCS}} - Ask user (default: language-specific, see below)
- {{BRANCH_PREFIX}} - Ask user
- {{COMMIT_FORMAT}} - Ask user
- {{PACKAGE_MANAGER}} - Auto-detected

Template-specific variables will be prompted as needed.
```

#### Phase 4: Generate Customized Command
```
- Replace all {{VARIABLES}} with user/detected values
- Add language-specific examples
- Adjust workflow steps for detected tools
- Include repo-specific file paths
- Add detected tool commands
```

#### Phase 5: Setup Code Quality Scripts
```
If the template needs code quality checks (like review-pr):
- Create .cursor/rules/scripts/ directory if needed
- Generate language-specific simplicity checker script
- Set thresholds based on user-provided complexity settings:
  - Max lines per file (from {{COMPLEXITY_LINES}})
  - Max cyclomatic complexity (from {{COMPLEXITY_CYCLO}})
  - Max public methods/functions (from {{COMPLEXITY_FUNCS}})
- Language-specific implementations:
  - Python: AST-based checker (similar to simplicity_checker.py)
  - Kotlin: Analyze with ktlint metrics
  - TypeScript/React: ESLint complexity rules
  - Go: Use gocyclo and line counting
- Make script executable
- Add usage documentation to script header
```

#### Phase 6: Installation
```
- Create .cursor/commands/ if needed
- Save customized command file
- Save simplicity checker script (if applicable)
- Verify files were created
- Display success message with usage and next steps
```

## Repository Auto-Detection

The installer detects your repo setup by examining:

### Language Detection
```
- Python: pyproject.toml, setup.py, requirements.txt, *.py files
- JavaScript/TypeScript: package.json, tsconfig.json, *.js, *.ts files
- Go: go.mod, go.sum, *.go files
- Rust: Cargo.toml, Cargo.lock, *.rs files
- Java: pom.xml, build.gradle, *.java files
- Ruby: Gemfile, *.rb files
- etc.
```

### Test Framework Detection
```
- Python: pytest.ini, pyproject.toml[tool.pytest], conftest.py
- JavaScript: jest.config.js, vitest.config.js, package.json scripts
- Go: *_test.go files
- Rust: tests/ directory, #[test] in code
- Java: JUnit in dependencies
```

### Tool Detection
```
Scans for config files:
- .ruff.toml, ruff.toml - Ruff linter
- .eslintrc.*, eslint.config.js - ESLint
- .golangci.yml - golangci-lint
- .prettierrc - Prettier
- .black.toml, pyproject.toml[tool.black] - Black
- etc.
```

### Package Manager Detection
```
- poetry: poetry.lock, pyproject.toml
- npm: package-lock.json
- yarn: yarn.lock
- pnpm: pnpm-lock.yaml
- go mod: go.mod
- cargo: Cargo.lock
- maven: pom.xml
- gradle: build.gradle
```

## Recommended Complexity Thresholds

Based on ACTUAL production code analysis (excluding comments & blank lines):

### Python (Enforced Standard)
**Recommended Thresholds:**
- **Max lines per file: 50** (target: 40, tolerance: +10)
- **Max cyclomatic complexity: 10**
- **Max public methods: 1** (enforces Single Responsibility Principle)

**Source:** eb-ads-estimation production standards with automated simplicity checker

**Rationale:**
- ✅ Actually enforced with `simplicity_checker.py`
- ✅ Proven in production
- ✅ Team has bought in

### TypeScript/React/Next.js (Based on Actual Production Code)
**Recommended Thresholds:**
- **Max lines per file: 150** (targets 75th percentile, median: 94)
- **Max cyclomatic complexity: 12**
- **Max exports: 1** (one component/function/class per file - SRP)

**Source:** Analysis of attendee-discovery production codebase (168 .tsx files)

**Actual Production Stats:**
- Median: 94 lines
- 75th percentile: 191 lines
- 90th percentile: 352 lines
- Max: 1,629 lines (outlier)

**Rationale:**
- **Median is 94** - Most files are already smaller
- **Setting at 150** encourages breaking up larger components
- **1 export enforces SRP** - Same discipline as Python/Kotlin
- **Internal functions are OK:** Event handlers and helpers within a component don't count
- **Types can be co-located:** Type definitions for the exported item don't count as exports
- Forces thinking about composition (extract hooks, split components)
- Will catch ~25% of files for refactoring consideration

**What counts as an export:**
- ✅ `export function MyComponent()` - Counts as 1 export
- ✅ `export const useMyHook = ()` - Counts as 1 export
- ✅ `export class MyClass` - Counts as 1 export (and max 1 public method within it)
- ✅ `export default MyComponent` - Counts as 1 export
- ❌ Internal functions within a component (handleClick, formatValue, etc.)
- ❌ Type definitions for the exported item (`export type MyComponentProps`)
- ❌ Helper functions not exported

**Examples:**

**✅ GOOD - One export with internal helpers:**
```typescript
type MyComponentProps = { id: string }; // ✅ Type for export

export const MyComponent = ({ id }: MyComponentProps) => {
  const handleClick = () => { };      // ✅ Internal
  const calculateValue = () => { };   // ✅ Internal
  return <div>...</div>;
};
// Total exports: 1 ✅
```

**✅ GOOD - One export with co-located type:**
```typescript
export type MyComponentProps = { id: string }; // Types for the export don't count

export const MyComponent = ({ id }: MyComponentProps) => {
  return <div>{id}</div>;
};
// Total exports: 1 ✅ (type is supporting the export)
```

**❌ BAD - Multiple independent exports:**
```typescript
export const ComponentA = () => { }; // Export 1
export const ComponentB = () => { }; // Export 2 ❌ Violates SRP
// Split into ComponentA.tsx and ComponentB.tsx
```

**❌ BAD - Class with multiple public methods:**
```typescript
export class MyService {
  public method1() { }  // 1st public
  public method2() { }  // ❌ Violates - only 1 allowed
}
```

### Kotlin (Based on Actual Production Code)
**Recommended Thresholds:**
- **Max lines per file: 50** (target: 40, tolerance: +10; median: 36)
- **Max cyclomatic complexity: 10**
- **Max public functions: 1** (enforces SRP like Python)

**Source:** Analysis of tlz-ads-retrieval-infra production codebase

**Actual Production Stats:**
- Median: 36 lines (very close to Python!)
- 75th percentile: 63 lines
- 90th percentile: 112 lines
- Max: 448 lines (outlier)

**Rationale:**
- **Kotlin is actually as concise as Python** in practice
- Median of 36 lines shows team already writes tight code
- **1 public function enforces SRP** - same discipline as Python
- Setting at 50 (same as Python) aligns with actual practice
- Would pass ~95% of existing files
- Extension functions and companion object functions count toward limit

### Go (Conservative Suggestion)
**Suggested Thresholds:**
- **Max lines per file: 150**
- **Max cyclomatic complexity: 15**
- **Max exported functions: 6**

**Note:** ⚠️ No production Go codebase analyzed yet

**Rationale:**
- Go encourages explicit error handling
- Conservative starting point
- Adjust based on actual usage

## Line Counting Methodology

**Consistent across all languages:**
- ✅ Exclude blank lines
- ✅ Exclude single-line comments (`//`, `#`)  
- ✅ Count multi-line comments as 1 line each
- ✅ Count JSX/markup (it's code)
- ✅ Count imports/declarations

**Why this matters:**
- Python standard counts this way
- Fair comparison across languages
- Focuses on actual code complexity

## Reality Check: Production vs Standards

| Language | Median (Actual) | Max Lines | Max Public/Exports | % Would Pass | Philosophy |
|----------|----------------|-----------|-------------------|--------------|------------|
| **Python** | ~30 | 50 | 1 public method | ~95% | Enforce SRP strictly |
| **Kotlin** | 36 | 50 | 1 public function | ~95% | Enforce SRP strictly |
| **TypeScript** | 94 | 150 | 1 export | ~75% | Enforce SRP strictly |

**Universal Principle: One Thing Per File**
- **Python:** 1 public method per class
- **Kotlin:** 1 public function per file
- **TypeScript:** 1 export per file
- **All allow internal helpers** (private methods, internal functions)
- **All enforce Single Responsibility Principle**

**The Only Difference:**
- **TypeScript allows more lines (150 vs 50)** due to JSX markup
- **Same SRP discipline across all languages**

**TypeScript Examples:**

**✅ GOOD - One component per file:**
```typescript
// MyComponent.tsx
export const MyComponent = () => {
  const handleClick = () => { }      // ✅ Internal - OK
  const handleSubmit = () => { }     // ✅ Internal - OK
  const calculateValue = () => { }   // ✅ Internal - OK
  return <div>...</div>;
};
```

**✅ GOOD - One hook per file:**
```typescript
// useMyData.ts
export const useMyData = (id: string) => {
  const fetchData = async () => { }  // ✅ Internal - OK
  const transformData = () => { }    // ✅ Internal - OK
  // ... implementation
};
```

**❌ BAD - Multiple exports (violates SRP):**
```typescript
// utils.ts - ❌ BAD
export const formatDate = () => { };  // Export 1
export const parseDate = () => { };   // Export 2 ❌
export const validateDate = () => { }; // Export 3 ❌
// Should be: formatDate.ts, parseDate.ts, validateDate.ts
```

**Exception - Types for the export:**
```typescript
// MyComponent.tsx - ✅ GOOD
export type MyComponentProps = { id: string }; // Supporting type

export const MyComponent = ({ id }: MyComponentProps) => {
  return <div>{id}</div>;
};
// The type is supporting the component, so this is still "1 thing"
```

## Important: Start Where It Hurts (But Not Too Much)

**Good thresholds:**
- Catch the worst outliers (top 10-20%)
- Allow most existing code to pass
- Encourage better practices going forward
- Don't require massive refactoring

**Bad thresholds:**
- Fail 50%+ of existing code
- Require heroic effort to comply
- Fight the natural patterns of the language
- Get ignored because they're unrealistic

## Example: Listing Templates

```
User: /install-command

AI: 
=== Available Command Templates ===

Location: /Users/[username]/eventbrite/cursor-prompts/templates/

📝 review-pr
   Interactive AI-assisted PR review workflow
   
   Description:
   Provides a comprehensive code review experience with GitHub CLI
   integration. Walks through all changes, allows inline comments,
   tracks review metrics, and can implement fixes directly.
   
   Features:
   - Checkout and analyze PR branches
   - Interactive file-by-file walkthrough
   - Post comments and questions via gh CLI
   - Request or implement fixes
   - Track review time and metrics
   - Optional sub-PR creation for fixes
   
   Prerequisites:
   - GitHub CLI (gh) installed and authenticated
   - Git configured
   
   Languages: All
   
   Install with: /install-command review-pr

===================================

Which template would you like to install? Type template name or 'cancel':
```

## Example: Installing review-pr

```
User: /install-command review-pr

AI: 
Installing template: review-pr
Location: /Users/[username]/eventbrite/cursor-prompts/templates/review-pr.md

✓ Template loaded

=== Repository Analysis ===

Analyzing your repository...

Detected configuration:
✓ Repository: my-app
✓ Primary language: Python
✓ Test framework: pytest
✓ Linter: ruff
✓ Formatter: black
✓ Coverage tool: pytest-cov
✓ Package manager: poetry
✓ Code standards: .cursor/rules/code-standards.mdc

=== Customization Questions ===

I'll ask you a few questions to customize this command for your repo.

1. What filename do you use for PR descriptions?
   Common options:
   - PR_REVIEW_DOC.md
   - PULL_REQUEST_TEMPLATE.md
   - .github/pull_request_template.md
   
   Your answer [default: PR_REVIEW_DOC.md]: 

User: PULL_REQUEST_TEMPLATE.md

AI: ✓ Using PULL_REQUEST_TEMPLATE.md

2. Test command?
   Auto-detected: poetry run pytest
   Press Enter to accept or type custom command: 

User: [Enter]

AI: ✓ Using: poetry run pytest

3. Complexity thresholds for code review:
   
   Recommended for Python (based on eb-ads-estimation standards):
   - Max lines: 50 (target: 40, tolerance: +10)
   - Max cyclomatic complexity: 10
   - Max public methods: 1 (Single Responsibility Principle)
   
   Max lines per file [default: 50]: 

User: [Enter]

AI: ✓ Using default: 50 lines (Python standard)

   Max cyclomatic complexity [default: 10]: 

User: [Enter]

AI: ✓ Using default: 10

   Max public methods per file [default: 1]: 

User: [Enter]

AI: ✓ Using default: 1 (enforces SRP)

4. Branch naming convention?
   Examples: feature/, fix/, chore/, bugfix/
   
   Your answer: 

User: feature/

AI: ✓ Using feature/* convention

5. Commit message format?
   Common formats:
   - conventional (feat:, fix:, chore:, etc.)
   - default (free form)
   - custom
   
   Your answer [default: conventional]: 

User: [Enter]

AI: ✓ Using conventional commits format

=== Generating Customized Command ===

Customizing template with your settings...

✓ Replaced {{REPO_NAME}} with my-app
✓ Replaced {{LANGUAGE}} with Python
✓ Replaced {{TEST_COMMAND}} with poetry run pytest
✓ Replaced {{LINT_COMMAND}} with poetry run ruff check --fix
✓ Replaced {{FORMAT_COMMAND}} with poetry run black
✓ Replaced {{COVERAGE_COMMAND}} with poetry run pytest --cov
✓ Replaced {{PR_DOC_NAME}} with PULL_REQUEST_TEMPLATE.md
✓ Replaced {{CODE_STANDARDS_DOC}} with .cursor/rules/code-standards.mdc
✓ Replaced {{COMPLEXITY_LINES}} with 50
✓ Replaced {{COMPLEXITY_CYCLO}} with 10
✓ Replaced {{COMPLEXITY_FUNCS}} with 1
✓ Replaced {{BRANCH_PREFIX}} with feature/
✓ Replaced {{COMMIT_FORMAT}} with conventional
✓ Replaced {{PACKAGE_MANAGER}} with poetry

Added Python-specific examples
Added pytest commands
Configured complexity checks (Python standards: 50 lines, 1 method, complexity ≤10)

=== Setting Up Code Quality Scripts ===

Generating Python simplicity checker...

✓ Created .cursor/rules/scripts/ directory
✓ Generated simplicity_checker.py with your thresholds:
  - Max lines: 50 (target: 40, tolerance: +10)
  - Max cyclomatic complexity: 10
  - Max public methods: 1
✓ Made script executable
✓ Added usage documentation

Usage: python .cursor/rules/scripts/simplicity_checker.py <file_path>

=== Installing Command ===

Creating .cursor/commands/ directory...
Saving to: .cursor/commands/review-pr.md

✓ Command installed successfully!
✓ Simplicity checker installed successfully!

=== Ready to Use ===

Your customized /review-pr command is now available!

Command: /review-pr [PR-number]

Configured for my-app:
- Language: Python
- Tests: poetry run pytest
- Linting: poetry run ruff
- PR doc: PULL_REQUEST_TEMPLATE.md
- Code standards: .cursor/rules/code-standards.mdc
- Complexity: ≤50 lines (target: 40), ≤10 cyclomatic, 1 public method
- Branches: feature/* convention
- Commits: conventional format

Code Quality Tools Installed:
- Simplicity checker: .cursor/rules/scripts/simplicity_checker.py
  Usage: python .cursor/rules/scripts/simplicity_checker.py <file_path>

Try it now: /review-pr 123

Or check a file's complexity: 
python .cursor/rules/scripts/simplicity_checker.py path/to/file.py
```

## Template Requirements

For templates to be discoverable and installable, they should:

### 1. Include Metadata (Optional but Recommended)
```markdown
<!-- 
template-name: my-command
description: Brief one-line description
languages: python,javascript,all
requires: gh CLI, git, docker
version: 1.0.0
-->
```

### 2. Use Standard Variables
```markdown
Replace hardcoded values with {{VARIABLES}}:

- Command examples: {{TEST_COMMAND}}, {{LINT_COMMAND}}
- File paths: {{CODE_STANDARDS_DOC}}, {{PR_DOC_NAME}}
- Thresholds: {{COMPLEXITY_LINES}}, {{COMPLEXITY_CYCLO}}
- Conventions: {{BRANCH_PREFIX}}, {{COMMIT_FORMAT}}
- Tools: {{PACKAGE_MANAGER}}, {{LANGUAGE}}
```

### 3. Document Customization Points
Include a section explaining what will be customized:

```markdown
## Customization Variables

This template uses the following variables:
- {{REPO_NAME}} - Your repository name
- {{TEST_COMMAND}} - Command to run tests
... etc
```

## Managing Installed Commands

### List installed commands
```bash
ls -la .cursor/commands/
```

### Update a command
Re-run installation to update:
```
/install-command review-pr
```

### Remove a command
```bash
rm .cursor/commands/review-pr.md
```

### Share with team
Commit `.cursor/commands/` to share customized commands:
```bash
git add .cursor/commands/
git commit -m "Add customized cursor commands"
```

## Troubleshooting

### Template not found
```
Error: Template 'xyz' not found

Solution: Run /install-command without arguments to see available templates
```

### Auto-detection failed
```
Warning: Could not detect [tool/language]

Solution: You'll be prompted to enter values manually
```

### Variable not replaced
```
Warning: {{XYZ}} was not replaced

Solution: 
1. Check if the variable is supported
2. The template may need updating
3. Edit .cursor/commands/[command].md manually to fix
```

### Command not available after install
```
Error: /command not recognized after installation

Solution:
1. Verify file exists: ls .cursor/commands/
2. Check filename matches command name
3. Restart Cursor or reload window
4. Ensure markdown formatting is valid
```

## Prerequisites

- Access to `/Users/[username]/eventbrite/cursor-prompts/templates/`
- Git repository initialized
- Write access to `.cursor/commands/` directory

## Notes

- Templates are org-wide and maintained centrally
- Installed commands are repo-specific
- You can customize after installation by editing the file
- Re-run installation to update with new template versions
- Share your `.cursor/commands/` directory with your team

## For Template Authors

When creating new templates:

1. **Save to templates directory**: `/Users/[username]/eventbrite/cursor-prompts/templates/`
2. **Add metadata**: Include template-name, description, requirements
3. **Use variables**: Replace specific values with {{VARIABLES}}
4. **Document variables**: List all customizable variables
5. **Test installation**: Try installing in different repo types
6. **Add examples**: Show how the command works
7. **Update this list**: Add your template to the available templates section

