# Claude Code Best Practices

> **The community handbook for shipping real software with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).**
> Guides, working plugins, drop-in starter kits, published benchmarks, and a dogfooded `.claude/` setup you can copy.
>
> **Last updated:** April 29, 2026 · **v1.5** · Covers Claude Code **v2.1.122** · Opus 4.7 / Sonnet 4.6 / Haiku 4.5

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Made with Claude Code](https://img.shields.io/badge/made%20with-Claude%20Code-8b7cff.svg)](https://docs.anthropic.com/en/docs/claude-code)
[![Conventional Commits](https://img.shields.io/badge/conventional%20commits-1.0.0-fa6673.svg)](https://www.conventionalcommits.org)
[![Awesome list](https://img.shields.io/badge/awesome-list-ff69b4.svg)](awesome.md)

**Browse the rendered site:** [MuhammadUsmanGM.github.io/claude-code-best-practices](https://MuhammadUsmanGM.github.io/claude-code-best-practices/)

---

## Why this repo exists

Claude Code is powerful out of the box, but the gap between *"it works"* and *"it ships production code reliably"* is closed by a handful of patterns: a sharp `CLAUDE.md`, the right permission mode, hooks that catch mistakes before they reach disk, skills for repeat tasks, and a cost model you can reason about. Most of that knowledge is scattered across blog posts, Discord threads, and internal wikis.

This repo pulls it together into one place — **opinionated, tested, and dogfooded on itself.** Every convention here has been used to build the repo you're reading: the `.claude/` directory wires the hooks, the `/lint-docs` skill runs the same checks CI does, and the commit log is a working example of the Conventional Commits skill under `plugins/commit-helper/`.

### What you'll find

- **30+ guides** covering fundamentals, workflows, permissions, advanced architecture, cost management, and security.
- **11 `CLAUDE.md` templates** for React, Python, Go, Rust, Rails, Django, Next.js, Spring Boot, Flutter, monorepos, and a minimal starter.
- **4 starter kits** — whole-project drop-ins (`CLAUDE.md` + `.claude/` with settings, skills, and hooks) for React, Next.js, Python, and Go.
- **Working plugin** (`commit-helper`) with a Conventional Commits skill and a `PreToolUse` hook that blocks secrets before they're committed.
- **Drop-in skills and hook scripts** — `/changelog`, `/pr-describe`, `/test-triage`, plus `block-secrets`, `format-on-write`, and `test-on-stop`.
- **Published benchmarks** — model comparison, plan-mode on/off, CLAUDE.md payoff, and prompt-cache impact, with a reproducible harness so you can rerun them in your own repo.
- **Security playbook** covering prompt injection, plugin supply chain, and team audit checklists.
- **Dogfooded `.claude/` setup** you can copy — see [`CLAUDE.md`](CLAUDE.md) and [`.claude/`](./.claude/).

### Who it's for

- **Individual developers** setting up Claude Code for the first time and wanting to skip the "figuring it out" phase.
- **Teams** standardizing how their engineers use Claude Code — shared configs, permission policies, and onboarding docs.
- **Tooling authors** building plugins, skills, or hooks who want reference implementations to study.

---

## See it in action

```text
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

One prompt. Claude reads the code, finds the bug, fixes it, and verifies the tests pass. The guides in this repo are about getting to that kind of loop on your own codebase — reliably, cheaply, and without surprises.

## Quick Start

1. **Install:** `npm install -g @anthropic-ai/claude-code`
2. **Authenticate:** run `claude` and follow the prompts to log in.
3. **Drop in a starter kit** (recommended for new projects): `cp -r starters/<stack>/. /path/to/your/repo/`. See the [starters overview](starters/README.md).
4. **Or generate a CLAUDE.md** for an existing project: `bash tools/generate-claude-md.sh`, or use the [Quickstart Prompt](tools/quickstart-prompt.md) to have Claude write one from your codebase.
5. **Start coding:** run `claude` in your project.

New to all of this? Read [Getting Started](guides/getting-started.md) → [CLAUDE.md Guide](guides/claude-md-guide.md) → [Workflow Patterns](guides/workflow-patterns.md) in that order. Each is ~10 minutes.

## Repo map

```text
claude-code-best-practices/
├── guides/          30+ guides — fundamentals, workflows, advanced, cost, security, reference
├── examples/        CLAUDE.md templates (11 stacks) + drop-in skills + hook-script recipes
├── starters/        Whole-project starter kits (React, Next.js, Python, Go)
├── plugins/         Working plugins — currently commit-helper
├── tools/           Shell utilities — CLAUDE.md generator, linter, cost estimator, benchmark harness, hooks
├── benchmarks/      Reproducible benchmark results and rolling summary
├── .claude/         Dogfood — settings, skills, and hooks used on this repo itself
├── .github/         CI workflows, issue and PR templates
├── CLAUDE.md        The project instructions Claude Code reads when working on this repo
├── CHANGELOG.md     Keep a Changelog format
└── CONTRIBUTING.md  Style guide and PR process
```

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
| [Benchmarks](guides/benchmarks.md) | **New in v1.3.** Published numbers: model comparison, plan mode on/off, CLAUDE.md payoff, cache impact |
| [Decision Trees](guides/decision-trees.md) | **New in v1.4.** Mermaid flowcharts: which model to pick, when to use plan mode |
| [Git Workflow](guides/git-workflow.md) | Commits, PRs, branch management with Claude Code |
| [Tips and Tricks](guides/tips-and-tricks.md) | Keyboard shortcuts, slash commands, headless mode, CLI flags |

### Reference

| Guide | Description |
|-------|-------------|
| [Troubleshooting](guides/troubleshooting.md) | Common issues and how to resolve them |
| [Common Mistakes](guides/common-mistakes.md) | Anti-patterns to avoid |
| [Anti-Patterns Gallery](guides/anti-patterns.md) | **New in v1.4.** Annotated bad/fixed pairs: CLAUDE.md, hooks, prompts |
| [Security Playbook](guides/security-playbook.md) | **New in v1.4.** Prompt injection, plugin supply chain, team audit checklist |

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
| [Rust](examples/claude-md-rust.md) | CLAUDE.md for a Rust Axum service with SQLx |
| [Java/Spring Boot](examples/claude-md-spring-boot.md) | CLAUDE.md for a Spring Boot 3 REST API with JPA |
| [Flutter/Dart](examples/claude-md-flutter.md) | CLAUDE.md for a Flutter mobile app with Riverpod |
| [Django](examples/claude-md-django.md) | CLAUDE.md for a Django + DRF application with Celery |
| [Minimal](examples/claude-md-minimal.md) | Minimal but effective CLAUDE.md |

### Toolbox

| Tool | Description |
|------|-------------|
| [CLAUDE.md Generator](tools/generate-claude-md.sh) | Interactive shell script that generates a CLAUDE.md in 60 seconds |
| [CLAUDE.md Linter](tools/lint-claude-md.sh) | Validates CLAUDE.md structure, catches common mistakes and secrets |
| [Cost Estimator](tools/estimate-cost.sh) | Estimates token usage and cost per task based on your codebase size |
| [Benchmark Harness](tools/benchmark.sh) | **New in v1.3.** Reproducible headless harness — run the benchmarks in your own repo |
| [Benchmark Summary](tools/benchmark-summary.sh) | **New in v1.4.** Aggregates `benchmarks/history/*.csv` into a living `benchmarks/latest.md` (nightly CI) |
| [Hook Scripts](tools/hooks/README.md) | **New in v1.3.** Drop-in `block-secrets`, `format-on-write`, `test-on-stop` |
| [Quickstart Prompt](tools/quickstart-prompt.md) | Copy-paste prompt that makes Claude auto-generate a CLAUDE.md |

### Plugins and Skills

| Item | Description |
|------|-------------|
| [commit-helper plugin](plugins/commit-helper/README.md) | **New in v1.3.** Working plugin: Conventional Commits skill + secret-blocking hook |
| [claude-md-checker plugin](plugins/claude-md-checker/README.md) | **New in v1.5.** PreToolUse guard that runs `lint-claude-md.sh` on every CLAUDE.md edit |
| [Example Skills](examples/skills/README.md) | **New in v1.3.** Drop-in `/changelog`, `/pr-describe`, `/test-triage` |

### Starter Kits

Whole-project drop-in kits — `CLAUDE.md` + `.claude/` (settings, skills, hooks) per stack.

| Kit | Description |
|-----|-------------|
| [React](starters/react/) | **New in v1.4.** React + TypeScript, ESLint+Prettier, `/component-new` and `/test-component` skills |
| [Next.js](starters/nextjs/) | **New in v1.5.** Next.js 15 App Router, TypeScript, RSC + server-action conventions |
| [Python](starters/python/) | **New in v1.4.** FastAPI/Django, ruff+pytest+mypy, `/api-endpoint` skill |
| [Go](starters/go/) | **New in v1.4.** Go services, gofmt+golangci-lint, `/add-handler` skill |
| [Starters overview](starters/README.md) | How to install a kit and conventions for adding new ones |

### Configuration References

| Example | Description |
|---------|-------------|
| [Hook Scripts](examples/hook-scripts.md) | Ready-to-use hook configurations for common tasks |
| [MCP Configs](examples/mcp-configs.md) | Sample MCP server setups for popular services |

## Community

- **[Awesome list](awesome.md)** — curated plugins, skills, posts, and tools that pair well with Claude Code.
- **[Discussions](https://github.com/MuhammadUsmanGM/claude-code-best-practices/discussions)** — open-ended questions, ideas, show-and-tell. Enable in repo Settings → General → Features.
- **[Issues](https://github.com/MuhammadUsmanGM/claude-code-best-practices/issues)** — concrete bugs and tool/guide requests. Templates under [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for style conventions and the PR process. Every PR runs through five CI checks:

| Check | What it catches |
|-------|-----------------|
| [shellcheck](.github/workflows/shellcheck.yml) | Shell bugs in any `.sh` under the repo |
| [markdownlint](.github/workflows/markdownlint.yml) | Markdown structure issues (headings, lists, code fences) |
| [links](.github/workflows/links.yml) | Broken internal and external links |
| [lint-claude-md](.github/workflows/lint-claude-md.yml) | CLAUDE.md structure issues in every template |
| [docs](.github/workflows/docs.yml) | mkdocs-material site build — catches broken nav and missing files |

A sixth workflow ([benchmarks](.github/workflows/benchmarks.yml)) is wired up but **manual-only** — it calls the Anthropic API and bills whoever runs it for tokens. Trigger it with **Actions → benchmarks → Run workflow** on a fork with `ANTHROPIC_API_KEY` set as a repo secret.

## Changelog and versioning

- [`CHANGELOG.md`](CHANGELOG.md) follows [Keep a Changelog](https://keepachangelog.com/).
- Versions are semver. Current release: **v1.4.0**.
- Breaking changes to starter kits, plugins, or hook scripts bump the major version.

## License

MIT — see [LICENSE](LICENSE). Community-maintained; not affiliated with Anthropic.
