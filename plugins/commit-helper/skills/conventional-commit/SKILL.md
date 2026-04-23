---
name: conventional-commit
description: Generate a Conventional Commits message for the staged diff and (optionally) create the commit. Invoke when the user asks to commit, write a commit message, or finalize staged work.
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*)
---

# Conventional Commit

You are being invoked to turn the current staged diff into a single, well-formed Conventional Commits message.

## Steps

1. Run `git status --short` and `git diff --cached --stat`. If nothing is staged, run `git diff --stat` and ask the user whether to stage everything or a subset. Do not guess.
2. Run `git diff --cached` (or `git diff` if nothing staged yet) to read the actual changes.
3. Run `git log -10 --oneline` to match the repo's existing commit style (scope naming, casing).
4. Draft a message:
   - **type**: one of `feat|fix|docs|refactor|perf|test|chore|build|ci|style|revert`
   - **scope**: optional, derived from the top-level directory or package touched
   - **subject**: imperative, ≤ 72 chars, no trailing period
   - **body**: only if the *why* isn't obvious from the subject. Wrap at 72.
   - **footer**: `BREAKING CHANGE:` or `Closes #123` only when applicable
5. Show the message to the user and ask for confirmation *unless* they already said "commit it" / "just commit."
6. On confirmation, run `git commit -m "..."` using a heredoc for multi-line bodies.

## Rules

- Never include `Co-Authored-By` lines unless the user asks.
- Never `git push`.
- Never `--amend` a commit that's already been pushed.
- If pre-commit hooks fail, fix the underlying issue and create a *new* commit. Do not `--no-verify`.

## Output

After committing, print the short SHA and subject line. Nothing else.
