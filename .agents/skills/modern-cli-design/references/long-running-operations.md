# Long-Running Operations

For CLIs that run for minutes to hours, stream large datasets, process many items in parallel, or manage persistent state. Load this alongside the main skill when designing such tools.

The core principles in `SKILL.md` still apply — stream contract, exit codes, error envelope, composability. This file adds concurrency, signal handling, crash-only design, and state management.

## Contents

- Concurrency and chunking — worker pools, parallelism, progress on stderr
- Rsync-style resume — checkpointing, idempotency, retry with backoff
- Responsive remote operations — context timeouts, rate limits
- Signal handling — SIGINT (130), SIGTERM (143), SIGPIPE (141)
- Crash-only design — atomic writes, stale lock recovery, idempotency
- State management — when stateless breaks down, embedded SQLite
- Startup performance — under 500ms, first output under 100ms

---

## Concurrency and chunking

Sequential processing of thousands of items is rarely acceptable when the work parallelizes. Split the work into independent units, process them concurrently, show progress on stderr, emit results on stdout.

Pattern for a worker pool in Go:

```go
type Job struct {
    ID   string
    Data []byte
}

type Result struct {
    JobID string
    OK    bool
    Err   error
}

func process(ctx context.Context, jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        select {
        case <-ctx.Done():
            return
        default:
        }
        r := doWork(ctx, job)
        results <- r
    }
}

func runPool(ctx context.Context, jobs []Job, workers int) []Result {
    jobCh := make(chan Job)
    resCh := make(chan Result, len(jobs))

    var wg sync.WaitGroup
    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            process(ctx, jobCh, resCh)
        }()
    }

    go func() {
        defer close(jobCh)
        for _, j := range jobs {
            select {
            case jobCh <- j:
            case <-ctx.Done():
                return
            }
        }
    }()

    go func() { wg.Wait(); close(resCh) }()

    var out []Result
    for r := range resCh {
        out = append(out, r)
    }
    return out
}
```

Defaults worth using: worker count matches `runtime.NumCPU()` for CPU-bound work; for I/O-bound work, 2-4x that is typical. Expose `--concurrency N` as a flag so users can tune.

Progress goes to stderr, never stdout. A progress line every 5-10 seconds is enough; faster than that is just noise. Libraries like `github.com/schollz/progressbar/v3` write to stderr by default.

When emitting results, prefer NDJSON for streaming. Emit one line per completed job. A final summary record (`type: "summary"`) closes the stream with totals.

---

## Rsync-style resume

Operations that last minutes to hours will get interrupted. Design so that re-running the same command resumes where it left off rather than starting from zero.

Requirements:

- **Checkpoint progress to disk.** After each completed unit, record it. SQLite or a newline-delimited log file works well; the choice depends on how much concurrent write contention is expected.
- **Check for prior state on startup.** If a checkpoint exists, skip already-completed units.
- **Retry with exponential backoff.** Transient failures deserve 3-5 retries with backoff (e.g., 1s, 2s, 4s, 8s) before being marked failed.
- **Idempotent operations.** Re-running a completed unit must be safe and produce the same result.
- **Atomic checkpoint writes.** Write to a temp file in the same directory, then rename. A crashed process must never leave a half-written checkpoint.

Pattern:

```go
type Checkpoint struct {
    path string
    done map[string]bool
    mu   sync.Mutex
}

func loadCheckpoint(path string) (*Checkpoint, error) {
    cp := &Checkpoint{path: path, done: map[string]bool{}}
    f, err := os.Open(path)
    if errors.Is(err, os.ErrNotExist) {
        return cp, nil
    }
    if err != nil {
        return nil, err
    }
    defer f.Close()
    sc := bufio.NewScanner(f)
    for sc.Scan() {
        cp.done[sc.Text()] = true
    }
    return cp, sc.Err()
}

func (c *Checkpoint) Mark(id string) error {
    c.mu.Lock()
    defer c.mu.Unlock()
    if c.done[id] {
        return nil
    }
    c.done[id] = true
    f, err := os.OpenFile(c.path, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o644)
    if err != nil {
        return err
    }
    defer f.Close()
    _, err = fmt.Fprintln(f, id)
    return err
}

func (c *Checkpoint) Done(id string) bool {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.done[id]
}
```

