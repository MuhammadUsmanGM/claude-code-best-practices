# Cost Management

Claude Code consumes tokens with every interaction. Understanding how token usage works and applying a few habits can significantly reduce your spend without sacrificing productivity.

## Understanding Token Usage

Every message you send and every response Claude generates costs tokens. But the biggest driver of cost is **context size** — the accumulated conversation history that gets sent with each new message. As your conversation grows, each exchange becomes more expensive.

With v2.1.92, **Opus 4.6 now supports a 1M token context window** by default on Max, Team, and Enterprise plans. This lets you sustain much longer sessions when using Opus, which is great for productivity but means a single extended session can accumulate significant cost if you are not mindful. Sonnet and Haiku have smaller context windows, so context management is even more important with those models.

Key cost factors:
- **Conversation length** — longer sessions mean more tokens per message (a 500K-token Opus session sends 500K tokens with every new exchange)
- **File reads** — every file Claude reads adds to the context
- **Tool output** — command results, search results, and file contents all count
- **Model choice** — Opus costs more than Sonnet, which costs more than Haiku

## Track Your Actual Spend

Before optimizing, know what you are spending. Use these methods to get real numbers:

### Session-Level Tracking

Use `/cost` during a session to see how many tokens you have used and what it costs. Check this periodically to build intuition about which tasks are expensive.

### Dashboard Monitoring

Check the [Anthropic Console](https://console.anthropic.com/) for daily and monthly usage breakdowns. Look at:

- **Daily spend trend** — is it climbing or stable?
- **Per-model breakdown** — how much goes to Opus vs Sonnet vs Haiku?
- **Peak usage days** — what tasks drove the spikes?

### Setting Budget Alerts

Set spending limits in the Anthropic Console to avoid surprises. Start with a daily cap that matches your expected usage, then adjust after a week of real data.

## The Model Selection Rule of Thumb

Pick the cheapest model that gets the job done:

| Task Type | Recommended Model | Why |
|-----------|------------------|-----|
| Quick questions, boilerplate, renames | Haiku | Fast, cheap, good enough |
| Feature implementation, code review, tests | Sonnet | Best balance of quality and cost |
| Complex multi-file refactors, subtle bugs, architecture | Opus | Worth the premium for hard problems |

Switch models mid-session with `/model`:

```
/model claude-haiku-4-5-20251001    # Drop to Haiku for simple tasks
/model claude-sonnet-4-6            # Back to Sonnet for real work
/model claude-opus-4-6              # Upgrade for the hard part
```

Most developers find that **80% of their work is Sonnet-appropriate.** Reserve Opus for the 10-20% that actually needs it.

## Use /compact — Your Biggest Cost Lever

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
- When `/cost` shows context growing beyond 200K tokens and you are doing routine work
- Before starting a new line of work in the same session

**What it saves:** A long Opus session can accumulate 300K-500K tokens of context. Compacting cuts this to 5-10K, meaning every subsequent message costs a fraction of what it would otherwise. With Opus 4.6's 1M token window on Max/Team/Enterprise, you will not _need_ to compact to avoid hitting the ceiling -- but you should still compact to **control costs**. A message at 500K context costs 50x more than one at 10K context. On Sonnet and Haiku, compacting also helps avoid hitting their smaller context limits.

## One Task Per Session

Start a new `claude` session for each distinct task. A session about "fix the login bug" should not continue into "now add the search feature." Each new topic inherits all the context from the previous one, inflating costs for no benefit.

```bash
# Task 1: fix the bug
claude "Fix the null check in auth.ts:42"
# Done. Exit.

# Task 2: new feature (fresh session, clean context)
claude "Add full-text search to the /products endpoint"
```

Use `--resume` only when you genuinely need to continue previous work.

## Scope Your Tasks

Smaller, focused tasks cost less than broad, open-ended ones. Instead of asking Claude to "refactor the entire codebase," break it into specific pieces.

```
# Expensive — broad scope, lots of exploration
"Refactor all the API endpoints to use the new middleware"

# Cheaper — focused, specific
"Refactor the /users endpoint in src/routes/users.ts to use the new auth middleware"
```

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

**Use CLAUDE.md to avoid repeating context** — instructions in CLAUDE.md are loaded once rather than typed every session. See [CLAUDE.md Guide](claude-md-guide.md).

## Daily Spend Patterns

To get a feel for realistic usage, track your own spend for a week. Most developers fall into one of these patterns:

- **Light usage** (exploration, questions, small fixes): primarily Haiku/Sonnet, low context accumulation
- **Moderate usage** (feature development, code review): Sonnet with occasional Opus, regular compacting
- **Heavy usage** (full-day pair programming, large refactors): mixed models, aggressive compacting, multiple sessions

The key variable is not which model you use — it is **how long your conversations get**. A 50-message Sonnet session costs more than a 5-message Opus session.

## Cost Reduction Checklist

| Strategy | Impact | Effort |
|----------|--------|--------|
| Use `/compact` every 15-20 messages | High | Low |
| Start fresh sessions per task | High | Low |
| Scope tasks narrowly | High | Low |
| Use Haiku for simple work | Medium | Low |
| Be specific in prompts (include file paths) | Medium | Low |
| Use CLAUDE.md for persistent context | Medium | One-time |
| Set budget alerts in the Console | Medium | One-time |
| Check `/cost` periodically | Low | Low |

## See Also

- [Performance Tuning](performance-tuning.md) — Model selection and speed optimization in depth
- [CLAUDE.md Guide](claude-md-guide.md) — Reduce repeated context with project instructions
- [Context Management](context-management.md) — Deep dive into managing conversation context
- [Tips and Tricks](tips-and-tricks.md) — More slash commands and efficiency techniques
- [Common Mistakes](common-mistakes.md) — Anti-patterns that waste tokens
