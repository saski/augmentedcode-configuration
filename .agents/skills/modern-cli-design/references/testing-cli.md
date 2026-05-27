# Testing CLIs in Go

TDD patterns for verifying the CLI contract: stream separation, exit codes, pipe behavior, output stability. Load this alongside the main skill when writing or reviewing CLI tests.

Two complementary layers:

- **Subprocess integration tests** spawn the compiled binary and assert on stdout, stderr, and exit code. These prove the CLI works from the user's perspective.
- **Handler unit tests** call pure handlers with in-memory fakes. These prove the business logic is correct without touching the process layer.

Neither replaces the other.

## Contents

- Subprocess integration tests — helper, stream separation, exit codes, pipe behavior
- Testing handlers in isolation — fake filesystem (afero), fake logger, domain errors
- JSON contract tests — envelope schema guards in CI
- Help text snapshots — deterministic under NO_COLOR / TERM=dumb
- Testscript for black-box scenarios — multi-step flows
- What each layer proves

---

## Subprocess integration tests

Build the binary once per test package with `go test` helpers, then spawn it with `os/exec`. Capture both streams independently and assert on exit code.

### Test helper

```go
package cli_test

import (
    "bytes"
    "os/exec"
    "strings"
    "testing"
)

type cliResult struct {
    Stdout   string
    Stderr   string
    ExitCode int
}

func runCLI(t *testing.T, bin string, args []string, opts ...runOpt) cliResult {
    t.Helper()
    cmd := exec.Command(bin, args...)
    cmd.Env = append([]string{
        "NO_COLOR=1",
        "TERM=dumb",
        "CI=true",
    }, baseEnv()...)

    for _, o := range opts {
        o(cmd)
    }

    var stdout, stderr bytes.Buffer
    cmd.Stdout = &stdout
    cmd.Stderr = &stderr

    err := cmd.Run()
    exitCode := 0
    if err != nil {
        var ee *exec.ExitError
        if errors.As(err, &ee) {
            exitCode = ee.ExitCode()
        } else {
            t.Fatalf("failed to run CLI: %v", err)
        }
    }

    return cliResult{
        Stdout:   stdout.String(),
        Stderr:   stderr.String(),
        ExitCode: exitCode,
    }
}

type runOpt func(*exec.Cmd)

func withStdin(s string) runOpt {
    return func(c *exec.Cmd) { c.Stdin = strings.NewReader(s) }
}

func withEnv(k, v string) runOpt {
    return func(c *exec.Cmd) { c.Env = append(c.Env, k+"="+v) }
}
```

Build the binary once in `TestMain`:

```go
func TestMain(m *testing.M) {
    bin := buildBinary()
    defer os.Remove(bin)
    binaryPath = bin
    os.Exit(m.Run())
}

var binaryPath string

func buildBinary() string {
    tmp, err := os.CreateTemp("", "mycli-*")
    if err != nil {
        panic(err)
    }
    tmp.Close()
    cmd := exec.Command("go", "build", "-o", tmp.Name(), "./cmd/mycli")
    if out, err := cmd.CombinedOutput(); err != nil {
        panic(fmt.Errorf("build failed: %v\n%s", err, out))
    }
    return tmp.Name()
}
```

### Stream separation tests

Assert that `--json` produces valid JSON on stdout with zero non-JSON content, and that diagnostics go to stderr.

