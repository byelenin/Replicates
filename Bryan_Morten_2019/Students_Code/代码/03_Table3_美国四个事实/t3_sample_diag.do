*==============================================================================
* t3_sample_diag.do — 判定论文 Table 3 的「Number of individuals」到底是什么
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_sample_diag_out.log", replace text

local ussrc "C:\Users\任娜\Documents\deepseek-harness\default-workspace\usa_od.csv"

display _n(2) "{hline 84}"
display "  usa_od.csv 结构诊断（论文 Table 3 报 个体数 2,294,054 / 州对 5,084）"
display "{hline 84}"

import delimited "`ussrc'", clear varnames(1)
display _n "  ① 原始行数（= 个体数候选）：" %12.0fc _N

capture destring o, replace
capture destring d, replace
capture destring year, replace
capture destring w, replace force
capture destring wage, replace force

display _n "  ② 按年份"
tab year, missing

display _n "  ③ 是否跨州（o != d）"
gen byte mover = (o != d) if !missing(o) & !missing(d)
tab mover, missing

display _n "  ④ 按年份 × 是否跨州"
tab year mover, missing

display _n "  ⑤ 权重 w 的描述"
summarize w, detail
quietly summarize w
display "     w 之和 = " %16.0fc r(sum)

display _n "  ⑥ 跨州个体的 w 之和（= 论文口径候选）"
quietly summarize w if mover == 1
display "     跨州 w 之和 = " %16.0fc r(sum)
quietly summarize w if mover == 0
display "     留守 w 之和 = " %16.0fc r(sum)

display _n "  ⑦ 跨州「行数」（未加权个体数）"
quietly count if mover == 1
display "     跨州行数 = " %12.0fc r(N)
quietly count if mover == 0
display "     留守行数 = " %12.0fc r(N)

display _n "  ⑧ 有工资的跨州个体"
quietly count if mover == 1 & !missing(wage) & wage > 0
display "     跨州且有工资行数 = " %12.0fc r(N)
quietly summarize w if mover == 1 & !missing(wage) & wage > 0
display "     跨州且有工资 w 之和 = " %16.0fc r(sum)

display _n "  ⑨ 州对数量"
preserve
    keep if mover == 1
    contract o d year
    quietly count
    display "     跨州 (o,d,year) 对数（含对角线无关）= " %10.0fc r(N)
    quietly levelsof o, local(OL)
    quietly levelsof d, local(DL)
    local no : word count `OL'
    local nd : word count `DL'
    display "     出发州数 = `no'    目的州数 = `nd'"
    display "     若为平衡面板：`no'×`nd'×2 年 = " %8.0fc `no'*`nd'*2
restore

display _n(2) "{hline 84}"
display "  论文：个体数 2,294,054    州对 5,084（列1）/ 5,076（列2-4）"
display "  本 csv 总行数 " %12.0fc _N
display "{hline 84}"
log close