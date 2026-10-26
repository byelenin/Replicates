* ============================================================
* 测试：把「不迁移的人」（对角线 o==d）放进 Eq (7) 会怎样？
* ============================================================
clear all
set more off
set seed 20191029

local root "D:\研一上\微观计量"
local fz   "D:\研一上\微观计量\复现"

* ---------- 距离文件 ----------
import delimited using "`fz'\idn_prov_dist25.csv", clear
capture rename province_o o
capture rename province_d d
capture rename dist_km dist_km
keep o d dist_km
tempfile iddist
save `iddist'

* ============================================================
* 建印尼省级面板（完全照抄 Table3_replication.do 第 253-331 行）
* ============================================================
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
display _n "  OD 单元数（含对角线）= " _N

* 记录对角线（给后面的 τ 用）
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

display _n "  对角线观测（不迁移）："
count if diag == 1
display "  非对角线观测（迁移）："
count if diag == 0

* 给对角线也把 pi_rev（对角线的反向就是它自己）算出来
* 对角线合并
merge m:1 o using `idg_o', keep(master match) nogen
merge m:1 d using `idg_d', keep(master match) nogen

* 反向值：非对角线用 irev，对角线用自己
merge 1:1 o d using `irev', keep(master match) nogen
replace pi_rev = pi_do if diag == 1 & missing(pi_rev)

merge m:1 o d using `iddist', keep(master match) nogen

gen double ln_p      = ln(pi_do)
gen double ln_p_rev  = ln(pi_rev)
gen double ln_poo    = ln(pi_oo)
gen double ln_pdd    = ln(pi_dd)
gen double ln_pdnoto = ln(pi_dnoto)
gen double ln_dist   = ln(dist_km)
gen double ln_wage   = ln(wage_od) if !missing(wage_od) & wage_od > 0

* 只保留 ln_pdnoto 有值的
keep if !missing(ln_pdnoto) & !missing(ln_p) & !missing(ln_wage)

display _n "  建成后面板："
count
count if diag == 1
count if diag == 0

tempfile panel
save `panel'

* ============================================================
* 估计程序：返回 theta / rho / thetat
* ============================================================
capture program drop thetaonly
program define thetaonly, rclass
    * 零阶段
    quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
    quietly predict double _ph, xb
    * 第二阶段 IV
    quietly capture ivregress 2sls ln_wage (ln_p = _ph) i.o i.d, cluster(o)
    if _rc {
        quietly ivregress 2sls ln_wage (ln_p = _ph) i.o i.d
    }
    local b = _b[ln_p]
    if `b' >= 0 {
        return scalar theta = .
        return scalar N     = e(N)
        exit
    }
    local theta = -1/`b'
    return scalar theta = `theta'
    return scalar N     = e(N)

    * 式 (8)：用组内工资方差估 theta-tilde
    quietly summarize wage_od
    local wbar = r(mean)
    quietly summarize wage_od
    local wvar = r(Var)
    local vm   = `wvar'/(`wbar'^2)

    local best = .
    local bezt = .
    forvalues tt = 200/3000 {
        local t = `tt'/100
        local g1 = lngamma(1 - 1/`t')
        local g2 = lngamma(1 - 2/`t')
        if `g2' < . {
            local pred = exp(`g2' - 2*`g1') - 1
            local d = abs(`pred' - `vm')
            if `best' == . | `d' < `best' {
                local best = `d'
                local bezt = `t'
            }
        }
    }
    forvalues tt = -50/50 {
        local t = `bezt' + `tt'/1000
        if `t' > 2 {
            local g1 = lngamma(1 - 1/`t')
            local g2 = lngamma(1 - 2/`t')
            if `g2' < . {
                local pred = exp(`g2' - 2*`g1') - 1
                local d = abs(`pred' - `vm')
                if `d' < `best' {
                    local best = `d'
                    local bezt = `t'
                }
            }
        }
    }
    return scalar thetat = `bezt'
    return scalar rho    = 1 - `bezt'/`theta'
    return scalar vm     = `vm'
end

* ============================================================
* 对比
* ============================================================
display _n(2) "{hline 78}"
display "对比：Eq (7) 是否包含不迁移的人（对角线 o == d）"
display "{hline 78}"

display _n "  【甲】只含迁移者（我们现在的做法：keep if o != d）"
use `panel', clear
keep if diag == 0
quietly thetaonly
local thA = r(theta)
local ttA = r(thetat)
local rhA = r(rho)
local nA  = r(N)
display "      OD 对 = `nA'    θ = " %8.4f `thA' "   θ̃ = " %7.4f `ttA' "   ρ = " %7.4f `rhA'

display _n "  【乙】含不迁移者（对角线也进回归）"
use `panel', clear
quietly thetaonly
local thB = r(theta)
local ttB = r(thetat)
local rhB = r(rho)
local nB  = r(N)
display "      OD 对 = `nB'    θ = " %8.4f `thB' "   θ̃ = " %7.4f `ttB' "   ρ = " %7.4f `rhB'

display _n "  【丙】只有不迁移者（对角线单独跑）"
use `panel', clear
keep if diag == 1
display "      对角线观测数 = " _N
capture quietly thetaonly
if _rc == 0 {
    display "      θ = " %8.4f r(theta) "   θ̃ = " %7.4f r(thetat) "   ρ = " %7.4f r(rho)
}
else {
    display "      （观测太少，跑不出来）"
}

display _n(2) "{hline 78}"
display "论文的值：θ = 12.5，ρ = 0.74"
display "{hline 78}"

display _n "  附：对角线上的工资 vs 非对角线"
use `panel', clear
table diag, statistic(mean wage_od) statistic(mean pi_do) statistic(count wage_od) nformat(%12.4f)

display _n(2) "{hline 78}"