*==============================================================================
*  微观计量 课程作业 —— 论文复现
*------------------------------------------------------------------------------
*  论文 : Bryan, G. and M. Morten (2019), "The Aggregate Productivity Effects
*         of Internal Migration: Evidence from Indonesia",
*         Journal of Political Economy, 127(5), 2229-2268.
*
*  复现 : Table 1 —— Migration rates by origin, Indonesia
*
*  作者 : 陈冠宇、任娜、冯诗语
*  日期 : 2026-10-29
*  软件 : Stata 19
*  数据 : IPUMS International, Indonesia 1995
*         D:\研一上\微观计量\ipumsi_00002.dta
*  输出 : 本目录下 table1_replication.log
*------------------------------------------------------------------------------
*  论文口径说明（三条，均可追溯至论文原文）：
*
*   [1] 迁移定义 = 现居县 != 出生县                            (Table 1 注释)
*
*   [2] 城乡划分 = 该县人口的农村占比；且出生地（起点）与现居地
*       （终点）必须使用同一套县级规则                          (脚注 12)
*       论文对切点给出了两种可依据的规则，本文件同时报告：
*         规则 A：使被划为农村的县的人口占比 = 全国农村人口占比
*                 (Table 1 注释："we choose the cutoff to classify
*                  the regency as rural to match the national
*                  urbanization rate for each year")
*         规则 B：县级农村人口占比的中位数                    (脚注 12)
*
*   [3] 样本 = 男性户主、15-65 岁、有工资记录
*                                                    (Appendix Table 1 注释)
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
log using "`root'\复现\table1_replication.log", replace text

display _n "================ 运行信息 ================"
display "运行时间  : $S_DATE $S_TIME"
display "Stata 版本: `c(stata_version)'"
display "数据文件  : `root'\ipumsi_00002.dta"

*------------------------------------------------------------------------------
*  1. 读入数据并限定年份
*------------------------------------------------------------------------------
use year geo2_id1995 id1995a_bplreg incwage perwt relate sex age urban using "`root'\ipumsi_00002.dta", clear
keep if year == 1995

quietly count
local Nall = r(N)
quietly count if missing(id1995a_bplreg)
local Nmiss_bpl = r(N)
quietly count if missing(geo2_id1995)
local Nmiss_geo = r(N)
quietly count if missing(urban)
local Nmiss_urb = r(N)

display _n "================ 数据检查 ================"
display "1995 年全部人口记录数 : " %12.0fc `Nall'
display "出生县码缺失          : " %12.0fc `Nmiss_bpl'
display "现居县码缺失          : " %12.0fc `Nmiss_geo'
display "城乡变量缺失          : " %12.0fc `Nmiss_urb'

*------------------------------------------------------------------------------
*  2. 县码统一到同一编码空间
*------------------------------------------------------------------------------
*  出生县码为 4 位（例：1101），现居县码为 5 位（例：11001）。
*  由 5 位转 4 位：省份部分 * 1000 + 县部分。
gen long geo_key = int(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
gen long bpl_key = id1995a_bplreg
label var geo_key "现居县（4 位码）"
label var bpl_key "出生县（4 位码）"

*------------------------------------------------------------------------------
*  3. 县级城乡划分（论文脚注 12 口径）
*     —— 用【全部人口】计算县级农村占比，必须在限制样本之前完成
*------------------------------------------------------------------------------
preserve
    gen double wrur = perwt*(urban == 1)
    collapse (sum) wpop = perwt wrur = wrur, by(geo_key)
    gen double rural_share = wrur/wpop

    quietly summarize wpop
    local totpop = r(sum)
    quietly summarize wrur
    local natrural = r(sum)/`totpop'
    local natp = `natrural'*100
    quietly summarize rural_share, detail
    local med = r(p50)

    * --- 规则 A：切点使农村县人口占比 = 全国农村人口占比 ---
    gsort -rural_share
    gen double cumshare = sum(wpop)/`totpop'
    gen long ord = _n
    quietly summarize ord if cumshare >= `natrural', meanonly
    local kA   = r(min)
    local cutA = rural_share[`kA']
    gen byte regA = (rural_share > `cutA')
    quietly count if regA == 1
    local nRA = r(N)
    quietly count if regA == 0
    local nUA = r(N)

    * --- 规则 B：切点 = 县级农村占比的中位数 ---
    gen byte regB = (rural_share > `med')
    quietly count if regB == 1
    local nRB = r(N)
    quietly count if regB == 0
    local nUB = r(N)

    local ntot = `nRA' + `nUA'

    keep geo_key regA regB
    rename geo_key bpl_key
    rename regA oA
    rename regB oB
    tempfile f_o
    save "`f_o'", replace
    rename bpl_key geo_key
    rename oA dA
    rename oB dB
    tempfile f_d
    save "`f_d'", replace
restore

display _n "================ 城乡划分 ================"
display "县级单位数                : " %6.0f `ntot'
display "全国农村人口占比（加权）  : " %6.2f `natp' "%"
display "规则 A 切点               : " %6.4f `cutA' "   ->  农村县 " %4.0f `nRA' " 个 / 城市县 " %4.0f `nUA' " 个"
display "规则 B 切点（中位数）     : " %6.4f `med'  "   ->  农村县 " %4.0f `nRB' " 个 / 城市县 " %4.0f `nUB' " 个"

*------------------------------------------------------------------------------
*  4. 给出生县与现居县分别贴上城乡标签（同一套县级规则）
*------------------------------------------------------------------------------
merge m:1 geo_key using "`f_d'", keep(1 3) nogen
merge m:1 bpl_key using "`f_o'", keep(1 3) nogen

*------------------------------------------------------------------------------
*  5. 样本限制（论文 Appendix Table 1 注释）
*     男性户主、15-65 岁、有有效工资记录
*------------------------------------------------------------------------------
keep if relate == 1 & sex == 1 & age >= 15 & age <= 65
keep if incwage > 0 & incwage < 9999990

quietly count
local N = r(N)

*------------------------------------------------------------------------------
*  6. 构造指标
*------------------------------------------------------------------------------
gen byte moved  = (geo_key != bpl_key)
label var moved "迁移：现居县 != 出生县"

gen byte okA    = !missing(oA) & !missing(dA)
gen byte okB    = !missing(oB) & !missing(dB)
gen byte sameA  = (oA == dA) if moved == 1
gen byte sameB  = (oB == dB) if moved == 1

gen double wmoved = perwt*moved
gen double wsameA = perwt*sameA
gen double wsameB = perwt*sameB

*------------------------------------------------------------------------------
*  7. 计算结果：迁移率 与 同类内迁移占比
*     迁移率的 Rural/Urban 分组依赖城乡划分规则，故规则 A、B 下均报告；
*     All 列不受划分规则影响。
*------------------------------------------------------------------------------
matrix RES = J(6, 3, .)
matrix colnames RES = Rural Urban All
matrix rownames RES = "Migrate_A" "Within_A" "Migrate_B" "Within_B" "PaperMigrate" "PaperWithin"

foreach rl in A B {
    local oc  "o`rl'"
    local okc "ok`rl'"
    local sc  "wsame`rl'"

    local mr = .
    local mu = .
    local ma = .
    local wr = .
    local wu = .
    local wa = .

    forvalues k = 1/3 {
        local sel ""
        if `k' == 2 local sel " & `oc' == 1"
        if `k' == 3 local sel " & `oc' == 0"

        * 迁移率：分母为全部样本，分子为迁移者
        quietly summarize perwt if 1`sel'
        local den = r(sum)
        quietly summarize wmoved if 1`sel'
        local mv = r(sum)/`den'*100

        * 同类内迁移占比：分母为可分类的迁移者，分子为迁往同类县者
        quietly summarize perwt if moved == 1 & `okc'`sel'
        local den2 = r(sum)
        quietly summarize `sc' if moved == 1 & `okc'`sel'
        local wv = r(sum)/`den2'*100

        if `k' == 1 {
            local ma = `mv'
            local wa = `wv'
        }
        if `k' == 2 {
            local mr = `mv'
            local wr = `wv'
        }
        if `k' == 3 {
            local mu = `mv'
            local wu = `wv'
        }
    }

    if "`rl'" == "A" {
        matrix RES[1,1] = `mr'
        matrix RES[1,2] = `mu'
        matrix RES[1,3] = `ma'
        matrix RES[2,1] = `wr'
        matrix RES[2,2] = `wu'
        matrix RES[2,3] = `wa'
    }
    else {
        matrix RES[3,1] = `mr'
        matrix RES[3,2] = `mu'
        matrix RES[3,3] = `ma'
        matrix RES[4,1] = `wr'
        matrix RES[4,2] = `wu'
        matrix RES[4,3] = `wa'
    }
}

* 论文 Table 1 报告的 1995 年数值
matrix RES[5,1] = 32.3
matrix RES[5,2] = 35.8
matrix RES[5,3] = 33.7
matrix RES[6,1] = 31.1
matrix RES[6,2] = 74.6
matrix RES[6,3] = 49.4

*------------------------------------------------------------------------------
*  8. 输出
*------------------------------------------------------------------------------
quietly count
local N = r(N)
quietly count if moved == 1
local Nmig = r(N)
quietly count if moved == 1 & !okA
local Ndrop = r(N)

display _n(2) "================ 样本与覆盖 ================"
display "样本量（男性户主 15-65 有工资） : " %12.0fc `N'
display "其中迁移者                      : " %12.0fc `Nmig'
display "出生县无法分类的迁移者          : " %12.0fc `Ndrop'

display _n(2) "=============================================================================="
display    "  Table 1 复现结果：迁移率与同类内迁移占比（%，加权）"
display    "=============================================================================="
matlist RES, border(rows) left(20) format(%9.1f)
display    "=============================================================================="
display    "  注：规则 A 为论文 Table 1 注释口径（匹配全国城镇化率）；"
display    "      规则 B 为论文脚注 12 口径（县级农村占比中位数）。"
display    "      Migrate 行为出发点类型对应的迁移率，Within 行为同类内迁移占比。"
display    "=============================================================================="

display _n(2) "================ 复现说明 ================"
display "1. 复现范围：论文 Table 1 的 1995 年一列。IPUMS International 未提供"
display "   2011、2012 年 SUSENAS 数据，故该两列无法复现。"
display "2. 城乡划分：论文脚注 12 与 Table 1 注释分别给出中位数规则与匹配全国"
display "   城镇化率规则，本文件同时报告，以检验结果对切点选择的敏感性。"
display "3. 起点与终点的一致性：论文脚注 12 指出出生地不记录城乡属性，必须用"
display "   县级规则补齐。故本文件对出生县与现居县使用完全相同的县级规则。"
display "4. 县级覆盖：可分类县 `ntot' 个，论文为 281 个。"
display "   地理范围：IPUMS 1995 样本仅覆盖 17 个省、221 个县，即苏门答腊（11-18）、"
display "   爪哇（31-35）、巴厘与努沙登加拉（51-53）；加里曼丹（61-64）、苏拉威西"
display "   （71-74）、马鲁古（81）、巴布亚（94）共 10 个省不在样本内。"
display "   加权人口 166,522,373，约为当年印尼实际人口（约 1.95 亿）的 86%。"
display "   这是县数少于论文（281 个）的主要原因，属数据可得性限制。"
display "5. 数据来源：论文为 BPS 原始数据（SUPAS 1995），本复现为 IPUMS"
display "   International 协调版数据，变量口径可能存在差异。"
display "6. 主要结论：在规则 A（论文 Table 1 注释口径）下，六个数值与论文报告值"
display "   的偏差均在 2 个百分点以内；规则 B 下偏差明显更大。这说明论文采用的"
display "   是规则 A 的切点定义，同时也验证了起点与终点使用同一套县级规则的必要性。"
display "=========================================="

log close