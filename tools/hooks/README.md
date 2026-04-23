# Standalone Hook Scripts

Drop-in hook scripts you can wire into `.claude/settings.json` (project) or `~/.claude/settings.json` (user). Each script reads the hook JSON payload from stdin, does its job, and exits with:

- `0` — allow / silent success
- `2` — block the tool call and surface stderr to Claude

## Scripts

| Script | Event | What it does |
|--------|-------|--------------|
| [block-secrets.sh](block-secrets.sh) | `PreToolUse` (Write, Edit) | Refuses to write AWS keys, private keys, common API tokens, or `.env` file contents |
| [format-on-write.sh](format-on-write.sh) | `PostToolUse` (Write, Edit) | Runs `prettier`/`gofmt`/`rustfmt`/`ruff format` on just-written files if the formatter is installed |
| [test-on-stop.sh](test-on-stop.sh) | `Stop` | Runs your project's test command once Claude finishes, and reports pass/fail back into the next turn |

## Install (one-liner)

```bash
# Per-project
mkdir -p .claude/hooks && \
  curl -fsSL https://raw.githubusercontent.com/<your-fork>/claude-code-best-practices/main/tools/hooks/block-secrets.sh \
  -o .claude/hooks/block-secrets.sh && chmod +x .claude/hooks/block-secrets.sh
```

Then add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "bash .claude/hooks/block-secrets.sh" }]
      }
    ]
  }
}
```

## Install (local clone)

If you've cloned this repo, just symlink:

```bash
ln -s "$(pwd)/tools/hooks" .claude/hooks
```

Then reference them as `bash .claude/hooks/<script>.sh` in your settings.

## Testing a hook

Each script accepts the hook JSON on stdin. You can dry-run:

```bash
echo '{"tool_input":{"file_path":"test.env","content":"AWS_SECRET=..."}}' | bash tools/hooks/block-secrets.sh
echo $?   # should be 2
```
