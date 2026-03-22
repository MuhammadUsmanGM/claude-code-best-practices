# Pre/Post Tool Hooks

Hooks let you run shell commands automatically when Claude Code performs certain actions. They are useful for enforcing code quality, triggering builds, sending notifications, and integrating with your existing development workflow.

## What Are Hooks?

A hook is a shell command that executes in response to a Claude Code event. For example, you can run a linter every time Claude edits a file, or send a notification when a task completes. Hooks run synchronously — Claude Code waits for them to finish before continuing.

Hooks provide feedback directly to Claude. If a hook exits with a non-zero status, Claude sees the failure and can adjust its approach.

## Configuring Hooks

Hooks are defined in `.claude/settings.json` (project-level) or `~/.claude/settings.json` (global):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "eslint --fix \"$CLAUDE_FILE_PATH\"",
        "description": "Auto-fix lint issues after file edits"
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "command": "notify-send 'Claude Code' \"$CLAUDE_NOTIFICATION\"",
        "description": "Desktop notification on completion"
      }
    ]
  }
}
```

Each hook specifies:

- **matcher** — A regex pattern to filter which tools or events trigger the hook. An empty string matches everything.
- **command** — The shell command to execute. Environment variables provide context about the event.
- **description** — A human-readable explanation shown in logs.

## Hook Events

### PreToolUse

Runs before a tool executes. The hook can block the tool by exiting with a non-zero status. Useful for validation and safety checks.

Available variables: `CLAUDE_TOOL_NAME`, `CLAUDE_FILE_PATH` (for file operations), `CLAUDE_COMMAND` (for Bash).

### PostToolUse

Runs after a tool completes successfully. Common uses include formatting, linting, and logging.

Available variables: same as PreToolUse, plus `CLAUDE_TOOL_RESULT` with the tool output.

### Notification

Runs when Claude Code sends a notification, such as when it finishes a task and is waiting for input.

Available variables: `CLAUDE_NOTIFICATION` with the notification message.

### PreUserPromptSubmit

Runs before a user prompt is processed. Can be used to inject context or validate prompts.

## Example Hooks

### Auto-format on Save

Run Prettier after every file edit:

```json
{
  "matcher": "Edit|Write",
  "command": "prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
  "description": "Format files after editing"
}
```

### Lint Check Before Commit

Validate changes before Claude runs git commit:

```json
{
  "matcher": "Bash",
  "command": "if echo \"$CLAUDE_COMMAND\" | grep -q 'git commit'; then npm run lint; fi",
  "description": "Run linter before git commits"
}
```

### Sound Notification on Completion

Play a sound when Claude finishes and is waiting:

```json
{
  "matcher": "",
  "command": "powershell -c '[console]::beep(600,300)'",
  "description": "Beep when Claude needs attention"
}
```

### Log All Tool Usage

Keep an audit trail of what Claude does:

```json
{
  "matcher": "",
  "command": "echo \"$(date): $CLAUDE_TOOL_NAME\" >> ~/.claude/tool-log.txt",
  "description": "Log tool usage to file"
}
```

## Writing Hook Scripts

For complex logic, put your hook in a script file rather than inlining it:

```json
{
  "matcher": "Edit|Write",
  "command": "bash .claude/hooks/post-edit.sh",
  "description": "Run post-edit checks"
}
```

In `.claude/hooks/post-edit.sh`:

```bash
#!/bin/bash
FILE="$CLAUDE_FILE_PATH"
EXT="${FILE##*.}"

case "$EXT" in
  ts|tsx) npx eslint --fix "$FILE" ;;
  py)     ruff check --fix "$FILE" ;;
  rs)     rustfmt "$FILE" ;;
esac
```

## Tips and Caveats

- **Keep hooks fast.** Claude waits for hooks to complete. Long-running hooks slow down the entire workflow.
- **Handle errors gracefully.** Use `|| true` if a hook failure should not block Claude.
- **Test hooks manually.** Run the command with sample environment variables before adding it to settings.
- **Use project-level hooks** for team-specific workflows and global hooks for personal preferences.
- **Hooks see the same environment** as Claude Code, including your PATH and installed tools.
- **PreToolUse hooks can block actions.** A non-zero exit prevents the tool from running. Use this carefully.

## See Also

- [MCP Servers](mcp-servers.md) — Another extensibility mechanism for adding tools
- [CLAUDE.md Guide](claude-md-guide.md) — Documenting hook behavior for your team
- [Getting Started](getting-started.md) — Initial project configuration
- [IDE Integration](ide-integration.md) — Hooks alongside editor workflows
