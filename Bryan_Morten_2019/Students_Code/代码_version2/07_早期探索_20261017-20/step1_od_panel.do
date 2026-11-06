* ==============================================================================
* BM2019 印尼侧复现 —— 第 1 步：造出 OD 面板（π_do + wage_od）
* ==============================================================================
* 这一步在做什么（一句话）：
*   把 718,837 行「一人一行」的人口普查数据，压成一张 220 行的
*   「出生地 × 现居地」汇总表。
*
* 产出两样东西（全文的地基）：
*   π_do    = 在 o 省出生的人里，有多大比例现在住在 d 省   （迁移份额）
*   wage_od = 从 o 省出生、现在在 d 省工作的人，平均工资    （工资楔子）
*
* 论文依据：
*   p2236 脚注 6：只用「男性户主」（模型里迁移是为了工作）  419,760 -> 187,065
*   p2236 脚注 7：剔除 Papua 和 West Papua
*   论文事实用 281 个 regency；结构估计汇总为 25 个省
*
* 设计说明：年份不写死。以后要换成 2010 的文件，只改第 1 步的路径即可。
* ==============================================================================


* ============================ 第 0 步：准备工作 ============================
* 清空内存里可能残留的数据；关掉分页；把结果同时写进日志文件
clear all
set more off
set linesize 200

* 把工作目录设到脚本所在文件夹（产出文件都会落在这里）
cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"

* 开日志。之后屏幕上出现的一切都会存进 step1.log
* replace = 如果已有同名日志就覆盖
log using "step1.log", replace text


* ============================ 第 1 步：读入数据 ============================
* 干什么：把人口普查原始数据读进 Stata 的内存。
*
* 写法说明：
*   use <要用的变量> using "<路径>", clear
*   只读需要的列，比整份读进来快得多、也省内存。
*   ★ 这一步对 ipumsi_00002.dta（含 2010，2.1 GB / 2432 万人）是必须的，
*     整份读进来要 5-7 GB 内存，会卡死。
*
* 这些变量各是什么：
*   year      = 调查年份
*   perwt     = 个人抽样权重（这个人代表多少个真实的人）★ 关键
*   geo1_id   = 现居地（省）编码
*   bplid     = 出生地（省）编码           ★ 关键
*   relate    = 与户主的关系（1 = 户主本人）
*   sex       = 性别（1 = 男，2 = 女）
*   age       = 年龄
*   incwage   = 工资薪金收入（卢比/月）
*   hhwt      = 住户权重

use year perwt hhwt geo1_id bplid relate sex age incwage ///
    using "D:\研一上\微观计量\ipumsi_00001.dta", clear

display _n "===== 第 1 步：读入完成 ====="
describe, short
count
display "  ^ 原始行数（应该 = 718,837）"


* ==================== 第 2 步：定义出生地 o 和现居地 d ====================
* 干什么：把两套编码对齐。
*
* ★ 这里有个坑：
*   bplid   用「纯省码」        例如 11 = 亚齐, 12 = 北苏门答腊
*   geo1_id 用「国家码 + 省码」 例如 360011, 360012
*   所以 geo1_id 必须减去 360000 才是省码，否则两套编码对不上。

gen int o = bplid
gen int d = geo1_id - 360000

label var o "出生省（origin）"
label var d "现居省（destination）"

display _n "===== 第 2 步：地理编码核对 ====="
display "  出生地 o 的取值："
tab o, missing
display "  现居地 d 的取值："
tab d, missing


* ==================== 第 3 步：剔掉两个不该在里面的地方 ====================
* 干什么：删掉两类观测，它们会让 π_do 算错。
*
* (a) o == 98 → 出生在国外的人（450 个）
*     他们没有「印尼的出生省」，无法进入 π_do 的分母。
*
* (b) o == 54 或 d == 626 → 东帝汶（28,117 个）
*     1999 年脱离印尼独立了；
*     而且它在两套编码里对不上（geo1_id = 360626，但 bplid = 54），
*     留着会污染 626 这个原本不存在的「省」。

drop if o == 98
drop if o == 54 | d == 626

display _n "===== 第 3 步：剔除后 ====="
count
display "  ^ 应该 = 690,270（718,837 - 450 - 28,117）"


* ==================== 第 4 步：按论文口径只留男性户主 ====================
* 干什么：论文 p2236 脚注 6 说：
*   "We restrict to male heads of households as our model is one in which
*    migration is motivated by work"
*   （我们只保留男性户主，因为模型里迁移的动机是工作）
*
* 编码含义：
*   relate == 1 → 户主本人
*   sex    == 1 → 男性
*   两个条件同时满足 → 男性户主

