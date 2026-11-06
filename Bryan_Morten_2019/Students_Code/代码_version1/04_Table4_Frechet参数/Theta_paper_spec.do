* ==============================================================================
*  我们离论文还差多远？—— 逐步补齐论文的样本口径
*
*  论文口径（§4.2 第 909 行）：
*    "we drop observations with less than five observed migrants from the wage data"
*  论文口径（§3，Appendix Table 1 注释）：
*    迁移份额 π_do 与工资都在「男性户主 15-65 岁」样本上算
*
*  本脚本测 2（份额口径）× 3（筛选强度）共 6 种组合，
*  估计方法统一用论文的 PPML + 双向固定效应 + 控制函数 IV。
* ==============================================================================
clear all
set more off
set linesize 150

local root   "D:\研一上\微观计量"
local fz     "D:\研一上\微观计量\复现"
local ussrc  "C:\Users\任娜\Documents\deepseek-harness\default-workspace\usa_od.csv"

log using "`fz'\theta_paper_spec_out.log", replace text

display "{hline 80}"
display "  逐步补齐论文口径：份额定义 × 格子筛选"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 80}"

*==============================================================================
* 1. 距离
*==============================================================================
import delimited "`fz'\idn_prov_dist25.csv", clear varnames(1)
destring o, replace
destring d, replace
destring dist_km, replace force
keep o d dist_km
tempfile iddist
save `iddist'

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
* 2. 美国面板基础：同时保留「全部人」和「有工资的人」两套份额
*==============================================================================
display _n "===== 2. 美国面板基础 ====="

import delimited "`ussrc'", clear varnames(1) colrange(1:5)
capture destring o, replace
capture destring d, replace
capture destring year, replace
capture destring wage, replace force
capture destring w, replace force

keep o d year wage w
drop if missing(o) | missing(d) | missing(year)
drop if missing(w) | w <= 0
keep if year == 1990

gen byte hasw = !missing(wage) & wage > 0
gen byte one    = 1
gen double wgt_all = w
gen double wgt_wg  = w if hasw
gen double wx_w    = w*wage if hasw
gen double wage_ok = wage if hasw

collapse (sum) m_all=wgt_all (sum) m_wg=wgt_wg (sum) wx_w=wx_w (count) n_raw=one (count) n_wage=wage_ok, by(o d)
gen double wage_od = wx_w/m_wg if m_wg > 0 & !missing(m_wg)

tempfile usbase
save `usbase'
quietly count
display "  美国 1990：(o,d) 格子数 = `r(N)'"

*==============================================================================
* 3. 印尼面板基础
*==============================================================================
display _n "===== 3. 印尼面板基础 ====="

use year bplid geo1_id incwage perwt relate sex age using "`root'\ipumsi_00002.dta", clear
keep if year == 1995
keep if sex == 1 & relate == 1 & inrange(age, 15, 65)
gen int o = bplid
gen int d = geo1_id - 360000
keep if inrange(o, 11, 18) | inrange(o, 31, 35) | inrange(o, 51, 54)
keep if inrange(d, 11, 18) | inrange(d, 31, 35) | inrange(d, 51, 54)

gen byte hasw = !missing(incwage) & incwage > 0 & incwage < 9999999
gen byte one    = 1
gen double wgt_all = perwt
gen double wgt_wg  = perwt if hasw
gen double wx_w    = perwt*incwage if hasw
gen double wage_ok = incwage if hasw

collapse (sum) m_all=wgt_all (sum) m_wg=wgt_wg (sum) wx_w=wx_w (count) n_raw=one (count) n_wage=wage_ok, by(o d)
gen double wage_od = wx_w/m_wg if m_wg > 0 & !missing(m_wg)

tempfile idbase
save `idbase'
quietly count
display "  印尼 1995：(o,d) 格子数 = `r(N)'"

*==============================================================================
* 4. 子程序：给定 m_od 建完整估计样本
*==============================================================================
capture program drop buildpanel
program define buildpanel
    args distf out
    * 输入数据集须含：o d m_od wage_od n_raw n_wage
    quietly {
        bysort o: egen double pop_o  = total(m_od)
        bysort d: egen double m_in_d = total(m_od)
        egen double pop_all = total(m_od)
        gen double pi_do = m_od/pop_o
    }

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
    merge 1:1 o d using `distf', keep(master match) nogen

    keep if !missing(pi_do) & pi_do > 0
    keep if !missing(pi_rev) & pi_rev > 0
    keep if !missing(pi_oo) & pi_oo > 0
    keep if !missing(pi_dd) & pi_dd > 0
    keep if !missing(pi_dnoto) & pi_dnoto > 0
    keep if !missing(dist_km) & dist_km > 0
    keep if !missing(wage_od) & wage_od > 0

    gen double ln_p      = ln(pi_do)
    gen double ln_p_rev  = ln(pi_rev)
    gen double ln_poo    = ln(pi_oo)
    gen double ln_pdd    = ln(pi_dd)
    gen double ln_pdnoto = ln(pi_dnoto)
    gen double ln_wage   = ln(wage_od)
    save `out', replace
end

