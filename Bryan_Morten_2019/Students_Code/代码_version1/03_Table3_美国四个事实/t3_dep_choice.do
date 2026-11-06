*==============================================================================
* t3_dep_choice.do —— 为什么用「平均工资」而不是「每个人的工资」？
*   检验一：个人层面回归 ≡ 单元格均值回归（按 n_od 加权）—— 数学恒等式
*   检验二：论文口径 ln(平均工资) vs 个人口径 平均(ln工资) 会不会给出不同答案
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "t3_dep_choice_out.log", replace text

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

*==============================================================================
* 单元格：同时造两个因变量
*   ln_mean = ln( Σw·wage / Σw )   ← 论文口径「平均工资的对数」
*   mean_ln = Σw·ln(wage) / Σw     ← 个人口径「工资对数的平均」
*==============================================================================
insheet using "`root'\usa_od.csv", clear
gen double hasw  = !missing(wage) & wage > 0
gen double m_w   = w
gen double n_w   = 1
gen double nw_w  = 1 if hasw
gen double wx_w  = w*wage      if hasw
gen double wg_w  = w           if hasw
gen double wln_w = w*ln(wage)  if hasw & wage > 0
gen double sln_w = ln(wage)    if hasw & wage > 0
collapse (sum) m_w n_w nw_w wx_w wg_w wln_w sln_w, by(o d year)
rename m_w m_od
rename n_w n_od
rename nw_w nw_od
gen double wage_bar = wx_w/wg_w         if wg_w > 0 & !missing(wg_w)
gen double ln_mean  = ln(wage_bar)      if wage_bar > 0 & !missing(wage_bar)
gen double mean_ln  = wln_w/wg_w        if wg_w > 0 & !missing(wg_w)
* mlu_od = 格内 ln(工资) 的【未加权】平均 —— 这才是「每人一票」个人回归的等价对象
gen double mlu_od   = sln_w/nw_od       if nw_od > 0 & !missing(nw_od)
bysort o year: egen double pop_o = total(m_od)
gen double pi_od = m_od/pop_o
gen double ln_p  = ln(pi_od) if pi_od > 0
drop if o == d
sort o d
merge m:1 o d using `usdist', keep(match) nogen
gen double ln_dist = ln(dist_km)
gen double oyear = o*10000 + year
gen double dyear = d*10000 + year

display _n(2) "{hline 88}"
display "  两个因变量到底差多少？（同一个州对）"
display "{hline 88}"
display "  ln(平均工资) 与 平均(ln工资) 的差 = 该格内 ln工资 的方差（Jensen）"
quietly summarize ln_mean
local a1 = r(mean)
quietly summarize mean_ln
local a2 = r(mean)
gen double gap = ln_mean - mean_ln
quietly summarize gap
display "    ln_mean 均值 = " %10.6f `a1' "    mean_ln 均值 = " %10.6f `a2'
display "    差值(gap) 均值 = " %10.6f r(mean) "   标准差 = " %10.6f r(sd) "   最小 " %8.4f r(min) "  最大 " %8.4f r(max)
display "    ⇒ 两者【不相等】，差多少取决于格内工资离散度"

tempfile cells
save `cells'

*==============================================================================
display _n(2) "{hline 88}"
display "  检验一：个人层面回归 是不是 等于 单元格回归（按 n_od 加权）？"
display "{hline 88}"
display "  自变量（距离、份额）在同一个州对内是【常数】⇒ 个人层面只是把每行复制 n_od 遍"

display _n "  ── 个人层面：918,748 个人，每人一个 ln(自己的工资)，不加权 ──"
insheet using "`root'\usa_od.csv", clear
keep o d year wage
drop if o == d
gen double lnw = ln(wage) if !missing(wage) & wage > 0
drop if missing(lnw)
sort o d year
merge m:1 o d year using `cells', keep(match) nogen
quietly count
display "     个体观测数 = " %12.0fc r(N)
quietly reghdfe lnw ln_dist, absorb(oyear dyear) vce(cluster oyear dyear)
local IND = _b[ln_dist]
display "     β = " %12.6f `IND'

display _n "  ── 单元格层面：因变量换成 mlu_od（格内 ln 工资的【未加权】平均），按 nw_od 加权 ──"
use `cells', clear
quietly reghdfe mlu_od ln_dist [aw=nw_od], absorb(oyear dyear) vce(cluster oyear dyear)
local CEL = _b[ln_dist]
display "     β = " %12.6f `CEL'
display "     ⇒ 与个人层面之差 = " %12.2e abs(`IND'-`CEL')

*==============================================================================
display _n(2) "{hline 88}"
display "  检验二：论文口径（ln 平均工资）vs 个人口径（平均 ln 工资）"
display "{hline 88}"
use `cells', clear
display "  " "{hline 70}"
display "  因变量                       论文口径 ln_mean   个人口径 mean_ln      差"
display "  " "{hline 70}"
* (2) 距离
quietly reghdfe ln_mean ln_dist [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
local d1 = _b[ln_dist]
quietly reghdfe mean_ln ln_dist [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
local d2 = _b[ln_dist]
display "  " %-28s "(2) ln w ← ln_dist" "  " %10.4f `d1' "      " %10.4f `d2' "    " %8.4f (`d2'-`d1')
* (3) 份额
quietly reghdfe ln_mean ln_p [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
local s1 = _b[ln_p]
quietly reghdfe mean_ln ln_p [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
local s2 = _b[ln_p]
display "  " %-28s "(3) ln w ← ln_p" "  " %10.4f `s1' "      " %10.4f `s2' "    " %8.4f (`s2'-`s1')
* (4) 同场
quietly reghdfe ln_mean ln_dist ln_p [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
local f1 = _b[ln_dist]
local g1 = _b[ln_p]
quietly reghdfe mean_ln ln_dist ln_p [aw=n_od], absorb(oyear dyear) vce(cluster oyear dyear)
local f2 = _b[ln_dist]
local g2 = _b[ln_p]
display "  " %-28s "(4) ln w ← 两者  dist" "  " %10.4f `f1' "      " %10.4f `f2' "    " %8.4f (`f2'-`f1')
display "  " %-28s "(4)               share" "  " %10.4f `g1' "      " %10.4f `g2' "    " %8.4f (`g2'-`g1')
display "  " "{hline 70}"

display _n "  论文报的数（JPE 表 3）：  (2) .023   (3) -.043   (4) dist -.004 / share -.050"

display _n(2) "{hline 88}"
display "  结束：$S_DATE $S_TIME"
log close