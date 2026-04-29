# Performance Tuning

Claude Code offers multiple models, modes, and settings that affect speed, quality, and cost. This guide covers how to choose the right configuration for each task and keep your sessions efficient.

## Model Selection

Claude Code supports several models in the Claude family. Each trades off capability, speed, and cost differently.

| Model | Best For | Speed | Cost |
|-------|----------|-------|------|
| Claude Opus 4.7 | Complex architecture, multi-file refactors, subtle bugs | Slower | Highest |
| Claude Sonnet 4.6 | General development, code review, feature implementation | Balanced | Medium |
| Claude Haiku 4.5 | Quick questions, simple edits, formatting, boilerplate | Fastest | Lowest |

### When to Use Opus

Choose Opus for tasks where quality matters most:

- Designing system architecture across many files
- Debugging subtle concurrency or race condition issues
- Large-scale refactoring that requires understanding the full codebase
- Complex migration planning with many interdependencies

### When to Use Sonnet

Sonnet is the default and handles most development tasks well:

- Writing new features and implementing business logic
- Code review and PR feedback
- Writing and fixing tests
- General debugging with clear error messages

### When to Use Haiku

Use Haiku when speed matters more than depth:

- Generating boilerplate code
- Simple rename or formatting tasks
- Quick syntax questions
- Exploratory questions about your codebase

## Fast Mode

Toggle fast mode with `/fast` in any session. Fast mode uses the same model but optimizes for faster output. This is useful for:

- Rapid iteration on small changes
- Sessions where you are making many quick edits
- Tasks where waiting for output slows your flow

Fast mode does not reduce quality — it uses the same Claude Opus 4.7 model with faster output generation.

## The 1M Token Context Window (Opus 4.7)

As of v2.1.122, **Opus 4.7 supports a 1M token context window** by default on Max, Team, and Enterprise plans (previously this required extra usage). Sonnet and Haiku have smaller context windows and will hit compression sooner.

With Opus, you can work through large features, multi-file refactors, and extended debugging sessions without hitting context limits. However, larger context does not mean free -- every token in the window is sent with each new message, affecting both speed and cost.

**Performance implications at different context sizes (Opus):**
- Sessions under 200K tokens feel fast and responsive
- Sessions at 400K-600K tokens may start to feel noticeably slower
- Sessions approaching 1M tokens work but cost significantly more per exchange
- `/compact` remains your primary tool for keeping sessions lean and fast

**For Sonnet and Haiku users:** Context management is more important since you will hit compression earlier. Use `/compact` more frequently and keep sessions focused.

## Context Management for Performance

Long conversations slow Claude down and increase token costs. Opus's 1M limit gives you room to breathe, but keeping sessions lean still improves speed across all models:

### Use `/compact` Strategically

The `/compact` command compresses your conversation history while preserving key context. With Opus's 1M window, you no longer need to compact to survive -- but compact to **stay fast**. On Sonnet and Haiku, compacting also prevents hitting the smaller context ceiling:

- After finishing a subtask, before starting the next one
- When context exceeds ~200K tokens and responses feel slower
- When Claude seems to be losing track of earlier context
- When `/cost` shows spending climbing faster than expected

### Start Fresh for New Tasks

Use `/clear` or start a new `claude` session for unrelated tasks. A clean context means faster responses and more focused output.

### Write Good CLAUDE.md Files

Well-written CLAUDE.md files reduce the need for repeated explanations. Instead of telling Claude about your project structure every session, document it once:

```markdown
## Project Structure
- src/api/ — Express route handlers
- src/services/ — Business logic
- src/models/ — Sequelize models
- tests/ — Jest test files mirroring src/ structure
```

## Reducing Token Usage

Every token you send and receive costs money. These patterns reduce waste:

### Be Concise in Prompts

```bash
# Efficient: clear and brief
claude "Add input validation to the POST /users endpoint. Require email and name, both non-empty strings."

# Wasteful: verbose and repetitive
claude "I need you to please add some input validation to the users endpoint. The endpoint is POST /users and it should validate that the email field is present and is a non-empty string, and also that the name field is present and is a non-empty string as well."
```

### Avoid Re-reading Large Files

If Claude has already read a file in this session, it remembers the contents. Do not paste file contents that Claude can read with its tools.

### Scope Tasks Narrowly

```bash
# Efficient: targeted
claude "Fix the date parsing bug in src/utils/dates.ts line 42"

# Costly: broad
claude "Fix all the bugs in the project"
```

## Headless Mode Performance

In CI and automation, use headless mode (`-p` flag) for single-shot tasks:

```bash
# Fast: single prompt, no interactive overhead
claude -p "Generate TypeScript types from the OpenAPI spec at api/spec.yaml"

# Pipe input directly
cat error.log | claude -p "What caused this error?"
```

Headless mode skips the interactive session setup, saving time for automated workflows.

## Optimizing for Specific Workflows

### Code Review

For faster reviews, tell Claude what to focus on:

```bash
claude "Review this diff for security issues only. Skip style and formatting feedback."
```

### Batch Operations

Group related changes into one prompt instead of making many small requests:

```bash
# One prompt for all related changes
claude "Rename the User model to Account across the entire codebase: model, routes, tests, and types."

# Instead of separate prompts for each file
```

### Parallel Agents

For large tasks, Claude can spawn sub-agents that work in parallel. This is automatic for tasks like codebase exploration but you can encourage it:

```bash
claude "Search for all usages of the deprecated authenticate() function and update them to use verifySession() instead. Work on multiple files in parallel."
```

## Monitoring Performance

### Token Usage

Check your token consumption in the Claude Code dashboard or by watching the session output. If costs are high:

1. Use `/compact` more frequently
2. Switch to Haiku for simple tasks
3. Keep prompts focused and avoid restating context

### Response Time

If responses feel slow:

1. Toggle `/fast` mode
2. Check if your conversation is very long (use `/compact`)
3. Consider whether a lighter model would suffice
4. Ensure your network connection is stable

## See Also

- [Cost Management](cost-management.md) -- Detailed cost tracking and budgeting strategies
- [Context Management](context-management.md) -- Deep dive into managing conversation context
- [Tips and Tricks](tips-and-tricks.md) -- CLI flags and shortcuts for efficient workflows
- [CI and Automation](ci-and-automation.md) -- Performance considerations for headless and CI usage
