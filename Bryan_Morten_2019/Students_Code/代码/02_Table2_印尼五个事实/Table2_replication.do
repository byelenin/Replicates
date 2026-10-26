*==============================================================================
*  微观计量 课程作业 —— 论文复现
*------------------------------------------------------------------------------
*  论文 : Bryan, G. and M. Morten (2019), "The Aggregate Productivity Effects
*         of Internal Migration: Evidence from Indonesia",
*         Journal of Political Economy, 127(5), 2229-2268.
*
*  复现 : Table 2 —— Five facts about migration in Indonesia
*
*  作者 : 陈冠宇、任娜、冯诗语
*  日期 : 2026-10-29
*  软件 : Stata 19
*  数据 : IPUMS International, Indonesia 1995
*         D:\研一上\微观计量\ipumsi_00002.dta
*         距离矩阵：D:\研一上\微观计量\复现\idn_regency_dist.csv
*  输出 : 本目录下 table2_replication.log
*------------------------------------------------------------------------------
*  论文 Table 2 口径说明（均可追溯至论文原文）：
*
*   [1] 观测单位 = 一个「出生县 o × 现居县 d」对          (Table 2 注释)
*
*   [2] 两个因变量：
*         log π_odt = 出生在 o、现居在 d 的人口占 o 县总人口的比例
*         log w_odt = 从 o 迁到 d 的迁移者的平均工资       (Table 2 注释)
*
*   [3] 固定效应 = Destination × Year 与 Origin × Year     (Table 2 面板)
*       本文件只有 1995 一年，故退化为 Destination FE + Origin FE
*
*   [4] 标准误 = origin-year 与 destination-year 双向聚类   (Table 2 注释)
*       单年情形下即 cluster(o d)
*
*   [5] 距离 = 出生县与现居县质心的直线距离，取对数        (论文脚注 9)
*
*   [6] 数据年份 = 1995 SUSENAS、2011 SUSENAS、2012 SUSENAS (Table 2 注释)
*       IPUMS International 未提供 2011、2012 年，故本文件仅复现 1995 年
*
*   [7] 第 (5) 列 Amenities = 6 项设施指标第一主成分的标准化值
*       需要 PODES 数据，IPUMS 不提供 —— 该列无法复现
*
*  论文 Table 2 报告值（1995+2011+2012 三年合并）：
*       (1) ln π 对 ln 距离 = -0.717 (0.009)***   N = 25,540
*       (2) ln w 对 ln 距离 =  0.029 (0.001)***   N = 25,244
*       (3) ln w 对 ln π    = -0.039 (0.001)***   N = 25,244
*       (4) ln w 对 ln π    = -0.031 (0.003)***
*           ln w 对 ln 距离 =  0.007 (0.002)***   N = 25,244
*       (5) Amenities       = -0.023 (0.010)**    N = 25,050
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
log using "`root'\复现\table2_replication.log", replace text

display _n "================ 运行信息 ================"
display "运行时间  : $S_DATE $S_TIME"
display "Stata 版本: `c(stata_version)'"
display "数据文件  : `root'\ipumsi_00002.dta"

*------------------------------------------------------------------------------
*  1. 距离矩阵：CSV 转 Stata 格式
*     （merge 只能并 Stata 格式文件，不能直接并 CSV）
*------------------------------------------------------------------------------
import delimited "`root'\复现\idn_regency_dist.csv", clear varnames(1)

quietly count
local Ndist = r(N)
quietly summarize dist_km
local dmin = r(min)
local dmax = r(max)

tempfile f_dist
save "`f_dist'", replace

display _n "================ 距离矩阵 ================"
display "OD 对数              : " %10.0fc `Ndist'
display "距离范围（公里）     : " %8.2f `dmin' "  ~  " %8.2f `dmax'

*------------------------------------------------------------------------------
*  2. 读入 1995 年微观数据
*------------------------------------------------------------------------------
use year geo2_id1995 id1995a_bplreg incwage perwt relate sex age using "`root'\ipumsi_00002.dta", clear

keep if year == 1995

quietly count
local N1995 = r(N)

