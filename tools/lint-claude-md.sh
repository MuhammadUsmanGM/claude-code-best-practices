#!/usr/bin/env bash
#
# lint-claude-md.sh — CLAUDE.md linter/validator
# Checks a CLAUDE.md file for structure issues, common mistakes, and best practices.
#
# Usage:
#   bash tools/lint-claude-md.sh                  # Lint ./CLAUDE.md
#   bash tools/lint-claude-md.sh path/to/CLAUDE.md  # Lint a specific file
#
# Exit codes:
#   0 — all checks passed
#   1 — warnings found (non-blocking)
#   2 — errors found (should fix before using)

set -euo pipefail

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
  BOLD="\033[1m"
  RED="\033[31m"
  YELLOW="\033[33m"
  GREEN="\033[32m"
  DIM="\033[2m"
  RESET="\033[0m"
else
  BOLD="" RED="" YELLOW="" GREEN="" DIM="" RESET=""
fi

FILE="${1:-CLAUDE.md}"
ERRORS=0
WARNINGS=0

if [ ! -f "$FILE" ]; then
  echo -e "${RED}${BOLD}Error:${RESET} File not found: $FILE"
  echo "Usage: bash tools/lint-claude-md.sh [path/to/CLAUDE.md]"
  exit 2
fi

LINE_COUNT=$(wc -l < "$FILE")
CONTENT=$(cat "$FILE")

echo -e "${BOLD}CLAUDE.md Linter${RESET}"
echo -e "${DIM}Checking: $FILE ($LINE_COUNT lines)${RESET}"
echo ""

# ── Helper functions ─────────────────────────────────────────────────────

error() {
  echo -e "  ${RED}ERROR${RESET}   $1"
  ERRORS=$((ERRORS + 1))
}

warn() {
  echo -e "  ${YELLOW}WARN${RESET}    $1"
  WARNINGS=$((WARNINGS + 1))
}

pass() {
  echo -e "  ${GREEN}OK${RESET}      $1"
}

# ── Structure checks ─────────────────────────────────────────────────────

echo -e "${BOLD}Structure${RESET}"

# Check for H1 title
if echo "$CONTENT" | head -5 | grep -qE '^# '; then
  pass "Has H1 title"
else
  error "Missing H1 title — add a '# Project Name' as the first heading"
fi

# Check for Commands section
if echo "$CONTENT" | grep -qiE '^## Commands|^## Common Commands|^## Development Commands'; then
  pass "Has Commands section"
else
  error "Missing Commands section — Claude needs to know how to build, test, and lint"
fi

# Check for project structure
if echo "$CONTENT" | grep -qiE '^## (Architecture|Project Structure|Structure|Directory|File Structure)'; then
  pass "Has Architecture/Structure section"
else
  warn "No Architecture section — add one so Claude knows where files live"
fi

# Check for testing info
if echo "$CONTENT" | grep -qiE '^## Test|test command|pytest|jest|vitest|cargo test|go test'; then
  pass "Has testing information"
else
  warn "No testing information — tell Claude how to run tests"
fi

# Check for Do NOT / Don't section
if echo "$CONTENT" | grep -qiE '^## Do NOT|^## Don.t|^## Rules|^## Constraints'; then
  pass "Has guardrails section (Do NOT / Rules)"
else
  warn "No guardrails section — add a 'Do NOT' section to prevent common mistakes"
fi

echo ""

# ── Content quality checks ───────────────────────────────────────────────

echo -e "${BOLD}Content Quality${RESET}"

# Check file length
if [ "$LINE_COUNT" -lt 10 ]; then
  warn "Very short ($LINE_COUNT lines) — consider adding more project context"
elif [ "$LINE_COUNT" -gt 200 ]; then
  warn "Very long ($LINE_COUNT lines) — consider splitting into per-package CLAUDE.md files"
else
  pass "Good length ($LINE_COUNT lines)"
fi

# Check for backtick-wrapped commands
COMMAND_LINES=$(echo "$CONTENT" | grep -cE '`[a-z]+ (run |test|build|install|lint|format)' || true)
if [ "$COMMAND_LINES" -gt 0 ]; then
  pass "Commands are formatted with backticks"
else
  warn "Commands may not be backtick-formatted — wrap commands in backticks for clarity"
fi

# Check for vague instructions
if echo "$CONTENT" | grep -qiE 'write clean code|follow best practices|use good patterns|be careful'; then
  warn "Contains vague instructions — replace with specific, actionable rules"
else
  pass "No vague instructions detected"
fi

echo ""

# ── Common mistakes ──────────────────────────────────────────────────────

echo -e "${BOLD}Common Mistakes${RESET}"

# Check for hardcoded secrets
if echo "$CONTENT" | grep -qiE '(ghp_[a-zA-Z0-9]{20}|sk-[a-zA-Z0-9]{20}|password\s*[:=]\s*["\x27][^"\x27]+|api[_-]?key\s*[:=]\s*["\x27][^"\x27]+)'; then
  error "Possible hardcoded secret detected — never put real credentials in CLAUDE.md"
else
  pass "No hardcoded secrets detected"
fi

# Check for absolute paths
if echo "$CONTENT" | grep -qE '/(home|Users|var|opt|tmp)/[a-zA-Z]'; then
  warn "Contains absolute paths — use relative paths so the file works for all team members"
else
  pass "No problematic absolute paths"
fi

# Check for outdated model references
if echo "$CONTENT" | grep -qiE 'claude-2|claude-instant|claude-3-opus|claude-3-sonnet|claude-3-haiku'; then
  warn "Contains outdated Claude model references — update to current model names"
else
  pass "No outdated model references"
fi

# Check for empty sections
EMPTY_SECTIONS=$(echo "$CONTENT" | grep -cE '^## ' || true)
SECTIONS_WITH_CONTENT=0
IN_SECTION=false
HAS_CONTENT=false
while IFS= read -r line; do
  if echo "$line" | grep -qE '^## '; then
    if $IN_SECTION && ! $HAS_CONTENT; then
      warn "Empty section detected — remove or fill in: $line"
    fi
    IN_SECTION=true
    HAS_CONTENT=false
  elif $IN_SECTION && [ -n "$line" ] && ! echo "$line" | grep -qE '^#'; then
    HAS_CONTENT=true
  fi
done <<< "$CONTENT"

echo ""

# ── Summary ──────────────────────────────────────────────────────────────

echo -e "${DIM}────────────────────────────────────────${RESET}"
if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}All checks passed!${RESET} Your CLAUDE.md looks good."
  exit 0
elif [ "$ERRORS" -eq 0 ]; then
  echo -e "${YELLOW}${BOLD}$WARNINGS warning(s)${RESET} — consider addressing these for a better experience."
  exit 1
else
  echo -e "${RED}${BOLD}$ERRORS error(s)${RESET}, ${YELLOW}$WARNINGS warning(s)${RESET} — fix errors before relying on this CLAUDE.md."
  exit 2
fi
