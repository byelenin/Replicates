*==============================================================================
* table5_qo_diag.do
*   q_o（出生地技能）的离散度对 Table 5 三列的影响
*
*   q_o 从式(7) 的出生地固定效应识别：
*     ln(wage_do) = ln(Γ̄) + ln(w_d) − (1/θ)ln(p_do) + ln(q_o) + ln(ε)
*   ⭐ q_o 【不进入】式(9) 引力方程（那里只有 w_d α_d τ），所以可以自由缩放，
*      不需要像 α_d 那样维护 ln(w_d·α_d) 的恒等式。
*
*   变换：ln q_o^ψ = ψ · ln q_o        归一化 q_ref = 1 ⇒ ln = 0，缩放后仍是 1
*   ψ = 1.0 → 原样        ψ = 0.0 → 技能完全无差异
*   ψ = 2.0 → 技能差距翻倍
*
*   每套 ψ 下跑「含选择」与「No selection」，看
*     差(1) 是否 = 0.161（论文，这是论文最看重的头条结论）
*     差(2) 是否塌到 0.001 量级（论文 1.127 vs 1.127）
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
matrix drop _all
capture log close
log using "table5_qo_diag_out.log", replace text

local root "D:\研一上\微观计量"
local TH   12.4399

display _n(2) "{hline 92}"
display "  q_o 技能分布诊断    θ = `TH'"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 92}"

*==============================================================================
* Mata
*==============================================================================
mata:

real rowvector make_H(real rowvector Lo, real rowvector q, real matrix P,
                      real scalar theta, real scalar selmode)
{
    if (selmode == 0) return( (Lo :* q) * (P :^ (1 - 1/theta)) )
    return( (Lo :* q) * P )
}

real scalar gsolve(real rowvector Lo, real rowvector q, real matrix tau,
                   real rowvector w0, real rowvector a0,
                   real rowvector Abar, real rowvector abar,
                   real scalar theta, real scalar gamma, real scalar lambda,
                   real scalar sigma, real scalar selmode,
                   real scalar maxit, real scalar tol, real scalar damp)
{
    real scalar no, nd, it, Y, err
    real rowvector w, alpha, L, H, A, wnew, anew, denom
    real matrix ATT, P
    no = cols(Lo)
    nd = cols(w0)
    w = w0
    alpha = a0
    err = 1e10
    for (it = 1; it <= maxit; it++) {
        ATT = (1 :- tau) :* (J(no, 1, 1) * (w :* alpha))
        P = ATT :^ theta
        denom = rowsum(P)
        P = P :/ denom
        L = Lo * P
        H = make_H(Lo, q, P, theta, selmode)
        if (min(H) <= 0) H = H :+ 1e-12
        A = Abar :* (H :^ gamma)
        Y = (sum((A :* H) :^ ((sigma - 1)/sigma))) ^ (sigma/(sigma - 1))
        wnew = (A :^ ((sigma - 1)/sigma)) :* (H :^ (-1/sigma)) :* (Y ^ (1/sigma))
        anew = abar :* (L :^ lambda)
        err = max(abs(wnew - w) :/ (abs(w) :+ 1e-12))
        err = max((err, max(abs(anew - alpha) :/ (abs(alpha) :+ 1e-12))))
        if (err < tol) {
            w = wnew
            alpha = anew
            break
        }
        w = (1 - damp) * w + damp * wnew
        alpha = (1 - damp) * alpha + damp * anew
    }
    return(Y)
}

void gcalib(real rowvector Lo, real rowvector q, real matrix tau,
            real rowvector wobs, real rowvector aobs,
            real scalar theta, real scalar gamma, real scalar lambda,
            real scalar sigma, real scalar selmode,
            real rowvector Abar, real rowvector abar, real scalar Ybase)
{
    real scalar no, nd
    real rowvector H, A, p, y, L, denom
    real matrix ATT, P
    no = cols(Lo)
    nd = cols(wobs)
    ATT = (1 :- tau) :* (J(no, 1, 1) * (wobs :* aobs))
    P = ATT :^ theta
    denom = rowsum(P)
    P = P :/ denom
    L = Lo * P
    H = make_H(Lo, q, P, theta, selmode)
    Ybase = sum(wobs :* H)
    y = ((wobs :* H) :^ (sigma/(sigma - 1))) :/ (Ybase ^ (1/(sigma - 1)))
    p = (Ybase :/ y) :^ (1/sigma)
    A = wobs :/ p
    Abar = A :/ (H :^ gamma)
    abar = aobs :/ (L :^ lambda)
}

