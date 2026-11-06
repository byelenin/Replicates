*==============================================================================
* table5_pi_diag.do
*   基准校准用【观测 π】还是【模型 π】？
*
*   现状（变体 M）：用模型算出的 π 建 L_d、H_d，再反推 Ā_d、ᾱ_d。
*                   好处：基准是严格不动点（自检 1e-15）。
*                   代价：模型的 π ≠ 数据观测的 π。
*
*   变体 O：用【数据观测的迁移流】建 L_d、H_d，再反推 Ā_d、ᾱ_d。
*           这是论文更可能的做法（论文的模型带残差，π 并不精确等于观测值）。
*
*   另一个维度：基准 Y 用哪个？
*     base=model ：Y_base = Σ_d w_d H_d(model π)   —— 模型自己的均衡
*     base=obs   ：Y_base = Σ_d w_d H_d(obs  π)   —— 观测经济的产出（论文 "output gain" 的自然读法）
*
*   观测 π 有 64 个空格（1995 年零流量），用模型 π 补，然后按行归一化。
*   缺格比例会照实报出来。
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
matrix drop _all
capture log close
log using "table5_pi_diag_out.log", replace text

local root "D:\研一上\微观计量"
local TH   12.4399

display _n(2) "{hline 92}"
display "  基准校准：观测 π vs 模型 π    θ = `TH'"
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

// 模型隐含的 π
real matrix model_pi(real rowvector w, real rowvector a, real matrix tau,
                     real scalar theta)
{
    real scalar no
    real matrix ATT, P
    no = rows(tau)
    ATT = (1 :- tau) :* (J(no, 1, 1) * (w :* a))
    P = ATT :^ theta
    return( P :/ rowsum(P) )
}

