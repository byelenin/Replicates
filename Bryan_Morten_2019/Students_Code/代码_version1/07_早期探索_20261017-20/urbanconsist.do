*==============================================================
* urban 是「个人主观填报」还是「按地区统一指定」？
*   检验：同一个家庭（同一个居住地）里，urban 是否完全一致
*==============================================================
clear all
set more off
capture log close
log using "urbanconsist_out.log", replace text

use year serial urban geo2_id1995 using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995

display _n "==== 1. urban 的取值分布（有没有 unknown）===="
tab urban

display _n "==== 2. 家庭数 ===="
codebook serial, compact

display _n "==== 3. 同一家庭内 urban 是否全部相同 ===="
bysort serial: gen byte same = (urban == urban[1])
bysort serial: egen byte allsame = min(same)
label var allsame "全家 urban 都相同"
tab allsame

display _n "==== 4. urban 不一致的家庭数 ===="
count if allsame == 0

display _n "==== 5. 每个县内，urban 是否既有 1 又有 2（说明县内分村）===="
preserve
    keep geo2_id1995 urban
    bysort geo2_id1995: egen byte has_rural = min(urban == 1)
    bysort geo2_id1995: egen byte has_urban = max(urban == 2)
    duplicates drop geo2_id1995, force
    gen byte mixed = has_rural & has_urban
    label var mixed "这个县里既有农村居民又有城市居民"
    tab mixed
restore

log close