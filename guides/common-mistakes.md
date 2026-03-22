# Common Mistakes

Anti-patterns that reduce Claude Code's effectiveness, waste tokens, or lead to frustrating results. Avoid these to get the most out of your workflow.

## Vague Prompts

The most common mistake. Vague prompts force Claude to guess your intent, explore broadly, and often produce results that miss the mark.

```
# Bad — vague, no direction
"fix the bug"
"make it better"
"refactor this"

# Good — specific, actionable
"fix the null reference error in src/auth/login.ts:42"
"improve the error messages in the validation module to include the field name"
"extract the database query logic from UserController into a UserRepository class"
```

The more specific your prompt, the fewer tokens Claude spends exploring and the better the result.

## Not Using CLAUDE.md

Without a CLAUDE.md file, Claude does not know your project's conventions. It will guess at coding style, test commands, linting rules, and architecture patterns — and often guess wrong.

**What happens without CLAUDE.md:**
- Claude uses generic conventions instead of your team's standards
- You repeat the same instructions every session
- Code style is inconsistent with the rest of your codebase

**Fix:** Create a CLAUDE.md at your project root. Even a minimal one helps enormously. See [CLAUDE.md Setup](./claude-md-guide.md) and the [minimal example](../examples/claude-md-minimal.md).

## Ignoring Plan Mode

For complex, multi-step tasks, jumping straight into implementation leads to wrong approaches and wasted effort. Plan mode lets Claude think through the approach before writing code.

```
# Risky for complex tasks — Claude may take a wrong turn
"refactor the authentication system to use JWT"

# Better — plan first, then execute
"plan how to refactor the authentication system to use JWT"
# Review the plan, then:
"looks good, go ahead and implement it"
```

Use plan mode for any task that touches more than 2-3 files or involves architectural decisions.

## Not Scoping Tasks

Asking Claude to do too much at once leads to context bloat, confusion, and errors. Large tasks should be broken into focused steps.

```
# Too broad — likely to go off track
"build a complete user management system with CRUD, roles, permissions, and an admin dashboard"

# Better — one piece at a time
"create the User model with fields for email, name, and role"
# Then: "add CRUD API endpoints for the User model"
# Then: "add role-based permission middleware"
```

Each focused task gets better results and costs fewer tokens.

## Running Without Context

Starting Claude Code and immediately asking about code without letting it understand your project first.

**Fix:** Let Claude read relevant files before asking it to modify them:

```
# Bad — Claude has no context
"fix the UserService"

# Good — provides context
"read src/services/UserService.ts and then fix the error handling in the create method"
```

Your CLAUDE.md file also provides automatic context. Use it.

## Over-Permissioning

Running Claude Code with all permissions allowed and never reviewing what it does. While Claude is careful by default, you should still review changes, especially for:

- Destructive operations (deleting files, dropping tables)
- Actions that affect shared systems (pushing code, creating PRs)
- Security-sensitive changes (auth logic, permissions, secrets handling)

**Fix:** Use a restrictive permission mode for sensitive projects. Review diffs before committing. Do not auto-approve everything.

## Not Using /compact

Letting conversations grow unbounded is one of the most expensive mistakes. Every message gets more expensive as context accumulates, and Claude's responses may degrade as context fills up.

**Fix:** Run `/compact` after completing each sub-task, or every 20-30 exchanges. See [Cost Management](./cost-management.md) for details.

## Trying to Do Everything in One Session

Marathon sessions of 100+ exchanges lead to context overflow, confusion, and high costs. Claude works best with focused sessions.

**Fix:**
- Start a new session for unrelated tasks
- Use `/compact` or `/clear` between phases of work
- Break large projects into multiple sessions with clear goals

## Not Reviewing Generated Code

Accepting Claude's output without reading it. Claude is highly capable but not infallible — especially for:

- Edge cases in business logic
- Security-sensitive code paths
- Complex state management
- Integration with systems Claude cannot access

**Fix:** Always read the diff before committing. Run tests. Check edge cases.

## Fighting the Tool Instead of Redirecting

When Claude takes a wrong approach, some users try to get it back on track with increasingly complex clarifications. It is often faster to interrupt and restart.

```
# If Claude is going down the wrong path:
[Press Escape]
"Stop. Use a different approach: instead of creating a new class, modify the existing UserService."
```

Or use `/clear` and start fresh with a better-scoped prompt.

## Anti-Pattern Summary

| Mistake | Fix |
|---------|-----|
| Vague prompts | Be specific about file, function, and intent |
| No CLAUDE.md | Create one — even a minimal version helps |
| Skipping plan mode | Plan first for complex, multi-file tasks |
| Too-broad tasks | Break into focused, single-concern steps |
| No context | Let Claude read files before modifying them |
| Over-permissioning | Review changes, use restrictive mode when needed |
| Skipping /compact | Compact after each sub-task |
| Marathon sessions | Fresh sessions for unrelated work |
| Not reviewing output | Always read the diff |

## See Also

- [CLAUDE.md Setup](./claude-md-guide.md) — set up project instructions properly
- [Cost Management](./cost-management.md) — avoid wasting tokens
- [Tips and Tricks](./tips-and-tricks.md) — shortcuts for more efficient workflows
- [Troubleshooting](./troubleshooting.md) — fixing problems when they occur
