# Changelog

All notable changes to this project are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/).

## [1.4.0] - 2026-04-23

### Added
- **Dogfooded repo setup** — [`CLAUDE.md`](CLAUDE.md) at repo root and
  [`.claude/`](./.claude/) wiring `block-secrets` + `format-on-write` hooks,
  a narrow permission allowlist, and a repo-local `/lint-docs` skill. We use
  Claude Code to maintain the repo that teaches Claude Code.
- **Anti-Patterns Gallery** ([`guides/anti-patterns.md`](guides/anti-patterns.md)) —
  14 annotated bad/fixed pairs across CLAUDE.md, hooks, and prompts, cross-linked
  to the positive-space guides.
- **CI quality gates** ([`.github/workflows/`](.github/workflows/)):
  - `shellcheck.yml` — shellcheck on every `.sh` on push/PR (fails on warnings).
  - `markdownlint.yml` — `markdownlint-cli` against all markdown with a shared
    `.markdownlint.json`.
  - `links.yml` — `lychee` link checker on push/PR and a weekly schedule to
    catch external rot.
  - `lint-claude-md.yml` — runs `tools/lint-claude-md.sh` against every
    `examples/claude-md-*.md` and the repo's own `CLAUDE.md`.
- Status badges for all four CI workflows in the README.

### Fixed
- `tools/hooks/block-secrets.sh` and
  `plugins/commit-helper/hooks/block-secret-commits.sh` — `grep -E` was parsing
  the `-----BEGIN …` pattern as a flag; added `--` separator. Caught by
  dogfooding the hook against the anti-patterns guide draft.
- `plugins/commit-helper/hooks/block-secret-commits.sh` — renamed a local
  `command` variable that shadowed the `command` builtin.
- `tools/hooks/test-on-stop.sh` — parenthesized a `||`/`&&` chain whose
  precedence was ambiguous.

### Notes
- CI badge URLs assume the repo is hosted at
  `github.com/MuhammadUsmanGM/claude-code-best-practices`. Update them if
  you fork.

## [1.3.0] - 2026-04-23

### Added
- **Benchmarks guide** ([`guides/benchmarks.md`](guides/benchmarks.md)) — published
  numbers for model comparison, plan mode on/off, CLAUDE.md payoff, and prompt
  cache impact, with guidance on how to read the ratios.
- **Benchmark harness** ([`tools/benchmark.sh`](tools/benchmark.sh)) — reproducible
  headless harness (`claude -p ... --output-format json`) that runs a fixed task
  set across models and emits a CSV with tokens, duration, cost, and outcome.
- **`commit-helper` plugin** ([`plugins/commit-helper/`](plugins/commit-helper/)) —
  a working Claude Code plugin: Conventional Commits skill plus a `PreToolUse`
  hook that blocks `git commit` when staged content contains secrets.
- **Example skills** ([`examples/skills/`](examples/skills/)) — drop-in
  `/changelog`, `/pr-describe`, and `/test-triage` skills with full `SKILL.md`
  manifests.
- **Standalone hook scripts** ([`tools/hooks/`](tools/hooks/)) — `block-secrets`,
  `format-on-write`, and `test-on-stop` as installable `.sh` files, each with
  dry-run instructions and a one-line install recipe.

### Changed
- README reorganized: new "Plugins and Skills" section, Benchmarks linked under
  Cost & Efficiency, Toolbox expanded with hooks and harness.

### Notes
- Benchmark numbers in the guide are representative (from the 2026-04-22 run
  against a medium Node.js repo). Rerun the harness in your own repo to get
  numbers that match your setup — the ratios travel; the absolutes don't.

## [1.2.0] - 2026-04-05

- CLAUDE.md examples for Django, Flutter, Rust, Spring Boot.
- Added cost estimation tool.
- Additional hook recipes.
- Clarified 1M-token context window implications across context/cost/perf/troubleshooting guides.

## [1.1.0] - 2026-03

- Guides for custom MCP servers, advanced architecture, enterprise patterns,
  cloud integration, case studies.

## [1.0.0]

- Initial release: fundamentals, workflows, permissions, advanced topics,
  cost/efficiency, and reference guides.
