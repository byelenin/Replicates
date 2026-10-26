* ============================================================
* 逐步加筛选条件，看 θ 怎么变（找出 10.55 vs 12.58 的来源）
* ============================================================
clear all
set more off
set seed 20191029

local root "D:\研一上\微观计量"
local fz   "D:\研一上\微观计量\复现"

import delimited using "`fz'\idn_prov_dist25.csv", clear
capture rename province_o o
capture rename province_d d
keep o d dist_km
tempfile iddist
save `iddist'

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
gen byte diag = (o == d)

preserve
    keep if o == d
    keep o pi_do
    rename pi_do pi_oo
    tempfile idg_o
    save `idg_o'
restore
preserve
    keep if o == d
    keep d pi_do
    rename pi_do pi_dd
    tempfile idg_d
    save `idg_d'
restore
preserve
    keep o d pi_do
    rename o _t1
    rename d _t2
    rename _t1 d
    rename _t2 o
    rename pi_do pi_rev
    tempfile irev
    save `irev'
restore

gen double pi_dnoto = (m_in_d - m_od)/(pop_all - pop_o) if (pop_all - pop_o) > 0

keep if o != d
merge m:1 o using `idg_o', keep(master match) nogen
merge m:1 d using `idg_d', keep(master match) nogen
merge 1:1 o d using `irev', keep(master match) nogen
merge m:1 o d using `iddist', keep(master match) nogen

gen double ln_p      = ln(pi_do)
gen double ln_p_rev  = ln(pi_rev)
gen double ln_poo    = ln(pi_oo)
gen double ln_pdd    = ln(pi_dd)
gen double ln_pdnoto = ln(pi_dnoto)
gen double ln_dist   = ln(dist_km)
gen double ln_wage   = ln(wage_od) if !missing(wage_od) & wage_od > 0

tempfile panel
save `panel'

capture program drop thetafull
program define thetafull, rclass
    quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
    quietly predict double _ph, xb
    quietly capture ivregress 2sls ln_wage (ln_p = _ph) i.o i.d, cluster(o)
    if _rc {
        quietly ivregress 2sls ln_wage (ln_p = _ph) i.o i.d
    }
    local b = _b[ln_p]
    return scalar N = e(N)
    if `b' >= 0 {
        return scalar theta = .
        exit
    }
    local theta = -1/`b'
    return scalar theta = `theta'
    quietly summarize wage_od
    local vm = r(Var)/(r(mean)^2)
    local best = .
    local bezt = .
    forvalues tt = 200/4000 {
        local t = `tt'/100
        local g1 = lngamma(1 - 1/`t')
        local g2 = lngamma(1 - 2/`t')
        if `g2' < . {
            local d = abs(exp(`g2' - 2*`g1') - 1 - `vm')
            if `best' == . | `d' < `best' {
                local best = `d'
                local bezt = `t'
            }
        }
    }
    return scalar thetat = `bezt'
    return scalar rho    = 1 - `bezt'/`theta'
    return scalar vm     = `vm'
end

display _n(2) "{hline 80}"
display "逐步加筛选条件，看 θ 和 ρ 怎么变"
display "{hline 80}"
display ""
display "  序号  筛选条件                                     OD 对     θ        θ̃      ρ"
display "  {hline 76}"

* ---- A: 只用 o != d ----
use `panel', clear
keep if !missing(ln_pdnoto) & !missing(ln_p) & !missing(ln_wage)
quietly thetafull
display "   A     o≠d + 有 π_d¬o + 有工资                 " %5.0f r(N) "   " %8.4f r(theta) "  " %7.4f r(thetat) "  " %7.4f r(rho)

* ---- B: A + pi_rev ----
use `panel', clear
keep if !missing(ln_pdnoto) & !missing(ln_p) & !missing(ln_wage)
keep if !missing(pi_rev) & pi_rev > 0
quietly thetafull
display "   B     A + 反向配对存在 (π_od)                  " %5.0f r(N) "   " %8.4f r(theta) "  " %7.4f r(thetat) "  " %7.4f r(rho)

* ---- C: B + pi_oo ----
use `panel', clear
keep if !missing(ln_pdnoto) & !missing(ln_p) & !missing(ln_wage)
keep if !missing(pi_rev) & pi_rev > 0
keep if !missing(pi_oo) & pi_oo > 0
quietly thetafull
display "   C     B + 出发地留乡比例存在 (π_oo)            " %5.0f r(N) "   " %8.4f r(theta) "  " %7.4f r(thetat) "  " %7.4f r(rho)

* ---- D: C + pi_dd ----
use `panel', clear
keep if !missing(ln_pdnoto) & !missing(ln_p) & !missing(ln_wage)
keep if !missing(pi_rev) & pi_rev > 0
keep if !missing(pi_oo) & pi_oo > 0
keep if !missing(pi_dd) & pi_dd > 0
quietly thetafull
display "   D     C + 目的地留乡比例存在 (π_dd)            " %5.0f r(N) "   " %8.4f r(theta) "  " %7.4f r(thetat) "  " %7.4f r(rho)

* ---- E: D + dist ----
use `panel', clear
keep if !missing(ln_pdnoto) & !missing(ln_p) & !missing(ln_wage)
keep if !missing(pi_rev) & pi_rev > 0
keep if !missing(pi_oo) & pi_oo > 0
keep if !missing(pi_dd) & pi_dd > 0
keep if !missing(dist_km) & dist_km > 0
quietly thetafull
display "   E     D + 有距离 (当前 Table3 的做法)          " %5.0f r(N) "   " %8.4f r(theta) "  " %7.4f r(thetat) "  " %7.4f r(rho)

display ""
display "  论文：θ = 12.5，ρ = 0.74"
display ""
display "{hline 80}"

display _n "  补充：A 和 E 两种样本下，工资均值和方差是否不同？"
foreach tag in A E {
    use `panel', clear
    keep if !missing(ln_pdnoto) & !missing(ln_p) & !missing(ln_wage)
    if "`tag'" == "E" {
        keep if !missing(pi_rev) & pi_rev > 0
        keep if !missing(pi_oo) & pi_oo > 0
        keep if !missing(pi_dd) & pi_dd > 0
        keep if !missing(dist_km) & dist_km > 0
    }
    quietly summarize wage_od
    display "    样本 `tag'：N = " %4.0f r(N) "   工资均值 = " %12.2f r(mean) "   var/mean² = " %8.5f r(Var)/(r(mean)^2)
}

display _n(2) "{hline 80}"