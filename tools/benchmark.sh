#!/usr/bin/env bash
# benchmark.sh — reproducible Claude Code benchmark harness.
#
# Runs a fixed task set against one or more models in headless mode, captures
# token usage + wall time + cost, and emits a CSV. Designed to produce the kind
# of numbers reported in guides/benchmarks.md.
#
# Usage:
#   bash tools/benchmark.sh --repo /path/to/repo --models sonnet,haiku --out results.csv
#   bash tools/benchmark.sh --help
#
# Requires: claude (>= 2.1.92), jq, bc. Optional: a git-clean target repo.

set -euo pipefail

# ----- defaults -----
REPO="$PWD"
MODELS="sonnet-4.6"
OUT="benchmark-$(date +%Y%m%d-%H%M%S).csv"
RUNS=3
PLAN_MODE=""
TASKS="T1,T2,T3,T4,T5"

# Prices per million tokens, USD. Update when list prices change.
# Format: input,output  (cache-hit input is ~10% of input per Anthropic docs)
declare -A PRICE_IN PRICE_OUT
PRICE_IN[opus-4.7]=15.00     ; PRICE_OUT[opus-4.7]=75.00
PRICE_IN[sonnet-4.6]=3.00    ; PRICE_OUT[sonnet-4.6]=15.00
PRICE_IN[haiku-4.5]=0.80     ; PRICE_OUT[haiku-4.5]=4.00

usage() {
  cat <<'EOF'
benchmark.sh — reproducible Claude Code benchmark harness

Flags:
  --repo PATH         Target repo to benchmark against (default: $PWD)
  --models LIST       Comma-separated: opus-4.7,sonnet-4.6,haiku-4.5 (default: sonnet-4.6)
  --tasks LIST        Comma-separated task IDs (default: T1,T2,T3,T4,T5). See --list-tasks.
  --runs N            Runs per (model,task) cell; median reported (default: 3)
  --plan-mode         Also run with plan mode on for each task
  --out FILE          Output CSV path (default: benchmark-<timestamp>.csv)
  --list-tasks        Print the task catalog and exit
  --help              This message

Output CSV columns:
  task,model,run,plan_mode,input_tokens,output_tokens,duration_s,cost_usd,outcome

Notes:
  * Runs use `claude -p "<prompt>" --output-format json --model <model>`.
  * Each run starts a fresh session (no carry-over context).
  * Outcome is "pass" if claude exited 0 and produced non-empty output; "fail" otherwise.
    Deeper semantic pass/fail (did the test actually become green?) is task-specific and
    left to the reader — see the post-run hooks in TASK_POSTCHECK.
EOF
}

# ----- task catalog -----
# Each task: id | description | prompt | postcheck-command (optional, evaluated in $REPO)
read -r -d '' TASK_CATALOG <<'EOF' || true
T1|Fix a known failing test|Find the single failing test in this repo, fix it, and confirm the suite passes. Do not touch unrelated files.|
T2|Add --dry-run flag|Add a --dry-run flag to the CLI entrypoint that prints what would happen without executing. Update help text and add a test.|
T3|Rename function repo-wide|Rename UserService.fetchProfile to getProfile across the entire repo. Update all call sites and tests.|
T4|Write unit tests|Write a thorough unit test file for the primary module in src/ (pick the most central one). Aim for ~80% branch coverage.|
T5|Explain and flag risks|Explain the authentication flow in this repo. Flag any security risks or code smells you find. No edits — answer only.|
T6|Framework migration|Migrate the main HTTP framework one major version forward (e.g. Express 4→5, Flask 2→3). Update all deprecated APIs.|
EOF

list_tasks() {
  printf "%-4s  %s\n" "ID" "Description"
  printf "%-4s  %s\n" "--" "-----------"
  while IFS='|' read -r id desc _ _; do
    [ -z "$id" ] && continue
    printf "%-4s  %s\n" "$id" "$desc"
  done <<< "$TASK_CATALOG"
}

# ----- parse args -----
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)        REPO="$2"; shift 2;;
    --models)      MODELS="$2"; shift 2;;
    --tasks)       TASKS="$2"; shift 2;;
    --runs)        RUNS="$2"; shift 2;;
    --plan-mode)   PLAN_MODE="1"; shift;;
    --out)         OUT="$2"; shift 2;;
    --list-tasks)  list_tasks; exit 0;;
    --help|-h)     usage; exit 0;;
    *) echo "unknown flag: $1" >&2; usage; exit 1;;
  esac
done

# ----- preflight -----
for tool in claude jq bc; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "benchmark: missing required tool: $tool" >&2
    exit 1
  fi
done

if [ ! -d "$REPO" ]; then
  echo "benchmark: --repo is not a directory: $REPO" >&2
  exit 1
