*==============================================================================
* t3_weight_mech.do —— 验证「加权 = 把这一行复制 w 遍」
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_weight_mech_out.log", replace text

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

* ---- 州对面板 ----
insheet using "`root'\usa_od.csv", clear
gen double m_w = w
gen double n_w = 1
collapse (sum) m_w n_w, by(o d year)
rename m_w m_od
rename n_w n_od
* ⚠ pop_o 必须含留守者（对角线）：π = o 出生者中住到 d 的比例
bysort o year: egen double pop_o = total(m_od)
gen double pi_od = m_od/pop_o
gen double ln_p  = ln(pi_od) if pi_od > 0
drop if o == d
sort o d
merge m:1 o d using `usdist', keep(match) nogen
gen double ln_dist = ln(dist_km)
gen long oyear = o*10000 + year
gen long dyear = d*10000 + year

display _n(2) "{hline 88}"
display "  验证：加权 = 把这一行复制 w 遍"
display "{hline 88}"
display ""
display "  ── 基准：按 n_od 加权 ──"
quietly reghdfe ln_p ln_dist [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
local A = _b[ln_dist]
display "     [aw=n_od]              β = " %10.6f `A'

display ""
display "  ── 把每一行复制 n_od 遍，然后【不加权】跑 ──"
preserve
expand n_od
quietly count
display "     展开后行数 = " %12.0fc r(N)
quietly reghdfe ln_p ln_dist, absorb(oyear dyear) vce(cluster oyear dyear)
local B = _b[ln_dist]
display "     展开后不加权           β = " %10.6f `B'
restore
display "     ⇒ 两者之差 = " %12.2e abs(`A'-`B')

display ""
display "  ── 再验证：权重同乘一个常数，系数不变 ──"
gen double n_od100 = n_od/100
quietly reghdfe ln_p ln_dist [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
display "     [aw=n_od]              β = " %10.6f _b[ln_dist]
quietly reghdfe ln_p ln_dist [aw=n_od100], absorb(oyear dyear) vce(cluster oyear dyear)
display "     [aw=n_od/100]          β = " %10.6f _b[ln_dist]
gen double ones = 1
quietly reghdfe ln_p ln_dist [aw=ones], absorb(oyear dyear) vce(cluster oyear dyear)
display "     [aw=1]（等于不加权）   β = " %10.6f _b[ln_dist]

display ""
display "  ── 对比三种口径（列(1)：ln_p ← ln_dist）──"
foreach wt in n_od m_od {
    quietly reghdfe ln_p ln_dist [aw=`wt'], absorb(oyear dyear) vce(cluster oyear dyear)
    display "     [aw=`wt']   β = " %10.6f _b[ln_dist]
}
quietly reghdfe ln_p ln_dist, absorb(oyear dyear) vce(cluster oyear dyear)
display "     不加权      β = " %10.6f _b[ln_dist]

display ""
display "  ── 大州对 vs 小州对：各自的「斜率」──"
* 用离差形式看每一行的贡献方向
quietly reghdfe ln_p ln_dist [aw=n_od], absorb(oyear dyear) residuals
predict double _e if e(sample), resid
* 最大的 5 个州对
gsort -n_od
display "  人数最多的 5 行（加权时它们说得最响）："
list o d year n_od m_od ln_dist ln_p _e in 1/5, noobs sep(0) abbrev(10)
gsort n_od
display "  人数最少的 5 行（加权时几乎被忽略）："
list o d year n_od m_od ln_dist ln_p _e in 1/5, noobs sep(0) abbrev(10)

display _n(2) "{hline 88}"
display "  结束：$S_DATE $S_TIME"
log close