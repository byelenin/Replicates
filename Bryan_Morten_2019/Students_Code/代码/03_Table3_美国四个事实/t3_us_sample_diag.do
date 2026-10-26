*==============================================================================
* t3_us_sample_diag.do — 美国样本口径诊断：论文的 2,294,054 到底是哪个样本？
*
*   要回答的问题：
*     论文 Table 3 报「Number of individuals = 2,294,054（列1）/ 2,294,046（列2-4）」
*     我们的 usa_od.csv 有 2,333,166 行 —— 差 39,112 行。
*     论文 L395-396 说样本限定为「male heads of household between 15 and 65」，
*     L396 又说这适用于「Indonesian AND US samples」。
*     那 2,294,054 是不是「男性户主 15-65」？还是别的口径？
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_us_sample_diag_out.log", replace text

local root "C:\Users\任娜\Documents\deepseek-harness\default-workspace"

display _n(2) "{hline 86}"
display "  美国样本口径诊断 —— 找 2,294,054 / 2,294,046"
display "{hline 86}"

insheet using "`root'\usa_od.csv", clear
display _n "  ① 全部行数 = " %14.0fc _N
display "     目标（论文列1）= 2,294,054      差 = " %12.0fc _N - 2294054
display "     目标（论文列2-4）= 2,294,046    差 = " %12.0fc _N - 2294046

display _n "  ② 变量与缺失"
describe, short
foreach v in o d year wage w age statefip pwstate2 gq educ empstat inctot incearn {
    capture confirm variable `v'
    if _rc == 0 {
        quietly count if missing(`v')
        display "     `v'  缺失 = " %12.0fc r(N)
    }
}

display _n "  ③ 分年"
tab year, missing

display _n "  ④ age 分布"
quietly summarize age, detail
display "     min = " %6.0f r(min) "  p25 = " %6.0f r(p25) "  中位 = " %6.0f r(p50) "  p75 = " %6.0f r(p75) "  max = " %6.0f r(max) "  缺失 = " %10.0fc r(N)
count if inrange(age, 15, 65)
display "     age 在 15-65 的行数 = " %14.0fc r(N)
count if !inrange(age, 15, 65) & !missing(age)
display "     age 在 15-65 之外   = " %14.0fc r(N)
display "     ⇒ 若只留 15-65，为 " %14.0fc _N " 行" 

display _n "  ⑤ gq（group quarters）"
tab gq, missing

display _n "  ⑥ empstat"
tab empstat, missing

display _n "  ⑦ 工资"
count if !missing(wage) & wage > 0
display "     有工资(wage>0)      = " %14.0fc r(N)
count if missing(wage) | wage <= 0
display "     无有效工资          = " %14.0fc r(N)
count if !missing(w)
display "     有 w（权重）        = " %14.0fc r(N)

display _n "  ⑧ 跨州 / 留守"
count if o != d
display "     跨州 o != d         = " %14.0fc r(N)
count if o == d
display "     留守 o == d         = " %14.0fc r(N)

display _n "  ⑨ 候选口径 —— 逐个试，看哪个等于 2,294,054"
local targets "2294054 2294046"
foreach f in "" "if inrange(age,15,65)" "if gq == 0" "if gq == 1" "if !missing(wage) & wage > 0" "if o != d" "if inrange(age,15,65) & o != d" "if inrange(age,15,65) & gq == 0" {
    quietly count `f'
    local n = r(N)
    local hit ""
    if abs(`n' - 2294054) < 2000 | abs(`n' - 2294046) < 2000 local hit "   ⭐ 接近目标！"
    display "     count `f'   →  " %14.0fc `n' "`hit'"
}
foreach e in 1 2 3 4 5 6 7 {
    quietly count if empstat == `e'
    local n = r(N)
    local hit ""
    if abs(`n' - 2294054) < 2000 local hit "   ⭐ 接近目标！"
    display "     count if empstat==`e'  →  " %14.0fc `n' "`hit'"
}

display _n "  ⑩ 权重之和（看 2,294,054 会不会是加权人口）"
quietly summarize w
display "     sum(w) 全样本 = " %16.0fc r(sum)
quietly summarize w if o != d
display "     sum(w) 跨州     = " %16.0fc r(sum)
quietly summarize w if o == d
display "     sum(w) 留守     = " %16.0fc r(sum)

display _n(2) "{hline 86}"
display "  结束：$S_DATE $S_TIME"
log close