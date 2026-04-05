# CI and Automation

A guide for power users who want to run Claude Code non-interactively — in CI pipelines, shell scripts, Docker containers, and automated workflows. This builds on the basics covered in [Tips and Tricks](tips-and-tricks.md) and goes deeper on scripting patterns, permission strategies for unattended execution, and real-world pipeline examples.

## Headless Mode Deep Dive

The `-p` flag runs Claude Code in non-interactive (print) mode. It processes a single prompt, writes the result to stdout, and exits. This is the foundation of all automation.

```bash
# Basic one-shot
claude -p "explain the purpose of src/auth/middleware.ts"

# With a specific model
claude -p --model claude-haiku-4-5-20251001 "list the public exports of src/index.ts"

# Output as JSON for structured parsing
claude -p --output-format json "list all TODO comments in the codebase"
```

Key flags for headless usage:

| Flag | Purpose |
|------|---------|
| `-p "prompt"` | Non-interactive mode — process prompt and exit |
| `--model` | Choose model (Haiku for cheap batch work, Opus for complex tasks) |
| `--output-format json` | Structured output for downstream parsing |
| `--allowedTools` | Restrict which tools Claude can use |
| `--max-turns` | Limit how many tool-use rounds Claude can take |
| `--verbose` | Debug output for troubleshooting scripts |

## Piping and Composition

Claude Code reads stdin and writes to stdout, making it composable with standard Unix tools.

### Input piping

```bash
# Feed a diff for review
git diff HEAD~5 | claude -p "summarize these changes for a changelog"

# Feed a file for analysis
cat src/config.ts | claude -p "find security issues in this configuration"

# Feed test output for diagnosis
npm test 2>&1 | claude -p "explain why these tests are failing and suggest fixes"

# Feed multiple files
cat src/models/*.ts | claude -p "find inconsistencies in these model definitions"
```

### Output capture

```bash
# Generate a file directly
claude -p "generate a .gitignore for a Python ML project" > .gitignore

# Capture for further processing
SUMMARY=$(git log --oneline -20 | claude -p "write a one-paragraph release summary")
echo "$SUMMARY" >> CHANGELOG.md

# Pipe into another tool
claude -p "generate test cases for src/utils/validate.ts as JSON" | jq '.tests[]'
```

### Shell aliases for repeated tasks

```bash
# Add to ~/.bashrc or ~/.zshrc
alias cr='git diff --staged | claude -p "review these staged changes for bugs, security issues, and style"'
alias ce='claude -p "explain"'
alias cfix='claude -p "fix the failing tests and explain what was wrong"'
alias ccommit='claude -p "commit the staged changes with a descriptive message"'
```

## Running in CI/CD Pipelines

### GitHub Actions

```yaml
name: AI Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Review PR diff
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          git diff origin/main...HEAD | claude -p \
            "Review this PR diff. Flag bugs, security issues, and style problems. \
             Be concise — one line per issue with file:line reference." \
            --dangerously-skip-permissions \
            --max-turns 3
```

### Other CI systems

The pattern is the same everywhere:

1. Install Claude Code (`npm install -g @anthropic-ai/claude-code`)
2. Set `ANTHROPIC_API_KEY` as a secret environment variable
3. Run `claude -p` with `--dangerously-skip-permissions`
4. Pipe input or let Claude read the checkout directly

```bash
# Generic CI script
#!/bin/bash
set -euo pipefail

export ANTHROPIC_API_KEY="$CI_ANTHROPIC_KEY"

# Review changes
git diff "$CI_MERGE_BASE"...HEAD | claude -p \
  "Review for bugs and security issues. Output as markdown." \
  --dangerously-skip-permissions \
  --model claude-sonnet-4-6 \
  > review-output.md
```

## Using --dangerously-skip-permissions Safely

This flag disables all permission prompts. Claude can read, write, execute, and commit without asking. It is **required** for unattended execution but must be used with care.

### When it is appropriate

