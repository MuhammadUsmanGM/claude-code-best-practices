# Prompt Tips for Claude Code

The quality of Claude Code's output depends heavily on how you communicate your intent. This guide covers practical techniques for writing clear, effective prompts that get the results you want on the first try.

## Core Principles

### Be Specific

Vague prompts lead to vague results. Tell Claude exactly what you want.

| Instead of | Try |
|-----------|-----|
| "Fix the bug" | "Fix the null reference in `checkout.ts` when the cart is empty" |
| "Add tests" | "Add unit tests for the `UserService.create` method covering valid input, duplicate email, and missing fields" |
| "Make it faster" | "Optimize the `getProducts` query -- it's doing N+1 selects on the categories table" |
| "Clean up this file" | "Extract the validation logic in `handleSubmit` into a separate `validateFormData` function" |

### Provide Context

Claude can read your code, but it cannot read your mind. Share relevant context:

- **What you've already tried**: "I tried adding a null check but the error still occurs in production"
- **Why you want the change**: "We need to support multi-tenancy, so all queries should be scoped to the tenant ID"
- **Constraints**: "This runs on Node 16, so we can't use top-level await"
- **Expected behavior**: "The endpoint should return a 400 with a validation error, not a 500"

### Use Examples

When describing a pattern, show Claude a concrete example:

```
Add a new API endpoint for /api/orders similar to the existing /api/products endpoint.
It should follow the same pattern: route handler, service layer, Zod validation schema,
and Prisma query.
```

### Reference Specific Files and Lines

Claude works best when you point it to the right place:

```
In src/services/auth.ts around line 45, the refreshToken function doesn't handle
expired tokens. Add a check that returns a 401 if the token's exp claim is in the past.
```

## Prompt Patterns That Work Well

### The "Fix and Verify" Pattern

Ask Claude to fix something and confirm the fix works:

```
Fix the failing test in tests/user.test.ts. After fixing it, run the test suite
to make sure nothing else broke.
```

### The "Explore Then Act" Pattern

For unfamiliar codebases, explore first:

```
First, explain how the authentication flow works in this project. Then add
support for OAuth2 with Google, following the existing patterns.
```

### The "Scope Limitation" Pattern

Prevent Claude from making unwanted changes:

```
Refactor the error handling in src/api/handlers.ts to use a shared error
middleware. Don't change any other files.
```

### The "Plan First" Pattern

For complex tasks, ask Claude to plan before executing:

```
Plan how you would add WebSocket support to this Express app. List the files
you'd change and what each change would be. Don't make any changes yet.
```

You can also use plan mode explicitly: see [Permission Modes](permission-modes.md) for details.

## Iterating on Prompts

Not every prompt will produce the perfect result on the first try. Here's how to iterate:

- **Narrow the scope**: If Claude changed too much, say "Revert everything except the change to `auth.ts`"
- **Add constraints**: "Do this without adding any new dependencies"
- **Ask for alternatives**: "Show me a different approach that doesn't use recursion"
- **Redirect**: "That's not what I meant. I want the validation to happen on the client side, not the server"

## When to Use Plan Mode vs Direct Execution

| Scenario | Approach |
|----------|----------|
| Simple bug fix | Direct execution |
| Small feature addition | Direct execution |
| Large refactor across many files | Plan first, then execute |
| Unfamiliar codebase | Explore first, then plan, then execute |
| Architecture decision | Plan mode to evaluate options |
| Risky change (database migration, etc.) | Plan mode to review before applying |

## Common Prompt Mistakes

- **Too many tasks at once**: Break large requests into smaller, sequential steps.
- **Ambiguous pronouns**: Say "rename the `UserService` class" not "rename it".
- **Assuming Claude remembers**: If you start a new session, re-state critical context or rely on your CLAUDE.md.
- **Not reviewing output**: Always review Claude's changes before moving on. Catching issues early saves time.

## Advanced Techniques

### Chaining Commands with Pipes

Use shell pipes to feed context directly to Claude:

```bash
git diff HEAD~3 | claude -p "summarize these changes for a changelog entry"
cat error.log | claude -p "diagnose the root cause of this error"
```

### Using System Prompts for Repeated Tasks

If you run the same kind of prompt often, create a shell alias:

```bash
alias review='git diff --staged | claude -p "review these changes for bugs and style issues"'
```

### Referencing Previous Conversation

In an interactive session, Claude remembers the conversation so far. Build on earlier context:

```
> Explain the payment processing flow
(Claude explains)
> Now add retry logic to the charge step you just described
```

## See Also

- [CLAUDE.md Guide](claude-md-guide.md) -- Provide persistent context so prompts can be shorter
- [Workflow Patterns](workflow-patterns.md) -- Common development workflows
- [Permission Modes](permission-modes.md) -- Plan mode and execution modes
- [Workflow Patterns](workflow-patterns.md) -- Debugging and other development workflows