```go
func TestStreamSeparation(t *testing.T) {
    t.Run("json output is parseable", func(t *testing.T) {
        r := runCLI(t, binaryPath, []string{"analyze", "--json", "input.txt"})
        if r.ExitCode != 0 {
            t.Fatalf("exit=%d stderr=%s", r.ExitCode, r.Stderr)
        }
        var env map[string]any
        if err := json.Unmarshal([]byte(r.Stdout), &env); err != nil {
            t.Fatalf("stdout not valid JSON: %v\n%s", err, r.Stdout)
        }
        if env["ok"] != true {
            t.Errorf("expected ok=true, got %v", env["ok"])
        }
    })

    t.Run("diagnostics go to stderr", func(t *testing.T) {
        r := runCLI(t, binaryPath, []string{"analyze", "--json", "--verbose", "input.txt"})
        if !strings.Contains(r.Stderr, "analyzing") {
            t.Errorf("expected verbose line on stderr, got: %q", r.Stderr)
        }
        if strings.Contains(r.Stdout, "analyzing") {
            t.Errorf("verbose output leaked to stdout: %q", r.Stdout)
        }
    })

    t.Run("no spinner chars on stdout", func(t *testing.T) {
        r := runCLI(t, binaryPath, []string{"analyze", "--json", "large-input.txt"})
        spinners := "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        if strings.ContainsAny(r.Stdout, spinners) {
            t.Errorf("spinner characters leaked to stdout")
        }
    })
}
```

### Exit code tests

Table-driven, one row per documented exit code. Every non-zero exit code must have a stderr explanation.

```go
func TestExitCodes(t *testing.T) {
    cases := []struct {
        name         string
        args         []string
        env          map[string]string
        wantCode     int
        stderrMatch  string
    }{
        {
            name:     "success on valid input",
            args:     []string{"analyze", "valid.txt"},
            wantCode: 0,
        },
        {
            name:        "domain failure on low quality",
            args:        []string{"analyze", "--threshold", "95", "low.txt"},
            wantCode:    1,
            stderrMatch: "threshold",
        },
        {
            name:        "invalid usage on unknown flag",
            args:        []string{"analyze", "--no-such-flag"},
            wantCode:    2,
            stderrMatch: "unknown|unrecognized",
        },
        {
            name:        "config error on missing config",
            args:        []string{"analyze", "input.txt"},
            env:         map[string]string{"MYCLI_CONFIG": "/nonexistent"},
            wantCode:    78,
            stderrMatch: "config",
        },
    }

    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            opts := []runOpt{}
            for k, v := range tc.env {
                opts = append(opts, withEnv(k, v))
            }
            r := runCLI(t, binaryPath, tc.args, opts...)
            if r.ExitCode != tc.wantCode {
                t.Fatalf("exit=%d want=%d stderr=%s", r.ExitCode, tc.wantCode, r.Stderr)
            }
            if tc.wantCode != 0 && strings.TrimSpace(r.Stderr) == "" {
                t.Errorf("non-zero exit with empty stderr")
            }
            if tc.stderrMatch != "" {
                matched, _ := regexp.MatchString("(?i)"+tc.stderrMatch, r.Stderr)
                if !matched {
                    t.Errorf("stderr %q did not match %q", r.Stderr, tc.stderrMatch)
                }
            }
        })
    }
}
```

### Pipe behavior tests

Simulate piped output — the subprocess sees stdout as a pipe, not a TTY. Assert no ANSI codes, no spinners, no color.

