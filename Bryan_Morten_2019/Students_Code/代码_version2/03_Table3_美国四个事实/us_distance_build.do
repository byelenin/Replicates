*==============================================================================
*  交付版说明：输出写到输入所在目录（`fz`），即与两个输入 CSV 同目录；
*  若你的数据放在别处，只需改上面的 local fz 一行。
*  生成【现成的】美国州间距离表  us_state_distance.csv
*  公式与 Table3US_replication.do L85-L89 逐字一致（Haversine, R=6371 km）
*  输入：us_state_centroids.csv（州面积加权质心）+ us_state_fips2usps.csv
*  输出：usps_o, o, usps_d, d, dist_km      （删掉同州 o=d，与 L172 一致）
*==============================================================================
clear all
set linesize 150
local fz "D:\研一上\微观计量\复现"
local out "`fz'\us_state_distance.csv"

* ---------- 1. FIPS <-> USPS 对照 ----------
import delimited "`fz'\us_state_fips2usps.csv", clear varnames(1)
destring state_fips, replace
rename state_fips o
tempfile f2u
save `f2u'
quietly count
display _n "===== 1. FIPS↔USPS 对照表：`r(N)' 行 ====="

* ---------- 2. 目的地质心 ----------
import delimited "`fz'\us_state_centroids.csv", clear varnames(1)
keep usps lat lon
merge 1:1 usps using `f2u', keep(match) nogen
rename usps usps_d
rename o d
rename lat lat_d
rename lon lon_d
keep usps_d d lat_d lon_d
tempfile c_d
save `c_d'
quietly count
display "  目的地质心：`r(N)' 个州"

* ---------- 3. 出发地质心 ----------
import delimited "`fz'\us_state_centroids.csv", clear varnames(1)
keep usps lat lon
merge 1:1 usps using `f2u', keep(match) nogen
rename usps usps_o
rename lat lat_o
rename lon lon_o
keep usps_o o lat_o lon_o
tempfile c_o
save `c_o'
quietly count
display "  出发地质心：`r(N)' 个州"

* ---------- 4. 全州对 + Haversine（照抄 L85-L89）----------
use `c_o', clear
cross using `c_d'
quietly count
display _n "===== 2. 全部州对（含同州）：`r(N)' 对 ====="

gen double _pio = _pi/180
gen double _dla = (lat_d - lat_o)*_pio
gen double _dlo = (lon_d - lon_o)*_pio
gen double _a   = sin(_dla/2)^2 + cos(lat_o*_pio)*cos(lat_d*_pio)*sin(_dlo/2)^2
gen double dist_km = 2*6371*asin(min(1, sqrt(_a)))
drop _pio _dla _dlo _a

* ---------- 5. 删同州（与 Table3US_replication.do L172 一致）----------
quietly count if dist_km == 0
display "  同州（距离=0）对数：`r(N)'  → 删除"
keep if dist_km > 0
order usps_o o usps_d d dist_km
sort o d
quietly count
display _n "===== 3. 最终州对：`r(N)' 对（应为 州数×(州数−1)）====="

* ---------- 6. 体检 ----------
quietly summarize dist_km
display _n "  dist_km  min = " %10.3f r(min) "   max = " %10.1f r(max) "   均值 = " %10.1f r(mean)

* 对称性：A→B 与 B→A 必须相等
preserve
    keep o d dist_km
    rename o oa
    rename d da
    rename dist_km dist_a
    tempfile fwd
    save `fwd'
restore
preserve
    keep o d dist_km
    rename o da
    rename d oa
    rename dist_km dist_b
    merge 1:1 oa da using `fwd', keep(match) nogen
    gen double asym = abs(dist_a - dist_b)
    quietly summarize asym
    display "  对称性检验 |A→B − B→A| 最大值 = " %12.4e r(max)
restore

* 抽查若干已知州对
display _n "  抽查："
foreach p in "6 36" "48 36" "17 36" "12 13" {
    local a : word 1 of `p'
    local b : word 2 of `p'
    quietly summarize dist_km if o == `a' & d == `b', meanonly
    if r(N) > 0 {
        display "     FIPS `a' → `b' ： " %10.1f r(mean) " km"
    }
}

* ---------- 7. 导出 ----------
export delimited usps_o o usps_d d dist_km using "`out'", replace
display _n "  已导出：`out'"
capture confirm file "`out'"
if _rc == 0 {
    display "  文件大小：待外部确认"
}