real rowvector three(real rowvector Lo, real rowvector q, real matrix TAU,
                     real rowvector W, real rowvector AL,
                     real scalar theta, real scalar selmode)
{
    real scalar gamma, lambda, sigma, maxit, tol, damp, nd
    real scalar Yb, Y0, Y1, Y2, Y3
    real rowvector Abar, abar, b2
    real matrix tau0
    gamma=0.05; lambda=-0.075; sigma=8; maxit=20000; tol=1e-13; damp=0.5
    nd = cols(W)
    tau0 = J(rows(TAU), cols(TAU), 0)
    gcalib(Lo, q, TAU, W, AL, theta, gamma, lambda, sigma, selmode,
           Abar, abar, Yb)
    b2 = J(1, nd, abar[1])
    Y0 = gsolve(Lo, q, TAU, W, AL, Abar, abar, theta, gamma, lambda, sigma,
                selmode, maxit, tol, damp)
    Y1 = gsolve(Lo, q, tau0, W, AL, Abar, abar, theta, gamma, lambda, sigma,
                selmode, maxit, tol, damp)
    Y2 = gsolve(Lo, q, TAU, W, AL, Abar, b2, theta, gamma, lambda, sigma,
                selmode, maxit, tol, damp)
    Y3 = gsolve(Lo, q, tau0, W, AL, Abar, b2, theta, gamma, lambda, sigma,
                selmode, maxit, tol, damp)
    return((Y1/Y0, Y2/Y0, Y3/Y0, Y0/Yb))
}

void qdiag(real rowvector QQ, real rowvector LO)
{
    real colvector lq, lw
    real scalar sdq, cv, rng
    lq = ln(QQ')
    sdq = sqrt(variance(lq))
    cv = sqrt(variance(QQ')) / mean(QQ')      // 水平上的变异系数
    rng = exp(max(lq) - min(lq))
    printf("      sd(ln q_o)=%6.4f   q_o 极差比=%6.4f   变异系数=%6.4f\n", sdq, rng, cv)
}
end

*==============================================================================
* 重建面板 + 估计
*==============================================================================
display _n "===== 1. 面板与估计 ====="

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
rename m_w m_od
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
display "  N = " _N

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
local olist ""
forvalues i = 1/`NO' {
    local olist "`olist' `=OLIST[`i',1]'"
}
local dlist ""
forvalues i = 1/`ND' {
    local dlist "`dlist' `=DLIST[`i',1]'"
}

quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
quietly predict double phat, xb
quietly ivregress 2sls ln_wage (ln_p = phat) i.o i.d, cluster(o)
display "  式(7) 估出的 θ = " %8.4f -1/_b[ln_p] "   （本次用 `TH'）"
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
display "  θ̃ = " %8.4f `ttilde'

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
quietly gen double lhs_sym = (ln_p - ln_poo) + (ln_p_rev - ln_pdd)
quietly gen double tau_obs = 1 - exp(lhs_sym/(2*`TH'))
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
quietly gen double q_orig = q_o

* τ 网格
tempfile panelmain tauobs o17 d17
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
merge 1:1 o d using `tauobs', keep(master match) nogen
quietly regress tau_obs i.o i.d
quietly predict double tau_full, xb
quietly replace tau_full = 0 if o == d
sort o d
mkmat tau_full, matrix(TAUF)
display "  τ 网格：" rowsof(TAUF) " = `NO'×`ND'"

* 固定向量
use `panelmain', clear
tempname W AL LO
matrix `W'  = J(1, `ND', .)
matrix `AL' = J(1, `ND', .)
matrix `LO' = J(1, `NO', .)
forvalues i = 1/`ND' {
    local cc : word `i' of `dlist'
    quietly summarize w_d if d == `cc'
    matrix `W'[1, `i'] = r(mean)
    quietly summarize alpha_d if d == `cc'
    matrix `AL'[1, `i'] = r(mean)
}
forvalues i = 1/`NO' {
    local cc : word `i' of `olist'
    quietly summarize pop_o if o == `cc'
    matrix `LO'[1, `i'] = r(mean)
}

*==============================================================================
* 2. ψ 循环
*==============================================================================
display _n(2) "{hline 92}"
display "  2. ψ ∈ {0.0, 0.5, 1.0, 1.5, 2.0, 3.0}"
display "     变换：ln q_o^ψ = ψ · ln q_o"
display "{hline 92}"

matrix RES = J(6, 12, .)
local r = 0