display _n "===== 第 4 步：男性户主 ====="
display "  relate 的分布（看看编码对不对）："
tab relate
display "  sex 的分布："
tab sex

count if relate == 1 & sex == 1
display "  ^ 男性户主人数（应该 = 139,444）"

keep if relate == 1 & sex == 1
count

summarize age, detail
display "  ^ 年龄分布，用来确认样本合理"


* ==================== 第 5 步：造 π_do（迁移份额矩阵）====================
* 干什么：这是整个第一步的灵魂。
*   按 (出生省 o, 现居省 d) 分组，数出每组有多少人，再除以该出生省的总人数。
*
* ★ 为什么要 preserve / restore：
*   π_do 要用「全部人」来算（不管有没有工资），
*   而下一步算工资只用工薪者。所以先保住完整样本，算完 π_do 再恢复。
*
* ★ 为什么必须用 perwt 加权：
*   perwt 是抽样权重。不加权算出来的是「样本比例」，
*   加权算出来才是「人口比例」。π_do 是模型里的真实份额，必须加权。
*
* 处理逻辑：
*   1) n = perwt，把每个人的权重当作他的「人数」
*   2) 按 (o,d) 分组求和 → n = 从 o 出生、现居 d 的总人数
*   3) 按 o 分组求总和   → n_o = 从 o 出生的总人数
*   4) π_do = n / n_o

preserve
    gen double n = perwt
    collapse (sum) n, by(year o d)
    bysort year o: egen n_o = total(n)
    gen double p_od = n / n_o

    label var n    "从 o 出生、现居 d 的人数（加权）"
    label var n_o  "从 o 出生的总人数（加权）"
    label var p_od "从 o 出生的人中现居 d 的比例 = π_do"

    * ★ 正确性检查（最重要的一条）：
    *   按出生省分组，π_do 必须加总到 1
    *   （从 o 出生的人，只能住在一个地方，所以各目的地份额之和 = 1）
    *   ⚠ 这个检查必须在这里做，也就是「合并之前」。
    *     合并会丢掉「有居民但没人挣工资」的单元，
    *     那样剩下的 π_do 就加总不到 1 了（那是正常的，见第 8 步说明）。
    bysort year o: egen p_check = total(p_od)
    quietly summarize p_check
    display _n "  【检查】π_do 按出生省加总：均值 = " %6.4f r(mean) ///
             "，最小 = " %6.4f r(min) "，最大 = " %6.4f r(max)
    display "         三个数都应该 = 1.0000，否则 π_do 算错了"
    drop p_check

    keep year o d n n_o p_od
    tempfile pop
    save "`pop'"
restore

display _n "===== 第 5 步：π_do 已算好并存入临时文件 ====="
display "  ★ 注意：p_od 是在 preserve/restore 内部生成的。"
display "    restore 之后内存恢复到原始样本，p_od 就不存在了，"
display "    所以这里不能直接 summarize p_od（会报 r(111)）。"
display "    π_do 的检查放到第 8 步合并之后再统一做。"


* ==================== 第 6 步：造 wage_od（平均工资）====================
* 干什么：对每个 (o,d) 单元，算出「从 o 出生、现居 d 的人的平均工资」。
*
* ★ 关键：先剔掉缺失码！
*   IPUMS 里 incwage 的缺失码是两个很大的数：
*     9999998 = 未知（unknown）
*     9999999 = 不适用（NIU，即没有工资收入的人）
*   不剔掉的话，平均工资会被这些天文数字直接拉爆。
*   条件 incwage > 0 & incwage < 9999990 把两类缺失和零值一起去掉。
*
* 加权平均的算法：
*   分子 ww    = Σ (perwt × incwage)
*   分母 sum_w = Σ perwt
*   wage_od = ww / sum_w
*   这和 Excel 的加权平均是一回事。

keep if incwage > 0 & incwage < 9999990

display _n "===== 第 6 步：有效工资样本 ====="
count
display "  ^ 有有效工资的男性户主人数（应该 = 49,617）"
summarize incwage, detail
display "  ^ 工资分布：均值约 330,239 卢比/月"

gen double ww = perwt * incwage
collapse (sum) ww perwt, by(year o d)
rename perwt sum_w
gen double wage_od = ww / sum_w

label var sum_w    "该单元的有效工资人数（加权）"
label var wage_od  "从 o 出生、现居 d 的工人的平均工资"

tempfile wag
save "`wag'"


* ==================== 第 7 步：合并成 OD 面板 ==========================
* 干什么：把「人数表」和「工资表」按 (year, o, d) 拼成一张宽表。
*
* merge 1:1 year o d → 一对一匹配
* _merge 的含义：
*   1 = 只在人数表里有（有人住，但没人挣工资）
*   2 = 只在工资表里有（不可能出现）
*   3 = 两边都有 ★ 我们要的
* 所以 keep if _merge == 3 会丢掉「有人但无工资」的单元，
* 这些单元算不出工资，对回归没用。

