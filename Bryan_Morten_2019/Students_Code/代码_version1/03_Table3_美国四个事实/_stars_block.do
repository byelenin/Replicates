*==============================================================================
* 8. 【新增】为 PPT 加星号：统一输出 b / SE / t / 星号
*
*   背景：双向聚类 (cluster oyear dyear) 的 VCV 有时非正定，reghdfe 会施加
*         Cameron-Gelbach-Miller 调整，把个别系数的方差压成 0
*         ⇒ 那些 SE 不可用，无法据此定星号。
*   对策：先跑双向聚类；若 _se 缺失或 <=0，自动回退到一维聚类 cluster(oyear)，
*         并在输出里标记 [二维VCV非正定→改一维聚类]。
*
*   约定（避免空参数被 args 跳过导致错位）：
*         wt   = "NONE" 表示不加权
*         useif= "ALL"  表示不加 if
*         yf   = "NONE" 表示全部年份
*         pan  = 面板临时文件名（program 里看不到调用方的 local，必须显式传）
*
*   星号规则（与论文一致）：|t|>2.576 → *** ，>1.96 → ** ，>1.645 → *
*==============================================================================
capture log close
log using "t3us_stars_out.log", replace text

display _n(2) "{hline 96}"
display "  Table 3（美国）各口径的系数与标准误 —— 供 PPT 加星号"
display "{hline 96}"

capture program drop _both
program define _both
    args dep rhs wt useif vn lab
    local wo ""
    if "`wt'" != "NONE" local wo "[aw=`wt']"
    local uf ""
    if "`useif'" != "ALL" local uf "`useif'"
    capture quietly reghdfe `dep' `rhs' `wo' `uf', absorb(oyear dyear) vce(cluster oyear dyear)
    local b = _b[`vn']
    local s = _se[`vn']
    local flag ""
    if missing(`s') | `s' <= 0 {
        capture quietly reghdfe `dep' `rhs' `wo' `uf', absorb(oyear dyear) vce(cluster oyear)
        local s = _se[`vn']
        local flag "   [二维VCV非正定 → 改一维聚类 cluster(oyear)]"
    }
    local t = `b'/`s'
    local st ""
    if abs(`t') > 2.576      local st "***"
    else if abs(`t') > 1.96  local st "**"
    else if abs(`t') > 1.645 local st "*"
    display "   `lab'   b = " %10.4f `b' "   SE = " %9.4f `s' "   t = " %8.2f `t' "  `st'`flag'"
end

capture program drop _block
program define _block
    args pan tag wt yf
    display _n "  ===== 口径：`tag' ====="
    use `pan', clear
    if "`yf'" != "NONE" keep if year == `yf'
    _both ln_p    "ln_dist"      "`wt'" "ALL"                  ln_dist "    (1) ln_dist → ln p "
    _both ln_wage "ln_dist"      "`wt'" "if !missing(ln_wage)" ln_dist "    (2) ln_dist → ln w "
    _both ln_wage "ln_dist ln_p" "`wt'" "if !missing(ln_wage)" ln_dist "    (3) ln_dist → ln w "
    _both ln_wage "ln_dist ln_p" "`wt'" "if !missing(ln_wage)" ln_p    "    (3) ln_p    → ln w "
    _both ln_wage "ln_p"         "`wt'" "if !missing(ln_wage)" ln_p    "    (4) ln_p    → ln w "
end

* ---- 主口径 ----
_block `uspanel' "主口径  n_od 加权（全样本 1990+2010）" "n_od" "NONE"

* ---- 三种加权对比 ----
_block `uspanel' "按人口权重和 m_od" "m_od" "NONE"
_block `uspanel' "不加权（州对等权）" "NONE" "NONE"

* ---- 分年 ----
_block `uspanel' "仅 1990" "n_od" "1990"
_block `uspanel' "仅 2010" "n_od" "2010"

* ---- 列(1) 的分母口径 ----
display _n "  ===== 列(1) 分母口径（均 n_od 加权）====="
use `uspanel', clear
capture drop p_share_o p_share_d p_share_all p_raw
gen double p_share_o   = m_od/pop_o    if pop_o > 0
gen double p_share_d   = m_od/m_in_d   if m_in_d > 0
gen double p_share_all = m_od/pop_all  if pop_all > 0
gen double p_raw       = m_od
foreach vn in p_share_o p_share_d p_share_all p_raw {
    capture drop _lnpv
    capture quietly gen double _lnpv = ln(`vn') if `vn' > 0
    _both _lnpv "ln_dist" "n_od" "ALL" ln_dist "    ln(`vn') → ln p "
}

display _n(2) "{hline 96}"
display "  结束：$S_DATE $S_TIME"
display "{hline 96}"
log close