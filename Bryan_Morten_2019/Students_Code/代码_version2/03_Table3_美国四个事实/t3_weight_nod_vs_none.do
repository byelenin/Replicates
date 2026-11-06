*==============================================================================
* t3_weight_nod_vs_none.do —— n_od 与「不加权」的关系，量化
*==============================================================================
clear all
set more off
set linesize 190
capture log close
log using "t3_weight_nod_vs_none_out.log", replace text

local root "C:\Users\任娜\Documents\deepseek-harness\default-workspace"

insheet using "`root'\usa_od.csv", clear
keep if o != d
gen double n_w = 1
collapse (sum) n_w, by(o d year)
rename n_w n_od

quietly count
local T = r(N)
quietly summarize n_od
local S = r(sum)
local AVG = `S'/`T'

display _n(2) "{hline 84}"
display "  n_od 与「不加权」：一个是「人投票」，一个是「州对投票」"
display "{hline 84}"
display ""
display "  州对总数（不加权的总票数）   = " %12.0fc `T'
display "  总人数 Σn_od（n_od 的总票数）= " %12.0fc `S'
display "  平均每个州对 " %6.1f `AVG' " 人"
display ""
display "  会被 1 整除：不加权时每票 = " %8.6f 1/`T' "（" %5.3f 100/`T' "%）"
display "             n_od 时最大那个州对 = " %8.6f 10737/`S'
display ""

display "  ── 小州对：不加权时它们很响，n_od 时它们几乎消失 ──"
display "  " "{hline 78}"
display "  n_od 范围      州对个数   占票数(不加权)   占人数(n_od)   相差倍数"
display "  " "{hline 78}"
foreach c in 1 2 5 10 50 100 {
    quietly count if n_od <= `c'
    local k = r(N)
    quietly summarize n_od if n_od <= `c'
    local s = r(sum)
    local p1 = 100*`k'/`T'
    local p2 = 100*`s'/`S'
    local rr = (`k'/`T')/(`s'/`S')
    display "  <= `c' 人        " %8.0fc `k' "     " %6.2f `p1' "%        " %6.3f `p2' "%      " %8.0f `rr' " 倍"
}
display "  " "{hline 78}"
display "  ⇒ 只抽到 1 个人的州对：不加权时占 3.1% 的话语权，n_od 时只占 0.017% —— 差约 180 倍"

display _n "  ── 大州对：反过来 ──"
quietly count if n_od >= 3000
local kb = r(N)
quietly summarize n_od if n_od >= 3000
local sb = r(sum)
display "  n_od >= 3,000 的州对： " %6.0fc `kb' " 个（占 " %5.2f 100*`kb'/`T' "% 的州对数）"
display "  ⇒ 但它们占了 " %5.2f 100*`sb'/`S' "% 的人数"
display "  ⇒ 不加权时它们只剩 " %5.2f 100*`kb'/`T' "% 的话语权 —— 被压缩了 " %6.0f (`sb'/`S')/(`kb'/`T') " 倍"

display _n "  ── 最大的那个州对，两种口径下的分量 ──"
gsort -n_od
local mx = n_od[1]
display "  最大州对 n_od = " %10.0fc `mx'
display "      不加权时分量 = " %10.6f 1/`T' "     n_od 时分量 = " %10.6f `mx'/`S'
display "      ⇒ n_od 让它重了 " %6.0f (`mx'/`S')/(1/`T') " 倍"

display _n(2) "{hline 84}"
display "  结束：$S_DATE $S_TIME"
log close