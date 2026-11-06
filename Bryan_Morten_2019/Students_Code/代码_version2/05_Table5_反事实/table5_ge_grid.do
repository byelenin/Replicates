*==============================================================================
* table5_ge_grid.do
*   最后一个参数类测试：γ × λ × σ 网格（论文自己的稳健性练习）
*
*   全部范围取自 JPE 正文（不用 WP）：
*     γ  主口径 0.05，稳健 0 → 0.08                     （全 1672–1673 行）
*     λ  = λ_a − 0.3·λ_r，主口径 −0.075                   （全 1698 行）
*        λ_a = 0（起点）/ −0.04（Combes-Gobillon）        （全 1679–1681 行）
*        λ_r = 0.25（印尼自估）/ 0.65（Saiz 美国）        （全 1694–1696 行）
*        住房支出份额 = 0.3                                （全 1697 行）
*     σ  主口径 8，稳健 4 → 8                             （全 1704–1705 行）
*
*   问题：在论文自己报的整个参数范围里，第(2)列的
*         「含选择 − 无选择」差能否达到 0.001？
*   若不能 ⇒ 可以确定地说 0.027 是【数据范围】问题，不是参数问题。
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
matrix drop _all
capture log close
log using "table5_ge_grid_out.log", replace text

local root "D:\研一上\微观计量"
local TH   12.4399

display _n(2) "{hline 96}"
display "  γ × λ × σ 网格    θ = `TH'"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 96}"

*==============================================================================
* Mata
*==============================================================================
mata:

// 收敛诊断计数器（跨函数共享；Mata 顶层不能裸声明，赋值即创建全局）
GC_ERR = 0
GC_FLOOR = 0

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
    external real scalar GC_ERR
    external real scalar GC_FLOOR
    real scalar no, nd, it, Y, err, floored
    real rowvector w, alpha, L, H, A, wnew, anew, denom
    real matrix ATT, P
    no = cols(Lo)
    nd = cols(w0)
    w = w0
    alpha = a0
    err = 1e10
    floored = 0
    for (it = 1; it <= maxit; it++) {
        ATT = (1 :- tau) :* (J(no, 1, 1) * (w :* alpha))
        P = ATT :^ theta
        denom = rowsum(P)
        P = P :/ denom
        L = Lo * P
        H = make_H(Lo, q, P, theta, selmode)
        if (min(H) <= 0) {
            floored = floored + 1
            H = H :+ 1e-12
        }
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
    if (err > GC_ERR) GC_ERR = err
    if (floored > 0) GC_FLOOR = GC_FLOOR + 1
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

// 一个 (γ, λ, σ, selmode) 下的三列 gain
real rowvector three3(real rowvector Lo, real rowvector q, real matrix TAU,
                      real rowvector W, real rowvector AL,
                      real scalar theta, real scalar selmode,
                      real scalar gamma, real scalar lambda, real scalar sigma)
{
    real scalar maxit, tol, damp, nd, Yb, Y0, Y1, Y2, Y3
    real rowvector Abar, abar, b2
    real matrix tau0
    maxit=20000; tol=1e-13; damp=0.5
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
    return((Y1/Y0, Y2/Y0, Y3/Y0))
}

// 一个格子的六个结果：含选择三列 + 无选择三列
real rowvector cell6(real rowvector Lo, real rowvector q, real matrix TAU,
                     real rowvector W, real rowvector AL,
                     real scalar theta, real scalar gamma,
                     real scalar lambda, real scalar sigma)
{
    external real scalar GC_ERR
    external real scalar GC_FLOOR
    GC_ERR = 0
    GC_FLOOR = 0
    return((three3(Lo,q,TAU,W,AL,theta,0,gamma,lambda,sigma),
            three3(Lo,q,TAU,W,AL,theta,1,gamma,lambda,sigma),
            GC_ERR, GC_FLOOR))
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

use `panelmain', clear
tempname W AL QQ LO
matrix `W'  = J(1, `ND', .)
matrix `AL' = J(1, `ND', .)
matrix `QQ' = J(1, `NO', .)
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
    quietly summarize q_o if o == `cc'
    matrix `QQ'[1, `i'] = r(mean)
    quietly summarize pop_o if o == `cc'
    matrix `LO'[1, `i'] = r(mean)
}

*==============================================================================
* 2. 网格
*==============================================================================
display _n(2) "{hline 96}"
display "  2. γ × λ × σ 网格（6 × 4 × 2 = 48 格）"
display "{hline 96}"
display "  γ  ∈ {0, 0.02, 0.04, 0.05, 0.06, 0.08}"
display "  λ  ∈ {−0.075, −0.115, −0.195, −0.235}"
display "  σ  ∈ {4, 8}"
display ""

matrix GRID = J(48, 13, .)
local r = 0
local dmin = 1e30
local dmax = -1e30
local nbad = 0

