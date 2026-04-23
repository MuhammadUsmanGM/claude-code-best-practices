# Workflow Patterns

Claude Code adapts to many development workflows. This guide covers common patterns for everyday tasks -- from fixing bugs to reviewing pull requests -- along with the prompts and strategies that make each workflow effective.

## Bug Fixing

A typical bug-fixing session follows a predictable flow: reproduce, locate, fix, verify.

### Step-by-step approach

1. **Describe the symptom**: Give Claude the error message, stack trace, or unexpected behavior.
2. **Ask Claude to locate the cause**: "Find where this error originates and explain why it happens."
3. **Fix and verify**: "Fix the issue and run the tests to confirm."

### Example session

```text
> Here's the error from production: "TypeError: Cannot read property 'email' of undefined"
  in src/services/notification.ts:42. The user object is sometimes null when a
  guest checks out. Fix this so guests don't trigger email notifications.
```

### Tips

- Paste the full stack trace when available -- Claude uses it to locate the code path.
- Ask Claude to check for similar bugs elsewhere: "Are there other places where we access `user.email` without a null check?"
- Have Claude write a regression test for the fix.

## Feature Development

For new features, the explore-plan-implement-test cycle works best.

### Workflow

1. **Explore**: "How does the current notification system work?"
2. **Plan**: "Plan how to add SMS notifications alongside the existing email system."
3. **Implement**: "Implement the plan. Start with the SMS service class."
4. **Test**: "Write tests for the SMS notification service."
5. **Review**: "Review all the changes we made and check for any issues."

### Tips

- Break large features into smaller pieces and implement them one at a time.
- Ask Claude to follow existing patterns: "Follow the same structure as `EmailService`."
- Commit incrementally: ask Claude to commit after each logical piece is done.

## Refactoring

Refactoring benefits from Claude's ability to make consistent changes across many files.

### Common refactoring tasks

```text
# Extract a function
"Extract the validation logic from handleSubmit into a validateOrder function"

# Rename across codebase
"Rename the UserManager class to UserService across all files"

# Change patterns
"Convert all callback-based functions in src/utils/ to use async/await"

# Consolidate duplicates
"The pagination logic is duplicated in ProductList, OrderList, and UserList.
 Extract it into a shared usePagination hook."
```

### Tips

- Run the test suite after refactoring to catch regressions.
- Ask Claude to make refactoring changes in small, reviewable increments.
- Use plan mode for large refactors to review the scope before executing.

## Debugging

When you don't know what's wrong, Claude can help investigate systematically.

### Diagnostic workflow

```text
> The /api/orders endpoint returns a 500 error intermittently. Help me debug this.
  Here are the recent logs: [paste logs]
```

Claude will typically:

1. Analyze the logs for patterns
2. Read the relevant code
3. Identify potential causes
4. Suggest and apply fixes

### Adding debug instrumentation

```text
> Add logging to the order processing pipeline so we can trace where requests fail.
  Use our existing logger (src/lib/logger.ts). Don't change any business logic.
```

## PR Review

Claude can review code changes and provide feedback before you submit a pull request.

### Review your own changes

```bash
git diff main | claude -p "Review these changes. Look for bugs, edge cases,
security issues, and style problems. Be specific about what to fix."
```

### Review someone else's PR

```bash
gh pr diff 123 | claude -p "Review this PR. Focus on correctness and whether
the approach is sound. List any concerns."
```

### Pre-commit review

```bash
git diff --staged | claude -p "Any issues with these staged changes?"
```

## Code Exploration

Claude excels at helping you understand unfamiliar code.

### Understanding a new codebase

```text
> Give me a high-level overview of this project's architecture.
> How does the authentication flow work end to end?
> What happens when a user submits an order? Trace the request path.
```

### Investigating specific code

```text
> Explain what src/middleware/rateLimit.ts does and why it's structured this way.
> What are all the places where we interact with the payments API?
```

## Git Workflows

Claude can handle many Git operations directly.

### Common Git tasks

```text
# Create a well-structured commit
"Commit the current changes with a descriptive message"

# Interactive rebase help
"Squash the last 3 commits into one with a clean message"

# Branch management
"Create a feature branch from main called feature/sms-notifications"

# Resolve conflicts
"Help me resolve the merge conflicts in src/services/order.ts"
```

## Combining Workflows

Real-world tasks often combine several patterns. For example, a typical feature request might look like:

1. Explore the existing code to understand the current behavior
2. Plan the implementation approach
3. Implement the changes incrementally
4. Write tests for the new functionality
5. Review all changes for correctness
6. Commit with a clear message

Claude handles this naturally in a single interactive session -- just guide it through each step.

## See Also

- [Prompt Tips](prompt-tips.md) -- Craft effective prompts for each workflow
- [Permission Modes](permission-modes.md) -- Use plan mode for complex workflows
- [Context Management](context-management.md) -- Managing context for multi-file work
- [Git Workflow](git-workflow.md) -- Commits, PRs, and branch management
- [Debugging](debugging.md) -- Dedicated debugging strategies and workflows
- [Testing Workflows](testing-workflows.md) -- TDD, test coverage, and fixing flaky tests
- [Case Studies](case-studies.md) -- Real-world walkthroughs of complete workflows
