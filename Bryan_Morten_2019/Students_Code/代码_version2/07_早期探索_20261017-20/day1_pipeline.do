* ============================================================
* BM2019 印尼侧复现 —— Day 1：管道搭建
* 输入：D:\研一上\微观计量\ipumsi_00001.dta（IPUMS International，印尼 1995）
* 产出：(1) OD 迁移份额 p_od
*       (2) 每个 o-d 对的平均工资 wage_od
*       (3) 目的地/原籍地固定效应（w_d, q_o）
* 设计说明：年份不写死。之后加入 2010 只需换输入文件，本脚本不用改。
* ============================================================

clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"

log using "idn_pipeline.log", replace text

* ============ 1. 读入与原始规模 ============
use "D:\研一上\微观计量\ipumsi_00001.dta", clear

display "===== 1. 原始数据 ====="
describe, short
count
tab year
summarize incwage perwt

* ============ 2. 构造地理代码 ============
* geo1_id = 现居地；bplid = 出生地
* geo1_id 减去国家码 360000 后，与 bplid 的省码一致（East Timor 例外）
gen int o = bplid
gen int d = geo1_id - 360000

display "===== 2. 地理代码核对 ====="
tab o, missing
tab d, missing

* ============ 3. 剔除特殊观测 ============
display "===== 3. 剔除特殊观测 ====="

count if o == 98
display "  ^ 出生在国外（abroad），剔除"
drop if o == 98

count if o == 54 | d == 626
display "  ^ East Timor（1999 年脱离印尼，且编码体系与 bplid 不一致），剔除"
drop if o == 54 | d == 626

count
display "  ^ 剩余样本"

count if incwage >= 9999990
display "  ^ 工资为哨兵值/极端值（IPUMS 缺失码 9999999）"

* ============ 4. 迁移份额 p_od（用全样本） ============
display "===== 4. 迁移份额 p_od ====="

preserve
    gen double n = perwt
    collapse (sum) n, by(year o d)
    bysort year o: egen n_o = total(n)
    gen double p_od = n / n_o
    label var n     "origin-o born persons living in d (weighted)"
    label var n_o   "total origin-o born persons (weighted)"
    label var p_od  "share of origin-o population living in d"
    keep year o d n n_o p_od
    tempfile pop
    save "`pop'"
restore

* ============ 5. 平均工资 wage_od（只留有效工资） ============
display "===== 5. 平均工资 wage_od ====="

keep if incwage > 0 & incwage < 9999990
display "  有效工资样本量："
count

gen double ww = perwt * incwage
collapse (sum) ww perwt, by(year o d)
rename perwt sum_w
gen double wage_od = ww / sum_w
label var wage_od "average wage of o-born workers in d"
tempfile wag
save "`wag'"

* ============ 6. 合并成 OD 面板 ============
display "===== 6. 合并 ====="

use "`pop'", clear
merge 1:1 year o d using "`wag'"
tab _merge
keep if _merge == 3
drop _merge

* ============ 7. 诊断 ============
display "===== 7. 诊断 ====="

count
display "  ^ OD 单元数"

tab o if o > 53
display "  ^ 只有出生地、没有现居地的省（Kalimantan/Sulawesi/Maluku/Papua）"

summarize p_od wage_od

display "===== 8. 用于结构部分的 16x16 子样本 ====="
* 现居地集合：11-18, 31-35, 51-53（共 16 个）
gen byte obs_prov = (o <= 53)
tab obs_prov
count if obs_prov == 1

* ============ 9. 式 (7)：取 w_d、q_o，并检查 ln p 的系数 ============
* ln wage_do = ln Gbar + ln w_d - (1/theta) ln p_do + ln q_o + ln eps
* 理论预测：ln_p 的系数 = -1/theta。theta=12.5 -> 约 -0.080
display "===== 9. 式(7) 回归（全样本） ====="

gen double ln_wage = ln(wage_od)
gen double ln_p    = ln(p_od)

regress ln_wage ln_p i.d i.o

display "===== 9b. 式(7) 回归（16x16 子样本） ====="
regress ln_wage ln_p i.d i.o if obs_prov == 1

* ============ 10. 保存 ============
display "===== 10. 保存产出 ====="

save "idn_od_panel.dta", replace
export delimited using "idn_od_panel.csv", replace

display "=== PIPELINE DONE ==="

log close