---
name: google-adk-setup
description: "Bootstrap a Google ADK (Agent Development Kit) project from zero to a running local dev UI. Use when setting up a new ADK agent project, configuring Vertex AI credentials, scaffolding the agent folder, or troubleshooting ADK environment issues. Trigger on: adk setup, adk init, google-adk, vertex ai agent, uv run adk, adk web."
---

# Google ADK Setup

## When to Use / When Not to Use

**Use this skill when:**
- Starting a new ADK project from scratch.
- Configuring GCP credentials and environment variables for ADK.
- Scaffolding an agent folder with `adk create agent`.
- Launching the ADK dev UI or CLI runner.
- Troubleshooting missing `.env` or Vertex AI auth errors.

**Do not use this skill when:**
- Designing agent logic, tools, or multi-agent systems (use `google-adk-agent-patterns`).
- Deploying to Cloud Run (deployment commands are in the references).

---

## Prerequisites

1. GCP project with billing enabled.
2. `gcloud` CLI installed and authenticated: `gcloud auth application-default login`.
3. `uv` installed (see `using-uv` skill).
4. Vertex AI API enabled in your GCP project.

Enable the API:
```bash
gcloud services enable aiplatform.googleapis.com
```

---

## Workflow

### 1. Create the project

```bash
uv init agent-project
cd agent-project
uv add google-adk
```

### 2. Scaffold the agent

```bash
uv run adk create agent
```

Interactive prompts:
- Model: `gemini-2.5-flash` (recommended starting point)
- Backend: `Vertex AI`
- GCP Project ID: your project id
- Location: `global`

Generated files:
```
agent/
├── __init__.py     # exposes root_agent
├── agent.py        # Agent definition
└── .env            # Vertex AI credentials (co-located with the package)
```

### 3. Verify the `.env` file

The `.env` lives inside the `agent/` directory (not the project root):

```
GOOGLE_GENAI_USE_VERTEXAI=1
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_LOCATION=global
```

### 4. Run the dev UI

```bash
uv run adk web --reload_agents
```

Opens at `http://localhost:8000`.

For Cloud Shell or remote environments, add `--allow_origins="*"`.

### 5. Run in CLI mode

```bash
uv run adk run agent
```

---

## Key Facts

- `GOOGLE_CLOUD_LOCATION=global` routes to the global Vertex AI endpoint; use a regional value (e.g. `us-central1`) only if `global` is unavailable.
- `.adk/session.db` (SQLite) stores conversation session state between runs. Delete it to reset sessions.
- `--reload_agents` hot-reloads agent code on file changes; omit in production.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `DefaultCredentialsError` | Run `gcloud auth application-default login` |
| `Permission denied: aiplatform.googleapis.com` | Enable API: `gcloud services enable aiplatform.googleapis.com` |
| Agent changes not reflected | Ensure `--reload_agents` flag is set |
| Sessions persist unexpectedly | Delete `agent/.adk/session.db` |

See [references/cli-commands.md](references/cli-commands.md) for the full CLI reference.
