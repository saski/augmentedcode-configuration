---
name: thin-wrappers
description: Encapsulates infrastructure SDKs behind minimal domain-aligned interfaces. Use when accessing any external infrastructure to keep SDK usage contained, testing simple, and changes easy.
---

STARTER_CHARACTER = 🏗️

# Thin Infrastructure Wrappers

## Core Principle

Minimize the API surface area: expose only what you use today, in your domain's language. The wrapper should be significantly smaller than the SDK it wraps.

## When to Apply

Apply thin wrappers when:
- Direct SDK usage spreads across the codebase
- Infrastructure concerns leak into business logic
- Testing requires mocking third-party libraries directly
- Switching providers or versions creates ripple effects
- SDK types and concepts appear in domain code

Skip when:
- The SDK is already minimal and domain-aligned
- Usage is isolated to a single boundary class
- The abstraction cost exceeds the coupling cost

## Design Process

### 1. Identify Usage Patterns

Analyze existing SDK usage across the codebase:
- Find all import statements for the SDK
- Catalog which SDK methods are actually used
- Group usage by purpose (read, write, delete, etc.)
- Apply the 80% rule: focus on covering the most common operations first

### 2. Design Minimal Interface

Create an interface exposing only what's needed:
- Use domain terminology, not SDK terminology
- Expose operations, not SDK objects or types
- Keep method signatures simple and focused
- Prevent SDK types from escaping the wrapper

Anti-pattern: Exposing entire SDK "just in case"

Example transformation:
- SDK: `cache.set(key, value, ex=ttl, nx=True)`
- Wrapper: `cache.set_if_not_exists(key, value, ttl)`

### 3. Choose Implementation Pattern

**Two-layer approach** (most common):
- Thin wrapper: Direct SDK encapsulation, minimal logic
- Domain class: Business logic using the wrapper

Use when business logic needs to be separated from infrastructure.

**Single-class approach**:
- Combine wrapper and domain logic in one class

Use when wrapper logic is minimal and business logic is simple.

### 4. Implement with Domain Language

Align method names and parameters with domain concepts:
- `publish_order_created(order_id, customer_id)` not `publish(topic, message)`
- `fetch_user_profile(user_id)` not `get(bucket, key)`
- `store_uploaded_file(file_id, content)` not `put_object(params)`

## Gradual Refactoring

Migrate existing code incrementally:

1. **Create wrapper for 80% case**: Start with most common usage patterns
2. **Replace one usage site at a time**: Incremental, safe changes
3. **Measure progress**: Track remaining direct SDK calls
4. **Refine interface**: Adjust based on actual migration experience
5. **Complete migration**: Handle remaining edge cases

Each step should be independently committable and testable.

## Integration with Architecture

Thin wrappers naturally map to the adapter layer in hexagonal/clean architecture, implementing domain-defined ports.

## Testing

Thin wrappers enable simple test doubles — no mocking libraries needed. See examples for test double implementations.

## Anti-Patterns

**Exposing SDK Types**: Don't let SDK classes or enums leak through the wrapper boundary. Transform them into domain types.

**Premature Abstraction**: Don't create wrappers for single-use SDKs. Wait until usage patterns emerge.

**Over-Engineering**: Don't add configuration, features, or flexibility beyond current needs. Simple is better.

**Generic Wrappers**: Don't create `DatabaseWrapper` or `QueueWrapper` with every possible method. Expose only what the application uses.

**Pass-Through Methods**: Don't just rename SDK methods without adding domain meaning. Each wrapper method should represent a domain operation.

## Examples

See reference implementations for common infrastructure types:

- **Cache/Redis**: [references/cache-example.md](references/cache-example.md)
- **Queue/Messaging**: [references/queue-example.md](references/queue-example.md)
- **Storage/S3**: [references/storage-example.md](references/storage-example.md)

These illustrate the principles. Consider what fits your context.
