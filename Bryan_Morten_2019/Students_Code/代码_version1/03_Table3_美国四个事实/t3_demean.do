*==============================================================================
* t3_demean.do —— 固定效应的去均值机制，手动验证
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_demean_out.log", replace text

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

* ---- 面板 ----
insheet using "`root'\usa_od.csv", clear
gen double m_w = w
gen double n_w = 1
collapse (sum) m_w n_w, by(o d year)
rename m_w m_od
rename n_w n_od
bysort o year: egen double pop_o = total(m_od)
gen double pi_od = m_od/pop_o
gen double ln_p  = ln(pi_od) if pi_od > 0
drop if o == d
sort o d
merge m:1 o d using `usdist', keep(match) nogen
gen double ln_dist = ln(dist_km)
gen double oyear = o*10000 + year
gen double dyear = d*10000 + year

*==============================================================================
display _n(2) "{hline 88}"
display "  A. 单个固定效应：手动「去均值」到底做了什么"
display "{hline 88}"

display _n "  ① 完全不放固定效应"
quietly reg ln_p ln_dist
display "     β = " %10.6f _b[ln_dist]

display _n "  ② 放「目的地×年」固定效应（areg）"
quietly areg ln_p ln_dist, absorb(dyear)
local B = _b[ln_dist]
display "     β = " %10.6f `B'

display _n "  ③ 手动去均值：把每个观测减去它所在「目的地×年」组的均值"
bysort dyear: egen double ybar = mean(ln_p)
bysort dyear: egen double xbar = mean(ln_dist)
gen double y_dm = ln_p    - ybar
gen double x_dm = ln_dist - xbar
display "     去均值后，每个组内的均值应该 = 0："
quietly summarize y_dm
display "        y_dm 总体均值 = " %12.2e r(mean)
bysort dyear: egen double _ck_y = mean(y_dm)
quietly summarize _ck_y
display "        y_dm 各组均值的最大绝对值 = " %12.2e max(abs(r(min)), abs(r(max)))
drop _ck_y
quietly reg y_dm x_dm, noconstant
local C = _b[x_dm]
display "     用去均值后的数据跑回归： β = " %10.6f `C'
display "     ⇒ 与 areg 之差 = " %12.2e abs(`B'-`C')

display _n "  ④ 看一组实例（目的地=佛州 d=12，1990）"
list o year ln_p ybar y_dm ln_dist xbar x_dm if d==12 & year==1990 in 1/4, ///
    noobs sep(0) abbrev(11)

*==============================================================================
display _n(2) "{hline 88}"
display "  B. 两个固定效应：靠「反复交替去均值」直到收敛"
display "{hline 88}"
display "  交替做两件事：减去出发州×年均值 → 减去目的州×年均值 → 重复"

gen double y2 = ln_p
gen double x2 = ln_dist
forvalues k = 1/250 {
    quietly bysort oyear: egen double _a = mean(y2)
    quietly replace y2 = y2 - _a
    quietly drop _a
    quietly bysort dyear: egen double _a = mean(y2)
    quietly replace y2 = y2 - _a
    quietly drop _a
    quietly bysort oyear: egen double _z1 = mean(x2)
    quietly replace x2 = x2 - _z1
    quietly drop _z1
    quietly bysort dyear: egen double _z1 = mean(x2)
    quietly replace x2 = x2 - _z1
    quietly drop _z1
}
display _n "  迭代 250 轮后："
bysort oyear: egen double _g1 = mean(y2)
bysort dyear: egen double _g2 = mean(y2)
quietly summarize _g1
display "     出发州×年 组均值的最大绝对值 = " %12.2e max(abs(r(min)), abs(r(max)))
quietly summarize _g2
display "     目的州×年 组均值的最大绝对值 = " %12.2e max(abs(r(min)), abs(r(max)))
drop _g1 _g2
quietly reg y2 x2, noconstant
local D = _b[x2]
display "     用迭代去均值后的数据跑回归： β = " %10.6f `D'
quietly reghdfe ln_p ln_dist, absorb(oyear dyear)
local E = _b[ln_dist]
display "     用 reghdfe absorb(oyear dyear)： β = " %10.6f `E'
display "     ⇒ 两者之差 = " %12.2e abs(`D'-`E')

display _n(2) "{hline 88}"
display "  结束：$S_DATE $S_TIME"
log close