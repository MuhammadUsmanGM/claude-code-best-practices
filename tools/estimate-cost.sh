#!/usr/bin/env bash
#
# estimate-cost.sh — Claude Code cost estimator
# Estimates token usage and cost for common tasks based on codebase size.
#
# Usage:
#   bash tools/estimate-cost.sh                    # Analyze current directory
#   bash tools/estimate-cost.sh /path/to/project   # Analyze a specific project
#
# This tool gives rough estimates based on typical Claude Code usage patterns.
# Actual costs depend on conversation length, model choice, and task complexity.

set -euo pipefail

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
  BOLD="\033[1m"
  DIM="\033[2m"
  CYAN="\033[36m"
  GREEN="\033[32m"
  YELLOW="\033[33m"
  RESET="\033[0m"
else
  BOLD="" DIM="" CYAN="" GREEN="" YELLOW="" RESET=""
fi

PROJECT_DIR="${1:-.}"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: Directory not found: $PROJECT_DIR"
  exit 1
fi

echo -e "${BOLD}${CYAN}Claude Code Cost Estimator${RESET}"
echo -e "${DIM}Analyzing: $(cd "$PROJECT_DIR" && pwd)${RESET}"
echo ""

# ── Gather project metrics ───────────────────────────────────────────────

# Count source files (exclude node_modules, .git, vendor, build directories)
FILE_COUNT=$(find "$PROJECT_DIR" \
  -type f \
  \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
     -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" \
     -o -name "*.rb" -o -name "*.dart" -o -name "*.swift" -o -name "*.kt" \
     -o -name "*.css" -o -name "*.scss" -o -name "*.html" -o -name "*.vue" \
     -o -name "*.svelte" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.git/*" \
  ! -path "*/vendor/*" \
  ! -path "*/dist/*" \
  ! -path "*/build/*" \
  ! -path "*/.next/*" \
  ! -path "*/target/*" \
  ! -path "*/__pycache__/*" \
  2>/dev/null | wc -l | tr -d ' ')

