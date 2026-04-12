# ADK Multi-Agent Patterns Reference

## SequentialAgent — State Handoff via output_key

```python
from google.adk.agents import SequentialAgent
from google.adk.agents.llm_agent import Agent

researcher = Agent(
    name="researcher",
    model="gemini-2.5-flash",
    instruction="Research the topic: {topic}. Produce detailed notes.",
    output_key="raw_notes",
)

writer = Agent(
    name="writer",
    model="gemini-2.5-flash",
    instruction="Write a clear article based on these notes:\n{raw_notes}",
    output_key="article",
)

reviewer = Agent(
    name="reviewer",
    model="gemini-2.5-flash",
    instruction="Review this article and provide feedback:\n{article}",
)

pipeline = SequentialAgent(
    name="content_pipeline",
    sub_agents=[researcher, writer, reviewer],
)
```

State flow: `researcher` → `raw_notes` → `writer` → `article` → `reviewer`.

## LoopAgent — Iterative Refinement

```python
from google.adk.agents import LoopAgent

drafter = Agent(
    name="drafter",
    model="gemini-2.5-flash",
    instruction="Improve the draft based on feedback: {feedback?}\nCurrent draft: {draft?}",
    output_key="draft",
)

critic = Agent(
    name="critic",
    model="gemini-2.5-flash",
    instruction="Review this draft. If excellent, say DONE. Otherwise provide feedback.\nDraft: {draft}",
    output_key="feedback",
)

refinement = LoopAgent(
    name="refinement_loop",
    sub_agents=[drafter, critic],
    max_iterations=4,
)
```

## ParallelAgent + Synthesizer

```python
from google.adk.agents import ParallelAgent, SequentialAgent

market_agent = Agent(
    name="market_researcher",
    model="gemini-2.5-flash",
    instruction="Research market trends for: {category}",
    output_key="market_data",
)

competitor_agent = Agent(
    name="competitor_analyst",
    model="gemini-2.5-flash",
    instruction="Analyze top competitors in: {category}",
    output_key="competitor_data",
)

synthesizer = Agent(
    name="synthesizer",
    model="gemini-2.5-flash",
    instruction="Based on:\nMarket: {market_data}\nCompetitors: {competitor_data}\n\nProvide recommendations.",
)

research_system = SequentialAgent(
    name="research_system",
    sub_agents=[
        ParallelAgent(name="parallel_research", sub_agents=[market_agent, competitor_agent]),
        synthesizer,
    ],
)
```

## Router Pattern (Dispatcher + Specialists via AgentTool)

```python
from google.adk.agents import AgentTool

billing_specialist = Agent(
    name="billing_specialist",
    model="gemini-2.5-flash",
    description="Handles billing questions, invoices, payment issues, and subscription management.",
    instruction="You are a billing specialist. Answer only billing-related questions.",
)

tech_specialist = Agent(
    name="tech_specialist",
    model="gemini-2.5-flash",
    description="Handles technical support: bugs, errors, installation, and configuration.",
    instruction="You are a technical support specialist. Answer only technical questions.",
)

dispatcher = Agent(
    name="dispatcher",
    model="gemini-2.5-flash",
    instruction="You are a dispatcher. Always delegate to the correct specialist. Never answer directly.",
    tools=[
        AgentTool(agent=billing_specialist),
        AgentTool(agent=tech_specialist),
    ],
)
```

Key: the `description` on each specialist is what the dispatcher reads for routing — make it precise and distinct.

## Composition Hierarchy

```
SequentialAgent
├── ParallelAgent        # concurrent independent tasks
│   ├── AgentA
│   └── AgentB
├── LlmAgent             # synthesizer reads parallel results from state
└── LoopAgent            # optional refinement pass
    ├── drafter
    └── critic
```

Start simple (single agent + tools), add orchestration only when needed.
