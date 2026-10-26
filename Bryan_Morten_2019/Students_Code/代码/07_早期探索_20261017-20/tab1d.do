*==============================================================
* Table 1 最终版 —— 删掉那两行 label values
*==============================================================
clear all
set more off
capture log close
log using "tab1d_out.log", replace text

cd "D:\研一上\微观计量\复现"

use year geo2_id1995 id1995a_bplreg urban perwt using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count

* ---- 注意：这两行 label values 已经删掉了 ----

gen long bcode = id1995a_bplreg
gen long geo_key = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
gen byte moved = (geo_key != bcode) if !missing(id1995a_bplreg)

preserve
    keep geo2_id1995 urban perwt
    bysort geo2_id1995: egen double tot_pop = total(perwt)
    bysort geo2_id1995: egen double rur_pop = total((urban==1)*perwt)
    duplicates drop geo2_id1995, force
    count
    gen double rshare = rur_pop/tot_pop
    summarize rshare, detail
    local med = r(p50)
    display "中位数 = " `med'
    gen byte reg_rural = (rshare > `med')
    tab reg_rural
    keep geo2_id1995 reg_rural
    gen long bcode = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
    keep bcode reg_rural
    rename reg_rural o_rural
    duplicates drop
    count
    save "tab1_lookup.dta", replace
restore

count

merge m:1 bcode using "tab1_lookup.dta", keep(master match) nogen
tab o_rural, missing

gen byte d_rural = (urban == 1)

display _n "==== 迁移率 ===="
tab o_rural moved [aw = perwt], row

display _n "==== 同类内迁移 ===="
tab o_rural d_rural if moved == 1 [aw = perwt], row

log close