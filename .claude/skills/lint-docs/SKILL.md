---
name: lint-docs
description: Run this repo's documentation and shell quality gates (shellcheck, markdownlint, lint-claude-md) the same way CI runs them. Invoke before opening a PR, or when the user asks to lint, validate, or pre-flight the docs.
allowed-tools: Bash(shellcheck:*), Bash(markdownlint:*), Bash(bash tools/lint-claude-md.sh:*), Bash(find:*), Bash(git status:*), Read
---

# Lint Docs

Run the same three checks CI runs and report pass/fail per check.

## Steps

1. **shellcheck** — find every `.sh` under the repo and run `shellcheck` on it.
   ```bash
   find . -name '*.sh' -not -path './.git/*' -print0 | xargs -0 shellcheck
   ```
2. **markdownlint** — run `markdownlint` on `README.md`, `CONTRIBUTING.md`,
   `CHANGELOG.md`, and everything under `guides/`, `examples/`, `plugins/`,
   `tools/hooks/`. Use `.markdownlint.json` at repo root.
3. **lint-claude-md** — run `bash tools/lint-claude-md.sh` against every
   `examples/claude-md-*.md` template and the repo's own `CLAUDE.md`.

## Output

Print a single summary table, one row per check:

| Check | Status | Details |
|-------|--------|---------|

If any check fails, print the first 20 lines of its output below the table and
stop. Do not try to auto-fix unless the user asks.

## Rules

- If `shellcheck` or `markdownlint` isn't installed, say so and skip that
  check — don't silently pass.
- Do not modify files. This skill is diagnostic only.
