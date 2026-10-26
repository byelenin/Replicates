*==============================================================
* 看看 ipumsi_00003.dta 里到底是什么
*==============================================================
clear all
set more off

capture log close
log using "desc00003_out.log", replace text

display "==================== 变量清单 ===================="
describe using "D:\研一上\微观计量\ipumsi_00003.dta"

display ""
display "==================== 观测数与年份 ===================="
use using "D:\研一上\微观计量\ipumsi_00003.dta", clear
count
display "总观测数 = " r(N)

capture confirm variable year
if _rc == 0 {
    display ""
    display "----- tab year -----"
    tab year
}

capture confirm variable sample
if _rc == 0 {
    display ""
    display "----- tab sample -----"
    tab sample
}

capture confirm variable country
if _rc == 0 {
    display ""
    display "----- tab country -----"
    tab country
}

log close