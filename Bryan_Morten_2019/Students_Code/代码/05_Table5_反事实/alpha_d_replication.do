*==============================================================================
* alpha_d_replication.do
*   Table 5 第一步：估计结构舒适度 α_d
*   1a  从式(7) 的 IV 回归里提取 w_d（目的地固定效应）
*   1b  用对称差分算 τ_do，跑引力方程取目的地固定效应 δ_d
*   1c  α_d = exp(δ_d/ν) / w_d，标准化 α_1 = 1
*   1d  合理性检查
*
*   依据：论文 1433–1445 行「having identified w_d, ν, and τ_do, the only
*   unknown in (9) is α_d … amenities are residuals, not a function of any
*   other data」。不需要任何舒适度数据（PODES 只用于事后验证）。
*
*   本文件独立，不改动 Table3_replication.do。
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
capture log close
log using "alpha_d_out.log", replace text

local root "D:\研一上\微观计量"
local work "C:\Users\任娜\Documents\deepseek-harness\default-workspace"

display _n(2) "{hline 78}"
display "  Table 5 第一步：估计结构舒适度 α_d"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 78}"

*==============================================================================
* 1. 重建印尼省级 OD 面板（照搬 Table3_replication.do 第 251–331 行的做法）
*==============================================================================
display _n "===== 1. 重建 1995 年省级 OD 面板 ====="

use year bplid geo1_id incwage perwt relate sex age using "`root'\ipumsi_00002.dta", clear
display "  原始记录：" _N
keep if year == 1995
display "  1995 年：" _N
keep if sex == 1 & relate == 1 & inrange(age, 15, 65)
display "  男性户主 15-65 岁：" _N

gen int o = bplid
gen int d = geo1_id - 360000
keep if inrange(o, 11, 18) | inrange(o, 31, 35) | inrange(o, 51, 54)
keep if inrange(d, 11, 18) | inrange(d, 31, 35) | inrange(d, 51, 54)
display "  限定 17 个覆盖省份内：" _N

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
display "  OD 单元（含对角线）：" _N

* 对角线：π_oo（按 o）与 π_dd（按 d）
preserve
    keep if o == d
    keep o pi_do
    rename pi_do pi_oo
    tempfile g_o
    save `g_o'
    rename o d
    rename pi_oo pi_dd
    tempfile g_d
    save `g_d'
restore

* 反向流量 π_od
preserve
    keep o d pi_do
    rename o _t1
    rename d _t2
    rename _t1 d
    rename _t2 o
    rename pi_do pi_rev
    tempfile rev
    save `rev'
restore

keep if o != d
merge m:1 o using `g_o', keep(master match) nogen
merge m:1 d using `g_d', keep(master match) nogen
merge 1:1 o d using `rev', keep(master match) nogen

gen double ln_p     = ln(pi_do)
gen double ln_p_rev = ln(pi_rev)
gen double ln_poo   = ln(pi_oo)
gen double ln_pdd   = ln(pi_dd)
gen double ln_wage  = ln(wage_od) if !missing(wage_od) & wage_od > 0

display _n "  过滤前（o != d）：" _N
count if pi_do > 0
display "  π_do  > 0 ：" r(N)
count if pi_do > 0 & pi_rev > 0
display "  加上 π_od > 0 ：" r(N)
count if pi_do > 0 & pi_rev > 0 & pi_oo > 0 & pi_dd > 0
display "  加上 π_oo, π_dd > 0 ：" r(N)
count if pi_do > 0 & pi_rev > 0 & pi_oo > 0 & pi_dd > 0 & !missing(ln_wage)
display "  再加上有工资 ：" r(N)

