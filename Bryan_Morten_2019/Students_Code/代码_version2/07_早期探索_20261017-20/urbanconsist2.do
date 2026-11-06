*==============================================================
* urban 一致性检验（修正版）
*==============================================================
clear all
set more off
capture log close
log using "urbanconsist2_out.log", replace text

use year serial urban geo2_id1995 using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995

display _n "==== 1. 有多少个家庭（serial 的唯一值）===="
egen byte tag_hh = tag(serial)
quietly count if tag_hh == 1
display "家庭数 = " r(N)

display _n "==== 2. 每户人数的分布 ===="
bysort serial: gen int hhsize = _N
summarize hhsize if tag_hh == 1, detail

display _n "==== 3. 同一家庭内 urban 是否全部相同 ===="
bysort serial: gen byte same = (urban == urban[1])
bysort serial: egen byte allsame = min(same)
label values allsame .
tab allsame

display _n "==== 4. urban 不一致的家庭数 ===="
count if allsame == 0

display _n "==== 5. 每个县内是否既有农村居民又有城市居民 ===="
preserve
    keep geo2_id1995 urban
    bysort geo2_id1995: egen byte has_rural = max(urban == 1)
    bysort geo2_id1995: egen byte has_urban = max(urban == 2)
    duplicates drop geo2_id1995, force
    label values has_rural .
    label values has_urban .
    gen byte mixed = has_rural & has_urban
    tab mixed
restore

log close