# Real-World Case Studies

Theory only takes you so far. This guide presents detailed walkthroughs of real-world tasks that developers accomplish with Claude Code -- large migrations, complex refactors, greenfield features, and production incident responses. Each case study shows the prompts used, the workflow followed, and the lessons learned.

## Case Study 1: Migrating a REST API to GraphQL

### Context

A Node.js backend with 45 REST endpoints, Express routing, and a PostgreSQL database. The team wanted to add a GraphQL layer while keeping REST endpoints working during the transition.

### Approach

**Phase 1 -- Schema generation (single prompt)**

```
Analyze all route handlers in src/routes/ and generate a GraphQL schema
that covers every endpoint. Group related endpoints into types. Write
the schema to src/graphql/schema.graphql.
```

Claude read every route handler, identified the request/response shapes, and generated a complete schema with types, queries, and mutations.

**Phase 2 -- Resolver scaffolding (multi-agent)**

```
Create a team to implement GraphQL resolvers. For each type in
src/graphql/schema.graphql, create a resolver file in src/graphql/resolvers/
that calls the existing service layer. Do not modify any existing code.
```

Three agents worked in parallel -- one on user-related resolvers, one on product resolvers, and one on order resolvers. Each agent reused the existing service functions, avoiding duplication.

**Phase 3 -- Integration and testing**

```
Add Apollo Server to the Express app alongside the existing REST routes.
Both should work simultaneously on different paths. Add integration tests
for every GraphQL query and mutation.
```

### Results

- 45 REST endpoints mapped to GraphQL in under 2 hours
- Zero changes to existing REST routes -- both APIs ran in parallel
- 93% test coverage on the new GraphQL layer

### Lessons learned

- Generating the schema first gave Claude a clear contract to implement against
- Using the existing service layer prevented the common mistake of reimplementing business logic
- Multi-agent was worth the overhead because resolver files were fully independent

## Case Study 2: Framework Migration -- CRA to Next.js

### Context

A React SPA built with Create React App, 120 components, client-side routing with React Router, and no server-side rendering. The goal was migrating to Next.js App Router.

### Approach

**Phase 1 -- Audit and plan**

```
Analyze this Create React App project. List every component, route, and
data-fetching pattern. Identify which components can become server components,
which must stay client components, and which routes need dynamic rendering.
Output a migration plan as a markdown file.
```

Claude produced a detailed migration plan categorizing every component. This plan became the reference document for the entire migration.

**Phase 2 -- File structure migration**

```
Migrate the routing structure from React Router to Next.js App Router.
Create the app/ directory with the correct folder-based routing. Move
page components but do not modify their internals yet. Keep the old
src/pages/ directory until we verify everything works.
```

**Phase 3 -- Component conversion (multi-agent)**

```
Create a team to convert components to Next.js patterns:
1. Convert data-fetching components to use server components with async/await
2. Add "use client" directive to components using hooks, event handlers, or browser APIs
3. Replace React Router's useNavigate/Link with Next.js navigation
4. Update all imports to reflect the new file structure
```

**Phase 4 -- Verification**

```
Run the Next.js dev server and verify every route renders correctly.
Fix any build errors or hydration mismatches. Run the existing test suite
and fix any broken tests.
```

### Results

- 120 components migrated, 73 converted to server components
- Build time dropped from 45s to 12s (with server components reducing client bundle)
- Existing tests required only import path updates

### Lessons learned

- The audit-first approach prevented surprises mid-migration
- Keeping old files until verification avoided the "half-broken" state
- Server component classification was the highest-value step -- Claude correctly identified 71 of 73 candidates

## Case Study 3: Debugging a Production Memory Leak

### Context

A Node.js API server showing steadily increasing memory usage, eventually triggering OOM kills every 18-24 hours. No obvious cause from manual code review.

### Approach

**Step 1 -- Triage**

```
Analyze the codebase for common Node.js memory leak patterns: unclosed
database connections, growing caches without eviction, event listener
accumulation, large closures in long-lived callbacks, and circular references.
Check every file in src/ and list any suspicious patterns with file:line references.
```

Claude identified three suspects: an in-memory cache in `src/services/cache.ts` with no TTL or max-size, event listeners being added but never removed in `src/websocket/handler.ts`, and a database connection pool that grew without bounds in `src/db/pool.ts`.

**Step 2 -- Targeted fix**

```
Fix the memory issues found:
1. Add LRU eviction with max 1000 entries and 5-minute TTL to the cache
2. Add proper cleanup in the WebSocket disconnect handler
3. Set max pool size to 20 and add idle connection cleanup
Write tests that verify each fix.
```

**Step 3 -- Verification**

