#!/usr/bin/env bash
# PostToolUse hook for Write and Edit. Formats the just-written file with the
# appropriate tool if it's installed on PATH. Silent on success, logs to stderr
# on formatter failure (but does not block — exit 0 either way).
set -euo pipefail

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
else
  file_path="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

run() {
  # Run a formatter, swallow its output unless it fails.
  if ! "$@" >/dev/null 2>&1; then
    echo "format-on-write: $1 failed on $file_path" >&2
  fi
}

case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.md|*.yaml|*.yml|*.html)
    if command -v prettier >/dev/null 2>&1; then
      run prettier --write "$file_path"
    fi
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      run ruff format "$file_path"
    elif command -v black >/dev/null 2>&1; then
      run black --quiet "$file_path"
    fi
    ;;
  *.go)
    if command -v gofmt >/dev/null 2>&1; then
      run gofmt -w "$file_path"
    fi
    ;;
  *.rs)
    if command -v rustfmt >/dev/null 2>&1; then
      run rustfmt --quiet "$file_path"
    fi
    ;;
  *.rb)
    if command -v rubocop >/dev/null 2>&1; then
      run rubocop -a --format quiet "$file_path"
    fi
    ;;
  *.sh|*.bash)
    if command -v shfmt >/dev/null 2>&1; then
      run shfmt -w "$file_path"
    fi
    ;;
esac

exit 0
