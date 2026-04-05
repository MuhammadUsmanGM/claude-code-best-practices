# Advanced Architecture with Claude

Claude Code is not just a code writer -- it is a capable design partner for system architecture. This guide covers how to use Claude Code for designing systems, planning large features, evaluating trade-offs, and making architectural decisions that hold up over time. The key is plan mode, structured prompting, and iterative refinement.

## Plan Mode for Architecture

Plan mode is your primary tool for architectural work. It forces a design-first approach: Claude explores the codebase, proposes an architecture, and waits for your approval before writing any code.

### Entering plan mode

```
/plan
```

Or ask Claude to plan directly:

```
I need to add real-time notifications to the app. Use plan mode to
design the architecture before implementing anything.
```

### What makes plan mode effective for architecture

- Claude reads your existing code before proposing changes
- You see the full plan and can reject, modify, or redirect before any code is written
- The plan serves as documentation of the architectural decision
- It prevents the common failure mode of Claude writing code that does not fit the existing patterns

## Designing Systems From Scratch

When building a new system or major feature, give Claude the full context and constraints:

### Good architecture prompt

```
Design a job queue system for this application. Requirements:
- Process background tasks (email sending, report generation, webhook delivery)
- At-least-once delivery guarantee
- Retry with exponential backoff
- Dead letter queue for permanently failed jobs
- Dashboard to monitor queue depth and failure rates

Constraints:
- Must use PostgreSQL (no Redis or external queue services)
- Must integrate with the existing Prisma schema
- Workers run as separate processes, not in the web server

Design the schema, worker architecture, and API surface. Do not
implement yet.
```

### What to include in architecture prompts

| Element | Why it matters |
|---------|---------------|
| **Requirements** | What the system must do -- functional behavior |
| **Constraints** | What it cannot do or must use -- limits the solution space |
| **Non-functional requirements** | Performance targets, scaling needs, SLAs |
| **Integration points** | How it connects to existing code |
| **What NOT to do** | Prevents Claude from over-engineering |

### What to leave out

Do not over-specify the solution. Let Claude propose the architecture:

- Do not dictate class names or file structures (unless you have strong conventions)
- Do not specify implementation details like "use a factory pattern"
- Do not constrain technology choices unless you have real constraints

## Evaluating Trade-offs

Claude can analyze multiple approaches and present trade-offs. This is especially useful when you are unsure which direction to take.

```
I need to implement caching for our API responses. Compare these approaches:
1. In-memory cache (node-cache or Map)
2. Redis
3. HTTP cache headers (CDN-based)

For each approach, analyze: implementation complexity, cache invalidation
strategy, behavior under horizontal scaling, cost, and failure modes.
Recommend the best fit for our current setup.
```

Claude will analyze your codebase to understand the current setup (single instance vs. multi-instance, existing infrastructure, data mutation patterns) and recommend accordingly.

### Structured comparison prompt

```
We need to choose a state management approach for the new dashboard.
Options: React Context, Zustand, Redux Toolkit.

Evaluate each against:
- Bundle size impact
- Learning curve for our team (we currently use useState/useContext)
- DevTools and debugging experience
- Compatibility with our existing patterns in src/hooks/
- Effort to migrate later if we outgrow it

Present as a comparison table with a recommendation.
```

## Incremental Architecture

Most architecture work is not greenfield. It is evolving existing systems to handle new requirements. Claude excels at this when you frame the problem correctly.

### Extending an existing system

```
Our current auth system uses JWT tokens with 1-hour expiry. We need to add:
- Refresh tokens with rotation
- Session revocation (admin can kill a user's sessions)
- Multi-device session tracking

Review the current auth implementation in src/auth/ and design the changes
needed. Minimize disruption to existing code. Show which files change and
which are new.
```

### Decomposing a monolith

```
The user service in src/services/user.ts has grown to 800 lines and handles
user CRUD, authentication, profile management, preferences, and notification
settings. Design a decomposition that separates these concerns while keeping
the existing API routes working. Show the new file structure and the migration
path from current state to target state.
```

### Identifying architectural debt

```
Analyze the codebase for architectural issues. Look for:
- God objects (classes/modules doing too many things)
- Circular dependencies between modules
- Inconsistent data access patterns (some code goes through services,
  some queries the database directly)
- Missing abstraction layers

List each issue with file:line references and suggest the fix.
```

## Multi-Agent Architecture Work

For large architectural tasks, use multi-agent teams where each agent focuses on a different layer:

```
Create a team to design and implement the new reporting system:
1. Agent 1: Database schema design -- new tables, indexes, and migrations
2. Agent 2: API layer -- endpoints, request/response contracts, pagination
3. Agent 3: Background processing -- report generation workers, scheduling
4. Agent 4: Frontend -- report builder UI, chart components, export
```

The team lead coordinates to ensure the layers align on contracts (API shapes, database schema, event formats) before agents implement their parts independently.

### When to use multi-agent for architecture

- The system has clearly separable layers or modules
- Each layer can be designed and implemented independently
- The work would take too long for a single conversation

### When NOT to use multi-agent

- The architecture requires tight coordination between components
- You are still in the design phase and the interfaces are not defined
- The task is primarily about refactoring interconnected code

## Architecture Decision Records

Use Claude to generate Architecture Decision Records (ADRs) as you make decisions:

```
Write an ADR for our decision to use PostgreSQL advisory locks for the
job queue instead of Redis. Include the context, the options we considered,
the decision, and the consequences. Follow the format in docs/adr/.
```

This creates a paper trail of why architectural decisions were made, which is invaluable when onboarding new team members or revisiting decisions later.

## Patterns for Large Feature Planning

### The three-pass approach

1. **Pass 1 -- Scope definition.** Ask Claude to analyze requirements and identify unknowns.
2. **Pass 2 -- Architecture design.** With unknowns resolved, design the system in plan mode.
3. **Pass 3 -- Implementation plan.** Break the approved design into ordered, parallelizable tasks.

### Scope definition prompt

```
I want to add multi-tenancy to this SaaS application. Before designing
anything, analyze the current codebase and list:
1. Every place where data is currently unscoped (accessible across tenants)
2. Every database query that would need tenant filtering
3. External integrations that would need tenant context
4. Potential approaches to tenant isolation (row-level, schema-level, database-level)
```

### Implementation plan prompt

```
Based on the approved architecture, create a phased implementation plan:
- Phase 1: What must be done first (dependencies for everything else)
- Phase 2: What can be done in parallel after Phase 1
- Phase 3: Integration, testing, and migration

For each phase, list specific tasks with estimated complexity (small/medium/large).
```

## Common Architectural Mistakes to Avoid

- **Skipping the audit.** Never let Claude design a system without first reading the existing code. Always start with exploration.
- **Over-specifying the solution.** Give Claude the problem and constraints, not the answer. You hired a design partner, not a typist.
- **Ignoring plan mode feedback.** If Claude's plan raises concerns about your approach, listen. It has read your entire codebase.
- **Designing in one shot.** Complex architectures need iteration. Review the first plan, give feedback, and refine.
- **No verification step.** Always include a phase for testing the architecture against real usage patterns before building the full system.

## See Also

- [Workflow Patterns](workflow-patterns.md) -- Everyday workflow patterns
- [Multi-Agent](multi-agent.md) -- Teams and agent coordination for large tasks
- [Context Management](context-management.md) -- Keeping architectural discussions focused
- [Custom Instructions](custom-instructions.md) -- Setting up architect personas in CLAUDE.md
