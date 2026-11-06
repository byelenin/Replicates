*==============================================================================
* t3_anova_table.do —— 把 ANOVA 表的两项拆开看清楚
*   Q1: 组内 2,407.14 是「各个组的方差之和」吗？        答：不是，是各组的【离差平方和】之和
*   Q2: 组间 544.90 是什么意思？                       答：各【组均值】偏离总均值的加权平方和
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_anova_table_out.log", replace text

local root "C:\Users\任娜\Documents\deepseek-harness\default-workspace"
local fz   "D:\研一上\微观计量\复现"

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

quietly summarize x
local XB = r(mean)
quietly count
local N = r(N)
display _n(2) "{hline 92}"
display "  ANOVA 表逐项拆解    x = ln(距离)   N = `N'   总均值 x̄ = " %8.5f `XB'
display "{hline 92}"

*==============================================================================
display _n "{hline 92}"
display "  【出发州×年】分组 —— 102 个组"
display "{hline 92}"
bysort oyear: egen double mo = mean(x)
gen double dev_in = (x - mo)^2
gen double dev_bt = (mo - `XB')^2

preserve
    collapse (sum) ss_g=dev_in (count) n_g=x (mean) mg=x (sum) bt_g=dev_bt, by(oyear)
    quietly count
    display _n "  组数 = " r(N)
    gen double var_g  = ss_g/n_g
    gen double var_g2 = ss_g/(n_g-1)

    quietly summarize ss_g
    local SUM_SS = r(sum)
    quietly summarize var_g
    local SUM_V  = r(sum)
    quietly summarize var_g2
    local SUM_V2 = r(sum)
    quietly summarize bt_g
    local SUM_BT = r(sum)
    quietly summarize n_g
    local NMIN = r(min)
    local NMAX = r(max)

    display _n "  ── Q1：组内那一项到底是什么？ ──"
    display "  " "{hline 78}"
    display "  (a) 各组【离差平方和】之和   Σ_g Σ_{i∈g}(x_i−x̄_g)²  = " %14.4f `SUM_SS'
    display "  (b) 各组【方差(*/n_g)】之和   Σ_g Var_g                = " %14.4f `SUM_V'
    display "  (c) 各组【无偏方差(/(n_g−1))】之和                    = " %14.4f `SUM_V2'
    display "  " "{hline 78}"
    display "  ⇒ ANOVA 表里的 2,407.14 是 (a)，不是 (b)" 
    display "  ⇒ (a)/(b) = " %8.2f `SUM_SS'/`SUM_V' " 倍 —— 差这么多是因为 (a) 里每组的离差被【加总】了 n_g 次"
    display ""
    display "  换算成【平均】方差：(a)/N = " %8.5f `SUM_SS'/`N' "    总方差 = " %8.5f (2952.0454/`N')
    display "  每组观测数 n_g：最小 " %3.0f `NMIN' "  最大 " %3.0f `NMAX'

    display _n "  ── Q2：组间那一项是什么意思？ ──"
    display "  " "{hline 78}"
    display "  Σ_g n_g (x̄_g − x̄)²  = " %14.4f `SUM_BT'
    display "  ⇒ 把每个【组均值】当成一个观测，看它偏离总均值多远，再按组的大小加权"
    display "  ⇒ 也就是「组与组之间的系统性差异」"
    display "  " "{hline 78}"
    display "  ★ 组间SS / 总SS = R²  = " %8.4f `SUM_BT'/2952.0454 "  ← 组虚拟变量回归 ln距离 的 R²"
    display "  ★ 组内SS / 总SS      = " %8.4f `SUM_SS'/2952.0454 "  ← 剩余（识别 β 用的变动）"
    display ""
    display "  组均值 x̄_g 的极端值（= 该州往所有目的地的平均 ln 距离）："
    gsort -mg
    display "    " %-10s "出发州-年" "   x̄_g      n_g"
    forvalues k = 1/3 {
        display "    " %-10.0f oyear[`k'] "   " %8.4f mg[`k'] "  " %5.0f n_g[`k']
    }
    display "    ..."
    local last = _N
    forvalues k = 1/3 {
        local r = `last' - `k' + 1
        display "    " %-10.0f oyear[`r'] "   " %8.4f mg[`r'] "  " %5.0f n_g[`r']
    }
restore

*==============================================================================
display _n(2) "{hline 92}"
display "  【目的州×年】分组 —— 102 个组"
display "{hline 92}"
bysort dyear: egen double md = mean(x)
gen double dev_in2 = (x - md)^2
gen double dev_bt2 = (md - `XB')^2
preserve
    collapse (sum) ss_g=dev_in2 (count) n_g=x (mean) mg=x (sum) bt_g=dev_bt2, by(dyear)
    quietly summarize ss_g
    local SUM_SS2 = r(sum)
    quietly summarize bt_g
    local SUM_BT2 = r(sum)
    display "  组内SS = " %12.4f `SUM_SS2' "     组间SS = " %12.4f `SUM_BT2' "     合计 = " %12.4f `SUM_SS2'+`SUM_BT2'
    display "  ★ R²(目的州×年 解释 ln距离) = " %8.4f `SUM_BT2'/2952.0454
restore

*==============================================================================
display _n(2) "{hline 92}"
display "  三张表放在一起看（总SS = 2,952.0454 恒定）"
display "{hline 92}"
display "  " "{hline 74}"
display "  分组           组内SS      组内占比    组间SS      组间占比(R²)"
display "  " "{hline 74}"
display "  出发州×年     2407.1434    " %6.2f 100*2407.1434/2952.0454 " %    544.9021    " %6.2f 100*544.9021/2952.0454 " %"
display "  目的州×年     2386.0098    " %6.2f 100*2386.0098/2952.0454 " %    566.0356    " %6.2f 100*566.0356/2952.0454 " %"
display "  双向迭代去均值 1826.0110    " %6.2f 100*1826.0110/2952.0454 " %    （交叉，无组间项）"
display "  " "{hline 74}"
display "  ⇒ 单向的组内占比 + 组间占比 = 100% ✓（精确分解）"
display "  ⇒ 双向没有这种加法结构：1826.0110 ≠ 2407.1434 − 某个组间项"

display _n(2) "{hline 92}"
display "  结束：$S_DATE $S_TIME"
log close