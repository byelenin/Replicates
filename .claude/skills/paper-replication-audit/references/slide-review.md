# Reviewing student replication slides

Standard: a complete report on the paper whose purpose is to learn the **model framework and the estimation method**, presented by a replication team. Cite slide numbers for every point. Render equation images (export to PDF, view pages) — slide text extraction misses them.

## Rubric

1. **Version** — do numbers, parameter values and table numbers match the published paper and the code being replicated? Build a table: item | slides | published/code. Screenshots from working papers are a common cause.
2. **Factual errors in the model** — sign/direction mistakes (e.g. "higher relative price → choose non-agriculture" when it is the reverse), conditions mislabelled (competitive wage conditions called "labour-market clearing"), statements that hold only in a special case, propositions stated without their conditions. Give the corrected statement.
3. **Parameter meaning** — copula/dependence parameters vs correlation coefficients; inverse vs direct dispersion parameters; which share (employment vs expenditure) a parameter targets.
4. **Estimation / calibration** — is the method named correctly (calibration vs estimation)? Is the moment table right (e.g. persistent-component variance from panel covariance, not raw log-wage sd)? Joint vs one-to-one identification? Simulation, objective, algorithm, staged calibration, counterfactual definition explained?
5. **Solution method** — are the unknowns, the reduced system, closed-form special case and numerical algorithm explained, or just "solve the general equilibrium"?
6. **Interpretation** — targeted moments presented as fit; multiplicative contributions computed by division instead of logs; "robust" claims contradicted by the sensitivity table; "larger than" claims that hold under only one decomposition.
7. **Replication content** — own data moments, own model results vs paper tables, own figures, porting difficulties, discrepancies and their explanations. A deck without these is a reading summary, not a replication report.
8. **Critique and literature** — identifying assumptions, model simplifications, measurement issues, later evidence (cite only works you are sure exist).
9. **Evidence slides** — data source, method and estimates shown, not just conclusions.

## Output

`PPT修改建议.md`: header (deck, page count, date, review standard), then numbered recommendations, each self-contained: what is wrong (slide no., quoted text), what it should say, and for new slides what content to include (with numbers and examples so the students can build the slide directly). Finish with pointers to the sections of `技术说明.md` / `技术笔记.md` that supply the material.
