# Cost Management

Claude Code consumes tokens with every interaction. Understanding how token usage works and applying a few habits can significantly reduce your spend without sacrificing productivity.

## Understanding Token Usage

Every message you send and every response Claude generates costs tokens. But the biggest driver of cost is **context size** — the accumulated conversation history that gets sent with each new message. As your conversation grows, each exchange becomes more expensive.

Key cost factors:
- **Conversation length** — longer sessions mean more tokens per message
- **File reads** — every file Claude reads adds to the context
- **Tool output** — command results, search results, and file contents all count
- **Model choice** — Opus costs more than Sonnet, which costs more than Haiku

## Use /compact Regularly

The `/compact` command summarizes your conversation history, dramatically reducing context size. This is the single most effective cost-saving habit.

```
# Compact with default summary
/compact

# Compact with a specific focus
/compact focus on the authentication refactor
```

**When to compact:**
- After completing a sub-task before moving to the next one
- When you notice responses slowing down
- Every 20-30 exchanges as a rule of thumb
- Before starting a new line of work in the same session

## Scope Your Tasks

Smaller, focused tasks cost less than broad, open-ended ones. Instead of asking Claude to "refactor the entire codebase," break it into specific pieces.

```
# Expensive — broad scope, lots of exploration
"Refactor all the API endpoints to use the new middleware"

# Cheaper — focused, specific
"Refactor the /users endpoint in src/routes/users.ts to use the new auth middleware"
```

## Use the Right Model for the Job

Not every task needs the most powerful model. Use `/model` to switch:

```
/model claude-haiku-4-5-20251001    # Simple tasks, quick questions
/model claude-sonnet-4-6            # Default, good balance
/model claude-opus-4-6              # Complex architecture, tricky bugs
```

**Good tasks for Haiku:** generating boilerplate, simple renames, formatting, straightforward questions about code.

**Worth using Opus for:** complex debugging, architectural decisions, multi-file refactors with subtle interactions.

## Efficient Prompting Patterns

How you write prompts affects how many tokens Claude uses exploring and responding.

**Be specific about what you want:**
```
# Vague — Claude explores broadly
"Fix the bug in the login page"

# Specific — Claude goes straight to the issue
"Fix the null pointer error in src/auth/login.ts:42 where user.email is accessed before the null check"
```

**Point Claude to the right files:**
```
# Let Claude search (costs tokens for tool calls)
"Find and fix the rate limiter"

# Direct Claude (saves exploration tokens)
"Fix the rate limiter in src/middleware/rateLimit.ts"
```

**Use CLAUDE.md to avoid repeating context** — instructions in CLAUDE.md are loaded once rather than typed every session. See [CLAUDE.md Setup](./claude-md-guide.md).

## Monitoring Spend

- Check your usage dashboard at the Anthropic Console or your IDE's billing page
- Track how many messages a task takes — if a simple task takes more than 10 exchanges, consider whether your prompts could be more specific
- Use `/cost` (if available) to see session token usage

## Quick Reference

| Strategy | Impact | Effort |
|----------|--------|--------|
| Use /compact regularly | High | Low |
| Scope tasks narrowly | High | Low |
| Use Haiku for simple work | Medium | Low |
| Be specific in prompts | Medium | Low |
| Use CLAUDE.md for context | Medium | One-time |
| Monitor usage | Low | Low |

## See Also

- [CLAUDE.md Setup](./claude-md-guide.md) — reduce repeated context with project instructions
- [Tips and Tricks](./tips-and-tricks.md) — more slash commands and efficiency techniques
- [Common Mistakes](./common-mistakes.md) — anti-patterns that waste tokens
