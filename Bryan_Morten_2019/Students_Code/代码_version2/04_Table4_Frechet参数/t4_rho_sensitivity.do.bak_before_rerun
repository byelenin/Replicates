*==============================================================================
* t4_rho_sensitivity.do
* 目的：量化解释「为什么 ρ 极难精确复现」，以及 θ̃ 反解的敏感度
* 全部用 Stata 的 lngamma() 做算术与数值微分，不读大数据，几秒钟跑完
*
* 注意：/e 批量模式会自动创建与 do 文件同名的日志，所以这里的日志叫 *_out.log
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
capture log close
log using "t4_rho_sens_out.log", replace text

* 式(8) 右端就是 Fréchet(θ̃) 的变异系数平方：
*     CV² = Γ(1−2/θ̃) / Γ(1−1/θ̃)² − 1
* 为避免溢出，用 ln(1+CV²) = lngamma(1−2/t) − 2·lngamma(1−1/t) 再取 exp 减 1

display "{hline 78}"
display "  ρ 的复现难度：敏感度分解"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 78}"

*===================================================================== A
display _n "{hline 78}"
display " A. 先验证式(8) 右端确实就是 Fréchet(θ̃) 的 CV²"
display "{hline 78}"
display "  θ̃       式(8) 右端 CV²      ln(1+CV²)        ln(θ̃)"
display "  " "{hline 70}"
foreach tt in 2.2 2.5 2.69 3 3.18 3.5 4 4.0874 5 5.4671 6.2753 8 12.5 27.6 {
    scalar t = `tt'
    scalar ln1p = lngamma(1 - 2/t) - 2*lngamma(1 - 1/t)
    scalar cv = exp(ln1p) - 1
    display "  " %7.4f t "    " %12.5f cv "     " %10.7f ln1p "     " %8.5f ln(t)
}

*===================================================================== B
display _n "{hline 78}"
display " B. 局部弹性 —— 式(8) 这把「尺子」有多陡"
display "    数值微分：d ln(CV²)/d ln(θ̃)，以及由它推出的传播系数"
display "{hline 78}"
display "  θ̃       d ln(CV²)/d ln(θ̃)    工资方差偏高 1% → θ̃ 变动"
display "  " "{hline 70}"
local h = 0.00001
foreach tt in 2.2 2.5 2.69 3.18 3.5 4.0874 4.3692 5.4671 6.2753 8 12.5 27.6 {
    scalar t = `tt'
    scalar tup = t*(1+`h')
    scalar tdn = t*(1-`h')
    scalar cup = exp(lngamma(1 - 2/tup) - 2*lngamma(1 - 1/tup)) - 1
    scalar cdn = exp(lngamma(1 - 2/tdn) - 2*lngamma(1 - 1/tdn)) - 1
    scalar elas = (ln(cup) - ln(cdn)) / (ln(1+`h') - ln(1-`h'))
    * d ln(θ̃) = (1/elas)·d ln(CV²)；d ln(CV²)=0.01 时的百分比变化 = 100*0.01/elas = 1/elas
    scalar invp = 1/elas
    display "  " %7.4f t "       " %10.4f elas "            " %7.3f invp " %"
}
display "  " "{hline 70}"
display "  读法：弹性约 −3 表示 θ̃ 每变动 1%，式(8) 右端反向变动 3%；"
display "        亦即测到的工资方差每偏高 1%，反解出的 θ̃ 只偏低约 0.35% —— "
display "        所以【不是】测量噪声把 ρ 拖垮的，而是工资方差本身系统性偏低（见 D 段）。"

*===================================================================== C
display _n "{hline 78}"
display " C. ρ 缺口的分解 —— ρ = 1 − θ̃/θ，两个估计量的误差会叠加"
display "{hline 78}"
foreach c in IDN US {
    if "`c'" == "IDN" {
        scalar to   = 10.5510
        scalar tto  = 4.0874
        scalar tp   = 12.5
        scalar ttp  = 3.18
        local nm "印度尼西亚 1995"
    }
    if "`c'" == "US" {
        scalar to   = 41.1300
        scalar tto  = 5.467
        scalar tp   = 27.6
        scalar ttp  = 2.69
        local nm "美国 1990"
    }
    scalar r_ours  = 1 - tto/to      // 我们的 θ̃ + 我们的 θ   ← 本复现实际值
    scalar r_paper = 1 - ttp/tp      // 论文的 θ̃ + 论文的 θ
    scalar r_th    = 1 - ttp/to      // 论文 θ̃ + 我们的 θ    → 只换 θ̃
    scalar r_tt    = 1 - tto/tp      // 我们的 θ̃ + 论文的 θ  → 只换 θ
    scalar gap   = r_ours - r_paper
    scalar g_th  = r_th   - r_paper
    scalar g_tt  = r_tt   - r_paper
    scalar g_int = gap - g_th - g_tt
    display _n "  【`nm'】   θ: 我们 " %7.3f to " / 论文 " %5.1f tp
    display "               θ̃: 我们 " %7.4f tto " / 论文 " %5.2f ttp
    display "    " "{hline 68}"
    display "    论文 ρ     = 1 − " %6.3f ttp "/" %6.2f tp "       = " %8.4f r_paper
    display "    本复现 ρ   = 1 − " %6.4f tto "/" %7.3f to "     = " %8.4f r_ours
    display "    " "{hline 68}"
    display "    只换 θ̃（θ 保持我们的）     ρ = " %8.4f r_th "   θ̃ 单独贡献 " %8.4f g_tt
    display "    只换 θ（θ̃ 保持我们的）     ρ = " %8.4f r_tt "   θ  单独贡献 " %8.4f g_th
    display "    交互项                                      " %8.4f g_int
    display "    " "{hline 68}"
    display "    总缺口 ρ_本复现 − ρ_论文 = " %8.4f gap
    scalar s_th  = 100*g_th/gap
    scalar s_tt  = 100*g_tt/gap
    scalar s_int = 100*g_int/gap
    local sg1 = cond(s_th  >= 0, "+", "")
    local sg2 = cond(s_tt  >= 0, "+", "")
    local sg3 = cond(s_int >= 0, "+", "")
    display "    归因占比：  θ 占 `sg1'" %6.1f s_th " %   θ̃ 占 `sg2'" %6.1f s_tt " %   交互占 `sg3'" %6.1f s_int " %"
}

*===================================================================== D
display _n "{hline 78}"
display " D. 要命中论文的 θ̃，工资方差需要是多少？（我们离多远）"
display "{hline 78}"
display "  样本                                  实际 var/w̄²   反解 θ̃   论文 θ̃"
display "  " "{hline 74}"
foreach row in "IDN_main 0.16956 3.18" "IDN_paper 0.14089 3.18" "US_main 0.07879 2.69" "US_paper 0.05635 2.69" {
    local nm  : word 1 of `row'
    local var = real("`: word 2 of `row''")
    local ttp = real("`: word 3 of `row''")
    * 二分法：找 θ̃ 使式(8) 右端 = 观测到的方差
    scalar lo = 2.0001
    scalar hi = 300
    forvalues it = 1/200 {
        scalar mid = (lo+hi)/2
        scalar cmid = exp(lngamma(1 - 2/mid) - 2*lngamma(1 - 1/mid)) - 1
        if cmid > `var' {
            scalar lo = mid
        }
        else {
            scalar hi = mid
        }
    }
    scalar tth = (lo+hi)/2
    * 论文 θ̃ 对应的方差
    scalar lnp = lngamma(1 - 2/`ttp') - 2*lngamma(1 - 1/`ttp')
    scalar varp = exp(lnp) - 1
    scalar ratio = varp/`var'
    if "`nm'" == "IDN_main"  local full "印尼 1995 省级 · 主口径（对数 2SLS）"
    if "`nm'" == "IDN_paper" local full "印尼 1995 省级 · 论文口径（PPML+IV）"
    if "`nm'" == "US_main"   local full "美国 1990 · 主口径（对数 2SLS）"
    if "`nm'" == "US_paper"  local full "美国 1990 · 论文口径（PPML+IV）"
    display "  " %-34s "`full'" %11.5f `var' "  " %8.4f tth "  " %6.2f `ttp'
    display "        论文 θ̃ 隐含的方差 = " %9.5f varp " ，是我们实际测到的 " %7.3f ratio " 倍"
}
display "  " "{hline 74}"
display "  最后一列若为 13，表示论文 θ̃ 隐含的工资方差是我们实际测到的 13 倍。"

*===================================================================== E
display _n "{hline 78}"
display " E. 各个样本口径下测到的工资方差（来自 theta_paper_spec_out.log）"
display "{hline 78}"
display "  印尼 1995："
display "    全部男性户主 / 不筛格子        var = 0.16422"
display "    全部男性户主 / 丢 n_raw<5      var = 0.14089"
display "    全部男性户主 / 丢 n_wage<5     var = 0.11086"
display "    论文 θ̃=3.18 隐含              var = 0.37209"
display "  美国 1990："
display "    全部人 / 不筛格子              var = 0.07886"
display "    全部人 / 丢 n_raw<5            var = 0.05635"
display "    全部人 / 丢 n_wage<5           var = 0.05579"
display "    论文 θ̃=2.69 隐含              var = 0.73089"
display "  → 印尼换口径只能挪到 0.111~0.164（论文要 0.372，差 2.3~3.4 倍）；"
display "    美国换口径只能挪到 0.056~0.079（论文要 0.731，差 9.3~13.1 倍）。"
display "    所以差距不是口径能修的，而是数据覆盖（我们 17 省 × 1 年 vs 论文 281 县 × 3 年）。"

display _n "{hline 78}"
display "  完成：$S_DATE $S_TIME"
display "{hline 78}"
log close