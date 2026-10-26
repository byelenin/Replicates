*==============================================================================
*  微观计量 课程作业 —— 论文复现【拓展分析】
*------------------------------------------------------------------------------
*  论文 : Bryan, G. and M. Morten (2019), "The Aggregate Productivity Effects
*         of Internal Migration: Evidence from Indonesia",
*         Journal of Political Economy, 127(5), 2229-2268.
*
*  内容 : 印尼【省级】迁移的五项事实 —— 1976 年 与 1995 年 两期对比
*
*  作者 : 陈冠宇、任娜、冯诗语
*  日期 : 2026-10-29
*  软件 : Stata 19
*  数据 : D:\研一上\微观计量\ipumsi_00003.dta  (Indonesia 1976)
*         D:\研一上\微观计量\ipumsi_00002.dta  (Indonesia 1995)
*         省级距离矩阵：D:\研一上\微观计量\复现\idn_prov_dist25.csv
*  输出 : 本目录下 province_two_period.log
*------------------------------------------------------------------------------
*  【重要】本文件是拓展分析，不是论文表格的复现。
*
*  论文 Appendix Table 4 是省级版本，数据为 1995、2011、2012 三年 SUSENAS。
*  1976 年不在论文使用的年份内，故本文件属于在论文框架下做的【向前延伸】。
*
*  论文 Appendix Table 4 报告值（1995+2011+2012 合并）：
*       (1) ln π 对 ln 距离 = -0.606 (0.013)***   N = 1,452
*       (2) ln w 对 ln 距离 =  0.041 (0.003)***   N = 1,444
*       (3) ln w 对 ln π    = -0.066 (0.005)***   N = 1,444
*       (4) ln w 对 ln π    = -0.036 (0.012)***   N = 1,444
*           ln w 对 ln 距离 =  0.019 (0.009)**
*       (5) Amenities       = -0.059 (0.074)      N = 1,444
*------------------------------------------------------------------------------
*  为什么只能做省级，不能做县级：
*
*  1976 年文件的出生地变量是 bplid = "province of birth"（省级，28 个取值），
*  而 1995 年文件另有 id1995a_bplreg = "regency/municipality of birth"（县级）。
*  1976 没有出生【县】，无法区分"省内跨县搬家"与"没搬家"，
*  因此论文 Table 1、Table 2 的县级结果无法用 1976 年数据复现。
*
*  两期共有的省份 = 16 个（数据的地理覆盖不同，必须取交集）：
*       苏门答腊  11-18
*       爪哇      31-35
*       巴厘与努沙登加拉 51-53
*  1976 另有加里曼丹(61-64)、苏拉威西(71-74)、马鲁古(81)、巴布亚(94)；
*  1995 的 IPUMS 样本缺失上述省份（加权人口仅为当年全国的约 86%）。
*
*  说明：本文件不修改、不覆盖任何原始数据文件。
*==============================================================================

*------------------------------------------------------------------------------
*  0. 运行环境与日志
*------------------------------------------------------------------------------
clear all
set more off
capture log close _all

local root "D:\研一上\微观计量"
log using "`root'\复现\province_two_period.log", replace text

display _n "================ 运行信息 ================"
display "运行时间  : $S_DATE $S_TIME"
display "Stata 版本: `c(stata_version)'"
display "1976 数据 : `root'\ipumsi_00003.dta"
display "1995 数据 : `root'\ipumsi_00002.dta"

*------------------------------------------------------------------------------
*  1. 省级距离矩阵
*     idn_prov_dist25.csv 为长表 o,d,dist_km，省码 11-81
*------------------------------------------------------------------------------
import delimited "`root'\复现\idn_prov_dist25.csv", clear varnames(1)
quietly count
local Ndist = r(N)
tempfile f_pdist
save "`f_pdist'", replace

display _n "================ 省级距离矩阵 ================"
display "OD 省对数            : " %10.0fc `Ndist'

*==============================================================================
*  2. 构建 1976 年省级 OD 面板
*==============================================================================
display _n(2) "=============================================================="
display       " 构建 1976 年省级 OD 面板"
display       "=============================================================="

use year bplid geo1_id incwage perwt relate sex age using "`root'\ipumsi_00003.dta", clear
keep if year == 1976

