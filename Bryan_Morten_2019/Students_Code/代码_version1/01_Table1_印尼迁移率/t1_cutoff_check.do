*==============================================================================
* t1_cutoff_check.do — 独立验证 Table 1 复现里 62.69% 的来源与 urban 编码方向
*
*   62.69% 声称是「全国农村人口占比」。本文件做三件事：
*     ① 打印 urban 的取值分布与标签（确认 1=Rural 还是 1=Urban）
*     ② 用平均工资反推方向：印尼 1995 年城镇工资远高于农村
*     ③ 重算 62.69%，并列出它对切点、对规则A/B 的影响
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t1_cutoff_check_out.log", replace text

local root "D:\研一上\微观计量"

display _n(2) "{hline 84}"
display "  Table 1 复现：62.69% 溯源与 urban 编码方向验证"
display "{hline 84}"

use year geo2_id1995 id1995a_bplreg incwage perwt relate sex age urban ///
    using "`root'\ipumsi_00002.dta", clear
display _n "  原始记录：" %12.0fc _N
keep if year == 1995
display "  1995 年：" %12.0fc _N

*------------------------------------------------------------------------------
display _n(2) "{hline 84}"
display "  ① urban 的取值分布与标签"
display "{hline 84}"
capture label list URBAN
capture label list urban
capture label list geo2_id1995
display ""
tab urban, missing

*------------------------------------------------------------------------------
display _n(2) "{hline 84}"
display "  ② 用平均工资反推方向（城镇工资 >> 农村）"
display "{hline 84}"
display "     若 urban==2 的平均工资明显更高 ⇒ urban==2 是城镇、urban==1 是农村"
display ""
table urban, statistic(mean incwage) statistic(mean perwt) statistic(frequency) nformat(%12.1f)

*------------------------------------------------------------------------------
display _n(2) "{hline 84}"
display "  ③ 重算 62.69%（全国农村人口占比，加权，全部 1995 年人口）"
display "{hline 84}"
quietly summarize perwt
local tot = r(sum)
display "     Σ perwt（全部人口，加权）= " %16.0fc `tot'

foreach u in 1 2 {
    quietly summarize perwt if urban == `u'
    local s`u' = r(sum)
    local p`u' = `s`u''/`tot'*100
    display "     urban==`u' 的 Σ perwt = " %16.0fc `s`u'' "   = " %6.2f `p`u'' "%"
}
display ""
display "     ⭐ 若 urban==1 是农村，则 62.69% = " %6.2f `p1' "%"
display "        若 urban==2 是农村，则 62.69% = " %6.2f `p2' "%"

*------------------------------------------------------------------------------
display _n(2) "{hline 84}"
display "  ④ 县级农村占比 → 规则 A / 规则 B 的切点（复算）"
display "{hline 84}"
preserve
    gen double wrur1 = perwt*(urban == 1)
    gen double wrur2 = perwt*(urban == 2)
    collapse (sum) wpop = perwt wrur1 wrur2, by(geo2_id1995)
    gen double rs1 = wrur1/wpop
    gen double rs2 = wrur2/wpop
    quietly summarize wpop
    local tp = r(sum)
    quietly summarize wrur1
    local n1 = r(sum)/`tp'
    quietly summarize wrur2
    local n2 = r(sum)/`tp'
    display "     县数 = " _N
    display "     以 urban==1 为农村：全国农村占比 = " %6.2f `n1'*100 "%"
    display "     以 urban==2 为农村：全国农村占比 = " %6.2f `n2'*100 "%"
    display ""
    foreach k in 1 2 {
        quietly summarize rs`k', detail
        local med`k' = r(p50)
        gsort -rs`k'
        gen double cs`k' = sum(wpop)/`tp'
        gen long ord`k' = _n
        local tgt = `n`k''
        quietly summarize ord`k' if cs`k' >= `tgt', meanonly
        local kA = r(min)
        local cutA = rs`k'[`kA']
        quietly count if rs`k' > `cutA'
        local nR = r(N)
        display "     口径 `k'：中位数 = " %6.4f `med`k'' ///
            " ；规则A 切点 = " %6.4f `cutA' " → 农村县 `nR' 个"
    }
restore

display _n(2) "{hline 84}"
display "  结论"
display "{hline 84}"
display "  62.69% 是【从 IPUMS 数据本身】算出来的全国农村人口占比，不是外部统计数字。"
display "  公式：62.69% = Σ_i perwt_i·1(农村_i) / Σ_i perwt_i   （1995 年全部人口）"
display "{hline 84}"
log close