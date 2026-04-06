# Cache Wrapper Example (Redis)

## Contents
- Problem: Direct Redis usage issues
- Solution: Two-layer approach (infrastructure wrapper + domain class)
- Benefits of thin wrapper approach
- Alternative: Single-layer approach for simple cases
- Key decisions on what to expose, hide, and keep in domain

## Problem

Direct Redis usage spreads across the codebase with mixed concerns:

```python
# In multiple files, Redis details leak everywhere
import redis

r = redis.Redis(host='localhost', port=6379)
r.set('user:123:profile', json.dumps(profile), ex=3600)
value = r.get('user:123:profile')
if value:
    profile = json.loads(value)
```

Issues:
- Redis connection details scattered
- JSON serialization repeated
- Key naming conventions inconsistent
- TTL values magic numbers
- Testing requires mocking Redis directly

## Solution: Thin Cache Wrapper

### Two-Layer Approach

**Infrastructure layer** - Thin wrapper:

```python
class CacheWrapper:
    """Minimal Redis wrapper exposing only needed operations."""

    def __init__(self, redis_client):
        self._redis = redis_client

    def set_with_ttl(self, key: str, value: str, ttl_seconds: int) -> None:
        """Store a value with expiration time."""
        self._redis.set(key, value, ex=ttl_seconds)

    def get(self, key: str) -> str | None:
        """Retrieve a value by key."""
        value = self._redis.get(key)
        return value.decode('utf-8') if value else None

    def delete(self, key: str) -> None:
        """Remove a value by key."""
        self._redis.delete(key)

    def exists(self, key: str) -> bool:
        """Check if key exists."""
        return self._redis.exists(key) > 0
```

**Domain layer** - Business logic using wrapper:

```python
class UserProfileCache:
    """Domain-specific cache for user profiles."""

    PROFILE_TTL = 3600  # 1 hour

    def __init__(self, cache: CacheWrapper):
        self._cache = cache

    def store_profile(self, user_id: int, profile: UserProfile) -> None:
        """Cache user profile data."""
        key = self._profile_key(user_id)
        value = json.dumps(profile.to_dict())
        self._cache.set_with_ttl(key, value, self.PROFILE_TTL)

    def fetch_profile(self, user_id: int) -> UserProfile | None:
        """Retrieve cached user profile."""
        key = self._profile_key(user_id)
        value = self._cache.get(key)
        if value:
            return UserProfile.from_dict(json.loads(value))
        return None

    def invalidate_profile(self, user_id: int) -> None:
        """Remove cached profile."""
        key = self._profile_key(user_id)
        self._cache.delete(key)

    def _profile_key(self, user_id: int) -> str:
        return f"user:{user_id}:profile"
```

### Benefits

**Minimal coupling**: Only 4 Redis methods exposed, not the entire API.

**Domain language**: Methods describe business operations, not cache operations.

**Testability**: Mock CacheWrapper, not Redis. Mock UserProfileCache for higher-level tests.

**Centralized concerns**: Key naming, serialization, TTL management in one place.

**Easy migration**: Switching from Redis to Memcached requires changing only CacheWrapper.

## Alternative: Single-Layer Approach

For simpler cases, combine wrapper and domain logic:

```python
class SessionCache:
    """Session storage with built-in Redis wrapper."""

    SESSION_TTL = 1800  # 30 minutes

    def __init__(self, redis_client):
        self._redis = redis_client

    def store_session(self, session_id: str, user_id: int, data: dict) -> None:
        """Store session data."""
        key = f"session:{session_id}"
        value = json.dumps({"user_id": user_id, **data})
        self._redis.set(key, value, ex=self.SESSION_TTL)

    def get_session(self, session_id: str) -> dict | None:
        """Retrieve session data."""
        key = f"session:{session_id}"
        value = self._redis.get(key)
        if value:
            return json.loads(value.decode('utf-8'))
        return None

    def delete_session(self, session_id: str) -> None:
        """Remove session."""
        key = f"session:{session_id}"
        self._redis.delete(key)
```

Use this when:
- Business logic is minimal
- No need to mock the cache separately
- Single domain concern using the cache

## Key Decisions

**What to expose**: Only `set_with_ttl`, `get`, `delete`, `exists`. Not `mget`, `scan`, `pipeline`, `watch`, or other advanced features until needed.

**What to hide**: Connection management, encoding/decoding, Redis exceptions transformed to domain exceptions.

**What stays in domain**: Key naming, serialization format, TTL values, business validation.
