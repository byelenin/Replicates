*==============================================================================
* table5_nosel_test.do
*   验证 no-selection 的算法：哪种实现能让第(2)列在两行之间【相等】
*
*   同时检验第(2)列反事实本身的处理。论文第 1791–1794 行说：
*     「we assume that it is possible to fully control endogenous changes in
*      amenity and rents so that all locations are equally desirable places
*      to live」—— 即舒适度被【钉住】，不再随 L_d 内生调整。
*   注意：α_d 被钉成共同值时，在 π_do = (w_d α_d (1−τ))^θ/Σ… 里是公因子会被约掉，
*   所以「舒适度拉平」的实质 = 让重新配置只由工资 + τ 驱动。
*
*   测试矩阵：
*     selmode ∈ {0,1,2,3}   0=含选择  1=NS1 H=Γ̄ΣLqπ  2=NS2 H=Γ̄L_d·q̄
*                           3=NS3 H=L_d·(H^base/L^base)  冻结人均技能
*     amfix   ∈ {0,1}       0=列(2) 让 α 内生   1=列(2) 钉住 α（论文口径）
*   共 8 组，每组给出 列(1)/列(2)/列(3)。
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
matrix drop _all
capture log close
log using "table5_nosel_test_out.log", replace text

local root "D:\研一上\微观计量"
local TH   12.4399

display _n(2) "{hline 78}"
display "  no-selection 算法验证    θ = `TH'"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 78}"

*==============================================================================
* Mata
*==============================================================================
mata:

// H_d 的构造。selmode: 0=含选择 1=NS1 2=NS2 3=NS3
// hbar_d 仅在 selmode==3 时使用
real rowvector make_H(real rowvector Lo, real rowvector q, real matrix P,
                      real scalar theta, real scalar selmode,
                      real rowvector hbar)
{
    real scalar no
    real rowvector L, qbar
    no = cols(Lo)
    if (selmode == 0) return( (Lo :* q) * (P :^ (1 - 1/theta)) )
    if (selmode == 1) return( (Lo :* q) * P )
    if (selmode == 2) {
        L = Lo * P
        qbar = sum(Lo :* q) / sum(Lo)
        return( L :* qbar )
    }
    // selmode == 3
    L = Lo * P
    return( L :* hbar )
}

// 求均衡。amfix==1 时 α 钉在传入的 alpha0 不动（论文列(2)/(3)口径）
real scalar ge_solve2(real rowvector Lo, real rowvector q, real matrix tau,
                      real rowvector w0, real rowvector a0,
                      real rowvector Abar, real rowvector abar,
                      real scalar theta, real scalar gamma, real scalar lambda,
                      real scalar sigma, real scalar selmode, real scalar amfix,
                      real rowvector hbar,
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
    Y = .
    for (it = 1; it <= maxit; it++) {
        ATT   = (1 :- tau) :* (J(no, 1, 1) * (w :* alpha))
        P     = ATT :^ theta
        denom = rowsum(P)
        P     = P :/ denom
        L     = Lo * P
        H     = make_H(Lo, q, P, theta, selmode, hbar)
        if (min(H) <= 0) H = H :+ 1e-12
        A    = Abar :* (H :^ gamma)
        Y    = (sum((A :* H) :^ ((sigma - 1)/sigma))) ^ (sigma/(sigma - 1))
        wnew = (A :^ ((sigma - 1)/sigma)) :* (H :^ (-1/sigma)) :* (Y ^ (1/sigma))
        if (amfix == 1) anew = alpha
        else            anew = abar :* (L :^ lambda)
        err = max(abs(wnew - w) :/ (abs(w) :+ 1e-12))
        if (amfix == 0) err = max((err, max(abs(anew - alpha) :/ (abs(alpha) :+ 1e-12))))
        if (err < tol) {
            w = wnew
            alpha = anew
            break
        }
        w     = (1 - damp) * w     + damp * wnew
        alpha = (1 - damp) * alpha + damp * anew
    }
    return(Y)
}

