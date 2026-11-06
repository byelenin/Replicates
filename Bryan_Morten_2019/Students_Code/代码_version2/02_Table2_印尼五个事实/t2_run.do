*==============================================================
* Table 2  第 2 步：跑回归 + 与论文对照（1995 年，县级，终身迁移）
*--------------------------------------------------------------
* 论文 Table 2 的目标值：
*   (1) Fact 1  ln π     对 ln 距离  =  -0.717 (0.009)***
*   (2) Fact 2  ln wage  对 ln 距离  =   0.029 (0.001)***
*   (3) Fact 3  ln wage  对 ln π     =  -0.039 (0.001)***
*   (4) Fact 4  ln wage  对 ln π     =  -0.031 (0.003)***
*               ln wage  对 ln 距离  =   0.007 (0.002)***
*   (5) Fact 5  需要 PODES 便利设施数据 → 无法复现
*
* 设定说明：
*   absorb(o d)    = 出生县 + 现居县 双向固定效应
*   cluster(o d)   = 双向聚类（论文口径；个别设定会因共线报缺失）
*==============================================================
clear all
set more off
capture log close
cd "D:\研一上\微观计量\复现"
log using "t2_run_out.log", replace text

use "idn_od_panel_regency.dta", clear

*---- 1. 只留有距离的单元（对角线 dist=0 自动剔除）----
keep if !missing(ln_dist)
count
display "  ^ 可用于回归的 OD 单元数"

*==============================================================
* 2. 主结果：全部人样本，不加权（论文 Table 2 没有写样本限制）
*==============================================================
display _n "=============================================================="
display    "主结果：全部人，不加权，双向聚类"
display    "=============================================================="

display _n "===== (1) Fact 1 引力        论文 = -0.717 ====="
reghdfe ln_p ln_dist, absorb(o d) cluster(o d)
local b1 = _b[ln_dist]
local s1 = _se[ln_dist]
local n1 = e(N)

display _n "===== (2) Fact 2 工资楔子    论文 = 0.029 ====="
reghdfe ln_wage ln_dist, absorb(o d) cluster(o d)
local b2 = _b[ln_dist]
local s2 = _se[ln_dist]
local n2 = e(N)

display _n "===== (3) Fact 3 选择        论文 = -0.039 ====="
reghdfe ln_wage ln_p, absorb(o d) cluster(o d)
local b3 = _b[ln_p]
local s3 = _se[ln_p]
local n3 = e(N)

display _n "===== (4) Fact 4             论文 = -0.031 / 0.007 ====="
reghdfe ln_wage ln_p ln_dist, absorb(o d) cluster(o d)
local b4p = _b[ln_p]
local s4p = _se[ln_p]
local b4d = _b[ln_dist]
local s4d = _se[ln_dist]
local n4 = e(N)

*==============================================================
* 3. 稳健性：男性户主 15-65 岁，加权
*==============================================================
display _n "=============================================================="
display    "稳健性：男性户主 15-65 岁，按单元人数加权"
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

*==============================================================
* 4. 与论文并排对照（方便截图放进 PPT）
*==============================================================
display _n ""
display _n "==========================================================================================" _n "                  Table 2 复现结果对照（1995 年，县级，终身迁移）" _n "==========================================================================================" _n "                                (1)        (2)        (3)        (4)" _n "                             Fact 1     Fact 2     Fact 3     Fact 4" _n "------------------------------------------------------------------------------------------" _n "Log distance   论文          " %8.3f -0.717 %10.3f 0.029 %10.3f . %10.3f 0.007 _n "               我们          " %8.3f `b1' %10.3f `b2' %10.3f . %10.3f `b4d' _n "               标准误        " %8.3f `s1' %10.3f `s2' %10.3f . %10.3f `s4d' _n "------------------------------------------------------------------------------------------" _n "Log share mig. 论文          " %8.3f . %10.3f . %10.3f -0.039 %10.3f -0.031 _n "               我们          " %8.3f . %10.3f . %10.3f `b3' %10.3f `b4p' _n "               标准误        " %8.3f . %10.3f . %10.3f `s3' %10.3f `s4p' _n "------------------------------------------------------------------------------------------" _n "观测数         论文          " %8.0f 25540 %10.0f 25244 %10.0f 25244 %10.0f 25244 _n "               我们          " %8.0f `n1' %10.0f `n2' %10.0f `n3' %10.0f `n4' _n "------------------------------------------------------------------------------------------" _n "固定效应       论文          Dest x Year + Origin x Year（含年份）" _n "               我们          Dest FE + Origin FE（单年，无年份维度）" _n "               第 5 列        Fact 5 需要 PODES 便利设施数据，无法复现" _n "=========================================================================================="

display _n ""
display _n "------------------------------------------------------------------------------------------" _n "  稳健性：男性户主 15-65 岁，按单元人数加权" _n "------------------------------------------------------------------------------------------" _n "Log distance   论文          " %8.3f -0.717 %10.3f 0.029 %10.3f . %10.3f 0.007 _n "               我们          " %8.3f `rb1' %10.3f `rb2' %10.3f . %10.3f `rb4d' _n "               标准误        " %8.3f `rs1' %10.3f `rs2' %10.3f . %10.3f `rs4d' _n "Log share mig. 论文          " %8.3f . %10.3f . %10.3f -0.039 %10.3f -0.031 _n "               我们          " %8.3f . %10.3f . %10.3f `rb3' %10.3f `rb4p' _n "               标准误        " %8.3f . %10.3f . %10.3f `rs3' %10.3f `rs4p' _n "------------------------------------------------------------------------------------------"

*==============================================================
* 5. 导出论文形状的表
*==============================================================
eststo clear
eststo c1: reghdfe ln_p    ln_dist,          absorb(o d) cluster(o d)
eststo c2: reghdfe ln_wage ln_dist,          absorb(o d) cluster(o d)
eststo c3: reghdfe ln_wage ln_p,             absorb(o d) cluster(o d)
eststo c4: reghdfe ln_wage ln_p ln_dist,     absorb(o d) cluster(o d)
esttab c1 c2 c3 c4 using "table2_replica.rtf", replace b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) stats(N r2_a, fmt(%9.0f %9.3f)) mtitles("(1) Fact1" "(2) Fact2" "(3) Fact3" "(4) Fact4") title("Table 2 复现: Indonesia 1995, regency level")

log close