quietly count
local N76raw = r(N)

* 出生省 = bplid；现居省 = geo1_id - 360000（geo1_id 形如 360011 → 省 11）
gen int o = bplid
gen int d = geo1_id - 360000

* 只保留合法省码，剔除 98/99（其他/未知）
drop if !inrange(o,11,94) | !inrange(d,11,94)
drop if o == 98 | o == 99

quietly count
local N76ok = r(N)

* ---- 省际终身迁移率（个体层面，加权）----
gen byte moved_prov = (o != d)
quietly summarize perwt if moved_prov == 1
local mv1 = r(sum)
quietly summarize perwt
local tp1 = r(sum)
global rate76 = `mv1'/`tp1'*100
global pop76  = `tp1'

display "1976 原始记录数        : " %12.0fc `N76raw'
display "1976 有效省码记录数    : " %12.0fc `N76ok'
display "1976 省际终身迁移率    : " %8.2f $rate76 "%（加权）"

* ---- 一次性构造两套加权和，避免反复 preserve/restore ----
gen byte validw = (incwage > 0 & incwage < 9999990)
gen byte mh     = (relate == 1 & sex == 1 & age >= 15 & age <= 65)

gen double w_all  = perwt
gen double w_mh   = perwt*mh
gen double nw_all = perwt*validw
gen double nw_mh  = perwt*validw*mh
gen double ww_all = perwt*validw*incwage
gen double ww_mh  = perwt*validw*mh*incwage

collapse (sum) w_all w_mh nw_all nw_mh ww_all ww_mh, by(o d)

bysort o: egen double to_all = total(w_all)
bysort o: egen double to_mh  = total(w_mh)

gen double p_all    = w_all/to_all
gen double p_mh     = w_mh/to_mh
gen double wage_all = ww_all/nw_all
gen double wage_mh  = ww_mh/nw_mh
gen int year = 1976

merge 1:1 o d using "`f_pdist'", keep(master match)
keep if _merge == 3
drop _merge

gen double ln_p       = ln(p_all)
gen double ln_p_mh    = ln(p_mh)
gen double ln_wage    = ln(wage_all)
gen double ln_wage_mh = ln(wage_mh)
gen double ln_dist    = ln(dist_km)

tempfile f_76
save "`f_76'", replace

quietly count
display "1976 可用 OD 省对数    : " %12.0fc r(N)

*==============================================================================
*  3. 构建 1995 年省级 OD 面板
*==============================================================================
display _n(2) "=============================================================="
display       " 构建 1995 年省级 OD 面板"
display       "=============================================================="

use year bplid geo1_id incwage perwt relate sex age using "`root'\ipumsi_00002.dta", clear
keep if year == 1995

quietly count
local N95raw = r(N)

gen int o = bplid
gen int d = geo1_id - 360000

drop if !inrange(o,11,94) | !inrange(d,11,94)
drop if o == 98 | o == 99

quietly count
local N95ok = r(N)

gen byte moved_prov = (o != d)
quietly summarize perwt if moved_prov == 1
local mv2 = r(sum)
quietly summarize perwt
local tp2 = r(sum)
global rate95 = `mv2'/`tp2'*100
global pop95  = `tp2'

display "1995 原始记录数        : " %12.0fc `N95raw'
display "1995 有效省码记录数    : " %12.0fc `N95ok'
display "1995 省际终身迁移率    : " %8.2f $rate95 "%（加权）"

gen byte validw = (incwage > 0 & incwage < 9999990)
gen byte mh     = (relate == 1 & sex == 1 & age >= 15 & age <= 65)

gen double w_all  = perwt
gen double w_mh   = perwt*mh
gen double nw_all = perwt*validw
gen double nw_mh  = perwt*validw*mh
gen double ww_all = perwt*validw*incwage
gen double ww_mh  = perwt*validw*mh*incwage

collapse (sum) w_all w_mh nw_all nw_mh ww_all ww_mh, by(o d)

bysort o: egen double to_all = total(w_all)
bysort o: egen double to_mh  = total(w_mh)

gen double p_all    = w_all/to_all
gen double p_mh     = w_mh/to_mh
gen double wage_all = ww_all/nw_all
gen double wage_mh  = ww_mh/nw_mh
gen int year = 1995

merge 1:1 o d using "`f_pdist'", keep(master match)
keep if _merge == 3
drop _merge

