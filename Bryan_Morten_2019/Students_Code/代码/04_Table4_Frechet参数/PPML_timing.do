* ==============================================================================
*  计时实验：PPML 路线要多久？GMM 路线真的要几天吗？
*  （面板口径 = 论文口径：有工资者份额 + 丢 n_raw<5）
* ==============================================================================
clear all
set more off
set linesize 150

local root   "D:\研一上\微观计量"
local fz     "D:\研一上\微观计量\复现"
local ussrc  "C:\Users\任娜\Documents\deepseek-harness\default-workspace\usa_od.csv"

log using "`fz'\ppml_timing_out.log", replace text

*==============================================================================
* 1-3. 建面板（同前）
*==============================================================================
import delimited "`fz'\idn_prov_dist25.csv", clear varnames(1)
destring o, replace
destring d, replace
destring dist_km, replace force
keep o d dist_km
tempfile iddist
save `iddist'

import delimited "`fz'\us_state_fips2usps.csv", clear varnames(1)
destring state_fips, replace
rename state_fips o
tempfile f2u
save `f2u'

import delimited "`fz'\us_state_centroids.csv", clear varnames(1)
keep usps lat lon
merge 1:1 usps using `f2u', keep(match) nogen
keep o lat lon
rename lat lat_o
rename lon lon_o
rename o d
rename lat_o lat_d
rename lon_o lon_d
tempfile c_d
save `c_d'

import delimited "`fz'\us_state_centroids.csv", clear varnames(1)
keep usps lat lon
merge 1:1 usps using `f2u', keep(match) nogen
keep o lat lon
rename lat lat_o
rename lon lon_o
tempfile c_o
save `c_o'

use `c_o', clear
cross using `c_d'
gen double _pio = _pi/180
gen double _dla = (lat_d - lat_o)*_pio
gen double _dlo = (lon_d - lon_o)*_pio
gen double _a = sin(_dla/2)^2 + cos(lat_o*_pio)*cos(lat_d*_pio)*sin(_dlo/2)^2
gen double dist_km = 2*6371*asin(min(1, sqrt(_a)))
keep o d dist_km
tempfile usdist
save `usdist'

* --- 美国 ---
import delimited "`ussrc'", clear varnames(1) colrange(1:5)
capture destring o, replace
capture destring d, replace
capture destring year, replace
capture destring wage, replace force
capture destring w, replace force
keep o d year wage w
drop if missing(o) | missing(d) | missing(year)
drop if missing(w) | w <= 0
keep if year == 1990
gen byte hasw = !missing(wage) & wage > 0
gen byte one = 1
gen double wgt_wg = w if hasw
gen double wx_w = w*wage if hasw
gen double wage_ok = wage if hasw
collapse (sum) m_wg=wgt_wg (sum) wx_w=wx_w (count) n_raw=one (count) n_wage=wage_ok, by(o d)
gen double wage_od = wx_w/m_wg if m_wg > 0
rename m_wg m_od
keep if m_od > 0 & !missing(wage_od) & wage_od > 0
bysort o: egen double pop_o = total(m_od)
bysort d: egen double m_in_d = total(m_od)
egen double pop_all = total(m_od)
gen double pi_do = m_od/pop_o
preserve
    keep if o == d
    keep o pi_do
    rename pi_do pi_oo
    tempfile go
    save `go'
    rename o d
    rename pi_oo pi_dd
    tempfile gd
    save `gd'
restore
preserve
    keep o d pi_do
    rename o _t1
    rename d _t2
    rename _t1 d
    rename _t2 o
    rename pi_do pi_rev
    tempfile rv
    save `rv'
restore
gen double pi_dnoto = (m_in_d - m_od)/(pop_all - pop_o) if (pop_all - pop_o) > 0
keep if o != d
merge m:1 o using `go', keep(master match) nogen
merge m:1 d using `gd', keep(master match) nogen
merge 1:1 o d using `rv', keep(master match) nogen
merge 1:1 o d using `usdist', keep(master match) nogen
keep if !missing(pi_do) & pi_do > 0
keep if !missing(pi_rev) & pi_rev > 0
keep if !missing(pi_oo) & pi_oo > 0
keep if !missing(pi_dd) & pi_dd > 0
keep if !missing(pi_dnoto) & pi_dnoto > 0
keep if !missing(dist_km) & dist_km > 0
keep if n_raw >= 5
gen double ln_p      = ln(pi_do)
gen double ln_p_rev  = ln(pi_rev)
gen double ln_poo    = ln(pi_oo)
gen double ln_pdd    = ln(pi_dd)
gen double ln_pdnoto = ln(pi_dnoto)
gen double ln_wage   = ln(wage_od)
tempfile uspanel
save `uspanel'
quietly count
display "  美国面板：`r(N)' 个 OD 对"

