# claude-md-checker

A Claude Code plugin that runs `tools/lint-claude-md.sh` automatically on every
`Edit` or `Write` to a `CLAUDE.md` file. If the linter reports errors (exit 2),
the write is blocked and the lint output surfaces in Claude's transcript so the
problems can be fixed in the same turn.

Useful for repos that maintain multiple `CLAUDE.md` files (monorepos, starter
kits, examples) where structure and content-quality drift quietly.

## Install

```bash
claude plugin install /path/to/claude-code-best-practices/plugins/claude-md-checker
```

Or copy the directory into `~/.claude/plugins/claude-md-checker/` and restart
Claude Code.

## Verify

```bash
claude /plugins
# Should list "claude-md-checker v1.0.0"
```

Then ask Claude to edit a `CLAUDE.md`. The hook fires before the write lands.

## Behavior

- **Triggers on:** `Edit` and `Write` whose target basename is `CLAUDE.md`.
- **Calls:** the project's own `tools/lint-claude-md.sh` (located via
  `$CLAUDE_PROJECT_DIR/tools/lint-claude-md.sh`, then `./tools/lint-claude-md.sh`).
- **Blocks on:** linter exit code `2` (errors). Warnings (exit `1`) are allowed
  through so you aren't blocked on style nits.
- **No linter, no block.** If neither path resolves to an executable linter,
  the hook exits `0` and the write proceeds. This keeps the plugin safe to
  install in repos that don't ship the linter.

## Uninstall

```bash
claude plugin remove claude-md-checker
```

## Files

- `plugin.json` — manifest
- `hooks/check-claude-md.sh` — `PreToolUse` guard

## License

MIT
