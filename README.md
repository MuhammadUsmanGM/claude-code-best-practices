# Claude Code Best Practices

> **Last updated:** April 5, 2026 · v1.2 · Covers Claude Code v1.x

A comprehensive guide to getting the most out of [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's agentic coding tool that lives in your terminal.

Claude Code connects directly to your development environment, understands your codebase, and helps you write, debug, and ship code faster. This wiki covers everything from first-time setup to advanced workflows and real-world configuration examples.

### See it in action

```
$ claude "Fix the failing test in src/utils/dates.test.ts"

 ● Reading src/utils/dates.test.ts...
 ● Reading src/utils/dates.ts...
 ● Found the bug: parseDate() doesn't handle ISO strings with timezone offsets.
 ● Editing src/utils/dates.ts — added offset normalization before parsing.
 ● Running npm test...
 ● All 47 tests passing.

 Done. Fixed the timezone offset handling in parseDate().
 One file changed, 3 lines added, 1 line removed.
```

One prompt. Claude reads the code, finds the bug, fixes it, and verifies the tests pass.

## Quick Start

1. **Install**: `npm install -g @anthropic-ai/claude-code`
2. **Authenticate**: Run `claude` and follow the prompts to log in
3. **Generate a CLAUDE.md**: Run `bash tools/generate-claude-md.sh` in your project, or use the [Quickstart Prompt](tools/quickstart-prompt.md) to have Claude generate one for you
4. **Start coding**: Navigate to your project and run `claude`

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
| [Debugging](guides/debugging.md) | Debugging strategies, stack traces, and fix-and-verify workflows |
| [Testing Workflows](guides/testing-workflows.md) | Writing tests, TDD with Claude, fixing flaky tests, and coverage |
| [Migration Guide](guides/migration-guide.md) | Migrating frameworks, languages, dependencies, and databases |

### Advanced Topics

| Guide | Description |
|-------|-------------|
| [Custom Instructions](guides/custom-instructions.md) | Advanced CLAUDE.md patterns for personas and role-based behavior |
| [Skills and Slash Commands](guides/skills-and-slash-commands.md) | Discovering, installing, and creating custom skills |
| [Context Management](guides/context-management.md) | Managing conversation length and keeping context focused |
| [MCP Servers](guides/mcp-servers.md) | Setting up and using Model Context Protocol servers |
| [Hooks](guides/hooks.md) | Pre/post tool hooks for automation |
| [Multi-Agent](guides/multi-agent.md) | Teams, agent swarms, and worktrees |
| [IDE Integration](guides/ide-integration.md) | VS Code, JetBrains setup and tips |
| [CI and Automation](guides/ci-and-automation.md) | Headless mode, piping, scripting, CI pipelines, containers |
| [Security Practices](guides/security-practices.md) | Secrets management, .claudeignore, safe permission patterns |
| [Team Setup](guides/team-setup.md) | Sharing configs, settings hierarchy, onboarding teammates |
| [Building Custom MCP Servers](guides/building-custom-mcp-servers.md) | Designing, building, testing, and deploying your own MCP servers |
| [Advanced Architecture](guides/advanced-architecture.md) | System design, plan mode for architecture, and trade-off evaluation |
| [Enterprise Patterns](guides/enterprise-patterns.md) | Governance, shared configs at scale, access control across large teams |
| [Cloud Integration](guides/cloud-integration.md) | Using Claude Code with AWS, GCP, Azure, serverless, Docker, and Kubernetes |
| [Case Studies](guides/case-studies.md) | Real-world walkthroughs of migrations, refactors, and feature builds |

### Cost and Efficiency

| Guide | Description |
|-------|-------------|
| [Performance Tuning](guides/performance-tuning.md) | Model selection, fast mode, and optimizing speed and cost |
| [Cost Management](guides/cost-management.md) | Monitoring usage, reducing token consumption, and budgeting |
| [Git Workflow](guides/git-workflow.md) | Commits, PRs, branch management with Claude Code |
| [Tips and Tricks](guides/tips-and-tricks.md) | Keyboard shortcuts, slash commands, headless mode, CLI flags |

### Reference

| Guide | Description |
|-------|-------------|
| [Troubleshooting](guides/troubleshooting.md) | Common issues and how to resolve them |
| [Common Mistakes](guides/common-mistakes.md) | Anti-patterns to avoid |

## Examples

### CLAUDE.md Templates

| Example | Description |
|---------|-------------|
| [React Project](examples/claude-md-react.md) | CLAUDE.md for a React + TypeScript frontend |
| [Python Project](examples/claude-md-python.md) | CLAUDE.md for a FastAPI backend service |
| [Monorepo](examples/claude-md-monorepo.md) | CLAUDE.md for a multi-package monorepo |
| [Next.js/Prisma](examples/claude-md-nextjs.md) | CLAUDE.md for a Next.js App Router + Prisma full-stack app |
| [Go Microservice](examples/claude-md-go.md) | CLAUDE.md for a Go HTTP service with sqlc and Docker |
| [Ruby on Rails](examples/claude-md-rails.md) | CLAUDE.md for a Rails 8 + Hotwire application |
| [Minimal](examples/claude-md-minimal.md) | Minimal but effective CLAUDE.md |

### Toolbox

| Tool | Description |
|------|-------------|
| [CLAUDE.md Generator](tools/generate-claude-md.sh) | Interactive shell script that generates a CLAUDE.md in 60 seconds |
| [Quickstart Prompt](tools/quickstart-prompt.md) | Copy-paste prompt that makes Claude auto-generate a CLAUDE.md |

### Configuration References

| Example | Description |
|---------|-------------|
| [Hook Scripts](examples/hook-scripts.md) | Ready-to-use hook configurations for common tasks |
| [MCP Configs](examples/mcp-configs.md) | Sample MCP server setups for popular services |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new guides, style conventions, and the PR process.

## License

This project is licensed under the MIT License.
