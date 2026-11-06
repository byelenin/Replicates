*==============================================================================
* Table3US_replication.do
*   JPE Table 3「Four Facts about Migration in the United States」复现
*   全 2166 行论文中的第 721–773 行（JPE p.2241）
*
*   四列：
*     (1) dep = ln p_odt   ，回归元 ln_dist                      → 论文 -.553 (.018)***
*     (2) dep = ln w_odt   ，回归元 ln_dist                      → 论文  .023 (.002)***
*     (3) dep = ln w_odt   ，回归元 ln_dist + ln p_odt           → 论文 -.004 (.004) / -.043 (.003)***
*     (4) dep = ln w_odt   ，回归元 ln p_odt                     → 论文 -.050 (.006)***
*   四列都含 出发地×年 与 目的地×年 固定效应；
*   标准误【双向聚类】在 origin-year 与 destination-year（论文注，第 770–771 行）。
*
*   美国州级面板代码复用 Table3_replication.do 第 1–2 节（未改动原文件）。
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
matrix drop _all
capture log close
log using "table3us_out.log", replace text

local root  "D:\研一上\微观计量"
local fz    "`root'\复现"
local ussrc "C:\Users\任娜\Documents\deepseek-harness\default-workspace\usa_od.csv"

display _n(2) "{hline 88}"
display "  Bryan & Morten (2019)  JPE Table 3 复现"
display "  Four Facts about Migration in the United States"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 88}"

*==============================================================================
* 0. 环境
*==============================================================================
display _n "===== 0. 环境检查 ====="
display "  Stata 版本：`c(stata_version)'"
foreach f in "`ussrc'" "`fz'\us_state_centroids.csv" "`fz'\us_state_fips2usps.csv" {
    capture confirm file "`f'"
    if _rc {
        display as error "  【错误】找不到文件：`f'"
        exit 601
    }
    display "  找到：`f'"
}
capture which reghdfe
if _rc display as error "  【警告】未装 reghdfe，将改用 areg + 手写聚类"

*==============================================================================
* 1. 美国州级距离（经纬度 → 大圆距离）
*==============================================================================
display _n "===== 1. 美国州级距离 ====="

import delimited "`fz'\us_state_fips2usps.csv", clear varnames(1)
destring state_fips, replace
rename state_fips o
tempfile f2u
save `f2u'

import delimited "`fz'\us_state_centroids.csv", clear varnames(1)
keep usps lat lon
merge 1:1 usps using `f2u', keep(match) nogen
display "  质心与 FIPS 对应：`c(N)' 个州"
keep o lat lon
rename lat lat_o
rename lon lon_o
rename o d
rename lat_o lat_d
rename lon_o lon_d
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
order o d dist_km
sort o d
tempfile usdist
save `usdist'
quietly summarize dist_km
display "  州级 OD 对：`r(N)'"
display "  距离(km)：最小 " %8.1f r(min) "   平均 " %8.1f r(mean) "   最大 " %8.1f r(max)

*==============================================================================
* 2. 美国州级 OD 面板（1990 census + 2010 ACS）
*==============================================================================
display _n "===== 2. 美国州级 OD 面板 ====="
display "  读入 usa_od.csv（145 MB），需要一会儿 ..."

import delimited "`ussrc'", clear varnames(1) colrange(1:5)
display "  原始行数：`c(N)'"
capture destring o, replace
capture destring d, replace
capture destring year, replace
capture destring wage, replace force
capture destring w, replace force

keep o d year wage w
drop if missing(o) | missing(d) | missing(year)
drop if missing(w) | w <= 0
keep if inrange(year, 1990, 2010)
display "  州码/年份/权重有效：`c(N)'"

* 迁移份额用全部人；平均工资只用有工资的人
gen byte hasw = !missing(wage) & wage > 0
gen double m_w  = w
gen double n_w  = 1
gen double wx_w = w*wage if hasw
gen double wg_w = w if hasw
collapse (sum) m_w n_w wx_w wg_w, by(o d year)
rename m_w  m_od
rename n_w  n_od
rename wx_w wsum
rename wg_w wden
gen double wage_od = wsum/wden if wden > 0 & !missing(wden)
drop wsum wden

