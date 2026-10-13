#!/usr/bin/env bash
# Run a Stata do-file in batch mode with a guaranteed working directory.
# A user profile.do may `cd` elsewhere at startup, which breaks relative paths;
# this writes a wrapper that cds to an absolute path, then runs the script.
#
# Usage: run_stata.sh <workdir> <dofile> [logdir]
#   workdir  directory Stata should cd into (scripts read/write c(pwd))
#   dofile   path to the do-file (made absolute)
#   logdir   where the batch log goes (default: a temp dir); prints its path
set -euo pipefail
[ $# -ge 2 ] || { sed -n '2,10p' "$0"; exit 2; }
WORK=$(cd "$1" && pwd -P)
DOF=$(cd "$(dirname "$2")" && pwd -P)/$(basename "$2")
LOGDIR=${3:-$(mktemp -d)}
mkdir -p "$LOGDIR"
STATA=${STATA:-$(command -v stata-mp || command -v stata-se || command -v stata || true)}
[ -n "$STATA" ] || { echo "Stata executable not found (set STATA=...)"; exit 3; }
NAME=$(basename "$DOF" .do)
WRAP="$LOGDIR/run_${NAME}.do"
printf 'cd "%s"\ndo "%s"\n' "$WORK" "$DOF" > "$WRAP"
start=$(date +%s)
(cd "$LOGDIR" && "$STATA" -b do "$WRAP") || true
end=$(date +%s)
LOG="$LOGDIR/run_${NAME}.log"
echo "log: $LOG  (elapsed $((end-start))s)"
echo "--- errors / breaks ---"
grep -nE '^r\([0-9]+\);|--Break--|assertion is false' "$LOG" || echo "(none)"
echo "--- last lines ---"
tail -5 "$LOG"
