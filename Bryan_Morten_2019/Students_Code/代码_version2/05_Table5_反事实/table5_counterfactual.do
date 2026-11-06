*==============================================================================
* table5_counterfactual.do
*   Table 5 复现：削减迁移壁垒的产出收益
*
*   模型方程（论文行号）：
*     w_d = p_d A_d                                        (1140)
*     Y = [Σ_d y_d^{(σ−1)/σ}]^{σ/(σ−1)} ,  p_d = (Y/y_d)^{1/σ}   (1141–1155, fn17)
*     y_d = A_d H_d ,  A_d = Ā_d H_d^γ                     (1165–1170)
*     α_d = ᾱ_d L_d^λ   (L_d = 居住人口)                    (1179–1184)
*     H_d = Γ̄ Σ_o L_o q_o π_do^{1−1/θ}                      (式 5/6)
*     π_do = (w_d α_d (1−τ_do))^θ / Σ_j (w_j α_j (1−τ_jo))^θ  (式 4)
*   由前两式可化出 Y = Σ_d w_d H_d（总产出 = 总劳动收入）。
*
*   ⚠ 系统是非对称的：出生地 o 有 17 个省（含 54 东帝汶），
*     而目的地 d 只有 16 个（1995 年 IPUMS 里没有居民被编码在东帝汶）。
*     所以 π 是 17×16，w_d/α_d/L_d 是 16 维，L_o/q_o 是 17 维。
*
*   GE 参数（论文 1661–1709 行，取自文献）：γ = 0.05, λ = −0.075, σ = 8
*   反事实：τ 重标 (1−τ̃) = (1−τ)^{1−k}；ᾱ_d 重标 ᾱ_d/ᾱ_1 = (α_d/α_1)^{1−k}
*   No selection：H_d 里的内生项 π_do^{−1/θ} 置 1（论文 fn 25）
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
matrix drop _all
capture log close
log using "table5_out.log", replace text

local root "D:\研一上\微观计量"

display _n(2) "{hline 78}"
display "  Table 5 复现：削减迁移壁垒的产出收益"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 78}"

*==============================================================================
* 1. Mata
*==============================================================================
mata:

// ---------- 给定参数求均衡总产出 Y ----------
real scalar ge_solve(real rowvector Lo, real rowvector q, real matrix tau,
                     real rowvector w0, real rowvector a0,
                     real rowvector Abar, real rowvector abar,
                     real scalar theta, real scalar gamma, real scalar lambda,
                     real scalar sigma, real scalar noselect,
                     real scalar maxit, real scalar tol, real scalar damp,
                     real scalar verbose)
{
    real scalar no, nd, it, Y, err, floored
    real rowvector w, alpha, L, H, A, wnew, anew, denom
    real matrix ATT, P

    no = cols(Lo)
    nd = cols(w0)
    w = w0
    alpha = a0
    err = 1e10
    floored = 0
    Y = .

    for (it = 1; it <= maxit; it++) {
        ATT   = (1 :- tau) :* (J(no, 1, 1) * (w :* alpha))
        P     = ATT :^ theta
        denom = rowsum(P)
        P     = P :/ denom
        L     = Lo * P
        if (noselect == 1) H = (Lo :* q) * P
        else               H = (Lo :* q) * (P :^ (1 - 1/theta))
        if (min(H) <= 0) {
            floored = floored + 1
            H = H :+ 1e-12
        }
        A    = Abar :* (H :^ gamma)
        Y    = (sum((A :* H) :^ ((sigma - 1)/sigma))) ^ (sigma/(sigma - 1))
        wnew = (A :^ ((sigma - 1)/sigma)) :* (H :^ (-1/sigma)) :* (Y ^ (1/sigma))
        anew = abar :* (L :^ lambda)

        err = max(abs(wnew - w) :/ (abs(w) :+ 1e-12))
        err = max((err, max(abs(anew - alpha) :/ (abs(alpha) :+ 1e-12))))
        if (err < tol) {
            w = wnew
            alpha = anew
            break
        }
        w     = (1 - damp) * w     + damp * wnew
        alpha = (1 - damp) * alpha + damp * anew
    }
    if (verbose == 1) {
        if (err >= tol) printf("      ⚠ 未收敛：%f 次迭代，相对误差 %e\n", it, err)
        else            printf("      收敛：%f 次迭代\n", it)
        if (floored > 0) printf("      ⚠ H_d 触底 %f 次\n", floored)
    }
    return(Y)
}

