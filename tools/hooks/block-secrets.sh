#!/usr/bin/env bash
# PreToolUse hook for Write and Edit. Blocks writes that contain obvious secrets
# or target known-sensitive filenames. Exits 2 to block; writes diagnostics to stderr.
set -euo pipefail

input="$(cat)"

# Extract file_path and content from the tool_input JSON. Prefer jq if present;
# fall back to portable sed so the hook works on minimal systems.
if command -v jq >/dev/null 2>&1; then
  file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
  content="$(printf '%s' "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')"
else
  file_path="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  content="$(printf '%s' "$input" | sed -n 's/.*"content"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | head -1)"
  [ -z "$content" ] && content="$(printf '%s' "$input" | sed -n 's/.*"new_string"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | head -1)"
fi

violations=()

case "$file_path" in
  *.env|*.env.*|*.pem|*.key|*/id_rsa|*/id_ed25519|*credentials*.json|*service-account*.json)
    violations+=("sensitive filename: $file_path")
    ;;
esac

check() {
  local pattern="$1" label="$2"
  if printf '%s' "$content" | grep -Eq "$pattern"; then
    violations+=("$label")
  fi
}

check 'AKIA[0-9A-Z]{16}'                                              "AWS access key"
check 'aws_secret_access_key[[:space:]]*=[[:space:]]*[A-Za-z0-9/+=]{40}' "AWS secret key"
check '-----BEGIN (RSA |OPENSSH |EC |DSA |PGP )?PRIVATE KEY-----'     "private key block"
check 'xox[baprs]-[A-Za-z0-9-]{10,}'                                  "Slack token"
check 'ghp_[A-Za-z0-9]{36}'                                           "GitHub PAT"
check 'sk-(ant-)?[A-Za-z0-9_-]{20,}'                                  "API key (Anthropic/OpenAI style)"
check 'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}' "JWT"

if [ ${#violations[@]} -gt 0 ]; then
  {
    echo "block-secrets: refusing write. Found:"
    printf '  - %s\n' "${violations[@]}"
    echo
    echo "If this is a placeholder or test fixture, scrub the value or move the file out of the repo."
  } >&2
  exit 2
fi

exit 0
