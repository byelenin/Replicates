*==============================================================
* nogen 到底管什么？—— 用最小例子演示
*==============================================================
clear all
set more off
capture log close
log using "nogen_out.log", replace text

* ---------- 造两份小数据 ----------
clear
input long bcode byte urban
1101 1
1101 2
1102 1
1105 2
1105 1
9999 1
end
tempfile master
save `master'

clear
input long bcode byte o_rural
1101 0
1102 1
1105 0
end
tempfile look
save `look'

display _n "==== A. 不加 keep、不加 nogen ===="
use `master', clear
merge m:1 bcode using `look'
display _n "---- 变量列表 ----"
describe, short
display _n "---- tab _merge ----"
tab _merge
display _n "---- 数据 ----"
list, sepby(bcode)

display _n "==== B. 加 keep(master match)，不加 nogen ===="
use `master', clear
merge m:1 bcode using `look', keep(master match)
display _n "---- tab _merge ----"
tab _merge

display _n "==== C. 加 keep(master match) 和 nogen ===="
use `master', clear
merge m:1 bcode using `look', keep(master match) nogen
capture confirm variable _merge
display "变量 _merge 是否存在？ _rc = " _rc "   （111 = 不存在）"
display _n "---- 变量列表 ----"
describe, short
display _n "---- 数据（o_rural 还在！）----"
list, sepby(bcode)

log close