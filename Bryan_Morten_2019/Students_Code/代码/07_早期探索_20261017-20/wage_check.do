* 验证：2010 年到底有没有工资数据
clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"
log using "wage_check_out.log", replace text

use year incwage using "D:\研一上\微观计量\ipumsi_00002.dta", clear

display "===== A. 两年各有多少人 ====="
tab year

display "===== B. incwage 的取值分布（按年）====="
gen byte inc_stat = .
replace inc_stat = 1 if incwage > 0 & incwage < 9999998
replace inc_stat = 2 if incwage == 9999998
replace inc_stat = 3 if incwage == 9999999
replace inc_stat = 4 if incwage == 0
replace inc_stat = 5 if missing(incwage)
label define inc_stat 1 "valid wage > 0" 2 "9999998 UNKNOWN" 3 "9999999 NIU (not asked)" 4 "zero" 5 "missing", replace
label values inc_stat inc_stat
tab year inc_stat, missing

display "===== C. 1995 年工资的描述统计 ====="
summarize incwage if year == 1995
summarize incwage if year == 1995 & incwage > 0 & incwage < 9999998

display "===== D. 2010 年工资的描述统计 ====="
summarize incwage if year == 2010
count if year == 2010 & incwage > 0 & incwage < 9999998
display "^^^ 上面这个数字就是 2010 年的有效工资人数"

display "===== E. 1995 年最大几个取值（看是否顶码）====="
preserve
keep if year == 1995 & incwage > 0 & incwage < 9999998
gsort -incwage
list incwage in 1/5
restore

log close