*==============================================================================
* t4_ppt_stats.do
* Table 4 复现 PPT 的辅助统计 —— 全部由 Stata 计算，不依赖任何 Python 结果
*
* 只做算术与数值求解，不读大数据，几秒跑完。
* 论文报告值直接抄论文 Table 4（p.2254）与附录表 1，其余由 Stata 算。
*==============================================================================
clear all
set more off
version 19

*------------------------------------------------------------------ 0. 日志头
display "{hline 88}"
display "  Table 4 复现 PPT —— 辅助统计（全部由 Stata 计算）"
display "{hline 88}"


*==============================================================================
* A. 论文 Table 4 报告值：t 值、95% 置信区间、显著性
*    论文只给了 rho 和 theta 的标准误（bootstrap），theta~ 与 tau 没给。
*    论文注：Only rho and theta carry SEs. Bootstrapped standard errors reported.
*==============================================================================
display _n(2) "{hline 88}"
display "  A. 论文 Table 4 报告值：t 值与 95% 置信区间"
display "{hline 88}"
display ""
display "  参数            估计值      标准误        t 值     95% 置信区间            显著性"

* --- 印尼 ---
foreach pr in "rho_IDN .74 .029" "theta_IDN 12.5 1.36" ///
              "rho_US .90 .015"  "theta_US 27.6 3.29" {
    local nm : word 1 of `pr'
    local b  : word 2 of `pr'
    local se : word 3 of `pr'
    local t  = `b'/`se'
    local lo = `b' - 1.96*`se'
    local hi = `b' + 1.96*`se'

    * 显著性判定：|t| > 2.576 -> 1% 水平；> 1.96 -> 5% 水平
    local star "无"
    if abs(`t') > 2.5758 local star "1% 水平 ***"
    else if abs(`t') > 1.9600 local star "5% 水平 **"

    display "  " %-14s "`nm'" %8.3f `b' %11.3f `se' %11.2f `t' ///
            "      [" %7.3f `lo' ", " %7.3f `hi' "]      `star'"
}
display ""
display "  说明：论文 Table 4 的 rho 与 theta 都打了 *** —— 也就是 1% 水平显著。"
display "        theta~ 与平均迁移成本 tau 论文没给标准误，所以无从判断显著性。"


*==============================================================================
* B. 式(8) 的映射：theta~  ->  var(w)/mean(w)^2
*    var(w)/wbar^2 = Gamma(1-2/theta~) / [Gamma(1-1/theta~)]^2 - 1
*    这个函数对 theta~ 单调递减，且在 theta~ 接近 2 时极其陡峭。
*==============================================================================
display _n(2) "{hline 88}"
display "  B. 式(8) 映射表：theta~ 决定横截面工资离散度"
display "{hline 88}"
display ""
display "    theta~       式(8) 右边 = var(w)/wbar^2        相邻两行的变化幅度"
display "  ----------------------------------------------------------------"

local prev = .
* 注意：theta~ <= 2 时 Gamma(1-2/theta~) 的自变量非正，公式失效（theta~ = 2 是奇点）
foreach tt in 2.2 2.5 2.69 3.0 3.18 3.5 4.0 5.0 8.0 12.5 27.6 {
    local v = exp(lngamma(1 - 2/`tt'))/(exp(lngamma(1 - 1/`tt'))^2) - 1
    if `prev' == . {
        display "   " %6.2f `tt' "        " %12.5f `v'
    }
    else {
        local chg = (`v' - `prev')/`prev'*100
        display "   " %6.2f `tt' "        " %12.5f `v' "          " %8.1f `chg' " %"
    }
    local prev = `v'
}
display ""
display "  >>> 看 theta~ = 2.69 -> 3.18 这一段：值从 0.731 掉到 0.372，一步就是 -49%。"
display "      这就是为什么 rho 极难精确复现 —— theta~ 差一点，工资方差要求差一倍。"


*==============================================================================
* C. 从【本复现实际算出的】var(w)/mean(w)^2 反解 theta~ 与 rho
*    用二分法。目标值取自 table3_replication.log 与 theta_paper_spec_out.log。
*==============================================================================
display _n(2) "{hline 88}"
display "  C. 从本复现实际的工资方差反解 theta~ 与 rho（二分法）"
display "{hline 88}"

capture program drop solve_tt
program define solve_tt, rclass
    args target
    local lo = 1.02
    local hi = 80
    forvalues i = 1/300 {
        local mid = (`lo' + `hi')/2
        local f = exp(lngamma(1 - 2/`mid'))/(exp(lngamma(1 - 1/`mid'))^2) - 1
        if `f' > `target' local lo = `mid'
        else                local hi = `mid'
    }
    return scalar tt = (`lo' + `hi')/2
end

display ""
display "  样本          实际 var/wbar^2    反解 theta~    配套 theta     推出 rho"

foreach pr in "IDN_main 0.16956 10.551" "IDN_paper 0.14089 12.4399" ///
              "US_main 0.07879 41.130" "US_paper 0.05635 30.2548" {
    local nm : word 1 of `pr'
    local v  : word 2 of `pr'
    local th : word 3 of `pr'
    if "`nm'" == "IDN_main"  local full "印尼 1995 省级（对数 2SLS 基准）"
    if "`nm'" == "IDN_paper" local full "印尼 论文口径（PPML+IV，丢 n_raw<5）"
    if "`nm'" == "US_main"   local full "美国 1990（对数 2SLS 基准）"
    if "`nm'" == "US_paper"  local full "美国 1990 论文口径（PPML+IV，丢 n_raw<5）"
    quietly solve_tt `v'
    local tt = r(tt)
    local rh = 1 - `tt'/`th'
    display "  " %-36s "`full'" %12.5f `v' %13.4f `tt' %13.4f `th' %10.4f `rh'
}
display ""
display "  对照论文：印尼 theta~ = 3.18、rho = 0.74；美国 theta~ = 2.69、rho = 0.90。"


*==============================================================================
* D. 样本与权重（论文附录表 1 —— 注意：Table 4 本身不报这些，附录才有）
*==============================================================================
display _n(2) "{hline 88}"
display "  D. 抽样性质与权重因子（论文附录表 1）"
display "{hline 88}"
display ""
display "  样本          样本量 N      Sum of weights     平均权重     抽样率"
display "  --------------------------------------------------------------------"

foreach pr in "印尼 1995 59006 13454136"    ///
              "印尼 2011 68510 17324774"    ///
              "印尼 2012 69330 17736228"    ///
              "美国 1990 1958123 39251152"  ///
              "美国 2010 336033 32404124" {
    local yr  : word 1 of `pr'
    local yr2 : word 2 of `pr'
    local n   : word 3 of `pr'
    local w   : word 4 of `pr'
    local fac = `w'/`n'
    display "  " %-14s "`yr' `yr2'" %12.0fc `n' %16.0fc `w' %12.2f `fac' "   1/" %5.0f `fac'
}
display ""
display "  >>> 美国 1990 平均权重 = 20.05 = 1/0.05 —— 精确对应论文说的 5% 普查样本。"
display "      这证明美国的数据也是抽样，也带权重，不是全样本。"
display "      印尼平均权重约 228~256（SUSENAS 约 0.4% 抽样率）。"
display ""
display "  注意：Table 4 报的是【样本量】。加权和只在附录表 1 出现。"
display "        加权不改变样本量，只改变「能推断的总体」。"


*==============================================================================
* E. 固定效应哑变量个数（Table 4 的估计也要控制双向固定效应）
*==============================================================================
display _n(2) "{hline 88}"
display "  E. 固定效应哑变量个数"
display "{hline 88}"
display ""
display "  设定                              组合数      自由度数(减 1 个基准)"

local idn_dt = 281*3
local idn_ot = 281*3
local us_dt  = 51*2
local us_ot  = 51*2
display "  印尼 目的地x年（281 县 x 3 年）  " %10.0f `idn_dt' %14.0f `idn_dt'-1
display "  印尼 出发地x年                   " %10.0f `idn_ot' %14.0f `idn_ot'-1
display "  美国 目的地x年（51 州 x 2 年）   " %10.0f `us_dt'  %14.0f `us_dt'-1
display "  美国 出发地x年                   " %10.0f `us_ot'  %14.0f `us_ot'-1
display ""
display "  两组同时放入时还要再多减 1（两组哑变量之和都等于常数向量）："
display "    印尼 " %4.0f `idn_dt' " + " %4.0f `idn_ot' " - 1 = " %5.0f `idn_dt'+`idn_ot'-1 " 个自由度"
display "    美国 " %4.0f `us_dt'  " + " %4.0f `us_ot'  " - 1 = " %5.0f `us_dt'+`us_ot'-1  " 个自由度"
display ""
display "  本复现实际样本：印尼 198 个 OD 对、美国 2,531 个 OD 对。"
display "  印尼的 198 个观测要支撑 1,685 个固定效应 —— 自由度极度紧张，"
display "  这是印尼列 theta 标准误偏大的直接原因。"


*==============================================================================
* F. 复现结果与论文的差距（百分比）
*==============================================================================
display _n(2) "{hline 88}"
display "  F. 主复现结果 vs 论文 Table 4：绝对差与相对差"
display "{hline 88}"
display ""
display "  参数           论文       本复现      绝对差     相对差"
display "  --------------------------------------------------------------"

* 印尼：论文 vs 本复现（对数 2SLS 基准）
foreach pr in "rho 0.74 0.613" "theta 12.5 10.551" ///
              "theta~ 3.18 4.087" "tau 0.39 0.396" {
    local nm : word 1 of `pr'
    local p  : word 2 of `pr'
    local o  : word 3 of `pr'
    local d  = `o' - `p'
    local rd = `d'/`p'*100
    local sg = cond(`rd' >= 0, "+", "")
    display "  印尼 " %-8s "`nm'" %9.3f `p' %11.3f `o' %11.3f `d' "   " "`sg'" %5.1f `rd' " %"
}
display ""
foreach pr in "rho 0.90 0.867" "theta 27.6 41.130" ///
              "theta~ 2.69 5.467" "tau 0.15 0.114" {
    local nm : word 1 of `pr'
    local p  : word 2 of `pr'
    local o  : word 3 of `pr'
    local d  = `o' - `p'
    local rd = `d'/`p'*100
    local sg = cond(`rd' >= 0, "+", "")
    display "  美国 " %-8s "`nm'" %9.3f `p' %11.3f `o' %11.3f `d' "   " "`sg'" %5.1f `rd' " %"
}
display ""
display "  >>> 印尼平均迁移成本 tau：0.396 vs 论文 0.39 —— 相差 +1.5%，几乎完全复现。"
display "      美国 1990：0.114 vs 论文 0.15 —— 低 24%。"


*==============================================================================
* G. 把 theta 的方法对照也在这里汇总（数值取自 Stata 日志）
*==============================================================================
display _n(2) "{hline 88}"
display "  G. theta 的估计方法对照（三个数字都来自 Stata 日志）"
display "{hline 88}"
display ""
display "  方法                                 印尼 1995      美国 1990"
display "  ----------------------------------------------------------------"
display "  ① 对数 2SLS + 虚拟变量               10.5507        41.0747"
display "  ② PPML + 双向固定效应（无 IV）       17.8288        28.7835"
display "  ③ PPML + 控制函数 IV                 10.2285        29.4912"
display "  ----------------------------------------------------------------"
display "  论文 Table 4                          12.5           27.6"
display ""
display "  再用论文口径（份额在有工资的人里算 + 丢 n_raw<5）的 PPML+IV："
display "    印尼（全部男性户主份额）           12.4399         —"
display "    美国（有工资的人份额）              —            30.2548"
display ""
display "  两步控制函数法 vs ivpoisson gmm（论文原版 GMM）："
display "    印尼   控制函数 10.3728   ivpoisson gmm 10.7653"
display "    美国   控制函数 30.2548   ivpoisson gmm 29.8321"
display ""
display "  >>> 换成论文原版做法（PPML + IV + GMM）后："
display "      印尼 theta 从 10.55 提到 12.44（论文 12.5，差 -0.5%）；"
display "      美国 theta 从 41.07 降到 30.25（论文 27.6，差 +9.6%）。"
display "      方法选择是 theta 差距的主要来源，不是数据。"

display _n(2) "{hline 88}"
display "  完成。以上全部由 Stata 计算。"
display "{hline 88}"