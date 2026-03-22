# Git Workflow

Claude Code integrates tightly with Git, handling commits, pull requests, branch management, and code review. This guide covers how to use Claude Code effectively for your Git workflow.

## Committing Changes

Claude Code writes excellent commit messages by analyzing staged changes. Simply ask it to commit:

```
"commit these changes"
"commit with a message about the auth fix"
```

Claude will:
1. Run `git diff` to understand what changed
2. Draft a commit message summarizing the "why" not just the "what"
3. Stage relevant files and create the commit

**Tips for better commits:**
- Make focused changes before committing — Claude writes better messages for cohesive changesets
- Tell Claude the intent if it is not obvious from the diff: "commit — this fixes the race condition in the queue processor"
- Claude follows conventional commit style if your CLAUDE.md specifies it

```markdown
# In your CLAUDE.md
## Git conventions
- Use conventional commits: feat:, fix:, chore:, docs:
- Keep subject line under 72 characters
```

## Creating Pull Requests

Ask Claude to create a PR and it will analyze all commits on your branch, write a title and description, and use the `gh` CLI:

```
"create a PR for this branch"
"open a pull request targeting the develop branch"
```

Claude generates a PR with:
- A concise title (under 70 characters)
- A summary section with bullet points
- A test plan section

You can guide the PR content:

```
"create a PR — mention that this is a breaking change for the v2 API"
```

## Branch Management

Claude can create and switch branches:

```
"create a branch called feature/user-settings"
"switch to the main branch"
"create a new branch for this bugfix"
```

For feature work, a good pattern is:

```
"create a branch called fix/login-null-check, fix the bug in login.ts:42, then commit and create a PR"
```

## Reviewing Pull Requests

Claude can review PRs by reading the diff and providing feedback:

```
"review PR #42"
"review the changes in this PR and look for security issues"
```

You can also point Claude at a GitHub URL:

```
"review https://github.com/org/repo/pull/42"
```

Claude will examine the diff, check for bugs, security issues, style problems, and provide specific feedback with file and line references.

## Resolving Merge Conflicts

When you hit merge conflicts, Claude can help resolve them:

```
"resolve the merge conflicts in src/auth.ts"
"I have merge conflicts after rebasing — help me resolve them"
```

Claude will:
1. Read the conflicting files
2. Understand both sides of the conflict
3. Produce a resolution that preserves the intent of both changes
4. Explain what it chose and why

**Important:** Always review conflict resolutions before committing. Claude does well with straightforward conflicts but complex semantic conflicts may need your judgment.

## Best Practices

**Keep commits atomic.** Ask Claude to commit after each logical change rather than batching unrelated work:

```
"commit the database migration separately from the API changes"
```

**Use CLAUDE.md for Git conventions.** If your team has specific branch naming, commit message, or PR conventions, document them:

```markdown
# Git workflow
- Branch naming: feature/, fix/, chore/
- Always rebase onto main before creating a PR
- PR descriptions must reference the Jira ticket
```

**Review before pushing.** Claude will not push to a remote unless you explicitly ask. Use this as a checkpoint:

```
"show me what will be pushed"
"diff against origin/main"
```

**Do not force-push to shared branches.** Claude will warn you if you attempt to force-push to main or master. Listen to the warning.

## Common Git Tasks — Quick Reference

| Task | Prompt |
|------|--------|
| Commit staged changes | "commit these changes" |
| Commit with context | "commit — this fixes the timeout bug" |
| Create a PR | "create a PR" |
| Create a PR to specific base | "create a PR targeting develop" |
| Review a PR | "review PR #42" |
| Resolve conflicts | "resolve merge conflicts" |
| Check what will be pushed | "diff against origin/main" |
| Amend last commit | "amend the last commit with these changes" |

## See Also

- [CLAUDE.md Setup](./claude-md-guide.md) — define Git conventions for your project
- [Tips and Tricks](./tips-and-tricks.md) — slash commands and shortcuts
- [Common Mistakes](./common-mistakes.md) — Git-related anti-patterns to avoid
- [Cost Management](./cost-management.md) — scoping commits to save tokens
