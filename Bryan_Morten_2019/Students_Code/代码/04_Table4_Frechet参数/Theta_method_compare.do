* ==============================================================================
*  θ 的三种估计方法对比（快速版，不做 bootstrap）
*    方法①  对数 2SLS + 固定效应虚拟变量   ← 我们现在用的
*    方法②  PPML + 双向固定效应（无 IV）    ← 看内生性偏误有多大
*    方法③  PPML + 双向固定效应 + 控制函数 IV ← 最接近论文
*
*  面板构造完全照抄 Table3_replication.do 的 §1/§2/§3，口径一致。
* ==============================================================================
clear all
set more off
set linesize 150
set matsize 2000

local root   "D:\研一上\微观计量"
local fz     "D:\研一上\微观计量\复现"
local ussrc  "C:\Users\任娜\Documents\deepseek-harness\default-workspace\usa_od.csv"

log using "`fz'\theta_compare_out.log", replace text

display "{hline 78}"
display "  θ 估计方法对比：对数 2SLS  vs  PPML  vs  PPML+IV"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 78}"

*==============================================================================
* 1. 读取距离数据
*==============================================================================
display _n "===== 1. 读取距离数据 ====="

import delimited "`fz'\idn_prov_dist25.csv", clear varnames(1)
destring o, replace
destring d, replace
destring dist_km, replace force
keep o d dist_km
tempfile iddist
save `iddist'
quietly count
display "  印尼省级距离：`r(N)' 个 OD 对"

import delimited "`fz'\us_state_fips2usps.csv", clear varnames(1)
destring state_fips, replace
rename state_fips o
tempfile f2u
save `f2u'

import delimited "`fz'\us_state_centroids.csv", clear varnames(1)
keep usps lat lon
merge 1:1 usps using `f2u', keep(match) nogen
keep o lat lon
rename lat lat_o
rename lon lon_o
rename o d
rename lat_o lat_d
rename lon_o lon_d
tempfile c_d
save `c_d'

import delimited "`fz'\us_state_centroids.csv", clear varnames(1)
keep usps lat lon
merge 1:1 usps using `f2u', keep(match) nogen
keep o lat lon
rename lat lat_o
rename lon lon_o
tempfile c_o
save `c_o'

use `c_o', clear
cross using `c_d'
gen double _pio = _pi/180
gen double _dla = (lat_d - lat_o)*_pio
gen double _dlo = (lon_d - lon_o)*_pio
gen double _a = sin(_dla/2)^2 + cos(lat_o*_pio)*cos(lat_d*_pio)*sin(_dlo/2)^2
gen double dist_km = 2*6371*asin(min(1, sqrt(_a)))
keep o d dist_km
tempfile usdist
save `usdist'

*==============================================================================
* 2. 美国州级 OD 面板
*==============================================================================
display _n "===== 2. 美国州级 OD 面板 ====="

import delimited "`ussrc'", clear varnames(1) colrange(1:5)

capture destring o, replace
capture destring d, replace
capture destring year, replace
capture destring wage, replace force
capture destring w, replace force

keep o d year wage w
drop if missing(o) | missing(d) | missing(year)
drop if missing(w) | w <= 0
keep if inrange(year, 1990, 2010)

gen byte hasw = !missing(wage) & wage > 0
gen double m_w  = w
gen double wx_w = w*wage if hasw
gen double wg_w = w if hasw

collapse (sum) m_w wx_w wg_w, by(o d year)
rename m_w  m_od
rename wx_w wsum
rename wg_w wden
gen double wage_od = wsum/wden if wden > 0 & !missing(wden)
drop wsum wden

bysort o year: egen double pop_o  = total(m_od)
bysort d year: egen double m_in_d = total(m_od)
bysort year:  egen double pop_all = total(m_od)
gen double pi_do = m_od/pop_o

preserve
    keep if o == d
    keep o year pi_do
    rename pi_do pi_oo
    tempfile udg_o
    save `udg_o'
    rename o d
    rename pi_oo pi_dd
    tempfile udg_d
    save `udg_d'
restore

preserve
    keep o d year pi_do
    rename o _t1
    rename d _t2
    rename _t1 d
    rename _t2 o
    rename pi_do pi_rev
    tempfile urev
    save `urev'
restore

gen double pi_dnoto = (m_in_d - m_od)/(pop_all - pop_o) if (pop_all - pop_o) > 0

keep if o != d
merge m:1 o year using `udg_o', keep(master match) nogen
merge m:1 d year using `udg_d', keep(master match) nogen
merge 1:1 o d year using `urev', keep(master match) nogen
merge m:1 o d using `usdist', keep(master match) nogen

keep if !missing(pi_do) & pi_do > 0
keep if !missing(pi_rev) & pi_rev > 0
keep if !missing(pi_oo) & pi_oo > 0
keep if !missing(pi_dd) & pi_dd > 0
keep if !missing(pi_dnoto) & pi_dnoto > 0
keep if !missing(dist_km) & dist_km > 0

gen double ln_p      = ln(pi_do)
gen double ln_p_rev  = ln(pi_rev)
gen double ln_poo    = ln(pi_oo)
gen double ln_pdd    = ln(pi_dd)
gen double ln_pdnoto = ln(pi_dnoto)
gen double ln_dist   = ln(dist_km)
gen double ln_wage   = ln(wage_od) if !missing(wage_od) & wage_od > 0

tempfile uspanel
save `uspanel'
display "  美国面板已存"

*==============================================================================
* 3. 印尼省级 OD 面板
*==============================================================================
display _n "===== 3. 印尼省级 OD 面板 ====="