* --- 印尼 ---
use year bplid geo1_id incwage perwt relate sex age using "`root'\ipumsi_00002.dta", clear
keep if year == 1995
keep if sex == 1 & relate == 1 & inrange(age, 15, 65)
gen int o = bplid
gen int d = geo1_id - 360000
keep if inrange(o, 11, 18) | inrange(o, 31, 35) | inrange(o, 51, 54)
keep if inrange(d, 11, 18) | inrange(d, 31, 35) | inrange(d, 51, 54)
gen byte hasw = !missing(incwage) & incwage > 0 & incwage < 9999999
gen byte one = 1
gen double wgt_wg = perwt if hasw
gen double wx_w = perwt*incwage if hasw
gen double wage_ok = incwage if hasw
collapse (sum) m_wg=wgt_wg (sum) wx_w=wx_w (count) n_raw=one (count) n_wage=wage_ok, by(o d)
gen double wage_od = wx_w/m_wg if m_wg > 0
rename m_wg m_od
keep if m_od > 0 & !missing(wage_od) & wage_od > 0
bysort o: egen double pop_o = total(m_od)
bysort d: egen double m_in_d = total(m_od)
egen double pop_all = total(m_od)
gen double pi_do = m_od/pop_o
preserve
    keep if o == d
    keep o pi_do
    rename pi_do pi_oo
    tempfile igo
    save `igo'
    rename o d
    rename pi_oo pi_dd
    tempfile igd
    save `igd'
restore
preserve
    keep o d pi_do
    rename o _t1
    rename d _t2
    rename _t1 d
    rename _t2 o
    rename pi_do pi_rev
    tempfile irv
    save `irv'
restore
gen double pi_dnoto = (m_in_d - m_od)/(pop_all - pop_o) if (pop_all - pop_o) > 0
keep if o != d
merge m:1 o using `igo', keep(master match) nogen
merge m:1 d using `igd', keep(master match) nogen
merge 1:1 o d using `irv', keep(master match) nogen
merge 1:1 o d using `iddist', keep(master match) nogen
keep if !missing(pi_do) & pi_do > 0
keep if !missing(pi_rev) & pi_rev > 0
keep if !missing(pi_oo) & pi_oo > 0
keep if !missing(pi_dd) & pi_dd > 0
keep if !missing(pi_dnoto) & pi_dnoto > 0
keep if !missing(dist_km) & dist_km > 0
keep if n_raw >= 5
gen double ln_p      = ln(pi_do)
gen double ln_p_rev  = ln(pi_rev)
gen double ln_poo    = ln(pi_oo)
gen double ln_pdd    = ln(pi_dd)
gen double ln_pdnoto = ln(pi_dnoto)
gen double ln_wage   = ln(wage_od)
tempfile idpanel
save `idpanel'
quietly count
display "  印尼面板：`r(N)' 个 OD 对"

*==============================================================================
* 4. 计时：单次 ppmlhdfe
*==============================================================================
display _n(2) "===== 4. 单次 ppmlhdfe 的耗时 ====="

use `idpanel', clear
quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
quietly predict double phat, xb
quietly reghdfe ln_p phat, absorb(o d) residuals(u)
timer clear 1
timer on 1
quietly ppmlhdfe wage_od ln_p u, absorb(o d) cluster(o)
timer off 1
timer list 1
display "  印尼单次 PPML（17 省 × 2 = 34 个固定效应）"

use `uspanel', clear
quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
quietly predict double phat, xb
quietly reghdfe ln_p phat, absorb(o d) residuals(u)
timer clear 2
timer on 2
quietly ppmlhdfe wage_od ln_p u, absorb(o d) cluster(o)
timer off 2
timer list 2
display "  美国单次 PPML（51 州 × 2 = 102 个固定效应）"