- CI/CD pipelines where no human is present to approve
- Docker containers and disposable VMs where the environment is ephemeral
- Pre-validated batch scripts running a known, tested prompt
- Sandboxed environments with no access to production systems

### When it is NOT appropriate

- Interactive development on your local machine
- Repos containing production secrets or infrastructure code
- Any environment where destructive actions cannot be easily reversed

### Reducing risk

```bash
# Limit tools to reduce blast radius
claude -p "review src/ for bugs" \
  --dangerously-skip-permissions \
  --allowedTools "Read,Grep,Glob"  # read-only — no writes, no bash

# Limit turns to prevent runaway loops
claude -p "fix the lint errors in src/utils.ts" \
  --dangerously-skip-permissions \
  --max-turns 5

# Run in a container for full isolation
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  -e ANTHROPIC_API_KEY \
  node:20-slim bash -c \
  'npm install -g @anthropic-ai/claude-code && \
   claude -p "run tests and fix any failures" \
   --dangerously-skip-permissions'
```

## Docker and Container Patterns

Running Claude Code in containers gives you full isolation — if something goes wrong, throw the container away.

### Dockerfile for CI

```dockerfile
FROM node:20-slim
RUN npm install -g @anthropic-ai/claude-code
WORKDIR /workspace
COPY . .
# API key provided at runtime via -e flag
ENTRYPOINT ["claude", "-p", "--dangerously-skip-permissions"]
```

```bash
# Usage
docker build -t claude-worker .
docker run --rm -e ANTHROPIC_API_KEY \
  claude-worker "run the test suite and report failures"
```

### Disposable review environment

```bash
# Clone into a temp container, review, discard
docker run --rm -e ANTHROPIC_API_KEY node:20-slim bash -c '
  npm install -g @anthropic-ai/claude-code &&
  git clone --depth 1 https://github.com/org/repo /workspace &&
  cd /workspace &&
  claude -p "audit this codebase for security vulnerabilities" \
    --dangerously-skip-permissions \
    --model claude-sonnet-4-6
'
```

## Scripting Patterns

### Batch processing files

```bash
#!/bin/bash
set -euo pipefail

for file in src/components/*.tsx; do
  echo "Reviewing $file..."
  claude -p "review $file for accessibility issues" \
    --dangerously-skip-permissions \
    --model claude-haiku-4-5-20251001 \
    >> a11y-report.md
  echo "---" >> a11y-report.md
done
```

### Conditional automation

```bash
#!/bin/bash
# Only run review if there are staged changes
if git diff --cached --quiet; then
  echo "No staged changes to review."
  exit 0
fi

git diff --cached | claude -p \
  "Review these staged changes. Exit with a summary." \
  --dangerously-skip-permissions
```

### Exit codes and error handling

Claude Code returns non-zero exit codes on failure. Use this in scripts:

```bash
if ! claude -p "run npm test" --dangerously-skip-permissions; then
  echo "Claude reported a failure — check output above"
  exit 1
fi
```

## Cost Control in Automation

Automated runs can accumulate cost quickly. Keep spend predictable:

- **Use Haiku** for simple tasks (review, summarize, explain) — it is significantly cheaper
- **Limit turns** with `--max-turns` to prevent Claude from spiraling on hard problems
- **Scope narrowly** — review one file at a time rather than entire repos
- **Restrict tools** with `--allowedTools` to prevent expensive exploration chains
- **Monitor usage** — track API spend by CI job using the Anthropic Console usage dashboard

## See Also

- [Tips and Tricks](tips-and-tricks.md) — Keyboard shortcuts, slash commands, and interactive tips
- [Permission Modes](permission-modes.md) — Full breakdown of permission options
- [Security Practices](security-practices.md) — Keeping credentials safe in automated environments
- [Cloud Integration](cloud-integration.md) — Using Claude Code with AWS, GCP, Azure, and containers
- [Cost Management](cost-management.md) — Token budgeting and efficient prompting
