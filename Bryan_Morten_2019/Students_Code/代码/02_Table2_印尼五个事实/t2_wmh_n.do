*==============================================================================
* t2_wmh_n.do — 补取 Table 2「加权口径（男性户主 15-65）」各列的样本量
*   面板已由 Table2_replication.do 存为 idn_od_panel_regency.dta，
*   此处只重跑那四条加权回归，读出 e(N)。
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t2_wmh_n_out.log", replace text

local root "D:\研一上\微观计量"

display _n(2) "{hline 78}"
display "  Table 2 加权口径（男性户主 15-65，[aw=单元人数]）的样本量"
display "{hline 78}"

use "`root'\复现\idn_od_panel_regency.dta", clear
display _n "  面板总观测（OD 县级对）= " %12.0fc _N

keep if !missing(ln_dist)
display "  剔除 ln_dist 缺失后      = " %12.0fc _N

display _n(2) "{hline 78}"
display "  加权回归各自的 e(N)"
display "{hline 78}"
display ""

display "  ----- (1) Fact 1：ln_p_mh 对 ln_dist，[aw = n_mh] -----"
reghdfe ln_p_mh ln_dist [aw = n_mh], absorb(o d) cluster(o)
local N1 = e(N)

display _n "  ----- (2) Fact 2：ln_wage_mh 对 ln_dist，[aw = n_wage_mh] -----"
reghdfe ln_wage_mh ln_dist [aw = n_wage_mh], absorb(o d) cluster(o)
local N2 = e(N)

display _n "  ----- (3) Fact 3：ln_wage_mh 对 ln_p_mh，[aw = n_wage_mh] -----"
reghdfe ln_wage_mh ln_p_mh [aw = n_wage_mh], absorb(o d) cluster(o)
local N3 = e(N)

display _n "  ----- (4) Fact 4：ln_wage_mh 对 ln_p_mh 与 ln_dist，[aw = n_wage_mh] -----"
reghdfe ln_wage_mh ln_p_mh ln_dist [aw = n_wage_mh], absorb(o d) cluster(o)
local N4 = e(N)

display _n(2) "{hline 78}"
display "  ⭐ 结果（供 PPT 第 7 页 N 行使用）"
display "{hline 78}"
display "     Fact 1（列 1）加权 N        = " %10.0fc `N1'
display "     Fact 2/3/4（列 2-4）加权 N  = " %10.0fc `N2'
display ""
display "     PPT 写法（对照论文 25,540 / 25,244）："
display "       " %9.0fc `N1' " / " %9.0fc `N2'
display "{hline 78}"
log close