*==============================================================================
* 5. 子程序：估 θ（PPML+控制函数IV）与 ρ（式 8），可加格子筛选
*==============================================================================
capture program drop estppml
program define estppml
    args tag cl nmin rawvar
    * nmin=0 表示不筛选
    if `nmin' > 0 {
        quietly drop if `rawvar' < `nmin'
    }
    quietly count
    local ncell = r(N)
    quietly count if !missing(wage_od)
    local nreg = r(N)

    if `ncell' < 10 {
        display "  `tag'：样本太小，跳过"
        exit
    }

    * --- θ：零阶段 ---
    quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
    local r2z = e(r2)
    quietly predict double phat, xb

    * --- θ：PPML + 双向 FE + 控制函数 ---
    quietly capture reghdfe ln_p phat, absorb(o d) residuals(u)
    if _rc != 0 {
        display "  `tag'：第一阶段失败 rc=`=_rc'"
        exit
    }
    quietly capture ppmlhdfe wage_od ln_p u, absorb(o d) cluster(`cl')
    if _rc != 0 {
        display "  `tag'：PPML 失败 rc=`=_rc'"
        exit
    }
    local beta = _b[ln_p]
    if `beta' >= 0 {
        display "  `tag'：β 为正，θ 无解"
        exit
    }
    local theta = -1/`beta'

    * --- ρ：式(8) 两阶段网格搜索 ---
    quietly summarize wage_od
    local V = r(Var)/r(mean)^2
    local best = .
    local bestv = .
    forvalues i = 205/3000 {
        local tt = `i'/100
        local rhs = exp(lngamma(1-2/`tt'))/(exp(lngamma(1-1/`tt'))^2) - 1
        local d = abs(`rhs' - `V')
        if `bestv' == . | `d' < `bestv' {
            local bestv = `d'
            local best = `tt'
        }
    }
    local c0 = `best' - 0.05
    local c1 = `best' + 0.05
    local bestv = .
    forvalues i = 0/100 {
        local tt = `c0' + `i'*0.001
        if `tt' > 2 {
            local rhs = exp(lngamma(1-2/`tt'))/(exp(lngamma(1-1/`tt'))^2) - 1
            local d = abs(`rhs' - `V')
            if `bestv' == . | `d' < `bestv' {
                local bestv = `d'
                local best = `tt'
            }
        }
    }
    local thetat = `best'
    local rho = 1 - `thetat'/`theta'

    display "  `tag'"
    display "      样本：`ncell' 个 OD 对（其中 `nreg' 个有工资）   零阶段 R² = " %6.4f `r2z'
    display "      θ  = " %8.4f `theta' "        θ̃ = " %7.4f `thetat' "        ρ = " %7.4f `rho'
    display "      var(w)/w̄² = " %8.5f `V'
end

*==============================================================================
* 6. 印尼：两种份额口径 × 三种筛选
*==============================================================================
display _n(2) "{hline 80}"
display "  印尼 1995"
display "{hline 80}"
display "  论文值：θ = 12.5   ρ = 0.74   θ̃ = 3.18   τ̄ = 0.50"

foreach share in m_all m_wg {
    if "`share'" == "m_all"  local slab "份额用【全部男性户主】"
    if "`share'" == "m_wg"   local slab "份额用【有工资的男性户主】（论文口径）"

    use `idbase', clear
    rename `share' m_od
    keep if m_od > 0 & !missing(wage_od) & wage_od > 0
    buildpanel `iddist' "`fz'\_tmp_id_`share'.dta"

    display _n "  ── `slab' ──"
    use "`fz'\_tmp_id_`share'.dta", clear
    estppml "不筛选格子" o 0 n_raw

    use "`fz'\_tmp_id_`share'.dta", clear
    estppml "丢 n_raw < 5（全部人计数）" o 5 n_raw

    use "`fz'\_tmp_id_`share'.dta", clear
    estppml "丢 n_wage < 5（有工资者计数）" o 5 n_wage
}

*==============================================================================
* 7. 美国 1990：同上
*==============================================================================
display _n(2) "{hline 80}"
display "  美国 1990"
display "{hline 80}"
display "  论文值：θ = 27.6   ρ = 0.90   θ̃ = 2.69   τ̄ = 0.22"

foreach share in m_all m_wg {
    if "`share'" == "m_all"  local slab "份额用【全部人】"
    if "`share'" == "m_wg"   local slab "份额用【有工资的人】（论文口径）"

    use `usbase', clear
    rename `share' m_od
    keep if m_od > 0 & !missing(wage_od) & wage_od > 0
    buildpanel `usdist' "`fz'\_tmp_us_`share'.dta"

    display _n "  ── `slab' ──"
    use "`fz'\_tmp_us_`share'.dta", clear
    estppml "不筛选格子" o 0 n_raw

    use "`fz'\_tmp_us_`share'.dta", clear
    estppml "丢 n_raw < 5（全部人计数）" o 5 n_raw

    use "`fz'\_tmp_us_`share'.dta", clear
    estppml "丢 n_wage < 5（有工资者计数）" o 5 n_wage
}

*==============================================================================
* 8. 说明
*==============================================================================
display _n(2) "{hline 80}"
display "  怎么读这张表"
display "{hline 80}"
display "  · 份额口径：论文在有工资的人里算迁移份额，我们之前用全部男性户主"
display "  · 格子筛选：论文丢掉迁移人数少于 5 的格子（工资均值不可靠）"
display "  · 估计方法统一用 PPML + 双向固定效应 + 控制函数 IV"
display "  · 全部 6 种组合都做了 bootstrap 之外的点估计，标准误未计算"

log close