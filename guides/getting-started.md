# Getting Started with Claude Code

Claude Code is an agentic coding assistant that operates directly in your terminal. It can read and edit files, run commands, search your codebase, and interact with Git and GitHub -- all through natural language. This guide walks you through installation, authentication, and your first productive session.

## Prerequisites

- **Node.js 18+**: Claude Code requires Node.js version 18 or later. Check with `node --version`.
- **An Anthropic account**: You need an active Anthropic account with API access or a Claude Pro/Team subscription.
- **A terminal**: Works in any Unix-like shell (macOS Terminal, Linux shell, WSL on Windows, or Git Bash).

## Installation

Install Claude Code globally via npm:

```bash
npm install -g @anthropic-ai/claude-code
```

To verify the installation:

```bash
claude --version
```

### Updating

To update to the latest version:

```bash
npm update -g @anthropic-ai/claude-code
```

## Authentication

Run `claude` for the first time and follow the interactive login flow:

```bash
claude
```

You will be prompted to authenticate through your browser. Once completed, your session credentials are stored locally and persist across sessions.

### API Key Authentication

Alternatively, set the `ANTHROPIC_API_KEY` environment variable:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
claude
```

## First Run

Navigate to your project directory and start Claude Code:

```bash
cd your-project
claude
```

Claude will automatically detect your project structure. Try some basic commands:

- `"What does this project do?"` -- Claude reads your files and gives a summary.
- `"Find all TODO comments"` -- Searches the codebase.
- `"Run the tests"` -- Executes your test suite.
- `"Fix the bug in auth.js where the token isn't refreshed"` -- Reads, edits, and verifies the fix.

## Basic CLI Usage

### Interactive Mode (default)

```bash
claude                    # Start an interactive session
```

### One-shot Mode

```bash
claude -p "explain src/index.ts"         # Print answer and exit
claude -p "add error handling to api.js"  # Make a change and exit
```

### Piping Input

```bash
cat error.log | claude -p "explain this error"
git diff | claude -p "review these changes"
```

### Resuming Conversations

```bash
claude --resume            # Resume the most recent conversation
claude --continue          # Continue the last conversation with a new prompt
```

## Common Flags

| Flag | Description |
|------|-------------|
| `-p "prompt"` | Run in non-interactive (print) mode |
| `--resume` | Resume the last conversation |
| `--continue` | Continue the last conversation |
| `--model` | Specify a model (e.g., `claude-sonnet-4-6`) |
| `--allowedTools` | Restrict which tools Claude can use |
| `--verbose` | Show detailed tool usage output |

For more CLI options and shortcuts, see [Tips and Tricks](tips-and-tricks.md).

## Tips for Your First Session

- **Start with exploration**: Ask Claude to summarize your project or explain a module before making changes.
- **Be specific**: Instead of "fix the bug", say "fix the null pointer in `processOrder` when the cart is empty".
- **Create a CLAUDE.md file**: Give Claude persistent context about your project. See the [CLAUDE.md Guide](claude-md-guide.md).
- **Review changes**: Claude shows you diffs before applying them. Take a moment to review.
- **Use plan mode for big tasks**: Prefix complex requests with "plan:" or use `--plan` to have Claude outline an approach before executing.

## What's Next

Now that you are up and running, explore these guides to deepen your usage:

## See Also

- [CLAUDE.md Guide](claude-md-guide.md) -- Give Claude persistent context about your project
- [Prompt Tips](prompt-tips.md) -- Write more effective instructions
- [Workflow Patterns](workflow-patterns.md) -- Common development workflows
- [Permission Modes](permission-modes.md) -- Control what Claude can do
