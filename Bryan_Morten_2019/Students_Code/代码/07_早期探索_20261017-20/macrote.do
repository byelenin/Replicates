*==============================================================
* 实验：display 和 local 的区别，以及各种写法的结果
*==============================================================
clear all
set more off
capture log close
log using "macrote_out.log", replace text

* ---- 这才是「赋值」：把 0.78169712 存进名为 med 的小盒子 ----
local med = 0.78169712

display _n "==== A：反引号+单引号，放在引号外面 ===="
display "值 = " `med'

display _n "==== B：反引号+单引号，放在引号里面 ===="
display "值 = `med'"

display _n "==== C：没有反引号（错）===="
display "值 = med"

display _n "==== D：你粘的样子（只有单引号，没反引号）===="
capture noisily display "值 = " med'
display "返回码 _rc = " _rc

display _n "==== E：宏可以直接当数字参与运算 ===="
display 1 + `med'

display _n "==== F：宏用在 if 条件里 ===="
display (`med' > 0.5)

log close