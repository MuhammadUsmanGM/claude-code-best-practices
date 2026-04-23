# Awesome Claude Code

A curated list of high-signal resources for getting more out of Claude Code:
community plugins, drop-in skills, essays worth reading, talks worth watching,
and tools that pair well.

> **Inclusion criteria.** An entry earns a spot if it meets *all* of:
> (1) publicly available and actively maintained (a commit or post in the
> last ~6 months), (2) specific to Claude Code or the Claude API in a way a
> generic list can't cover, (3) either the author or a reviewer has used it
> in real work — not just read the README.
>
> Want to add something? Open a PR editing this file. Keep descriptions to
> one line, alphabetical within each section, and add a one-sentence
> justification in the PR body.

## Official

- [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code) — canonical reference for CLI flags, settings, and behavior.
- [Anthropic API docs](https://docs.anthropic.com/en/api/overview) — for building against the API directly.
- [anthropic-cookbook](https://github.com/anthropics/anthropic-cookbook) — official recipes; good prompt and tool-use patterns.

## Plugins

- [commit-helper](plugins/commit-helper/) — this repo's reference plugin: Conventional Commits skill plus a secret-blocking `PreToolUse` hook.
- _Add yours here._ Use the shape: `[name](url) — one-line summary.`

## Skills

Drop-in `SKILL.md` files you can copy into `.claude/skills/`.

- [changelog](examples/skills/changelog/SKILL.md) — generate or update `CHANGELOG.md` from commits since the last tag.
- [pr-describe](examples/skills/pr-describe/SKILL.md) — draft PR title and body from the current branch.
- [test-triage](examples/skills/test-triage/SKILL.md) — classify failing tests as flaky vs. real, propose a fix path per test.
- [conventional-commit](plugins/commit-helper/skills/conventional-commit/SKILL.md) — Conventional Commits message from staged diff.
- _Add yours here._

## Starter kits

Whole-project `.claude/` drop-ins.

- [starters/react](starters/react/) — React + TypeScript, ESLint+Prettier, `/component-new` and `/test-component`.
- [starters/python](starters/python/) — FastAPI/Django agnostic, ruff+pytest+mypy, `/api-endpoint`.
- [starters/go](starters/go/) — Go services, gofmt+golangci-lint, `/add-handler`.

## Hook scripts

- [block-secrets](tools/hooks/block-secrets.sh) — refuses to write AWS keys, private keys, common API tokens, or `.env` files.
- [format-on-write](tools/hooks/format-on-write.sh) — runs prettier/gofmt/rustfmt/ruff on just-written files.
- [test-on-stop](tools/hooks/test-on-stop.sh) — runs the project's test suite after Claude finishes a turn.

## CLAUDE.md templates

Per-stack examples under [`examples/`](examples/): Django, Flutter, Go, minimal, monorepo, Next.js, Python, Rails, React, Rust, Spring Boot.

## Essays and posts

- _Add a link here when you find something worth keeping._ Please include a
  one-line hook that tells the reader *why* they should click — not just
  what the post is about.

## Talks and videos

- _Add a link here when you find something worth keeping._ Prefer permalinks
  over YouTube search results; include approximate duration.

## Tooling that pairs well with Claude Code

- [lychee](https://github.com/lycheeverse/lychee) — the link checker this repo uses in CI.
- [shellcheck](https://www.shellcheck.net/) — for validating hook scripts before they touch a real session.
- [jq](https://jqlang.github.io/jq/) — indispensable for hook scripts that parse the tool-use JSON payload.
- [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) — what renders this repo's published site.

## Adjacent reading

- [Model Context Protocol](https://modelcontextprotocol.io/) — the protocol behind `/mcp` servers.
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) — what this repo's `CHANGELOG.md` follows.
- [Conventional Commits](https://www.conventionalcommits.org/) — what the `/conventional-commit` skill produces.

## See also

- [README.md](README.md) — the full index of this repo's content.
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution rules, including how to add awesome-list entries.
- [guides/anti-patterns.md](guides/anti-patterns.md) — things to *avoid*, as a useful counterweight to this list.
