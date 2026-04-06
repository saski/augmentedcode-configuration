Author: Eduardo Ferro
Source: https://www.eferro.net/

# Complexity Dimensions and Guiding Heuristics

These dimensions help assess potential complexity and guide system design toward simplicity, reversibility, and small safe steps.

## Contents

### Complete 30 Complexity Dimensions Checklist
1. [Data Volume and Nature](#1-data-volume-and-nature) (Dimensions 1-5)
   - Data Size, Number of Elements, Growth Rate, Processing Weight, Data Lifespan
2. [Interaction and Frequency](#2-interaction-and-frequency) (Dimensions 6-9)
   - Interaction Frequency, Latency, Concurrency, Elasticity
3. [Consistency, Order, Dependencies](#3-consistency-order-dependencies) (Dimensions 10-14)
   - Processing Order, Scope of Order, Consistency, Transactions, State
4. [Resilience, Security, Fault Tolerance](#4-resilience-security-fault-tolerance) (Dimensions 15-22)
   - Error Criticality, Idempotence, Side Effects, Uniqueness, Reversibility, Inconsistency Tolerance, Exactly-Once, Auditability
5. [Integration, External Dependencies, Versions](#5-integration-external-dependencies-versions) (Dimensions 23-26)
   - External Dependencies, Security/Privacy, Versioning, Interoperability
6. [Efficiency, Maintainability, Evolution](#6-efficiency-maintainability-evolution) (Dimensions 27-30)
   - Refactoring, Cost Sensitivity, Availability, Scaling Time

### Additional Resources
- [Specialized Checklists](#specialized-checklists)
- [Pattern Catalog](#pattern-catalog-simplest-first-approaches)

---

## Complete 30 Complexity Dimensions Checklist

Use this comprehensive checklist when reviewing technical proposals. For each dimension, ask the probing questions to challenge assumptions.

---

### 1. Data Volume and Nature

**1. Data Size**
- 🔍 Ask: "Are we dealing with KBs, MBs, or GBs?"
- 🚨 Challenge: "Do we really need to handle large files now, or can we start with a 1MB limit?"
- **Guidance**: 1KB form = simple HTTP POST. 2GB video upload = use resumable/chunked uploads (but do we need video uploads now?).

**2. Number of Elements**
- 🔍 Ask: "How many items will we process typically?"
- 🚨 Challenge: "Can we start with 100 items and see if we ever hit limits?"
- **Guidance**: Few = O(n²) is OK. Millions = use optimized data structures (but do we have millions now?).

**3. Expected Growth Rate**
- 🔍 Ask: "How fast will usage grow?"
- 🚨 Challenge: "Is this really going to be viral, or are we over-planning for scale?"
- **Guidance**: Viral app = prepare for scaling. Internal tool = simpler infra is fine. **Most projects overestimate growth.**

**4. Internal Processing Weight**
- 🔍 Ask: "Are we just moving data or doing heavy computation?"
- 🚨 Challenge: "Can we use simpler processing and optimize only if it becomes a problem?"
- **Guidance**: Video conversion = parallel workers. Log transfer = simple copy. Don't optimize before measuring.

**5. Data Lifespan**
- 🔍 Ask: "How long do we need to keep this data?"
- 🚨 Challenge: "Can we use a 30-day TTL and add archiving later if needed?"
- **Guidance**: Apply TTL, archiving or cold storage patterns as appropriate. Default to shorter retention.

---

### 2. Interaction and Frequency

**6. Interaction Frequency**
- 🔍 Ask: "How often does this happen? Milliseconds or daily?"
- 🚨 Challenge: "Can we use a simple polling/batch approach instead of real-time streaming?"
- **Guidance**: High frequency = streaming/event systems. Low frequency = batch jobs or polling. **Most "real-time" needs aren't really real-time.**

**7. Acceptable Latency**
- 🔍 Ask: "What's the actual latency requirement?"
- 🚨 Challenge: "Do users really need sub-second response, or is 2-3 seconds acceptable?"
- **Guidance**: Product page <1s. Monthly report: minutes OK. **Ask for evidence, not assumptions.**

**8. Concurrency Volume**
- 🔍 Ask: "How many concurrent users/requests?"
- 🚨 Challenge: "Can we start with a simple monolith and scale later if traffic grows?"
- **Guidance**: High concurrency = stateless design + horizontal scaling. Low = monolith may suffice. **Start simple.**

**9. Elasticity Needs**
- 🔍 Ask: "How fast must the system scale?"
- 🚨 Challenge: "Can we manually scale at first instead of setting up auto-scaling?"
- **Guidance**: Fast (e.g., ticket sales) = autoscaling/serverless. Slow = scheduled/manual scaling. **Manual scaling teaches you patterns.**

---

### 3. Consistency, Order, Dependencies

**10. Processing Order Requirement**
- 🔍 Ask: "Does order matter?"
- 🚨 Challenge: "Can we relax ordering constraints to simplify the design?"
- **Guidance**: Payment processing = strict order. Likes = relaxed. **Most things don't need strict ordering.**

**11. Scope of Order**
- 🔍 Ask: "Global order or per-entity/user?"
- 🚨 Challenge: "Can we partition by user ID to avoid global ordering complexity?"
- **Guidance**: Prefer partitioned ordering when possible. Global ordering is expensive.

**12. Consistency Guarantees**
- 🔍 Ask: "Do we need strong or eventual consistency?"
- 🚨 Challenge: "Can we use eventual consistency and avoid distributed transactions?"
- **Guidance**: Bank balance = strong. Video views = eventual. **Eventual consistency is your friend.**

**13. Distributed Transactions**
- 🔍 Ask: "Do changes span multiple systems?"
- 🚨 Challenge: "Can we use a saga pattern or avoid the transaction entirely?"
- **Guidance**: Avoid distributed transactions when possible. Use sagas or event-driven designs. **Distributed transactions are complexity magnets.**

**14. Stateful vs Stateless**
- 🔍 Ask: "Does this need to maintain state?"
- 🚨 Challenge: "Can we make it stateless and store state externally (cache, DB)?"
- **Guidance**: Prefer stateless for scalability. Store state externally if needed. **Stateless is simpler.**

---

### 4. Resilience, Security, Fault Tolerance

**15. Error Criticality**
- 🔍 Ask: "What happens if this fails?"
- 🚨 Challenge: "Can we accept graceful degradation instead of complex retry logic?"
- **Guidance**: Critical (payments) = retries, alerts. Tolerable = graceful degradation. **Not everything is critical.**

**16. Idempotence**
- 🔍 Ask: "Can this operation be retried safely?"
- 🚨 Challenge: "Can we use unique request IDs to make it idempotent?"
- **Guidance**: Prefer idempotent operations with unique request IDs. **Idempotence simplifies retry logic.**

**17. Side Effects**
- 🔍 Ask: "Does this trigger critical side effects?"
- 🚨 Challenge: "Can we delay side effects or make them optional?"
- **Guidance**: Handle with care. Use confirmation mechanisms. **Minimize side effects.**

**18. Uniqueness Requirements**
- 🔍 Ask: "Must this be globally unique?"
- 🚨 Challenge: "Can we tolerate rare duplicates and handle them manually?"
- **Guidance**: Apply unique keys or pre-checks where needed. **Perfect uniqueness is expensive.**

**19. Reversibility**
- 🔍 Ask: "Can this action be undone?"
- 🚨 Challenge: "Can we add soft deletes or versioning to make it reversible?"
- **Guidance**: Favor reversible operations. If not, use compensating actions. **Reversibility reduces risk.**

**20. Tolerance to Temporary Inconsistency**
- 🔍 Ask: "Can we tolerate short-term inaccuracies?"
- 🚨 Challenge: "Can we use eventual consistency and simplify the architecture?"
- **Guidance**: Favor eventual consistency when safe. **Most systems can tolerate seconds of inconsistency.**

**21. Exactly-Once Requirements**
- 🔍 Ask: "Is exactly-once delivery critical?"
- 🚨 Challenge: "Can we use at-least-once + deduplication instead?"
- **Guidance**: Avoid exactly-once unless critical. Prefer at-least-once + deduplication. **Exactly-once is hard and expensive.**

**22. Auditability**
- 🔍 Ask: "Do we need full traceability?"
- 🚨 Challenge: "Can we add structured logging later if auditing becomes important?"
- **Guidance**: Use structured logging, correlation IDs from the start. **Start with basic logging, enhance as needed.**

---

### 5. Integration, External Dependencies, Versions

**23. External Dependencies**
- 🔍 Ask: "Do we rely on third-party services?"
- 🚨 Challenge: "Can we mock/stub the external service initially and integrate later?"
- **Guidance**: Use circuit breakers, timeouts, graceful fallbacks. **Mock first, integrate later.**

**24. Security & Privacy**
- 🔍 Ask: "What are the security/compliance requirements?"
- 🚨 Challenge: "Can we start with basic auth and add OAuth/encryption later?"
- **Guidance**: Apply TLS, data encryption, anonymization. **Start with basic security, enhance as needed.**

**25. Versioning**
- 🔍 Ask: "Do we need multiple API versions?"
- 🚨 Challenge: "Can we avoid versioning initially and iterate the API directly?"
- **Guidance**: Explicit versioning, backward compatibility, planned deprecation. **Versioning adds complexity—avoid until proven necessary.**

**26. Interoperability**
- 🔍 Ask: "Are we locked into specific formats/protocols?"
- 🚨 Challenge: "Can we use a simple adapter instead of supporting multiple formats?"
- **Guidance**: Use adapters/translators for clean internal design. **Support one format well first.**

---

### 6. Efficiency, Maintainability, Evolution

**27. Refactoring Flexibility**
- 🔍 Ask: "Can we change this later?"
- 🚨 Challenge: "If refactoring is cheap, let's optimize for speed now and improve later."
- **Guidance**: Optimize for delivery now only if change is cheap later. **Favor learning over perfect design.**

**28. Cost Sensitivity**
- 🔍 Ask: "Is cost a major constraint?"
- 🚨 Challenge: "Can we use cheaper infrastructure and upgrade only if needed?"
- **Guidance**: Start simple, scale where needed. Avoid premature optimization. **Cheaper infrastructure teaches you constraints.**

**29. Availability Requirements**
- 🔍 Ask: "What uptime level is necessary?"
- 🚨 Challenge: "Can we accept 99% uptime instead of 99.99% to simplify operations?"
- **Guidance**: Mission-critical? Use HA design, replication, failover. **Most systems don't need five nines.**

**30. Scaling Time / Elasticity**
- 🔍 Ask: "How fast must we scale?"
- 🚨 Challenge: "Can we scale manually at first to learn before automating?"
- **Guidance**: Fast: pre-warmed instances, aggressive autoscaling. **Manual scaling first teaches you what matters.**

---

## Specialized Checklists by System Type

Use these focused checklists for common system types. Each includes the most relevant dimensions and specific questions.

---

### Web API / REST Service Checklist

**Most relevant dimensions:** #7, #8, #14, #15, #16, #23, #24, #25, #29

**Key questions:**
1. **Latency (#7)**: What's the p95 latency requirement? Can we start with 2-3 seconds?
2. **Concurrency (#8)**: How many concurrent requests? Can we start with a simple monolith?
3. **Stateless (#14)**: Can we make all endpoints stateless? Where should state live (DB, cache)?
4. **Error handling (#15)**: What happens when endpoints fail? Can we return 503 and retry client-side?
5. **Idempotence (#16)**: Which endpoints need to be idempotent? Can we use request IDs?
6. **External dependencies (#23)**: Which third-party APIs do we call? Can we mock them initially?
7. **Authentication (#24)**: Do we need OAuth or is API key sufficient initially?
8. **Versioning (#25)**: Do we need /v1/ now or can we iterate the API directly?
9. **Availability (#29)**: Do we need load balancing and failover, or is single instance OK initially?

**Common over-engineering patterns to avoid:**
- ❌ GraphQL when REST would work
- ❌ API gateway when you have 3 endpoints
- ❌ Rate limiting when you have 10 users
- ❌ Caching layer before measuring performance
- ❌ Multiple API versions on day 1

**Simplest viable approach:**
- Single monolith with REST endpoints
- PostgreSQL for persistence
- Basic auth (API keys or simple JWT)
- No versioning (iterate directly)
- Deploy on single instance
- Add complexity only when pain is felt

---

### Data Pipeline / ETL Checklist

**Most relevant dimensions:** #1, #2, #3, #4, #5, #6, #10, #12, #15

**Key questions:**
1. **Data size (#1)**: How much data per batch? Can we start with small batches?
2. **Number of elements (#2)**: How many records? Can we process 1000s before optimizing?
3. **Growth rate (#3)**: How fast will data volume grow? Can we scale later?
4. **Processing weight (#4)**: How CPU-intensive is the transformation? Can we use simple scripts first?
5. **Data lifespan (#5)**: How long do we keep processed data? Can we use 30-day TTL?
6. **Frequency (#6)**: Hourly, daily, or real-time? Can we start with daily batch?
7. **Order (#10)**: Must records be processed in order? Can we process in parallel?
8. **Consistency (#12)**: Do we need transactions? Can we use idempotent processing?
9. **Error handling (#15)**: What happens when a record fails? Can we skip and log it?

**Common over-engineering patterns to avoid:**
- ❌ Kafka/streaming when daily batch would work
- ❌ Spark/Hadoop for <1M records
- ❌ Complex orchestration (Airflow) for simple cron jobs
- ❌ Data lake when you have one data source
- ❌ Real-time processing when daily is sufficient

**Simplest viable approach:**
- Cron job running Python/bash script
- Read from source, transform, write to destination
- Log errors to file
- No orchestration framework
- Scale to hourly/streaming only when daily is too slow

---

### Background Job / Worker System Checklist

**Most relevant dimensions:** #2, #6, #8, #10, #12, #15, #16, #21

**Key questions:**
1. **Job volume (#2)**: How many jobs per hour? Can we start with simple queue?
2. **Frequency (#6)**: How often do jobs run? Can we use cron instead of queue?
3. **Concurrency (#8)**: How many workers? Can we start with 1-2?
4. **Order (#10)**: Must jobs run in order? Can we process in parallel?
5. **Consistency (#12)**: What happens if job fails mid-execution? Can we retry entire job?
6. **Criticality (#15)**: What happens if jobs are delayed? Can we tolerate delays?
7. **Idempotence (#16)**: Can jobs be retried safely? Can we make them idempotent?
8. **Exactly-once (#21)**: Must jobs run exactly once? Can we use at-least-once + deduplication?

**Common over-engineering patterns to avoid:**
- ❌ Celery/RabbitMQ when cron would work
- ❌ Job priority queues when all jobs have same priority
- ❌ Complex retry logic when simple retry is sufficient
- ❌ Multiple worker pools when one pool handles load
- ❌ Job orchestration when jobs are independent

**Simplest viable approach:**
- Cron job for scheduled tasks
- Simple queue (database table) for async tasks
- Single worker process polling queue
- Retry failed jobs (store retry count in DB)
- Add Redis/Celery only when DB queue becomes bottleneck

---

### Mobile App Backend Checklist

**Most relevant dimensions:** #7, #8, #14, #23, #24, #28, #29

**Key questions:**
1. **Latency (#7)**: What's acceptable response time? Can we start with 2-3 seconds?
2. **Concurrency (#8)**: How many active users? Can we start with simple backend?
3. **Stateless (#14)**: Can we make API stateless? Where should session state live?
4. **External deps (#23)**: Push notifications, analytics? Can we add these later?
5. **Security (#24)**: Do we need OAuth or is JWT sufficient? Can we start with simple auth?
6. **Cost (#28)**: What's the infrastructure budget? Can we start with single instance?
7. **Availability (#29)**: Do we need 99.9% uptime on day 1? Can we start with single instance?

**Common over-engineering patterns to avoid:**
- ❌ Multiple backend microservices for MVP
- ❌ Real-time features (WebSockets) when polling works
- ❌ Push notifications before you have active users
- ❌ CDN before measuring asset load times
- ❌ Multi-region deployment for local app

**Simplest viable approach:**
- Single backend API (monolith)
- PostgreSQL database
- JWT authentication
- Deploy on single cloud instance
- Add CDN, caching, scaling after measuring performance

---

### Real-Time / WebSocket System Checklist

**Most relevant dimensions:** #6, #7, #8, #14, #20, #29

**Key questions:**
1. **Frequency (#6)**: Do users really need real-time updates? Can we poll every 5-30 seconds?
2. **Latency (#7)**: Is <100ms necessary or is 1-2 seconds OK?
3. **Concurrency (#8)**: How many concurrent connections? Can we start with simple server?
4. **Stateful (#14)**: How do we manage connection state? Can we use sticky sessions?
5. **Inconsistency tolerance (#20)**: Can users tolerate stale data for seconds? Can we use polling?
6. **Availability (#29)**: What happens when WebSocket server fails? Can we fallback to polling?

**Common over-engineering patterns to avoid:**
- ❌ WebSockets when server-sent events (SSE) would work
- ❌ WebSockets when polling every 10 seconds is sufficient
- ❌ Message broker (Redis Pub/Sub) for simple broadcasting
- ❌ Horizontal scaling before testing single instance capacity
- ❌ Connection pooling/load balancing before you have load

**Simplest viable approach:**
- Start with polling (HTTP requests every 5-30 sec)
- If latency critical, use Server-Sent Events (SSE) first
- Only use WebSockets if bidirectional communication is required
- Single server instance (test capacity first)
- Add Redis Pub/Sub only when you need multi-server broadcasting

---

### Machine Learning / ML System Checklist

**Most relevant dimensions:** #3, #4, #6, #7, #27, #28

**Key questions:**
1. **Growth (#3)**: How fast will training data grow? Can we retrain manually initially?
2. **Processing weight (#4)**: How expensive is training/inference? Can we start with simple model?
3. **Frequency (#6)**: How often do we retrain? Can we retrain weekly/monthly manually?
4. **Latency (#7)**: Real-time inference or batch? Can we use batch predictions?
5. **Refactoring (#27)**: Can we change model architecture later? Start with simplest model?
6. **Cost (#28)**: What's the GPU/compute budget? Can we use pre-trained models?

**Common over-engineering patterns to avoid:**
- ❌ Complex deep learning when linear regression works
- ❌ Real-time inference when batch predictions sufficient
- ❌ MLOps pipeline when manual retraining works
- ❌ Model versioning/A/B testing before model is working
- ❌ GPU infrastructure when CPU is fast enough

**Simplest viable approach:**
- Start with simplest algorithm (linear/logistic regression, decision tree)
- Batch predictions (daily/hourly)
- Manual model training and deployment
- Use pre-trained models if available (transfer learning)
- Add complex ML only when simple approaches fail

---

## Additional Complete Examples

### Example 1: Proposing a Microservices Architecture

**User proposes:** "Let's split our monolith into 15 microservices for user management, payments, notifications, analytics, etc."

**Complexity review:**

**Dimensions challenged:**
- #8 (Concurrency): Do we have concurrency issues in the monolith?
- #13 (Distributed transactions): How do we handle cross-service transactions?
- #14 (State): How do we manage state across services?
- #23 (Dependencies): Each service depends on others—how do we handle failures?
- #27 (Refactoring): Can we change service boundaries later?
- #28 (Cost): What's the infrastructure cost increase?

**Questions:**
- What specific problem are we solving? (likely: deployment independence, team autonomy)
- How many developers on the team? (<10? Microservices premature)
- What's the deployment frequency goal? (Can we achieve it with better CI/CD for monolith?)
- Do we have distinct bounded contexts? (Or are we just splitting by layer?)

**Simpler alternatives:**

**Version 1 (Modular Monolith):**
- Keep single deployment unit
- Organize code into clear modules with defined interfaces
- Enforce module boundaries with architecture tests
- Deploy entire monolith (fast with good CI/CD)
- Cost: 1 server
- Team capacity impact: 5%

**Version 2 (Extract critical service):**
- Identify ONE service that truly needs independence (e.g., payment processing)
- Extract only that service
- Keep rest as monolith
- Cost: 2 servers
- Team capacity impact: 15%

**Version 3 (Microservices - only if justified):**
- Extract services only when:
  - Team size > 20 developers
  - Clear bounded contexts exist
  - Independent deployment is critical
  - Cost increase is acceptable

**Recommendation:** Start with Version 1 (modular monolith). Microservices are a team organization strategy, not a technical one.

---

### Example 2: Building a Caching Layer

**User proposes:** "Add Redis for caching with cache invalidation, TTL management, cache warming, and multi-level caching"

**Complexity review:**

**Dimensions challenged:**
- #5 (Lifespan): How long is cached data valid?
- #7 (Latency): What's the current response time? Is it a problem?
- #12 (Consistency): Can we tolerate stale data?
- #20 (Inconsistency tolerance): For how long can data be stale?
- #28 (Cost): Redis infrastructure cost?

**Questions:**
- What's the current p95 latency? (If <1s, is caching necessary?)
- Have we measured database query performance? (Optimize queries first?)
- Which endpoints are slow? (Cache only those)
- Can we use HTTP caching headers first? (Much simpler)

**Simpler alternatives:**

**Version 1 (No cache):**
- Optimize database queries (add indexes, rewrite N+1 queries)
- Use database query results directly
- Measure improvement
- Cost: $0
- Team capacity: 2% (index maintenance)

**Version 2 (In-memory cache):**
- Use application-level in-memory cache (e.g., Python `functools.lru_cache`)
- Cache expensive queries in application memory
- Simple TTL (5-60 minutes)
- No external dependencies
- Cost: $0
- Team capacity: 3%

**Version 3 (Redis - only if needed):**
- Add Redis only when:
  - In-memory cache insufficient (multiple app instances)
  - Cache needs to survive deploys
  - Cache size > available application memory

**Recommendation:** Start with Version 1 (query optimization). Most "caching problems" are actually "bad query problems."

---

### Example 3: Event Sourcing for Audit Trail

**User proposes:** "Implement event sourcing with event store, snapshots, projections, and event replay for audit trail"

**Complexity review:**

**Dimensions challenged:**
- #10 (Order): Do we need strict event ordering?
- #12 (Consistency): Do we need event replay or just audit log?
- #22 (Auditability): What level of auditability do we need?
- #27 (Refactoring): Can we change event schema later? (No—events are immutable)

**Questions:**
- What do we need to audit? (Just changes or full state reconstruction?)
- Do we need to replay events? (Or just view history?)
- Who needs access to audit trail? (Admins only or users too?)
- What's the compliance requirement? (General audit or regulatory?)

**Simpler alternatives:**

**Version 1 (Audit log table):**
- Create `audit_log` table: (timestamp, user_id, action, entity_type, entity_id, old_value, new_value)
- Write to audit log on every CREATE/UPDATE/DELETE
- Query audit log for history
- Cost: 1 database table
- Team capacity: 3%

**Version 2 (Immutable event log):**
- Append-only `events` table
- Store every state change as event
- No event replay—just historical record
- Cost: 1 database table + some storage
- Team capacity: 5%

**Version 3 (Event sourcing - only if needed):**
- Full event sourcing only when:
  - Need to reconstruct state at any point in time
  - Need to replay events for system recovery
  - Temporal queries are critical business requirement

**Recommendation:** Start with Version 1 (audit log table). Event sourcing is a massive complexity investment—ensure you truly need event replay.

---

### Example 4: Adding Search Functionality

**User proposes:** "Set up Elasticsearch cluster with sharding, replication, custom analyzers, and real-time indexing"

**Complexity review:**

**Dimensions challenged:**
- #2 (Elements): How many records to search?
- #6 (Frequency): How often do users search?
- #7 (Latency): What's acceptable search response time?
- #23 (Dependencies): Elasticsearch is external dependency

**Questions:**
- How many records? (<10K? Database full-text search works)
- What type of search? (Exact match, prefix, fuzzy, full-text?)
- How often is data updated? (Real-time indexing necessary?)
- What's search usage? (1% of traffic or 50%?)

**Simpler alternatives:**

**Version 1 (Database LIKE query):**
```sql
SELECT * FROM products WHERE name LIKE '%keyword%';
```
- Works for <10K records
- No external dependencies
- Cost: $0
- Team capacity: 1%

**Version 2 (Database full-text search):**
```sql
-- PostgreSQL
SELECT * FROM products WHERE to_tsvector('english', name) @@ to_tsquery('keyword');
CREATE INDEX products_name_fts ON products USING GIN(to_tsvector('english', name));
```
- Works for <1M records
- Built-in to PostgreSQL
- Cost: $0 (disk space for index)
- Team capacity: 3%

**Version 3 (Elasticsearch - only if needed):**
- Add Elasticsearch only when:
  - >1M records to search
  - Complex queries (faceting, fuzzy search, relevance scoring)
  - Database full-text search too slow

**Recommendation:** Start with Version 2 (PostgreSQL full-text search). Elasticsearch is expensive—ensure you need it.

---

## When to Add Complexity: Decision Criteria

Use these objective criteria to decide when to add complexity.

| Complexity | Add only when... | Typical threshold |
|------------|-----------------|-------------------|
| Caching (Redis) | Database queries >1s at p95 AND query optimization exhausted | Response time >1s |
| Microservices | Team >20 people AND clear bounded contexts exist | Team size >20 |
| Message queue (Kafka) | >10K events/second OR multiple consumers need events | >10K events/sec |
| NoSQL database | >10M records AND query patterns don't fit SQL | >10M records |
| Auto-scaling | Traffic varies >10× daily AND manual scaling too slow | 10× variance |
| Real-time (WebSockets) | Users need updates <5 seconds AND polling insufficient | <5 sec latency |
| Event sourcing | Need event replay OR temporal queries are critical | Regulatory requirement |
| Search (Elasticsearch) | >1M records AND database full-text search too slow | >1M records |
| Multi-region | >30% users in distant region AND latency >500ms | Latency >500ms |
| CDN | Static assets >1MB AND users globally distributed | Global users |

**Key principle:** Measure first, add complexity second. Don't add complexity based on anticipated future needs.

---

## Common Anti-Patterns

### Anti-Pattern 1: "Netflix/Google does it"

**Problem:** "Netflix uses microservices, so we should too"

**Reality:** Netflix has 1000s of engineers. You have 5. Context matters.

**Fix:** Choose technologies appropriate for your team size and scale.

---

### Anti-Pattern 2: "We might need to scale"

**Problem:** "We might get 1M users, so let's build for that now"

**Reality:** 95% of applications never reach high scale. Optimize for learning, not hypothetical scale.

**Fix:** Build for today's scale + 10×. Refactor when you actually hit limits.

---

### Anti-Pattern 3: "Resume-driven development"

**Problem:** "I want to learn Kafka, so let's use it"

**Reality:** Production systems should optimize for business value, not learning opportunities.

**Fix:** Learn new technologies in side projects. Use proven, simple technologies in production.

---

### Anti-Pattern 4: "Best practices require it"

**Problem:** "Best practices say we need comprehensive monitoring, so let's set up Datadog, Prometheus, Grafana, and PagerDuty"

**Reality:** Best practices are context-dependent. Small teams need different tools than large teams.

**Fix:** Start with simple logging. Add monitoring incrementally as needed.

---

Author: Eduardo Ferro
Source: https://www.eferro.net/

_These dimensions help you systematically challenge complexity and guide teams toward simple, safe, reversible solutions._