gen double ln_p       = ln(p_all)
gen double ln_p_mh    = ln(p_mh)
gen double ln_wage    = ln(wage_all)
gen double ln_wage_mh = ln(wage_mh)
gen double ln_dist    = ln(dist_km)

tempfile f_95
save "`f_95'", replace

quietly count
display "1995 可用 OD 省对数    : " %12.0fc r(N)

*==============================================================================
*  4. 合并两期，并限制在两期共有的 16 个省
*==============================================================================
use "`f_76'", clear
append using "`f_95'"

quietly count
local Npool_raw = r(N)

* 两期共有省份：11-18（苏门答腊）、31-35（爪哇）、51-53（巴厘与努沙登加拉）
keep if inrange(o,11,18) | inrange(o,31,35) | inrange(o,51,53)
keep if inrange(d,11,18) | inrange(d,31,35) | inrange(d,51,53)

quietly count
local Npool = r(N)
quietly levelsof o, local(plist)
local nprov : word count `plist'

* 剔除对角线（dist = 0，ln_dist 缺失）
keep if !missing(ln_dist)

egen long oy = group(o year)
egen long dy = group(d year)

display _n "================ 合并后面板 ================"
display "合并（未限省份）OD 省对数 : " %10.0fc `Npool_raw'
display "限制为共有 16 省后         : " %10.0fc `Npool'
display "省份数                     : " %10.0fc `nprov'
quietly count
display "剔除对角线后可用于回归     : " %10.0fc r(N)

display _n "--- 关键变量描述统计 ---"
summarize p_all wage_all dist_km ln_p ln_wage ln_dist, sep(0)

*==============================================================================
*  5. 回归：两期合并（对应论文 Appendix Table 4 的设定，但只有 2 个年份）
*     absorb(oy dy) = 出生省×年份 + 现居省×年份 固定效应
*     cluster(oy dy) = 双向聚类（论文口径）
*==============================================================================
display _n(2) "=============================================================="
display       " 两期合并回归（16 省 × 2 年）"
display       "=============================================================="

display _n "===== (1) Fact 1 引力方程   论文 = -0.606 ====="
reghdfe ln_p ln_dist, absorb(oy dy) cluster(oy dy)
local pb1 = _b[ln_dist]
local ps1 = _se[ln_dist]
local pn1 = e(N)

display _n "===== (2) Fact 2 工资楔子   论文 =  0.041 ====="
reghdfe ln_wage ln_dist, absorb(oy dy) cluster(oy dy)
local pb2 = _b[ln_dist]
local ps2 = _se[ln_dist]
local pn2 = e(N)

display _n "===== (3) Fact 3 选择       论文 = -0.066 ====="
reghdfe ln_wage ln_p, absorb(oy dy) cluster(oy dy)
local pb3 = _b[ln_p]
local ps3 = _se[ln_p]
local pn3 = e(N)

display _n "===== (4) Fact 4 联合       论文 = -0.036 / 0.019 ====="
reghdfe ln_wage ln_p ln_dist, absorb(oy dy) cluster(oy dy)
local pb4p = _b[ln_p]
local ps4p = _se[ln_p]
local pb4d = _b[ln_dist]
local ps4d = _se[ln_dist]
local pn4 = e(N)

*==============================================================================
*  6. 回归：分年份
*==============================================================================
display _n(2) "=============================================================="
display       " 分年份回归（单年，故退化为 absorb(o d) cluster(o d)）"
display       "=============================================================="

