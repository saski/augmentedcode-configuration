---
name: bun-toolkit
description: JS/TS/JSX toolkit with Bun awareness. Use when using Bun as a runtime, test runner, or package manager in JavaScript and TypeScript projects.
---

# Bun Toolkit

Bun is a fast, all-in-one JavaScript runtime and toolkit.

## Core Features

- **Runtime**: Fast JS/TS runtime, drop-in replacement for Node.js.
- **Package Manager**: `bun install` is significantly faster than `npm` or `yarn`.
- **Test Runner**: `bun test` provides a fast, Jest-compatible testing environment.
- **Bundler**: `bun build` for bundling JS/TS for the web or other runtimes.

## Common Commands

```bash
bun init                        # Start a new project
bun install                     # Install dependencies
bun add <package>               # Add a package
bun run <script>                # Run a package.json script
bun <file.ts>                   # Run a TS/JS file directly
bun test                        # Run tests
bun build ./index.ts --outdir ./build # Build for production
```

## Awareness & Best Practices

- **TypeScript Support**: Bun supports `.ts` and `.tsx` files out of the box. No separate compilation step needed.
- **Environment Variables**: Automatically loads `.env` files. Access via `process.env` or `Bun.env`.
- **Fast I/O**: Use `Bun.file(path)` and `Bun.write(path, content)` for high-performance file operations.
- **HTTP Server**: Use `Bun.serve({ fetch(req) { ... } })` for an extremely fast built-in web server.
- **SQLite**: Built-in high-performance SQLite driver via `import { Database } from "bun:sqlite"`.

## When to use Bun Toolkit
- When the project has a `bun.lockb` file.
- When the user mentions "Bun".
- When performance is a priority for JS/TS tasks (installing, testing, running).
- For quick JS/TS scripts that need high performance.
