---
name: dockerfile-review
description: Reviews Dockerfiles for build performance, image size, and security issues. Use when optimizing, validating, or improving Dockerfiles.
---

# Dockerfile Review

STARTER_CHARACTER = 🐳

When starting, announce: "🐳 Using DOCKERFILE-REVIEW skill".

## Process

1. Check if `droast` (dockerfile-roast) is available by running `command -v droast`
   - If available: run `droast --no-roast --min-severity warning <Dockerfile>` and use the output as a starting point
   - If not available: skip and continue with manual review
2. Read the Dockerfile (and .dockerignore if present)
3. Evaluate against each dimension below
4. Report findings grouped by severity: critical (security risks), major (significant size/performance impact), minor (incremental improvements)
5. For each finding: state what's wrong, why it matters, and suggest a fix direction
6. If the Dockerfile is solid, say so — don't invent issues

## Review Dimensions

### 1. Layer Cache Ordering

Dependency files (package.json, requirements.txt, go.mod) must be copied and installed BEFORE application source code. Violations cause full dependency reinstalls on every code change.

Anti-pattern: `COPY . .` followed by `RUN pip install` or `RUN npm ci`. The entire dependency layer rebuilds on any source change.

Impact: builds that should take seconds take minutes. With frequent builds, this compounds to hours per week.

### 2. Base Image Selection

Three tiers exist: full (includes compilers, tools), slim (minimal OS, basic tooling), distroless (application only, no shell).

Anti-patterns:
- Using full images in production (node:20 is ~950MB vs node:20-slim at ~220MB)
- Using distroless when debugging access is needed
- Not considering slim as the default production choice

Alpine warning: Alpine uses musl libc instead of glibc. For Python, Node, and other runtimes with native extensions, this means rebuilding native deps from source (slower builds) or silent performance regressions. Prefer `-slim` (Debian-based) for these workloads — similar size savings, zero compatibility issues. Alpine remains a good choice for Go binaries and static builds where libc doesn't matter.

### 3. .dockerignore Coverage

Without .dockerignore, `COPY . .` sends everything to the build context: node_modules (50-500MB), .git (100MB+), coverage reports, IDE configs, .env files.

`COPY . .` is fine — if the .dockerignore is correct. Most pain comes from a missing or incomplete ignore file, not from the COPY instruction itself.

Anti-patterns:
- No .dockerignore file at all
- Missing .git/ (often the largest offender in mature repos)
- Missing local dependency directories (node_modules/, venv/, __pycache__/)
- Missing .env files (both a size and security issue)

### 4. Multi-Stage Builds

Build tools, compilers, and dev dependencies should not exist in the final image. Multi-stage builds separate construction from execution. The builder stage is the bloat zone; the final stage must be lean.

Anti-patterns:
- Single-stage builds that include build toolchains in production
- Copying entire build context into final stage instead of only artifacts
- Not using named stages (makes COPY --from fragile)

### 5. Version Pinning

Tags like `latest` or unpinned package versions create non-reproducible builds.

Anti-patterns:
- `FROM ubuntu:latest` or `FROM node:lts`
- `apt-get install -y curl` without version pinning
- No lock files for language-level dependencies

For production images, pin base images by digest, not just tag. `node:20` today is not `node:20` in six months — tags are mutable. Example: `FROM node:20-slim@sha256:abc123...`. This guarantees reproducible builds. Use tag+digest together so the tag documents intent while the digest locks the exact image.

### 6. Layer Minimization

Each RUN, COPY, ADD creates a layer. Deletions in later layers don't reduce image size — the previous layer still contains the data.

Anti-pattern: separate RUN instructions for install and cleanup. `RUN apt-get update` then `RUN rm -rf /var/lib/apt/lists/*` preserves the cache in the first layer.

Fix direction: combine install and cleanup in a single RUN with `&&`.

### 7. BuildKit Cache Mounts

BuildKit's `--mount=type=cache` keeps package manager caches (pip, apt, cargo, npm) between builds without them ending up in the final layer. This dramatically speeds up rebuilds.

Example:
```dockerfile
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

```dockerfile
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y curl
```

Anti-patterns:
- Downloading all dependencies from scratch on every build when a cache mount would persist them
- Manually copying and removing caches in the same layer to avoid bloat (cache mounts solve this cleaner)

Requires `DOCKER_BUILDKIT=1` or Docker Buildx (default in modern Docker). Check the project's Docker version expectations before recommending.

### 8. Secret Handling

Credentials, API keys, and tokens embedded in layers are permanently accessible via `docker history` or registry inspection.

Anti-patterns:
- `ENV API_KEY=...` or `ARG` with secrets passed at build time
- COPY of .env, credentials, or key files into the image
- RUN commands with inline secrets

Fix direction: use `--mount=type=secret` with BuildKit for build-time secrets. Never bake secrets into layers.

### 9. Non-Root Execution

Running as root means a container escape or application vulnerability grants full system access.

Anti-patterns:
- No USER instruction (defaults to root)
- USER instruction placed before file operations (causing permission issues)
- Not setting file ownership with chown

Fix direction: create a dedicated user with useradd, chown application files, then switch with USER — placed after all file operations that need root.

### 10. Process Model

One process per container is a good default, not an absolute law. If the app needs nginx + app server and is not running at orchestrator scale, using supervisord or a process manager is a valid choice that avoids premature infrastructure complexity.

When to flag: when a Dockerfile runs multiple unrelated services that should clearly be separate (e.g., app + database). When NOT to flag: when a Dockerfile uses a process manager for tightly coupled processes in a simple deployment context.

## Severity Classification

- **Critical**: secret handling violations, running as root in production
- **Major**: missing multi-stage builds, poor cache ordering, no .dockerignore, full base images in production, Alpine with native-extension runtimes
- **Minor**: unpinned versions (tags without digest), extra layers, missing specific .dockerignore entries, missing BuildKit cache mounts
