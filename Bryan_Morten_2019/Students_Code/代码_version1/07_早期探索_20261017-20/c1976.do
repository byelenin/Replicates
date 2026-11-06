*==============================================================
* 1976 能不能和 1995 一起用来算 pi_do / tau_do ？
* 关键：省份编码是否兼容
*==============================================================
clear all
set more off
capture log close
log using "c1976_out.log", replace text

*--------------------------------------------------------------
* A. 1976
*--------------------------------------------------------------
display "############ A. 1976 (ipumsi_00003) ############"
use geo1_id bplid perwt relate sex age using "D:\研一上\微观计量\ipumsi_00003.dta", clear
count
display "1976 总人数 = " r(N)

gen int o = bplid
gen int d = geo1_id - 360000

display ""
display "----- 1976: geo1_id 的取值 -----"
tab geo1_id

display ""
display "----- 1976: bplid 的取值 -----"
tab bplid

display ""
display "----- 1976: 省数（现居）-----"
quietly levelsof d, local(dd)
display "  现居省数 = " wordcount("`dd'")
quietly levelsof o, local(oo)
display "  出生省数 = " wordcount("`oo'")

display ""
display "----- 1976: geo1_id - 360000 == bplid 的相容性 -----"
count if d == o & d != 0
tab d if d <= 53, missing

*--------------------------------------------------------------
* B. 1976 男性户主子样本
*--------------------------------------------------------------
display ""
display "############ B. 1976 男性户主 ############"
preserve
keep if relate == 1 & sex == 1
count
display "1976 男性户主 = " r(N)

display "----- 非迁移率（男性户主，加权）-----"
gen byte stay = (o == d)
summarize stay [aw=perwt]
display "  非迁移率 = " r(mean)

display "----- 非迁移率（男性户主，未加权）-----"
summarize stay
display "  非迁移率 = " r(mean)

display "----- 交叉格子数（o 与 d 的组合）-----"
egen cell = group(o d)
quietly summarize cell
display "  非空 (o,d) 格子数 = " r(max)
restore

*--------------------------------------------------------------
* C. 1995 对照
*--------------------------------------------------------------
display ""
display "############ C. 1995 (ipumsi_00002) 对照 ############"
use year geo1_id bplid perwt relate sex age using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count
display "1995 总人数 = " r(N)

gen int o = bplid
gen int d = geo1_id - 360000

display ""
display "----- 1995: 现居省 d 的取值 -----"
tab d

display ""
display "----- 1995: 出生省 o 的取值 -----"
tab o

quietly levelsof d, local(dd)
display "  1995 现居省数 = " wordcount("`dd'")
quietly levelsof o, local(oo)
display "  1995 出生省数 = " wordcount("`oo'")

display ""
display "----- 1995 男性户主 - 非迁移率 -----"
preserve
keep if relate == 1 & sex == 1
count
gen byte stay = (o == d)
summarize stay [aw=perwt]
display "  1995 男性户主数 = " r(N)
display "  1995 非迁移率（加权）= " r(mean)
restore

log close