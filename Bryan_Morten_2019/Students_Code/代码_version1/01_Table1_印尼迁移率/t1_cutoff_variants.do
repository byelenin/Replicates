*==============================================================================
* t1_cutoff_variants.do — 「匹配全国城镇化率」有几种实现？它们等价吗？
*
*   全国农村占比  natrural = 62.69%
*   全国城镇化率  naturban = 37.31%
*
*   五种切点实现：
*     V1 累计人口法(跨线县不计入, rs >  cut1)   ← 我原代码
*     V2 累计人口法(跨线县计入,   rs >= cut1)
*     V3 直接阈值法(cut = 全国农村占比 0.6269 本身)
*     V4 匹配城镇侧(让城市县承载 37.31%)
*     VB 中位数法(脚注 3 / 规则 B)
*==============================================================================
clear all
set more off
set linesize 220
capture log close
log using "t1_cutoff_variants_out.log", replace text

local root "D:\研一上\微观计量"

display _n(2) "{hline 94}"
display "  「匹配全国城镇化率」的实现变体：它们真的等价吗？"
display "{hline 94}"

use year geo2_id1995 incwage perwt urban using "`root'\ipumsi_00002.dta", clear
keep if year == 1995

preserve
    gen double wrur = perwt*(urban == 1)
    collapse (sum) wpop = perwt wrur = wrur, by(geo2_id1995)
    gen double rs = wrur/wpop

    quietly summarize wpop
    local tp = r(sum)
    quietly summarize wrur
    local natrural = r(sum)/`tp'
    local naturban = 1 - `natrural'
    quietly count
    local nc = r(N)

    display _n "  县数 = `nc'"
    display "  全国农村占比 natrural = " %7.4f `natrural'
    display "  全国城镇化率 naturban = " %7.4f `naturban'

    * --- 切点 V1/V2：按农村占比降序累计人口，找累计份额首次 >= natrural 的县
    gsort -rs
    gen double csd = sum(wpop)/`tp'
    gen long ordd = _n
    quietly summarize ordd if csd >= `natrural', meanonly
    local k1   = r(min)
    local CUT1 = rs[`k1']

    * --- 切点 V4：按农村占比升序累计人口（= 城市侧），找累计份额首次 >= naturban
    gsort rs
    gen double csa = sum(wpop)/`tp'
    gen long orda = _n
    quietly summarize orda if csa >= `naturban', meanonly
    local k4   = r(min)
    local CUT4 = rs[`k4']

    * --- 切点 VB：中位数
    quietly summarize rs, detail
    local CUTB = r(p50)

    local CUT3 = `natrural'

    display _n "  切点：V1 = " %7.4f `CUT1' "   V3 = " %7.4f `CUT3' ///
        "   V4 = " %7.4f `CUT4' "   VB = " %7.4f `CUTB'

    * --- 四种标签（一次生成，避免嵌套 preserve）
    gen byte rA1 = (rs >  `CUT1')
    gen byte rA2 = (rs >= `CUT1')
    gen byte rA3 = (rs >  `CUT3')
    gen byte rA4 = (rs >  `CUT4')
    gen byte rB_ = (rs >  `CUTB')

    display _n(2) "{hline 94}"
    display "  ① 各实现的农村县数 / 城市县数 / 农村县实际承载人口占比"
    display "{hline 94}"
    display ""
    display "  实现                                  切点     农村县  城市县   农村县人口占比"
    display "  " "{hline 84}"

    local names `" "V1 累计人口法(跨线县不计入)" "V2 累计人口法(跨线县计入)" "V3 直接阈值法(cut=全国农村占比)" "V4 匹配城镇侧(城市县37.31%)" "VB 中位数法(脚注3/规则B)" "'
    local vars  "rA1 rA2 rA3 rA4 rB_"
    local cuts  "`CUT1' `CUT1' `CUT3' `CUT4' `CUTB'"
    forvalues i = 1/5 {
        local v  : word `i' of `vars'
        local nm : word `i' of `names'
        local ct : word `i' of `cuts'
        quietly count if `v' == 1
        local nR = r(N)
        quietly summarize wpop if `v' == 1
        local pR = r(sum)/`tp'*100
        display "  `nm'  " %7.4f `ct' "  " %5.0f `nR' "   " %5.0f `nc'-`nR' "   " %8.2f `pR' "%"
    }

    display _n(2) "{hline 94}"
    display "  ② 关键：农村县人口占比 vs 目标 62.69%"
    display "{hline 94}"
    display ""
    display "  实现                                  农村县占比   与62.69%的差   是否真匹配"
    display "  " "{hline 84}"
    forvalues i = 1/5 {
        local v  : word `i' of `vars'
        local nm : word `i' of `names'
        quietly summarize wpop if `v' == 1
        local pR = r(sum)/`tp'
        local dv = (`pR' - `natrural')*100
        local ok = "否"
        if abs(`dv') < 0.5  local ok = "近似"
        if abs(`dv') < 0.05 local ok = "是"
        display "  `nm'  " %9.2f `pR'*100 "%   " %8.2f `dv' " 点      `ok'"
    }

    display _n(2) "{hline 94}"
    display "  ③ 各实现切点与农村县数彼此差多少"
    display "{hline 94}"
    display ""
    local cuts2 "`CUT1' `CUT1' `CUT3' `CUT4' `CUTB'"
    quietly count if rA1 == 1
    local N1 = r(N)
    quietly count if rA2 == 1
    local N2 = r(N)
    quietly count if rA3 == 1
    local N3 = r(N)
    quietly count if rA4 == 1
    local N4 = r(N)
    quietly count if rB_ == 1
    local NB = r(N)
    display "  V1 农村县 = " %4.0f `N1' "   切点 = " %7.4f `CUT1'
    display "  V2 农村县 = " %4.0f `N2' "   切点 = " %7.4f `CUT1'
    display "  V3 农村县 = " %4.0f `N3' "   切点 = " %7.4f `CUT3'
    display "  V4 农村县 = " %4.0f `N4' "   切点 = " %7.4f `CUT4'
    display "  VB 农村县 = " %4.0f `NB' "   切点 = " %7.4f `CUTB'
    display ""
    display "  ⭐ V1 与 V3 的切点差 = " %7.4f `CUT3'-`CUT1' ///
        " , 农村县数差 = " %4.0f `N3'-`N1' " 个"

    keep geo2_id1995 rs wpop rA1 rA2 rA3 rA4 rB_
    tempfile cnty
    save `cnty'
restore

*==============================================================================
* ④ 用四种划分各算一遍 Table 1 的六个数值（迁移率 + 同类内占比）
*==============================================================================
display _n(2) "{hline 94}"
display "  ④ 四种划分下的 Table 1 六个数值"
display "{hline 94}"

use year geo2_id1995 id1995a_bplreg incwage perwt relate sex age urban ///
    using "`root'\ipumsi_00002.dta", clear
keep if year == 1995

merge m:1 geo2_id1995 using `cnty', keep(master match) nogen

* 样本限制：男性户主 15-65 岁且有工资
keep if sex == 1 & inrange(age, 15, 65) & relate == 1
drop if missing(incwage) | incwage <= 0
display "  估计样本（男性户主 15-65 且有工资）：" %12.0fc _N

gen byte moved = (geo2_id1995 != id1995a_bplreg) if !missing(id1995a_bplreg)

* 同类别内迁移需要【出生县】和【现居县】两套标签，分别 merge
display _n "  —— 需要出生县与现居县各自的标签，重做 ——"

* 出生县标签
use geo2_id1995 rA1 rA2 rA3 rB_ using `cnty', clear
rename geo2_id1995 bpl_key
rename rA1 bA1
rename rA2 bA2
rename rA3 bA3
rename rB_ bB_
tempfile bpl
save `bpl'

* 现居县标签
use geo2_id1995 rA1 rA2 rA3 rB_ using `cnty', clear
rename geo2_id1995 geo_key
rename rA1 cA1
rename rA2 cA2
rename rA3 cA3
rename rB_ cB_
tempfile cur
save `cur'

use year geo2_id1995 id1995a_bplreg incwage perwt relate sex age urban ///
    using "`root'\ipumsi_00002.dta", clear
keep if year == 1995
merge m:1 id1995a_bplreg using `bpl', keep(master match) nogen
merge m:1 geo2_id1995   using `cur', keep(master match) nogen
keep if sex == 1 & inrange(age, 15, 65) & relate == 1
drop if missing(incwage) | incwage <= 0
gen byte moved = (geo2_id1995 != id1995a_bplreg)
display "  估计样本：" %12.0fc _N

display ""
display "  划分      Rural迁移率  Urban迁移率  All迁移率 | 同类Rural  同类Urban  同类All"
display "  " "{hline 92}"
local k = 0
foreach v in A1 A2 A3 B_ {
    local k = `k' + 1
    local lb : word `k' of "V1 V2"
    quietly summarize perwt if b`v' == 1
    local tR = r(sum)
    quietly summarize perwt if b`v' == 0
    local tU = r(sum)
    local tA = `tR' + `tU'
    quietly summarize perwt if b`v' == 1 & moved == 1
    local mR = r(sum)
    quietly summarize perwt if b`v' == 0 & moved == 1
    local mU = r(sum)
    local mA = `mR' + `mU'
    * 同类内：迁移者的出生类别 == 现居类别
    quietly summarize perwt if b`v' == 1 & moved == 1 & c`v' == 1
    local sR = r(sum)
    quietly summarize perwt if b`v' == 0 & moved == 1 & c`v' == 0
    local sU = r(sum)
    local sA = `sR' + `sU'
    local lbl "r`v'"
    if "`v'" == "A1" local lbl "V1 累计不计入"
    if "`v'" == "A2" local lbl "V2 累计计入  "
    if "`v'" == "A3" local lbl "V3 直接阈值  "
    if "`v'" == "B_" local lbl "VB 中位数    "
    display "  `lbl'  " %8.2f `mR'/`tR'*100 "   " %8.2f `mU'/`tU'*100 "   " ///
        %8.2f `mA'/`tA'*100 "  | " %8.2f `sR'/`mR'*100 "   " ///
        %8.2f `sU'/`mU'*100 "   " %8.2f `sA'/`mA'*100
}

display ""
display "  论文 Table 1（1995）    " %8.2f 32.3 "   " %8.2f 35.8 "   " %8.2f 33.7 "  | " ///
    %8.2f 31.1 "   " %8.2f 74.6 "   " %8.2f 49.4

display _n(2) "{hline 94}"
display "  结束：$S_DATE $S_TIME"
display "{hline 94}"
log close