---
name: paper-replication-audit
description: Audit and document the replication of a published economics paper. Compares the author's original replication package (code + data) with a student/course replication written in another language (e.g. MATLAB/R/Python → Stata/Mata), verifies the replication against the paper's tables by actually running it, explains in depth how parameters are estimated or calibrated (GMM, SMM, MLE, minimum distance, indirect inference, calibration) and how the model/equilibrium is solved, reviews the students' presentation slides, and writes technical notes, a replication comparison table, and a teaching deck. Use this skill whenever the user asks to check, verify, compare, audit, explain or document a replication (复现/復現/replicate/replication package), asks whether student code matches the original code or the paper, asks how a paper's model is solved or its parameters are estimated/calibrated, or asks to review a replication presentation — even if they only name one of these pieces.
---

# Paper replication audit

The job is to establish, with evidence, **what the replication reproduces, how faithfully, and why any differences arise**, and to turn that into teaching material that explains the paper's technical machinery (estimation/calibration and solution methods), not just its story.

The audience is a course instructor and students in a micro-econometrics course. They care about three things: is the replication correct, where exactly does it deviate (and is the deviation the replication's fault, the original code's, or the paper's), and do the students understand the estimation and solution methods.

## Expected folder layout

Each paper lives in its own folder (check the project CLAUDE.md for the actual names; they can differ from any readme):

```
<Author_Year>/
  Paper/           published PDF, online appendix, translations, student slides (.pptx/.pdf)
  Original_Code/   author's replication package — reference, never modify
  Students_Code/   the course replication: code/, data/, fig/, logs, report
```

Treat `Original_Code/` as read-only ground truth for *what the authors did*, and the published paper as ground truth for *what they claim*. These two can disagree; finding where is part of the job.

## Outputs

Write in the language the user is using (simplified vs traditional Chinese, or English), and name files in that script. Put them in the paper folder. Default set:

| File | Content |
|---|---|
| `技术说明.md` | The audit: coverage, code-to-code comparison, verification results, technical difficulties, estimation/calibration method, equilibrium solution, inconsistencies. Long-form, with appendices for deep dives. |
| `复现对照表.md` | Cell-by-cell comparison of every paper table/figure the replication covers vs replication output, with a status per row. |
| `PPT修改建议.md` | Review of the students' slides (only if slides exist). |
| `技术笔记.md` | Teaching notes: the model and the estimation/solution methods explained from first principles, with derivations, toy examples and code excerpts. Self-contained — a student should learn the method from it without reading the audit. |
| Teaching deck | Slides built from the teaching notes (see "Slides" below). |

If the user asks for only one piece, do only that piece — but still do the verification steps it depends on.

## Bundled resources

| File | Use it when |
|---|---|
| `scripts/inventory.py <paper_dir>` | Phase 1: list all files with line counts |
| `scripts/pptx_text.py <deck.pptx>` | Phase 1/7: slide text in order, with picture/table/equation counts and speaker notes |
| `scripts/run_stata.sh <workdir> <dofile> [logdir]` | Phase 4: batch Stata run immune to `profile.do` changing directory; reports errors/breaks |
| `references/code-comparison.md` | Phase 3 checklist |
| `references/running-code.md` | Phase 4, before running anything |
| `references/estimation-methods.md` | Phase 5: GMM / SMM / MLE / minimum distance / calibration templates, SE checklist, worked example |
| `references/equilibrium-solving.md` | Phase 6 |
| `references/slide-review.md` | Phase 7 rubric |
| `references/report-templates.md` | Phase 8: skeletons for every output file |

## Workflow

Work through these phases in order. Each phase produces facts the later ones depend on; skipping verification and writing from reading alone is how wrong claims get into teaching material.

### Phase 1 — Inventory and versions

1. List every file in `Paper/`, `Original_Code/`, `Students_Code/` (`scripts/inventory.py <paper_dir>` does this with line counts).
2. Identify **which version of the paper** each artifact follows. Published versions, working papers and online appendices often have different parameter values and table numbering. Check: the published PDF, the appendix (its date), the code's dates/comments, and the numbers on the student slides. A mismatch here explains many later "discrepancies", so settle it first.
3. Extract text from PDFs (`pdftotext -layout`) and slides (`scripts/pptx_text.py deck.pptx`; render the exported PDF pages to see equations that are images). Locate the model section, the estimation/calibration section, every results table, and the appendix sections on data and estimation.

### Phase 2 — Coverage map

Build a table mapping each original driver/script to the replication script/scenario that covers it, and mark gaps (e.g. "calibration step not replicated; parameters hand-copied") and additions (scenarios the replication added that the original does not have). Gaps matter: a replication that copies calibrated parameters verifies *the model solution given parameters*, not *that the parameters are identified from data*.

### Phase 3 — Code-to-code comparison

Compare logic, not syntax. Read `references/code-comparison.md` for the checklist of cross-language pitfalls (RNG, merge semantics, indexing, globals passed through files, optimizer defaults, data-vintage drift).

- **Every hard-coded parameter**: check each value in the replication against the exact original driver file. List them in a table with source file names.
- **Every reformulation**: when the replication rewrites something (a different solver, a change of variables, an analytic shortcut), verify equivalence mathematically and show the derivation. Example from practice: a Frank-copula conditional-inverse sampler written with log-sum-exp is equivalent to MATLAB's `copularnd` formula after multiplying through; a three-price equilibrium can be reduced to one dimension using Cobb-Douglas FOCs.
- **Quirks to preserve**: if the original relies on old or odd behaviour (e.g. legacy Stata `merge` acting like `m:m`, a `collapse (min)` that silently picks the smaller weight), the replication should reproduce it. Note whether it does.
- **Original-code bugs and comment/code mismatches**: undefined variables, wrong paths, comments that describe a different rule than the code executes. Report them; do not silently "fix" them in the replication.
- **Paper vs code**: places where the code does something different from what the paper says (e.g. paper: factor income distributed in equal shares; code: proportional to wages). These are high-value findings — explain the economic consequence.

### Phase 4 — Run and verify

Read `references/running-code.md` before running anything — it covers batch-mode pitfalls (e.g. a Stata `profile.do` that `cd`s elsewhere), backing up outputs, background runs, and output comparison.

1. Back up existing outputs to the scratchpad before re-running.
2. Run the replication (in the background if it takes minutes). Check sentinels, asserts and error codes in the log.
3. Compare the new outputs with the backup (`cf` in Stata, or a diff script). Differences at 1e-16 are floating-point summation order, not a problem; say so explicitly.
4. If an MATLAB/R/etc. original cannot be run here, say so plainly and verify against the paper's tables instead.
5. **Compare against the paper, table by table**, in `复现对照表.md`. For each cell: paper value, replication value, status. Use these statuses:
   - ✅ matches after the paper's rounding
   - 🟡 small deviation (crosses a rounding boundary, or a few percent)
   - ❌ substantive deviation — investigate and give candidate explanations (simulation noise, parameter version, paper typo, code-vs-paper difference), and say which cannot be distinguished without running the original
   Also check calibration targets (they should match by construction — if they do not, something upstream is wrong) and untargeted moments separately.
6. When a claim depends on a number you have not computed, compute it before writing it (e.g. the effect of alternative weights on a moment). Do not assert that a detail "matters" without quantifying it — an early draft in practice called a weighting choice important; computing it showed a <0.003 effect.

### Phase 5 — Estimation / calibration method

This is the core teaching content. Read `references/estimation-methods.md` and identify which estimator the paper uses (GMM, SMM, MLE/SML, minimum distance, indirect inference, NLS, or calibration = exactly identified moment matching). For each parameter block, document:

- **Model object**: what distribution/structural object the parameter governs (e.g. Fréchet marginals describe ability, a copula parameter describes dependence — not a correlation coefficient).
- **Data moments / likelihood**: exactly which statistics, from which sample, and how they are measured. Trace them to the data code and the appendix (e.g. "variance of the persistent component" measured as the cross-sectional covariance of matched year-pairs, square-rooted to a standard deviation in the calibration code).
- **Model counterpart**: how the code computes the same statistic from the model (`m(β)`), step by step, with the code file and function names.
- **Objective and algorithm**: distance metric, weighting matrix, transformations of parameters, optimizer, multistart, number of simulations, common random numbers, tolerances.
- **Identification intuition**: which moment pins down which parameter and why. Where a closed form exists for a special case, use it as a numerical sanity check (e.g. log of a Fréchet(θ) variable is Gumbel with sd π/(θ√6); for a nearly unselected sector this reproduces the targeted wage dispersion).
- **Relation to GMM/MLE theory**: is it exactly identified? Are standard errors reported? What would be needed to compute them (Ω via bootstrap, G via numerical derivatives, (1+1/S) simulation correction)? Is the objective smooth? Are the two sides of each moment measured on the same basis?
- **Nested layers**: many papers calibrate in stages (distribution parameters in partial equilibrium, preference parameters to aggregate shares, country-level productivity to GDP gaps). Say which stages have code and which were done by hand.

### Phase 6 — Model solution

Read `references/equilibrium-solving.md`. Answer, concretely:

- What are the unknowns, and what conditions pin them down? Reduce to the minimal system (competition conditions, Walras' law, by-construction market clearing).
- **Is there a closed-form solution?** Show the special case where there is one and the step at which it disappears. This is usually the clearest way to explain why the mechanism needs a particular feature (e.g. without a subsistence term, the relative price is ν^{−1/θ} and independent of productivity, so selection does nothing).
- How are integrals computed (simulation, quadrature)? How is the root/fixed point found (which function, which algorithm, tolerances, what happens on non-convergence)?
- Show the original and replication implementations side by side with short code excerpts, and say which is more robust and why (e.g. bisection on a monotone excess demand with sign information vs Nelder–Mead on its absolute value).

### Phase 7 — Slide review (if student slides exist)

Read `references/slide-review.md` for the rubric. Review from the standpoint of "a complete report whose purpose is to learn the model framework and the estimation method". Cite slide numbers. Separate: version problems, factual errors (with the correct statement), omissions in model/estimation/solution, interpretation problems (targeted moments presented as validation; multiplicative contributions computed by division instead of logs; "robust" claims contradicted by the table), missing replication results, missing critique/literature. End with a concrete list of slides to add or fix, each self-contained.

### Phase 8 — Write

Use the templates in `references/report-templates.md`. Principles:

- Lead each section with the conclusion, then the evidence.
- Every number gets a source: paper table/page, file:line, or a command you ran.
- Quote the paper or appendix when the exact wording matters (e.g. a stated assumption or a stated equal-share rule).
- Correct yourself in writing when verification overturns an earlier claim; do not leave the earlier version standing elsewhere in the document.
- Keep deep dives in appendices of `技术说明.md` (附一, 附二, …) and cross-reference them from the main text by name.

### Slides

Build the teaching deck from `技术笔记.md`, one message per slide: question → mechanism → model → estimation/calibration (with the moment table and identification intuition) → solution method (closed-form special case → numerical method) → replication results vs paper → discrepancies → critique. If an artifact slide-deck type is available in the session, use it (start with the Artifact tool's quickstart, intent "slides"); otherwise use the pptx skill to produce a `.pptx`. Use the paper's actual published numbers, and label anything from a different version.

## Things that went wrong before (and how to avoid them)

- Student slides quoted a working-paper version (different θ, ρ and table numbers) while the course replicated the published version. → Phase 1 version check.
- A batch run failed with `file not found` because Stata's `profile.do` changed directory. → `references/running-code.md`.
- A log looked complete but the run had actually been interrupted (`--Break-- r(1)`), and the saved outputs came from an earlier run. → Always check the log tail and file timestamps.
- An online appendix reported transitory variances that were exactly half of what its own equation implied (fixed-effect residual variance with T=2 without dof correction). → Recompute reported numbers from their stated formula.
- A contribution share was computed as 2.3/10.7 = 21%; for multiplicative gaps the right measure is ln 2.3 / ln 10.7 ≈ 35%.
