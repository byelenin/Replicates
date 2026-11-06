* ============================================================
* 县级复现（修正版）——编码对齐之后再做
*   o = id1995a_bplreg 转换后  （省2 + 县3）
*   d = geo2_id1995           （省2 + 县3）
* ============================================================

clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"

log using "regency2_out.log", replace text

use year perwt geo2_id geo2_id1995 id1995a_bplreg relate sex incwage ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear

keep if year == 1995
count

* ---------- 编码转换 ----------
gen long o = int(id1995a_bplreg/100)*1000 + mod(id1995a_bplreg,100)
gen long d = geo2_id1995

label var o "出生县（转换后）"
label var d "现居县"

* ---------- A. 编码集合是否可比 ----------
display _n "===== A. 出生县编码集合 vs 现居县编码集合 ====="

preserve
    keep o
    rename o code
    duplicates drop code, force
    gen byte in_bpl = 1
    keep code in_bpl
    tempfile A
    save "`A'"
restore

preserve
    keep d
    rename d code
    duplicates drop code, force
    gen byte in_res = 1
    keep code in_res
    tempfile B
    save "`B'"
restore

preserve
    use "`A'", clear
    merge 1:1 code using "`B'"
    tab _merge
    display "  说明：matched = 出生县编码同时也是有效的现居县编码"
restore

* ---------- B. 抽查 id1995a_bplreg 的高位取值 ----------
display _n "===== B. id1995a_bplreg 的取值抽查 ====="
preserve
    keep id1995a_bplreg
    duplicates drop
    quietly count
    display "  不同取值数 = " r(N)
    sort id1995a_bplreg
    display "  最小的 10 个："
    list id1995a_bplreg in 1/10, noobs
    display "  最大的 10 个："
    quietly count
    local n = r(N)
    local m = `n' - 9
    list id1995a_bplreg in `m'/`n', noobs
restore

* ---------- C. 迁移率（关键！）----------
display _n "===== C. 非迁移者 vs 迁移者 ====="

count if o == d
display "  出生县 == 现居县（没迁移）= " r(N)
count
display "  总观测数 = " r(N)

quietly count if o == d
scalar same = r(N)
quietly count
scalar tot = r(N)
display "  非迁移比例 = " %6.4f same/tot

* ---------- D. 县级 OD 面板 ----------
display _n "===== D. 县级 OD 面板 ====="

keep if relate == 1 & sex == 1
count
display "  ^ 男性户主"

preserve
    gen double n = perwt
    collapse (sum) n, by(o d)
    bysort o: egen n_o = total(n)
    gen double p_od = n / n_o

    bysort o: egen p_check = total(p_od)
    quietly summarize p_check
    display "  【检查】π_do 按出生县加总：最小 = " %6.4f r(min) ///
             "，最大 = " %6.4f r(max)

    count
    display "  ^ OD 单元总数（有人住的）"

    tempfile pop
    save "`pop'"
restore

keep if incwage > 0 & incwage < 9999990
count
display "  ^ 有有效工资的男性户主"

gen double ww = perwt * incwage
collapse (sum) ww perwt, by(o d)
rename perwt sum_w
gen double wage_od = ww / sum_w
tempfile wag
save "`wag'"

use "`pop'", clear
merge 1:1 o d using "`wag'"

display _n "===== D2. 合并 ====="
tab _merge

keep if _merge == 3
drop _merge

count
display "  ^ 有工资的县级 OD 单元数"

summarize sum_w, detail

foreach k in 100 50 20 10 5 2 {
    quietly count if sum_w < `k'
    display "  工资人数 < `k' 的单元数：" r(N)
}

* ---------- E. Fact 3 ----------
display _n "===== E. 县级 Fact 3（修正后）  论文目标 = -0.039 ====="

gen double ln_wage = ln(wage_od)
gen double ln_p    = ln(p_od)

display _n "  (a) 不加权"
regress ln_wage ln_p i.d i.o

display _n "  (b) 按人口加权"
regress ln_wage ln_p i.d i.o [aw = n]

* ---------- F. 稳健性：砍掉小格子 ----------
display _n "===== F. 稳健性：只保留工资人数 >= 20 的单元 ====="

display _n "  (a) 不加权"
regress ln_wage ln_p i.d i.o if sum_w >= 20

display _n "  (b) 按人口加权"
regress ln_wage ln_p i.d i.o if sum_w >= 20 [aw = n]

display _n "===== 完成 ====="

log close