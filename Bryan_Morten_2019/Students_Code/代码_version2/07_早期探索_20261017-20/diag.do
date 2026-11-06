*==============================================================
* 确认：当时 merge 失败到底是因为什么？
*==============================================================
clear all
set more off
capture log close
log using "diag_out.log", replace text

use year geo2_id1995 id1995a_bplreg using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995

* ---- 当时「失败版」的两个 key ----
gen double bpl_now = floor(id1995a_bplreg/100)*1000 + mod(id1995a_bplreg,100)
gen long   bpl_key = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)

display _n "==== 失败版：两个 key 的前 10 行 ===="
list id1995a_bplreg bpl_now geo2_id1995 bpl_key in 1/10, noobs

display _n "==== 失败版：key 相等的观测数 ===="
count if bpl_now == bpl_key

* ---- 「成功版」的两个 key ----
gen long bcode_master = id1995a_bplreg
gen long bcode_using  = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)

display _n "==== 成功版：两个 key 的前 10 行 ===="
list id1995a_bplreg bcode_master geo2_id1995 bcode_using in 1/10, noobs

display _n "==== 成功版：key 相等的观测数 ===="
count if bcode_master == bcode_using

display _n "==== 取值范围对照 ===="
summarize bpl_now bpl_key bcode_master bcode_using

log close