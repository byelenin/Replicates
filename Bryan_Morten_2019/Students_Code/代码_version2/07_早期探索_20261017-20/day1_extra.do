* ============================================================
* BM2019 印尼侧 Day 1 —— 补充诊断
* 目的：(1) 校验样本代表性（加权总人口 vs 印尼 1995 实际人口）
*       (2) 看 OD 单元规模分布（小单元会让平均工资很吵）
*       (3) 按人口加权的稳健性回归
* ============================================================

clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"

log using "idn_extra.log", replace text

* ============ A. 样本代表性校验 ============
display "===== A. 加权总人口 vs 印尼 1995 实际人口 ====="

use "D:\研一上\微观计量\ipumsi_00001.dta", clear
gen int o = bplid
gen int d = geo1_id - 360000

quietly summarize perwt
display "  剔除前加权总人口 = " %15.0fc r(sum)

drop if o == 98
drop if o == 54 | d == 626

quietly summarize perwt
local tot = r(sum)
display "  剔除后加权总人口 = " %15.0fc `tot'
display "  占印尼 1995 年人口（194,800,000）的比重 = " %6.2f 100*`tot'/194800000 "%"
display "  缺失的 10 个省：Kalimantan(4) Sulawesi(4) Maluku Papua"

* ============ B. OD 单元规模分布 ============
display "===== B. OD 单元规模分布 ====="

use "idn_od_panel.dta", clear
capture drop obs_prov
gen byte obs_prov = (o <= 53)

display "  --- 单元加权人口 n ---"
summarize n, detail

display "  加权人口 < 100 的单元数："
count if n < 100
display "  加权人口 < 500 的单元数："
count if n < 500

display "  --- 单元内有效工资人数 sum_w ---"
summarize sum_w, detail

display "  有效工资人数 < 30 的单元数："
count if sum_w < 30

* ============ C. 稳健性：按人口加权 ============
display "===== C. 基准回归（16x16，不加权，229 个单元） ====="
regress ln_wage ln_p i.d i.o if obs_prov == 1

display "===== C2. 按单元人口加权 ====="
regress ln_wage ln_p i.d i.o if obs_prov == 1 [aw = n]

display "===== C3. 剔除小单元（加权人口 >= 500） ====="
regress ln_wage ln_p i.d i.o if obs_prov == 1 & n >= 500

display "===== C4. 全样本（328 个单元） ====="
regress ln_wage ln_p i.d i.o

log close