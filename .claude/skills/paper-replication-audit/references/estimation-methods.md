# Estimation and calibration methods — what to identify and explain

Use this when documenting how a paper's parameters are obtained. The goal is that a student could re-derive the estimator and re-implement it from your notes.

## Contents
1. Recognising the method in code
2. Common template for every method
3. GMM
4. SMM / simulated minimum distance
5. MLE and simulated MLE
6. Minimum distance / indirect inference
7. Calibration (exactly identified moment matching)
8. Standard errors checklist
9. Worked example: Lagakos & Waugh (2013)

## 1. Recognising the method in code

| Code signal | Likely method |
|---|---|
| A function returning model moments, a loss `‖m(β) − m̂‖` or `(m−m̂)'W(m−m̂)`, random draws inside | SMM / simulated minimum distance |
| Same, but moments computed analytically | GMM / classical minimum distance |
| Sum of log densities, `ml model`, `fminunc` on `-loglik`, `mlexp`, `optimize(... "d0/d1/d2")` | MLE |
| Simulated choice probabilities inside a log-likelihood | Simulated MLE (SML) |
| An auxiliary regression run on both data and simulated data | Indirect inference |
| Parameters typed in as constants with comments like "chosen to match …", or `fzero`/bisection on one target | Calibration |
| Stata `gmm`, R `gmm`/`momentfit`, Python `linearmodels`/`statsmodels` GMM | GMM |

Optimizers: `fminsearch` (Nelder–Mead, derivative-free, local), `fminunc`/`fmincon` (gradient), `patternsearch`, `ga`, `parfor` over a grid of starting values (multistart), Mata `optimize()`, Stata `ml`.

## 2. Common template (fill this for every parameter block)

1. **Parameters** β and their economic meaning; note any reparametrisation in code (e.g. code uses 1/θ, logistic transforms to (0,1), logs to enforce positivity).
2. **Data side**: statistics, sample, weights, how computed (file and line).
3. **Model side**: the mapping β → m(β) or β → L(β), step by step, naming functions.
4. **Objective**: distance/likelihood, weighting matrix, transformations (logs, percentage deviations).
5. **Algorithm**: optimizer, starting values, multistart, number of simulations S and draws N, common random numbers (fixed seed across β), tolerances, convergence checks.
6. **Identification**: number of moments vs parameters; intuition for which moment moves which parameter; any closed-form special case to sanity check.
7. **Inference**: reported SEs? how computed? if none, what would be needed.
8. **Caveats**: non-smooth objective, local minima, moments measured on different bases on the two sides, data vintage.

## 3. GMM