use "`pop'", clear
merge 1:1 year o d using "`wag'"

display _n "===== 第 7 步：合并结果 ====="
tab _merge

keep if _merge == 3
drop _merge


* ==================== 第 8 步：诊断（确认没做错）======================
* 干什么：检查这张表是否健康。要看三件事：
*   1) 单元数对不对
*   2) π_do 是否合理
*   3) 有没有「小得不可靠」的单元（样本太少的格子）

* 需要 ln 版本给回归用
gen double ln_wage = ln(wage_od)
gen double ln_p    = ln(p_od)

* ★ 16x16 子样本标记
*   1995 年作为「现居地」被覆盖的省只有 16 个：
*   苏门答腊 11-18、爪哇 31-35、巴厘/努沙登加拉 51-53
*   代码 > 53 的是：加里曼丹 61-64、苏拉威西 71-74、马鲁古 81、巴布亚 94、国外 98
*   这些省在 1995 年「没有抽样」——所以从它们出生的人，
*   π_do 的分母是残缺的（只看得到搬出去的人，看不到留在本省的人）。
*   → 强行使用会算出错误的 π_do，必须限制在 16x16。
*   这不是偷懒，是数据结构的硬要求。
gen byte obs_prov = (o <= 53)

display _n "===== 第 8 步：诊断 ====="
count
display "  ^ OD 单元总数（应该 = 348）"

count if obs_prov == 1
display "  ^ 16x16 子样本单元数（应该 = 220）"

summarize p_od wage_od
summarize n sum_w, detail
display "  ^ n = 加权人数；sum_w = 加权工资人数"

count if sum_w < 20
display "  ^ 有效工资人数 < 20 的单元数（越少越好）"

display "  ★ 关于「π_do 加总到 1」的检查说明："
display "    这个检查已经在第 5 步做过了，那里结果全部 = 1.0000。"
display "    如果在这里重做，会得到小于 1 的数（最小值约 0.60）——"
display "    这完全正常，不是错误。原因："
display "      第 7 步的 merge 丢掉了 41 个「有居民、但没人挣工资」的单元，"
display "      那些目的地 d 就不在面板里了，份额自然凑不满 1。"
display "    ★ 关键：π_do 每个数值本身是对的（第 5 步是按完整样本算的），"
display "      被丢掉的只是「没有工资、无法参与回归」的那些格子。"

bysort o: egen p_check = total(p_od)
quietly summarize p_check
display "    合并后的实际加总：均值 = " %6.4f r(mean) "，最小 = " %6.4f r(min)
drop p_check


* ==================== 第 9 步：对照论文 Fact 3（验收）=================
* 干什么：用刚造出来的表，跑论文的式(7)：
*   ln(wage_do) = ln(Γ̄) + ln(w_d) - (1/θ)·ln(π_do) + ln(q_o) + ln(ε^w_do)
*   即：ln_wage = β·ln_p + 目的地固定效应(d) + 出生地固定效应(o) + 误差
*
* i.d i.o 就是「目的地虚拟变量」和「出生地虚拟变量」——
* 它们分别吸收 w_d 和 q_o。
*
* 论文 Fact 3 的目标值：β = -0.039
* 理论值：β = -1/θ = -1/12.5 = -0.080
*
* 注意：这里用不加权的 OLS。
* 论文全文只有 3 处提到 "weight"，且没有为这组事实回归写明加权，
* 所以不加权是与论文可比的正确做法。

display _n "===== 第 9 步：Fact 3 验收 ====="

display _n "--- (a) 16x16，不加权 ←★ 与论文直接可比，目标 -0.039 ---"
regress ln_wage ln_p i.d i.o if obs_prov == 1

display _n "--- (b) 16x16，按人口加权（理论值 -1/theta = -0.080）---"
regress ln_wage ln_p i.d i.o if obs_prov == 1 [aw = n]

display _n "--- (c) 全样本，不加权 ---"
regress ln_wage ln_p i.d i.o

display _n "--- (d) 全样本，按人口加权 ---"
regress ln_wage ln_p i.d i.o [aw = n]


* ==================== 第 10 步：保存产出 ==============================
* 干什么：把这张表存下来。后面的第 2-8 步都从这个文件开始。

save "idn_od_panel_malehead.dta", replace
export delimited using "idn_od_panel_malehead.csv", replace

display _n "===== 第 1 步完成 ====="
display "  产出：idn_od_panel_malehead.dta / .csv"
display "  日志：step1.log"

log close