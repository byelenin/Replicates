# Explaining how a model is solved

Use this when documenting the solution of an equilibrium, dynamic programming, or fixed-point problem. Students should come away knowing what the unknowns are, why there is (usually) no closed form, and exactly which numerical routine finds the solution.

## 1. Reduce to the minimal system

- List the equilibrium objects from the paper's definition (prices, wages, allocations, value functions).
- Eliminate what is pinned down directly: competitive factor prices, first-order conditions, agents' cutoff rules, budget constraints.
- Use Walras' law to drop one market; note markets that clear by construction (e.g. every worker chooses a sector, so labour markets clear).
- State the remaining system explicitly, ideally as one or a few equations E(x) = 0, and write each term as a function of the unknowns. Map each term to the code function that computes it.
- Note monotonicity/uniqueness arguments (often in a proposition proof) — they justify bisection.

## 2. Closed form or not?

Walk from the simplest special case to the paper's setting:

1. A special case with an explicit solution (independent draws, a parameter set to zero, homothetic preferences). Derive it.
2. The first complication that breaks the closed form — show the resulting equation and why it cannot be solved explicitly.
3. The paper's actual setting — often the equation itself contains integrals with no closed form, so it must be simulated or approximated.

Summarise in a table: case | can E be written in closed form | explicit solution?

The special case often explains the mechanism (e.g. Lagakos–Waugh: with ā = 0 the relative price is p_a = ν^{−1/θ}, independent of A, so productivity differences cause no reallocation and selection has no bite; the subsistence term is what makes A matter).

## 3. Numerical method

Identify and explain:

| Problem type | Typical methods | What to check |
|---|---|---|
| Scalar root | bisection, Brent/`fzero`, secant; or `fminsearch` on \|E\| | bracket, sign information kept?, tolerance, behaviour on failure |
| System of equations | Newton/Broyden, `fsolve`, `fminsearch` on ‖E‖, tâtonnement | starting values, scaling (log residuals), redundant equations (Walras) |
| Fixed point | function iteration, damping, contraction (BLP), Anderson acceleration | contraction modulus, damping factor |
| Dynamic programming | VFI, PFI, EGM, collocation | grid, interpolation, convergence norm |
| Integrals | Monte Carlo, quasi-MC, Gauss–Hermite/Legendre quadrature | number of draws/nodes, fixed seed |

- Discrete agents + indicator choices make excess demand a step function; derivative-based methods may fail and \|E\| minimisers may stop off the zero crossing.
- Non-homothetic preferences create corner solutions (income below subsistence); check the code truncates demand.
- Degenerate limits (homogeneous agents) make allocations knife-edge; check how the code handles them (small heterogeneity instead of zero, or an analytic benchmark).
- Note any ad-hoc fixes in the original (random perturbations on non-convergence, forcing a fraction of agents into a sector) and whether the replication needs them.

## 4. Reformulations in the replication

When the replication changes the unknown (e.g. solving for a cutoff t instead of a price) or eliminates dimensions analytically, derive the equivalence in full, e.g.:

- cutoff condition: (1−φ) p_a Y_a / L_a = t (1−α) Y_n / L_n
- capital FOCs: r = φ_k p_a Y_a / k_a = α Y_n / k_n
- ⇒ k_a / k_n = t (1−α)/(1−φ) · (φ_k/α) · (L_a/L_n), so given t everything except one market follows in closed form.

Then show both implementations side by side (short code excerpts with file names), and compare robustness, tolerance and failure handling.

## 5. Outer loops

Experiments usually wrap the solver: solve a benchmark economy, then economies with different fundamentals; compute measured statistics (at whose prices? — check the paper's footnotes vs the code); counterfactuals ("no selection"). Document what is matched in the outer loop and whether that search is coded or hand-tuned.
