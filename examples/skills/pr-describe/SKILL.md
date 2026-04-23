---
name: pr-describe
description: Write a pull-request title and body from the current branch's commits and diff against the base branch. Invoke when the user asks to open a PR, draft a PR description, or summarize a branch.
allowed-tools: Bash(git branch:*), Bash(git log:*), Bash(git diff:*), Bash(git remote:*), Bash(gh pr view:*)
---

# PR Describe

Draft a pull-request title and body. Do **not** open the PR — hand the text to the user.

## Steps

1. Detect the base branch: check `git remote show origin | grep 'HEAD branch'`, fall back to `main`.
2. `git log <base>..HEAD --no-merges --reverse --format='%h %s%n%b'` — read every commit, not just the latest.
3. `git diff <base>...HEAD --stat` for scope, then targeted `git diff <base>...HEAD -- <path>` for files that look important.
4. If a PR template exists at `.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE.md`, follow its structure.

## Title

- ≤ 70 characters, imperative mood, no trailing period.
- Prefix with a Conventional Commits type only if the repo's existing PR titles do.

## Body

Default structure (unless a template overrides):

```markdown
## Summary
<2-4 bullets: what changed and why — not a commit list>

## Changes
<grouped, human-readable bullets; collapse noisy refactors>

## Test plan
- [ ] <explicit verification step>
- [ ] <explicit verification step>

## Notes
<risks, migrations, follow-ups — omit the section if empty>
```

## Rules

- Focus on *why*, not *what*. The diff already shows *what*.
- Never invent issue numbers or Jira tickets. Only include `Closes #N` if a commit message references it.
- If the branch is empty relative to base, stop and tell the user.
- Do not run `gh pr create` or push. Output the title and body as a single markdown block the user can paste.

## Output

Exactly two fenced blocks: `title` and `body`. Nothing else.
