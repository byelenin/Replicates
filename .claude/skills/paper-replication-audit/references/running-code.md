# Running and verifying code

## Before running
- Read the project CLAUDE.md for how scripts are meant to be run, expected sentinels and input fallbacks.
- Back up current outputs (e.g. `*.dta`, figures) to the scratchpad so you can compare.
- Check file timestamps and the tail of existing logs: a log ending in `--Break--` / `r(1)` means the last run was interrupted and the outputs on disk are from an earlier run.

## Stata in batch mode
- `stata-mp -b do file.do` writes `file.log` to the **shell's** current directory.
- A user `profile.do` may `cd` elsewhere at startup (and open its own log), so relative paths fail with `file … not found r(601)` and `c(pwd)` is not what you expect. Use `scripts/run_stata.sh <workdir> <dofile> [logdir]`, which writes a wrapper that `cd`s to an absolute path and then `do`es the script by absolute path.
- Check the log for: the script's success sentinel, `r(` error codes, `assertion is false`, and "residual too large"-type messages (but distinguish code echoes from actual output).
- Long simulations: run in the background and wait for the completion notification instead of polling.

## Comparing outputs
- Stata: `cf _all using old.dta, all` per file; then list the size of any mismatch. Differences ~1e-16 are summation-order noise.
- Python/R: compare with a tolerance and report max abs/rel difference per variable.

## When the original cannot run here (no MATLAB, missing toolbox, missing data)
- Say so explicitly. Verify against the paper's tables instead and note the precision limit (papers often round to integers).
- Do not claim the original "would produce" a number unless it is printed in the package or the paper.

## Verifying data moments
- Recompute every reported statistic from its stated formula (e.g. Var − Cov should equal the reported transitory variance; if it is exactly half, suspect a T=2 fixed-effect residual variance without dof correction).
- Before asserting a detail matters, compute the alternative (e.g. alternative weights) and report the size of the effect.
