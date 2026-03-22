# Tips and Tricks

A collection of keyboard shortcuts, slash commands, CLI features, and workflow tricks to get the most out of Claude Code.

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **Escape** | Interrupt Claude mid-response (useful if it goes off track) |
| **Shift+Tab** | Insert a newline in your prompt (for multi-line input) |
| **Up Arrow** | Cycle through previous prompts |
| **Ctrl+C** | Cancel current input or interrupt response |
| **Ctrl+L** | Clear the terminal display |

**Escape is your best friend.** If Claude starts heading in the wrong direction, hit Escape immediately. You save tokens and can redirect with a better prompt.

## Slash Commands

Slash commands are typed directly into the prompt input:

### Session Management

- `/compact` — Summarize conversation history to reduce context size. Optionally add a focus: `/compact focus on the auth module`
- `/clear` — Clear the entire conversation and start fresh
- `/help` — Show available commands and usage information

### Model Selection

- `/model` — Switch the active model mid-session

```
/model claude-haiku-4-5-20251001    # Fast, cheap — good for simple tasks
/model claude-sonnet-4-6            # Balanced — default for most work
/model claude-opus-4-6              # Most capable — for complex tasks
```

### Other Commands

- `/cost` — Show token usage for the current session (if available)
- `/config` — Open or manage configuration
- `/review` — Start a code review workflow

## Headless Mode

Run Claude Code non-interactively for scripting and automation:

```bash
# Pipe a prompt directly
echo "explain src/main.ts" | claude

# Use the -p flag for a one-shot prompt
claude -p "what does the main function do in src/index.ts"

# Combine with other tools
git diff | claude -p "review this diff for bugs"
cat error.log | claude -p "explain these errors and suggest fixes"
```

Headless mode is powerful for:
- CI/CD pipelines (automated code review, commit message generation)
- Shell scripts that need AI assistance
- Batch processing multiple files

## Piping Input and Output

Claude Code reads from stdin and writes to stdout, making it composable with Unix tools:

```bash
# Feed file contents as context
cat src/config.ts | claude -p "are there any security issues here?"

# Save Claude's output to a file
claude -p "generate a .gitignore for a Node.js project" > .gitignore

# Chain with other commands
git log --oneline -20 | claude -p "summarize recent changes"
```

## CLI Flags

Useful flags when launching Claude Code:

```bash
claude                          # Interactive mode (default)
claude -p "prompt"              # One-shot prompt, exit after response
claude --model claude-opus-4-6  # Start with a specific model
claude --verbose                # Show additional debug output
claude --allowedTools "Edit,Read,Bash"  # Restrict available tools
```

## Vim Mode

If you prefer vim keybindings, Claude Code supports vim mode for input editing:

```bash
# Enable vim mode
claude config set vim_mode true
```

With vim mode enabled:
- Press `Escape` to enter normal mode
- Standard vim motions (`h`, `j`, `k`, `l`, `w`, `b`, etc.) work in the input
- Press `i` or `a` to return to insert mode

## Multi-line Input

For complex prompts, use Shift+Tab to add newlines:

```
Fix the following issues:          [Shift+Tab]
1. The login form doesn't validate  [Shift+Tab]
2. The error message is wrong       [Shift+Tab]
3. The redirect URL is hardcoded    [Enter to send]
```

Alternatively, write your prompt in a file and pipe it:

```bash
claude -p "$(cat my-prompt.txt)"
```

## Useful Workflow Patterns

**Quick exploration before deep work:**
```
"list all files that import from src/auth/"
"show me the public API of the User class"
```

**Checkpoint with /compact:**
After finishing a sub-task, compact before starting the next one. This keeps costs down and prevents context confusion.

**Use Escape + redirect:**
If Claude starts implementing the wrong approach, hit Escape and clarify:
```
[Escape]
"Stop — use the existing validateUser function instead of creating a new one"
```

**Batch related changes:**
```
"rename all instances of userId to user_id in the Python files under src/models/"
```

## See Also

- [CI and Automation](ci-and-automation.md) — Headless mode, piping, scripting, and CI pipelines in depth
- [Cost Management](cost-management.md) — /compact and other cost-saving techniques
- [Git Workflow](git-workflow.md) — Git-specific commands and patterns
- [Troubleshooting](troubleshooting.md) — fixes for common issues
