#!/usr/bin/env bash
#
# generate-claude-md.sh — Interactive CLAUDE.md generator
# Asks 7 questions about your project and outputs a ready-to-use CLAUDE.md file.
#
# Usage:
#   bash tools/generate-claude-md.sh
#   # or from your project directory:
#   bash /path/to/generate-claude-md.sh

set -euo pipefail

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
  BOLD="\033[1m"
  DIM="\033[2m"
  CYAN="\033[36m"
  GREEN="\033[32m"
  RESET="\033[0m"
else
  BOLD="" DIM="" CYAN="" GREEN="" RESET=""
fi

echo -e "${BOLD}${CYAN}CLAUDE.md Generator${RESET}"
echo -e "${DIM}Answer a few questions about your project. Press Enter to skip any question.${RESET}"
echo ""

# ── Question 1: Project name and description ────────────────────────────
read -rp "$(echo -e "${BOLD}1/7${RESET} Project name: ")" PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-My Project}"

read -rp "$(echo -e "${BOLD}     ${RESET} One-line description: ")" PROJECT_DESC

# ── Question 2: Language and framework ──────────────────────────────────
echo ""
echo -e "${DIM}Examples: React + TypeScript, Python + FastAPI, Go, Rust, Node.js + Express${RESET}"
read -rp "$(echo -e "${BOLD}2/7${RESET} Language/framework: ")" TECH_STACK

# ── Question 3: Build and run commands ──────────────────────────────────
echo ""
echo -e "${DIM}Examples: npm run dev, python manage.py runserver, go run ./cmd/server${RESET}"
read -rp "$(echo -e "${BOLD}3/7${RESET} Dev/build command: ")" BUILD_CMD
read -rp "$(echo -e "${BOLD}     ${RESET} Install dependencies command: ")" INSTALL_CMD

# ── Question 4: Test runner ─────────────────────────────────────────────
echo ""
echo -e "${DIM}Examples: npm test, pytest, go test ./..., cargo test${RESET}"
read -rp "$(echo -e "${BOLD}4/7${RESET} Test command: ")" TEST_CMD
read -rp "$(echo -e "${BOLD}     ${RESET} Single test command (optional): ")" SINGLE_TEST_CMD

# ── Question 5: Linting and formatting ──────────────────────────────────
echo ""
echo -e "${DIM}Examples: eslint + prettier, ruff, gofmt, rustfmt${RESET}"
read -rp "$(echo -e "${BOLD}5/7${RESET} Lint command: ")" LINT_CMD
read -rp "$(echo -e "${BOLD}     ${RESET} Format command: ")" FORMAT_CMD

# ── Question 6: Commit conventions ──────────────────────────────────────
echo ""
echo -e "${DIM}Examples: conventional commits, angular, none${RESET}"
read -rp "$(echo -e "${BOLD}6/7${RESET} Commit message style: ")" COMMIT_STYLE

# ── Question 7: Code style rules ────────────────────────────────────────
echo ""
echo -e "${DIM}Examples: prefer functional components, use early returns, no classes${RESET}"
read -rp "$(echo -e "${BOLD}7/7${RESET} Key code style rules (comma-separated): ")" STYLE_RULES

# ── Detect project structure ────────────────────────────────────────────
echo ""
echo -e "${DIM}Scanning current directory for project structure...${RESET}"

STRUCTURE=""
if [ -d "src" ]; then
  STRUCTURE=$(find src -maxdepth 2 -type d 2>/dev/null | head -15 | sed 's/^/- \//')
elif [ -d "app" ]; then
  STRUCTURE=$(find app -maxdepth 2 -type d 2>/dev/null | head -15 | sed 's/^/- \//')
elif [ -d "lib" ]; then
  STRUCTURE=$(find lib -maxdepth 2 -type d 2>/dev/null | head -15 | sed 's/^/- \//')
fi

# ── Generate the CLAUDE.md ──────────────────────────────────────────────
OUTPUT="CLAUDE.md"

{
  echo "# $PROJECT_NAME"
  echo ""

  if [ -n "$PROJECT_DESC" ]; then
    echo "$PROJECT_DESC"
    echo ""
  fi

  # Tech stack
  if [ -n "$TECH_STACK" ]; then
    echo "## Tech Stack"
    echo ""
    echo "$TECH_STACK"
    echo ""
  fi

  # Project structure
  if [ -n "$STRUCTURE" ]; then
    echo "## Project Structure"
    echo ""
    echo '```'
    echo "$STRUCTURE"
    echo '```'
    echo ""
  fi

  # Commands
  echo "## Commands"
  echo ""
  if [ -n "$INSTALL_CMD" ]; then
    echo "- Install: \`$INSTALL_CMD\`"
  fi
  if [ -n "$BUILD_CMD" ]; then
    echo "- Dev/Build: \`$BUILD_CMD\`"
  fi
  if [ -n "$TEST_CMD" ]; then
    echo "- Test: \`$TEST_CMD\`"
  fi
  if [ -n "$SINGLE_TEST_CMD" ]; then
    echo "- Single test: \`$SINGLE_TEST_CMD\`"
  fi
  if [ -n "$LINT_CMD" ]; then
    echo "- Lint: \`$LINT_CMD\`"
  fi
  if [ -n "$FORMAT_CMD" ]; then
    echo "- Format: \`$FORMAT_CMD\`"
  fi
  echo ""

  # Code style
  if [ -n "$STYLE_RULES" ] || [ -n "$COMMIT_STYLE" ]; then
    echo "## Code Style"
    echo ""
    if [ -n "$COMMIT_STYLE" ]; then
      echo "- Commit messages: $COMMIT_STYLE"
    fi
    if [ -n "$STYLE_RULES" ]; then
      IFS=',' read -ra RULES <<< "$STYLE_RULES"
      for rule in "${RULES[@]}"; do
        trimmed=$(echo "$rule" | xargs)
        if [ -n "$trimmed" ]; then
          echo "- $trimmed"
        fi
      done
    fi
    echo ""
  fi

  # Guidelines
  echo "## Guidelines"
  echo ""
  echo "- Read existing code before modifying to match patterns"
  echo "- Run tests after changes to verify nothing is broken"
  echo "- Keep changes focused and minimal"

} > "$OUTPUT"

echo ""
echo -e "${GREEN}${BOLD}Done!${RESET} Generated ${BOLD}$OUTPUT${RESET} in the current directory."
echo -e "${DIM}Review and customize it, then commit to your repo.${RESET}"
echo ""
echo -e "Preview:"
echo -e "${DIM}────────────────────────────────────────${RESET}"
cat "$OUTPUT"
echo -e "${DIM}────────────────────────────────────────${RESET}"