foreach yy in 1976 1995 {
    display _n "===================== `yy' 年 ====================="

    display _n "--- (1) Fact 1  ln π 对 ln 距离 ---"
    reghdfe ln_p ln_dist if year == `yy', absorb(o d) cluster(o d)
    local b1_`yy' = _b[ln_dist]
    local s1_`yy' = _se[ln_dist]
    local n1_`yy' = e(N)

    display _n "--- (2) Fact 2  ln w 对 ln 距离 ---"
    reghdfe ln_wage ln_dist if year == `yy', absorb(o d) cluster(o d)
    local b2_`yy' = _b[ln_dist]
    local s2_`yy' = _se[ln_dist]
    local n2_`yy' = e(N)

    display _n "--- (3) Fact 3  ln w 对 ln π ---"
    reghdfe ln_wage ln_p if year == `yy', absorb(o d) cluster(o d)
    local b3_`yy' = _b[ln_p]
    local s3_`yy' = _se[ln_p]
    local n3_`yy' = e(N)

    display _n "--- (4) Fact 4  ln w 对 ln π 与 ln 距离 ---"
    reghdfe ln_wage ln_p ln_dist if year == `yy', absorb(o d) cluster(o d)
    local b4p_`yy' = _b[ln_p]
    local s4p_`yy' = _se[ln_p]
    local b4d_`yy' = _b[ln_dist]
    local s4d_`yy' = _se[ln_dist]
    local n4_`yy' = e(N)
}

*==============================================================================
*  7. 稳健性：男性户主 15-65 岁、按单元人数加权（两期合并）
*==============================================================================
display _n(2) "=============================================================="
display       " 稳健性：男性户主 15-65 岁，按单元人数加权（两期合并）"
display       "=============================================================="

display _n "--- (1) Fact 1 加权 ---"
reghdfe ln_p_mh ln_dist [aw = w_mh], absorb(oy dy) cluster(oy)
local rb1 = _b[ln_dist]

display _n "--- (2) Fact 2 加权 ---"
reghdfe ln_wage_mh ln_dist [aw = nw_mh], absorb(oy dy) cluster(oy)
local rb2 = _b[ln_dist]

display _n "--- (3) Fact 3 加权 ---"
reghdfe ln_wage_mh ln_p_mh [aw = nw_mh], absorb(oy dy) cluster(oy)
local rb3 = _b[ln_p_mh]

display _n "--- (4) Fact 4 加权 ---"
reghdfe ln_wage_mh ln_p_mh ln_dist [aw = nw_mh], absorb(oy dy) cluster(oy)
local rb4p = _b[ln_p_mh]
local rb4d = _b[ln_dist]

*==============================================================================
*  8. 结果汇总
*==============================================================================
matrix PL = J(6, 4, .)
matrix colnames PL = Fact1 Fact2 Fact3 Fact4
matrix rownames PL = DistPaper DistOurs DistSE MigPaper MigOurs MigSE

matrix PL[1,1] = -0.606
matrix PL[1,2] =  0.041
matrix PL[1,4] =  0.019
matrix PL[2,1] = `pb1'
matrix PL[2,2] = `pb2'
matrix PL[2,4] = `pb4d'
matrix PL[3,1] = `ps1'
matrix PL[3,2] = `ps2'
matrix PL[3,4] = `ps4d'
matrix PL[4,3] = -0.066
matrix PL[4,4] = -0.036
matrix PL[5,3] = `pb3'
matrix PL[5,4] = `pb4p'
matrix PL[6,3] = `ps3'
matrix PL[6,4] = `ps4p'

matrix BY = J(5, 4, .)
matrix colnames BY = Fact1 Fact2 Fact3 Fact4
matrix rownames BY = Paper Dist1976 Dist1995 Mig1976 Mig1995

matrix BY[1,1] = -0.606
matrix BY[1,2] =  0.041
matrix BY[1,4] =  0.019
matrix BY[2,1] = `b1_1976'
matrix BY[2,2] = `b2_1976'
matrix BY[2,4] = `b4d_1976'
matrix BY[3,1] = `b1_1995'
matrix BY[3,2] = `b2_1995'
matrix BY[3,4] = `b4d_1995'
matrix BY[4,3] = `b3_1976'
matrix BY[4,4] = `b4p_1976'
matrix BY[5,3] = `b3_1995'
matrix BY[5,4] = `b4p_1995'

