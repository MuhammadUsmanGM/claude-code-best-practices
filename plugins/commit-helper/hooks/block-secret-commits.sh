#!/usr/bin/env bash
# PreToolUse hook for Bash. Blocks `git commit` when staged content looks like secrets.
# Hook input arrives on stdin as JSON; we read tool_input.command.
set -euo pipefail

input="$(cat)"
bash_cmd="$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | head -1)"

# Only guard `git commit` invocations.
case "$bash_cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

if ! command -v git >/dev/null 2>&1; then
  exit 0
fi

staged="$(git diff --cached --name-only 2>/dev/null || true)"
[ -z "$staged" ] && exit 0

violations=()

# 1. Known-sensitive filenames.
while IFS= read -r f; do
  case "$f" in
    *.env|*.env.*|*.pem|*.key|id_rsa|id_ed25519|*credentials*.json|*service-account*.json)
      violations+=("sensitive filename: $f")
      ;;
  esac
done <<< "$staged"

# 2. Content patterns in the staged diff.
diff_content="$(git diff --cached -U0 2>/dev/null || true)"
check_pattern() {
  local pattern="$1" label="$2"
  if printf '%s' "$diff_content" | grep -Eq -- "$pattern"; then
    violations+=("$label")
  fi
}

check_pattern 'AKIA[0-9A-Z]{16}'                              "AWS access key"
check_pattern 'aws_secret_access_key[[:space:]]*=[[:space:]]*[A-Za-z0-9/+=]{40}' "AWS secret key"
check_pattern '-----BEGIN (RSA |OPENSSH |EC |DSA |PGP )?PRIVATE KEY-----'        "private key block"
check_pattern 'xox[baprs]-[A-Za-z0-9-]{10,}'                  "Slack token"
check_pattern 'ghp_[A-Za-z0-9]{36}'                           "GitHub personal access token"
check_pattern 'sk-(ant-)?[A-Za-z0-9_-]{20,}'                  "API key (Anthropic/OpenAI style)"

if [ ${#violations[@]} -gt 0 ]; then
  {
    echo "block-secret-commits: refusing to commit. Found:"
    printf '  - %s\n' "${violations[@]}"
    echo
    echo "Unstage the file or scrub the value, then retry."
  } >&2
  exit 2   # exit code 2 tells Claude Code to block the tool call and show stderr
fi

exit 0
