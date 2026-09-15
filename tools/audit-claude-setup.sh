#!/usr/bin/env bash
# audit-claude-setup.sh -- score a project's Claude Code configuration.
#
# Checks CLAUDE.md, .claude/settings.json, permission rules, and hook wiring,
# then prints a 0-100 score with per-check results and targeted suggestions.
#
# Usage:
#   bash tools/audit-claude-setup.sh [path] [--strict]
#
# Exit codes:
#   0  score >= 60 (or --strict with no outright failures)
#   1  score < 60, bad arguments, or --strict with at least one FAIL

set -euo pipefail

usage() {
  cat <<'EOF'
audit-claude-setup.sh -- score a project's Claude Code configuration.

Usage:
  bash tools/audit-claude-setup.sh [path] [--strict]

Options:
  path       Project root to audit (default: current directory)
  --strict   Exit 1 if any check fails outright, regardless of score
  -h, --help Show this help

Exit codes:
  0  Score >= 60 (or --strict with no outright failures)
  1  Score < 60, or --strict with at least one FAIL
EOF
}

TARGET="."
STRICT=0
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) printf 'audit: unknown option: %s\n\n' "$arg" >&2; usage >&2; exit 1 ;;
    *) TARGET="$arg" ;;
  esac
done

if [ ! -d "$TARGET" ]; then
  printf 'audit: target directory not found: %s\n' "$TARGET" >&2
  exit 1
fi

SCORE=0
FAILURES=0

add_points() { SCORE=$((SCORE + $1)); }
pass() { printf '  [PASS] %s\n' "$1"; add_points "$2"; }
warn() { printf '  [WARN] %s\n' "$1"; add_points "$2"; }
fail() { printf '  [FAIL] %s\n' "$1"; FAILURES=$((FAILURES + 1)); }
hint() { printf '  [hint] %s\n' "$1"; }

HAVE_JQ=0
HAVE_PY=0
if command -v jq >/dev/null 2>&1; then HAVE_JQ=1; fi
if command -v python3 >/dev/null 2>&1; then HAVE_PY=1; fi

claude_md="$TARGET/CLAUDE.md"
settings="$TARGET/.claude/settings.json"
gitignore="$TARGET/.gitignore"

json_ok=0

printf 'Auditing Claude Code setup in: %s\n\n' "$TARGET"

printf 'CLAUDE.md\n'
if [ -f "$claude_md" ]; then
  pass "CLAUDE.md present at project root" 15

  h2_count="$(grep -c '^## ' "$claude_md" || true)"
  case "$h2_count" in
    ''|0)
      fail "CLAUDE.md has no ## sections -- add Commands, Architecture, and Conventions at minimum"
      ;;
    1|2)
      warn "CLAUDE.md has only $h2_count ## section(s) -- want 3 or more (Commands, Architecture, Conventions)" 5
      ;;
    *)
      pass "CLAUDE.md structure: $h2_count ## sections" 10
      ;;
  esac

  lines="$(wc -l < "$claude_md" | tr -d ' ')"
  if [ "$lines" -ge 20 ] && [ "$lines" -le 400 ]; then
    pass "CLAUDE.md length: $lines lines" 5
  else
    warn "CLAUDE.md length: $lines lines (sweet spot is 20-400; long files stop getting read)" 2
  fi
else
  fail "CLAUDE.md missing at project root (see guides/claude-md-guide.md for what belongs in it)"
fi

printf '\n.claude/settings.json\n'
if [ ! -f "$settings" ]; then
  fail ".claude/settings.json missing -- permissions and hooks live there"
else
  pass ".claude/settings.json present" 15

  if [ "$HAVE_JQ" -eq 1 ]; then
    if jq empty "$settings" >/dev/null 2>&1; then json_ok=1; fi
  elif [ "$HAVE_PY" -eq 1 ]; then
    if python3 -m json.tool "$settings" >/dev/null 2>&1; then json_ok=1; fi
  fi

  if [ "$json_ok" -eq 1 ]; then
    if grep -Eq -- 'sk-ant-[A-Za-z0-9_-]{10,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|-----BEGIN [A-Z ]*PRIVATE KEY-----' "$settings"; then
      fail "settings.json contains what looks like a secret -- move it to the environment, never into settings"
    else
      pass "settings.json parses as valid JSON and contains no obvious secrets" 10
    fi
  elif [ "$HAVE_JQ" -eq 0 ] && [ "$HAVE_PY" -eq 0 ]; then
    warn "cannot validate settings.json -- install jq or python3 for a full audit" 5
  else
    fail "settings.json is not valid JSON"
  fi
