*==============================================================
* IPUMS 的县级代码有没有「县名」标签？
* 这决定我们能不能把它匹配到地图上的县质心
*==============================================================
clear all
set more off
capture log close
log using "geoLbl_out.log", replace text

use year geo2_id geo1_id bplid using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count

display ""
display "==================== geo2_id 的值标签 ===================="
capture label list GEO2_ID
if _rc != 0 {
    display "  label list GEO2_ID 失败，rc = " _rc
    display "  试 label list GEO2ID ..."
    capture label list GEO2ID
    if _rc != 0 display "   也失败，rc = " _rc
}

display ""
display "==================== 抽 20 个县看标签长什么样 ===================="
preserve
    keep geo2_id
    duplicates drop
    sort geo2_id
    list geo2_id in 1/20, noobs
    list geo2_id in 180/200, noobs
restore

display ""
display "==================== 同样检查出生省 bplid 的标签 ===================="
capture label list BPLID

log close