display _n "================ 数据检查 ================"
display "1995 年全部人口记录数 : " %12.0fc `N1995'

*------------------------------------------------------------------------------
*  3. 县码统一到同一编码空间
*     出生县 id1995a_bplreg 形如 1101（4 位）
*     现居县 geo2_id1995    形如 11001（5 位）
*     转换公式：int(x/100)*1000 + mod(x,100)
*------------------------------------------------------------------------------
gen long o = int(id1995a_bplreg/100)*1000 + mod(id1995a_bplreg,100)
gen long d = geo2_id1995

label var o "出生县（5 位码）"
label var d "现居县（5 位码）"

*------------------------------------------------------------------------------
*  4. π_od：迁移份额
*     分子 = 出生在 o、现居在 d 的加权人数
*     分母 = 出生在 o 的加权人数
*     论文未写明样本限制，故同时造两套：全部人 / 男性户主 15-65 岁
*------------------------------------------------------------------------------
display _n "===== 4a. π_od（全部人）====="
preserve
    collapse (sum) n = perwt, by(o d)
    bysort o: egen double n_o = total(n)
    gen double p_od = n / n_o
    bysort o: egen double chk = total(p_od)
    quietly summarize chk
    display "  【自检】π_od 按出生县加总：最小 = " %9.6f r(min) "   最大 = " %9.6f r(max)
    display "         （应恒等于 1）"
    keep o d p_od n
    tempfile f_pi_all
    save "`f_pi_all'"
restore

display _n "===== 4b. π_od（男性户主 15-65 岁）====="
preserve
    keep if relate == 1 & sex == 1 & age >= 15 & age <= 65
    quietly count
    display "  男性户主 15-65 岁人数 : " %10.0fc r(N)
    collapse (sum) n = perwt, by(o d)
    bysort o: egen double n_o = total(n)
    gen double p_od_mh = n / n_o
    rename n n_mh
    keep o d p_od_mh n_mh
    tempfile f_pi_mh
    save "`f_pi_mh'"
restore

*------------------------------------------------------------------------------
*  5. w_od：平均月工资
*     分子 = Σ(perwt × incwage)，分母 = Σperwt
*     incwage 缺失码：9999998 = UNKNOWN，9999999 = NIU（没被问过）
*------------------------------------------------------------------------------
display _n "===== 5a. wage_od（全部有工资的人）====="
preserve
    keep if incwage > 0 & incwage < 9999990
    quietly count
    display "  有有效工资的人数 : " %10.0fc r(N)
    gen double ww = perwt * incwage
    collapse (sum) ww perwt, by(o d)
    rename perwt n_wage
    gen double wage_od = ww / n_wage
    keep o d wage_od n_wage
    tempfile f_w_all
    save "`f_w_all'"
restore

display _n "===== 5b. wage_od（男性户主 15-65 岁）====="
preserve
    keep if incwage > 0 & incwage < 9999990
    keep if relate == 1 & sex == 1 & age >= 15 & age <= 65
    quietly count
    display "  有有效工资的男性户主 15-65 岁 : " %10.0fc r(N)
    gen double ww = perwt * incwage
    collapse (sum) ww perwt, by(o d)
    rename perwt n_wage_mh
    gen double wage_od_mh = ww / n_wage_mh
    keep o d wage_od_mh n_wage_mh
    tempfile f_w_mh
    save "`f_w_mh'"
restore

*------------------------------------------------------------------------------
*  6. 合并四张表（π 两张 + 工资两张）
*     π_od 全部人那张作主表：所有出现过迁移流的 (o,d) 对
*------------------------------------------------------------------------------
use "`f_pi_all'", clear
merge 1:1 o d using "`f_pi_mh'",  nogen
merge 1:1 o d using "`f_w_all'", nogen
merge 1:1 o d using "`f_w_mh'",  nogen

quietly count
local Ncell = r(N)
quietly count if missing(wage_od)
local Nnowage = r(N)

display _n "================ 合并结果 ================"
display "OD 单元数                     : " %10.0fc `Ncell'
display "其中【无工资观测】的单元数     : " %10.0fc `Nnowage'
display "  （论文表注：'not all pairs with positive migration flows have observed wages'）"

