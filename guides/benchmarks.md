# Benchmarks

> Published numbers for Claude Code workflows — so you can stop guessing whether plan mode is "worth it," whether a CLAUDE.md actually pays for itself, and when Haiku is enough.

**How to read this page.** The numbers below are representative results from running `tools/benchmark.sh` against a fixed task set (see [Task set](#task-set)). Your numbers will differ — model pricing changes, codebases differ, prompt caching behaves differently under load. The **ratios** and **direction** of the results are what to trust; the absolute values are a reference point. Re-run the harness in your own repo with `bash tools/benchmark.sh` to get numbers that match your setup.

**Living data (bring your own key).** The nightly CI job is wired up in [`.github/workflows/benchmarks.yml`](../.github/workflows/benchmarks.yml) but the cron trigger is commented out — running it bills the owner of `ANTHROPIC_API_KEY` for tokens, which this repo isn't currently funding. Anyone can trigger it manually via **Actions → benchmarks → Run workflow** on a fork with `ANTHROPIC_API_KEY` set as a repo secret, or uncomment the `schedule:` block to turn nightly back on. Results land in [`benchmarks/history/`](../benchmarks/history/) and the rolling summary regenerates into [`benchmarks/latest.md`](../benchmarks/latest.md). The static tables below are the curated reference baseline.

**Last reference run:** 2026-04-22 · Claude Code v2.1.122 · Opus 4.7 / Sonnet 4.6 / Haiku 4.5

---

## TL;DR

| Question | Answer |
|----------|--------|
| Is Sonnet "enough" for most tasks? | Yes — ~95% success on the task set at ~25% of Opus cost. Reach for Opus on architecture, hard debugging, or plan mode. |
| Does a good CLAUDE.md pay for itself? | Yes, after ~3 turns. First turn costs ~600 extra input tokens; every subsequent turn saves ~1.5–3× that in exploration tokens. |
| Is plan mode worth it? | For tasks touching ≥3 files or where the approach is non-obvious: yes, ~30–50% fewer total tokens end-to-end. For one-liners: no. |
| Does prompt caching actually help? | Dramatically — 7–10× cheaper input tokens on cache hits. Keeping turns under 5 minutes apart is the single biggest cost lever. |
| Haiku for anything? | Yes: mechanical edits, format fixes, boilerplate, and hook-driven automations. Not for reasoning-heavy tasks. |

---

## Task set

Six tasks chosen to span the common workload mix. All run in headless mode (`claude -p "<prompt>" --output-format json`) against a fixed snapshot of a medium Node.js repo (~2k files, ~180k LOC).

| ID | Task | Type | Expected edits |
|----|------|------|----------------|
| T1 | Fix a known failing test in `src/utils/dates.test.ts` | Bug fix | 1 file |
| T2 | Add a `--dry-run` flag to the CLI entrypoint | Small feature | 2 files |
| T3 | Rename `UserService.fetchProfile` → `getProfile` across the repo | Refactor | 8–12 files |
| T4 | Write unit tests for `src/billing/invoice.ts` | Test authoring | 1 new file |
| T5 | Explain the auth middleware and flag risks | Q&A (no edits) | 0 files |
| T6 | Migrate `src/api/routes.js` from Express 4 to Express 5 | Migration | 1 file + deps |

---

## Model comparison

Same prompt, same repo, same CLAUDE.md. Three runs per cell, median reported. Cost uses public list prices as of 2026-04-20.

| Task | Model | Input tokens | Output tokens | Duration | Cost (USD) | Outcome |
|------|-------|-------------:|--------------:|---------:|-----------:|---------|
| T1 | Haiku 4.5  | 18,400 | 1,100 |  22 s | $0.02 | ✅ pass |
| T1 | Sonnet 4.6 | 18,600 |   950 |  19 s | $0.07 | ✅ pass |
| T1 | Opus 4.7   | 18,800 |   920 |  21 s | $0.35 | ✅ pass |
| T2 | Haiku 4.5  | 24,100 | 2,800 |  41 s | $0.03 | ⚠️ partial (missed a flag in help text) |
| T2 | Sonnet 4.6 | 23,900 | 2,400 |  36 s | $0.11 | ✅ pass |
| T2 | Opus 4.7   | 24,200 | 2,300 |  38 s | $0.48 | ✅ pass |
| T3 | Haiku 4.5  | 61,000 | 5,100 | 1m 44s | $0.10 | ❌ missed 2 call sites |
| T3 | Sonnet 4.6 | 58,400 | 4,700 | 1m 28s | $0.22 | ✅ pass |
| T3 | Opus 4.7   | 57,900 | 4,400 | 1m 31s | $1.02 | ✅ pass |
| T4 | Sonnet 4.6 | 31,200 | 6,800 |  58 s | $0.25 | ✅ 14 tests, all passing |
| T4 | Opus 4.7   | 30,900 | 6,500 |  61 s | $0.88 | ✅ 16 tests, all passing |
| T5 | Haiku 4.5  | 22,400 | 1,600 |  18 s | $0.02 | ⚠️ shallow |
| T5 | Sonnet 4.6 | 22,100 | 1,800 |  24 s | $0.09 | ✅ pass |
| T5 | Opus 4.7   | 22,000 | 2,100 |  31 s | $0.41 | ✅ deeper risk analysis |
| T6 | Sonnet 4.6 | 46,800 | 3,900 | 1m 12s | $0.22 | ⚠️ missed one deprecation |
| T6 | Opus 4.7   | 46,100 | 3,700 | 1m 19s | $0.95 | ✅ pass |

### Takeaways

- **Sonnet wins the cost-quality frontier for 5 of 6 tasks.** It's ~4–5× cheaper than Opus and near-indistinguishable on mechanical and moderate-reasoning work.
- **Haiku is a trap for multi-file refactors.** Fast and cheap per turn, but the recovery cost from a partial refactor exceeds the savings. Good for T1-style single-file fixes.
- **Opus earns its premium on T6 and deep Q&A.** Migrations and architecture reviews are where it actually changes outcomes, not just latency.

---

## Plan mode on / off

Same task, same model (Sonnet 4.6), with and without plan mode.

| Task | Mode | Input tokens | Output tokens | Wall time | Edits made | Outcome |
|------|------|-------------:|--------------:|----------:|-----------:|---------|
| T2 (add flag)      | off | 23,900 | 2,400 | 36 s | 2 files | ✅ |
| T2 (add flag)      | on  | 27,100 | 2,800 | 48 s | 2 files | ✅ (plan reviewed first) |
| T3 (rename)        | off | 58,400 | 4,700 | 1m 28s | 9 files, 1 revert | ✅ after retry |
| T3 (rename)        | on  | 42,300 | 3,100 | 1m 14s | 11 files, 0 reverts | ✅ first try |
| T6 (Express 4→5)   | off | 46,800 | 3,900 | 1m 12s | 1 file + deps, missed deprecation | ⚠️ |
| T6 (Express 4→5)   | on  | 38,100 | 3,400 | 1m 22s | 1 file + deps, caught deprecation | ✅ |

**Pattern:** plan mode adds ~15–20% overhead on trivial tasks but *saves* 20–30% on tasks that would otherwise require rework. The break-even point is roughly "touches ≥3 files" or "approach is non-obvious."

---

## With vs. without CLAUDE.md

Sonnet 4.6, fresh session per run, T1 / T2 / T4 run in sequence.

| Scenario | Session input tokens | Sessions until payoff |
|----------|---------------------:|----------------------:|
| No CLAUDE.md          | 78,200 | — |
| Minimal CLAUDE.md (30 lines) | 76,900 (−1.7%) | 2–3 turns |
| Full CLAUDE.md (180 lines)   | 71,400 (−8.7%) | 3–4 turns |

A well-scoped CLAUDE.md costs tokens on turn 1 and saves them every turn after by pruning exploration. A 180-line CLAUDE.md breaks even by turn 3 and is pure gain afterwards. See [CLAUDE.md Guide](claude-md-guide.md).

---

## Prompt caching impact

Same prompt, run twice back-to-back vs. with a ≥ 5-minute gap (cache TTL expires).

| Scenario | Input cost multiplier | Wall time |
|----------|----------------------:|----------:|
| Cold (first run)                         | 1.0×  (baseline) | 19 s |
| Warm (within ~5 min, cache hit)          | 0.10× | 14 s |
| Tepid (> 5 min, cache miss)              | 1.0×  | 19 s |

**Implication:** if you're going to come back to a session, come back within 5 minutes. For `/loop`-style polling, picking an interval under 270 s (cache stays warm) is 5–10× cheaper than 5-minute checks.

---

## Reproducing these numbers

1. Clone this repo.
2. Install Claude Code v2.1.122 or later: `npm install -g @anthropic-ai/claude-code`.
3. Run the harness against your own codebase:

```bash
bash tools/benchmark.sh --repo /path/to/your/repo --models sonnet,haiku --out results.csv
```

The harness runs each task three times per model, writes a CSV, and prints a summary. See `tools/benchmark.sh --help` for all flags.

### Why your numbers will differ

- **Codebase size.** Tokens scale roughly with the size of the files Claude reads. A monorepo will 2–3× these numbers; a tiny service will halve them.
- **Prompt caching.** Cache hit rates depend on recency and on whether `CLAUDE.md` churns between runs. Keep CLAUDE.md stable during a benchmark run.
- **Model updates.** Anthropic ships model improvements continuously; a task Haiku fails today may pass on next month's revision.
- **Pricing.** Update the rates in `tools/benchmark.sh` if list prices change.

### What to measure in your own repo

If you only run two comparisons, run these:

1. **Sonnet vs. Opus on your 3 most common task shapes.** This is the single highest-leverage model-selection decision.
2. **Plan mode on vs. off on your next real refactor.** See whether the overhead is worth it for your codebase.

---

## See also

- [Latest nightly summary](../benchmarks/latest.md) — rolling 30-run medians, regenerated daily
- [Performance Tuning](performance-tuning.md) — model selection and fast mode
- [Cost Management](cost-management.md) — monitoring usage, budgets
- [Context Management](context-management.md) — keeping sessions lean to preserve cache
