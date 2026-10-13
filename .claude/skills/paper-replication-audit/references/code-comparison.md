# Cross-language code comparison checklist

Compare behaviour, not syntax. For each item, note: same / different-but-equivalent (show why) / different (consequence).

## Randomness
- Generators differ across languages (MATLAB `twister` vs Mata `rseed` vs NumPy PCG64): same seed ≠ same draws. Results can only be statistically equivalent; say so.
- Seed placement: fixed once vs per scenario vs per simulation index (common random numbers).
- Copulas, multivariate draws: compare the sampling formula algebraically (e.g. conditional inverse for Frank). Watch numerical cancellation at extreme dependence (use log-sum-exp).
- Parameter conversions done by toolbox functions (`copulaparam`, `gamrnd` parametrisation shape/scale vs shape/rate) need explicit re-implementation and a check.

## Data handling (Stata-specific traps included)
- Merge semantics: legacy `merge id using` with non-unique keys behaves like sequential matching (≈ `merge m:m`), not a Cartesian product (`joinby`). Preserve the original's behaviour if the sample depends on it.
- Missing values: Stata missing is +∞ in comparisons (`x > 1` true for missing); `~=` with missing; R `NA` propagation; MATLAB `NaN` comparisons false.
- `collapse (stat)` side effects on variables you did not mean to aggregate (e.g. weights).
- Weights: `aw` vs `fw` vs `pw`; which year's weight in panels; unweighted vs weighted can matter a lot.
- Filters written in two passes (e.g. drop rules that combine into "age difference exactly +1") vs what the comment says.
- Deflators, units, sample years, supplementary samples (e.g. CPS 2001 SCHIP).
- Data vintage: re-downloaded data (CEPR, PWT, WDI) can differ from the authors' copy.

## Numerics
- Optimizer defaults: `fminsearch` TolFun/TolX/MaxIter; whether non-convergence only warns.
- Root finders on |E| vs signed E.
- Indexing (1- vs 0-based), column order (which column is which sector), vector orientation.
- Integer division, float precision, `set type double` in Stata profiles.
- Multithreaded sums (Stata MP) differ at 1e-16.

## Program structure
- MATLAB globals and `save/load parameter_vector` passing parameters between functions: make sure every parameter reaches every function in the port.
- Functions with different behaviour depending on `nargout` (MATLAB).
- Hard-coded paths and `cd` calls; undefined variables in drivers (the original may not run as-is).
- Dead code / commented-out alternatives — they often reveal what the paper describes vs what was run.

## Measurement conventions
- At whose prices is GDP measured (benchmark country vs "rich country")?
- Productivity = output per worker vs per efficiency unit.
- Ratios: rich/poor vs poor/rich; normalisations (US = 1).
- Contribution decompositions in multiplicative models: use logs.

## Reporting format
Table: item | original (file:line) | replication (file:line) | status | note.