// ---------- 基准校准 ----------
void ge_calibrate(real rowvector Lo, real rowvector q, real matrix tau,
                  real rowvector wobs, real rowvector aobs,
                  real scalar theta, real scalar gamma, real scalar lambda,
                  real scalar sigma, real scalar noselect,
                  real rowvector Abar, real rowvector abar,
                  real rowvector Lmod, real scalar Ybase)
{
    real scalar no, nd
    real rowvector H, A, p, y, denom
    real matrix ATT, P

    no = cols(Lo)
    nd = cols(wobs)
    ATT   = (1 :- tau) :* (J(no, 1, 1) * (wobs :* aobs))
    P     = ATT :^ theta
    denom = rowsum(P)
    P     = P :/ denom
    Lmod  = Lo * P

    if (noselect == 1) H = (Lo :* q) * P
    else               H = (Lo :* q) * (P :^ (1 - 1/theta))

    Ybase = sum(wobs :* H)
    y     = ((wobs :* H) :^ (sigma/(sigma - 1))) :/ (Ybase ^ (1/(sigma - 1)))
    p     = (Ybase :/ y) :^ (1/sigma)
    A     = wobs :/ p
    Abar  = A :/ (H :^ gamma)
    abar  = aobs :/ (Lmod :^ lambda)
}

// ---------- 主程序 ----------
void table5_do(real scalar theta,
               real rowvector W, real rowvector AL, real rowvector QQ,
               real rowvector LO, real matrix TAU)
{
    real scalar nd, gamma, lambda, sigma, maxit, tol, damp
    real scalar Ybase, Y, Ysave
    real rowvector Abar_b, abar_b, Abar_n, abar_n, Lmod_b, Lmod_n
    real rowvector b2
    real matrix tau_cf
    real scalar g11, g12, g13, g21, g22, g23

    nd = cols(W)
    gamma  = 0.05
    lambda = -0.075
    sigma  = 8
    maxit  = 20000
    tol    = 1e-13
    damp   = 0.5

    printf("\n")
    printf("  ── θ = %9.4f  （出发地 %f 个，目的地 %f 个）────────────\n", theta, cols(LO), nd)

    // ===== 基准校准（含比较优势）=====
    ge_calibrate(LO, QQ, TAU, W, AL, theta, gamma, lambda, sigma, 0,
                 Abar_b, abar_b, Lmod_b, Ybase)
    printf("  [含选择] 基准 Y = %16.6f\n", Ybase)

    // ===== 数值自检：τ 不变 ⇒ gain 必须 = 1 =====
    Ysave = ge_solve(LO, QQ, TAU, W, AL, Abar_b, abar_b,
                     theta, gamma, lambda, sigma, 0, maxit, tol, damp, 0)
    printf("  [自检] 不改 τ 时 Y = %16.6f   比值−1 = %16.12e  %s\n", Ysave, Ysave/Ybase-1, (abs(Ysave/Ybase-1)<1e-6 ? "✅ 校准正确":"❌ 校准或求解有误"))

    tau_cf = J(rows(TAU), cols(TAU), 0)
    g11 = ge_solve(LO, QQ, tau_cf, W, AL, Abar_b, abar_b, theta, gamma, lambda, sigma, 0, maxit, tol, damp, 1) / Ybase
    printf("    ① 迁移成本完全消除      gain = %8.4f\n", g11)
    b2 = J(1, nd, abar_b[1])
    g12 = ge_solve(LO, QQ, TAU, W, AL, Abar_b, b2, theta, gamma, lambda, sigma, 0, maxit, tol, damp, 1) / Ybase
    printf("    ② 舒适度完全拉平        gain = %8.4f\n", g12)
    g13 = ge_solve(LO, QQ, tau_cf, W, AL, Abar_b, b2, theta, gamma, lambda, sigma, 0, maxit, tol, damp, 1) / Ybase
    printf("    ③ 两者同时              gain = %8.4f\n", g13)

    // ===== No selection =====
    printf("  ── No selection：H_d 的内生项 π^{−1/θ} 置 1 ──\n")
    ge_calibrate(LO, QQ, TAU, W, AL, theta, gamma, lambda, sigma, 1,
                 Abar_n, abar_n, Lmod_n, Ybase)
    printf("  [无选择] 基准 Y = %16.6f\n", Ybase)
    g21 = ge_solve(LO, QQ, tau_cf, W, AL, Abar_n, abar_n, theta, gamma, lambda, sigma, 1, maxit, tol, damp, 1) / Ybase
    printf("    ① 迁移成本完全消除      gain = %8.4f\n", g21)
    b2 = J(1, nd, abar_n[1])
    g22 = ge_solve(LO, QQ, TAU, W, AL, Abar_n, b2, theta, gamma, lambda, sigma, 1, maxit, tol, damp, 1) / Ybase
    printf("    ② 舒适度完全拉平        gain = %8.4f\n", g22)
    g23 = ge_solve(LO, QQ, tau_cf, W, AL, Abar_n, b2, theta, gamma, lambda, sigma, 1, maxit, tol, damp, 1) / Ybase
    printf("    ③ 两者同时              gain = %8.4f\n", g23)

    st_matrix("ROWOUT", (theta, g11, g12, g13, g21, g22, g23, Ybase))
}
end