* 省份中文名
label define prov 11 "Aceh 亚齐" 12 "North Sumatra 北苏门答腊" 13 "West Sumatra 西苏门答腊" ///
    14 "Riau 廖内" 15 "Jambi 占碑" 16 "South Sumatra 南苏门答腊" 17 "Bengkulu 明古鲁" ///
    18 "Lampung 楠榜" 31 "DKI Jakarta 雅加达" 32 "West Java 西爪哇" 33 "Central Java 中爪哇" ///
    34 "DI Yogyakarta 日惹" 35 "East Java 东爪哇" 51 "Bali 巴厘" 52 "West Nusa Tenggara 西努沙登加拉" ///
    53 "East Nusa Tenggara 东努沙登加拉" 54 "East Timor 东帝汶"
label values d prov
label values o prov

*==============================================================================
* 2. 1a —— 式(7) 的 IV 回归，提取 w_d
*==============================================================================
display _n(2) "{hline 78}"
display "  2. 1a：式(7) 的 IV 回归，提取 w_d"
display "{hline 78}"

* 样本：有工资、且四个份额都为正（与 Table3_replication.do 一致）
keep if pi_do > 0 & pi_rev > 0 & pi_oo > 0 & pi_dd > 0
keep if !missing(ln_wage)
display "  估计样本 N = " _N

* 零阶段：ln π_do 对 ln π_d¬o 的二次多项式
gen double pi_dnoto = (m_in_d - m_od)/(pop_all - pop_o) if (pop_all - pop_o) > 0
keep if pi_dnoto > 0
gen double ln_pdnoto = ln(pi_dnoto)
display "  加上 π_d¬o > 0 ：N = " _N

quietly regress ln_p c.ln_pdnoto##c.ln_pdnoto
quietly predict double phat, xb
display "  零阶段 R² = " %6.4f e(r2)

quietly ivregress 2sls ln_wage (ln_p = phat) i.o i.d, cluster(o)
local b  = _b[ln_p]
local th = -1/`b'
display _n "  式(7) 的 ln π_do 系数 = " %10.6f `b' "   ⇒  θ = " %8.4f `th'

