*==============================================================================
* 对照测试：把出生地 o 的省份范围限制去掉，看 ν(θ) 会不会更接近论文的 12.5
*   设定 A（现状）：o 与 d 都限制在 11-18 / 31-35 / 51-54
*   设定 B（放宽）：只限制 d，o 放开（省级距离表本身覆盖 25 省）
*   估计对象：论文式(7) 的 θ = -1/弹性，用 pi_d-not-o 做工具变量
*   参考：论文印尼 θ = 12.5 (1.36)；我们现状下估出 12.5836
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 140
log using "geo_relax_test_out.log", replace text

local root "D:\研一上\微观计量"
local fz   "`root'\复现"
* program 内部看不到 local，必须用 global
global ROOT "`root'"

import delimited "`fz'\idn_prov_dist25.csv", clear varnames(1)
keep o d dist_km
tempfile dist25
save `dist25'
global DIST25 "`dist25'"
display "  省级距离表：25 省的 " _N " 个 OD 对"

*------------------------------------------------------------------------------
* 建面板的子程序（参数 1 = 是否也限制 o）
*------------------------------------------------------------------------------
capture program drop buildpanel
program define buildpanel
    args restrictO
    local dist25x "$DIST25"
    use year bplid geo1_id incwage perwt relate sex age using "$ROOT\ipumsi_00002.dta", clear
    keep if year == 1995
    keep if sex == 1 & relate == 1 & inrange(age, 15, 65)
    gen int o = bplid
    gen int d = geo1_id - 360000
    * d：现居地本来就只有这 17 个省
    keep if inrange(d, 11, 18) | inrange(d, 31, 35) | inrange(d, 51, 54)
    if `restrictO' == 1 {
        * 现状：对 o 也套用同一范围（这一步是代码设定，不是数据限制）
        keep if inrange(o, 11, 18) | inrange(o, 31, 35) | inrange(o, 51, 54)
    }
    gen byte hasw   = !missing(incwage) & incwage > 0 & incwage < 9999999
    gen double m_w  = perwt
    gen double wx_w = perwt*incwage if hasw
    gen double wg_w = perwt if hasw
    collapse (sum) m_w wx_w wg_w, by(o d)
    rename m_w  m_od
    rename wx_w wsum
    rename wg_w wden
    gen double wage_od = wsum/wden if wden > 0 & !missing(wden)
    drop wsum wden

    bysort o: egen double pop_o  = total(m_od)
    bysort d: egen double m_in_d = total(m_od)
    egen double pop_all = total(m_od)
    gen double pi_do = m_od/pop_o

    preserve
        keep if o == d
        keep o pi_do
        rename pi_do pi_oo
        tempfile go
        save `go'
        rename o d
        rename pi_oo pi_dd
        tempfile gd
        save `gd'
    restore
    preserve
        keep o d pi_do
        rename o _t1
        rename d _t2
        rename _t1 d
        rename _t2 o
        rename pi_do pi_rev
        tempfile rv
        save `rv'
    restore

    gen double pi_dnoto = (m_in_d - m_od)/(pop_all - pop_o) if (pop_all - pop_o) > 0
    keep if o != d
    merge m:1 o using `go', keep(master match) nogen
    merge m:1 d using `gd', keep(master match) nogen
    merge 1:1 o d using `rv', keep(master match) nogen
    merge 1:1 o d using `dist25x', keep(master match) nogen

    keep if !missing(pi_do)     & pi_do     > 0
    keep if !missing(pi_rev)    & pi_rev    > 0
    keep if !missing(pi_oo)     & pi_oo     > 0
    keep if !missing(pi_dd)     & pi_dd     > 0
    keep if !missing(pi_dnoto)  & pi_dnoto  > 0
    keep if !missing(dist_km)   & dist_km   > 0
    gen double ln_p      = ln(pi_do)
    gen double ln_pdnoto = ln(pi_dnoto)
    gen double ln_wage   = ln(wage_od) if !missing(wage_od) & wage_od > 0
end

*------------------------------------------------------------------------------
display _n(2) "{hline 88}"
display "  设定 A：现状（o 与 d 都限制在同一批省份）"
display "{hline 88}"
buildpanel 1
quietly count
display "  OD 单元数 = " r(N)
quietly levelsof o, local(OA)
display "  出发地省数 = " wordcount("`OA'")
tempfile pa
save `pa'

display _n(2) "{hline 88}"
display "  设定 B：放宽（只限制 d，o 放开）"
display "{hline 88}"
buildpanel 0
quietly count
display "  OD 单元数 = " r(N)
quietly levelsof o, local(OB)
display "  出发地省数 = " wordcount("`OB'")
tempfile pb
save `pb'

*------------------------------------------------------------------------------
display _n(2) "{hline 88}"
display "  对比：论文式(7)估出的 ν(θ)"
display "{hline 88}"
display "  论文印尼 θ = 12.5  (1.36)"
display ""
display "  %-14s %10s %10s %12s"  "设定" "出发地省数" "OD 单元数" "式(7) θ"
foreach s in "A `pa'" "B `pb'" {
    local tag : word 1 of `s'
    local f   : word 2 of `s'
    use `f', clear
    quietly count
    local n = r(N)
    quietly levelsof o, local(OL)
    local no : word count `OL'
    quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
    quietly predict double phat, xb
    capture quietly ivregress 2sls ln_wage (ln_p = phat) i.o i.d
    if _rc == 0 {
        local th = -1/_b[ln_p]
        display "  设定 `tag'        `no'      `n'      " %8.4f `th'
    }
    else {
        display "  设定 `tag'  回归失败 rc = " _rc
    }
    capture drop phat
}

display _n(2) "{hline 88}"
log close