bysort o year: egen double pop_o  = total(m_od)
bysort d year: egen double m_in_d = total(m_od)
bysort year:  egen double pop_all = total(m_od)
gen double pi_do = m_od/pop_o
display "  OD 单元数(含对角线)：`c(N)'"

preserve
    keep if o == d
    keep o year pi_do
    rename pi_do pi_oo
    tempfile udg_o
    save `udg_o'
    rename o d
    rename pi_oo pi_dd
    tempfile udg_d
    save `udg_d'
restore
preserve
    keep o d year pi_do
    rename o _t1
    rename d _t2
    rename _t1 d
    rename _t2 o
    rename pi_do pi_rev
    tempfile urev
    save `urev'
restore

gen double pi_dnoto = (m_in_d - m_od)/(pop_all - pop_o) if (pop_all - pop_o) > 0
keep if o != d
merge m:1 o year using `udg_o', keep(master match) nogen
merge m:1 d year using `udg_d', keep(master match) nogen
merge 1:1 o d year using `urev', keep(master match) nogen
merge m:1 o d using `usdist', keep(master match) nogen

* --- Table 3 只需要的筛选：正向流量 + 距离 ---
* 【重要】不需要 反向流 pi_rev / 对角线 pi_oo,pi_dd / 留一法 pi_dnoto ——
* 那些是 Table 4 结构估计用的，套到 Table 3 上会砍掉约 60% 的样本。
keep if !missing(pi_do) & pi_do > 0
keep if !missing(dist_km) & dist_km > 0

gen double ln_p    = ln(pi_do)
gen double ln_dist = ln(dist_km)
gen double ln_wage = ln(wage_od) if !missing(wage_od) & wage_od > 0

* 双向聚类的两个维度
egen long oyear = group(o year)
egen long dyear = group(d year)

display "  州对(含 1990/2010)：`c(N)'"
tab year, missing
count if !missing(ln_wage)
display "  其中有观测工资的州对：`r(N)'"

tempfile uspanel
save `uspanel'

*==============================================================================
* 3. Table 3 四列回归
*==============================================================================
display _n(2) "{hline 88}"
display "  3. Table 3 四列回归（加权 by n_od；双向聚类 origin-year / destination-year）"
display "{hline 88}"

capture program drop t3col
program define t3col
    args tag dep rhs useif
    display _n "  ── 列 `tag'：dep = `dep' ，回归元 = `rhs' ─────────────"
    capture noisily reghdfe `dep' `rhs' [aw=n_od] `useif', ///
        absorb(oyear dyear) vce(cluster oyear dyear)
    if _rc {
        display "     (reghdfe 失败 rc=" _rc "，改用 areg + 双向聚类)"
        capture noisily areg `dep' `rhs' [aw=n_od] `useif', absorb(oyear) vce(cluster oyear dyear)
    }
    quietly count `useif'
    local npair = r(N)
    quietly summarize n_od `useif'
    display "     州对 N = " `npair' "    个体数 = " %12.0fc r(sum)
end

