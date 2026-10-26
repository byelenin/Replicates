*==============================================================================
* table5_alpha_diag.do
*   α_d「弱识别」对 Table 5 第(2)列的贡献有多大？
*
*   设计：把 α_d 的离散度按 φ 收缩，同时让 w_d 吸收差额，
*         保持【乘积 w_d·α_d 严格不变】—— 因为论文式(9) 的省固定效应
*         识别的是乘积 θ·ln(w_d α_d)，式(7) 单独识别 w_d。
*
*     ln α_d^φ = φ · ln α_d
*     ln w_d^φ = ln w_d + (1−φ) · ln α_d
*     ⇒ ln(w_d^φ α_d^φ) = ln w_d + ln α_d    （引力拟合完全不变）
*
*   φ = 1.0 → 原样（α_d 离散度最大，w_d·α_d 平坦）
*   φ = 0.0 → α_d 完全拉平，w_d 承担全部离散
*
*   每套 φ 下分别跑「含选择」与「No selection」，看第(2)列两行的差如何变。
*   若某个 φ 让差塌到 0.001 量级 ⇒ α_d 弱识别就是那 0.027 的来源。
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
matrix drop _all
capture log close
log using "table5_alpha_diag_out.log", replace text

local root "D:\研一上\微观计量"
local TH   12.4399

display _n(2) "{hline 90}"
display "  α_d 弱识别的贡献诊断    θ = `TH'"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 90}"

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

// 求均衡 Y
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

// 校准
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

// 一套 φ 参数下，某个 selection 口径的三列 gain
real rowvector three(real rowvector Lo, real rowvector q, real matrix TAU,
                     real rowvector W, real rowvector AL,
                     real scalar theta, real scalar selmode,
                     real scalar amfix)
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
    if (amfix == 1) {
        Y2 = gsolve(Lo, q, TAU, W, b2, Abar, b2, theta, gamma, lambda, sigma,
                    selmode, maxit, tol, damp)
        Y3 = gsolve(Lo, q, tau0, W, b2, Abar, b2, theta, gamma, lambda, sigma,
                    selmode, maxit, tol, damp)
    }
    else {
        Y2 = gsolve(Lo, q, TAU, W, AL, Abar, b2, theta, gamma, lambda, sigma,
                    selmode, maxit, tol, damp)
        Y3 = gsolve(Lo, q, tau0, W, AL, Abar, b2, theta, gamma, lambda, sigma,
                    selmode, maxit, tol, damp)
    }
    return((Y1/Y0, Y2/Y0, Y3/Y0, Y0/Yb))
}

// 横截面诊断：sd(ln α)、sd(ln w)、corr、ln(wα) 极差
void diag_out(real rowvector W, real rowvector AL)
{
    real rowvector lprod
    real scalar sdw, sda, c, rng
    lw = ln(W')          // Mata 的 variance/correlation 要列向量
    la = ln(AL')
    lprod = lw + la
    sdw = sqrt(variance(lw))
    sda = sqrt(variance(la))
    c = correlation(lw, la)
    rng = max(lprod) - min(lprod)
    printf("      sd(ln w_d)=%6.4f  sd(ln α_d)=%6.4f  corr=%7.4f  ln(w·α) 极差=%6.4f\n",
           sdw, sda, c, rng)
}
end

*==============================================================================
* 重建面板 + 估计（这一套与 table5_counterfactual.do 完全一致）
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
quietly gen double w_orig  = w_d
quietly gen double al_orig = alpha_d

* τ 网格（不随 φ 变）
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

* 基础向量（用于 φ 变换）—— 先把面板取回内存
use `panelmain', clear
tempname W0 AL0 QQ LO
matrix `W0'  = J(1, `ND', .)
matrix `AL0' = J(1, `ND', .)
matrix `QQ'  = J(1, `NO', .)
matrix `LO'  = J(1, `NO', .)
forvalues i = 1/`ND' {
    local cc : word `i' of `dlist'
    quietly summarize w_orig if d == `cc'
    matrix `W0'[1, `i'] = r(mean)
    quietly summarize al_orig if d == `cc'
    matrix `AL0'[1, `i'] = r(mean)
}
forvalues i = 1/`NO' {
    local cc : word `i' of `olist'
    quietly summarize q_o if o == `cc'
    matrix `QQ'[1, `i'] = r(mean)
    quietly summarize pop_o if o == `cc'
    matrix `LO'[1, `i'] = r(mean)
}

*==============================================================================
* 2. φ 循环
*==============================================================================
display _n(2) "{hline 90}"
display "  2. φ ∈ {1.0, 0.8, 0.7, 0.5, 0.3, 0.0}"
display "     变换：ln α^φ = φ·ln α ，  ln w^φ = ln w + (1−φ)·ln α（乘积不变）"
display "{hline 90}"

