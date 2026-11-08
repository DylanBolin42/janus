#!/usr/bin/env bash
# Run from the repository root with Flutter installed through FVM.
# Generated logs and the temporary baseline worktree stay under .dart_tool.
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"
result_dir="$repo_root/.dart_tool/scheduler-verification"
mkdir -p "$result_dir"
baseline_ref=$(git merge-base HEAD origin/main)
baseline_dir=$(mktemp -d "$result_dir/baseline.XXXXXX")
rmdir "$baseline_dir"
cleanup() {
  git worktree remove --force "$baseline_dir" >/dev/null 2>&1 || true
}
trap cleanup EXIT

fvm dart format --output=none --set-exit-if-changed \
  lib/scheduling test/unit/scheduling
fvm flutter pub get
fvm flutter test --no-pub --concurrency=4 2>&1 | tee "$result_dir/tests.log"

# Existing warnings make analyze return 1. Compare diagnostics to the branch's
# main merge-base rather than treating that return code as a successful check.
set +e
fvm flutter analyze --no-pub > "$result_dir/analyze.log" 2>&1
branch_analysis_status=$?
set -e
if (( branch_analysis_status > 1 )); then
  cat "$result_dir/analyze.log"
  exit "$branch_analysis_status"
fi

git worktree add --detach "$baseline_dir" "$baseline_ref"
(
  cd "$baseline_dir"
  fvm flutter pub get
  set +e
  fvm flutter analyze --no-pub > "$result_dir/baseline-analyze.log" 2>&1
  baseline_status=$?
  if (( baseline_status > 1 )); then exit "$baseline_status"; fi
)
grep ' • ' "$result_dir/analyze.log" > "$result_dir/branch-diagnostics.txt" || true
grep ' • ' "$result_dir/baseline-analyze.log" > "$result_dir/baseline-diagnostics.txt" || true
diff -u "$result_dir/baseline-diagnostics.txt" "$result_dir/branch-diagnostics.txt"
printf 'Tests passed; analysis matches main merge-base %s. Logs: %s\n' \
  "$baseline_ref" "$result_dir"