use year bplid geo1_id incwage perwt relate sex age using "`root'\ipumsi_00002.dta", clear
keep if year == 1995
keep if sex == 1 & relate == 1 & inrange(age, 15, 65)
gen int o = bplid
gen int d = geo1_id - 360000
keep if inrange(o, 11, 18) | inrange(o, 31, 35) | inrange(o, 51, 54)
keep if inrange(d, 11, 18) | inrange(d, 31, 35) | inrange(d, 51, 54)

gen byte hasw = !missing(incwage) & incwage > 0 & incwage < 9999999
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
    tempfile idg_o
    save `idg_o'
    rename o d
    rename pi_oo pi_dd
    tempfile idg_d
    save `idg_d'
restore

preserve
    keep o d pi_do
    rename o _t1
    rename d _t2
    rename _t1 d
    rename _t2 o
    rename pi_do pi_rev
    tempfile irev
    save `irev'
restore

gen double pi_dnoto = (m_in_d - m_od)/(pop_all - pop_o) if (pop_all - pop_o) > 0

keep if o != d
merge m:1 o using `idg_o', keep(master match) nogen
merge m:1 d using `idg_d', keep(master match) nogen
merge 1:1 o d using `irev', keep(master match) nogen
merge 1:1 o d using `iddist', keep(master match) nogen

keep if !missing(pi_do) & pi_do > 0
keep if !missing(pi_rev) & pi_rev > 0
keep if !missing(pi_oo) & pi_oo > 0
keep if !missing(pi_dd) & pi_dd > 0
keep if !missing(pi_dnoto) & pi_dnoto > 0
keep if !missing(dist_km) & dist_km > 0

gen double ln_p      = ln(pi_do)
gen double ln_p_rev  = ln(pi_rev)
gen double ln_poo    = ln(pi_oo)
gen double ln_pdd    = ln(pi_dd)
gen double ln_pdnoto = ln(pi_dnoto)
gen double ln_dist   = ln(dist_km)
gen double ln_wage   = ln(wage_od) if !missing(wage_od) & wage_od > 0

tempfile idpanel
save `idpanel'
quietly count
display "  印尼面板：`r(N)' 个 OD 对"

*==============================================================================
* 4. 子程序：把三种方法都跑一遍
*==============================================================================
capture program drop thetacmp
program define thetacmp
    args tag cl
    display _n(2) "{hline 78}"
    display "  【`tag'】"
    display "{hline 78}"

    quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
    local r2z = e(r2)
    quietly predict double phat, xb
    display "  零阶段 R² = " %6.4f `r2z'

    quietly count if !missing(ln_wage)
    local n1 = r(N)
    quietly capture ivregress 2sls ln_wage (ln_p = phat) i.o i.d, cluster(`cl')
    if _rc == 0 {
        local b1 = _b[ln_p]
        if `b1' < 0 {
            display "  ① 对数 2SLS + 虚拟变量：   β = " %10.6f `b1' "   θ = " %10.4f -1/`b1' "   N = `n1'"
        }
        else {
            display "  ① 对数 2SLS + 虚拟变量：   β = " %10.6f `b1' "   θ 无解（β 为正）"
        }
    }
    else {
        display "  ① 对数 2SLS 失败，返回码 `=_rc'"
    }

    quietly capture ppmlhdfe wage_od ln_p, absorb(o d) cluster(`cl')
    if _rc == 0 {
        local b2 = _b[ln_p]
        local n2 = e(N)
        if `b2' < 0 {
            display "  ② PPML + 双向固定效应：    β = " %10.6f `b2' "   θ = " %10.4f -1/`b2' "   N = `n2'"
        }
        else {
            display "  ② PPML + 双向固定效应：    β = " %10.6f `b2' "   θ 无解（β 为正）"
        }
    }
    else {
        display "  ② PPML 失败，返回码 `=_rc'"
    }

    quietly capture reghdfe ln_p phat, absorb(o d) residuals(u)
    if _rc == 0 {
        quietly capture ppmlhdfe wage_od ln_p u, absorb(o d) cluster(`cl')
        if _rc == 0 {
            local b3 = _b[ln_p]
            local n3 = e(N)
            if `b3' < 0 {
                display "  ③ PPML + 控制函数 IV：      β = " %10.6f `b3' "   θ = " %10.4f -1/`b3' "   N = `n3'"
            }
            else {
                display "  ③ PPML + 控制函数 IV：      β = " %10.6f `b3' "   θ 无解（β 为正）"
            }
        }
        else {
            display "  ③ PPML 第二阶段失败，返回码 `=_rc'"
        }
    }
    else {
        display "  ③ 第一阶段 reghdfe 失败，返回码 `=_rc'"
    }
end

*==============================================================================
* 5. 印尼
*==============================================================================
use `idpanel', clear
thetacmp "印尼 1995（17 个省）" o
display "    论文 θ = 12.5  （SE 1.73）"

*==============================================================================
* 6. 美国 1990
*==============================================================================
use `uspanel', clear
keep if year == 1990
thetacmp "美国 1990（51 个州）" o
display "    论文 θ = 27.6  （SE 3.42）"

*==============================================================================
* 7. 说明
*==============================================================================
display _n(2) "{hline 78}"
display "  说明"
display "{hline 78}"
display "  ① 是我们现在 PPT 里的做法；③ 最接近论文（PPML + 固定效应 + IV）。"
display "  ② 故意不加 IV，用来看内生性偏误的方向和大小。"
display "  论文的预测：不加 IV 会把 θ 估得偏大（低估选择效应）。"

log close