# Permission Modes

Claude Code operates within a permission system that controls which tools and actions it can take without asking for approval. Understanding these modes lets you balance safety with speed depending on your task and comfort level.

## Overview

By default, Claude Code asks for your approval before performing actions that modify files, run commands, or interact with external services. You can adjust these permissions to be more restrictive (plan mode) or more permissive (allowlisted tools, or the fully autonomous mode).

## Default Mode

In the default interactive mode, Claude Code will:

- **Automatically allow**: Reading files, searching code, listing directories
- **Ask permission for**: Writing/editing files, running shell commands, making Git operations

Each time Claude wants to perform a restricted action, you see a prompt:

```
Claude wants to edit src/services/auth.ts
[Allow] [Deny] [Allow All]
```

- **Allow**: Approve this single action.
- **Deny**: Reject the action. Claude will adjust its approach.
- **Allow All**: Allow this type of action for the rest of the session.

### When to use

Default mode is ideal for most development tasks. It gives you full visibility into what Claude is doing while still being efficient for standard workflows.

## Plan Mode

Plan mode prevents Claude from making any changes. It can only read code and propose a plan.

### Activating plan mode

Start a session in plan mode:

```bash
claude --plan
```

Or switch to plan mode during a session by typing:

```
/plan
```

Switch back to normal mode with:

```
/execute
```

### What Claude can do in plan mode

- Read and analyze files
- Search the codebase
- Propose changes (without applying them)
- Outline implementation steps

### What Claude cannot do in plan mode

- Edit or create files
- Run shell commands
- Make Git commits
- Execute any side effects

### When to use

- **Large refactors**: Review the plan before Claude touches dozens of files.
- **Unfamiliar codebases**: Explore and understand before making changes.
- **Architecture decisions**: Have Claude analyze trade-offs without committing to an approach.
- **Risky operations**: Database migrations, dependency changes, or security-sensitive code.
- **Learning**: Understand how Claude would approach a problem without modifying anything.

## Allowlisted Tools

You can pre-approve specific tools so Claude doesn't ask permission each time.

### Via CLI flags

```bash
claude --allowedTools "Edit,Write,Bash(npm test)"
```

This allows Claude to edit files, write new files, and run `npm test` without asking, while still requiring permission for other commands.

### Via CLAUDE.md

Add an `allowedTools` section to your project's CLAUDE.md or settings:

```json
{
  "permissions": {
    "allow": [
      "Edit",
      "Write",
      "Bash(npm test)",
      "Bash(npm run lint)"
    ]
  }
}
```

### Common allowlist patterns

| Pattern | Effect |
|---------|--------|
| `Edit` | Allow all file edits |
| `Write` | Allow creating new files |
| `Bash(npm test)` | Allow running `npm test` only |
| `Bash(git status)` | Allow checking git status |
| `Bash(npx prettier --write *)` | Allow formatting |

### When to use

Allowlisting is ideal when you trust Claude with routine operations but want guardrails on potentially destructive actions. It removes friction for common tasks while keeping you in control.

## Dangerously Skip Permissions

This mode disables all permission checks. Claude can read, write, execute, and commit without any prompts.

```bash
claude --dangerously-skip-permissions
```

### Risks

- Claude can run arbitrary shell commands without confirmation.
- Files can be overwritten or deleted without prompting.
- Git commits and pushes happen automatically.
- No opportunity to review changes before they are applied.

### When to use

- **CI/CD pipelines**: Automated environments where no human is present to approve actions.
- **Disposable environments**: Docker containers, VMs, or codespaces where damage is easily reversed.
- **Trusted, repetitive scripts**: Batch operations you've already validated and want to run unattended.

This mode is never recommended for interactive development on a codebase you care about. Always prefer allowlisted tools or default mode for regular work.

## Choosing the Right Mode

| Scenario | Recommended Mode |
|----------|-----------------|
| Day-to-day development | Default |
| Exploring a new codebase | Plan mode |
| Routine tasks you've done before | Allowlisted tools |
| Planning a large refactor | Plan mode, then switch to default |
| CI/CD automation | Dangerously skip permissions (in containers) |
| Pair programming with Claude | Default with selective allows |
| Reviewing someone else's PR | Plan mode |

## Combining Modes in a Session

A typical session might use multiple modes:

1. **Start in plan mode** to understand the scope of a task.
2. **Switch to default mode** to implement the changes with review.
3. **Allowlist `Bash(npm test)`** so Claude can run tests freely while you review edits.

This layered approach gives you maximum safety without sacrificing productivity.

## See Also

- [Getting Started](getting-started.md) -- Basic setup and CLI usage
- [Workflow Patterns](workflow-patterns.md) -- Workflows that benefit from mode switching
- [Tips and Tricks](tips-and-tricks.md) -- CLI flags and shortcuts
- [Common Mistakes](common-mistakes.md) -- Permission-related anti-patterns
- [Security Practices](security-practices.md) -- Secrets management and safe patterns