*------------------------------------------------------------------------------
*  7. 合并距离
*     论文脚注 9：出生县与现居县质心的直线距离
*------------------------------------------------------------------------------
merge 1:1 o d using "`f_dist'", keep(master match)
quietly count if _merge == 1
local Nomiss = r(N)
keep if _merge == 3
drop _merge

*------------------------------------------------------------------------------
*  8. 造对数变量
*     注意：o == d 时 dist_km = 0，ln(0) 缺失 —— 对角线会自动被剔除
*------------------------------------------------------------------------------
gen double ln_p        = ln(p_od)
gen double ln_p_mh     = ln(p_od_mh)
gen double ln_wage     = ln(wage_od)
gen double ln_wage_mh  = ln(wage_od_mh)
gen double ln_dist     = ln(dist_km)

quietly count
local Nfinal = r(N)
quietly count if missing(ln_dist)
local Ndiag = r(N)
quietly count if !missing(ln_dist)
local Nreg = r(N)

display _n "================ 面板概况 ================"
display "有距离的 OD 单元数            : " %10.0fc `Nfinal'
display "对角线单元（dist=0，ln_dist 缺失）: " %8.0fc `Ndiag'
display "可用于 Fact 1 的 OD 单元数     : " %10.0fc `Nreg'
display "  距离矩阵中未匹配上的对数     : " %10.0fc `Nomiss'

display _n "--- 工资异常值检查（对数回归对极端值敏感）---"
quietly count if wage_od > 1000000 & !missing(wage_od)
display "  wage_od > 1,000,000 的单元数 : " %10.0fc r(N)
quietly summarize wage_od if !missing(wage_od), detail
display "  wage_od 中位数 / 均值 / 最大 : " %12.0fc r(p50) " / " %12.0fc r(mean) " / " %12.0fc r(max)

display _n "--- 关键变量描述统计 ---"
summarize p_od wage_od dist_km ln_p ln_wage ln_dist, sep(0)

*------------------------------------------------------------------------------
*  9. 存盘（中间数据，便于复核）
*------------------------------------------------------------------------------
save "`root'\复现\idn_od_panel_regency.dta", replace

*------------------------------------------------------------------------------
* 10. 回归
*     主结果：全部人、不加权、cluster(o d)   —— 论文 Table 2 未写明加权
*     稳健性：男性户主 15-65 岁、按单元人数加权
*------------------------------------------------------------------------------
keep if !missing(ln_dist)

display _n "=============================================================="
display    " 主结果：全部人，不加权，cluster(o d)"
display    "=============================================================="

display _n "===== (1) Fact 1  引力方程       论文 = -0.717 ====="
reghdfe ln_p ln_dist, absorb(o d) cluster(o d)
local b1 = _b[ln_dist]
local s1 = _se[ln_dist]
local n1 = e(N)

display _n "===== (2) Fact 2  工资楔子       论文 =  0.029 ====="
reghdfe ln_wage ln_dist, absorb(o d) cluster(o d)
local b2 = _b[ln_dist]
local s2 = _se[ln_dist]
local n2 = e(N)

display _n "===== (3) Fact 3  选择           论文 = -0.039 ====="
reghdfe ln_wage ln_p, absorb(o d) cluster(o d)
local b3 = _b[ln_p]
local s3 = _se[ln_p]
local n3 = e(N)

display _n "===== (4) Fact 4  联合           论文 = -0.031 / 0.007 ====="
reghdfe ln_wage ln_p ln_dist, absorb(o d) cluster(o d)
local b4p = _b[ln_p]
local s4p = _se[ln_p]
local b4d = _b[ln_dist]
local s4d = _se[ln_dist]
local n4 = e(N)

display _n "=============================================================="
display    " 稳健性：男性户主 15-65 岁，按单元人数加权"
display    "=============================================================="

display _n "===== (1) Fact 1 加权 ====="
reghdfe ln_p_mh ln_dist [aw = n_mh], absorb(o d) cluster(o)
local rb1 = _b[ln_dist]
local rs1 = _se[ln_dist]

