* ============================================================
*  gmm 耗时基准（第三版：表达式全部显式写开，避开字符串拼接 bug）
*  形状：wage_s = exp( 出发地虚拟变量的系数 + b1*ln_pi )
*  目的：量出 gmm 的耗时随参数个数怎么涨
* ============================================================
clear all
set more off
set linesize 140
set matsize 2000

log using "C:\Users\任娜\Documents\deepseek-harness\default-workspace\gmmbench_out.log", replace text

*--- 建面板 ---
use year bplid geo1_id incwage perwt sex relate age using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995
keep if sex == 1 & relate == 1 & inrange(age, 15, 65)
gen int o = bplid
gen int d = geo1_id - 360000
keep if inrange(o,11,18) | inrange(o,31,35) | inrange(o,51,54)
keep if inrange(d,11,18) | inrange(d,31,35) | inrange(d,51,54)
gen byte hasw = !missing(incwage) & incwage > 0 & incwage < 9999999
gen double m_w = perwt
gen double wx_w = perwt*incwage if hasw
gen double wg_w = perwt if hasw
collapse (sum) m_w wx_w wg_w, by(o d)
rename m_w m_od
egen double pop_o = total(m_od), by(o)
keep if o != d
gen double wage_od = wx_w/wg_w if wg_w > 0
keep if !missing(wage_od) & wage_od > 0 & m_od > 0
gen double pi_do = m_od/pop_o
keep if pi_do > 0
gen double ln_p = ln(pi_do)
gen double ln_p2 = ln_p^2
quietly summarize wage_od
gen double wage_s = wage_od/r(mean)
quietly tab o, gen(do_)
quietly tab d, gen(dd_)
quietly count
display _n(2) "面板观测数 N = " r(N)

timer clear

*--- 档 A：3 个参数 ---
display _n(2) "########## 档 A：3 个参数 ##########"
timer on 1
capture quietly gmm (wage_s - exp({q1}*do_1 + {q2}*do_2 + {b1}*ln_p)), instruments(do_1 do_2 ln_p ln_p2) iterate(50) nolog
display "  返回码 = " _rc
timer off 1
timer list 1

*--- 档 B：9 个参数 ---
display _n(2) "########## 档 B：9 个参数 ##########"
timer on 2
capture quietly gmm (wage_s - exp({q1}*do_1 + {q2}*do_2 + {q3}*do_3 + {q4}*do_4 + {q5}*do_5 + {q6}*do_6 + {q7}*do_7 + {q8}*do_8 + {b1}*ln_p)), instruments(do_1 do_2 do_3 do_4 do_5 do_6 do_7 do_8 ln_p ln_p2) iterate(50) nolog
display "  返回码 = " _rc
timer off 2
timer list 2

*--- 档 C：17 个参数 ---
display _n(2) "########## 档 C：17 个参数（全部出发地固定效应）##########"
timer on 3
capture quietly gmm (wage_s - exp({q1}*do_1 + {q2}*do_2 + {q3}*do_3 + {q4}*do_4 + {q5}*do_5 + {q6}*do_6 + {q7}*do_7 + {q8}*do_8 + {q9}*do_9 + {q10}*do_10 + {q11}*do_11 + {q12}*do_12 + {q13}*do_13 + {q14}*do_14 + {q15}*do_15 + {q16}*do_16 + {b1}*ln_p)), instruments(do_1 do_2 do_3 do_4 do_5 do_6 do_7 do_8 do_9 do_10 do_11 do_12 do_13 do_14 do_15 do_16 ln_p ln_p2) iterate(50) nolog
display "  返回码 = " _rc
timer off 3
timer list 3

*--- 档 D：32 个参数（出发地 + 目的地）---
display _n(2) "########## 档 D：32 个参数（双向固定效应）##########"
timer on 4
capture quietly gmm (wage_s - exp({q1}*do_1 + {q2}*do_2 + {q3}*do_3 + {q4}*do_4 + {q5}*do_5 + {q6}*do_6 + {q7}*do_7 + {q8}*do_8 + {q9}*do_9 + {q10}*do_10 + {q11}*do_11 + {q12}*do_12 + {q13}*do_13 + {q14}*do_14 + {q15}*do_15 + {q16}*do_16 + {r1}*dd_1 + {r2}*dd_2 + {r3}*dd_3 + {r4}*dd_4 + {r5}*dd_5 + {r6}*dd_6 + {r7}*dd_7 + {r8}*dd_8 + {r9}*dd_9 + {r10}*dd_10 + {r11}*dd_11 + {r12}*dd_12 + {r13}*dd_13 + {r14}*dd_14 + {r15}*dd_15 + {b1}*ln_p)), instruments(do_1 do_2 do_3 do_4 do_5 do_6 do_7 do_8 do_9 do_10 do_11 do_12 do_13 do_14 do_15 do_16 dd_1 dd_2 dd_3 dd_4 dd_5 dd_6 dd_7 dd_8 dd_9 dd_10 dd_11 dd_12 dd_13 dd_14 dd_15 ln_p ln_p2) iterate(50) nolog
display "  返回码 = " _rc
timer off 4
timer list 4

display _n(2) "================ 耗时汇总（秒）================"
timer list
display _n "  参数个数：A=3  B=9  C=17  D=32"

log close