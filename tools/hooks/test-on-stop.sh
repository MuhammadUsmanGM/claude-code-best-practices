#!/usr/bin/env bash
# Stop hook. Runs the project's test command after Claude finishes a turn and
# surfaces pass/fail to the next turn. Skips if the repo has no tests or if a
# previous invocation set CLAUDE_SKIP_TESTS=1 in the user's shell.
set -euo pipefail

# Respect an opt-out flag set in the hook settings or shell.
if [ "${CLAUDE_SKIP_TESTS:-0}" = "1" ]; then
  exit 0
fi

# Detect a test command by inspecting common project markers.
cmd=""
if [ -f package.json ] && grep -q '"test"' package.json 2>/dev/null; then
  cmd="npm test --silent"
elif { [ -f pyproject.toml ] || [ -f pytest.ini ] || [ -f setup.cfg ]; } && command -v pytest >/dev/null 2>&1; then
  cmd="pytest -q"
elif [ -f go.mod ]; then
  cmd="go test ./..."
elif [ -f Cargo.toml ]; then
  cmd="cargo test --quiet"
elif [ -f Gemfile ] && [ -d spec ]; then
  cmd="bundle exec rspec --format progress"
elif [ -f Makefile ] && grep -Eq '^test:' Makefile 2>/dev/null; then
  cmd="make test"
fi

if [ -z "$cmd" ]; then
  # No known test runner — stay silent so we don't spam Claude's output.
  exit 0
fi

log="$(mktemp -t claude-tests.XXXXXX)"
if $cmd >"$log" 2>&1; then
  echo "test-on-stop: passed ($cmd)"
  rm -f "$log"
  exit 0
else
  status=$?
  echo "test-on-stop: FAILED ($cmd, exit=$status)"
  echo "---- last 40 lines ----"
  tail -40 "$log"
  rm -f "$log"
  # Exit 0 so we don't trap Claude in a loop; the output itself signals failure.
  exit 0
fi