// 把观测 π 的空格（0）用模型 π 补上，再按行归一化
real matrix fill_pi(real matrix PIOBS, real matrix PM)
{
    real scalar i, j, no, nd
    real matrix P
    no = rows(PIOBS)
    nd = cols(PIOBS)
    P = PIOBS
    for (i = 1; i <= no; i++) {
        for (j = 1; j <= nd; j++) {
            if (P[i,j] <= 0) P[i,j] = PM[i,j]
        }
    }
    return( P :/ rowsum(P) )
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

// 给定 H_d 和 L_d 反推 Ā_d、ᾱ_d
void backout(real rowvector wobs, real rowvector aobs,
             real rowvector H, real rowvector L,
             real scalar gamma, real scalar lambda, real scalar sigma,
             real rowvector Abar, real rowvector abar, real scalar Ybase)
{
    real rowvector A, p, y
    Ybase = sum(wobs :* H)
    y = ((wobs :* H) :^ (sigma/(sigma - 1))) :/ (Ybase ^ (1/(sigma - 1)))
    p = (Ybase :/ y) :^ (1/sigma)
    A = wobs :/ p
    Abar = A :/ (H :^ gamma)
    abar = aobs :/ (L :^ lambda)
}

// 一个变体：返回 (col1, col2, col3, Ybase)
// usepiobs: 0=模型 π 反推   1=观测 π 反推
// baseobs : 0=基准 Y 用模型均衡   1=基准 Y 用观测 π
real rowvector variant(real rowvector Lo, real rowvector q, real matrix TAU,
                       real matrix PIOBS,
                       real rowvector W, real rowvector AL,
                       real scalar theta, real scalar selmode,
                       real scalar usepiobs, real scalar baseobs)
{
    real scalar gamma, lambda, sigma, maxit, tol, damp, nd
    real scalar Ymod, Yobs, Yb, Y1, Y2, Y3
    real rowvector Abar, abar, b2, H, L
    real matrix tau0, PM, P
    gamma=0.05; lambda=-0.075; sigma=8; maxit=20000; tol=1e-13; damp=0.5
    nd = cols(W)
    tau0 = J(rows(TAU), cols(TAU), 0)

    PM = model_pi(W, AL, TAU, theta)
    P  = fill_pi(PIOBS, PM)

    if (usepiobs == 0) {
        L = Lo * PM
        H = make_H(Lo, q, PM, theta, selmode)
    }
    else {
        L = Lo * P
        H = make_H(Lo, q, P, theta, selmode)
    }
    backout(W, AL, H, L, gamma, lambda, sigma, Abar, abar, Yobs)
    Ymod = gsolve(Lo, q, TAU, W, AL, Abar, abar, theta, gamma, lambda, sigma,
                  selmode, maxit, tol, damp)

    if (baseobs == 1) Yb = Yobs
    else              Yb = Ymod

    b2 = J(1, nd, abar[1])
    Y1 = gsolve(Lo, q, tau0, W, AL, Abar, abar, theta, gamma, lambda, sigma,
                selmode, maxit, tol, damp)
    Y2 = gsolve(Lo, q, TAU, W, AL, Abar, b2, theta, gamma, lambda, sigma,
                selmode, maxit, tol, damp)
    Y3 = gsolve(Lo, q, tau0, W, AL, Abar, b2, theta, gamma, lambda, sigma,
                selmode, maxit, tol, damp)
    // 第 5 个返回值是模型的基准 vs 观测基准，用来衡量内部一致性
    return((Y1/Yb, Y2/Yb, Y3/Yb, Ymod/Yobs))
}

// 诊断：观测 π 与模型 π 的差
void pi_gap(real matrix PIOBS, real rowvector W, real rowvector AL,
            real matrix TAU, real rowvector LO, real scalar theta)
{
    real matrix PM, P
    real scalar nz, i, j, avg, mx
    PM = model_pi(W, AL, TAU, theta)
    P  = fill_pi(PIOBS, PM)
    nz = 0
    for (i=1; i<=rows(PIOBS); i++) for (j=1; j<=cols(PIOBS); j++) if (PIOBS[i,j] <= 0) nz = nz + 1
    avg = sum(abs(P - PM)) / (rows(P)*cols(P))
    mx  = max(vec(abs(P - PM)))
    printf("      观测 π 空格数 = %f / %f   平均绝对偏差 = %10.7f   最大 = %10.7f\n",
           nz, rows(PIOBS)*cols(PIOBS), avg, mx)
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

* ---- 网格工具 ----
tempfile panelmain tauobs o17 d17 piall
quietly save `panelmain', replace

* τ 网格
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

* ---- 观测 π 网格（含对角线）----
use `panelmain', clear
keep o d pi_do
rename pi_do pi_obs
tempfile pioff
save `pioff'
use `panelmain', clear
keep if o == d
keep o d pi_do
rename pi_do pi_obs
append using `pioff'
save `piall', replace
use `o17', clear
cross using `d17'
rename oo o
rename dd d
sort o d
merge 1:1 o d using `piall', keep(master match) nogen
quietly replace pi_obs = 0 if missing(pi_obs)
quietly count if pi_obs <= 0
display "  观测 π 空格数（含对角线）= " r(N) " / `=`NO'*`ND''"
sort o d
mkmat pi_obs, matrix(PIOBS)

* ---- 固定向量 ----
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
* 2. 四个变体
*==============================================================================
display _n(2) "{hline 92}"
display "  2. 变体：{模型π, 观测π} × {基准Y=模型, 基准Y=观测} × {含选择, 无选择}"
display "{hline 92}"

mata: pi_gap(rowshape(st_matrix("PIOBS"), `NO'), st_matrix("`W'"), st_matrix("`AL'"), rowshape(st_matrix("TAUF"), `NO'), st_matrix("`LO'"), `TH')

matrix RES = J(8, 8, .)
local r = 0
foreach up of numlist 0 1 {
    foreach bo of numlist 0 1 {
        foreach se of numlist 0 1 {
            local r = `r' + 1
            mata: st_matrix("RV", variant(st_matrix("`LO'"), st_matrix("`QQ'"), rowshape(st_matrix("TAUF"), `NO'), rowshape(st_matrix("PIOBS"), `NO'), st_matrix("`W'"), st_matrix("`AL'"), `TH', `se', `up', `bo'))
            matrix RES[`r', 1] = `up'
            matrix RES[`r', 2] = `bo'
            matrix RES[`r', 3] = `se'
            matrix RES[`r', 4] = RV[1,1]
            matrix RES[`r', 5] = RV[1,2]
            matrix RES[`r', 6] = RV[1,3]
            matrix RES[`r', 7] = RV[1,4]
            display "      π=`up' 基准Y=`bo' 选择=`se'  →  列1 " %8.4f RV[1,1] "  列2 " %8.4f RV[1,2] "  列3 " %8.4f RV[1,3] "   (模型Y/观测Y = " %8.5f RV[1,4] ")"
        }
    }
}

*==============================================================================
* 3. 汇总
*==============================================================================
display _n(2) "{hline 92}"
display "  3. 汇总"
display "{hline 92}"
display _n "  π反推  基准Y   选择      列1      列2      列3   |  模型Y/观测Y"
display "  " "{hline 92}"
forvalues r = 1/8 {
    local lb : word `=RES[`r',3]+1' of "含选择 无选择"
    display "    " %1.0f RES[`r',1] "      " %1.0f RES[`r',2] "     `lb'   " %7.4f RES[`r',4] "  " %7.4f RES[`r',5] "  " %7.4f RES[`r',6] "  |  " %9.5f RES[`r',7]
}
display ""
display "  ⭐ JPE Table 5：含选择 1.075 / 1.127 / 1.217 ，No selection .914 / 1.127 / 1.133"
display ""
display "  ── 每个变体下 第(2)列 的「含选择 − 无选择」差 ──"
forvalues up = 0/1 {
    forvalues bo = 0/1 {
        local a = .
        local b = .
        forvalues r = 1/8 {
            if RES[`r',1] == `up' & RES[`r',2] == `bo' & RES[`r',3] == 0 local a = RES[`r',5]
            if RES[`r',1] == `up' & RES[`r',2] == `bo' & RES[`r',3] == 1 local b = RES[`r',5]
        }
        local d = `a' - `b'
        display "     π反推=`up' 基准Y=`bo' ： " %7.4f `a' " − " %7.4f `b' " = " %7.4f `d'
    }
}
display ""
display "  ── 第(1)列 的差（论文 0.161）──"
forvalues up = 0/1 {
    forvalues bo = 0/1 {
        local a = .
        local b = .
        forvalues r = 1/8 {
            if RES[`r',1] == `up' & RES[`r',2] == `bo' & RES[`r',3] == 0 local a = RES[`r',4]
            if RES[`r',1] == `up' & RES[`r',2] == `bo' & RES[`r',3] == 1 local b = RES[`r',4]
        }
        local d = `a' - `b'
        display "     π反推=`up' 基准Y=`bo' ： " %7.4f `a' " − " %7.4f `b' " = " %7.4f `d'
    }
}

display _n(2) "{hline 92}"
display "  运行结束：$S_DATE $S_TIME"
display "{hline 92}"
log close