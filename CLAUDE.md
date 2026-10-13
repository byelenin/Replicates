# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Teaching material for an NJU MicroEconometrics course (Fall 2026): replications of published economics papers, one folder per paper. Replication code is written in **Stata**. Comments, reports, and many file names are in Chinese. The folder is not a git repo and lives in a Synology Drive sync folder.

`readme.md` describes the planned layout as `paper/`, `original_code/`, `replication_code/` (each with `data/`, `code/`, `results/` and a README). The actual folders use different names:

```
<Author_Year>/
  Paper/           paper PDFs, plus a Chinese translation and slides
  Original_Code/   author replication package as published (code/, data/, Documents/readme.pdf)
  Students_Code/   the course's Stata replication: code/, data/, fig/, report.docx, a presentation PDF
```

Keep `Original_Code/` unmodified because it is the reference.

## Tooling

- `/usr/local/bin/stata-mp` is a symlink to **StataNow 19.5 MP** (`/Applications/StataNow/StataMP.app`). Stata 16 is also installed in `/Applications`. The student do-files declare `version 16.0` and use only built-in Stata and Mata, with no SSC packages.
- At startup Stata runs `/Applications/StataNow/profile.do`. That file runs `cd /Users/freeman/Dropbox/Stata/Log`, opens its own log and cmdlog there, and sets `set type double`. Because of the `cd`, `c(pwd)` is **not** the shell's working directory when a batch run begins.
- MATLAB is **not** installed, so the author's `.m` files cannot run here. Read them to get parameter values and check logic.

## Running the student do-files (Lagakos_Waugh_2013)

The student do-files resolve all inputs from `c(pwd)` and write every output (`.dta`, `.png`) to `c(pwd)`, so Stata's working directory must be `Students_Code/data/`. Do **not** run `cd data && stata-mp -b do ../code/X.do`. The `cd` in `profile.do` runs first, so the relative path fails with `file ... not found r(601)`. Instead, write a small wrapper do-file, preferably in the scratchpad, that uses absolute paths. It first `cd`s into `data/` and then runs the script:

```stata
* run_model.do  (wrapper; absolute paths)
local B "/Users/freeman/Library/CloudStorage/SynologyDrive-NJU/Teaching/2026Fall/MicroEconometrics/Replicates/Lagakos_Waugh_2013/Students_Code"
cd "`B'/data"
do "`B'/code/模型复现.do"     // or CPS工资统计.do / 跨国图形.do (needs model output)
```

```sh
cd <dir for the log> && stata-mp -b do /absolute/path/run_model.do
```

Batch mode writes `<wrapper name>.log` to the **shell's** current directory, not to `data/`. Run order: `CPS工资统计.do` and `模型复现.do` are independent. `跨国图形.do` reads `model_trends_demo.dta`. `模型复现.do` simulates 1,000,000 draws per economy and takes several minutes, so run it in the background.

Each script ends with a sentinel line: `__CPS_OK__`, `__MODEL_ALL_OK__`, or `__COUNTRY_OK__`. The scripts also contain `assert`s. Check the log for the sentinel or for `r(…)` errors. Exported figures land in `data/` and must be moved to `fig/` by hand. When an expected input is missing, each script falls back to `input_1.dta` / `input_2.dta`.

## Architecture: Lagakos & Waugh (2013, AER), "Selection, Agriculture, and Cross-Country Productivity Differences"

The pipeline has three independent pieces. Only the model and the figures depend on each other.

1. **`CPS工资统计.do`** is a step-by-step port of `Original_Code/code/Stata/lw_cps.do`. It reads `CPS_input.dta`, a stacked extract of the CEPR March CPS 1996–2010 that is asserted to have `_N==2685662`. It applies the author's minimum-wage filter, CPI deflation, and year-to-year panel matching (same sex and race, age +1, same sector). Then it computes weighted wage moments by sector. Outputs: `cps_matched`, `cps_moments`, `cps_covariance`, `cps_flow`. It deliberately keeps the author's `merge m:m` semantics instead of switching to `joinby`, because `joinby` would change the sample.
2. **`模型复现.do`** re-implements the MATLAB general-equilibrium model in Mata. It does **not** recalibrate. Parameters are copied by hand from the author's `run_*.m` drivers into the `cases` matrix: Section-4 baseline, Correlation-Table-Results tau ∈ {0, .2, …, .99}, Section-5 Aa variants, and Section-6 capital/land. Key pieces:
   - `talents()` draws N=1,000,000 Fréchet talent pairs coupled by a Frank copula, with fixed seed 32878. `frank()` maps Kendall tau to the Frank parameter.
   - `distribution` = [non-ag 1/θ, ag 1/θ, Kendall tau]. These are inverse shape parameters, not the paper's θ.
   - `state()` evaluates the economy at a sector cutoff. `solve()` bisects on that one-dimensional cutoff until the ag excess demand clears, and the assert checks every market residual.
   - Each scenario solves three economies: US, "rich" (A/1.26), and "poor". Outputs: `model_economies_demo`, `model_ratios_demo`, `model_parameters_demo`, and `model_trends_demo` (a 20-point GDP grid used for the figure curves).
3. **`跨国图形.do`** reproduces the author's `Section-4-Results/Figures1_5`. It plots country scatters from `country_input.dta`, which holds values transcribed from the author's `.mat` files, with `kind` 1–5 selecting the figure. The model curves come from `model_trends_demo.dta`.

Treat the author's MATLAB as the ground truth. When the Stata port changes a parameter or approximates something, record it in a comment. For example, Section-6 keeps `al=.001` as "near no land", and scenario 3 is an exact homogeneous-labor benchmark rather than a simulation.
