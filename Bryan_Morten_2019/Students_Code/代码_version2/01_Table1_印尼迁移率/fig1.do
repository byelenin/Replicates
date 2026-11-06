*==============================================================
* Figure 1 复现：Distribution of wages: regency level
*   论文原文："kernel density plots of the log of the average monthly
*            wage, calculated at the regency level and broken down by
*            rural/urban status"
*   观测单位：regency（县）—— 每个县一个点，不加权
*   数据来源：1995 SUPAS（论文还有 2011/2012 SUSENAS，IPUMS 没有）
*==============================================================
clear all
set more off
capture log close
cd "D:\研一上\微观计量\复现"
log using "fig1_out.log", replace text

*---- 1. 载入 1995 年数据 ----
use year geo2_id1995 incwage perwt urban using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count

*---- 2. 县级农村人口占比（用【全部人】算，不能只用有工资的人）----
bysort geo2_id1995: egen double tot_pop = total(perwt)
bysort geo2_id1995: egen double rur_pop = total((urban==1)*perwt)
gen double rshare = rur_pop/tot_pop

*---- 3. 县级平均月工资（只用【有有效工资】的人算）----
*   incwage 的缺失码：9999998 = UNKNOWN, 9999999 = NIU（未问）
gen double ww = perwt*incwage if incwage > 0 & incwage < 9999990
gen double wp = perwt         if incwage > 0 & incwage < 9999990
bysort geo2_id1995: egen double sum_w  = total(wp)
bysort geo2_id1995: egen double sum_ww = total(ww)
gen double wage_reg = sum_ww/sum_w
gen double ln_wage  = ln(wage_reg)

*---- 4. 每个县只留一行 ----
duplicates drop geo2_id1995, force
count
display "有工资数据、且农民工数>0 的县数 = " r(N)

*---- 5. 按中位数规则分农村县/城市县 ----
summarize rshare, detail
local med = r(p50)
display "县级农村占比中位数 = " `med'
gen byte o_rural = (rshare > `med')
tab o_rural

*---- 6. 看三个密度的大致分布 ----
display _n "==== 对数平均工资的描述统计 ===="
summarize ln_wage, detail
display "--- 城市县 ---"
summarize ln_wage if o_rural == 0, detail
display "--- 农村县 ---"
summarize ln_wage if o_rural == 1, detail

*---- 7. 画核密度图（三条曲线叠在一起）----
twoway (kdensity ln_wage if o_rural == 0) (kdensity ln_wage if o_rural == 1) (kdensity ln_wage), legend(order(1 "Urban" 2 "Rural" 3 "All") rows(1)) xtitle("log average monthly wage") ytitle("Kernel density") title("Figure 1: Distribution of wages, regency level (1995)")

*---- 8. 存成图片，方便放进 PPT ----
graph export "fig1_1995.png", replace width(1800)

log close