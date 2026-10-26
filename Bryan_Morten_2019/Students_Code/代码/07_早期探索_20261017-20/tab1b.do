*==============================================================
* Table 1：迁移率与同类内迁移（1995）—— 修正版
*   urban: 1=rural, 2=urban, 9=unknown
*==============================================================
clear all
set more off
capture log close
log using "tab1b_out.log", replace text

use year geo2_id1995 id1995a_bplreg urban perwt ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count

* ---- 关键：去掉出生县码的值标签，否则 merge 会因为标签不一致而 0 匹配 ----
label values id1995a_bplreg .
label values geo2_id1995 .

* ---- 1. 出生县码（原始格式 prov*100+reg），本身就是我们要的 key ----
gen long bcode = id1995a_bplreg

* ---- 2. 迁移标记 ----
gen double geo_key = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
gen byte moved = (geo_key != bcode) if !missing(id1995a_bplreg)
label var moved "现居县 != 出生县"

display ""
display "==== 迁移率（全体，加权，用于交叉核对）===="
tab moved [aw = perwt]

* ---- 3. 每个「现居县」的农村人口占比 -> 定农村县/城市县 ----
display ""
display "==== 县的农村人口占比 ===="
bysort geo2_id1995: egen double tot_pop = total(perwt)
bysort geo2_id1995: egen double rur_pop = total((urban==1)*perwt)
gen double rshare = rur_pop/tot_pop
summarize rshare, detail
local med = r(p50)
display "农村占比中位数 = " `med'

gen byte reg_rural = (rshare > `med')

* ---- 4. 做成查找表（key 用「出生县码」格式）----
preserve
    keep geo2_id1995 reg_rural rshare
    duplicates drop
    gen long bcode = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
    keep bcode reg_rural
    rename reg_rural o_rural
    duplicates drop
    count
    list bcode o_rural in 1/6, noobs
    save "tab1_lookup.dta", replace
restore

* ---- 5. 诊断：查找表本身有没有内容 ----
display ""
display "==== 诊断：查找表 ===="
preserve
    use "tab1_lookup.dta", clear
    count
    summarize bcode
    list in 1/6, noobs
restore

* ---- 6. 合并出生地类别 ----
display ""
display "==== 合并 ===="
merge m:1 bcode using "tab1_lookup.dta", keep(master match) nogen
tab o_rural, missing

* ---- 7. 现居地类别（用个人的 urban）----
gen byte d_rural = (urban == 1)
label var d_rural "现居地是农村(=1)"

* ---- 8. 迁移率（按出生地城乡）----
display ""
display "==== 【论文 Table 1】Migration rate 行 ===="
tab o_rural moved [aw = perwt], row

* ---- 9. 同类内迁移 ----
display ""
display "==== 【论文 Table 1】Moves within category 行 ===="
tab o_rural d_rural if moved == 1 [aw = perwt], row

display ""
display "论文 1995 迁移率：农村 32.3 / 城市 35.8 / 全部 33.7"
display "论文 1995 同类内：农村 31.1 / 城市 74.6 / 全部 49.4"

log close