foreach psi of numlist 0.0 0.5 1.0 1.5 2.0 3.0 {
    local r = `r' + 1
    display _n "  ── ψ = `psi' ──────────────────────────────────────────────────"

    capture drop q_psi
    quietly gen double q_psi = q_orig^(`psi')

    tempname QP
    matrix `QP' = J(1, `NO', .)
    forvalues i = 1/`NO' {
        local cc : word `i' of `olist'
        quietly summarize q_psi if o == `cc'
        matrix `QP'[1, `i'] = r(mean)
    }

    mata: qdiag(st_matrix("`QP'"), st_matrix("`LO'"))

    mata: st_matrix("R0", three(st_matrix("`LO'"), st_matrix("`QP'"), rowshape(st_matrix("TAUF"), `NO'), st_matrix("`W'"), st_matrix("`AL'"), `TH', 0))
    mata: st_matrix("R1", three(st_matrix("`LO'"), st_matrix("`QP'"), rowshape(st_matrix("TAUF"), `NO'), st_matrix("`W'"), st_matrix("`AL'"), `TH', 1))

    display "      含选择       列1 " %8.4f R0[1,1] "  列2 " %8.4f R0[1,2] "  列3 " %8.4f R0[1,3]
    display "      No selection 列1 " %8.4f R1[1,1] "  列2 " %8.4f R1[1,2] "  列3 " %8.4f R1[1,3]
    display "      ⇒ 差(1)=" %8.4f R0[1,1]-R1[1,1] "  差(2)=" %8.4f R0[1,2]-R1[1,2] "  差(3)=" %8.4f R0[1,3]-R1[1,3]

    matrix RES[`r', 1]  = `psi'
    matrix RES[`r', 2]  = R0[1,1]
    matrix RES[`r', 3]  = R0[1,2]
    matrix RES[`r', 4]  = R0[1,3]
    matrix RES[`r', 5]  = R1[1,1]
    matrix RES[`r', 6]  = R1[1,2]
    matrix RES[`r', 7]  = R1[1,3]
    matrix RES[`r', 8]  = R0[1,1]-R1[1,1]
    matrix RES[`r', 9]  = R0[1,2]-R1[1,2]
    matrix RES[`r', 10] = R0[1,3]-R1[1,3]
}

*==============================================================================
* 3. 汇总
*==============================================================================
display _n(2) "{hline 92}"
display "  3. 汇总"
display "{hline 92}"
display _n "  ψ    含选择:列1   列2     列3  |  NoSel:列1   列2     列3   | 差(1)    差(2)    差(3)"
display "  " "{hline 92}"
forvalues r = 1/6 {
    display "  " %3.1f RES[`r',1] "   " %8.4f RES[`r',2] "  " %7.4f RES[`r',3] "  " %7.4f RES[`r',4] "  |  " %7.4f RES[`r',5] "  " %7.4f RES[`r',6] "  " %7.4f RES[`r',7] "  |  " %7.4f RES[`r',8] "  " %7.4f RES[`r',9] "  " %7.4f RES[`r',10]
}
display ""
display "  ⭐ JPE Table 5：含选择 1.075 / 1.127 / 1.217 ，No selection .914 / 1.127 / 1.133"
display "     目标：差(1) = 0.161（论文头条结论）    差(2) ≈ 0.001"
display ""
display "  ── 差(1) 对 ψ 的响应（这是论文最看重的量）──"
forvalues r = 1/6 {
    display "     ψ=" %3.1f RES[`r',1] "  →  差(1) = " %7.4f RES[`r',8] "   偏离论文 0.161 为 " %8.4f RES[`r',8]-0.161
}
display ""
display "  ── 差(2) 对 ψ 的响应（这是还没解释的那 0.027）──"
forvalues r = 1/6 {
    display "     ψ=" %3.1f RES[`r',1] "  →  差(2) = " %7.4f RES[`r',9]
}
display ""
display "  判断："
if abs(RES[3,9]) > 0.005 & abs(RES[1,9]) > 0.005 {
    display "     ❌ 差(2) 在整个 ψ 范围内都远离 0.001 ⇒ q_o 也不是那 0.027 的来源"
}
else {
    display "     ⚠ 差(2) 在某个 ψ 下接近 0.001，需要具体看"
}
display "     ψ=1 时差(1) = " %7.4f RES[3,8] " ，论文 0.161"

display _n(2) "{hline 92}"
display "  运行结束：$S_DATE $S_TIME"
display "{hline 92}"
log close