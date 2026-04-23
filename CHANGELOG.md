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
- **Starter kits** ([`starters/`](starters/)) — whole-project drop-in kits with
  `CLAUDE.md` and `.claude/` (settings, skills, hooks) for React, Python, and
  Go. Each kit is self-contained (hook scripts copied in, not referenced) so
  it can be dropped into a project with a single `cp -r`.
- **Security Playbook** ([`guides/security-playbook.md`](guides/security-playbook.md)) —
  covers prompt injection from tool results, plugin supply chain, per-repo and
  per-user audit checklists, and a recommended default `.claude/settings.json`.
- **Published site** — [`mkdocs.yml`](mkdocs.yml) + `requirements-docs.txt`
  wire up mkdocs-material with search, nav mirroring the README sections, and
  a dark/light palette. Deployed via [`.github/workflows/docs.yml`](.github/workflows/docs.yml)
  to GitHub Pages on every push to `main`.
- **Benchmarks workflow (bring your own key)** —
  [`.github/workflows/benchmarks.yml`](.github/workflows/benchmarks.yml) wires
  up the harness to run in CI, commit CSVs to
  [`benchmarks/history/YYYY-MM-DD.csv`](benchmarks/history/), and regenerate
  [`benchmarks/latest.md`](benchmarks/latest.md) via
  [`tools/benchmark-summary.sh`](tools/benchmark-summary.sh). The nightly
  cron is **commented out** — running the harness bills the owner of
  `ANTHROPIC_API_KEY` for tokens, and this repo isn't funding that right now.
  Manual `workflow_dispatch` still works; uncomment the `schedule:` block on
  a fork with a key set to turn nightly on.
- **CI quality gates** ([`.github/workflows/`](.github/workflows/)):
  - `shellcheck.yml` — shellcheck on every `.sh` on push/PR (fails on warnings).
  - `markdownlint.yml` — `markdownlint-cli` against all markdown with a shared
    `.markdownlint.json`.
  - `links.yml` — `lychee` link checker on push/PR and a weekly schedule to
    catch external rot.
  - `lint-claude-md.yml` — runs `tools/lint-claude-md.sh` against every
    `examples/claude-md-*.md` and the repo's own `CLAUDE.md`.
- Status badges for six CI workflows in the README, plus a link to the
  published site.
- **Awesome list** ([`awesome.md`](awesome.md)) — curated community plugins,
  skills, essays, talks, and adjacent tooling, with explicit inclusion
  criteria so it stays signal-heavy.
- **Decision trees** ([`guides/decision-trees.md`](guides/decision-trees.md)) —
  Mermaid flowcharts for "which model?" and "plan mode when?" with
  plain-text fallbacks for viewers without Mermaid support, calibrated from
  the benchmark numbers.
- **Issue and PR templates** ([`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/),
  [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md)) —
  bug, tool/workflow, and guide request forms with `config.yml` routing
  open-ended questions to Discussions; PR template checklist ties to the
  style rules in `CONTRIBUTING.md`.
- **Social preview card** ([`.github/social-preview.svg`](.github/social-preview.svg))
  — 1280×640 SVG source. [`.github/README.md`](.github/README.md) documents
  how to render it to PNG and upload it via repo settings.
- **Extra README badges** — License, PRs-welcome, and Awesome-list badges;
  new Community section linking the awesome list, Discussions, and Issues.

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