```
Add a /debug/memory endpoint that reports process.memoryUsage() and
connection pool stats. This is for monitoring only -- protect it with
the existing admin auth middleware.
```

### Results

- Memory leak eliminated -- stable at ~180MB after 72-hour soak test
- Root cause was primarily the unbounded cache (accounting for ~80% of the leak)
- Total time from triage to fix: 35 minutes

### Lessons learned

- Asking Claude to check for specific patterns (not just "find the bug") produced actionable results
- The structured approach (triage, fix, verify) prevented premature optimization
- Adding the memory endpoint provided ongoing observability

## Case Study 4: Building a Feature From Scratch

### Context

Adding a notification system to a SaaS application: in-app notifications, email digests, and webhook delivery. The stack was Next.js, Prisma, and PostgreSQL.

### Approach

**Step 1 -- Architecture design using plan mode**

```
I need to add a notification system. Requirements:
- In-app notifications stored in the database
- Email digest (daily summary of unread notifications)
- Webhook delivery for integrations
- User preferences for notification channels

Use plan mode to design the architecture before implementing.
```

Claude produced a plan covering database schema, API routes, a background job system for email/webhooks, and a React component for the notification bell.

**Step 2 -- Implementation (multi-agent team)**

After approving the plan:

```
Implement the notification system using a team:
1. Database schema and Prisma migrations
2. API routes for CRUD operations and preferences
3. Background job system for email digests and webhook delivery
4. Frontend notification bell component and preferences UI
```

Four agents worked in parallel, with the schema agent completing first since others depended on it.

**Step 3 -- Integration testing**

```
Write end-to-end tests covering:
- Creating a notification and seeing it appear in the UI
- Marking notifications as read
- Email digest generation with correct content
- Webhook delivery with retry logic
- User preference changes affecting delivery channels
```

### Results

- Full notification system in approximately 3 hours of Claude Code time
- 14 new files, 2 Prisma migrations, 5 API routes, 3 React components
- 89% test coverage including webhook retry edge cases

### Lessons learned

- Plan mode was essential -- the initial design caught a missing database index that would have caused performance issues at scale
- Multi-agent worked well because each layer was independent after the schema was defined
- Asking for retry logic explicitly in the test prompt ensured Claude implemented it in the webhook delivery code

## Case Study 5: Legacy Codebase Modernization

### Context

A 5-year-old Express.js API with JavaScript (no TypeScript), callbacks (no async/await), and no test coverage. Goal: add TypeScript, modernize async patterns, and reach 70% test coverage.

### Approach

**Phase 1 -- TypeScript setup and initial conversion**

```
Set up TypeScript in this project. Add tsconfig.json with strict mode.
Rename all .js files to .ts. Fix type errors by adding type annotations
where needed. Do not change any runtime behavior -- this is a types-only pass.
```

**Phase 2 -- Async modernization (batched)**

```
Convert all callback-based code in src/services/ to async/await.
Work through one file at a time. After converting each file, run the
existing manual test to verify behavior is unchanged.
```

**Phase 3 -- Test coverage (multi-agent)**

```
Create a team to add test coverage across the codebase:
1. Unit tests for all service functions in src/services/
2. Integration tests for all route handlers in src/routes/
3. Test utilities: factories, fixtures, and database helpers
Target 70% overall coverage.
```

### Results

- 47 files converted from JavaScript to TypeScript
- 23 callback chains replaced with async/await
- Test coverage went from 0% to 74%
- Zero runtime behavior changes (verified by running the full test suite after each phase)

### Lessons learned

- Separating TypeScript conversion from async modernization prevented compounding errors
- The "types-only pass" instruction was critical -- it kept Claude from refactoring logic during conversion
- Building test utilities first (Phase 3, task 3) made the other test tasks faster

## Patterns Across Case Studies

Several patterns appear consistently in successful large-scale Claude Code tasks:

- **Audit first, act second.** Always start by having Claude analyze what exists before making changes.
- **Explicit constraints.** "Do not modify existing code" and "do not change runtime behavior" prevent scope creep.
- **Phased execution.** Break large tasks into phases where each phase is verifiable before moving on.
- **Multi-agent for independent work.** Use teams when tasks are truly independent; avoid them when work is tightly coupled.
- **Verification at every step.** Run tests, check builds, and inspect diffs between phases.

## See Also

- [Workflow Patterns](workflow-patterns.md) -- Common workflows for everyday tasks
- [Migration Guide](migration-guide.md) -- Detailed migration strategies
- [Multi-Agent](multi-agent.md) -- Teams and agent coordination
- [Debugging](debugging.md) -- Debugging strategies and fix-and-verify workflows
