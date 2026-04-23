# commit-helper

A working Claude Code plugin that ships:

1. A `conventional-commit` skill — Claude writes Conventional Commits-style messages from the current diff.
2. A `PreToolUse` hook — blocks `git commit` when staged files contain obvious secrets (AWS keys, private keys, `.env` files).

## Install

```bash
# Clone this repo anywhere, then point Claude Code at the plugin:
claude plugin install /path/to/claude-code-best-practices/plugins/commit-helper
```

Or copy the directory into `~/.claude/plugins/commit-helper/` and restart Claude Code.

## Verify

```bash
claude /plugins
# Should list "commit-helper v1.0.0"
```

Inside Claude, invoke the skill:

```text
/conventional-commit
```

## Uninstall

```bash
claude plugin remove commit-helper
```

## Files

- `plugin.json` — manifest
- `skills/conventional-commit/SKILL.md` — the skill
- `hooks/block-secret-commits.sh` — PreToolUse guard

## License

MIT
