*==============================================================================
* t3_pairs.do — 把 P11「跨州 (出发,目的,年) 州对」2,542 / 2,458 / 5,000 算清楚
*
*   P11 原表：
*     跨州 (出发,目的,年) 州对 | 2,542 | 2,458 | 5,000
*
*   定义：从 usa_od.csv 取 o != d 的行，按 (o, d, year) 去重，
*         数出有多少个「不同的三元组」—— 这就是那一列的观测数。
*   上限：51 个出发州 × 50 个目的州（去掉同州）× 每年 = 2,550 / 年
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_pairs_out.log", replace text

local root "C:\Users\任娜\Documents\deepseek-harness\default-workspace"

display _n(2) "{hline 84}"
display "  跨州 (o,d,year) 州对的数量 —— 复算 P11 的 2,542 / 2,458 / 5,000"
display "{hline 84}"

insheet using "`root'\usa_od.csv", clear
display _n "  csv 总行数 = " %14.0fc _N

* ---------------------------------------------------------------------------
* ① 各州个数
* ---------------------------------------------------------------------------
quietly levelsof o, local(OL)
quietly levelsof d, local(DL)
local no : word count `OL'
local nd : word count `DL'
display _n "  ① 出发州数 = `no'    目的州数 = `nd'"
display "     26 检验：`no'×(`nd'−1)×2 年 = " %10.0fc `no'*(`nd'-1)*2

* ---------------------------------------------------------------------------
* ② 跨州 (o,d,year) 去重后的个数（= P11 的口径）
* ---------------------------------------------------------------------------
preserve
    keep if o != d
    keep o d year
    duplicates drop
    display _n "  ② 跨州 (o,d,year) 去重后总对数 = " %10.0fc _N
    quietly contract year
    display _n "     分年："
    list year _freq, noobs table clean
restore

* ---------------------------------------------------------------------------
* ③ 用 fillin 找出「理论上该有、实际没有」的配对
* ---------------------------------------------------------------------------
preserve
    keep o d year
    duplicates drop
    fillin o d year
    display _n "  ③ fillin 补全后：理论上限 = " %10.0fc _N
    count if _fillin == 1 & o != d
    display "     缺失的跨州配对 = " %10.0fc r(N)
    display _n "     按年看缺失数："
    tab year if _fillin == 1 & o != d
    display _n "     全部缺失配对（o d year）："
    list o d year if _fillin == 1 & o != d, noobs table clean
restore

* ---------------------------------------------------------------------------
* ④ 结论
* ---------------------------------------------------------------------------
display _n(2) "{hline 84}"
display "  上限（跨州、每年）= 51 × 50 = 2,550"
display "  1990 实际         = 2,542      ⇒ 缺 8 对"
display "  2010 实际         = 2,458      ⇒ 缺 92 对"
display "  两年合计（无重叠） = 2,542 + 2,458 = 5,000"
display "{hline 84}"
display "  结束：$S_DATE $S_TIME"
log close