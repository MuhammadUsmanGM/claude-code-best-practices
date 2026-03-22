# Managing the Context Window

Claude Code operates within a finite context window. How you manage that window directly affects response quality, speed, and cost. This guide covers strategies for keeping context focused and knowing when to start fresh.

## How Context Works

Every message you send, every file Claude reads, and every tool result occupies tokens in the context window. As the conversation grows, older messages get compressed automatically. Understanding this lifecycle helps you work more effectively:

1. **Fresh context** — Early in a conversation, Claude has full access to everything discussed.
2. **Compression** — As the window fills, the system summarizes older messages to make room.
3. **Degradation** — After heavy compression, nuance from earlier exchanges may be lost.

## The /compact Command

Use `/compact` to manually trigger context compression before hitting limits. This is useful when:

- You have finished one subtask and are moving to another
- The conversation has accumulated a lot of tool output you no longer need
- You notice responses slowing down or becoming less accurate

You can also pass a prompt to `/compact` to guide what gets preserved:

```
/compact focus on the database migration work
```

This tells the compressor to prioritize retaining information about database migrations while aggressively summarizing everything else.

## Scoping Tasks Narrowly

The single most effective context management strategy is keeping tasks small. Instead of asking Claude to "refactor the entire authentication system," break it into focused requests:

- "Refactor the password hashing in `auth/hash.ts`"
- "Update the session middleware to use the new token format"
- "Add tests for the refreshToken endpoint"

Each focused task uses less context, produces better results, and is easier to review.

## Using Subagents to Protect Context

When you need to explore the codebase or research a question, subagents run in their own context window. The main conversation only receives a summary of their findings. This is valuable when:

- **Exploring unfamiliar code** — A subagent can read dozens of files without polluting your main context.
- **Running broad searches** — Grep and glob results from a subagent stay contained.
- **Parallel investigation** — Multiple subagents can research different aspects simultaneously.

Claude Code automatically uses subagents for deep exploration tasks. You can encourage this by framing requests as research:

```
Find all the places where we handle authentication errors
and summarize the patterns used.
```

## When to Start Fresh

Start a new conversation when:

- You are switching to a completely unrelated task
- The conversation has gone through multiple rounds of compression
- Claude starts "forgetting" decisions made earlier in the conversation
- You have accumulated more than ~50 back-and-forth exchanges

There is no penalty for starting fresh. Claude reads your `CLAUDE.md` and project files at the start of every conversation, so project context is always available.

## Practical Tips

- **Front-load important information.** Put critical constraints and requirements in your first message or in `CLAUDE.md` so they survive compression.
- **Use CLAUDE.md for durable context.** Anything Claude needs to remember across conversations belongs in `CLAUDE.md`, not in chat.
- **Avoid pasting large files into chat.** Let Claude read files with tools instead — the content can be compressed more effectively than inline text.
- **Review what Claude remembers.** If you suspect context loss, ask "What do you remember about X?" to check before continuing.
- **One concern per conversation.** Mixing bug fixes, feature work, and refactoring in one session wastes context on task-switching overhead.

## How Context Compression Works

When the context window approaches its limit, the system automatically:

1. Identifies older message pairs (your message + Claude's response)
2. Summarizes them into compact representations
3. Replaces the originals with summaries
4. Preserves the most recent messages in full

The compression is lossy — specific code snippets, exact line numbers, and nuanced decisions may be simplified. This is why keeping tasks focused matters: less to compress means less information lost.

## See Also

- [Getting Started](getting-started.md) — Initial setup and configuration basics
- [CLAUDE.md Guide](claude-md-guide.md) — Storing durable project context
- [Multi-Agent](multi-agent.md) — Using subagents for context isolation
- [Prompt Tips](prompt-tips.md) — Writing effective prompts within context constraints