*==============================================================================
* 5. 定义一次完整估计（θ 和 ρ）
*==============================================================================
capture program drop onepass
program define onepass, rclass
    capture drop phat
    capture drop u
    quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
    quietly predict double phat, xb
    quietly capture reghdfe ln_p phat, absorb(o d) residuals(u)
    if _rc != 0 {
        return scalar theta = .
        return scalar thetat = .
        return scalar rho = .
        exit
    }
    quietly capture ppmlhdfe wage_od ln_p u, absorb(o d)
    if _rc != 0 {
        return scalar theta = .
        return scalar thetat = .
        return scalar rho = .
        exit
    }
    local beta = _b[ln_p]
    if `beta' >= 0 {
        return scalar theta = .
        return scalar thetat = .
        return scalar rho = .
        exit
    }
    local theta = -1/`beta'

    quietly summarize wage_od
    local V = r(Var)/r(mean)^2
    local best = .
    local bestv = .
    forvalues i = 205/3000 {
        local tt = `i'/100
        local rhs = exp(lngamma(1-2/`tt'))/(exp(lngamma(1-1/`tt'))^2) - 1
        local df = abs(`rhs' - `V')
        if `bestv' == . | `df' < `bestv' {
            local bestv = `df'
            local best = `tt'
        }
    }
    local c0 = `best' - 0.05
    local bestv = .
    forvalues i = 0/100 {
        local tt = `c0' + `i'*0.001
        if `tt' > 2 {
            local rhs = exp(lngamma(1-2/`tt'))/(exp(lngamma(1-1/`tt'))^2) - 1
            local df = abs(`rhs' - `V')
            if `bestv' == . | `df' < `bestv' {
                local bestv = `df'
                local best = `tt'
            }
        }
    }
    return scalar theta  = `theta'
    return scalar thetat = `best'
    return scalar rho    = 1 - `best'/`theta'
end

*==============================================================================
* 6. 计时：完整一次估计
*==============================================================================
display _n(2) "===== 6. 完整一次估计（θ + ρ）====="

use `idpanel', clear
timer clear 3
timer on 3
quietly onepass
timer off 3
timer list 3
display "  印尼 θ = " %8.4f r(theta) "   θ̃ = " %7.4f r(thetat) "   ρ = " %7.4f r(rho)

use `uspanel', clear
timer clear 4
timer on 4
quietly onepass
timer off 4
timer list 4
display "  美国 θ = " %8.4f r(theta) "   θ̃ = " %7.4f r(thetat) "   ρ = " %7.4f r(rho)

*==============================================================================
* 7. 实测：跑 B=20 轮 bootstrap，量出每轮真实耗时
*==============================================================================
display _n(2) "===== 7. 实测 bootstrap 速度（B=20）====="

local Btest = 20
set seed 20191029

capture program drop boottime
program define boottime
    args cl Btest
    timer clear 5
    timer on 5
    forvalues b = 1/`Btest' {
        preserve
        quietly bsample, cluster(`cl') idcluster(bsid2)
        quietly capture onepass
        restore
    }
    timer off 5
end

foreach cc in id us {
    if "`cc'" == "id" {
        use `idpanel', clear
        local lab "印尼"
    }
    if "`cc'" == "us" {
        use `uspanel', clear
        local lab "美国"
    }
    quietly boottime o `Btest'
    display "  ── `lab' 跑完 `Btest' 轮 bootstrap，计时器 5 显示："
    timer list 5
    display "  ── `lab' 结束"
}

*==============================================================================
* 8. 汇总
*==============================================================================
display _n(2) "{hline 80}"
display "  计时汇总（看上面的 timer list 输出）"
display "{hline 80}"
display "  把「20 轮 bootstrap」的秒数 × 10 就是 B=200 的估计时间。"
display "  印尼和美国都要跑，所以总时间 = 两者相加。"

log close