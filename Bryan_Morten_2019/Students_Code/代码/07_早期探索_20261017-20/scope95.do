*==============================================================
* 1995 年到底能做什么？—— 把省级 Fact 1 放宽到全部起点
*==============================================================
clear all
set more off
capture log close
log using "scope95_out.log", replace text

* ---- 距离 ----
import delimited "D:\研一上\微观计量\复现\idn_prov_dist25.csv", clear
keep o d dist_km
tempfile dist
save `dist'

* ---- OD 面板（不限制起点）----
use "D:\研一上\微观计量\复现\idn_od_panel_malehead.dta", clear

display ""
display "==== 面板结构 ===="
display "总行数 = " _N
qui levelsof o, local(lo)
qui levelsof d, local(ld)
local no : word count `lo'
local nd : word count `ld'
display "起点省个数 = `no'   ->  `lo'"
display "终点省个数 = `nd'   ->  `ld'"
display "起点省的出生人口（加权）:"
table o [aw = n], statistic(sum n) nototals

* ---- 合并 ----
merge 1:1 o d using `dist'
tab _merge
display "起点 o=94（巴布亚）在距离文件里没有 —— 被这一步剔掉"
keep if _merge == 3
drop _merge
display "配对成功 = " _N

* ---- 去对角线 + 回归 ----
drop if o == d
gen double ln_dist = ln(dist_km)
display "可用观测 = " _N

display ""
display "==== Fact 1（全部起点，未加权）===="
regress ln_p ln_dist i.o i.d

display ""
display "==== Fact 1（全部起点，按人数加权）===="
regress ln_p ln_dist i.o i.d [aw = n]

log close