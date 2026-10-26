*==============================================================
* 更干净的版本：复用 geo_key，公式只写一次
*==============================================================
clear all
set more off
capture log close
log using "tab1e_out.log", replace text

cd "D:\研一上\微观计量\复现"

use year geo2_id1995 id1995a_bplreg urban perwt using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995

* ---- 公式只出现这一次 ----
gen long bcode   = id1995a_bplreg
gen long geo_key = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
gen byte moved   = (geo_key != bcode) if !missing(id1995a_bplreg)

preserve
    * ---- 这里 keep 的是 geo_key，不是 geo2_id1995 ----
    keep geo_key urban perwt
    bysort geo_key: egen double tot_pop = total(perwt)
    bysort geo_key: egen double rur_pop = total((urban==1)*perwt)
    duplicates drop geo_key, force
    count
    gen double rshare = rur_pop/tot_pop
    summarize rshare, detail
    local med = r(p50)
    display "中位数 = " `med'
    gen byte reg_rural = (rshare > `med')
    tab reg_rural
    * ---- 不需要再换算，geo_key 本来就是出生县码格式 ----
    keep geo_key reg_rural
    rename geo_key   bcode
    rename reg_rural o_rural
    duplicates drop
    count
    save "tab1_lookup.dta", replace
restore

count
merge m:1 bcode using "tab1_lookup.dta", keep(master match) nogen
tab o_rural, missing
gen byte d_rural = (urban == 1)
tab o_rural moved [aw = perwt], row
tab o_rural d_rural if moved == 1 [aw = perwt], row

log close