# Count total lines of source code
TOTAL_LINES=$(find "$PROJECT_DIR" \
  -type f \
  \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
     -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" \
     -o -name "*.rb" -o -name "*.dart" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.git/*" \
  ! -path "*/vendor/*" \
  ! -path "*/dist/*" \
  ! -path "*/build/*" \
  ! -path "*/.next/*" \
  ! -path "*/target/*" \
  ! -path "*/__pycache__/*" \
  -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')

# Estimate average tokens per line (rough: 1 line ~= 10 tokens)
TOKENS_PER_LINE=10
TOTAL_TOKENS=$((TOTAL_LINES * TOKENS_PER_LINE))

# Check for CLAUDE.md
HAS_CLAUDE_MD="No"
CLAUDE_MD_LINES=0
if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
  HAS_CLAUDE_MD="Yes"
  CLAUDE_MD_LINES=$(wc -l < "$PROJECT_DIR/CLAUDE.md" | tr -d ' ')
fi

# ── Display project metrics ──────────────────────────────────────────────

echo -e "${BOLD}Project Metrics${RESET}"
echo -e "  Source files:        $FILE_COUNT"
echo -e "  Lines of code:       $TOTAL_LINES"
echo -e "  Est. total tokens:   $TOTAL_TOKENS"
echo -e "  CLAUDE.md:           $HAS_CLAUDE_MD ($CLAUDE_MD_LINES lines)"
echo ""

# ── Pricing (as of April 2026) ───────────────────────────────────────────
# Prices per million tokens

HAIKU_INPUT=1.00
HAIKU_OUTPUT=5.00
SONNET_INPUT=3.00
SONNET_OUTPUT=15.00
OPUS_INPUT=15.00
OPUS_OUTPUT=75.00

# ── Estimate costs per task type ─────────────────────────────────────────

# Helper: calculate cost in dollars (input_tokens, output_tokens, price_in, price_out)
calc_cost() {
  local input_k=$1
  local output_k=$2
  local price_in=$3
  local price_out=$4
  echo "scale=3; ($input_k * $price_in / 1000) + ($output_k * $price_out / 1000)" | bc 2>/dev/null || echo "N/A"
}

echo -e "${BOLD}Estimated Cost Per Task${RESET}"
echo -e "${DIM}(Rough estimates — actual costs vary with task complexity and conversation length)${RESET}"
echo ""

# Task definitions: (name, input_tokens_K, output_tokens_K, description)
printf "  %-30s %-10s %-10s %-10s\n" "Task" "Haiku" "Sonnet" "Opus"
echo -e "  ${DIM}──────────────────────────────────────────────────────────────${RESET}"

# Simple question / explanation (~5K in, ~1K out)
H=$(calc_cost 5 1 $HAIKU_INPUT $HAIKU_OUTPUT)
S=$(calc_cost 5 1 $SONNET_INPUT $SONNET_OUTPUT)
O=$(calc_cost 5 1 $OPUS_INPUT $OPUS_OUTPUT)
printf "  %-30s %-10s %-10s %-10s\n" "Quick question" "\$$H" "\$$S" "\$$O"

# Bug fix (~20K in, ~3K out)
H=$(calc_cost 20 3 $HAIKU_INPUT $HAIKU_OUTPUT)
S=$(calc_cost 20 3 $SONNET_INPUT $SONNET_OUTPUT)
O=$(calc_cost 20 3 $OPUS_INPUT $OPUS_OUTPUT)
printf "  %-30s %-10s %-10s %-10s\n" "Single bug fix" "\$$H" "\$$S" "\$$O"

# Small feature (~50K in, ~10K out)
H=$(calc_cost 50 10 $HAIKU_INPUT $HAIKU_OUTPUT)
S=$(calc_cost 50 10 $SONNET_INPUT $SONNET_OUTPUT)
O=$(calc_cost 50 10 $OPUS_INPUT $OPUS_OUTPUT)
printf "  %-30s %-10s %-10s %-10s\n" "Small feature" "\$$H" "\$$S" "\$$O"

# Code review (~30K in, ~5K out)
H=$(calc_cost 30 5 $HAIKU_INPUT $HAIKU_OUTPUT)
S=$(calc_cost 30 5 $SONNET_INPUT $SONNET_OUTPUT)
O=$(calc_cost 30 5 $OPUS_INPUT $OPUS_OUTPUT)
printf "  %-30s %-10s %-10s %-10s\n" "Code review (PR)" "\$$H" "\$$S" "\$$O"

# Large feature / refactor (~150K in, ~30K out)
H=$(calc_cost 150 30 $HAIKU_INPUT $HAIKU_OUTPUT)
S=$(calc_cost 150 30 $SONNET_INPUT $SONNET_OUTPUT)
O=$(calc_cost 150 30 $OPUS_INPUT $OPUS_OUTPUT)
printf "  %-30s %-10s %-10s %-10s\n" "Large feature / refactor" "\$$H" "\$$S" "\$$O"

# Full codebase audit (~200K in, ~20K out)
H=$(calc_cost 200 20 $HAIKU_INPUT $HAIKU_OUTPUT)
S=$(calc_cost 200 20 $SONNET_INPUT $SONNET_OUTPUT)
O=$(calc_cost 200 20 $OPUS_INPUT $OPUS_OUTPUT)
printf "  %-30s %-10s %-10s %-10s\n" "Full codebase audit" "\$$H" "\$$S" "\$$O"

# Multi-agent team session (~500K in, ~100K out)
H=$(calc_cost 500 100 $HAIKU_INPUT $HAIKU_OUTPUT)
S=$(calc_cost 500 100 $SONNET_INPUT $SONNET_OUTPUT)
O=$(calc_cost 500 100 $OPUS_INPUT $OPUS_OUTPUT)
printf "  %-30s %-10s %-10s %-10s\n" "Multi-agent team session" "\$$H" "\$$S" "\$$O"

echo ""

# ── Cost-saving tips ─────────────────────────────────────────────────────

echo -e "${BOLD}Cost-Saving Tips${RESET}"
echo ""
echo "  - Use Haiku for simple tasks (explain, review, summarize)"
echo "  - Use Sonnet for most development work (default)"
echo "  - Use Opus only for complex architecture, hard bugs, or large refactors"
echo "  - Run /compact regularly to reduce context size and cost"
echo "  - Use --max-turns to limit runaway agentic loops"
echo "  - Scope prompts narrowly (one file > whole directory)"

if [ "$HAS_CLAUDE_MD" = "No" ]; then
  echo ""
  echo -e "  ${YELLOW}TIP:${RESET} Add a CLAUDE.md to reduce exploration tokens — Claude"
  echo "  will know your project structure without reading every file."
fi

echo ""
echo -e "${DIM}Prices based on Anthropic API pricing as of April 2026.${RESET}"
echo -e "${DIM}Actual costs depend on caching, context reuse, and conversation patterns.${RESET}"
