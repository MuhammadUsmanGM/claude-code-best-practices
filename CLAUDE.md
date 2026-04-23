# CLAUDE.md — claude-code-best-practices

This repository is a **documentation wiki** about Claude Code. It is also a
dogfood: the `.claude/` directory and this file show how we use Claude Code on
the very repo that teaches Claude Code. Read this before making changes.

## What this repo is

- Markdown guides in `guides/`, stack-specific CLAUDE.md examples in
  `examples/`, shell tools in `tools/`, plugins in `plugins/`.
- No application code. No build step. No package manager.
- Quality gates are enforced in CI: `shellcheck`, `markdownlint`, a link
  checker, and `tools/lint-claude-md.sh` against every template.

## How to help here

- **Edit existing files over creating new ones.** Only add a new guide when an
  existing one can't absorb the content without losing focus.
- **Follow `CONTRIBUTING.md` exactly**: H1 per file, 100–180 lines, fenced
  code blocks with language tags, relative links, "See Also" at the bottom,
  no emojis.
- **Cross-links are bidirectional.** When you add a new guide, update the
  related guides' "See Also" sections too.
- **Touch the README when you add a guide, tool, example, plugin, or skill.**
  The README's tables are the index; a file that isn't linked is invisible.
- **Update `CHANGELOG.md`** under the current unreleased / next-version section
  for any user-facing change.

## Style

- Direct, second-person ("you"). No filler, no hedging, no "in this guide we
  will explore." Lead with the answer.
- Tables for comparisons and option references. Bullets for lists.
- Prefer published numbers over adjectives. "~25% of Opus cost" beats "much
  cheaper." If you don't have the number, say so — don't invent one.
- No emojis in guide content. The only exceptions are the status markers
  already used in `guides/benchmarks.md` tables (✅ ⚠️ ❌).

## Shell scripts

- All `.sh` files must pass `shellcheck` with no warnings. CI enforces this.
- Start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Quote all variable expansions. Use `[ ]` with explicit `-z` / `-n` checks,
  not `[[ ]]` unless the script already uses it.
- Scripts that are hooks read JSON from stdin; prefer `jq` with a `sed`
  fallback so the script still works on minimal systems.
- Exit codes for hooks: `0` = allow, `2` = block with stderr surfaced.
  Anything else is treated as a script bug.

## Skills and plugins

- A skill is a single `SKILL.md` with YAML frontmatter (`name`, `description`,
  `allowed-tools`). The `description` is how Claude decides when to invoke it —
  be specific about *when* it applies, not just *what* it does.
- A plugin is a directory with `plugin.json`, optional `skills/`, optional
  `hooks/`. See `plugins/commit-helper/` as the reference implementation.
- Never include `Co-Authored-By` lines in generated commits unless the user
  asks. Never `git push` from a skill.

## Commits

- Conventional Commits: `type(scope): subject`, imperative mood, ≤ 72 chars,
  no trailing period.
- One topic per PR (see `CONTRIBUTING.md`).
- Never `--amend` a pushed commit. Never `--no-verify`.

## Benchmarks

- Numbers in `guides/benchmarks.md` are representative. When you rerun them,
  update the "Last run" line and the tables together — don't partially update.
- `tools/benchmark.sh` is the source of truth for reproducibility. Update it
  first if the methodology changes, then regenerate the guide's tables.

## What to avoid

- Adding dependencies. This repo has no `package.json`, no `requirements.txt`,
  and that's intentional — everything runs with bash + common Unix tools.
- Long code blocks copied from external docs. Link to the canonical source
  instead and explain the Claude Code–specific angle.
- Speculation presented as fact. If you haven't verified a behavior against
  the current version of Claude Code, mark it as "as of vX.Y" or cut it.

## See also

- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution and style rules
- [README.md](README.md) — index of guides, examples, and tools
- [.claude/README.md](.claude/README.md) — how the dogfooded Claude Code
  setup for this repo is wired
