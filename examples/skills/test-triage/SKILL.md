---
name: test-triage
description: Classify failing tests as flaky vs. real regressions and propose a next step for each. Invoke when the user pastes failing test output, asks to triage CI failures, or asks "are these tests flaky".
allowed-tools: Bash(git log:*), Bash(git blame:*), Read, Grep, Glob
---

# Test Triage

Given a batch of failing tests, classify each and propose one concrete action per test.

## Input sources

Prefer in this order:
1. Test output the user pasted.
2. A CI log file the user points at (Read it).
3. Running the test suite locally — only if the user asks.

## For each failing test

1. Read the test file and the code under test.
2. `git log -5 --follow <test-file>` and the same for the implementation. Look for changes in the last ~24h or the last PR.
3. Classify:
   - **Real regression** — behavior under test changed in a recent commit, or the assertion is logically correct and the implementation is wrong.
   - **Flaky** — test depends on wall-clock time, ordering, network, randomness, shared global state, or external services without a stub.
   - **Environmental** — passes locally, fails in CI (or vice versa) due to missing env, OS differences, or toolchain versions.
   - **Stale test** — intended behavior changed; the test wasn't updated.
4. Propose one action: *fix the code*, *update the test*, *stub the dependency*, *add a retry with rationale*, *delete the test*, *reproduce locally with <command>*.

## Output format

A table, one row per failing test:

| Test | Classification | Likely cause | Proposed action |
|------|----------------|--------------|-----------------|

Then, below the table, list the tests ranked by **fix-first priority** (real regressions > stale tests > environmental > flaky-with-high-frequency > low-frequency flakes).

## Rules

- Do not modify code or tests during triage. This skill only diagnoses.
- If you can't classify a test in under ~90 seconds of investigation, mark it `unknown` and say what you'd need.
- Flag any test that looks security-sensitive (auth, crypto, input validation) so the user doesn't wave it through as "flaky."
