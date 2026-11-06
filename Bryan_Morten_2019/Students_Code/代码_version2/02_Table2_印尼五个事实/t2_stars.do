*==============================================================================
* t2_stars.do — Table 2 三个口径的系数 / 标准误 / 星号（供 PPT 加星）
*   面板：D:\研一上\微观计量\复现\idn_od_panel_regency.dta（已存盘）
*   三个口径完全按 Table2_replication.do 的定义：
*     主结果  全部人，不加权，cluster(o d)
*     加权    男性户主 15-65 岁，[aw=单元人数]，cluster(o)
*     剔极端  全部人、不加权、wage_od <= 1,000,000，cluster(o d)
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t2_stars_out.log", replace text

local root "D:\研一上\微观计量"

capture program drop _both
program define _both
    args dep rhs wt useif vn lab cl
    local wo ""
    if "`wt'" != "NONE" local wo "[aw=`wt']"
    local uf ""
    if "`useif'" != "ALL" local uf "`useif'"
    capture quietly reghdfe `dep' `rhs' `wo' `uf', absorb(o d) vce(cluster `cl')
    local b = _b[`vn']
    local s = _se[`vn']
    local flag ""
    if missing(`s') | `s' <= 0 {
        capture quietly reghdfe `dep' `rhs' `wo' `uf', absorb(o d) vce(cluster o)
        local s = _se[`vn']
        local flag "   [VCV非正定 → 改 cluster(o)]"
    }
    local t = `b'/`s'
    local st ""
    if abs(`t') > 2.576      local st "***"
    else if abs(`t') > 1.96  local st "**"
    else if abs(`t') > 1.645 local st "*"
    display "   `lab'   b = " %10.4f `b' "   SE = " %9.4f `s' "   t = " %8.2f `t' "  `st'`flag'"
end

display _n(2) "{hline 92}"
display "  Table 2（印尼 1995）三个口径的系数与标准误"
display "{hline 92}"

use "`root'\复现\idn_od_panel_regency.dta", clear
keep if !missing(ln_dist)

display _n "  ===== 口径 A：主结果（全部人，不加权，cluster(o d)）====="
_both ln_p    "ln_dist"      "NONE" "ALL"                  ln_dist "    (1) ln_dist → ln p" "o d"
_both ln_wage "ln_dist"      "NONE" "if !missing(ln_wage)" ln_dist "    (2) ln_dist → ln w" "o d"
_both ln_wage "ln_p"         "NONE" "if !missing(ln_wage)" ln_p    "    (3) ln_p    → ln w" "o d"
_both ln_wage "ln_dist ln_p" "NONE" "if !missing(ln_wage)" ln_p    "    (4a) ln_p   → ln w" "o d"
_both ln_wage "ln_dist ln_p" "NONE" "if !missing(ln_wage)" ln_dist "    (4b) ln_dist→ ln w" "o d"

display _n "  ===== 口径 B：加权（男性户主 15-65，[aw=人数]，cluster(o)）====="
_both ln_p_mh    "ln_dist"      "n_mh"      "ALL"                  ln_dist "    (1) ln_dist → ln p" "o"
_both ln_wage_mh "ln_dist"      "n_wage_mh" "if !missing(ln_wage_mh)" ln_dist "    (2) ln_dist → ln w" "o"
_both ln_wage_mh "ln_p_mh"      "n_wage_mh" "if !missing(ln_wage_mh)" ln_p    "    (3) ln_p    → ln w" "o"
_both ln_wage_mh "ln_dist ln_p_mh" "n_wage_mh" "if !missing(ln_wage_mh)" ln_p    "    (4a) ln_p   → ln w" "o"
_both ln_wage_mh "ln_dist ln_p_mh" "n_wage_mh" "if !missing(ln_wage_mh)" ln_dist "    (4b) ln_dist→ ln w" "o"

display _n "  ===== 口径 C：剔极端值（wage_od <= 100 万，cluster(o d)）====="
capture drop okw
gen byte okw = missing(wage_od) | wage_od <= 1000000
_both ln_p    "ln_dist"      "NONE" "if okw"                  ln_dist "    (1) ln_dist → ln p" "o d"
_both ln_wage "ln_dist"      "NONE" "if okw & !missing(ln_wage)" ln_dist "    (2) ln_dist → ln w" "o d"
_both ln_wage "ln_p"         "NONE" "if okw & !missing(ln_wage)" ln_p    "    (3) ln_p    → ln w" "o d"
_both ln_wage "ln_dist ln_p" "NONE" "if okw & !missing(ln_wage)" ln_p    "    (4a) ln_p   → ln w" "o d"
_both ln_wage "ln_dist ln_p" "NONE" "if okw & !missing(ln_wage)" ln_dist "    (4b) ln_dist→ ln w" "o d"

display _n(2) "{hline 92}"
display "  结束：$S_DATE $S_TIME"
display "{hline 92}"
log close