// 基准校准
void calib2(real rowvector Lo, real rowvector q, real matrix tau,
            real rowvector wobs, real rowvector aobs,
            real scalar theta, real scalar gamma, real scalar lambda,
            real scalar sigma, real scalar selmode,
            real rowvector Abar, real rowvector abar,
            real rowvector Lmod, real rowvector Hmod, real scalar Ybase)
{
    real scalar no, nd
    real rowvector H, A, p, y, denom
    real matrix ATT, P
    no = cols(Lo)
    nd = cols(wobs)
    ATT = (1 :- tau) :* (J(no, 1, 1) * (wobs :* aobs))
    P = ATT :^ theta
    denom = rowsum(P)
    P = P :/ denom
    Lmod = Lo * P
    H = make_H(Lo, q, P, theta, selmode, J(1, nd, 0))
    Hmod = H
    Ybase = sum(wobs :* H)
    y = ((wobs :* H) :^ (sigma/(sigma - 1))) :/ (Ybase ^ (1/(sigma - 1)))
    p = (Ybase :/ y) :^ (1/sigma)
    A = wobs :/ p
    Abar = A :/ (H :^ gamma)
    abar = aobs :/ (Lmod :^ lambda)
}

// 一个组合：返回 (col1, col2, col3)
// shared==1 时：Ā_d 用【含选择校准】得到的那一套，之后不再重新校准
//   （理由：Ā_d 是地点的「内在生产率」，是地点的结构参数，
//     不应该因为换了 selection 假设就变。论文说 Ā_d 是 "intrinsic productivity—
//     an exogenous parameter"，第 1171–1173 行）
void one_combo(real rowvector Lo, real rowvector q, real matrix TAU,
               real rowvector W, real rowvector AL,
               real scalar theta, real scalar selmode, real scalar amfix,
               real scalar shared)
{
    real scalar gamma, lambda, sigma, maxit, tol, damp, nd
    real scalar Yb, Y0, Y1, Y2, Y3, Ybns, Y0ns
    real rowvector Abar, abar, Lm, Hm, b2, hbar
    real rowvector AbarS, abarS, LmS, HmS
    real matrix tau0

    gamma=0.05; lambda=-0.075; sigma=8; maxit=20000; tol=1e-13; damp=0.5
    nd = cols(W)
    tau0 = J(rows(TAU), cols(TAU), 0)

    // 先用【含选择】校准一套 Ā_d、ᾱ_d（永远如此，因为基准要与数据吻合）
    calib2(Lo, q, TAU, W, AL, theta, gamma, lambda, sigma, 0,
           AbarS, abarS, LmS, HmS, Yb)
    hbar = HmS :/ LmS

    if (shared == 1) {
        Abar = AbarS
        abar = abarS
    }
    else {
        calib2(Lo, q, TAU, W, AL, theta, gamma, lambda, sigma, selmode,
               Abar, abar, Lm, Hm, Yb)
        hbar = Hm :/ Lm
    }

    b2 = J(1, nd, abar[1])

    // 含选择那一行的自检（用 selmode=0、自己的校准）
    Y0 = ge_solve2(Lo, q, TAU, W, AL, AbarS, abarS, theta, gamma, lambda, sigma,
                   0, 0, hbar, maxit, tol, damp)

    // 本行自己的基准：同一套参数、同样 τ，只是 H 的构造换成 selmode
    Ybns = ge_solve2(Lo, q, TAU, W, AL, Abar, abar, theta, gamma, lambda, sigma,
                     selmode, 0, hbar, maxit, tol, damp)

    Y1 = ge_solve2(Lo, q, tau0, W, AL, Abar, abar, theta, gamma, lambda, sigma,
                   selmode, 0, hbar, maxit, tol, damp)
    if (amfix == 1) {
        Y2 = ge_solve2(Lo, q, TAU, W, b2, Abar, b2, theta, gamma, lambda, sigma,
                       selmode, 1, hbar, maxit, tol, damp)
        Y3 = ge_solve2(Lo, q, tau0, W, b2, Abar, b2, theta, gamma, lambda, sigma,
                       selmode, 1, hbar, maxit, tol, damp)
    }
    else {
        Y2 = ge_solve2(Lo, q, TAU, W, AL, Abar, b2, theta, gamma, lambda, sigma,
                       selmode, 0, hbar, maxit, tol, damp)
        Y3 = ge_solve2(Lo, q, tau0, W, AL, Abar, b2, theta, gamma, lambda, sigma,
                       selmode, 0, hbar, maxit, tol, damp)
    }
    printf("      sel=%f amfix=%f shared=%f | 自检 %10.7f | 列1 %8.4f  列2 %8.4f  列3 %8.4f\n",
           selmode, amfix, shared, Y0/Yb, Y1/Ybns, Y2/Ybns, Y3/Ybns)
    st_matrix("C1", Y1/Ybns); st_matrix("C2", Y2/Ybns); st_matrix("C3", Y3/Ybns)
    st_matrix("SELF", Y0/Yb)
}
end

