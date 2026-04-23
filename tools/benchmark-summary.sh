#!/usr/bin/env bash
# benchmark-summary.sh — aggregates all benchmark CSVs under benchmarks/history/
# into a single benchmarks/latest.md with trend tables.
#
# Usage:
#   bash tools/benchmark-summary.sh                  # write benchmarks/latest.md
#   bash tools/benchmark-summary.sh path/to/history  # custom history dir
#
# Emits a markdown document with:
#   - A "Latest run" table (most recent CSV).
#   - A "30-day trend" table: median input/output tokens and cost per (task, model),
#     averaged across the most recent 30 daily runs.
#
# Designed to be safe to run with zero history (produces a placeholder doc).

set -euo pipefail

HISTORY_DIR="${1:-benchmarks/history}"
OUT="${2:-benchmarks/latest.md}"

mkdir -p "$(dirname "$OUT")"

shopt -s nullglob
csvs=("$HISTORY_DIR"/*.csv)
shopt -u nullglob

if [ ${#csvs[@]} -eq 0 ]; then
  cat > "$OUT" <<'EOF'
# Benchmarks — latest

No benchmark runs yet. The nightly workflow will populate
`benchmarks/history/YYYY-MM-DD.csv` and this file will regenerate automatically.

Run locally: `bash tools/benchmark.sh --models sonnet-4.6 --out benchmarks/history/$(date +%Y-%m-%d).csv`.
EOF
  echo "No CSVs in $HISTORY_DIR — wrote placeholder to $OUT"
  exit 0
fi

# Sort by filename (YYYY-MM-DD.csv) so "last" is the most recent.
IFS=$'\n' sorted=($(printf '%s\n' "${csvs[@]}" | sort))
latest_csv="${sorted[-1]}"
latest_date="$(basename "$latest_csv" .csv)"

# Last 30 daily runs.
if [ ${#sorted[@]} -gt 30 ]; then
  trend_csvs=("${sorted[@]: -30}")
else
  trend_csvs=("${sorted[@]}")
fi

trend_window="${#trend_csvs[@]}"

# median of stdin (one number per line).
median() {
  sort -n | awk '
    { a[NR]=$1 }
    END {
      if (NR==0) { print 0; exit }
      if (NR%2==1) print a[(NR+1)/2]
      else print (a[NR/2] + a[NR/2+1]) / 2
    }'
}

{
  echo "# Benchmarks — latest"
  echo
  echo "_Generated $(date -u +%Y-%m-%dT%H:%M:%SZ) from \`$HISTORY_DIR\` (most recent run: \`$latest_date\`; trend window: last $trend_window runs)._"
  echo
  echo "## Latest run — $latest_date"
  echo
  echo "| task | model | plan | input | output | duration (s) | cost (USD) | outcome |"
  echo "|------|-------|------|------:|-------:|-------------:|-----------:|---------|"
  tail -n +2 "$latest_csv" | awk -F, '{
    printf "| %s | %s | %s | %s | %s | %s | $%s | %s |\n", $1,$2,$4,$5,$6,$7,$8,$9
  }'
  echo
  echo "## $trend_window-run trend (median per task × model)"
  echo
  echo "| task | model | median input | median output | median duration (s) | median cost (USD) | runs |"
  echo "|------|-------|-------------:|--------------:|--------------------:|------------------:|-----:|"

  # Build an aggregate keyed by "task|model" from all trend CSVs (plan_mode=0 only for trend).
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  for f in "${trend_csvs[@]}"; do
    tail -n +2 "$f" | awk -F, '$4==0 { print $1","$2","$5","$6","$7","$8 }' >> "$tmp"
  done

  # Sort and group.
  sort -t, -k1,1 -k2,2 "$tmp" | awk -F, '
    {
      key = $1 "|" $2
      if (key != prev && NR > 1) flush()
      prev = key; task = $1; model = $2
      n++
      in_v[n]  = $3
      out_v[n] = $4
      dur_v[n] = $5
      cost_v[n]= $6
    }
    END { flush() }
    function flush(    i, tmpf, cmd, m_in, m_out, m_dur, m_cost) {
      if (n == 0) return
      # median helper per field via sort
      m_in  = med(in_v,  n)
      m_out = med(out_v, n)
      m_dur = med(dur_v, n)
      m_cost= med(cost_v,n)
      printf "| %s | %s | %s | %s | %s | $%s | %d |\n", task, model, m_in, m_out, m_dur, m_cost, n
      delete in_v; delete out_v; delete dur_v; delete cost_v
      n = 0
    }
    function med(arr, count,   i, sorted, tmp) {
      for (i=1; i<=count; i++) sorted[i] = arr[i]
      # insertion sort (counts are small)
      for (i=2; i<=count; i++) {
        tmp = sorted[i]; j = i-1
        while (j>=1 && sorted[j] > tmp) { sorted[j+1] = sorted[j]; j-- }
        sorted[j+1] = tmp
      }
      if (count % 2 == 1) return sorted[(count+1)/2]
      return (sorted[count/2] + sorted[count/2+1]) / 2
    }'
  echo
  echo "## History"
  echo
  echo "| date | runs |"
  echo "|------|-----:|"
  for f in "${sorted[@]}"; do
    d="$(basename "$f" .csv)"
    n=$(( $(wc -l < "$f") - 1 ))
    [ "$n" -lt 0 ] && n=0
    echo "| $d | $n |"
  done
  echo
  echo "## See also"
  echo
  echo "- [Benchmarks guide](../guides/benchmarks.md) — methodology and interpretation"
  echo "- [tools/benchmark.sh](../tools/benchmark.sh) — the harness that produced these numbers"
} > "$OUT"

echo "Wrote $OUT ($latest_date latest, $trend_window-run trend)"