use `uspanel', clear
t3col 1 ln_p    "ln_dist"            ""
t3col 2 ln_wage "ln_dist"            "if !missing(ln_wage)"
t3col 3 ln_wage "ln_dist ln_p"       "if !missing(ln_wage)"
t3col 4 ln_wage "ln_p"               "if !missing(ln_wage)"

* ---- 3b. 列(1) 的分母口径检验（论文 -.553 对州际引力方程异常偏小）----
display _n(2) "{hline 88}"
display "  3b. 列(1) 分母口径检验：p_od 到底除以谁的入口？"
display "{hline 88}"
use `uspanel', clear
gen double p_share_o   = m_od/pop_o                       if pop_o > 0
gen double p_share_d   = m_od/m_in_d                      if m_in_d > 0
gen double p_share_all = m_od/pop_all                     if pop_all > 0
gen double p_raw       = m_od
display ""
display "  口径                                    系数(ln_dist)     SE       州对N"
display "  " "{hline 74}"
foreach vn in p_share_o p_share_d p_share_all p_raw {
    local vl ""
    if "`vn'" == "p_share_o"   local vl "m_od / 出发州人口 pop_o"
    if "`vn'" == "p_share_d"   local vl "m_od / 目的州人口 m_in_d"
    if "`vn'" == "p_share_all" local vl "m_od / 全国人口 pop_all"
    if "`vn'" == "p_raw"       local vl "m_od (原始流量, 不除)"
    capture drop _lnpv
    capture gen double _lnpv = ln(`vn') if `vn' > 0
    capture quietly reghdfe _lnpv ln_dist [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
    if _rc == 0 {
        local bb = _b[ln_dist]
        local ss = _se[ln_dist]
        local nn = e(N)
        display "  `vl'   b = " %9.4f `bb' "   SE = " %8.4f `ss' "   N = " %9.0fc `nn'
    }
    else display "  `vl'  → 失败 rc=" _rc
}
display "  " "{hline 74}"
display "  论文对应（JPE Table 3 列(1)）：  -0.5530     (.0180)   5,084"

*==============================================================================
* 4. 与论文对照
*==============================================================================
display _n(2) "{hline 88}"
display "  4. 与论文对照（JPE Table 3, p.2241）"
display "{hline 88}"
display ""
display "  列  变量            本复现      论文         论文SE"
display "  " "{hline 78}"

* 重新跑一遍并抓系数
matrix RES = J(6, 4, .)
local r = 0

use `uspanel', clear
quietly reghdfe ln_p ln_dist [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
local r = `r' + 1
matrix RES[`r', 1] = _b[ln_dist]
matrix RES[`r', 2] = _se[ln_dist]
display "  (1) ln_dist  → ln p      " %9.4f _b[ln_dist] "   -.553       (.018)"

quietly reghdfe ln_wage ln_dist [aw=n_od] if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
local r = `r' + 1
matrix RES[`r', 1] = _b[ln_dist]
matrix RES[`r', 2] = _se[ln_dist]
display "  (2) ln_dist  → ln w      " %9.4f _b[ln_dist] "    .023       (.002)"

quietly reghdfe ln_wage ln_dist ln_p [aw=n_od] if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
local r = `r' + 1
matrix RES[`r', 1] = _b[ln_dist]
matrix RES[`r', 2] = _se[ln_dist]
local r = `r' + 1
matrix RES[`r', 1] = _b[ln_p]
matrix RES[`r', 2] = _se[ln_p]
display "  (3) ln_dist  → ln w      " %9.4f _b[ln_dist] "   -.004       (.004)"
display "  (3) ln p     → ln w      " %9.4f _b[ln_p] "   -.043       (.003)"

quietly reghdfe ln_wage ln_p [aw=n_od] if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
local r = `r' + 1
matrix RES[`r', 1] = _b[ln_p]
matrix RES[`r', 2] = _se[ln_p]
display "  (4) ln p     → ln w      " %9.4f _b[ln_p] "   -.050       (.006)"

*==============================================================================
* 5. 四个事实逐条判读
*==============================================================================
display _n(2) "{hline 88}"
display "  5. 四个事实"
display "{hline 88}"
display ""
display "  事实 1（引力方程）：距离降低迁移份额 —— 论文 -.553，本复现 " %8.4f RES[1,1]
display "  事实 2（距离抬高目的工资）：论文  .023，本复现 " %8.4f RES[2,1]
display "  事实 3（迁移份额压低工资）：论文 -.043，本复现 " %8.4f RES[4,1]
display "  事实 4（份额而非距离驱动，赛马）："
display "        含份额后距离系数 —— 论文 -.004（不显著），本复现 " %8.4f RES[3,1] "   SE " %8.4f RES[3,2]
display "        份额系数     —— 论文 -.050，本复现 " %8.4f RES[5,1]
display ""

* 显著性
display "  ── 显著性（|t| 判读：1.96→5%，2.576→1%）──"
local nm : word 1 of "ln_dist→lnp ln_dist→lnw ln_dist→lnw ln_p→lnw ln_p→lnw"
forvalues i = 1/5 {
    local b = RES[`i',1]
    local s = RES[`i',2]
    local t = `b'/`s'
    local star ""
    if abs(`t') > 2.576 local star "***"
    else if abs(`t') > 1.96 local star "**"
    else if abs(`t') > 1.645 local star "*"
    local lb : word `i' of "ln_dist→lnp ln_dist→lnw ln_dist→lnw ln_p→lnw ln_p→lnw"
    display "     `lb'   b = " %9.4f `b' "   SE = " %9.4f `s' "   t = " %7.2f `t' "  `star'"
}

*==============================================================================
* 6. 稳健性
*==============================================================================
display _n(2) "{hline 88}"
display "  6. 稳健性"
display "{hline 88}"

* ---- (0) 三种加权方式的对比（这是关键诊断）----
display _n "  ── (0) 三种加权方式对比：哪一种是论文口径？──"
display "     论文个体数 = 2,294,054 / 州对 = 5,084"
display ""
foreach wt in "m_od" "n_od" "" {
    use `uspanel', clear
    if "`wt'" == "" local lab "不加权（州对等权）"
    else if "`wt'" == "m_od" local lab "按人口权重和 m_od"
    else local lab "按原始人数 n_od"
    local wopt ""
    if "`wt'" != "" local wopt "[aw=`wt']"
    quietly summarize `wt' if !missing(ln_wage)
    display "     加权 = `lab'   个体数 = " %12.0fc r(sum)
    capture quietly reghdfe ln_p ln_dist `wopt', absorb(oyear dyear) vce(cluster oyear dyear)
    local b1 = _b[ln_dist]
    display "        (1) ln_dist → ln p   " %9.4f `b1'
    capture quietly reghdfe ln_wage ln_dist `wopt' if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
    display "        (2) ln_dist → ln w   " %9.4f _b[ln_dist]
    capture quietly reghdfe ln_wage ln_dist ln_p `wopt' if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
    display "        (3) ln_dist → ln w   " %9.4f _b[ln_dist] "   ln p → ln w   " %9.4f _b[ln_p]
    capture quietly reghdfe ln_wage ln_p `wopt' if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
    display "        (4) ln p    → ln w   " %9.4f _b[ln_p]
    display "        ── 论文对应： -0.5530    0.0230    -0.0040 / -0.0430    -0.0500"
    display ""
}

display _n "  ── (a) 不加权（州对等权）──"
use `uspanel', clear
quietly reghdfe ln_p ln_dist, absorb(oyear dyear) vce(cluster oyear dyear)
display "     (1) ln_dist → ln p   " %9.4f _b[ln_dist] "  SE " %8.4f _se[ln_dist]
quietly reghdfe ln_wage ln_dist if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
display "     (2) ln_dist → ln w   " %9.4f _b[ln_dist] "  SE " %8.4f _se[ln_dist]
quietly reghdfe ln_wage ln_p if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
display "     (4) ln p    → ln w   " %9.4f _b[ln_p] "  SE " %8.4f _se[ln_p]

foreach y in 1990 2010 {
    display _n "  ── (b) 只用 `y' 年 ──"
    use `uspanel', clear
    keep if year == `y'
    quietly count
    display "     州对 = " r(N)
    quietly reghdfe ln_p ln_dist [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
    display "     (1) ln_dist → ln p   " %9.4f _b[ln_dist] "  SE " %8.4f _se[ln_dist]
    quietly reghdfe ln_wage ln_dist [aw=n_od] if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
    display "     (2) ln_dist → ln w   " %9.4f _b[ln_dist] "  SE " %8.4f _se[ln_dist]
    quietly reghdfe ln_wage ln_dist ln_p [aw=n_od] if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
    display "     (3) ln_dist → ln w   " %9.4f _b[ln_dist] "  SE " %8.4f _se[ln_dist]
    display "     (3) ln p    → ln w   " %9.4f _b[ln_p] "  SE " %8.4f _se[ln_p]
    quietly reghdfe ln_wage ln_p [aw=n_od] if !missing(ln_wage), absorb(oyear dyear) vce(cluster oyear dyear)
    display "     (4) ln p    → ln w   " %9.4f _b[ln_p] "  SE " %8.4f _se[ln_p]
}

* ---- (c) 标准误口径对比（列(2) 的双向聚类在只有 2 年时数值退化）----
display _n "  ── (c) 标准误口径对比（同一系数，不同 SE）──"
local n = 0
foreach dv in ln_p ln_wage ln_wage {
    local n = `n' + 1
    local rv "ln_dist"
    local cd "if 1"
    if `n' == 2 local rv "ln_dist"
    if `n' == 2 local cd "if !missing(ln_wage)"
    if `n' == 3 local rv "ln_p"
    if `n' == 3 local cd "if !missing(ln_wage)"
    display "     [dep=`dv'  reg=`rv'  `cd']"
    use `uspanel', clear
    capture quietly reghdfe `dv' `rv' [aw=n_od] `cd', absorb(oyear dyear) vce(cluster oyear dyear)
    if _rc == 0 & !missing(_se[`rv']) {
        display "        vce(cluster oyear dyear)  →  b = " %9.4f _b[`rv'] "   SE = " %9.4f _se[`rv']
    }
    else {
        display "        vce(cluster oyear dyear)  →  SE 数值退化（非正定），改报单向聚类："
        capture quietly reghdfe `dv' `rv' [aw=n_od] `cd', absorb(oyear dyear) vce(cluster oyear)
        if _rc == 0 capture display "          vce(cluster oyear)  →  b = " %9.4f _b[`rv'] "   SE = " %9.4f _se[`rv']
        capture quietly reghdfe `dv' `rv' [aw=n_od] `cd', absorb(oyear dyear) vce(cluster dyear)
        if _rc == 0 capture display "          vce(cluster dyear)  →  b = " %9.4f _b[`rv'] "   SE = " %9.4f _se[`rv']
        capture quietly reghdfe `dv' `rv' [aw=n_od] `cd', absorb(oyear dyear) vce(robust)
        if _rc == 0 capture display "          vce(robust)         →  b = " %9.4f _b[`rv'] "   SE = " %9.4f _se[`rv']
    }
}

*==============================================================================
* 7. 结果表
*==============================================================================
display _n(2) "{hline 88}"
display "  7. 复现结果汇总表"
display "{hline 88}"
display ""
display "                    (1)ln p     (2)ln w     (3)ln w     (3)ln w     (4)ln w"
display "                     ln_dist     ln_dist     ln_dist     ln_p        ln_p"
display "  " "{hline 82}"
display "  本复现            " %9.4f RES[1,1] "  " %9.4f RES[2,1] "  " %9.4f RES[3,1] "  " %9.4f RES[4,1] "  " %9.4f RES[5,1]
display "  本复现 SE         " %9.4f RES[1,2] "  " %9.4f RES[2,2] "  " %9.4f RES[3,2] "  " %9.4f RES[4,2] "  " %9.4f RES[5,2]
display "  JPE 论文          " %9.3f -0.553 "  " %9.3f 0.023 "  " %9.3f -0.004 "  " %9.3f -0.043 "  " %9.3f -0.050
display "  JPE 论文 SE       " %9.3f 0.018 "  " %9.3f 0.002 "  " %9.3f 0.004 "  " %9.3f 0.003 "  " %9.3f 0.006
display "  "
display "  论文个体数        2,294,054   2,294,046   2,294,046   2,294,046   2,294,046"
display "  论文州对数        5,084       5,076       5,076       5,076       5,076"

display _n(2) "{hline 88}"
display "  运行结束：$S_DATE $S_TIME"
display "{hline 88}"
log close