*==============================================================================
* 2. 重建印尼省级 OD 面板
*==============================================================================
display _n "===== 1. 重建 1995 年省级 OD 面板 ====="

use year bplid geo1_id incwage perwt relate sex age using "`root'\ipumsi_00002.dta", clear
keep if year == 1995
keep if sex == 1 & relate == 1 & inrange(age, 15, 65)
gen int o = bplid
gen int d = geo1_id - 360000
keep if inrange(o, 11, 18) | inrange(o, 31, 35) | inrange(o, 51, 54)
keep if inrange(d, 11, 18) | inrange(d, 31, 35) | inrange(d, 51, 54)

gen byte hasw = !missing(incwage) & incwage > 0 & incwage < 9999999
gen double m_w  = perwt
gen double wx_w = perwt*incwage if hasw
gen double wg_w = perwt if hasw
collapse (sum) m_w wx_w wg_w, by(o d)
rename m_w  m_od
rename wx_w wsum
rename wg_w wden
gen double wage_od = wsum/wden if wden > 0 & !missing(wden)
drop wsum wden

bysort o: egen double pop_o  = total(m_od)
bysort d: egen double m_in_d = total(m_od)
egen double pop_all = total(m_od)
gen double pi_do = m_od/pop_o

preserve
    keep if o == d
    keep o pi_do
    rename pi_do pi_oo
    tempfile g_o
    save `g_o'
    rename o d
    rename pi_oo pi_dd
    tempfile g_d
    save `g_d'
restore
preserve
    keep o d pi_do
    rename o _t1
    rename d _t2
    rename _t1 d
    rename _t2 o
    rename pi_do pi_rev
    tempfile rev
    save `rev'
restore

keep if o != d
merge m:1 o using `g_o', keep(master match) nogen
merge m:1 d using `g_d', keep(master match) nogen
merge 1:1 o d using `rev', keep(master match) nogen

gen double ln_p      = ln(pi_do)
gen double ln_p_rev  = ln(pi_rev)
gen double ln_poo    = ln(pi_oo)
gen double ln_pdd    = ln(pi_dd)
gen double ln_wage   = ln(wage_od) if !missing(wage_od) & wage_od > 0
gen double pi_dnoto  = (m_in_d - m_od)/(pop_all - pop_o) if (pop_all - pop_o) > 0
gen double ln_pdnoto = ln(pi_dnoto) if pi_dnoto > 0

keep if pi_do > 0 & pi_rev > 0 & pi_oo > 0 & pi_dd > 0
keep if !missing(ln_wage) & !missing(ln_pdnoto)
display "  估计样本 N = " _N

preserve
    keep o
    duplicates drop
    sort o
    mkmat o, matrix(OLIST)
restore
preserve
    keep d
    duplicates drop
    sort d
    mkmat d, matrix(DLIST)
restore
local NO = rowsof(OLIST)
local ND = rowsof(DLIST)
display "  出发地数 = `NO'    目的地数 = `ND'"
local olist ""
forvalues i = 1/`NO' {
    local olist "`olist' `=OLIST[`i',1]'"
}
local dlist ""
forvalues i = 1/`ND' {
    local dlist "`dlist' `=DLIST[`i',1]'"
}
display "  出发地：`olist'"
display "  目的地：`dlist'"

*==============================================================================
* 3. 三套 θ
*==============================================================================
display _n(2) "{hline 78}"
display "  3. 三套 θ 分别估计与求解"
display "{hline 78}"