```go
func TestPipedOutput(t *testing.T) {
    r := runCLI(t, binaryPath, []string{"analyze", "input.txt"})
    ansi := regexp.MustCompile(`\x1b\[[0-9;]*[a-zA-Z]`)
    if ansi.MatchString(r.Stdout) {
        t.Errorf("ANSI codes leaked into piped output")
    }
}
```

Test the `--plain` contract — stable, grep-friendly, one record per line:

```go
func TestPlainOutputGrepFriendly(t *testing.T) {
    r := runCLI(t, binaryPath, []string{"list", "--plain"})
    for i, line := range strings.Split(strings.TrimSpace(r.Stdout), "\n") {
        if line == "" {
            t.Errorf("line %d is empty", i)
        }
        if strings.Contains(line, "\t\t") {
            t.Errorf("line %d has double-tab (likely formatting artifact)", i)
        }
    }
}
```

Non-TTY prompts must not hang. Test with a finite timeout and assert a clean failure:

```go
func TestNonTTYPromptFailsCleanly(t *testing.T) {
    cmd := exec.Command(binaryPath, "init") // asks for confirmation by default
    cmd.Env = append(baseEnv(), "CI=true")
    done := make(chan error, 1)
    go func() { done <- cmd.Run() }()
    select {
    case err := <-done:
        if cmd.ProcessState.ExitCode() == 0 {
            t.Errorf("expected non-zero exit in non-TTY prompt scenario, got 0")
        }
        _ = err
    case <-time.After(3 * time.Second):
        _ = cmd.Process.Kill()
        t.Fatalf("CLI hung waiting for input in non-TTY mode")
    }
}
```

---

## Testing handlers in isolation

Handlers are pure: `func Analyze(input Input, deps Deps) (Result, error)`. No process calls, no streams, no `os.Exit`. Test them directly with in-memory fakes.

### Fake filesystem

`github.com/spf13/afero` provides an in-memory filesystem that satisfies the same interface as the real one:

```go
import "github.com/spf13/afero"

func TestAnalyzeHandler_FileNotFound(t *testing.T) {
    fs := afero.NewMemMapFs()
    logger := newFakeLogger()
    deps := Deps{FS: fs, Logger: logger}

    _, err := Analyze(Input{Path: "missing.txt"}, deps)

    var cliErr CLIError
    if !errors.As(err, &cliErr) {
        t.Fatalf("expected CLIError, got %T", err)
    }
    if cliErr.Code != "FILE_NOT_FOUND" {
        t.Errorf("got code=%q want FILE_NOT_FOUND", cliErr.Code)
    }
}
```

Accept the filesystem as a parameter in the handler; never reach for `os.ReadFile` directly inside the handler.

### Fake logger

Record calls instead of mocking. The test asserts on what was logged:

```go
type fakeLogger struct {
    entries []logEntry
}

type logEntry struct {
    Level    string
    Category string
    Message  string
}

func newFakeLogger() *fakeLogger { return &fakeLogger{} }

func (l *fakeLogger) Info(category, msg string) {
    l.entries = append(l.entries, logEntry{"info", category, msg})
}
func (l *fakeLogger) Warn(category, msg string) {
    l.entries = append(l.entries, logEntry{"warn", category, msg})
}
func (l *fakeLogger) Debug(category, msg string) {
    l.entries = append(l.entries, logEntry{"debug", category, msg})
}
```

This is a fake, not a mock — it implements the real interface fully. Tests assert on state, not on call expectations.

### Domain error assertions

Result type or `error` — consistency matters more than which pattern. If the handler returns `(Result, error)`, assert on `errors.As` + the code field. If the handler returns a `Result[T, CLIError]` discriminated union, assert on the `Err` branch.

```go
func TestThresholdNotMet(t *testing.T) {
    fs := afero.NewMemMapFs()
    _ = afero.WriteFile(fs, "low.txt", []byte("meh"), 0o644)

    _, err := Analyze(Input{Path: "low.txt", Threshold: 99}, Deps{FS: fs, Logger: newFakeLogger()})

    var cliErr CLIError
    if !errors.As(err, &cliErr) {
        t.Fatalf("want CLIError, got %T", err)
    }
    if cliErr.Code != "THRESHOLD_NOT_MET" {
        t.Errorf("code=%q want THRESHOLD_NOT_MET", cliErr.Code)
    }
    if cliErr.Transient {
        t.Errorf("threshold failure should not be transient")
    }
}
```

---

## JSON contract tests

Stdout is a public API. Contract tests run against the real binary and assert that JSON output conforms to the documented schema. Run them in CI on every PR.

```go
func TestJSONEnvelopeContract(t *testing.T) {
    t.Run("success envelope", func(t *testing.T) {
        r := runCLI(t, binaryPath, []string{"analyze", "--json", "valid.txt"})
        var env struct {
            OK   bool `json:"ok"`
            Data struct {
                Score    float64 `json:"score"`
                File     string  `json:"file"`
                Findings []struct {
                    Rule     string `json:"rule"`
                    Severity string `json:"severity"`
                    Message  string `json:"message"`
                } `json:"findings"`
            } `json:"data"`
        }
        if err := json.Unmarshal([]byte(r.Stdout), &env); err != nil {
            t.Fatalf("invalid envelope: %v", err)
        }
        if !env.OK {
            t.Error("expected ok=true")
        }
        if env.Data.File == "" {
            t.Error("missing required field data.file")
        }
    })

    t.Run("error envelope", func(t *testing.T) {
        r := runCLI(t, binaryPath, []string{"analyze", "--json", "missing.txt"})
        var env struct {
            OK    bool `json:"ok"`
            Error struct {
                Code      string `json:"code"`
                Message   string `json:"message"`
                Fix       string `json:"fix,omitempty"`
                Transient bool   `json:"transient"`
            } `json:"error"`
        }
        if err := json.Unmarshal([]byte(r.Stdout), &env); err != nil {
            t.Fatalf("invalid error envelope: %v", err)
        }
        if env.OK {
            t.Error("expected ok=false")
        }
        if !regexp.MustCompile(`^[A-Z][A-Z_]+$`).MatchString(env.Error.Code) {
            t.Errorf("code %q not UPPER_SNAKE_CASE", env.Error.Code)
        }
        if env.Error.Message == "" {
            t.Error("missing required field error.message")
        }
    })
}
```

Contract tests catch the most expensive kind of regression — silent renames that break every downstream consumer.

Schema validation with `github.com/xeipuuv/gojsonschema` or similar is worth it once the CLI has a stable external contract. For early-stage tools, manual structural assertions as above are enough.

---

## Help text snapshots

Snapshots detect unintentional changes to help output. Always run with `NO_COLOR=1` and `TERM=dumb` for deterministic output.

`github.com/bradleyjkemp/cupaloy` or the standard `golden file` pattern both work.

```go
func TestRootHelp(t *testing.T) {
    r := runCLI(t, binaryPath, []string{"--help"})
    if r.ExitCode != 0 {
        t.Fatalf("help exited non-zero: %d", r.ExitCode)
    }
    cupaloy.SnapshotT(t, r.Stdout)
}
```

Keep snapshots clean:

- Strip version numbers before snapshotting, or use `strings.Contains` assertions for the stable parts
- Strip timestamps, durations, and absolute paths
- Review snapshot diffs on every update — each diff is a potential breaking change to the help contract

Assert the examples section exists:

```go
func TestSubcommandHelpIncludesExamples(t *testing.T) {
    r := runCLI(t, binaryPath, []string{"analyze", "--help"})
    if !strings.Contains(r.Stdout, "Examples:") {
        t.Error("subcommand help missing Examples section")
    }
    if !strings.Contains(r.Stdout, "mycli analyze") {
        t.Error("help missing concrete example invocations")
    }
}
```

---

## Testscript for black-box scenarios

For multi-step scenarios (init → configure → run), `github.com/rogpeppe/go-internal/testscript` provides a scripted test format that runs the binary and asserts on output and exit codes in a single script.

```txt
# analyze-flow.txtar
exec mycli init
exec mycli config set threshold 80
exec mycli analyze input.txt
stdout 'Score:'
! stderr .

-- input.txt --
Some content
```

Useful when the scenario involves filesystem state, multiple commands, or stdin piping. For single-command assertions, plain Go tests are clearer.

---

## What each layer proves

- Subprocess tests prove the CLI respects the contract — streams, exit codes, pipes, format stability.
- Handler unit tests prove the logic is correct — domain errors, edge cases, orchestration.
- Contract tests prove the JSON schema does not regress silently.
- Snapshot tests prove help output does not regress unintentionally.

All four are cheap in Go. None replaces the others.
