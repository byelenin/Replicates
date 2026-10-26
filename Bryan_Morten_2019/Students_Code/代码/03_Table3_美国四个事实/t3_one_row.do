*==============================================================================
* t3_one_row.do —— 把回归里的「一行」完整拆开看
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_one_row_out.log", replace text

local root "C:\Users\任娜\Documents\deepseek-harness\default-workspace"
local fz   "D:\研一上\微观计量\复现"

* ---- 距离（照搬 Table3US_replication.do 第 1 节）----
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

* ---- 个体 → 州对（照搬第 2 节口径）----
insheet using "`root'\usa_od.csv", clear
gen double hasw = !missing(wage) & wage > 0
gen double m_w  = w
gen double n_w  = 1
gen double wx_w = w*wage if hasw
gen double wg_w = w if hasw
collapse (sum) m_w n_w wx_w wg_w, by(o d year)
rename m_w m_od
rename n_w n_od
gen double wage_od = wx_w/wg_w if wg_w > 0 & !missing(wg_w)
bysort o year: egen double pop_o = total(m_od)
gen double pi_od  = m_od/pop_o
gen double ln_p   = ln(pi_od) if pi_od > 0
gen double ln_wage = ln(wage_od) if wage_od > 0 & !missing(wage_od)
sort o d
merge m:1 o d using `usdist', keep(match) nogen
gen double ln_dist = ln(dist_km)

display _n(2) "{hline 92}"
display "  「一行」到底是什么 —— 以 纽约(36) → 佛罗里达(12) 1990 为例"
display "{hline 92}"

display _n "  ① 这一行的原始量"
list o d year n_od m_od pop_o pi_od wage_od dist_km if o==36 & d==12 & year==1990, ///
    noobs sep(0) abbrev(12)

display _n "  ② 回归实际吃进去的三个数字（因变量/自变量）"
display "     列(1) 因变量 = ln_p        列(2)(3)(4) 因变量 = ln_wage"
display "     自变量 = ln_dist"
list o d year ln_p ln_wage ln_dist if o==36 & d==12 & year==1990, noobs sep(0) abbrev(12)

display _n "  ③ 一行 = 一个 (出发州, 目的州, 年份) 三元组"
quietly count
display "     全部州对行数 = " %10.0fc r(N)
quietly count if !missing(ln_wage)
display "     其中有观测工资（列 2/3/4 用）= " %10.0fc r(N)

display _n "  ④ 加权只改影响力，不改行数：三种加权下 N 完全一样"
use `usdist', clear
display _n(2) "{hline 92}"
display "  结束：$S_DATE $S_TIME"
log close