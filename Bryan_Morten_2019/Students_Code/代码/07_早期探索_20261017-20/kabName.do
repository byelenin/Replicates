*==============================================================
* 导出 IPUMS 1995 的 221 个「一致边界县」代码 + 完整县名
* 目的：和 idn_kabupaten_coords.csv（514 个县）做名字匹配
*==============================================================
clear all
set more off
capture log close
log using "kabName_out.log", replace text

use year geo2_id geo2_id1995 id1995a_bplreg using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count

* ---- 把值标签解码成字符串（decode 会给出完整名字）----
capture decode geo2_id, gen(kabname)
if _rc != 0 {
    display "decode geo2_id 失败 rc=" _rc
    exit
}
capture decode geo2_id1995, gen(name95)
if _rc != 0 {
    display "decode geo2_id1995 失败 rc=" _rc
    exit
}

* ---- 现居县清单 ----
preserve
    keep geo2_id geo2_id1995 kabname name95
    duplicates drop
    sort geo2_id1995
    count
    gen long prov = floor(geo2_id1995/1000)
    * nolabel: 导出数字代码而不是值标签文字
    export delimited geo2_id geo2_id1995 prov name95 kabname using "..\..\idn_geo\ipums1995_regency_names.csv", replace nolabel
    display ""
    display "==== name95（1995 年那个县本身的英文名）前 20 个 ===="
    list geo2_id1995 name95 in 1/20, noobs
restore

* ---- 出生县清单 ----
preserve
    keep id1995a_bplreg
    rename id1995a_bplreg bplreg
    duplicates drop
    count
    display ""
    display "==== 出生县代码个数（上面 count）===="
restore

log close