Anti-pattern: starting from zero after a 2-hour run failed at 90%. The user will never trust the tool again.

Tell the user on startup if a prior checkpoint was found: `Resuming — 4,823/5,000 items already complete`. Silent resume confuses users who think they started fresh.

---

## Responsive remote operations

When calling remote APIs or services that may be slow:

- Use context timeouts on every remote call. Never let a single slow request hang the whole CLI.
- Configure the timeout via flag: `--timeout 30s`.
- Print `waiting for response...` on stderr after ~2 seconds of silence. The user needs to know the tool is alive.
- On timeout, produce a clear error: which endpoint, how long it waited, what the user can do. Set `transient: true` on the error and exit 75.

```go
ctx, cancel := context.WithTimeout(ctx, timeout)
defer cancel()
req = req.WithContext(ctx)

resp, err := client.Do(req)
if err != nil {
    if errors.Is(err, context.DeadlineExceeded) {
        return CLIError{
            Code:      "API_TIMEOUT",
            Message:   fmt.Sprintf("No response from %s after %s", req.URL, timeout),
            Fix:       "Increase --timeout or check network connectivity",
            Transient: true,
        }
    }
    return err
}
```

Respect rate limits. When the remote returns 429, read the `Retry-After` header and back off. Print a stderr note the first time it happens so the user understands the slowdown.

---

## Signal handling

Users send signals. Docker sends SIGTERM. Pipes close. Handle all three correctly.

### SIGINT (Ctrl-C) — exit 130

Acknowledge immediately on stderr so the user knows the signal was received. Start cleanup with a bounded timeout. If a second Ctrl-C arrives, force-exit.

```go
func installSignalHandler(cancel context.CancelFunc, cleanup func() error) {
    sigCh := make(chan os.Signal, 1)
    signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

    go func() {
        sig := <-sigCh
        fmt.Fprintln(os.Stderr, "\nShutting down...")
        cancel()

        done := make(chan struct{})
        go func() {
            _ = cleanup()
            close(done)
        }()

        select {
        case <-done:
        case <-time.After(5 * time.Second):
            fmt.Fprintln(os.Stderr, "Cleanup timed out. Exiting.")
        case <-sigCh:
            fmt.Fprintln(os.Stderr, "Force quit. Cleanup skipped.")
        }

        switch sig {
        case syscall.SIGINT:
            os.Exit(130)
        case syscall.SIGTERM:
            os.Exit(143)
        }
    }()
}
```

Cleanup should be best-effort. Anything critical must already be persisted (see crash-only design below) — the cleanup handler is an optimization, not a guarantee.

### SIGTERM — exit 143

Sent by process managers, container runtimes, and `docker stop`. Same cleanup as SIGINT. If cleanup does not finish in time, the orchestrator sends SIGKILL (which cannot be caught). Exit code 143 signals graceful shutdown to Kubernetes and Docker.

### SIGPIPE — exit 141

The pipe consumer exited early:

```bash
mycli run | head -5
```

`head` reads 5 lines and closes the pipe. The next write from the CLI triggers SIGPIPE. The correct response is to exit silently and immediately — the user got what they asked for.

Go's default behavior: the runtime ignores SIGPIPE for non-stdout/stderr pipes, but writes to a closed stdout return an `EPIPE` error wrapped in `*os.PathError`. Handle it:

```go
_, err := os.Stdout.Write(data)
if err != nil {
    if errors.Is(err, syscall.EPIPE) {
        os.Exit(141)
    }
    // other errors: fall through to normal error path
}
```

