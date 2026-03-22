# Teams and Multi-Agent Workflows

Claude Code can orchestrate multiple agents working in parallel on different parts of a task. This is useful for large projects where work can be divided into independent subtasks that benefit from isolated context and simultaneous execution.

## When to Use Multi-Agent

Multi-agent workflows shine when:

- **Tasks are parallelizable.** Multiple files or features can be worked on independently.
- **The scope is large.** A single conversation would exhaust its context window before finishing.
- **Isolation matters.** Each agent works in its own git worktree, preventing merge conflicts.
- **Speed is important.** Three agents working in parallel finish faster than one working sequentially.

Avoid multi-agent for small tasks, tightly coupled changes, or work that requires constant coordination between agents.

## How It Works

The multi-agent system uses a lead-agent model:

1. **Team lead** — Coordinates work, creates tasks, assigns agents, reviews results.
2. **Teammate agents** — Independent Claude Code instances that each work on assigned tasks.
3. **Task system** — A shared task board that tracks what each agent is working on.

Each teammate runs in its own worktree (a separate working copy of the repository), so agents can edit files simultaneously without conflicts.

## Creating a Team

Use the `/teams` command or ask Claude to create a team for a large task:

```
Create a team to implement the new user dashboard. We need:
1. Backend API endpoints for user stats
2. Frontend React components for the dashboard
3. Database migrations for the new tables
4. Tests for all of the above
```

Claude will analyze the work, create a task breakdown, spin up teammate agents, and assign tasks.

## Task Coordination

Tasks are the central coordination mechanism. Each task has:

- **Subject** — What needs to be done
- **Description** — Detailed requirements and context
- **Status** — Pending, in progress, or completed
- **Owner** — Which agent is responsible
- **Dependencies** — Tasks that must finish first (blockedBy/blocks)

The team lead creates tasks and assigns them. Teammates pick up tasks, work on them, and mark them complete. The lead monitors progress and handles any issues.

## Worktrees for Isolation

Each teammate agent operates in its own git worktree, which is a separate checkout of the repository that shares the same git history. This means:

- Agents can edit the same files without conflicting
- Each agent has a clean working directory
- Changes are merged back through normal git workflows
- Worktrees are created automatically in `.claude/worktrees/`

## Spawning Subagents

Beyond full team workflows, you can use subagents for lighter-weight parallelism within a single conversation. Subagents are useful for:

- **Research tasks** — "Find all usages of this deprecated API"
- **Parallel exploration** — Investigating multiple potential solutions simultaneously
- **Context protection** — Heavy file reading stays in the subagent's context

Subagents differ from teammates in that they run within your current session and do not get their own worktree. They share your working directory but have their own context window.

## Communication Between Agents

Agents communicate through:

- **Task updates** — Marking tasks complete, adding descriptions
- **Direct messages** — Using SendMessage for coordination
- **Broadcasts** — Team-wide announcements (use sparingly)

The team lead sees all task updates and can redirect work as needed. Teammates should communicate blockers, questions, and completion status through the task system.

## Practical Example

A typical multi-agent session for adding a feature:

```
User: Add OAuth2 login with Google and GitHub providers.
       Use a team approach.

Lead creates:
  Task 1: Add OAuth2 configuration and provider abstraction (agent-1)
  Task 2: Implement Google OAuth provider (agent-2, blocked by Task 1)
  Task 3: Implement GitHub OAuth provider (agent-3, blocked by Task 1)
  Task 4: Add OAuth callback routes and session handling (agent-1, after Task 1)
  Task 5: Write integration tests (agent-2, after Tasks 2-4)
  Task 6: Update documentation (agent-3, after Tasks 2-4)
```

Agent-1 starts on the shared foundation. Once Task 1 completes, agents 2 and 3 work in parallel on their respective providers. Testing and docs follow.

## Tips

- **Keep tasks well-defined.** Each task should have clear inputs, outputs, and acceptance criteria.
- **Minimize dependencies.** The more tasks that can run in parallel, the faster the team finishes.
- **Let the lead handle merging.** The team lead is best positioned to resolve conflicts between agent outputs.
- **Use for big tasks only.** The overhead of team coordination is not worth it for tasks that take one agent under 10 minutes.
- **Check task status regularly.** Agents should update their task status so the lead can track progress and unblock others.

## See Also

- [Context Management](context-management.md) — Why subagents help preserve context
- [Getting Started](getting-started.md) — Setting up Claude Code before using teams
- [Hooks](hooks.md) — Automating actions across agent workflows
- [Prompt Tips](prompt-tips.md) — Writing clear task descriptions for agents
- [Team Setup](team-setup.md) -- Organizing team configurations
