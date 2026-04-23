# Dogfooded `.claude/` for this repo

This directory shows how we use Claude Code on the very repo that teaches
Claude Code. Nothing here is magic — it's the same primitives (`settings.json`,
`skills/`, hooks) documented in `guides/`.

## What's wired up

### `settings.json`

- **PreToolUse → `tools/hooks/block-secrets.sh`** on `Write`/`Edit`.
  Stops anyone (human or Claude) from committing AWS keys, private keys, or
  common API tokens by accident. This is the same script shipped under
  `tools/hooks/` for readers to install.
- **PostToolUse → `tools/hooks/format-on-write.sh`** on `Write`/`Edit`.
  Auto-formats files after changes, silently if no formatter is installed.
- **Permissions.** A narrow allowlist for read-only git and the repo's own
  lint/benchmark scripts, plus a deny list that blocks `git push` and
  `rm -rf` so Claude can't fire destructive commands without explicit user
  override.

### `skills/lint-docs`

Repo-local skill that runs the three lint gates (shellcheck, markdownlint,
`lint-claude-md.sh`) the way CI runs them, so you can catch violations before
pushing. Invoke with `/lint-docs`.

## Install notes for your own project

Don't copy this file verbatim — copy the *pattern*:

1. Pin the hook scripts your team relies on in `.claude/settings.json` so every
   clone gets the same guardrails.
2. Keep the permissions list narrow. An allowlist beats a denylist for most
   repos; add items as Claude asks for them in practice.
3. Put repo-local skills under `.claude/skills/`. User-global skills belong in
   `~/.claude/skills/`.

## See also

- [CLAUDE.md](../CLAUDE.md) — how to work on this repo
- [guides/hooks.md](../guides/hooks.md) — hook reference
- [guides/security-practices.md](../guides/security-practices.md) — why
  block-secrets exists
- [tools/hooks/README.md](../tools/hooks/README.md) — the hook scripts
