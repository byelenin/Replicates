*==============================================================
* 按用户的改法修正后的完整 Table 1
*==============================================================
clear all
set more off
capture log close
log using "tab1f_out.log", replace text

cd "D:\研一上\微观计量\复现"

use year geo2_id1995 id1995a_bplreg urban perwt ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count

gen long bcode = id1995a_bplreg
gen long geo_key = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
gen byte moved = (geo_key != bcode) if !missing(id1995a_bplreg)

preserve
    keep geo_key urban perwt
    bysort geo_key: egen double tot_pop = total(perwt)
    bysort geo_key: egen double rur_pop = total((urban==1)*perwt)
    duplicates drop geo_key, force
    count
    gen double rshare = rur_pop/tot_pop
    summarize rshare, detail
    local med = r(p50)
    display "农村占比中位数（按县）= " `med'
    gen byte o_rural = (rshare > `med')
    tab o_rural
    keep geo_key o_rural
    rename geo_key bcode
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