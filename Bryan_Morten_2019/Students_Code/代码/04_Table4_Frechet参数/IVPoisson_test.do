* ==============================================================================
*  关键测试：ivpoisson gmm 能不能直接做论文的「PPML + IV + GMM + 固定效应」？
*
*  之前测过：ivpoisson gmm y (x=z) 可以跑，但不支持 absorb()
*  但 ivpoisson 支持因子变量 i.o i.d —— 把固定效应当成普通回归元塞进去，
*  是不是就能同时拿到 PPML + IV + GMM + 固定效应？
*
*  面板口径 = 论文口径（有工资者份额 + 丢 n_raw<5）
* ==============================================================================
clear all
set more off
set linesize 150

local root   "D:\研一上\微观计量"
local fz     "D:\研一上\微观计量\复现"
local ussrc  "C:\Users\任娜\Documents\deepseek-harness\default-workspace\usa_od.csv"

log using "`fz'\ivpoisson_test_out.log", replace text

* ---- 距离 ----
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

* ---- 美国面板 ----
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

* ---- 印尼面板 ----
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
* 正式测试
*==============================================================================
foreach cc in id us {
    if "`cc'" == "id" {
        use `idpanel', clear
        local lab "印尼 1995"
        local pobj "论文 θ = 12.5"
    }
    if "`cc'" == "us" {
        use `uspanel', clear
        local lab "美国 1990"
        local pobj "论文 θ = 27.6"
    }

    display _n(2) "{hline 80}"
    display "  `lab'      （`pobj'）"
    display "{hline 80}"

    quietly count
    display "  OD 对数：`r(N)'"

    * 零阶段
    quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
    display "  零阶段 R² = " %6.4f e(r2)
    quietly predict double phat, xb

    * ---------- 方法甲：控制函数法（两步）----------
    timer clear 1
    timer on 1
    quietly capture reghdfe ln_p phat, absorb(o d) residuals(u)
    if _rc == 0 {
        quietly capture ppmlhdfe wage_od ln_p u, absorb(o d) cluster(o)
        if _rc == 0 {
            local bA = _b[ln_p]
        }
        else {
            local bA = .
        }
    }
    else {
        local bA = .
    }
    timer off 1
    display _n "  【甲】控制函数法：reghdfe + ppmlhdfe 两步"
    timer list 1
    if `bA' != . & `bA' < 0 {
        display "      θ = " %8.4f -1/`bA'
    }
    else {
        display "      失败或 β 为正"
    }

    * ---------- 方法乙：ivpoisson gmm（一步到位，固定效应当回归元）----------
    timer clear 2
    timer on 2
    capture noisily ivpoisson gmm wage_od (ln_p = phat) i.o i.d
    local rcB = _rc
    timer off 2
    display _n "  【乙】ivpoisson gmm：PPML + IV + GMM + 固定效应虚拟变量"
    display "      返回码 = `rcB'"
    timer list 2
    if `rcB' == 0 {
        local bB = _b[ln_p]
        if `bB' < 0 {
            display "      θ = " %8.4f -1/`bB'
        }
        else {
            display "      β 为正，θ 无解"
        }
    }
}

display _n(2) "{hline 80}"
display "  说明"
display "{hline 80}"
display "  甲 = 我们现在用的（两步控制函数）"
display "  乙 = 论文的方法：PPML + IV + GMM + 固定效应，一步到位"
display "  如果乙能跑通且不慢，就不需要自己编写程序了"

log close