matrix NN = J(2, 4, .)
matrix colnames NN = Fact1 Fact2 Fact3 Fact4
matrix rownames NN = Paper Ours
matrix NN[1,1] = 1452
matrix NN[1,2] = 1444
matrix NN[1,3] = 1444
matrix NN[1,4] = 1444
matrix NN[2,1] = `pn1'
matrix NN[2,2] = `pn2'
matrix NN[2,3] = `pn3'
matrix NN[2,4] = `pn4'

display _n(2) "=============================================================================="
display       "  省级两期分析结果（1976 + 1995，16 个共有省份）"
display       "=============================================================================="
display       "  对照对象：论文 Appendix Table 4（省级，1995+2011+2012 三年合并）"

display _n "【两期合并】16 省 × 2 年，absorb(oy dy)，cluster(oy dy)"
matlist PL, border(rows) left(14) format(%9.3f)

display _n "【样本量】"
matlist NN, border(rows) left(14) format(%9.0f)

display _n "【分年份】单年 absorb(o d)，cluster(o d)"
matlist BY, border(rows) left(14) format(%9.3f)

display _n "【省际终身迁移率（加权）】"
display "  1976 年 : " %8.2f $rate76 "%      加权人口 " %12.0fc $pop76
display "  1995 年 : " %8.2f $rate95 "%      加权人口 " %12.0fc $pop95
display "  变化    : " %8.2f ($rate95 - $rate76) " 个百分点"

display _n "【稳健性】男性户主 15-65 岁、按单元人数加权（两期合并）"
display "  Fact 1  ln π 对 ln 距离 : " %8.3f `rb1'
display "  Fact 2  ln w 对 ln 距离 : " %8.3f `rb2'
display "  Fact 3  ln w 对 ln π    : " %8.3f `rb3'
display "  Fact 4  ln w 对 ln π    : " %8.3f `rb4p'
display "          ln w 对 ln 距离 : " %8.3f `rb4d'

display _n "=============================================================================="
display    "  注：Dist = ln 距离的系数；Mig = ln 迁移份额的系数。"
display    "      论文第 (5) 列 Amenities 需要 PODES 设施数据，无法复现。"
display    "=============================================================================="

*==============================================================================
*  9. 说明
*==============================================================================
display _n(2) "================ 分析说明 ================"
display "1. 本文件是【拓展分析】，不是论文表格的复现。论文 Appendix Table 4 使用"
display "   1995、2011、2012 三年；1976 年不在论文使用的年份内。"
display "2. 为什么只能做省级：1976 文件的出生地变量 bplid 为 province of birth，"
display "   只有省级；1995 文件另有 id1995a_bplreg（regency of birth）才是县级。"
display "   1976 缺出生县，无法区分省内跨县迁移与未迁移，故 Table 1、Table 2 的"
display "   县级结果无法用 1976 数据复现。"
display "3. 省份取交集：两期共有的省份只有 16 个（苏门答腊 11-18、爪哇 31-35、"
display "   巴厘与努沙登加拉 51-53）。1976 另有加里曼丹(61-64)、苏拉威西(71-74)、"
display "   马鲁古(81)、巴布亚(94)，而 1995 的 IPUMS 样本缺失这些省份。"
display "4. 固定效应：两期合并用 absorb(oy dy)（出生省×年份 + 现居省×年份），"
display "   对应论文 Appendix Table 4 的 Origin x Year 与 Destination x Year。"
display "5. 聚类：两期合并用 cluster(oy dy) 双向聚类；分年份时单年退化为"
display "   cluster(o d)。加权稳健性一栏因双向聚类与双向固定效应共线，改为 cluster(oy)。"
display "6. 样本量差异：论文 N = 1,452 / 1,444 来自 25 个省 × 3 个年份；"
display "   本分析为 16 个省 × 2 个年份，故 N 更小。"
display "7. 工资口径：1976 与 1995 的名义工资水平差异极大（1976 年中位数约 1 万盾，"
display "   1995 年约 20 万盾），但回归使用对数且含双向固定效应，水平差异会被吸收；"
display "   跨年比较系数时应注意到这一点。"
display "=========================================="

log close