*==============================================================================
* 重建面板并算出 θ = 12.4399 那一套输入
*==============================================================================
display _n "===== 1. 面板与输入 ====="

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

* 式(7) IV → w_d, q_o
quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
quietly predict double phat, xb
quietly ivregress 2sls ln_wage (ln_p = phat) i.o i.d, cluster(o)
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

* τ 网格（双向固定效应插值）
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

*==============================================================================
* 2. 八组组合
*==============================================================================
display _n(2) "{hline 78}"
display "  2. selmode × shared 全组合（amfix 固定为 0，因为钉住 α 已被证伪）"
display "{hline 78}"
display "  selmode: 0=含选择 H=Γ̄ΣLqπ^{1−1/θ}   1=NS1 H=Γ̄ΣLqπ   2=NS2 H=Γ̄L_d·q̄"
display "  shared : 0=no-selection 自己重新校准 Ā_d"
display "           1=沿用【含选择】校准的 Ā_d（Ā_d 是地点的内在生产率，不该随假设变）"
display ""

matrix RESULTS2 = J(6, 7, .)
local r = 0
foreach sm of numlist 0 1 2 {
    foreach sh of numlist 0 1 {
        local r = `r' + 1
        mata: one_combo(st_matrix("`LO'"), st_matrix("`QQ'"), rowshape(st_matrix("TAUF"), `NO'), st_matrix("`W'"), st_matrix("`AL'"), `TH', `sm', 0, `sh')
        matrix RESULTS2[`r', 1] = `sm'
        matrix RESULTS2[`r', 2] = `sh'
        matrix RESULTS2[`r', 3] = SELF[1,1]
        matrix RESULTS2[`r', 4] = C1[1,1]
        matrix RESULTS2[`r', 5] = C2[1,1]
        matrix RESULTS2[`r', 6] = C3[1,1]
    }
}

*==============================================================================
* 3. 判断
*==============================================================================
display _n(2) "{hline 78}"
display "  3. 第(2)列：Baseline vs No selection 之差"
display "{hline 78}"
display "  JPE：Baseline 1.127 ，No selection 1.127（差 <0.001）；WP 是 1.126 / 1.125"
display ""
display "  selmode  shared   列(2)含选择   列(2)无选择     差       列(1)含选  列(1)无选"
display "  " "{hline 78}"
local base2 = .
forvalues r = 1/6 {
    if RESULTS2[`r',1] == 0 & RESULTS2[`r',2] == 0 local base2 = RESULTS2[`r',5]
    local base1 = RESULTS2[1,4]
}
forvalues r = 1/6 {
    local d2 = RESULTS2[`r',5] - `base2'
    display "     " %2.0f RESULTS2[`r',1] "      " %2.0f RESULTS2[`r',2] "     " %8.4f `base2' "     " %8.4f RESULTS2[`r',5] "    " %8.4f `d2' "   " %8.4f RESULTS2[1,4] "  " %8.4f RESULTS2[`r',4]
}
display ""
display "  selmode shared   自检        列(1)    列(2)    列(3)    | 与 JPE 比（列2 应为 1.127）"
display "  " "{hline 86}"
forvalues r = 1/6 {
    local dev = RESULTS2[`r',5] - 1.127
    display "     " %2.0f RESULTS2[`r',1] "     " %2.0f RESULTS2[`r',2] "    " %10.7f RESULTS2[`r',3] "  " %7.4f RESULTS2[`r',4] "  " %7.4f RESULTS2[`r',5] "  " %7.4f RESULTS2[`r',6] "  |  " %8.4f `dev'
}

display _n(2) "{hline 78}"
display "  运行结束：$S_DATE $S_TIME"
display "{hline 78}"
log close