# Example Hook Scripts

These are ready-to-use hook configurations for `.claude/settings.json`. Each example includes the settings entry and any associated scripts. For background on how hooks work, see the [Hooks Guide](../guides/hooks.md).

## Auto-Format by File Type

A PostToolUse hook that runs the appropriate formatter whenever Claude edits a file.

`.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hook": "bash /path/to/your/project/.claude/hooks/auto-format.sh $CLAUDE_FILE_PATH"
      }
    ]
  }
}
```

`.claude/hooks/auto-format.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

FILE="$1"
EXT="${FILE##*.}"

case "$EXT" in
  ts|tsx|js|jsx|json|css|md)
    npx prettier --write "$FILE" 2>/dev/null
    ;;
  py)
    black --quiet "$FILE" 2>/dev/null
    ;;
  rs)
    rustfmt "$FILE" 2>/dev/null
    ;;
esac
```

## Pre-Commit Lint Gate

A PreToolUse hook that intercepts `git commit` commands and runs linting first. If the linter fails, the commit is blocked.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hook": "bash /path/to/your/project/.claude/hooks/pre-commit-lint.sh \"$CLAUDE_BASH_COMMAND\""
      }
    ]
  }
}
```

`.claude/hooks/pre-commit-lint.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

COMMAND="$1"

if echo "$COMMAND" | grep -q "git commit"; then
  echo "Running lint check before commit..."
  npm run lint
  # Non-zero exit here blocks the tool use
fi
```

## Desktop Notification on Task Complete

A Notification hook that alerts you when Claude finishes a task. Choose the variant for your OS.

**macOS:**

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hook": "osascript -e 'display notification \"$CLAUDE_NOTIFICATION\" with title \"Claude Code\"'"
      }
    ]
  }
}
```

**Linux:**

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hook": "notify-send 'Claude Code' \"$CLAUDE_NOTIFICATION\""
      }
    ]
  }
}
```

**Windows (PowerShell toast):**

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hook": "powershell -Command \"[console]::beep(600,300); Write-Host 'Claude: $env:CLAUDE_NOTIFICATION'\""
      }
    ]
  }
}
```

## Run Tests After Edits

A PostToolUse hook that runs the corresponding test file when a source file is edited.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hook": "bash /path/to/your/project/.claude/hooks/run-related-test.sh $CLAUDE_FILE_PATH"
      }
    ]
  }
}
```

`.claude/hooks/run-related-test.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

FILE="$1"

# Skip if the edited file is itself a test
if echo "$FILE" | grep -qE '\.(test|spec)\.(ts|js|py)$'; then
  exit 0
fi

# Derive test file path (adjust pattern to match your project)
TEST_FILE=$(echo "$FILE" | sed 's|src/|tests/|' | sed 's/\.\(ts\|js\)$/.test.\1/')

if [ -f "$TEST_FILE" ]; then
  echo "Running related test: $TEST_FILE"
  npx jest "$TEST_FILE" --no-coverage 2>&1 | tail -5
fi
```

## Audit Log

A PostToolUse hook that logs every tool invocation with a timestamp.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hook": "echo \"$(date -Iseconds) tool=$CLAUDE_TOOL_NAME file=$CLAUDE_FILE_PATH\" >> ~/.claude/audit-log.txt"
      }
    ]
  }
}
```

This produces output like:

```
2026-03-22T10:15:32+00:00 tool=Edit file=src/index.ts
2026-03-22T10:15:45+00:00 tool=Bash file=
```

## Block Dangerous Commands

A PreToolUse hook that rejects potentially destructive commands before they execute.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hook": "bash /path/to/your/project/.claude/hooks/block-dangerous.sh \"$CLAUDE_BASH_COMMAND\""
      }
    ]
  }
}
```

`.claude/hooks/block-dangerous.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

COMMAND="$1"

BLOCKED_PATTERNS=(
  "rm -rf /"
  "DROP TABLE"
  "DROP DATABASE"
  "git push --force.*main"
  "git push --force.*master"
  "git push -f.*main"
  "git push -f.*master"
  ":(){ :|:& };:"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qEi "$pattern"; then
    echo "BLOCKED: Command matches dangerous pattern: $pattern" >&2
    exit 1
  fi
done
```

## See Also

- [Hooks Guide](../guides/hooks.md) — how hooks work, lifecycle events, and environment variables
- [Security Practices](../guides/security-practices.md) — broader security guidance for Claude Code
- [Permission Modes](../guides/permission-modes.md) — controlling what Claude can do without approval
