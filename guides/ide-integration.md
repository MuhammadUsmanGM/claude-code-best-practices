# IDE Integration

Claude Code works alongside your existing editor setup. Whether you use VS Code, a JetBrains IDE, or a plain terminal, there are ways to make the integration smooth and productive.

## VS Code Extension

The official Claude Code extension for VS Code provides an integrated chat panel and direct access to Claude from your editor.

### Installation

1. Open VS Code and go to the Extensions panel (Ctrl+Shift+X).
2. Search for "Claude Code" and install the extension from Anthropic.
3. The extension uses your existing Claude Code CLI authentication — no separate login needed.

### Key Features

- **Inline chat panel** — Talk to Claude without leaving your editor.
- **File context** — The extension automatically includes your current file and selection as context.
- **Terminal integration** — Claude Code commands run in the VS Code integrated terminal.
- **Diff view** — Proposed changes appear as diffs you can accept or reject inline.
- **Status bar** — Shows current Claude Code status and token usage.

### Tips for VS Code

- Use `Ctrl+L` (or `Cmd+L` on Mac) to open the Claude panel quickly.
- Select code before opening Claude to automatically include it as context.
- Use the "Apply" button on code suggestions to apply them directly to your file.
- The terminal panel shows full Claude Code output for debugging.
- Pin the Claude panel to the secondary sidebar to keep it visible alongside your file explorer.

## JetBrains Plugin

Claude Code integrates with IntelliJ IDEA, WebStorm, PyCharm, and other JetBrains IDEs.

### Installation

1. Open Settings > Plugins > Marketplace.
2. Search for "Claude Code" and install.
3. Restart the IDE when prompted.

### Key Features

- **Tool window** — A dedicated Claude Code panel in the IDE.
- **Context awareness** — Sends your current file, project structure, and selection to Claude.
- **Action integration** — Access Claude from the right-click context menu or via keyboard shortcuts.
- **Terminal support** — Claude Code CLI runs in the built-in terminal.

### Tips for JetBrains

- Assign a keyboard shortcut to the Claude Code action for quick access.
- Use the "Explain this code" context menu action for unfamiliar code sections.
- The plugin respects your project's `.claude/settings.json` configuration.
- JetBrains' built-in diff viewer works well with Claude's proposed changes.

## Terminal Integration

Claude Code is a CLI tool at its core. You can use it effectively from any terminal.

### Setup

```bash
# Install globally
npm install -g @anthropic-ai/claude-code

# Run in your project directory
cd your-project
claude
```

### Terminal Multiplexer Workflows

For power users, combining Claude Code with tmux or a similar multiplexer is highly effective:

- **Split panes** — Run Claude in one pane and your normal terminal in another.
- **Session persistence** — Detach and reattach without losing your Claude session.
- **Multiple agents** — Run separate Claude instances in different panes for parallel work.

```bash
# Example tmux layout
tmux new-session -s dev
# Pane 1: Claude Code
# Pane 2: git, build commands
# Pane 3: test runner
```

### Integration with Other Editors

For Vim, Emacs, or other editors:

- Run Claude Code in a separate terminal alongside your editor.
- Use Claude to make edits, then reload files in your editor (`:e!` in Vim, `revert-buffer` in Emacs).
- Configure your editor to auto-reload changed files for a smoother experience.

## General Tips Across All IDEs

- **Let Claude read, you review.** Claude makes changes via its tools. Your IDE shows the results. Use your editor's diff and history features to review what changed.
- **Use source control.** Always have uncommitted changes visible in your IDE's git panel so you can review Claude's edits before committing.
- **Configure auto-save carefully.** If your IDE auto-saves, Claude's edits take effect immediately. Disable auto-save or use git to maintain a safety net.
- **Leverage IDE navigation.** After Claude makes changes, use "Go to Definition," "Find References," and other IDE features to verify the changes are correct.
- **Keep your terminal visible.** Even when using an IDE extension, the terminal output from Claude Code provides useful details about what tools were called and what happened.

## Combining Claude Code with IDE Features

The most productive workflow uses both Claude Code and your IDE's built-in features:

| Task | Best Tool |
|------|-----------|
| Writing new code | Claude Code |
| Reviewing changes | IDE diff view |
| Navigating code | IDE (Go to Definition, etc.) |
| Running tests | Either — Claude can run and interpret; IDE gives visual feedback |
| Debugging | IDE debugger + Claude for analysis |
| Refactoring (simple) | IDE refactoring tools |
| Refactoring (complex) | Claude Code |
| Git operations | Either — Claude for complex, IDE for visual staging |

## See Also

- [Getting Started](getting-started.md) — Installing and configuring Claude Code
- [Context Management](context-management.md) — Managing context effectively in IDE panels
- [Hooks](hooks.md) — Auto-formatting and linting alongside IDE features
- [MCP Servers](mcp-servers.md) — Adding tools that work across all IDE setups