tempfile panelmain tauobs o17 d17
matrix RESULTS = J(3, 8, .)
local rowi = 0

foreach TH of numlist 4.0869 12.4399 12.5836 {
    local rowi = `rowi' + 1
    display _n(2) "{hline 78}"
    display "  θ = `TH'   （第 `rowi' 套）"
    display "{hline 78}"

    * 上一轮保存的 panelmain 里已含这些变量，先清掉
    capture drop w_d
    capture drop q_o
    capture drop lhs_sym
    capture drop tau_obs
    capture drop Zg
    capture drop alpha_d
    capture drop phat
    capture drop tau_full
    capture drop tau_use

    * ---- (a) 式(7) IV ----
    quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
    quietly predict double phat, xb
    quietly ivregress 2sls ln_wage (ln_p = phat) i.o i.d, cluster(o)
    display "  式(7) 自己估出的 θ = " %8.4f -1/_b[ln_p] "   （本次强制 θ = `TH'）"
    quietly summarize wage_od
    local v = r(Var)/(r(mean)^2)
    local best = .
    local bestd = 1e30
    forvalues i = 205/4000 {
        local tt = `i'/100
        local rhs = exp(lngamma(1 - 2/`tt'))/(exp(lngamma(1 - 1/`tt'))^2) - 1
        if abs(`rhs' - `v') < `bestd' {
            local bestd = abs(`rhs' - `v')
            local best = `tt'
        }
    }
    local ttilde = `best'
    display "  θ̃ = " %8.4f `ttilde' "   Γ̄ = Γ(1−1/θ̃) = " %10.6f exp(lngamma(1 - 1/`ttilde'))

    * ---- w_d（按目的地 16 个）----
    quietly gen double w_d = .
    forvalues i = 1/`ND' {
        local cc : word `i' of `dlist'
        if `cc' == `=DLIST[1,1]' local g = 0
        else {
            capture local g = _b[`cc'.d]
            if _rc local g = .
        }
        quietly replace w_d = exp(_b[_cons] + `g' - lngamma(1 - 1/`ttilde')) if d == `cc'
    }
    quietly summarize w_d
    display "  w_d：最小 = " %12.1f r(min) "   最大 = " %12.1f r(max) "   非缺失 = " %4.0f r(N)

    * ---- q_o（按出发地 17 个）----
    quietly gen double q_o = .
    forvalues i = 1/`NO' {
        local cc : word `i' of `olist'
        if `cc' == `=OLIST[1,1]' local h = 0
        else {
            capture local h = _b[`cc'.o]
            if _rc local h = .
        }
        quietly replace q_o = exp(`h') if o == `cc'
    }
    quietly summarize q_o
    display "  q_o：最小 = " %8.4f r(min) "   最大 = " %8.4f r(max) "   非缺失 = " %4.0f r(N)

    * ---- (b) τ(θ) ----
    quietly gen double lhs_sym = (ln_p - ln_poo) + (ln_p_rev - ln_pdd)
    quietly gen double tau_obs = 1 - exp(lhs_sym/(2*`TH'))
    quietly summarize tau_obs
    display "  τ（可算格子）：均值 = " %8.4f r(mean) "  范围 [" %8.4f r(min) ", " %8.4f r(max) "]  N = " %4.0f r(N)

    * ---- (c) α_d(θ) ----
    quietly gen double Zg = ln_p - `TH'*ln(w_d) - lhs_sym/2
    quietly regress Zg i.d i.o
    local refd = .
    capture local refd = _b[`=DLIST[1,1]'.d]
    if _rc local refd = 0
    quietly gen double alpha_d = .
    forvalues i = 1/`ND' {
        local cc : word `i' of `dlist'
        if `cc' == `=DLIST[1,1]' local g = 0
        else {
            capture local g = _b[`cc'.d]
            if _rc local g = .
        }
        quietly replace alpha_d = exp((`g' - `refd')/`TH') if d == `cc'
    }
    quietly summarize alpha_d
    display "  α_d：最小 = " %8.4f r(min) "   最大 = " %8.4f r(max) "   非缺失 = " %4.0f r(N)

    * ---- (d) 组装向量 ----
    tempname W AL QQ LO
    matrix `W'  = J(1, `ND', .)
    matrix `AL' = J(1, `ND', .)
    matrix `QQ' = J(1, `NO', .)
    matrix `LO' = J(1, `NO', .)
    forvalues i = 1/`ND' {
        local cc : word `i' of `dlist'
        quietly summarize w_d if d == `cc'
        matrix `W'[1, `i']  = r(mean)
        quietly summarize alpha_d if d == `cc'
        matrix `AL'[1, `i'] = r(mean)
    }
    forvalues i = 1/`NO' {
        local cc : word `i' of `olist'
        quietly summarize q_o if o == `cc'
        matrix `QQ'[1, `i'] = r(mean)
        quietly summarize pop_o if o == `cc'
        matrix `LO'[1, `i'] = r(mean)
    }

    * ---- (e) 17×16 网格上的 τ ----
    quietly save `panelmain', replace
    keep o d tau_obs
    save `tauobs', replace
    use `panelmain', clear
    keep o
    duplicates drop
    rename o oo
    sort oo
    save `o17', replace
    use `panelmain', clear
    keep d
    duplicates drop
    rename d dd
    sort dd
    save `d17', replace

    use `o17', clear
    cross using `d17'
    rename oo o
    rename dd d
    sort o d
    display "  完整 OD 网格：" _N " 格"
    merge 1:1 o d using `tauobs', keep(master match) nogen
    quietly count if !missing(tau_obs)
    display "  其中 τ 可观测：" r(N)
    quietly regress tau_obs i.o i.d
    quietly predict double tau_full, xb
    quietly replace tau_full = 0 if o == d
    quietly count if missing(tau_full)
    display "  插值后仍缺失：" r(N)
    sort o d
    mkmat tau_full, matrix(TAUF)
    display "  τ_full 行数 = " rowsof(TAUF) "  （应为 `NO'×`ND' = `=`NO'*`ND''）"

    * ---- (f) Mata ----
    mata: table5_do(`TH', st_matrix("`W'"), st_matrix("`AL'"), st_matrix("`QQ'"), st_matrix("`LO'"), rowshape(st_matrix("TAUF"), `NO'))
    forvalues j = 1/8 {
        matrix RESULTS[`rowi', `j'] = ROWOUT[1, `j']
    }

    use `panelmain', clear
}

*==============================================================================
* 4. 汇总
*==============================================================================
display _n(2) "{hline 78}"
display "  4. 汇总：本复现 vs 论文 Table 5"
display "{hline 78}"
display _n "  论文 Table 5（迁移成本 / 舒适度 / 两者）"
display "     Baseline      1.075   1.127   1.217"
display "     No selection  .914    1.127   1.133"
display _n "  本复现："
display "     θ        列(1)     列(2)     列(3)  |  NoSel(1)  NoSel(2)  NoSel(3)  |  基准 Y"
forvalues i = 1/3 {
    display "  " %8.4f RESULTS[`i',1] "  " %8.4f RESULTS[`i',2] "  " %8.4f RESULTS[`i',3] "  " %8.4f RESULTS[`i',4] "  |  " %8.4f RESULTS[`i',5] "  " %8.4f RESULTS[`i',6] "  " %8.4f RESULTS[`i',7] "  |  " %16.1f RESULTS[`i',8]
}

display _n "  ── 定性结论检查 ──"
forvalues i = 1/3 {
    display _n "  θ = " %8.4f RESULTS[`i',1]
    if RESULTS[`i',2] > 1 & RESULTS[`i',5] < 1 {
        display "    ✅ 符号翻转成立：含选择 " %7.4f RESULTS[`i',2] " > 1，无选择 " %7.4f RESULTS[`i',5] " < 1"
    }
    else {
        display "    ❌ 符号翻转不成立：含选择 " %7.4f RESULTS[`i',2] "，无选择 " %7.4f RESULTS[`i',5]
    }
    local gs = RESULTS[`i',4] - 1
    local gn = RESULTS[`i',7] - 1
    if `gs' > 0 {
        display "    第(3)列低估幅度 = " %6.1f 100*(1 - `gn'/`gs') "%   （论文 40%）"
    }
    display "    列(2) 含选择 " %7.4f RESULTS[`i',3] " vs 无选择 " %7.4f RESULTS[`i',6] "   差 " %7.4f RESULTS[`i',6]-RESULTS[`i',3]
}

display _n(2) "{hline 78}"
display "  运行结束：$S_DATE $S_TIME"
display "{hline 78}"
log close