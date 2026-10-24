---
name: changelog
description: Generate or update CHANGELOG.md with an entry for the unreleased changes since the last git tag. Invoke when the user asks to cut a release, update the changelog, or summarize changes since v-something.
allowed-tools: Bash(git tag:*), Bash(git log:*), Bash(git describe:*), Bash(git diff:*), Read, Edit, Write
---

# Changelog

Produce or update `CHANGELOG.md` in the Keep-a-Changelog format.

## Steps

1. `git describe --tags --abbrev=0` to find the most recent tag. If no tag exists, use the repo's first commit and tell the user there's no prior tag.
2. `git log <last-tag>..HEAD --oneline --no-merges` to enumerate commits.
3. Read the existing `CHANGELOG.md` if present. Match its headings, casing, and date format. If missing, create one with the Keep-a-Changelog header.
4. Group commits into sections — **Added, Changed, Fixed, Removed, Deprecated, Security** — by inspecting subject prefixes (`feat:` → Added, `fix:` → Fixed, `refactor:`/`perf:` → Changed, etc.). Merge trivial commits into one bullet.
5. Ask the user for the new version number (semver). Do not guess.
6. Insert a new `## [x.y.z] - YYYY-MM-DD` section above the previous release. Move "Unreleased" content in if present.
7. Show the diff before writing. Write only after confirmation.

## Rules

- Rewrite commit subjects into user-facing language. "feat: add FOO" → "Added FOO that does X."
- Drop internal-only commits (`chore(deps)`, CI-only changes) unless they affect consumers.
- Do not create a git tag. Do not commit. Hand the finished file back to the user.

## Output

Print the new section you added, then stop.
