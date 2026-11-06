*==============================================================
* Table 2  第 1 步：造县级 OD 面板
*--------------------------------------------------------------
* 数据：IPUMS International, Indonesia 1995 SUPAS
* 迁移定义：出生县 != 现居县（终身迁移，论文口径）
* 观测单位：一个 (o,d) 出生县-现居县 对
* 产出：idn_od_panel_regency.dta
*
* 同时造两套样本，因为论文没写明限制，两套都报：
*   _all = 全部人
*   _mh  = 男性户主、15-65 岁
*==============================================================
clear all
set more off
capture log close
cd "D:\研一上\微观计量\复现"
log using "t2_build_out.log", replace text

*---- 0. 先把距离 CSV 转成 dta ----
*  merge 只能并 Stata 格式文件，不能直接并 CSV（否则报 r(610)）
import delimited "idn_regency_dist.csv", clear varnames(1)
describe
save "idn_regency_dist.dta", replace

*---- 1. 载入 1995 年（只读需要的 7 个变量）----
use year geo2_id1995 id1995a_bplreg incwage perwt relate sex age using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count
display "  ^ 1995 年总人数（论文 Table 2 的样本年份）"

*---- 2. 统一县码 ----
*  出生县码是 1101 这种 4 位，现居县码是 11001 这种 5 位，必须先转换
*  int(x/100)*1000 取省，mod(x,100) 取县，拼起来
gen long o = int(id1995a_bplreg/100)*1000 + mod(id1995a_bplreg,100)
gen long d = geo2_id1995

*==============================================================
* 3. π_od：迁移份额
*    分子 = 出生在 o、现居在 d 的加权人数
*    分母 = 所有出生在 o 的加权人数
*==============================================================
display _n "===== 3a. π_od（全部人）====="
preserve
    collapse (sum) n = perwt, by(o d)
    bysort o: egen double n_o = total(n)
    gen double p_od = n / n_o
    bysort o: egen double chk = total(p_od)
    quietly summarize chk
    display "  【自检】π_od 按出生县 o 加总：最小 = " %9.6f r(min) "  最大 = " %9.6f r(max)
    keep o d p_od n
    tempfile pop_all
    save "`pop_all'"
restore

display _n "===== 3b. π_od（男性户主 15-65 岁）====="
preserve
    keep if relate == 1 & sex == 1 & age >= 15 & age <= 65
    count
    display "  ^ 男性户主 15-65 岁人数"
    collapse (sum) n = perwt, by(o d)
    bysort o: egen double n_o = total(n)
    gen double p_od_mh = n / n_o
    rename n n_mh
    keep o d p_od_mh n_mh
    tempfile pop_mh
    save "`pop_mh'"
restore

*==============================================================
* 4. wage_od：平均月工资
*    分子 = Σ(perwt × incwage)
*    分母 = Σ perwt
*    incwage 缺失码：9999998 = UNKNOWN，9999999 = NIU（没问过）
*==============================================================
display _n "===== 4a. wage_od（全部有工资的人）====="
preserve
    keep if incwage > 0 & incwage < 9999990
    count
    display "  ^ 有有效工资的人数"
    gen double ww = perwt * incwage
    collapse (sum) ww perwt, by(o d)
    rename perwt n_wage
    gen double wage_od = ww / n_wage
    keep o d wage_od n_wage
    tempfile wag_all
    save "`wag_all'"
restore

display _n "===== 4b. wage_od（男性户主 15-65 岁）====="
preserve
    keep if incwage > 0 & incwage < 9999990 & relate == 1 & sex == 1 & age >= 15 & age <= 65
    count
    display "  ^ 有有效工资的男性户主 15-65 岁"
    gen double ww = perwt * incwage
    collapse (sum) ww perwt, by(o d)
    rename perwt n_wage_mh
    gen double wage_od_mh = ww / n_wage_mh
    keep o d wage_od_mh n_wage_mh
    tempfile wag_mh
    save "`wag_mh'"
restore

*==============================================================
* 5. 合并四张表（π 两张 + 工资两张）
*    pop_all 是主表：所有出现过迁移流的 (o,d) 对
*==============================================================
use "`pop_all'", clear
merge 1:1 o d using "`pop_mh'", nogen
merge 1:1 o d using "`wag_all'", nogen
merge 1:1 o d using "`wag_mh'", nogen

display _n "===== 5. 合并 π 与 wage 之后的概况 ====="
count
display "  ^ OD 单元数"
count if missing(wage_od)
display "  ^ 其中【没有工资观测】的单元数（论文表注说的就是这个）"

*==============================================================
* 6. 合并距离（论文脚注 9：出生县和现居县质心的直线距离）
*    idn_regency_dist.csv 是长表 o,d,dist_km，县码格式已经对得上
*==============================================================
merge 1:1 o d using "idn_regency_dist.dta", keep(master match)
display _n "===== 6. 合并距离的结果 ====="
tab _merge
keep if _merge == 3
drop _merge

*==============================================================
* 7. 造对数变量
*    注意：o == d 时 dist_km = 0，ln(0) 缺失，对角线会自动被剔除
*==============================================================
gen double ln_p        = ln(p_od)
gen double ln_p_mh     = ln(p_od_mh)
gen double ln_wage     = ln(wage_od)
gen double ln_wage_mh  = ln(wage_od_mh)
gen double ln_dist     = ln(dist_km)

*==============================================================
* 8. 检查面板
*==============================================================
display _n "===== 8. 面板概况 ====="
count
display "  ^ 最终 OD 单元数（有距离）"
quietly count if missing(ln_dist)
display "  ^ 对角线单元数（dist=0，ln_dist 缺失）：" r(N)
quietly count if !missing(ln_dist)
display "  ^ 可用于回归的 OD 单元数：" r(N)
display _n "--- 关键变量的描述统计 ---"
summarize p_od wage_od dist_km ln_p ln_wage ln_dist, sep(0)

*==============================================================
* 9. 存盘
*==============================================================
save "idn_od_panel_regency.dta", replace
display _n "===== 已保存：idn_od_panel_regency.dta ====="

log close