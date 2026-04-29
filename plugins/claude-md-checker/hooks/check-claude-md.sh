#!/usr/bin/env bash
# PreToolUse hook for Edit/Write. Runs tools/lint-claude-md.sh against any
# target file whose basename is CLAUDE.md, and blocks the write if the lint
# reports errors (exit 2 from the linter).
#
# Hook input arrives on stdin as JSON; we read tool_input.file_path.
set -euo pipefail

input="$(cat)"

# Extract file_path from tool_input. jq if available; sed fallback.
if command -v jq >/dev/null 2>&1; then
  file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
else
  file_path="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi

[ -z "$file_path" ] && exit 0

# Only guard CLAUDE.md edits. Match the basename so nested CLAUDE.md files
# (e.g. starters/react/CLAUDE.md) are also checked.
case "$(basename -- "$file_path")" in
  CLAUDE.md) ;;
  *) exit 0 ;;
esac

# Locate the linter. Prefer one inside the current repo; fall back to the
# plugin's own copy if shipped alongside.
linter=""
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -x "${CLAUDE_PROJECT_DIR}/tools/lint-claude-md.sh" ]; then
  linter="${CLAUDE_PROJECT_DIR}/tools/lint-claude-md.sh"
elif [ -x "./tools/lint-claude-md.sh" ]; then
  linter="./tools/lint-claude-md.sh"
fi

if [ -z "$linter" ]; then
  # No linter available; do not block. The user may not be in a repo that
  # ships it, and we shouldn't fail open writes for that reason.
  exit 0
fi

# The linter expects a path on disk. On Edit, the file already exists. On
# Write to a new file, lint the existing version if any; otherwise skip.
if [ ! -f "$file_path" ]; then
  exit 0
fi

if ! output="$(bash "$linter" "$file_path" 2>&1)"; then
  rc=$?
  # Exit code 2 from the linter == errors. Anything else (1 = warnings) we
  # let through so the user isn't blocked on style nits.
  if [ "$rc" -eq 2 ]; then
    {
      echo "claude-md-checker: lint-claude-md.sh reported errors in $file_path"
      echo
      printf '%s\n' "$output"
      echo
      echo "Fix the errors above, then retry the write."
    } >&2
    exit 2
  fi
fi

exit 0
