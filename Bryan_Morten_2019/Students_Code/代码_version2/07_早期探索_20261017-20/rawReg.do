*==============================================================
* 探明「原始县代码」能到多少分辨率
*   id1995a_bplreg  = 出生县（原始 1995 代码）
*   id1995a_prevreg = 前居住县（原始 1995 代码）
*   geo2_id1995     = 现居县（IPUMS 协调代码，只有 221）
* 目标：解码出县名，看能否匹配到坐标
*==============================================================
clear all
set more off
capture log close
log using "rawReg_out.log", replace text

use year geo2_id1995 id1995a_bplreg id1995a_prevreg ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
count

* ---- 解码三套编码 ----
capture decode id1995a_bplreg, gen(bplname)
display "decode bplreg  rc = " _rc
capture decode id1995a_prevreg, gen(prevname)
display "decode prevreg rc = " _rc
capture decode geo2_id1995, gen(nowname)
display "decode geo2_id1995 rc = " _rc

foreach v in id1995a_bplreg id1995a_prevreg geo2_id1995 {
    qui levelsof `v', local(lv)
    local n : word count `lv'
    display "`v' 的不同取值数 = `n'"
}

* ---- 导出三套县名清单 ----
preserve
    keep id1995a_bplreg bplname
    duplicates drop
    drop if missing(id1995a_bplreg)
    rename id1995a_bplreg code
    gen long prov = floor(code/100)
    export delimited code prov bplname using "..\..\idn_geo\raw_bplreg_names.csv", replace nolabel
    count
    display "  -> 出生县清单已导出，N = " r(N)
restore

preserve
    keep id1995a_prevreg prevname
    duplicates drop
    drop if missing(id1995a_prevreg)
    rename id1995a_prevreg code
    gen long prov = floor(code/100)
    export delimited code prov prevname using "..\..\idn_geo\raw_prevreg_names.csv", replace nolabel
    count
    display "  -> 前居住县清单已导出，N = " r(N)
restore

preserve
    keep geo2_id1995 nowname
    duplicates drop
    drop if missing(geo2_id1995)
    rename geo2_id1995 code
    gen long prov = floor(code/1000)
    export delimited code prov nowname using "..\..\idn_geo\geo1995_names.csv", replace nolabel
    count
    display "  -> 现居县清单已导出，N = " r(N)
restore

* ---- 三套编码的县名是否一致？抽 25 个看 ----
display ""
display "==== 三套编码对照（同一批人，前 25 个非缺失）===="
preserve
    keep if !missing(id1995a_bplreg) & !missing(geo2_id1995)
    keep id1995a_bplreg bplname geo2_id1995 nowname
    duplicates drop
    sort id1995a_bplreg
    list id1995a_bplreg bplname geo2_id1995 nowname in 1/25, noobs
restore

log close