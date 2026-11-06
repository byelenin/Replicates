* ============================================================
* 县级最终检查：只保留「既可能是出生县、又可能是现居县」的县
* （这是省级 16x16 限制的县级版本）
* ============================================================

clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"

log using "regency3_out.log", replace text

use year perwt geo2_id1995 id1995a_bplreg relate sex incwage ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear

keep if year == 1995

gen long o = int(id1995a_bplreg/100)*1000 + mod(id1995a_bplreg,100)
gen long d = geo2_id1995

* ---- 标记「出生县同时也是现居县」的观测 ----
preserve
    keep d
    rename d code
    duplicates drop code, force
    gen byte in_res = 1
    keep code in_res
    tempfile B
    save "`B'"
restore

* 用 merge 标记
preserve
    keep o
    rename o code
    duplicates drop code, force
    merge 1:1 code using "`B'"
    keep if _merge == 3
    keep code
    rename code o
    gen byte keep_me = 1
    tempfile K
    save "`K'"
restore

merge m:1 o using "`K'", keep(master match)
display _n "===== 标记结果 ====="
tab _merge
keep if keep_me == 1
drop _merge keep_me
count
display "  ^ 保留的观测数（出生县同时也是有效现居县）"

* ---- 样本 ----
keep if relate == 1 & sex == 1
count
display "  ^ 男性户主"

* ---- π_do ----
preserve
    gen double n = perwt
    collapse (sum) n, by(o d)
    bysort o: egen n_o = total(n)
    gen double p_od = n / n_o
    bysort o: egen p_check = total(p_od)
    quietly summarize p_check
    display "  【检查】π_do 加总：最小 = " %6.4f r(min) "，最大 = " %6.4f r(max)
    tempfile pop
    save "`pop'"
restore

* ---- 工资 ----
keep if incwage > 0 & incwage < 9999990
count
display "  ^ 有有效工资"

gen double ww = perwt * incwage
collapse (sum) ww perwt, by(o d)
rename perwt sum_w
gen double wage_od = ww / sum_w
tempfile wag
save "`wag'"

use "`pop'", clear
merge 1:1 o d using "`wag'"
tab _merge
keep if _merge == 3
drop _merge

count
display "  ^ 县级 OD 单元数（有工资）"

summarize sum_w, detail
foreach k in 100 50 20 10 {
    quietly count if sum_w < `k'
    display "  工资人数 < `k' 的单元数：" r(N)
}

* ---- Fact 3 ----
gen double ln_wage = ln(wage_od)
gen double ln_p    = ln(p_od)

display _n "===== 县级 Fact 3（严格版）  论文目标 = -0.039 ====="

display _n "  (a) 不加权"
regress ln_wage ln_p i.d i.o

display _n "  (b) 按人口加权"
regress ln_wage ln_p i.d i.o [aw = n]

display _n "===== 完成 ====="
log close