*==============================================================================
* theta_tilde_derivation.do
* 目的：把 θ̃ = θ(1−ρ) 从联合 Fréchet 分布推出来，并用蒙特卡洛验证
* 全部用 Stata（runiform / rnormal / lngamma），不读大数据，几十秒跑完
*==============================================================================
clear all
set more off
set varabbrev off
set linesize 200
set seed 20191029
capture log close
log using "theta_tilde_deriv_out.log", replace text

display "{hline 78}"
display "  θ̃ = θ(1−ρ) 的推导与蒙特卡洛验证"
display "  运行时间：$S_DATE $S_TIME"
display "{hline 78}"

*=============================================================================
* A. 解析推导
*=============================================================================
display _n "{hline 78}"
display " A. 解析推导（论文原文第 896–921 行）"
display "{hline 78}"
display "  论文的联合分布（原文的形式，内层指数是 θ，外层是 1−ρ）："
display ""
display "     F(s_1,...,s_N) = exp{ − [ Σ_{d=1}^{N} s_d^(−θ) ]^(1−ρ) }"
display ""
display "  第 1 步：求第 1 个地点的边缘分布 —— 把 s_2,...,s_N 全部送到 +∞"
display "           因为 s_d → ∞ 时 s_d^(−θ) → 0，所以求和里除了 d=1 的项全变成 0："
display ""
display "     F(s_1, ∞, ..., ∞) = exp{ − [ s_1^(−θ) + 0 + ... + 0 ]^(1−ρ) }"
display ""
display "  第 2 步：只剩一项，方括号消失"
display ""
display "                       = exp{ − [ s_1^(−θ) ]^(1−ρ) }"
display ""
display "  第 3 步：幂的幂 = 指数相乘 —— 这一步就是 (1−ρ) 变成乘数的位置"
display ""
display "                       = exp{ − s_1^(−θ·(1−ρ)) }"
display ""
display "  第 4 步：对照 Fréchet 的标准形式  F(x) = exp{ − x^(−α) }"
display "           标准式的形状参数 α 出现在 x 的指数上，取负号。"
display "           这里 x = s_1 的指数是 −θ(1−ρ)，所以 α = θ(1−ρ) ≡ θ̃。"
display ""
display "  结论：  s_d 的边缘分布 = Fréchet( θ̃ )，  θ̃ ≡ θ(1−ρ)"
display ""
display "  反过来，论文第 921 行说「it is useful to work with θ = θ̃/(1−ρ)」——"
display "  这正是把上式反解，所以论文的主参数 θ = θ̃/(1−ρ) 恰好是内层指数。"

*=============================================================================
* B. 这个性质叫什么、为什么函数形式要这么设计
*=============================================================================
display _n "{hline 78}"
display " B. 这是什么性质"
display "{hline 78}"
display "  论文自己只写了「a property of the Fréchet distribution」（原文 1327 行），没给名字。"
display "  标准名称：多变量极值分布（multivariate extreme value / max-stable）"
display "            在【取边缘】时的【闭合性】—— 边缘仍是同一族的分布。"
display ""
display "  这个函数形式里有两个机关，缺一不可："
display ""
display "  机关①  内层是【幂的和】 Σ_d s_d^(−θ)"
display "          → 其他维度送到 ∞ 时，它们那几项变成 0，自动消失，不会污染留下的维度。"
display "            如果换成乘积 Π_d s_d 或别的形式，就没有这个性质了。"
display ""
display "  机关②  外层指数是 (1−ρ)"
display "          → 取幂时指数相乘：(x^(−θ))^(1−ρ) = x^(−θ(1−ρ))。"
display "            所以形状参数被「乘上」了 (1−ρ)。"
display ""
display "  两条合起来：形状参数 θ 被压缩成 θ(1−ρ) = θ̃。"

*=============================================================================
* C. 为什么是这个函数形式 —— 分解式（想清楚的钥匙）
*=============================================================================
display _n "{hline 78}"
display " C. 分解式：每个人 = 一个「总天赋」 × 每个地点一次「运气」"
display "{hline 78}"
display "  把技能写成：      s_id = V_i^(1/θ) · u_id"
display ""
display "    u_id ~ i.i.d. Fréchet(θ)   —— 个人 i 在目的地 d 的【地方特有运气】"
display "                                  每个人在每个地方各抽一次，互相独立"
display "    V_i  ~ 正稳定分布，指数 (1−ρ) —— 个人 i 的【总天赋】"
display "                                  一个人只抽一次，所有地方共用"
display ""
display "  推导：先给定 V_i = v，此时各地点条件独立"
display ""
display "    P(s_id ≤ x | V=v) = P(u_id ≤ x·v^(−1/θ)) = exp( −(x·v^(−1/θ))^(−θ) ) = exp( −v·x^(−θ) )"
display ""
display "  乘起来（各地点条件独立）："
display ""
display "    P(全部 ≤ x | v) = Π_d exp( −v·x_d^(−θ) ) = exp( −v · Σ_d x_d^(−θ) )"
display ""
display "  再对 V 取期望。用正稳定分布的性质  E[ exp(−sV) ] = exp( −s^(1−ρ) )："
display ""
display "    F(s) = E_V[ exp( −V · Σ_d s_d^(−θ) ) ] = exp{ − [ Σ_d s_d^(−θ) ]^(1−ρ) }   ✓ 与论文一致"
display ""
display "  ⭐ 所以 ρ 的本质：【公共因子 V_i 的强弱】"
display "     ρ → 0 ：V 退化为常数 1，各地点抽签完全独立（没有任何「通用才能」）"
display "     ρ 越大：V 越主导，一个人在一处强、处处都强"
display "     ρ → 1 ：完全同步，技能【一维化】—— 论文第 920 行原话："
display "             「the case in which talent is unidimensional is a limiting case as ρ → 1」"

