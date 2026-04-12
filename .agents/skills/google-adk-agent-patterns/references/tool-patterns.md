# ADK Function Tool Patterns

## Anatomy of a Function Tool

```python
def lookup_product(product_id: str) -> dict:
    """Retrieve product details by product ID.

    Call this tool when the user asks about a specific product,
    its price, or availability.

    Args:
        product_id: The unique product identifier (e.g. 'SKU-1234').
    """
    product = db.get(product_id)
    if product is None:
        return {"status": "error", "message": f"Product {product_id!r} not found."}
    return {"status": "success", "product": product}
```

## Return Value Conventions

| Return value | How ADK treats it |
|---|---|
| `{"status": "success", ...}` | Passed directly to LLM as tool result |
| `{"status": "error", "message": "..."}` | Passed to LLM; LLM may retry or explain |
| `{"status": "pending", ...}` | Signals async / long-running work |
| `"a string"` | Auto-wrapped: `{"result": "a string"}` |
| `42` | Auto-wrapped: `{"result": 42}` |

Always prefer returning a dict explicitly.

## Long-Running Tools

```python
from google.adk.tools import LongRunningFunctionTool

def process_large_file(file_path: str) -> dict:
    """Process a large file asynchronously.

    Args:
        file_path: Absolute path to the file to process.
    """
    return {"status": "success", "records_processed": 1000}

long_running_tool = LongRunningFunctionTool(func=process_large_file)
agent = Agent(name="processor", model="gemini-2.5-flash", tools=[long_running_tool])
```

## Structured Output (output_schema — No Tools)

```python
from pydantic import BaseModel

class AnalysisResult(BaseModel):
    sentiment: str
    confidence: float
    key_themes: list[str]

agent = Agent(
    name="sentiment_agent",
    model="gemini-2.5-flash",
    output_schema=AnalysisResult,
    output_key="analysis",
    # DO NOT add tools=[...] — incompatible with output_schema on most models
)
```
