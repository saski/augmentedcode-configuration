---
name: google-adk-agent-patterns
description: "Define, compose, and wire Google ADK agents with function tools and multi-agent orchestration. Use when writing agent definitions, adding Python function tools, building pipelines with SequentialAgent/LoopAgent/ParallelAgent, or designing router/delegation patterns. Trigger on: adk agent, LlmAgent, SequentialAgent, LoopAgent, ParallelAgent, AgentTool, function tool, output_key, output_schema, agent routing."
---

# Google ADK Agent Patterns

## When to Use / When Not to Use

**Use this skill when:**
- Defining or modifying an `Agent` (LlmAgent) with model, instructions, or tools.
- Writing Python function tools registered in `tools=[...]`.
- Composing multi-agent pipelines (sequential, loop, parallel, router).
- Passing state between agents using `output_key` / `{var}` injection.

**Do not use this skill when:**
- Setting up a new ADK project from scratch (use `google-adk-setup`).
- Deploying to Cloud Run (covered in `google-adk-setup` references).

---

## Agent Configuration (LlmAgent / Agent)

```python
from google.adk.agents.llm_agent import Agent

root_agent = Agent(
    name="my_agent",
    model="gemini-2.5-flash",
    description="One-sentence description used by other agents for routing.",
    instruction="You are a helpful assistant. Answer: {topic?}",
    tools=[my_tool],
)
```

Key parameters:

| Parameter | Purpose |
|-----------|---------|
| `name` | Unique identifier for the agent |
| `model` | Gemini model string (e.g. `gemini-2.5-flash`) |
| `description` | Used by orchestrators for routing — be precise |
| `instruction` | System prompt; supports `{var}` (required) and `{var?}` (optional) state injection |
| `tools` | List of Python functions or `AgentTool` instances |
| `output_schema` | Pydantic model for structured output |
| `output_key` | Writes agent output to shared session state under this key |
| `include_contents` | Controls which conversation history is passed |
| `generate_content_config` | Fine-grained generation parameters |

**Critical constraint:** `output_schema` and `tools` cannot both be set on most models. Choose one.

---

## Function Tools

See [references/tool-patterns.md](references/tool-patterns.md) for full examples.

### Minimal function tool

```python
def get_weather(city: str) -> dict:
    """Return current weather for the given city name.

    Args:
        city: The city name to look up.
    """
    return {"status": "success", "temperature_c": 22}

agent = Agent(model="gemini-2.5-flash", name="weather_agent", tools=[get_weather])
```

### Rules for function tools

1. The **docstring is the tool description** the LLM reads — write it precisely.
2. Always return a `dict` with a `"status"` key: `"success"`, `"error"`, or `"pending"`.
3. Non-dict returns are auto-wrapped as `{"result": value}`.
4. Minimize parameters; use only simple, serializable types.
5. `*args` and `**kwargs` are ignored in schema generation — never use them.
6. Long-running operations: wrap with `LongRunningFunctionTool(func=my_func)`.

---

## Multi-Agent Patterns

See [references/multi-agent-patterns.md](references/multi-agent-patterns.md) for full examples.

### SequentialAgent (pipeline)

```python
from google.adk.agents import SequentialAgent

pipeline = SequentialAgent(
    name="research_pipeline",
    sub_agents=[researcher, writer, reviewer],
)
```

- Each agent runs in order.
- Use `output_key="my_key"` on an agent to write its result to shared state.
- Downstream agents read it via `{my_key}` in their `instruction`.

### LoopAgent (iterative refinement)

```python
from google.adk.agents import LoopAgent

loop = LoopAgent(
    name="refinement_loop",
    sub_agents=[drafter, critic],
    max_iterations=5,
)
```

- Runs sub-agents repeatedly until a termination condition is met.

### ParallelAgent (concurrent)

```python
from google.adk.agents import ParallelAgent

parallel = ParallelAgent(
    name="parallel_research",
    sub_agents=[topic_a_agent, topic_b_agent],
)
```

- Runs all sub-agents concurrently; results aggregate into shared session state.

### AgentTool (delegation)

```python
from google.adk.agents import AgentTool

dispatcher = Agent(
    name="dispatcher",
    model="gemini-2.5-flash",
    tools=[AgentTool(agent=specialist)],
)
```

- Wraps an agent as a callable tool for the parent agent.
- The `description` on the wrapped agent controls when it is invoked.

---

## State Injection in Instructions

```python
# Required variable (errors if missing from state)
instruction = "Summarize this text: {raw_text}"

# Optional variable (silently ignored if missing)
instruction = "Context: {context?}\n\nAnswer the user's question."
```

State is populated by prior agents' `output_key` values or session initialization.
