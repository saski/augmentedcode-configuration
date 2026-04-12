# ADK CLI Commands Reference

## Project Bootstrap

```bash
# Enable Vertex AI API
gcloud services enable aiplatform.googleapis.com

# Create and enter project
uv init agent-project
cd agent-project
uv add google-adk
```

## Agent Scaffold

```bash
# Interactive scaffold (creates agent/ directory)
uv run adk create agent
```

## Running Agents

```bash
# Dev UI (hot reload, localhost:8000)
uv run adk web --reload_agents

# Dev UI in Cloud Shell / remote (no CORS restrictions)
uv run adk web --reload_agents --allow_origins="*"

# CLI interactive mode
uv run adk run agent
```

## Deployment (Cloud Run)

```bash
# Deploy agent to Cloud Run
adk deploy cloud_run \
  --project=YOUR_PROJECT_ID \
  --region=us-central1 \
  --service_name=my-agent \
  path/to/agent

# Deploy with built-in web UI
adk deploy cloud_run \
  --project=YOUR_PROJECT_ID \
  --region=us-central1 \
  --service_name=my-agent \
  --with_ui \
  path/to/agent
```

## Session Management

```bash
# Reset all sessions (SQLite file inside agent package)
rm agent/.adk/session.db
```

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `GOOGLE_GENAI_USE_VERTEXAI` | `1` | Route to Vertex AI backend |
| `GOOGLE_CLOUD_PROJECT` | your project id | GCP project |
| `GOOGLE_CLOUD_LOCATION` | `global` | Vertex AI endpoint region |
