*==============================================================
* 验证：省级 Fact 1（引力回归）能不能跑通
*==============================================================
clear all
set more off
capture log close
log using "verify_fact1_out.log", replace text

* ---- 1. 距离文件 ----
import delimited "D:\研一上\微观计量\复现\idn_prov_dist25.csv", clear
keep o d dist_km
tempfile dist
save `dist'

* ---- 2. OD 面板 ----
use "D:\研一上\微观计量\复现\idn_od_panel_malehead.dta", clear
display "面板总行数 = " _N
display "o 里有没有 94（巴布亚）？"
count if o == 94
display "  o==94 的行数 = " r(N)

keep if obs_prov == 1
display "限定 obs_prov==1 后行数 = " _N

* ---- 3. 合并 ----
merge 1:1 o d using `dist'
display ""
display "==== 合并结果 ===="
tab _merge
keep if _merge == 3
display "配对成功行数 = " _N

* ---- 4. 生成距离对数 + 回归 ----
gen double ln_dist = ln(dist_km)
display ""
display "==== 描述统计 ===="
summarize ln_p ln_dist

display ""
display "==== Fact 1 回归（省级）===="
regress ln_p ln_dist i.o i.d
estimates store m1

display ""
display "==== 加权版（按 n）===="
regress ln_p ln_dist i.o i.d [aw = n]

log close