- Moment conditions E[g(x_i; β)] = 0; sample analogue ĝ(β) = (1/N)Σ g(x_i; β).
- Estimator: β̂ = argmin ĝ(β)' W ĝ(β). Optimal W = Ω⁻¹ with Ω = Var(g); two-step or iterated GMM.
- Asymptotic variance: (G'WG)⁻¹ G'WΩWG (G'WG)⁻¹ / N; with W = Ω⁻¹ it becomes (G'Ω⁻¹G)⁻¹ / N, where G = E[∂g/∂β'].
- Exactly identified (dim g = dim β): β̂ solves ĝ(β) = 0 and W is irrelevant.
- Over-identified: Hansen J test for overidentifying restrictions.
- Explain what each moment condition says economically.

## 4. SMM / simulated minimum distance

- Use when m(β) = E_β[statistic] has no closed form. Simulate S datasets (or one large one) from the model at β, compute the same statistic, average: m̃_S(β).
- Objective: [m̂ − m̃_S(β)]' W [m̂ − m̃_S(β)]. Moments can be any statistic (sd, ratios, regression coefficients, shares), not just means — the data-side statistic must be computed the same way as the model-side one.
- **Common random numbers**: hold the underlying uniform/normal draws fixed across β, otherwise the objective jitters and optimizers fail. Look for a fixed seed inside the moment function.
- **Simulation noise**: averaging over S simulations; variance inflation factor (1 + 1/S) in the asymptotic variance (or 1 + N/(S·N_sim) when sizes differ).
- **Non-smoothness**: discrete choices, indicators and inner root-finding make m̃ a step function in β → derivative-free optimizers, multistart, smoothing (logit kernels), or larger simulations. Pakes & Pollard (1989) give asymptotics for non-smooth objectives; numerical G needs care with step size.
- References: McFadden (1989), Pakes & Pollard (1989), Lee & Ingram (1991), Duffie & Singleton (1993).

## 5. MLE and simulated MLE

- β̂ = argmax Σ log f(y_i | x_i; β). Explain the likelihood contribution of one observation and where each parameter enters.
- Variance: inverse Hessian, OPG, or sandwich (robust). Check which the code uses.
- Identification issues: flat likelihood, normalisations (scale of latent utility, location of fixed effects), boundary parameters.
- SML: simulated probabilities inside the log are biased for finite S (log of an average); bias vanishes only if S grows faster than √N. Contrast with SMM, which is consistent for fixed S.
- Mixtures/EM, nested fixed point (Rust), MPEC — name them if used.

## 6. Minimum distance / indirect inference

- Classical minimum distance: reduced-form estimates π̂ and a structural mapping π = h(β); β̂ = argmin (π̂ − h(β))' W (π̂ − h(β)).
- Indirect inference: π are coefficients of an auxiliary model (often a regression) estimated on data and on simulated data.
- Explain why the auxiliary statistics are informative about β.

## 7. Calibration (exactly identified moment matching)

- Typical in macro/trade/development. Number of targets = number of parameters; solves m(β) = m_data.
- Treat it honestly as an exactly identified (S)MM estimator without reported uncertainty. Say what would turn it into an estimator: Ω (bootstrap the data moments), G (numerical derivatives), then Var(β̂) = G⁻¹ Ω G⁻¹' / N (× (1+1/S) if simulated).
- Distinguish **targeted** moments (fit by construction — not evidence of model fit) from **untargeted** predictions (genuine validation).
- Staged calibration: document each stage, what is held fixed, and whether the stage needs the full equilibrium or only part of the model.
- Hand-tuned values (e.g. a productivity level "chosen to match a GDP gap" but hard-coded): say there is no code for the search.

## 8. Standard errors checklist

- Reported? Clustered/robust? Delta method for transformed parameters?
- For simulated estimators: simulation correction included?
- For staged estimation: first-stage uncertainty propagated (Murphy–Topel / stacked GMM)?
- If none: propose the bootstrap or analytic route as a classroom exercise.

## 9. Worked example: Lagakos & Waugh (2013)

- Parameters: Fréchet dispersion θ_a, θ_n (code stores 1/θ) and Frank copula dependence ρ (code passes Kendall τ = 0.3451 to `copulaparam`, giving ρ = 3.5).
- Data moments: sd of the persistent component of log wages by sector (0.4733, 0.3795 = √0.224, √0.144, from CPS matched-year covariances) and the ag/non-ag mean wage ratio (0.7014).
- m(β): draw 100,000 (z_a, z_n); `fzero` on the cutoff so exactly 2% choose agriculture (partial equilibrium — no need to solve the GE); wages p_a z_a and z_n; compute std(log w_n), std(log w_a), mean ratio.
- Objective: ‖log m(β) − log m̂‖ (W = I, log deviations); 60-point multistart grid with `fminsearch` in `parfor`, then polish with moments averaged over 32 simulations; seeds fixed per simulation index (common random numbers); logistic reparametrisation.
- Identification check: non-ag is 98% of workers (barely selected) so sd(log w_n) ≈ π/(θ_n√6) = 1.283/2.7 ≈ 0.475 vs target 0.4733.
- Exactly identified, no SEs; objective non-smooth (indicator choice + inner root find). Preference parameters (ā, ν) and country productivity levels are hand-calibrated with no search code.
