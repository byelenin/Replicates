*==============================================================
* 1976 的工资能不能用？（单位/参照期和 1995 不同）
* 以及 25 省 pi 矩阵的可行格子数
*==============================================================
clear all
set more off
capture log close
log using "c1976w_out.log", replace text

*--------------------------------------------------------------
* A. 1976 工资有效性
*--------------------------------------------------------------
display "############ A. 1976 工资 ############"
use incwage perwt relate sex age geo1_id bplid using "D:\研一上\微观计量\ipumsi_00003.dta", clear

display "----- 全部人：incwage 缺失情况 -----"
tab incwage if incwage >= 9999990, missing

display ""
display "----- 全部人：有效工资 -----"
count if !missing(incwage) & incwage < 9999990
display "  全部有效工资 = " r(N)

display ""
display "----- 全部人：有效工资的分布 -----"
summarize incwage if !missing(incwage) & incwage < 9999990, detail

display ""
display "----- 男性户主 -----"
preserve
keep if relate == 1 & sex == 1
count
display "  1976 男性户主 = " r(N)
count if !missing(incwage) & incwage < 9999990
display "  其中有效工资 = " r(N)
summarize incwage if !missing(incwage) & incwage < 9999990
restore

*--------------------------------------------------------------
* B. 25 省 pi 矩阵（剔 Papua=94，剔 abroad/unknown）
*--------------------------------------------------------------
display ""
display "############ B. 1976 的 25 省 pi 矩阵 ############"
use perwt relate sex geo1_id bplid using "D:\研一上\微观计量\ipumsi_00003.dta", clear
keep if relate == 1 & sex == 1

gen int o = bplid
gen int d = geo1_id - 360000

display "剔之前："
count
display "  N = " r(N)

drop if o == 98 | o == 99
drop if d == 94          // 剔 Papua & Papua Barat（论文脚注 7）
count
display "  剔 abroad/unknown/Papua 后 N = " r(N)

quietly levelsof d, local(dd)
display "  目的地省数 = " wordcount("`dd'")
quietly levelsof o, local(oo)
display "  出发地省数 = " wordcount("`oo'")

display ""
display "----- 25 省：双向都非零的省对（算 tau 需要的）-----"
* 每个 (o,d) 的加权人数
preserve
collapse (sum) n=perwt, by(o d)
* 标记非零
gen byte nz = (n > 0)
* 自连接判断双向
rename o o1
rename d d1
rename nz nz1
tempfile t1
save `t1'

use `t1', clear
rename o1 o2
rename d1 d2
rename nz1 nz2
rename o2 d
rename d2 o
rename nz2 nz_other
merge 1:1 o d using `t1', nogenerate
rename nz1 nz_this
count if nz_this == 1 & nz_other == 1
display "  双向都非零的省对 = " r(N)

display ""
display "----- 只单向非零的省对 -----"
count if nz_this == 1 & nz_other == 0
display "  单向 = " r(N)
restore

log close