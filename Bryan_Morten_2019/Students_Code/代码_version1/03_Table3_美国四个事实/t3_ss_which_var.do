*==============================================================================
* t3_ss_which_var.do —— 这个 SS 是哪个变量的？
*   对 x = ln距离 / y = ln份额 / y = ln工资 三个变量分别做方差分解
*   并验证：x 的组内 SS 正是 β 精度的分母
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_ss_which_var_out.log", replace text

local root "C:\Users\任娜\Documents\deepseek-harness\default-workspace"
local fz   "D:\研一上\微观计量\复现"

* ---- 距离 ----
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
rename lon lon_d
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

* ---- 州对面板：三个变量 ----
insheet using "`root'\usa_od.csv", clear
gen double hasw  = !missing(wage) & wage > 0
gen double m_w   = w
gen double wx_w  = w*wage if hasw
gen double wg_w  = w      if hasw
collapse (sum) m_w wx_w wg_w, by(o d year)
rename m_w m_od
gen double wage_bar = wx_w/wg_w if wg_w > 0 & !missing(wg_w)
bysort o year: egen double pop_o = total(m_od)
gen double pi_od   = m_od/pop_o
gen double ln_p    = ln(pi_od)     if pi_od > 0
gen double ln_wage = ln(wage_bar)  if wage_bar > 0 & !missing(wage_bar)
drop if o == d
sort o d
merge m:1 o d using `usdist', keep(match) nogen
gen double ln_dist = ln(dist_km)
gen double oyear = o*10000 + year
gen double dyear = d*10000 + year

display _n(2) "{hline 96}"
display "  一、三个变量的方差分解（分组 = 出发州×年 / 目的州×年）"
display "{hline 96}"
display "  " "{hline 86}"
display "  变量            分组         总SS        组内SS   组内占比     组间SS      R²"
display "  " "{hline 86}"
foreach v in ln_dist ln_p ln_wage {
    quietly summarize `v'
    local TOT  = r(Var)*(r(N)-1)
    local MEAN = r(mean)
    local nm = cond("`v'"=="ln_dist", "ln 距离 (x)", cond("`v'"=="ln_p", "ln 份额 (y)", "ln 工资 (y)"))
    foreach g in oyear dyear {
        capture drop _mg _dev _bt
        quietly bysort `g': egen double _mg = mean(`v')
        quietly gen double _dev = (`v' - _mg)^2
        quietly gen double _bt  = (_mg - `MEAN')^2
        quietly summarize _dev
        local WIN = r(sum)
        quietly summarize _bt
        local BET = r(sum)
        local lab = cond("`g'"=="oyear", "出发州×年", "目的州×年")
        display "  " %-16s "`nm'" %-12s "`lab'" %11.2f `TOT' " " %11.2f `WIN' "  " %6.2f 100*`WIN'/`TOT' " %  " %10.2f `BET' "  " %6.2f 100*`BET'/`TOT' " %"
    }
}
capture drop _mg _dev _bt
display "  " "{hline 86}"

*==============================================================================
display _n(2) "{hline 96}"
display "  二、β 的精度由谁决定？—— x 的【组内】平方和就是分母"
display "{hline 96}"
display "  理论：Var(β̂) ≈ σ² / Σ(x − x̄_组)²   ⇒ Σ x̃² 越大，β̂ 估得越准"

gen double xd = ln_dist
gen double yd = ln_p
forvalues k = 1/250 {
    foreach v in xd yd {
        quietly bysort oyear: egen double _q = mean(`v')
        quietly replace `v' = `v' - _q
        quietly drop _q
        quietly bysort dyear: egen double _q = mean(`v')
        quietly replace `v' = `v' - _q
        quietly drop _q
    }
}
quietly summarize xd if !missing(yd)
local SXX = r(N)*r(Var)
local MY  = r(N)
display _n "  样本：`MY' 个州对（o≠d 且有观测工资）"
display "  Σ x̃²  = " %14.4f `SXX' "   ← 双向去均值后 ln距离 的平方和"

quietly reghdfe ln_p ln_dist, absorb(oyear dyear) vce(ols)
local SE_OLS = _se[ln_dist]
quietly reghdfe ln_p ln_dist, absorb(oyear dyear) vce(cluster oyear dyear)
local SE_CL  = _se[ln_dist]
local B_CL   = _b[ln_dist]
display _n "  β̂ = " %10.6f `B_CL'
display "  无聚类 SE   = " %10.6f `SE_OLS' "   ⇒ SE×√(Σx̃²) = " %10.4f `SE_OLS'*sqrt(`SXX') "  （= 残差标准差 σ̂）"
display "  双向聚类 SE = " %10.6f `SE_CL'  "   ⇒ 聚类把 SE 放大了 " %6.2f `SE_CL'/`SE_OLS' " 倍"
display ""
display "  ⇒ β̂ 的标准误 ∝ 1/√(Σ x̃²)：x 的组内平方和越大，β̂ 越准"
display "  ⇒ 而 Σ x̃² 正是「固定效应之后剩下的 x 的变异」（上表第 3 列）"

display _n(2) "{hline 96}"
display "  结束：$S_DATE $S_TIME"
log close