matrix RES = J(6, 12, .)
local r = 0

foreach phi of numlist 1.0 0.8 0.7 0.5 0.3 0.0 {
    local r = `r' + 1
    display _n "  ── φ = `phi' ──────────────────────────────────────────────────"

    * 在面板层面做变换（按省，值唯一）
    capture drop w_phi
    capture drop al_phi
    quietly gen double w_phi  = w_orig * (al_orig^(`=1-`phi''))
    quietly gen double al_phi = al_orig^(`phi')

    tempname WP AP
    matrix `WP' = J(1, `ND', .)
    matrix `AP' = J(1, `ND', .)
    forvalues i = 1/`ND' {
        local cc : word `i' of `dlist'
        quietly summarize w_phi if d == `cc'
        matrix `WP'[1, `i'] = r(mean)
        quietly summarize al_phi if d == `cc'
        matrix `AP'[1, `i'] = r(mean)
    }

    * 横截面诊断
    mata: diag_out(st_matrix("`WP'"), st_matrix("`AP'"))

    * 含选择（selmode=0）
    mata: st_matrix("R0", three(st_matrix("`LO'"), st_matrix("`QQ'"), rowshape(st_matrix("TAUF"), `NO'), st_matrix("`WP'"), st_matrix("`AP'"), `TH', 0, 0))
    * No selection（selmode=1）
    mata: st_matrix("R1", three(st_matrix("`LO'"), st_matrix("`QQ'"), rowshape(st_matrix("TAUF"), `NO'), st_matrix("`WP'"), st_matrix("`AP'"), `TH', 1, 0))

    display "      含选择     列1 " %8.4f R0[1,1] "  列2 " %8.4f R0[1,2] "  列3 " %8.4f R0[1,3]
    display "      No selection 列1 " %8.4f R1[1,1] "  列2 " %8.4f R1[1,2] "  列3 " %8.4f R1[1,3]
    display "      ⇒ 第(2)列之差 = " %8.4f R0[1,2]-R1[1,2] "    第(1)列之差 = " %8.4f R0[1,1]-R1[1,1]

    matrix RES[`r', 1]  = `phi'
    matrix RES[`r', 2]  = R0[1,1]
    matrix RES[`r', 3]  = R0[1,2]
    matrix RES[`r', 4]  = R0[1,3]
    matrix RES[`r', 5]  = R1[1,1]
    matrix RES[`r', 6]  = R1[1,2]
    matrix RES[`r', 7]  = R1[1,3]
    matrix RES[`r', 8]  = R0[1,2]-R1[1,2]
    matrix RES[`r', 9]  = R0[1,1]-R1[1,1]
    matrix RES[`r', 10] = R0[1,3]-R1[1,3]
}

*==============================================================================
* 3. 汇总
*==============================================================================
display _n(2) "{hline 90}"
display "  3. 汇总"
display "{hline 90}"
display _n "  φ     含选择:列1   列2     列3  |  NoSel:列1   列2     列3   | 差(2)    差(1)    差(3)"
display "  " "{hline 90}"
forvalues r = 1/6 {
    display "  " %3.1f RES[`r',1] "   " %8.4f RES[`r',2] "  " %7.4f RES[`r',3] "  " %7.4f RES[`r',4] "  |  " %7.4f RES[`r',5] "  " %7.4f RES[`r',6] "  " %7.4f RES[`r',7] "  |  " %7.4f RES[`r',8] "  " %7.4f RES[`r',9] "  " %7.4f RES[`r',10]
}
display ""
display "  ⭐ JPE Table 5：含选择 1.075 / 1.127 / 1.217 ，No selection .914 / 1.127 / 1.133"
display "     目标：差(2) ≈ 0.001（WP 口径 1.126 vs 1.125），差(1) ≈ 0.161"
display ""
display "  诊断：差(2) 从 φ=1 的 " %7.4f RES[1,8] " 变到 φ=0 的 " %7.4f RES[6,8]
display "        变化幅度 = " %7.4f RES[1,8]-RES[6,8] "   （这就是 α_d 离散度能解释的上限）"
display ""
display "  α_d 离散度确实是第(2)列差的来源？"
if abs(RES[6,8]) < 0.005 & abs(RES[1,8]) > 0.02 {
    display "     ✅ 是。α_d 拉平后第(2)列差塌到 0.005 以内"
}
else {
    display "     ❌ 不是唯一来源。φ=0 时差仍有 " %7.4f RES[6,8]
}

display _n(2) "{hline 90}"
display "  运行结束：$S_DATE $S_TIME"
display "{hline 90}"
log close