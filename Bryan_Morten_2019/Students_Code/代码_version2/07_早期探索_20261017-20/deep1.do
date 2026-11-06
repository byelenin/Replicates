*==============================================================
* 深挖 1：变量定义 + 编码粒度
*==============================================================
clear all
set more off
capture log close
log using "deep1_out.log", replace text

cd "D:\研一上\微观计量\复现"

use year serial pernum geo1_id geo2_id geo2_id1995 bplid ///
    id1995a_bplreg id1995a_prevprov id1995a_prevreg ///
    mig1_p_id mig1_5_id mig2_5_id ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear

display _n "==== 1. 官方变量标签 ===="
foreach v in geo1_id geo2_id geo2_id1995 bplid id1995a_bplreg id1995a_prevprov id1995a_prevreg mig1_p_id mig1_5_id mig2_5_id {
    local lb : variable label `v'
    display "`v'  ->  `lb'"
}

keep if year == 1995

display _n "==== 2. 各变量的不同取值个数（编码粒度）===="
foreach v in geo1_id geo2_id geo2_id1995 id1995a_bplreg id1995a_prevprov id1995a_prevreg {
    quietly levelsof `v', local(lv)
    local k : word count `lv'
    display "`v'  不同取值 = `k'"
}

display _n "==== 3. 家庭内一致性：出生地/上次居住地是个人的还是家庭的 ===="
foreach v in id1995a_bplreg id1995a_prevreg geo2_id1995 {
    capture drop same_`v' allsame_`v'
    bysort serial: gen byte same_`v' = (`v' == `v'[1])
    bysort serial: egen byte allsame_`v' = min(same_`v')
    label values allsame_`v' .
    display _n "---- `v' 在家庭内是否全同 ----"
    tab allsame_`v'
}

log close