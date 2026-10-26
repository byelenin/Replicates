* ============================================================
* 迁移比例的分母到底该不该包括不迁移的人？
* ============================================================
clear all
set more off
set seed 20191029

local root "D:\研一上\微观计量"
local fz   "D:\研一上\微观计量\复现"

import delimited using "`fz'\idn_prov_dist25.csv", clear
capture rename province_o o
capture rename province_d d
keep o d dist_km
tempfile iddist
save `iddist'

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
gen byte diag = (o == d)

* 对角线的人数（留在老家的人）
preserve
    keep if o == d
    keep o m_od
    rename m_od m_oo
    tempfile istay
    save `istay'
restore
preserve
    keep if o == d
    keep o pi_do
    rename pi_do pi_oo
    tempfile idg_o
    save `idg_o'
restore
preserve
    keep if o == d
    keep d pi_do
    rename pi_do pi_dd
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
merge m:1 o using `istay', keep(master match) nogen
merge m:1 o using `idg_o', keep(master match) nogen
merge m:1 d using `idg_d', keep(master match) nogen
merge 1:1 o d using `irev', keep(master match) nogen
merge m:1 o d using `iddist', keep(master match) nogen

* ---- 两种迁移比例 ----
* 甲：分母 = 所有出生在 o 的人（含不迁移）← 论文/当前做法
gen double pi_A = m_od/pop_o
* 乙：分母 = 只含【迁出去的人】（剔除不迁移）
gen double pi_B = m_od/(pop_o - m_oo) if (pop_o - m_oo) > 0

gen double ln_pA = ln(pi_A)
gen double ln_pB = ln(pi_B)
gen double ln_p_rev  = ln(pi_rev)
gen double ln_pdnoto = ln(pi_dnoto)
gen double ln_wage   = ln(wage_od) if !missing(wage_od) & wage_od > 0

keep if !missing(ln_pdnoto) & !missing(ln_wage)
keep if !missing(pi_rev) & pi_rev > 0
keep if !missing(dist_km) & dist_km > 0

display _n(2) "{hline 80}"
display "两种分母的定义，看看数值差多少"
display "{hline 80}"
display ""
quietly summarize pi_A
display "  甲（分母含不迁移）：均值 = " %8.5f r(mean) "  最小 = " %8.5f r(min) "  最大 = " %8.5f r(max)
quietly summarize pi_B
display "  乙（分母剔不迁移）：均值 = " %8.5f r(mean) "  最小 = " %8.5f r(min) "  最大 = " %8.5f r(max)
display ""
display "  甲的加总（对每个 o）："
preserve
    collapse (sum) s = pi_A, by(o)
    quietly summarize s
    display "     均值 = " %8.5f r(mean) "   范围 " %6.4f r(min) " ~ " %6.4f r(max)
restore
display "  乙的加总（对每个 o）："
preserve
    collapse (sum) s = pi_B, by(o)
    quietly summarize s
    display "     均值 = " %8.5f r(mean) "   范围 " %6.4f r(min) " ~ " %6.4f r(max)
restore
display ""
display "  >>> 甲加起来 ≈ 1（因为「留在老家」是选择集里的一项）"
display "  >>> 乙加起来 ≈ 1 吗？看上面"

* ============================================================
* 用两种 pi 分别估 theta
* ============================================================
capture program drop estpi
program define estpi, rclass
    args pv
    capture drop _ph
    quietly regress `pv' c.ln_pdnoto##c.ln_pdnoto
    quietly predict double _ph, xb
    quietly capture ivregress 2sls ln_wage (`pv' = _ph) i.o i.d, cluster(o)
    if _rc {
        quietly ivregress 2sls ln_wage (`pv' = _ph) i.o i.d
    }
    local b = _b[`pv']
    return scalar N = e(N)
    if `b' >= 0 {
        return scalar theta = .
        exit
    }
    return scalar theta = -1/`b'
end

display _n(2) "{hline 80}"
display "用两种 π 分别估 θ（式 7 + IV）"
display "{hline 80}"
display ""
quietly estpi ln_pA
display "  甲（分母含不迁移）：N = " %4.0f r(N) "    θ = " %9.4f r(theta)
quietly estpi ln_pB
display "  乙（分母剔不迁移）：N = " %4.0f r(N) "    θ = " %9.4f r(theta)
display ""
display "  论文：θ = 12.5"
display ""
display "{hline 80}"

display _n "  细节：两个 π 的相关系数"
quietly correlate pi_A pi_B
display "    corr(π_甲, π_乙) = " %8.4f r(rho)
display ""
display "  比值 π_乙/π_甲 的分布（就是分母缩小的倍数）"
gen double ratio = pi_B/pi_A
quietly summarize ratio
display "    均值 = " %8.3f r(mean) "   最小 = " %8.3f r(min) "   最大 = " %8.3f r(max)
display ""
display "  >>> 每个 (o,d) 被乘以了 1/(1-π_oo)，而 π_oo 各省不同（0.76~0.99）"
display "  >>> 所以这个「缩放」在不同出发地之间【不一样】—— 相当于给回归元注入了噪声"

display _n(2) "{hline 80}"