fi

if [ -f "$settings" ] && [ "$json_ok" -eq 1 ] && [ "$HAVE_JQ" -eq 1 ]; then
  allow_count="$(jq '.permissions.allow // [] | length' "$settings")"
  deny_count="$(jq '.permissions.deny // [] | length' "$settings")"
  deny_text="$(jq -r '.permissions.deny // [] | join(" ")' "$settings")"

  printf '\nPermissions\n'
  if [ "$allow_count" -gt 0 ]; then
    pass "permissions.allow has $allow_count rule(s)" 15
  else
    fail "permissions.allow is empty -- allowlist your hot-path commands (test, lint, fmt)"
  fi

  push_denied="$(printf '%s' "$deny_text" | grep -c 'git push' || true)"
  if [ "$deny_count" -eq 0 ]; then
    warn "permissions.deny is empty -- deny Bash(git push:*) and Bash(rm -rf:*) at minimum" 5
  elif [ "$push_denied" -gt 0 ]; then
    pass "git push is denied" 10
  else
    warn "permissions.deny exists but does not block git push" 5
  fi

  printf '\nHooks\n'
  hook_count="$(jq '[.. | objects | .command? // empty] | length' "$settings")"
  if [ "$hook_count" -gt 0 ]; then
    pass "hooks configured ($hook_count hook command(s))" 10
  else
    warn "no hooks configured -- a PreToolUse block-secrets hook is the highest-value addition" 5
  fi

  missing_hooks=0
  while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    # Intentional word split: each whitespace-separated token is a candidate path.
    # shellcheck disable=SC2086
    for token in $cmd; do
      case "$token" in
        .claude/*.sh)
          if [ ! -f "$TARGET/$token" ]; then
            missing_hooks=$((missing_hooks + 1))
            hint "hook script referenced in settings.json not found: $token"
          fi
          ;;
      esac
    done
  done < <(jq -r '.. | objects | .command? // empty' "$settings")

  if [ "$missing_hooks" -eq 0 ]; then
    pass "all referenced .claude/hooks/*.sh scripts exist on disk" 5
  else
    fail "$missing_hooks hook script(s) referenced in settings.json not found on disk"
  fi
fi

printf '\nHygiene\n'
if [ -f "$gitignore" ] && grep -q 'settings.local.json' "$gitignore"; then
  pass ".claude/settings.local.json is gitignored" 5
elif [ -f "$gitignore" ]; then
  warn ".gitignore does not cover .claude/settings.local.json -- personal overrides will leak into commits" 2
else
  warn "no .gitignore -- add .claude/settings.local.json before committing personal overrides" 2
fi

printf '\nSuggestions\n'
if [ ! -f "$TARGET/.claudeignore" ]; then
  hint "no .claudeignore -- exclude build output and secrets-adjacent files from Claude's reads (see guides/security-practices.md)"
fi
if [ -d "$TARGET/.claude/skills" ]; then
  skill_count="$(find "$TARGET/.claude/skills" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
  if [ "$skill_count" -eq 0 ]; then
    hint ".claude/skills/ exists but holds no SKILL.md files -- add one for your most repeated workflow"
  else
    hint ".claude/skills/ has $skill_count skill(s) -- two or three focused ones beat a large pile"
  fi
else
  hint "no .claude/skills/ -- codify your team's most repeated workflow as a skill (see guides/skills-and-slash-commands.md)"
fi

printf '\nScore: %d/100\n' "$SCORE"
if [ "$SCORE" -ge 85 ]; then
  printf 'Result: strong setup -- minor polish available\n'
elif [ "$SCORE" -ge 60 ]; then
  printf 'Result: workable -- close the WARN items above\n'
else
  printf 'Result: needs work -- start with the FAIL items\n'
fi

if [ "$STRICT" -eq 1 ] && [ "$FAILURES" -gt 0 ]; then
  exit 1
fi
if [ "$SCORE" -lt 60 ]; then
  exit 1
fi
exit 0
