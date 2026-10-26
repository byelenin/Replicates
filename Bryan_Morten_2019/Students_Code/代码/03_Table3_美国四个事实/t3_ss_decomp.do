*==============================================================================
* t3_ss_decomp.do —— 二阶矩的排序：围绕 0 / 总均值 / 单路组均值 / 双向迭代
*   问题：减去均值的二阶矩，是不是小于任何其他二阶矩，包括单向分组的？
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_ss_decomp_out.log", replace text

local root "C:\Users\任娜\Documents\deepseek-harness\default-workspace"
local fz   "D:\研一上\微观计量\复现"

* ---- 距离 ----
import delimited "`fz'\us_state_fips2usps.csv", clear varnames(1)
destring state_fips, replace
rename state_fips o
tempfile f2u
save `f2u'
import delimited "`fz'\us_state_centroids.csv", clear varnames(1)
keep usps lat lon
merge 1:1 usps using `f2u', keep(match) nogen
keep o lat lon
rename lat lat_o
rename lon lon_o
rename o d
rename lat_o lat_d
rename lon lon_d
tempfile c_d
save `c_d'
import delimited "`fz'\us_state_centroids.csv", clear varnames(1)
keep usps lat lon
merge 1:1 usps using `f2u', keep(match) nogen
keep o lat lon
rename lat lat_o
rename lon lon_o
tempfile c_o
save `c_o'
use `c_o', clear
cross using `c_d'
gen double _pio = _pi/180
gen double _dla = (lat_d - lat_o)*_pio
gen double _dlo = (lon_d - lon_o)*_pio
gen double _a = sin(_dla/2)^2 + cos(lat_o*_pio)*cos(lat_d*_pio)*sin(_dlo/2)^2
gen double dist_km = 2*6371*asin(min(1, sqrt(_a)))
keep o d dist_km
tempfile usdist
save `usdist'

* ---- 州对面板 ----
insheet using "`root'\usa_od.csv", clear
gen double m_w = w
collapse (sum) m_w, by(o d year)
rename m_w m_od
drop if o == d
sort o d
merge m:1 o d using `usdist', keep(match) nogen
gen double x = ln(dist_km)
gen double oyear = o*10000 + year
gen double dyear = d*10000 + year

quietly count
local N = r(N)
display _n(2) "{hline 92}"
display "  二阶矩的排序 —— 变量取 x = ln(距离)，N = `N' 个州对"
display "{hline 92}"

* (A) 围绕 0
gen double ss0 = x^2
quietly summarize ss0
local A = r(sum)

* (B) 围绕总均值
quietly summarize x
local xb = r(mean)
gen double ssT = (x - `xb')^2
quietly summarize ssT
local B = r(sum)

* (C) 围绕「出发州×年」组均值
bysort oyear: egen double mo = mean(x)
gen double ssO = (x - mo)^2
quietly summarize ssO
local C = r(sum)
* 组间（出发州×年）
gen double ssB1 = (mo - `xb')^2
quietly summarize ssB1
local B1 = r(sum)

* (D) 围绕「目的州×年」组均值
bysort dyear: egen double md = mean(x)
gen double ssD = (x - md)^2
quietly summarize ssD
local D = r(sum)
gen double ssB2 = (md - `xb')^2
quietly summarize ssB2
local B2 = r(sum)

* (E) 双向迭代去均值
gen double xt = x
forvalues k = 1/250 {
    quietly bysort oyear: egen double _q = mean(xt)
    quietly replace xt = xt - _q
    quietly drop _q
    quietly bysort dyear: egen double _q = mean(xt)
    quietly replace xt = xt - _q
    quietly drop _q
}
gen double ss2 = xt^2
quietly summarize ss2
local E = r(sum)

display _n "  ── 各口径的二阶矩 ──"
display "  " "{hline 74}"
display "  (A) 围绕 0                        Σx²                = " %14.4f `A'
display "  (B) 围绕【总均值】x̄              Σ(x−x̄)²            = " %14.4f `B'
display "  (C) 围绕【出发州×年】组均值       Σ(x−x̄_oyear)²      = " %14.4f `C'
display "  (D) 围绕【目的州×年】组均值       Σ(x−x̄_dyear)²      = " %14.4f `D'
display "  (E) 双向【迭代】去均值            Σ(x−x̃)²            = " %14.4f `E'
display "  " "{hline 74}"

display _n "  ── 排序检验 ──"
display "  (B) ≤ (A) ？  " %14.4f `B' " ≤ " %14.4f `A' "   →  " cond(`B' <= `A', "✓ 成立", "✗ 不成立")
display "  (C) ≤ (B) ？  " %14.4f `C' " ≤ " %14.4f `B' "   →  " cond(`C' <= `B', "✓ 成立", "✗ 不成立")
display "  (D) ≤ (B) ？  " %14.4f `D' " ≤ " %14.4f `B' "   →  " cond(`D' <= `B', "✓ 成立", "✗ 不成立")
display "  (E) ≤ min(C,D) ？  " %14.4f `E' " →  " cond(`E' <= min(`C',`D'), "✓ 成立", "✗ 不成立")

display _n "  ── 关键：单向的方差分解是【精确】的；双向不是 ──"
display "  " "{hline 74}"
display "  单向 (出发州×年)：  组内 + 组间 = " %14.4f `C' " + " %14.4f `B1' " = " %14.4f `C'+`B1'
display "                      总二阶矩 (B) = " %14.4f `B'
display "                      差           = " %12.2e abs(`B' - (`C'+`B1'))
display "                      ⇒ " cond(abs(`B'-(`C'+`B1')) < 1e-8, "✓ 精确相等（ANOVA 恒等式）", "✗ 不相等")
display ""
display "  单向 (目的州×年)：  组内 + 组间 = " %14.4f `D' " + " %14.4f `B2' " = " %14.4f `D'+`B2'
display "                      总二阶矩 (B) = " %14.4f `B'
display "                      差           = " %12.2e abs(`B' - (`D'+`B2'))
display "                      ⇒ " cond(abs(`B'-(`D'+`B2')) < 1e-8, "✓ 精确相等（ANOVA 恒等式）", "✗ 不相等")
display ""
display "  双向：组内_行 + 组内_列 = " %14.4f `C' " + " %14.4f `D' " = " %14.4f `C'+`D'
display "                      总二阶矩 (B) = " %14.4f `B'
display "                      ⇒ 两者【没有】固定的加减关系（重叠部分被算了两次）"

display _n(2) "{hline 92}"
display "  结束：$S_DATE $S_TIME"
log close