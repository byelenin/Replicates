*==============================================================
* 深挖 2：出生地编码 vs 现居地编码 是否同一体系
*==============================================================
clear all
set more off
capture log close
log using "deep2_out.log", replace text

cd "D:\研一上\微观计量\复现"

use year age sex relate perwt geo2_id geo2_id1995 id1995a_bplreg id1995a_prevreg ///
    mig1_5_id mig2_5_id using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995

display _n "==== 1. 取值范围对比 ===="
foreach v in id1995a_bplreg geo2_id1995 geo2_id id1995a_prevreg mig2_5_id {
    quietly summarize `v'
    display "`v'   min=" %12.0f r(min) "   max=" %12.0f r(max)
}

gen long bcode   = id1995a_bplreg
gen long geo_key = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)

display _n "==== 2. geo_key（我们的转换）取值范围 ===="
quietly summarize geo_key
display "geo_key   min=" %12.0f r(min) "   max=" %12.0f r(max)

display _n "==== 3. 三种相等口径下各有多少人（718,837 总数）===="
quietly count if id1995a_bplreg == geo2_id1995
display "id1995a_bplreg == geo2_id1995    : " r(N)
quietly count if id1995a_bplreg == geo_key
display "id1995a_bplreg == geo_key        : " r(N)
quietly count if id1995a_bplreg == id1995a_prevreg
display "id1995a_bplreg == id1995a_prevreg: " r(N)

display _n "==== 4. 出生地县码是否出现在现居县码集合里 ===="
preserve
    keep geo_key
    duplicates drop geo_key, force
    rename geo_key bcode
    tempfile curcodes
    save `curcodes'
restore

gen byte birth_in_current = 0
merge m:1 bcode using `curcodes'
replace birth_in_current = 1 if _merge == 3
quietly tab _merge
drop _merge

display _n "==== 4b. 出生县码在现居编码体系里的比例 ===="
tab birth_in_current [aw=perwt]

display _n "==== 5. 迁移率：按出生县码是否在两套编码的交集里分组 ===="
gen byte moved_reg = (bcode != geo_key) if !missing(bcode)
tab birth_in_current moved_reg [aw=perwt], row

display _n "==== 6. 县层面未加权平均迁移率 ===="
preserve
    keep geo_key moved_reg
    bysort geo_key: egen double mr = mean(moved_reg)
    duplicates drop geo_key, force
    quietly summarize mr
    display "县层面未加权平均迁移率 = " %6.2f r(mean)*100
restore

display _n "==== 7. 5年前居住地口径（mig2_5_id vs geo2_id，两者都已协调边界）===="
capture confirm numeric variable mig2_5_id
if _rc == 0 {
    quietly count if missing(mig2_5_id)
    display "mig2_5_id 缺失人数 = " r(N)
    gen byte moved5 = (mig2_5_id != geo2_id) if !missing(mig2_5_id)
    quietly summarize moved5 [aw=perwt]
    display "5年迁移率（加权）= " %6.2f r(mean)*100
    quietly summarize moved5
    display "5年迁移率（未加权）= " %6.2f r(mean)*100
}

display _n "==== 8. 出生地口径迁移率（对照）===="
quietly summarize moved_reg [aw=perwt]
display "出生地口径 全体加权   = " %6.2f r(mean)*100
quietly summarize moved_reg
display "出生地口径 全体未加权 = " %6.2f r(mean)*100

log close