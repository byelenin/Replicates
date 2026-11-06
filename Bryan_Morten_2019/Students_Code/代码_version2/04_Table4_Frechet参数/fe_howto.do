* ============================================================
* 固定效应怎么算 —— 完整演示（修正版）
* ============================================================
clear all
set more off
set seed 20191029

set obs 360
gen byte o = ceil(_n/120)
gen byte d = 1 + floor(mod(_n-1,120)/30)      // ← 修正：d 从 1 开始

gen double w_true = .
replace w_true = 1.00 if d == 1
replace w_true = 1.50 if d == 2
replace w_true = 0.80 if d == 3
replace w_true = 1.20 if d == 4

gen double q_true = .
replace q_true = 1.00 if o == 1
replace q_true = 0.60 if o == 2
replace q_true = 1.40 if o == 3

gen double pi = 0.05 + 0.10*runiform()
replace pi = pi + 0.02 if d == 2
replace pi = pi - 0.01 if o == 3

local Gbar  = 0.9
local theta = 5
local lnG   = ln(`Gbar')

gen double ln_pi   = ln(pi)                   // ← 先算好变量，reghdfe 不认 ln(pi)
gen double ln_wage = `lnG' + ln(w_true) - (1/`theta')*ln_pi + ///
                     ln(q_true) + 0.15*rnormal()

display _n(2) "{hline 76}"
display "真值：θ=5（系数 -0.2）；w_d = 1.00 / 1.50 / 0.80 / 1.20；q_o = 1.00 / 0.60 / 1.40"
display "{hline 76}"

* ============================================================
* 方法一：虚拟变量
* ============================================================
display _n(2) "{hline 76}"
display "方法一：regress ln_wage ln_pi i.o i.d"
display "{hline 76}"
quietly regress ln_wage ln_pi i.o i.d

display _n "  系数           估出来      真实值      差"
display "  {hline 50}"
display "  ln(π)        " %9.4f _b[ln_pi] "   " %9.4f -1/`theta' "   " %9.4f _b[ln_pi]+1/`theta'
display "  2.d          " %9.4f _b[2.d]   "   " %9.4f ln(1.50) "   " %9.4f _b[2.d]-ln(1.50)
display "  3.d          " %9.4f _b[3.d]   "   " %9.4f ln(0.80) "   " %9.4f _b[3.d]-ln(0.80)
display "  4.d          " %9.4f _b[4.d]   "   " %9.4f ln(1.20) "   " %9.4f _b[4.d]-ln(1.20)
display "  2.o          " %9.4f _b[2.o]   "   " %9.4f ln(0.60) "   " %9.4f _b[2.o]-ln(0.60)
display "  3.o          " %9.4f _b[3.o]   "   " %9.4f ln(1.40) "   " %9.4f _b[3.o]-ln(1.40)
display "  常数项       " %9.4f _b[_cons] "   " %9.4f `lnG' "   " %9.4f _b[_cons]-`lnG'

* ============================================================
* 方法三：还原绝对水平（归一化 q_1 = 1）
* ============================================================
display _n(2) "{hline 76}"
display "方法三：用归一化 q_1 = 1 还原 w_d 和 q_o 的绝对水平"
display "{hline 76}"

quietly regress ln_wage ln_pi i.o i.d
local c    = _b[_cons]
local lnw1 = `c' - `lnG'

display _n "  d     ln(w_d)      w_d 还原     真实 w_d     误差"
display "  {hline 54}"
display "  1   " %10.4f `lnw1' "    " %8.4f exp(`lnw1') "     " %7.4f 1.00 "    " %7.4f exp(`lnw1')-1.00
forvalues i = 2/4 {
    local lnwi = `lnw1' + _b[`i'.d]
    quietly summarize w_true if d == `i'
    display "  `i'   " %10.4f `lnwi' "    " %8.4f exp(`lnwi') "     " %7.4f r(mean) "    " %7.4f exp(`lnwi')-r(mean)
}

display _n "  o     ln(q_o)      q_o 还原     真实 q_o     误差"
display "  {hline 54}"
display "  1   " %10.4f 0 "    " %8.4f 1 "     " %7.4f 1.00 "    " %7.4f 0
forvalues i = 2/3 {
    local lnqi = _b[`i'.o]
    quietly summarize q_true if o == `i'
    display "  `i'   " %10.4f `lnqi' "    " %8.4f exp(`lnqi') "     " %7.4f r(mean) "    " %7.4f exp(`lnqi')-r(mean)
}

* ============================================================
* 方法二：reghdfe + savefe + predict
* ============================================================
display _n(2) "{hline 76}"
display "方法二：reghdfe ..., absorb(d o, savefe) 然后 predict"
display "{hline 76}"

quietly reghdfe ln_wage ln_pi, absorb(d o, savefe)
display "  reghdfe 的 ln(π) 系数 = " %9.4f _b[ln_pi] "   （真实 -0.2000）"
display "  观测数 N = " e(N)

display _n "  savefe 造出来的变量："
capture describe __hdfe*, short
if _rc == 0 {
    display "  （存在）"
}

display _n "  试各种 predict 写法："
foreach opt in "d" "xbd" "xb" "residuals" {
    capture drop _ft
    capture predict double _ft, `opt'
    display "    predict ..., " %-10s "`opt'" "  → rc = " _rc
}
capture drop _ft

display _n "  取出固定效应的推荐写法（reghdfe 官方）："
capture predict double fe_d, d
if _rc == 0 {
    display "    predict fe_d, d 成功"
    forvalues i = 1/4 {
        quietly summarize fe_d if d == `i'
        display "      d=`i'   fe_d = " %9.4f r(mean)
    }
}
else {
    display "    predict fe_d, d 返回 rc = " _rc
    display "    → 改用 savefe 生成的 __hdfe1__ / __hdfe2__ 变量"
    capture confirm variable __hdfe1__
    if _rc == 0 {
        display "    __hdfe1__（对应 absorb 里第一个变量 d）分城市均值："
        forvalues i = 1/4 {
            quietly summarize __hdfe1__ if d == `i'
            display "      d=`i'   __hdfe1__ = " %9.4f r(mean)
        }
    }
    capture confirm variable __hdfe2__
    if _rc == 0 {
        display "    __hdfe2__（对应 o）分出发地均值："
        forvalues i = 1/3 {
            quietly summarize __hdfe2__ if o == `i'
            display "      o=`i'   __hdfe2__ = " %9.4f r(mean)
        }
    }
}

display _n(2) "{hline 76}"
display "结论：固定效应 = 虚拟变量的系数。相对差异两条路都能拿到，"
display "      绝对水平靠 q_1 = 1 这个归一化定出来。"
display "{hline 76}"