foreach sg of numlist 4 8 {
    foreach gam of numlist 0 0.02 0.04 0.05 0.06 0.08 {
        foreach lam of numlist -0.075 -0.115 -0.195 -0.235 {
            local r = `r' + 1
            mata: st_matrix("CV", cell6(st_matrix("`LO'"), st_matrix("`QQ'"), rowshape(st_matrix("TAUF"), `NO'), st_matrix("`W'"), st_matrix("`AL'"), `TH', `gam', `lam', `sg'))
            local d1 = CV[1,1] - CV[1,4]
            local d2 = CV[1,2] - CV[1,5]
            local d3 = CV[1,3] - CV[1,6]
            matrix GRID[`r', 1]  = `sg'
            matrix GRID[`r', 2]  = `gam'
            matrix GRID[`r', 3]  = `lam'
            matrix GRID[`r', 4]  = CV[1,1]
            matrix GRID[`r', 5]  = CV[1,2]
            matrix GRID[`r', 6]  = CV[1,3]
            matrix GRID[`r', 7]  = CV[1,4]
            matrix GRID[`r', 8]  = CV[1,5]
            matrix GRID[`r', 9]  = CV[1,6]
            matrix GRID[`r', 10] = `d1'
            matrix GRID[`r', 11] = `d2'
            matrix GRID[`r', 12] = CV[1,7]
            matrix GRID[`r', 13] = CV[1,8]
            if `d2' < `dmin' local dmin = `d2'
            if `d2' > `dmax' local dmax = `d2'
            if CV[1,7] >= 1e-13 | CV[1,8] > 0 local nbad = `nbad' + 1
            if `gam' == 0.05 & `lam' == -0.075 {
                display "      ▶ 基准格 σ=`sg' γ=`gam' λ=`lam'   含选择 " %7.4f CV[1,1] " / " %7.4f CV[1,2] " / " %7.4f CV[1,3] "   无选择 " %7.4f CV[1,4] " / " %7.4f CV[1,5] " / " %7.4f CV[1,6] "   差(2)=" %7.4f `d2' "   收敛误差=" %10.2e CV[1,7] " 触底=" %2.0f CV[1,8]
            }
        }
    }
}

*==============================================================================
* 3. 汇总
*==============================================================================
display _n(2) "{hline 96}"
display "  3. 全网格"
display "{hline 96}"
display _n "   σ    γ      λ      含选择:列1   列2     列3   |  无选择:列1   列2     列3   | 差(1)    差(2)   | 收敛误差   触底"
display "  " "{hline 110}"
forvalues r = 1/48 {
    local flag ""
    if GRID[`r',12] >= 1e-13 | GRID[`r',13] > 0 local flag " ⚠失效"
    display "  " %2.0f GRID[`r',1] "  " %5.2f GRID[`r',2] "  " %7.3f GRID[`r',3] "   " %7.4f GRID[`r',4] "  " %7.4f GRID[`r',5] "  " %7.4f GRID[`r',6] "  |  " %7.4f GRID[`r',7] "  " %7.4f GRID[`r',8] "  " %7.4f GRID[`r',9] "  | " %7.4f GRID[`r',10] "  " %7.4f GRID[`r',11] "  | " %9.2e GRID[`r',12] "  " %4.0f GRID[`r',13] "`flag'"
}

display _n(2) "{hline 96}"
display "  4. 判断"
display "{hline 96}"
display ""
display "  ⭐ JPE Table 5：含选择 1.075 / 1.127 / 1.217 ，No selection .914 / 1.127 / 1.133"
display "     目标：差(1) = 0.161（论文头条结论）   差(2) ≈ 0.001"
display ""
display "  48 个格子中，差(2) 的最小值 = " %8.4f `dmin'
display "                  最大值 = " %8.4f `dmax'
display "  数值失效的格子数 = " `nbad' " / 48"
display ""
display "  ── 只用【数值有效】的格子重算 ──"
local vmin = 1e30
local vmax = -1e30
local vmin1 = 1e30
local vmax1 = -1e30
local nv = 0
forvalues r = 1/48 {
    if GRID[`r',12] < 1e-13 & GRID[`r',13] == 0 {
        local nv = `nv' + 1
        if GRID[`r',11] < `vmin' local vmin = GRID[`r',11]
        if GRID[`r',11] > `vmax' local vmax = GRID[`r',11]
        if GRID[`r',10] < `vmin1' local vmin1 = GRID[`r',10]
        if GRID[`r',10] > `vmax1' local vmax1 = GRID[`r',10]
    }
}
display "  有效格子数 = " `nv'
display "  差(2) 有效范围 = " %8.4f `vmin' "  →  " %8.4f `vmax'
display "  差(1) 有效范围 = " %8.4f `vmin1' "  →  " %8.4f `vmax1' "   （论文 0.161）"
display ""
if `vmin' > 0.005 {
    display "  ⇒ ❌ 在所有【数值有效】的格子中，差(2) 从未接近 0.001（最小 " %7.4f `vmin' "）"
    display "     结论：0.027 不是【参数选择】造成的，而且这个结论不受参数取值范围影响。"
}
else {
    display "  ⇒ ⚠️ 有有效格子的差(2) 接近 0.001，需要具体看"
}
display ""
display "  ── 差(1) 的分布（论文 0.161）──"
local smin = 1e30
local smax = -1e30
forvalues r = 1/48 {
    if GRID[`r',10] < `smin' local smin = GRID[`r',10]
    if GRID[`r',10] > `smax' local smax = GRID[`r',10]
}
display "     最小 = " %8.4f `smin' "    最大 = " %8.4f `smax'
display "     ⇒ 差(1) 在整个参数范围内稳定，论文的 0.161 " %8.4f `smin' "–" %8.4f `smax'
display ""
display "  ── 含选择列(2) 的水平（论文 1.127）──"
local pmin = 1e30
local pmax = -1e30
forvalues r = 1/48 {
    if GRID[`r',5] < `pmin' local pmin = GRID[`r',5]
    if GRID[`r',5] > `pmax' local pmax = GRID[`r',5]
}
display "     最小 = " %8.4f `pmin' "    最大 = " %8.4f `pmax'

display _n(2) "{hline 96}"
display "  运行结束：$S_DATE $S_TIME"
display "{hline 96}"
log close