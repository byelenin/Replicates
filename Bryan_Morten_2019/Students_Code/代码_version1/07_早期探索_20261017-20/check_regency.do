* ============================================================
* 可行性检查：BM2019 县级（regency）复现到底能不能做
* 数据：ipumsi_00002.dta（含 1995 + 2010，37 变量）
* 说明：这是一个一次性的诊断脚本，不产出交付物。
* ============================================================

clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"

log using "check_regency_out.log", replace text

* ---------- 1. 读入县級相关变量（先读全部年份，再筛 1995）----------
use year perwt geo2_id geo2_id1995 id1995a_bplreg relate sex incwage ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear

display _n "===== 1. 读入 ====="
count
tab year

keep if year == 1995
count
display "  ^ 1995 年观测数"

tab relate
tab sex


* ---------- 2. 县級变量的覆盖：有多少个不同的县 ----------
display _n "===== 2. 县級变量覆盖 ====="

foreach v in geo2_id geo2_id1995 id1995a_bplreg {
    capture confirm variable `v'
    if _rc {
        display "★ 变量 `v' 不存在！"
        continue
    }
    quietly count if missing(`v')
    display _n "`v'：缺失 = " r(N)
    capture drop tagtmp
    egen tagtmp = tag(`v')
    quietly count if tagtmp == 1
    display "`v'：不同取值数 = " r(N)
    quietly summarize `v'
    display "`v'：取值范围 " r(min) " 到 " r(max)
    drop tagtmp
}


* ---------- 3. 建县級 OD 面板 ----------
display _n "===== 3. 建县級 OD 面板 ====="

gen long o = id1995a_bplreg
gen long d = geo2_id

count if missing(o) | missing(d)
display "  ^ 县级地理缺失的观测数"

drop if missing(o) | missing(d)
count
display "  ^ 有完整县级地理信息的观测数"

keep if relate == 1 & sex == 1
count
display "  ^ 男性户主（县級分析样本）"


* ---------- 4. π_do ----------
preserve
    gen double n = perwt
    collapse (sum) n, by(o d)
    bysort o: egen n_o = total(n)
    gen double p_od = n / n_o

    bysort o: egen p_check = total(p_od)
    quietly summarize p_check
    display _n "  【检查】π_do 按出生县加总：最小 = " %6.4f r(min) ///
             "，最大 = " %6.4f r(max)

    keep o d n n_o p_od
    tempfile pop
    save "`pop'"
restore


* ---------- 5. 工资 ----------
keep if incwage > 0 & incwage < 9999990
count
display "  ^ 有有效工资的男性户主"

gen double ww = perwt * incwage
collapse (sum) ww perwt, by(o d)
rename perwt sum_w
gen double wage_od = ww / sum_w
tempfile wag
save "`wag'"


* ---------- 6. 合并 ----------
use "`pop'", clear
merge 1:1 o d using "`wag'"

display _n "===== 6. 合并 ====="
tab _merge

keep if _merge == 3
drop _merge


* ---------- 7. 诊断：格子大小 ----------
display _n "===== 7. 县級 OD 单元诊断 ====="

count
display "  ^ 县級 OD 单元数（有工资的）"

summarize sum_w, detail

foreach k in 100 50 20 10 5 2 {
    quietly count if sum_w < `k'
    display "  工资人数 < `k' 的单元数：" r(N)
}

quietly count if sum_w >= 2 & sum_w < 20
display "  工资人数在 2-19 之间的单元数：" r(N)


* ---------- 8. Fact 3 能不能估出来 ----------
display _n "===== 8. 县級 Fact 3 回归 ====="

gen double ln_wage = ln(wage_od)
gen double ln_p    = ln(p_od)

display "  (a) 不加权，有 i.o i.d 固定效应"
regress ln_wage ln_p i.d i.o

display _n "  (b) 按人口加权"
regress ln_wage ln_p i.d i.o [aw = n]


* ---------- 9. 出生县编码 vs 现居县编码 是否可比 ----------
display _n "===== 9. 出生县 vs 现居县 编码可比性 ====="

use "`pop'", clear

preserve
    keep o
    rename o code
    duplicates drop code, force
    gen byte is_o = 1
    keep code is_o
    tempfile oc
    save "`oc'"
restore

preserve
    keep d
    rename d code
    duplicates drop code, force
    gen byte is_d = 1
    keep code is_d
    tempfile dc
    save "`dc'"
restore

use "`oc'", clear
merge 1:1 code using "`dc'"
tab _merge

display _n "===== 检查完成 ====="

log close