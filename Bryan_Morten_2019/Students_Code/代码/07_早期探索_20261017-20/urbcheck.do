*==============================================================
* 查证：urban 到底怎么编码的
*==============================================================
clear all
set more off
capture log close
log using "urbcheck_out.log", replace text

use year urban perwt using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995

display _n "==== urban 变量的值标签定义 ===="
label list URBAN

display _n "==== tab urban（带标签，看编码含义）===="
tab urban

display _n "==== tab urban 加权（看实际占比）===="
tab urban [aw = perwt]

display _n "==== 验证 (urban==1)*perwt 到底加出来什么 ===="
gen double rur = (urban==1)*perwt
gen double urb = (urban==2)*perwt
total rur urb

display _n "==== 对照：不乘 perwt 时 (urban==1) 的样子 ===="
list urban rur urb in 1/8, noobs

log close