display _n "===== (2) Fact 2 加权 ====="
reghdfe ln_wage_mh ln_dist [aw = n_wage_mh], absorb(o d) cluster(o)
local rb2 = _b[ln_dist]
local rs2 = _se[ln_dist]

display _n "===== (3) Fact 3 加权 ====="
reghdfe ln_wage_mh ln_p_mh [aw = n_wage_mh], absorb(o d) cluster(o)
local rb3 = _b[ln_p_mh]
local rs3 = _se[ln_p_mh]

display _n "===== (4) Fact 4 加权 ====="
reghdfe ln_wage_mh ln_p_mh ln_dist [aw = n_wage_mh], absorb(o d) cluster(o)
local rb4p = _b[ln_p_mh]
local rs4p = _se[ln_p_mh]
local rb4d = _b[ln_dist]
local rs4d = _se[ln_dist]

*------------------------------------------------------------------------------
* 10c. 稳健性：剔除工资极端值单元（wage_od > 1,000,000）
*      目的：检验 Fact 2/3/4 与论文的差异是否由工资异常值驱动
*------------------------------------------------------------------------------
gen byte okw = missing(wage_od) | wage_od <= 1000000

display _n "=============================================================="
display    " 稳健性：剔除 wage_od > 1,000,000 的极端单元"
display    "=============================================================="

display _n "===== (1) Fact 1 剔极端值 ====="
reghdfe ln_p ln_dist if okw, absorb(o d) cluster(o d)
local eb1 = _b[ln_dist]

display _n "===== (2) Fact 2 剔极端值 ====="
reghdfe ln_wage ln_dist if okw, absorb(o d) cluster(o d)
local eb2 = _b[ln_dist]

display _n "===== (3) Fact 3 剔极端值 ====="
reghdfe ln_wage ln_p if okw, absorb(o d) cluster(o d)
local eb3 = _b[ln_p]

display _n "===== (4) Fact 4 剔极端值 ====="
reghdfe ln_wage ln_p ln_dist if okw, absorb(o d) cluster(o d)
local eb4p = _b[ln_p]
local eb4d = _b[ln_dist]

*------------------------------------------------------------------------------
* 11. 结果汇总表（矩阵 → matlist，避免超长 display）
*------------------------------------------------------------------------------
matrix RES = J(6, 4, .)
matrix colnames RES = Fact1 Fact2 Fact3 Fact4
matrix rownames RES = DistPaper DistOurs DistSE MigPaper MigOurs MigSE

matrix RES[1,1] = -0.717
matrix RES[1,2] =  0.029
matrix RES[1,4] =  0.007
matrix RES[2,1] = `b1'
matrix RES[2,2] = `b2'
matrix RES[2,4] = `b4d'
matrix RES[3,1] = `s1'
matrix RES[3,2] = `s2'
matrix RES[3,4] = `s4d'
matrix RES[4,3] = -0.039
matrix RES[4,4] = -0.031
matrix RES[5,3] = `b3'
matrix RES[5,4] = `b4p'
matrix RES[6,3] = `s3'
matrix RES[6,4] = `s4p'

matrix RBS = J(6, 4, .)
matrix colnames RBS = Fact1 Fact2 Fact3 Fact4
matrix rownames RBS = DistPaper DistOurs DistSE MigPaper MigOurs MigSE

matrix RBS[1,1] = -0.717
matrix RBS[1,2] =  0.029
matrix RBS[1,4] =  0.007
matrix RBS[2,1] = `rb1'
matrix RBS[2,2] = `rb2'
matrix RBS[2,4] = `rb4d'
matrix RBS[3,1] = `rs1'
matrix RBS[3,2] = `rs2'
matrix RBS[3,4] = `rs4d'
matrix RBS[4,3] = -0.039
matrix RBS[4,4] = -0.031
matrix RBS[5,3] = `rb3'
matrix RBS[5,4] = `rb4p'
matrix RBS[6,3] = `rs3'
matrix RBS[6,4] = `rs4p'

