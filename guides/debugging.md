# Debugging with Claude Code

Claude Code is an effective debugging partner. It can read stack traces, trace logic through your codebase, form hypotheses, and apply fixes — all within your terminal. This guide covers strategies for getting the best debugging results.

## Start with Context

The most important thing you can give Claude when debugging is a clear description of the problem. Include:

- **What you expected** to happen
- **What actually happened** (error message, wrong output, crash)
- **Steps to reproduce** if the bug is not obvious

```bash
# Good: specific and actionable
claude "The /api/users endpoint returns 500 when the email field contains a plus sign. Here's the error from the logs: [paste error]"

# Less effective: vague
claude "The API is broken"
```

## Debugging Strategies

### Paste the Error

The simplest approach — paste the full stack trace or error message directly into your prompt. Claude will read the referenced files, identify the root cause, and suggest a fix.

```bash
claude "I'm getting this error when running tests:

TypeError: Cannot read properties of undefined (reading 'map')
    at UserList (src/components/UserList.tsx:14:22)
    at renderWithHooks (node_modules/react-dom/...)

Fix this bug."
```

### Let Claude Investigate

For bugs without a clear error message, describe the symptom and let Claude explore:

```bash
claude "The search feature returns duplicate results when the query contains uppercase letters. Investigate and fix."
```

Claude will read the relevant code, trace the logic, and identify where the issue occurs. This works well because Claude can follow code paths across multiple files.

### Use Logs and Output

Pipe log output directly into Claude for analysis:

```bash
cat logs/error.log | claude "Analyze these logs and identify the root cause of the failures"
```

Or ask Claude to add logging to narrow down a problem:

```bash
claude "Add debug logging to the payment processing pipeline so we can trace where the order total becomes negative"
```

### Reproduce First

For intermittent bugs, ask Claude to write a reproduction:

```bash
claude "Users report that the cart sometimes shows stale prices after a product update. Write a test that reproduces this race condition."
```

A failing test makes the bug concrete and verifiable, and gives Claude a clear target for the fix.

## Debugging Workflows

### The Fix-and-Verify Loop

The most reliable debugging workflow:

1. **Describe the bug** with as much context as possible
2. **Let Claude investigate** the codebase and propose a fix
3. **Ask Claude to run the tests** to verify the fix works
4. **Review the changes** before committing

```bash
claude "Fix the bug where deleted users still appear in search results. Run the tests after fixing to make sure nothing else breaks."
```

### Bisecting with Claude

When you know a bug was introduced recently but not which commit:

```bash
claude "The login page broke sometime in the last week. Check the recent commits that touched auth-related files and identify which change introduced the regression."
```

### Debugging Performance Issues

Ask Claude to profile and analyze:

```bash
claude "The dashboard page takes 8 seconds to load. Profile the API calls and database queries to find the bottleneck."
```

Claude can add timing instrumentation, analyze query plans, and suggest optimizations.

## Working with Stack Traces

Claude excels at reading stack traces. For best results:

- **Paste the complete trace**, not just the error line
- **Include the language and framework** if not obvious from the trace
- **Mention what triggered the error** (which action, endpoint, or test)

## Debugging in Different Contexts

### Frontend Bugs

For UI issues, describe what you see:

```bash
claude "The modal closes immediately after opening on mobile Safari. It works fine on Chrome desktop. The modal component is in src/components/Modal.tsx."
```

### API and Backend Bugs

Include the request, response, and expected behavior:

```bash
claude "POST /api/orders with this payload returns 422 but should succeed: {\"items\": [{\"id\": 1, \"qty\": 2}]}. The validation error says 'price is required' but price should come from the database."
```

### Database Issues

Provide the query or migration context:

```bash
claude "This query returns wrong results after we added the soft-delete column. Fix the query to exclude deleted records: SELECT * FROM orders WHERE user_id = $1"
```

## Tips for Effective Debugging

- **One bug at a time.** Do not ask Claude to fix multiple unrelated bugs in one prompt. Start a new conversation or use `/clear` between bugs.
- **Share the error, not your guess.** Let Claude form its own hypothesis from the evidence. Saying "I think the bug is in X" can bias the investigation.
- **Ask for tests.** After a fix, ask Claude to add a test that would catch the same bug if it regresses.
- **Use headless mode for CI debugging.** Pipe CI logs into Claude to diagnose build failures: `cat ci-output.log | claude -p "Why did this build fail?"`
- **Check related code.** Ask Claude to verify that similar patterns elsewhere do not have the same bug.

## See Also

- [Workflow Patterns](workflow-patterns.md) -- General development workflows including bug-fix patterns
- [Testing Workflows](testing-workflows.md) -- Writing tests to verify fixes and prevent regressions
- [Prompt Tips](prompt-tips.md) -- Crafting effective prompts for debugging sessions
- [Context Management](context-management.md) -- Keeping debugging sessions focused