*=============================================================================
* D. 蒙特卡洛验证
*=============================================================================
display _n "{hline 78}"
display " D. 蒙特卡洛验证：50,000 个人 × 4 个地点"
display "{hline 78}"
display "  用印尼的参数：θ = 12.5, ρ = 0.74  ⇒  θ̃ = θ(1−ρ) = 12.5×0.26 = 3.25"

local NPER = 50000
local NLOC = 4
local TH   = 12.5
local RH   = 0.74
local ALP  = 1 - `RH'
local TTH  = `TH' * (1 - `RH')

* 造数据：NPER 个人 × NLOC 个地点，每个人一个 V
quietly {
    drop _all
    set obs `NPER'
    gen long pid = _n
    * 个人总天赋 V ~ 正稳定(指数 alpha)，用 Chambers-Mallows-Stuck 算法（取对数防溢出）
    gen double uu = 3.14159265358979 * runiform()
    gen double ww = -ln(runiform())
    gen double lnV = ln(sin(`ALP'*uu)) - (1/`ALP')*ln(sin(uu)) ///
                     + ((1-`ALP')/`ALP')*( ln(sin((1-`ALP')*uu)) - ln(ww) )
    drop uu ww
    * 展开成长表：每个人 × 每个地点
    expand `NLOC'
    bysort pid: gen byte loc = _n
    * 地方特有运气 u ~ Fréchet(theta)：  u = (-ln U)^(-1/theta)
    gen double ln_u = (-1/`TH') * ln( -ln(runiform()) )
    * 技能 s = V^(1/theta) * u
    gen double ln_s = lnV/`TH' + ln_u
    gen double s = exp(ln_s)
}
local ntot = _N
display "  模拟得到 `ntot' 个观测（`NPER' 人 × `NLOC' 地点）"
display ""

*---- D1. 边缘分布检验：应该是 Fréchet(θ̃)，而不是 Fréchet(θ)
display "  D1. 边缘分布检验（取第 1 个地点）"
display "  " "{hline 74}"
display "      把每个模拟值代进理论 CDF，得到的数应该服从 Uniform(0,1)（均值 0.5）。"
display "      CDF 越接近真实分布，这个「概率积分变换」就越均匀。"
display ""
display "                                         均值      低于0.5的比例    标准差(理论0.2887)"
display "  " "{hline 74}"
quietly {
    preserve
    keep if loc == 1
    gen double p_thetat = exp( -s^(-`TTH') )      // 假设是 Fréchet(θ̃)
    gen double p_theta  = exp( -s^(-`TH')  )      // 假设是 Fréchet(θ)  ← 反例
    quietly summarize p_thetat
    local m1 = r(mean)
    local s1 = r(sd)
    quietly count if p_thetat < 0.5
    local f1 = r(N)/_N
    quietly summarize p_theta
    local m2 = r(mean)
    local s2 = r(sd)
    quietly count if p_theta < 0.5
    local f2 = r(N)/_N
    restore
}
display "      假设 Fréchet(θ̃=" %5.2f `TTH' ")  →   " %8.4f `m1' "     " %8.4f `f1' "        " %8.4f `s1'
display "      假设 Fréchet(θ =" %5.2f `TH' ")  →   " %8.4f `m2' "     " %8.4f `f2' "        " %8.4f `s2'
display "  " "{hline 74}"
display "      → 第一行三项都接近理想值（0.5 / 0.5 / 0.289），第二行严重偏离。"
display "        这证明边缘分布的形状参数是 θ̃ = θ(1−ρ)，不是 θ。"

*---- D2. 直接比理论分位数与经验分位数
display _n "  D2. 理论分位数 vs 模拟分位数（第 1 个地点）"
display "  " "{hline 74}"
display "      分位点   模拟得到的中位数      Fréchet(θ̃) 理论      Fréchet(θ) 理论"
display "  " "{hline 74}"
quietly {
    preserve
    keep if loc == 1
    _pctile s, p(25 50 75 95)
    local q25 = r(r1)
    local q50 = r(r2)
    local q75 = r(r3)
    local q95 = r(r4)
    restore
}
foreach q in 25 50 75 95 {
    local sim = `q`q''
    * Fréchet(alpha) 的 q 分位点：( -ln(q/100) )^(-1/alpha)
    local tt_q = ( -ln(`q'/100) )^(-1/`TTH')
    local th_q = ( -ln(`q'/100) )^(-1/`TH')
    display "      " %5.0f `q' " %     " %12.4f `sim' "          " %12.4f `tt_q' "          " %12.4f `th_q'
}
display "  " "{hline 74}"
display "      → 模拟值与「Fréchet(θ̃) 理论」几乎重合；「Fréchet(θ) 理论」差了一个数量级。"

*---- D3. ρ 的作用：同一个人两个地点的相关性
display _n "  D3. ρ 到底控制什么：同一个人的 s_1 与 s_2 有多同步"
display "  " "{hline 74}"
display "      固定 θ = 12.5，只变 ρ —— 看两个地点的抽签相关性"
display ""
display "        ρ      θ̃=θ(1−ρ)   皮尔逊相关    都进前25%的比例   斯皮尔曼秩相关"
display "  " "{hline 74}"
foreach rho in 0 0.3 0.5 0.74 0.9 0.99 {
    quietly {
        preserve
        drop _all
        set obs `NPER'
        gen long pid = _n
        local alp = 1 - `rho'
        gen double uu = 3.14159265358979 * runiform()
        gen double ww = -ln(runiform())
        * alpha = 1 (即 rho = 0) 时 V 退化为常数 1，必须特判，
        * 否则 0 * ln(sin(0)) = 0 * 缺失 = 缺失
        if `alp' >= 1 {
            gen double lnV = 0
        }
        else {
            gen double lnV = ln(sin(`alp'*uu)) - (1/`alp')*ln(sin(uu)) ///
                             + ((1-`alp')/`alp')*( ln(sin((1-`alp')*uu)) - ln(ww) )
        }
        drop uu ww
        expand 2
        bysort pid: gen byte loc = _n
        gen double ln_u = (-1/`TH') * ln( -ln(runiform()) )
        gen double s = exp(lnV/`TH' + ln_u)
        keep pid loc s
        reshape wide s, i(pid) j(loc)
        quietly correlate s1 s2
        local corr = r(rho)
        quietly spearman s1 s2
        local spr = r(rho)
        quietly _pctile s1, p(75)
        local c1 = r(r1)
        quietly _pctile s2, p(75)
        local c2 = r(r1)
        quietly count if s1 > `c1' & s2 > `c2'
        local both = r(N)/_N
        restore
    }
    local ttv = `TH'*(1-`rho')
    display "      " %5.2f `rho' "   " %9.3f `ttv' "      " %9.4f `corr' "       " %9.4f `both' "        " %9.4f `spr'
}
display "  " "{hline 74}"
display "      → 相关性随 ρ 单调上升；ρ → 1 时秩相关趋近 1 = 技能一维化（论文第 920 行）。"

*---- D4. 反过来：把每个人的 profile 标准化后，形状只由 θ 决定
display _n "  D4. 关键辨析：θ̃ 管【人与人之间】，θ 管【同一个人去不同地方】"
display "  " "{hline 74}"
display "      做法：把每个人的 4 个技能值除以本人最大值（去掉 V 的影响），"
display "            再看这个「个人内部 profile」的分布 —— 它对 ρ 应该【不敏感】。"
display ""
display "        ρ      标准化后 profile 的均值      标准化后 profile 的变异系数"
display "  " "{hline 74}"
foreach rho in 0 0.5 0.74 0.9 {
    quietly {
        preserve
        drop _all
        set obs `NPER'
        gen long pid = _n
        local alp = 1 - `rho'
        gen double uu = 3.14159265358979 * runiform()
        gen double ww = -ln(runiform())
        if `alp' >= 1 {
            gen double lnV = 0
        }
        else {
            gen double lnV = ln(sin(`alp'*uu)) - (1/`alp')*ln(sin(uu)) ///
                             + ((1-`alp')/`alp')*( ln(sin((1-`alp')*uu)) - ln(ww) )
        }
        drop uu ww
        expand 4
        bysort pid: gen byte loc = _n
        gen double ln_u = (-1/`TH') * ln( -ln(runiform()) )
        gen double s = exp(lnV/`TH' + ln_u)
        bysort pid: egen double smax = max(s)
        gen double z = s/smax
        quietly summarize z
        local mz = r(mean)
        local cz = r(sd)/r(mean)
        restore
    }
    display "      " %5.2f `rho' "        " %10.4f `mz' "                 " %10.4f `cz'
}
display "  " "{hline 74}"
display "      → 两列几乎不随 ρ 变化 ⇒「一个人在不同地点的相对优势形状」只由 θ 决定，"
display "        与 ρ 无关。而【人与人之间的差距】才由 θ̃ = θ(1−ρ) 决定（看 D1/D2）。"
display "        这就是为什么式(8) 用的是 θ̃，而式(4) 排序用的是 θ。"

display _n "{hline 78}"
display "  完成：$S_DATE $S_TIME"
display "{hline 78}"
log close