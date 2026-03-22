# Claude Code Best Practices

A comprehensive guide to getting the most out of [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's agentic coding tool that lives in your terminal.

Claude Code connects directly to your development environment, understands your codebase, and helps you write, debug, and ship code faster. This wiki covers everything from first-time setup to advanced workflows and real-world configuration examples.

## Quick Start

1. **Install**: `npm install -g @anthropic-ai/claude-code`
2. **Authenticate**: Run `claude` and follow the prompts to log in
3. **Start coding**: Navigate to your project and run `claude`

For detailed setup instructions, see the [Getting Started](guides/getting-started.md) guide.

## Guides

### Fundamentals

| Guide | Description |
|-------|-------------|
| [Getting Started](guides/getting-started.md) | Installation, authentication, first run, and basic CLI usage |
| [CLAUDE.md Guide](guides/claude-md-guide.md) | Writing effective CLAUDE.md files to give Claude project context |
| [Prompt Tips](guides/prompt-tips.md) | Crafting clear instructions and iterating on prompts |

### Workflows and Permissions

| Guide | Description |
|-------|-------------|
| [Workflow Patterns](guides/workflow-patterns.md) | Common workflows for bug fixing, features, refactoring, and PR review |
| [Permission Modes](guides/permission-modes.md) | Understanding and configuring permission levels |

### Advanced Topics

| Guide | Description |
|-------|-------------|
| [Context Management](guides/context-management.md) | Managing conversation length and keeping context focused |
| [MCP Servers](guides/mcp-servers.md) | Setting up and using Model Context Protocol servers |
| [Hooks](guides/hooks.md) | Pre/post tool hooks for automation |
| [Multi-Agent](guides/multi-agent.md) | Teams, agent swarms, and worktrees |
| [IDE Integration](guides/ide-integration.md) | VS Code, JetBrains setup and tips |

### Cost and Efficiency

| Guide | Description |
|-------|-------------|
| [Cost Management](guides/cost-management.md) | Monitoring usage, reducing token consumption, and budgeting |
| [Git Workflow](guides/git-workflow.md) | Commits, PRs, branch management with Claude Code |
| [Tips and Tricks](guides/tips-and-tricks.md) | Keyboard shortcuts, slash commands, headless mode, CLI flags |

### Reference

| Guide | Description |
|-------|-------------|
| [Troubleshooting](guides/troubleshooting.md) | Common issues and how to resolve them |
| [Common Mistakes](guides/common-mistakes.md) | Anti-patterns to avoid |

## Examples

Real-world CLAUDE.md files and configuration patterns:

| Example | Description |
|---------|-------------|
| [React Project](examples/claude-md-react.md) | CLAUDE.md for a React + TypeScript frontend |
| [Python Project](examples/claude-md-python.md) | CLAUDE.md for a FastAPI backend service |
| [Monorepo](examples/claude-md-monorepo.md) | CLAUDE.md for a multi-package monorepo |
| [Minimal](examples/claude-md-minimal.md) | Minimal but effective CLAUDE.md |

## Contributing

Found an issue or want to suggest an improvement? Open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
