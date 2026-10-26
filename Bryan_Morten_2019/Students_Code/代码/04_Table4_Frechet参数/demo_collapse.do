* ============================================================
*  教学演示：collapse 在干什么、加权人数是什么、加权平均工资是什么
*  用真实的 1995 年印尼数据
* ============================================================
clear all
set more off
set linesize 120

log using "C:\Users\任娜\Documents\deepseek-harness\default-workspace\demo_out.log", replace text

use year bplid geo1_id incwage perwt sex relate age using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
keep if sex == 1 & relate == 1 & inrange(age, 15, 65)
gen int o = bplid
gen int d = geo1_id - 360000
keep if inrange(o, 11, 18) | inrange(o, 31, 35) | inrange(o, 51, 54)
keep if inrange(d, 11, 18) | inrange(d, 31, 35) | inrange(d, 51, 54)

display _n(2) "================ A. 记录数 vs 加权人数 ================"
quietly count
display "  数据里一共有 " %9.0f r(N) " 条【记录】（每行一个人）"
gen double one = 1
quietly summarize one
display "  把 one 加起来 = " %14.0f r(sum) "   ← 这就是【不加权】的人数"
quietly summarize perwt
display "  把 perwt 加起来 = " %12.0f r(sum) "   ← 这才是【加权人数】"
display ""
display "  perwt 均值 = " %8.2f r(mean) "  （平均每条记录代表多少真人）"
display "  perwt 最小 = " %8.1f r(min)  "   最大 = " %8.1f r(max)
display ""
display "  → 差别有多大：加权人数是记录数的 " %6.1f r(sum)/_N " 倍"

display _n(2) "================ B. 有工资记录的人有多少 ================"
gen byte hasw = !missing(incwage) & incwage > 0 & incwage < 9999999
quietly count if hasw
display "  有工资记录的人：" %9.0f r(N) " 条记录（占全部记录的 " %5.2f 100*r(N)/_N "%）"
display "  → 论文说的数据缺陷就是这里：自雇者和农业人口没有工资记录。"

display _n(2) "================ C. 挑一个小到能手算的 (o,d) 组 ================"
bysort o d: gen long ngrp = _N
bysort o d: egen long nw  = total(hasw)
gen byte ismix = (nw > 0 & nw < ngrp)
gsort -ismix o d
local o1 = o[1]
local d1 = d[1]
keep if o == `o1' & d == `d1'
quietly count
display "  这一组：出生省 o = `o1'，现居省 d = `d1'"
display "  组内共 " %2.0f r(N) " 人，其中有工资记录的见下表（有缺口的行 incwage 是 .）"
display ""
display "  【collapse 之前】一个人一行："
list o d perwt incwage hasw, noobs sep(0)

display _n "  【collapse 之后】同一个 (o,d) 只剩一行："
gen double m_w    = perwt
gen double wx_w   = perwt*incwage if hasw
gen double wg_w   = perwt if hasw
gen double wg_all = perwt
collapse (sum) m_w wx_w wg_w wg_all, by(o d)
gen double wage_ok   = wx_w/wg_w
gen double wage_bad  = wx_w/wg_all
list o d m_w wx_w wg_w wg_all, noobs sep(0)

display ""
display "  m_w    = " %8.0f m_w[1]    "   ← 加权人数 = 组内所有 perwt 相加"
display "  wx_w   = " %10.0f wx_w[1]  "   ← 分子 = 有工资者的 (perwt × incwage) 相加"
display "  wg_w   = " %8.0f wg_w[1]    "   ← 正确分母 = 只有工资者的 perwt 相加"
display "  wg_all = " %8.0f wg_all[1]  "   ← 错误分母（把没工资的人也加进来了）"
display ""
display "  正确  wage_od = wx_w/wg_w   = " %10.2f wage_ok[1]
display "  错误  wage_od = wx_w/wg_all = " %10.2f wage_bad[1]
display ""
if wg_w[1] != wg_all[1] {
    display "  → 两者不一样！因为组内有人没有工资记录。"
    display "     如果分母用全部人，等于把「没工资」当成「工资 = 0」放进平均值，结果被拉低。"
}
else {
    display "  → 这一组 4 人都有工资，所以两种写法一样。"
    display "     但只要组内有人没工资，错误写法就会把均值拉低 —— 这就是代码里那句 if hasw 的作用。"
}

log close