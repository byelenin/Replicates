*==============================================================================
* t3_weight_explain.do —— 把 n_od / m_od / 不加权 三者的区别跑成具体数字
*==============================================================================
clear all
set more off
set linesize 190
capture log close
log using "t3_weight_explain_out.log", replace text

local root "C:\Users\任娜\Documents\deepseek-harness\default-workspace"

display _n(2) "{hline 84}"
display "  n_od / m_od / 不加权 —— 到底是什么"
display "{hline 84}"

insheet using "`root'\usa_od.csv", clear
keep if o != d

*------------------------------------------------------------------------------
display _n(2) "① 关键：被抽到的「1 个人」代表多少真实人口（IPUMS 个人权重 w）"
display "   " "{hline 74}"
tabstat w, by(year) statistics(sum n mean) format(%16.0fc)
display "   " "{hline 74}"
display "   ⇒ 1990 是 5% 普查，1 人代表约 20 人；2010 ACS 抽样率低得多，1 人代表约 100 人"

*------------------------------------------------------------------------------
gen double m_w = w
gen double n_w = 1
collapse (sum) m_w n_w, by(o d year)
rename m_w m_od
rename n_w n_od
gen double per_person = m_od/n_od

display _n(2) "② 人数最多的 6 个州对（n_od 大）"
list o d year n_od m_od per_person in 1/6, noobs sep(0)
gsort -n_od
display _n "   排序后，人数最多的 6 个："
list o d year n_od m_od per_person in 1/6, noobs sep(0)

display _n(2) "③ 人数最少的 6 个州对（n_od 小，但可能代表同样多的人）"
gsort n_od
list o d year n_od m_od per_person in 1/6, noobs sep(0)

display _n(2) "④ 假设只抽到 1 个人：m_od 还是能反映它代表的人口"
count if n_od == 1
display "   只有 1 个人的州对： " %8.0fc r(N) " 个"
count if n_od <= 5
display "   5 个人及以下的州对： " %8.0fc r(N) " 个"

display _n(2) "⑤ 总量对比"
quietly summarize n_od
display "   Σ n_od（实际人数合计）  = " %16.0fc r(sum)
quietly summarize m_od
display "   Σ m_od（代表人口合计）  = " %16.0fc r(sum)
quietly count
display "   州对个数（不加权时每个算 1 票） = " %10.0fc r(N)

display _n(2) "⑥ 一个『不加权』的直观后果"
quietly summarize n_od
display "   最大的州对 n_od = " %10.0fc r(max) " ，最小的 n_od = " %10.0fc r(min)
display "   ⇒ n_od 加权：最大州对的影响是最小州对的 " %8.0fc r(max) " 倍"
display "   ⇒ m_od 加权：按代表人口算，倍数 = " 
quietly summarize m_od
local mmax = r(max)
quietly summarize m_od
local mmin = r(min)
display "      最大 m_od / 最小 m_od = " %12.1f `mmax'/`mmin'
display "   ⇒ 不加权：最大州对和最小州对【完全同权】，倍数 = 1"

display _n(2) "{hline 84}"
display "  结束：$S_DATE $S_TIME"
log close