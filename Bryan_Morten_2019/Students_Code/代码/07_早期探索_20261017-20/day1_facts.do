* ============================================================
* BM2019 印尼侧 Day 1 —— 按论文正式样本口径重跑
* 论文的样本限制（p2236 脚注 6）：
*   只保留「男性户主」——"We restrict to male heads of households as our
*   model is one in which migration is motivated by work"
*   样本量 419,760 -> 187,065
* 论文的地理口径（p2236 脚注 7）：
*   剔除 Papua 和 West Papua；事实用 281 个 regency，结构估计汇总为 25 个省
* ============================================================

clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"

log using "idn_facts.log", replace text

* ============ 1. 读入 ============
use "D:\研一上\微观计量\ipumsi_00001.dta", clear

display "===== 1. 关系与性别编码 ====="
tab relate
tab sex

* ============ 2. 地理代码 + 与论文一致的地理剔除 ============
gen int o = bplid
gen int d = geo1_id - 360000

drop if o == 98
drop if o == 54 | d == 626
display "  剔除 abroad 与 East Timor 后："
count

* ============ 3. 论文的样本限制：男性户主 ============
display "===== 3. 男性户主子样本 ====="
count if relate == 1 & sex == 1
display "  ^ 男性户主人数（上）"

keep if relate == 1 & sex == 1
count

display "  年龄分布："
summarize age, detail

* ============ 4. 迁移份额 p_od ============
preserve
    gen double n = perwt
    collapse (sum) n, by(year o d)
    bysort year o: egen n_o = total(n)
    gen double p_od = n / n_o
    keep year o d n n_o p_od
    tempfile pop
    save "`pop'"
restore

* ============ 5. 平均工资 wage_od ============
keep if incwage > 0 & incwage < 9999990
display "  男性户主中有有效工资的人数："
count

gen double ww = perwt * incwage
collapse (sum) ww perwt, by(year o d)
rename perwt sum_w
gen double wage_od = ww / sum_w
tempfile wag
save "`wag'"

* ============ 6. 合并 ============
use "`pop'", clear
merge 1:1 year o d using "`wag'"
tab _merge
keep if _merge == 3
drop _merge

gen byte obs_prov = (o <= 53)
gen double ln_wage = ln(wage_od)
gen double ln_p    = ln(p_od)

display "===== 6. OD 面板诊断 ====="
count
display "  ^ OD 单元数"
summarize p_od wage_od
summarize n sum_w, detail
count if sum_w < 20
display "  ^ 有效工资人数 < 20 的单元数"

* ============ 7. Fact 3 ============
display "===== 7. Fact 3（16x16，不加权）  论文 = -0.039 ====="
regress ln_wage ln_p i.d i.o if obs_prov == 1

display "===== 7b. Fact 3（16x16，按人口加权）  理论 -1/theta = -0.080 ====="
regress ln_wage ln_p i.d i.o if obs_prov == 1 [aw = n]

display "===== 7c. Fact 3（全样本，不加权） ====="
regress ln_wage ln_p i.d i.o

display "===== 7d. Fact 3（全样本，按人口加权） ====="
regress ln_wage ln_p i.d i.o [aw = n]

* ============ 8. 保存 ============
save "idn_od_panel_malehead.dta", replace
export delimited using "idn_od_panel_malehead.csv", replace

display "=== DONE ==="
log close