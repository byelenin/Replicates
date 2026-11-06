*==============================================================
* 迁移率缺口排查：不同样本口径下的迁移率（论文 1995 = 33.7%）
*==============================================================
clear all
set more off
capture log close
log using "miggap_out.log", replace text

use year age sex relate urban geo2_id1995 id1995a_bplreg perwt using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995

gen long bcode   = id1995a_bplreg
gen long geo_key = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
gen byte moved   = (geo_key != bcode) if !missing(id1995a_bplreg)

display _n "==== 各种样本口径下的加权迁移率（论文 1995 = 33.7%）===="

quietly summarize moved [aw=perwt]
display "全体                            : " %6.2f r(mean)*100

quietly summarize moved [aw=perwt] if age >= 15
display "age >= 15                       : " %6.2f r(mean)*100

quietly summarize moved [aw=perwt] if age >= 15 & age <= 65
display "age 15-65                       : " %6.2f r(mean)*100

quietly summarize moved [aw=perwt] if sex == 1
display "男性                            : " %6.2f r(mean)*100

quietly summarize moved [aw=perwt] if sex == 1 & age >= 15 & age <= 65
display "男性 15-65                      : " %6.2f r(mean)*100

quietly summarize moved [aw=perwt] if relate == 1
display "户主                            : " %6.2f r(mean)*100

quietly summarize moved [aw=perwt] if relate == 1 & sex == 1 & age >= 15 & age <= 65
display "男性户主 15-65（论文事实表口径）: " %6.2f r(mean)*100

display _n "==== 按年龄组的迁移率（加权）===="
gen agegrp = floor(age/10)*10
tab agegrp moved [aw=perwt], row

display _n "==== 出生地变量缺失情况 ===="
count if missing(id1995a_bplreg)
count if missing(geo2_id1995)

log close