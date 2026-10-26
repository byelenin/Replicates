*==============================================================
* Table 1：迁移率与同类内迁移（1995）
*==============================================================
clear all
set more off
capture log close
log using "tab1_out.log", replace text

use year geo2_id1995 id1995a_bplreg urban perwt ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count

display ""
display "==== urban 变量的取值 ===="
tab urban, missing
display "==== urban 的值标签 ===="
label list URBAN

* ---- 1. 出生县码 -> 和现居县码同格式 ----
gen double bpl_now = floor(id1995a_bplreg/100)*1000 + mod(id1995a_bplreg,100)
replace bpl_now = . if missing(id1995a_bplreg)

* ---- 2. 迁移标记 ----
gen byte moved = (geo2_id1995 != bpl_now) if !missing(bpl_now)
label var moved "现居县 != 出生县"

display ""
display "==== 迁移率（全体，加权）===="
tab moved [aw = perwt]

display ""
display "==== 交叉检查：未迁移者的 bpl_now 是否等于 geo2_id1995 ===="
count if moved == 0
count if bpl_now == geo2_id1995

* ---- 3. 每个县的农村人口占比 ----
display ""
display "==== 建县级别（农村/城市）===="
preserve
    keep geo2_id1995 urban perwt
    drop if missing(geo2_id1995) | missing(urban)
    gen double pop_rural = (urban == 1) * perwt
    collapse (sum) pop_rural perwt, by(geo2_id1995)
    gen double rural_share = pop_rural / perwt
    summarize rural_share, detail
    local med = r(p50)
    display "农村占比的中位数 = " `med'
    gen byte reg_rural = (rural_share > `med')
    tab reg_rural
    keep geo2_id1995 reg_rural
    gen long bpl_key = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
    tempfile rk
    save `rk'
restore

* ---- 4. 出生地类别 ----
rename bpl_now bpl_key
merge m:1 bpl_key using `rk', keep(master match) nogen
rename reg_rural o_rural
label var o_rural "出生县是农村(=1)"

* ---- 5. 现居地类别（用个人的 urban）----
gen byte d_rural = (urban == 1)
label var d_rural "现居地是农村(=1)"

display ""
display "==== 样本里出生地类别缺失多少 ===="
tab o_rural, missing

* ---- 6. 迁移率（按出生地城乡）----
display ""
display "==== 【论文 Table 1】迁移率 行 ===="
tab o_rural moved [aw = perwt], row

* ---- 7. 同类内迁移 ----
display ""
display "==== 【论文 Table 1】Moves within category 行 ===="
tab o_rural d_rural if moved == 1 [aw = perwt], row

* ---- 8. 对照论文 ----
display ""
display "论文 1995：迁移率  农村 32.3 / 城市 35.8 / 全部 33.7"
display "论文 1995：同类内  农村 31.1 / 城市 74.6 / 全部 49.4"

log close