Never treat EPIPE as an application error. Exit 1 on SIGPIPE will confuse downstream scripts that rely on correct exit codes.

---

## Crash-only design

Cleanup handlers may not run. SIGKILL, power loss, OOM kill, and kernel panic all bypass them. Design so the tool recovers on the next startup.

### Atomic file writes

Write to a temp file in the same directory (same filesystem = atomic rename) and rename on success:

```go
func atomicWrite(path string, data []byte) error {
    dir := filepath.Dir(path)
    f, err := os.CreateTemp(dir, ".tmp-*")
    if err != nil {
        return err
    }
    tmpPath := f.Name()
    defer func() {
        if tmpPath != "" {
            _ = os.Remove(tmpPath)
        }
    }()

    if _, err := f.Write(data); err != nil {
        f.Close()
        return err
    }
    if err := f.Sync(); err != nil {
        f.Close()
        return err
    }
    if err := f.Close(); err != nil {
        return err
    }
    if err := os.Rename(tmpPath, path); err != nil {
        return err
    }
    tmpPath = "" // skip deferred cleanup
    return nil
}
```

The file on disk is always either the previous complete version or the new complete version — never a partial write.

### Stale lock file recovery

If the tool uses a lock file to prevent concurrent runs, check whether the recorded PID is still alive. If not, the previous process crashed — remove the stale lock and continue.

```go
func acquireLock(path string) error {
    existing, err := os.ReadFile(path)
    if err == nil {
        pid, _ := strconv.Atoi(strings.TrimSpace(string(existing)))
        if pid > 0 && processAlive(pid) {
            return CLIError{
                Code:    "LOCKED",
                Message: fmt.Sprintf("Another instance is running (PID %d)", pid),
                Fix:     "Wait for it to finish, or kill it if stuck",
            }
        }
        fmt.Fprintf(os.Stderr, "Removing stale lock (PID %d not running)\n", pid)
        _ = os.Remove(path)
    } else if !errors.Is(err, os.ErrNotExist) {
        return err
    }

    return atomicWrite(path, []byte(strconv.Itoa(os.Getpid())))
}

func processAlive(pid int) bool {
    p, err := os.FindProcess(pid)
    if err != nil {
        return false
    }
    return p.Signal(syscall.Signal(0)) == nil
}
```

Anti-pattern: failing with `Another instance is running` when the previous instance was killed two days ago.

### Idempotency

Each operation must be safe to run twice. Re-running a completed migration step checks state and skips. Re-running a completed API call detects the resource already exists and treats it as success (or uses `If-None-Match` / idempotency keys).

The user's recovery path should be: hit up-arrow, hit enter.

---

## State management

Prefer stateless. CLIs that maintain no persistent state are easier to reason about, easier to test, and trivial to recover from failure.

When state is genuinely needed — resume checkpoints, cached lookups, local queues — use embedded SQLite. It is transactional, crash-safe, single-file, and needs no server.

Persist to the system of record (the remote API, the shared database) as soon as possible. Local state exists to survive crashes, not as the source of truth. Document where state files live, and provide a `--reset` or `state clear` subcommand for users who want to start over.

Clean up completed state on successful completion. Stale checkpoint files piling up in `~/.cache/mycli/` are a symptom of a tool that does not own its lifecycle.

Go: `modernc.org/sqlite` (pure Go, no CGo) or `github.com/mattn/go-sqlite3` (CGo, faster). The former simplifies cross-compilation significantly and is the better default for a CLI.

---

## Startup performance

Long-running does not mean slow to start. Startup under 500ms and first output under 100ms are both achievable in Go and matter for user perception. Avoid heavy initialization (network calls, large database opens) before the first output. Defer expensive setup until the command actually needs it.

Cobra's default behavior is fast. Watch out for init-time DNS lookups or config loading that blocks on a slow filesystem.