matrix EXT = J(4, 4, .)
matrix colnames EXT = Fact1 Fact2 Fact3 Fact4
matrix rownames EXT = DistPaper DistOurs MigPaper MigOurs

matrix EXT[1,1] = -0.717
matrix EXT[1,2] =  0.029
matrix EXT[1,4] =  0.007
matrix EXT[2,1] = `eb1'
matrix EXT[2,2] = `eb2'
matrix EXT[2,4] = `eb4d'
matrix EXT[3,3] = -0.039
matrix EXT[3,4] = -0.031
matrix EXT[4,3] = `eb3'
matrix EXT[4,4] = `eb4p'

matrix NN = J(2, 4, .)
matrix colnames NN = Fact1 Fact2 Fact3 Fact4
matrix rownames NN = Paper Ours
matrix NN[1,1] = 25540
matrix NN[1,2] = 25244
matrix NN[1,3] = 25244
matrix NN[1,4] = 25244
matrix NN[2,1] = `n1'
matrix NN[2,2] = `n2'
matrix NN[2,3] = `n3'
matrix NN[2,4] = `n4'

display _n(2) "=============================================================================="
display       "  Table 2 复现结果对照（1995 年，县级，终身迁移）"
display       "=============================================================================="
display       "  论文报告值来自 1995+2011+2012 三年合并；本复现仅有 1995 年。"

display _n "【主结果】全部人，不加权，cluster(o d)"
matlist RES, border(rows) left(14) format(%9.3f)

display _n "【样本量】"
matlist NN, border(rows) left(14) format(%9.0f)

display _n "【稳健性】男性户主 15-65 岁，按单元人数加权"
matlist RBS, border(rows) left(14) format(%9.3f)

display _n "【稳健性】全部人、不加权，但剔除 wage_od > 1,000,000 的极端单元"
matlist EXT, border(rows) left(14) format(%9.3f)

display _n "=============================================================================="
display    "  注：Dist = ln 距离的系数；Mig = ln 迁移份额的系数。"
display    "      论文第 (5) 列 Amenities 需要 PODES 设施数据，IPUMS 不提供，无法复现。"
display    "=============================================================================="

*------------------------------------------------------------------------------
* 12. 复现说明
*------------------------------------------------------------------------------
display _n(2) "================ 复现说明 ================"
display "1. 复现范围：论文 Table 2 的 (1)-(4) 列，1995 年。第 (5) 列 Amenities 需要"
display "   PODES 六项设施数据做主成分分析，IPUMS International 不提供，无法复现。"
display "2. 年份：论文合并 1995、2011、2012 三年，故 N = 25,540；本复现只有 1995，"
display "   故 N 约为论文的一半。这是样本量差异的主要原因。"
display "3. 固定效应：论文为 Destination x Year 与 Origin x Year；单年情形下退化为"
display "   Destination FE 与 Origin FE。"
display "4. 聚类：论文为 origin-year 与 destination-year 双向聚类；单年情形下即"
display "   cluster(o d)。加权稳健性一栏因双向聚类与双向固定效应共线，改为 cluster(o)。"
display "5. 工资异常值：wage_od 存在接近千万的极端值（见第 8 节检查），对数回归对"
display "   极端值敏感，这可能是 Fact 2/3/4 与论文差异的来源之一。"
display "6. 数据来源：论文为 BPS 原始数据（1995 SUPAS），本复现为 IPUMS International"
display "   协调版，县数为 221 个（论文 281 个），变量口径可能存在差异。"
display "7. 地理范围：IPUMS 1995 样本仅覆盖 17 个省（苏门答腊 11-18、爪哇 31-35、"
display "   巴厘与努沙登加拉 51-53）；加里曼丹（61-64）、苏拉威西（71-74）、马鲁古"
display "   （81）、巴布亚（94）共 10 个省不在样本内。加权人口 166,522,373，约为"
display "   当年印尼实际人口（约 1.95 亿）的 86%。这既减少了可用的 OD 单元数，"
display "   也部分解释了 N 与论文的差距。属数据可得性限制，非代码设定问题。"
display "=========================================="

log close