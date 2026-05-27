# Credentials and Security

For CLIs that authenticate users, hold API tokens, or otherwise handle secrets. Load this alongside the main skill when designing auth flows or secret input.

## Contents

- Never be a password manager — what not to do, what to delegate
- Secret input patterns — stdin, file, env var, interactive; never flag value
- OS keychain integration — 99designs/keyring across platforms
- Session token pattern — short-lived tokens, OAuth device flow
- Authentication subcommands — login / logout / status / refresh
- Environment variable secrets in CI — the escape hatch
- Minimum checklist

---

## Never be a password manager

A CLI is not a secrets vault. Delegating secret storage to the OS or a dedicated secret manager is always better than rolling the tool's own.

Do not:

- Store long-lived credentials in plain-text config files
- Hardcode secrets in binaries or source
- Accept passwords via command-line flag values — they leak into `ps` output, shell history, and process tree snapshots
- Log secrets anywhere, even at `--debug` level

Do:

- Integrate with the OS credential store (macOS Keychain, Windows Credential Manager, libsecret / kwallet on Linux)
- Support external credential providers (AWS credential helper, gcloud auth, GitHub CLI, 1Password CLI)
- Prefer short-lived tokens (session tokens, OAuth access tokens) over long-lived API keys
- Read secrets from stdin, files, or env vars

---

## Secret input patterns

The four acceptable input channels for a secret:

- **stdin** — `echo "$TOKEN" | mycli auth login --token-stdin`. Works with password managers, CI secret stores, and shell heredocs.
- **File path** — `mycli auth login --token-file ~/.secrets/mytoken`. The file permission model does the protection.
- **Environment variable** — `MYCLI_TOKEN=... mycli deploy`. Convenient for CI. Document that env vars are visible to sibling processes on the same host.
- **Interactive prompt** (TTY only) — use a library that reads without echo. Never prompt when stdin is not a TTY; fail with a clear error instead.

Anti-pattern — flag value:

```bash
mycli auth login --token abc123   # leaks to ps, shell history, audit logs
```

Go for interactive prompts: `golang.org/x/term` with `term.ReadPassword(int(os.Stdin.Fd()))`. Check `term.IsTerminal(int(os.Stdin.Fd()))` first — if stdin is not a terminal, fail with guidance to use `--token-stdin` or `--token-file`.

---

## OS keychain integration

Use `github.com/99designs/keyring` — a cross-platform library that targets macOS Keychain, Windows Credential Manager, Secret Service (GNOME Keyring / KWallet), pass, and several fallbacks.

Pattern:

```go
import "github.com/99designs/keyring"

func openKeyring() (keyring.Keyring, error) {
    return keyring.Open(keyring.Config{
        ServiceName: "mycli",
        // Reasonable defaults for each platform
        AllowedBackends: []keyring.BackendType{
            keyring.KeychainBackend,     // macOS
            keyring.WinCredBackend,      // Windows
            keyring.SecretServiceBackend,// Linux (GNOME/KDE)
            keyring.PassBackend,         // password-store fallback
            keyring.FileBackend,         // encrypted file last resort
        },
        FilePasswordFunc: keyring.TerminalPrompt,
    })
}

func storeToken(key, token string) error {
    kr, err := openKeyring()
    if err != nil {
        return err
    }
    return kr.Set(keyring.Item{
        Key:   key,
        Data:  []byte(token),
        Label: "mycli session token",
    })
}

func loadToken(key string) (string, error) {
    kr, err := openKeyring()
    if err != nil {
        return "", err
    }
    item, err := kr.Get(key)
    if err != nil {
        return "", err
    }
    return string(item.Data), nil
}
```

Keychain access triggers a user prompt on some platforms (macOS asks to approve). Document this so users are not surprised. Offer `--use-env` or similar escape hatches for CI environments where no keychain exists.

---

## Session token pattern

The goal: authenticate once per session, store a short-lived token, never store the long-lived credential.

Flow:

1. `mycli auth login` — prompts for credentials (or opens browser for OAuth device flow), exchanges for a short-lived token.
2. Store only the token in the OS keychain, with expiry metadata.
3. Every subsequent command reads the token, checks expiry.
4. On expired token: attempt refresh with refresh token (if OAuth), or prompt re-login with a helpful error.

```go
type SessionToken struct {
    Access    string    `json:"access_token"`
    Refresh   string    `json:"refresh_token,omitempty"`
    ExpiresAt time.Time `json:"expires_at"`
}

func currentToken() (*SessionToken, error) {
    raw, err := loadToken("session")
    if errors.Is(err, keyring.ErrKeyNotFound) {
        return nil, CLIError{
            Code:    "NOT_AUTHENTICATED",
            Message: "No active session",
            Fix:     "Run `mycli auth login`",
        }
    }
    if err != nil {
        return nil, err
    }
    var tok SessionToken
    if err := json.Unmarshal([]byte(raw), &tok); err != nil {
        return nil, err
    }
    if time.Now().After(tok.ExpiresAt) {
        refreshed, err := refresh(tok.Refresh)
        if err != nil {
            return nil, CLIError{
                Code:    "SESSION_EXPIRED",
                Message: "Session expired and refresh failed",
                Fix:     "Run `mycli auth login` again",
            }
        }
        return refreshed, nil
    }
    return &tok, nil
}
```

OAuth device flow (`RFC 8628`) is the right default for CLIs that need to authenticate against a web service. The user visits a URL, enters a code, grants access. The CLI polls the token endpoint until approval. No long-lived credentials touch the tool.

For OAuth, `golang.org/x/oauth2` has device flow support in subpackages, or use the vendor's SDK.

---

## Authentication subcommands

Standard pattern:

- `mycli auth login` — interactive login
- `mycli auth logout` — clear stored credentials
- `mycli auth status` — show active session (identity, expiry, keychain backend)
- `mycli auth refresh` — force token refresh (optional)

`auth status` is the first thing users run when something breaks. Make it informative:

```
$ mycli auth status
Authenticated as eduardo@example.com
Session expires in 42 minutes (2026-04-17 15:32 UTC)
Token stored in macOS Keychain (service: mycli)
```

On JSON output:

```json
{
  "ok": true,
  "data": {
    "authenticated": true,
    "subject": "eduardo@example.com",
    "expires_at": "2026-04-17T15:32:00Z",
    "backend": "keychain"
  }
}
```

If the user hit a 403 and ran `auth status`, they should immediately see whether their session is the problem.

---

## Environment variable secrets in CI

CI environments rarely have a keychain. The conventional escape hatch:

- The CLI reads `MYCLI_TOKEN` (or equivalent) from env if no keychain session exists.
- Env var takes precedence when explicitly set — CI users never want to be prompted for login.
- Document the env var in `--help` and in `auth` subcommand help.

Never log the env var value. Never echo it back. `mycli auth status` should show only metadata, never the token itself.

---

## Minimum checklist

- No secret accepted via flag value
- No secret stored in plain-text config
- Passwords read without echo in interactive mode, or from stdin / file / env otherwise
- Session tokens stored in OS keychain with expiry metadata
- Token refresh path when possible; clear re-login guidance otherwise
- `auth status` command shows session metadata without revealing the secret
- CI escape hatch via documented env var
- Failing a non-TTY secret prompt produces a helpful stderr error, not a hang