* 式(8)：由工资方差反解 θ̃
quietly summarize wage_od
local v = r(Var)/(r(mean)^2)
display "  工资均值 = " %14.2f r(mean) "   方差 = " %18.2f r(Var)
display "  var(w)/w̄² = " %10.5f `v'
local best  = .
local bestd = 1e30
forvalues i = 205/4000 {
    local tt = `i'/100
    local rhs = exp(lngamma(1 - 2/`tt'))/(exp(lngamma(1 - 1/`tt'))^2) - 1
    if abs(`rhs' - `v') < `bestd' {
        local bestd = abs(`rhs' - `v')
        local best  = `tt'
    }
}
local c  = `best'
local lo = `c' - 0.05
local hi = `c' + 0.05
forvalues i = 1/200 {
    local tt = `lo' + (`i' - 1)*(`hi' - `lo')/199
    local rhs = exp(lngamma(1 - 2/`tt'))/(exp(lngamma(1 - 1/`tt'))^2) - 1
    if abs(`rhs' - `v') < `bestd' {
        local bestd = abs(`rhs' - `v')
        local best  = `tt'
    }
}
local tt   = `best'
local rho  = 1 - `tt'/`th'
display _n "  θ̃ = " %8.4f `tt' "   ρ = 1 − θ̃/θ = " %8.4f `rho'

* Γ̄ = Γ(1 − 1/θ̃)；论文式(5)：Γ̄ = Γ(1 − 1/[ν(1−ρ)])
local Gbar = exp(lngamma(1 - 1/`tt'))
display "  Γ̄ = Γ(1 − 1/θ̃) = " %10.6f `Gbar'

* ---- 提取 w_d：式(10) 的截距 = ln(Γ̄) + ln(w_基准地) ----
levelsof d, local(ds)
local dbase : word 1 of `ds'
display _n "  目的地基准（Stata 自动丢掉的最低值）= 省码 `dbase'"
matrix W = J(1, 1, .)

tempname wd
matrix `wd' = J(`:word count `ds'', 2, .)
local r = 0
foreach dd of local ds {
    local r = `r' + 1
    if `dd' == `dbase' {
        local g = 0
    }
    else {
        capture local g = _b[`dd'.d]
        if _rc local g = .
    }
    local lnwd = _b[_cons] + `g' - lngamma(1 - 1/`tt')
    matrix `wd'[`r', 1] = `dd'
    matrix `wd'[`r', 2] = `lnwd'
}
matrix colnames `wd' = dcode ln_w_d
display _n "  w_d（相对水平，式(7) 目的地固定效应）"
display "  省码     ln w_d        w_d"
forvalues i = 1/`r' {
    local dd = `wd'[`i', 1]
    local lw = `wd'[`i', 2]
    display "  " %4.0f `dd' "   " %10.6f `lw' "   " %12.6f exp(`lw')
}

* 存成变量方便后续
preserve
    clear
    svmat double `wd', names(col)
    rename dcode d
    keep d ln_w_d
    tempfile wdfile
    save `wdfile'
restore

*==============================================================================
* 3. 1b —— 对称差分算 τ，跑引力方程取目的地固定效应
*==============================================================================
display _n(2) "{hline 78}"
display "  3. 1b：τ 与引力方程的目的地固定效应 δ_d"
display "{hline 78}"

* τ 的对称差分式（论文紧跟式(9) 之后，未单独编号）：
*   (ln π_do − ln π_oo) + (ln π_od − ln π_dd) = 2ν ln(1 − τ_do) + η
* ⇒ ν ln(1 − τ_do) = [(ln π_do − ln π_oo) + (ln π_od − ln π_dd)] / 2
gen double lhs_sym = (ln_p - ln_poo) + (ln_p_rev - ln_pdd)
gen double nu_ln1mtau = lhs_sym/2
gen double tau_do = 1 - exp(lhs_sym/(2*`th'))
quietly summarize tau_do
display "  τ_do：均值 = " %8.4f r(mean) "   最小 = " %8.4f r(min) "   最大 = " %8.4f r(max) "   非缺失 = " %4.0f r(N)
display "  ⚠ 注意：Stata 里缺失值(.)比任何数都大，count if x>1 会把缺失算进去，必须加 !missing()"
quietly count if tau_do < 0 & !missing(tau_do)
display "  τ_do < 0 的格子数 = " r(N) "（论文不截断）"
quietly count if tau_do > 1 & !missing(tau_do)
display "  τ_do > 1 的格子数 = " r(N)
quietly count if missing(tau_do)
display "  τ_do 缺失（反向流量为 0，算不出来）的格子数 = " r(N)

* 合并 w_d
merge m:1 d using `wdfile', keep(master match) nogen
quietly count if missing(ln_w_d)
display "  缺 w_d 的格子数 = " r(N)

* 引力方程：ln π_do = ν ln w_d + ν ln a_d + ν ln(1−τ_do) + 出发地项 + 误差
* 已知 ν、w_d、τ_do ⇒ 移到左边：Z = ν ln a_d + 出发地项 + 误差
gen double Z = ln_p - `th'*ln_w_d - nu_ln1mtau
display _n "  对 Z 回归 i.d i.o，目的地固定效应 = ν ln(α_d/α_基准)"
quietly regress Z i.d i.o
display "  R² = " %6.4f e(r2) "   N = " e(N)

levelsof d, local(ds2)
local dbase2 : word 1 of `ds2'
tempname ad
local K : word count `ds2'
matrix `ad' = J(`K', 3, .)
local r = 0
foreach dd of local ds2 {
    local r = `r' + 1
    if `dd' == `dbase2' {
        local g = 0
    }
    else {
        capture local g = _b[`dd'.d]
        if _rc local g = .
    }
    matrix `ad'[`r', 1] = `dd'
    matrix `ad'[`r', 2] = `g'/`th'          // ln(α_d / α_基准)
    matrix `ad'[`r', 3] = `g'               // 原始 δ_d
}
* 标准化 α_1 = 1（论文第 1445 行：amenities 只能识别到标准化为止）
local base1 = 11
local ref = .
forvalues i = 1/`K' {
    if `ad'[`i', 1] == `base1' local ref = `ad'[`i', 2]
}
if missing(`ref') {
    display "  ⚠ 省码 11 不在样本内，改用基准地做标准化"
    local ref = 0
}
gen double dummy_placeholder = .
display "  标准化参照：ln α_11 = " %10.6f `ref'

*==============================================================================
* 4. 1c —— α_d
*==============================================================================
display _n(2) "{hline 78}"
display "  4. 1c：结构舒适度 α_d（17 个省，α_11 = 1）"
display "{hline 78}"
display "  省码   省份                      δ_d          ln α_d        α_d"
display "  " "{hline 74}"
matrix A = J(`K', 4, .)
forvalues i = 1/`K' {
    local dd = `ad'[`i', 1]
    local lna = `ad'[`i', 2] - `ref'
    local a   = exp(`lna')
    matrix A[`i', 1] = `dd'
    matrix A[`i', 2] = `ad'[`i', 3]
    matrix A[`i', 3] = `lna'
    matrix A[`i', 4] = `a'
    display "  " %4.0f `dd' "   " %-24s "`: label prov `dd''" "  " %10.5f `ad'[`i',3] "  " %10.5f `lna' "  " %10.5f `a'
}
display "  " "{hline 74}"

* 排序输出
preserve
    clear
    svmat double A, names(col)
    rename c1 d
    rename c2 delta_d
    rename c3 ln_alpha
    rename c4 alpha_d
    keep d delta_d ln_alpha alpha_d
    gsort -alpha_d
    display _n "  按 α_d 从高到低排序："
    display "  省码   省份                      α_d         ln α_d"
    display "  " "{hline 68}"
    forvalues i = 1/`=_N' {
        display "  " %4.0f d[`i'] "   " %-24s "`: label prov `=d[`i']''" "  " %10.5f alpha_d[`i'] "  " %10.5f ln_alpha[`i']
    }
    display "  " "{hline 68}"
    quietly summarize alpha_d
    display _n "  α_d 的分布：均值 = " %8.5f r(mean) "   最小 = " %8.5f r(min) "   最大 = " %8.5f r(max)
    display "  最大/最小 = " %8.3f r(max)/r(min)
    quietly summarize ln_alpha
    display "  ln α_d 的标准差 = " %8.5f r(sd)
    tempfile alphafile
    save `alphafile'
restore

*==============================================================================
* 5. 1d —— 合理性检查
*==============================================================================
display _n(2) "{hline 78}"
display "  5. 1d：合理性检查"
display "{hline 78}"

* 合并 α_d 回到面板
merge m:1 d using `alphafile', keep(master match) nogen
gen double ln_w_d_merge = ln_w_d

display _n "  (1) ★ 补偿性差异检验：论文第 644 行明说「locations with higher amenities have"
display "      lower wages」⇒ corr(ln α_d, ln w_d) 应该【为负】。"
quietly correlate ln_alpha ln_w_d_merge
display "      corr(ln α_d, ln w_d) = " %7.4f r(rho)
display "      → 负号符合补偿性差异的理论预期。"
display "      ⚠ 但若接近 −1，说明 α_d 几乎是 w_d 的机械镜像，"
display "        「w_d·α_d」在各目的地之间几乎不变 ⇒ 识别很弱。必须看下面的倍数。"

display _n "  (2) ★ 关键量化：吸引力 w_d·α_d 在各目的地之间的差距有多大？"
gen double attract = ln_w_d_merge + ln_alpha
quietly summarize attract
display "      ln(w_d·α_d)：最小 = " %8.4f r(min) "   最大 = " %8.4f r(max) "   极差 = " %8.4f r(max)-r(min)
display "      w_d 本身：  "
quietly summarize ln_w_d_merge
display "      ln w_d：    最小 = " %8.4f r(min) "   最大 = " %8.4f r(max) "   极差 = " %8.4f r(max)-r(min)
display "      ⇒ 乘以 θ = " %6.3f `th' " 后，生产率项能造成的份额差距 = exp(" %8.3f (`th')*(r(max)-r(min)) ") 倍"
display "        而 α_d 抵消掉一部分，实际吸引力极差只有 " %8.4f r(max)-r(min) " 个对数点。"

display _n "  (3) 原始（未经 τ 调整）目的地的吸引力与 w_d 的关系"
* 单独的 ln π_do 目的地固定效应
quietly regress ln_p i.d i.o
display "      回归 ln π_do on i.d i.o ：R² = " %6.4f e(r2)
quietly predict double fe_raw, xb
* 取每个目的地一行的值
preserve
    collapse (mean) fe_raw ln_w_d_merge ln_alpha, by(d)
    quietly correlate fe_raw ln_w_d_merge
    display "      corr(目的地固定效应 ln π_do , ln w_d) = " %7.4f r(rho)
    quietly correlate fe_raw ln_alpha
    display "      corr(目的地固定效应 ln π_do , ln α_d) = " %7.4f r(rho)
    display "      ⇒ 若第二个相关为正，说明 α_d 确实在解释「刨掉生产率之后还剩的吸引力」"
restore

display _n "  (4) 换 θ 的敏感性：α_d 的排序稳不稳？"
foreach thx in 4.0869 12.4399 12.5836 {
    preserve
        quietly {
            gen double Zx = ln_p - `thx'*ln_w_d_merge - nu_ln1mtau
            regress Zx i.d i.o
        }
        levelsof d, local(dxs)
        local r2 = 0
        local vref = .
        foreach dd of local dxs {
            local r2 = `r2' + 1
            if `dd' == 11 {
                capture local vref = _b[11.d]
                if _rc local vref = 0
            }
        }
        tempname ax
        matrix `ax' = J(`:word count `dxs'', 2, .)
        local r2 = 0
        foreach dd of local dxs {
            local r2 = `r2' + 1
            if `dd' == 11 {
                local g = 0
            }
            else {
                capture local g = _b[`dd'.d]
                if _rc local g = .
            }
            matrix `ax'[`r2', 1] = `dd'
            matrix `ax'[`r2', 2] = exp(`g'/`thx')
        }
        * 找出 α 最大 / 最小的省
        local amax = 0
        local amin = 1e30
        local dmax = .
        local dmin = .
        forvalues i = 1/`:word count `dxs'' {
            if `ax'[`i', 2] > `amax' {
                local amax = `ax'[`i', 2]
                local dmax = `ax'[`i', 1]
            }
            if `ax'[`i', 2] < `amin' {
                local amin = `ax'[`i', 2]
                local dmin = `ax'[`i', 1]
            }
        }
        display "      θ = " %8.4f `thx' "    最大 α_d 省码 = " %4.0f `dmax' " (" %7.4f `amax' ")" ///
            "    最小 α_d 省码 = " %4.0f `dmin' " (" %7.4f `amin' ")"
    restore
}
display "      → 若最大/最小的省码在各 θ 下都相同，说明排序稳健；若翻转则说明识别依赖 θ。"

display _n "  (5) 数据来源与性质说明"
display "      · w_d 来自式(7) 的 IV 回归目的地固定效应（本文件 2 节）"
display "      · τ 来自式(9) 的对称差分（未单独编号的那一式）"
display "      · α_d = exp(δ_d/ν)/w_d 再标准化 —— 论文 1438–1445 行的「残差」"
display "      · 【无独立数据可验证】：论文用 PODES 实测舒适度做 Figure 5 与附录表 6"
display "        的验证（估出来的 α_d 应与污染负相关、与医疗可达性正相关），"
display "        我们手上没有 PODES，所以这一步做不了。"

display _n(2) "{hline 78}"
display "  运行结束：$S_DATE $S_TIME"
display "{hline 78}"
log close