fi

# ----- helpers -----
median() {
  # median of stdin (one number per line). Simple sort + mid.
  sort -n | awk '
    { a[NR]=$1 }
    END {
      if (NR==0) { print 0; exit }
      if (NR%2==1) print a[(NR+1)/2]
      else print (a[NR/2] + a[NR/2+1]) / 2
    }'
}

cost_usd() {
  local model="$1" in_tokens="$2" out_tokens="$3"
  local pin="${PRICE_IN[$model]:-0}" pout="${PRICE_OUT[$model]:-0}"
  echo "scale=4; ($in_tokens * $pin + $out_tokens * $pout) / 1000000" | bc
}

get_task_prompt() {
  local want="$1"
  while IFS='|' read -r id _ prompt _; do
    [ "$id" = "$want" ] && { echo "$prompt"; return; }
  done <<< "$TASK_CATALOG"
  echo ""
}

# ----- run one cell -----
run_one() {
  local task="$1" model="$2" run="$3" plan="$4"
  local prompt; prompt="$(get_task_prompt "$task")"
  [ -z "$prompt" ] && { echo "unknown task: $task" >&2; return 1; }

  local plan_flag=""
  [ "$plan" = "1" ] && plan_flag="--permission-mode plan"

  local start end duration
  start=$(date +%s)

  # Run headless. --output-format json surfaces token usage in the result.
  local out
  if ! out="$(cd "$REPO" && claude -p "$prompt" --output-format json --model "$model" $plan_flag 2>/dev/null)"; then
    end=$(date +%s); duration=$((end - start))
    echo "$task,$model,$run,$plan,0,0,$duration,0.0000,fail"
    return 0
  fi

  end=$(date +%s); duration=$((end - start))

  local in_tokens out_tokens outcome cost
  in_tokens="$(echo "$out"  | jq -r '.usage.input_tokens  // 0')"
  out_tokens="$(echo "$out" | jq -r '.usage.output_tokens // 0')"
  outcome="$(echo "$out"    | jq -r 'if .result and (.result|length) > 0 then "pass" else "fail" end')"
  cost="$(cost_usd "$model" "$in_tokens" "$out_tokens")"

  echo "$task,$model,$run,$plan,$in_tokens,$out_tokens,$duration,$cost,$outcome"
}

# ----- main loop -----
echo "task,model,run,plan_mode,input_tokens,output_tokens,duration_s,cost_usd,outcome" > "$OUT"

IFS=',' read -ra task_list  <<< "$TASKS"
IFS=',' read -ra model_list <<< "$MODELS"

plan_modes=("0")
[ "$PLAN_MODE" = "1" ] && plan_modes=("0" "1")

total_cells=$(( ${#task_list[@]} * ${#model_list[@]} * ${#plan_modes[@]} * RUNS ))
cell=0

for task in "${task_list[@]}"; do
  for model in "${model_list[@]}"; do
    for plan in "${plan_modes[@]}"; do
      for run in $(seq 1 "$RUNS"); do
        cell=$((cell + 1))
        echo "[$cell/$total_cells] task=$task model=$model plan=$plan run=$run" >&2
        line="$(run_one "$task" "$model" "$run" "$plan")"
        echo "$line" | tee -a "$OUT"
      done
    done
  done
done

echo
echo "=== Summary (median per cell) ==="
echo

# Group by (task, model, plan) and print medians.
{
  echo "task|model|plan|in_med|out_med|dur_med|cost_med|pass_rate"
  tail -n +2 "$OUT" | awk -F, '
    {
      k=$1"|"$2"|"$4
      n[k]++
      in_v[k]=in_v[k]" "$5
      out_v[k]=out_v[k]" "$6
      dur_v[k]=dur_v[k]" "$7
      cost_v[k]=cost_v[k]" "$8
      if ($9=="pass") pass[k]++
    }
    END {
      for (k in n) {
        printf "%s|%s|%s|%s|%s|%s|%.0f%%\n", k, in_v[k], out_v[k], dur_v[k], cost_v[k], (pass[k]/n[k])*100
      }
    }' | while IFS='|' read -r task model plan in_v out_v dur_v cost_v pass; do
      in_med=$(echo "$in_v"    | tr ' ' '\n' | grep -v '^$' | median)
      out_med=$(echo "$out_v"  | tr ' ' '\n' | grep -v '^$' | median)
      dur_med=$(echo "$dur_v"  | tr ' ' '\n' | grep -v '^$' | median)
      cost_med=$(echo "$cost_v"| tr ' ' '\n' | grep -v '^$' | median)
      echo "$task|$model|$plan|$in_med|$out_med|${dur_med}s|\$$cost_med|$pass"
    done
} | column -t -s '|'

echo
echo "Wrote raw results to: $OUT"
