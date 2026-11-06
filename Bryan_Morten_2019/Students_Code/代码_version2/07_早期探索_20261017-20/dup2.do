*==============================================================
* duplicates drop 完整行为测试（用 capture 防止中断）
*==============================================================
clear all
set more off
capture log close
log using "dup2_out.log", replace text

clear
input long k double x
1 10
1 10
1 20
2 40
2 50
3 60
end
tempfile base
save `base'

display _n "===== A: duplicates drop （不写变量，不加 force）====="
use `base', clear
capture noisily duplicates drop
count
list, noobs

display _n "===== B: duplicates drop k （写变量，不加 force）====="
use `base', clear
capture noisily duplicates drop k
display "返回码 _rc = " _rc
count
list, noobs

display _n "===== C: duplicates drop k, force ====="
use `base', clear
capture noisily duplicates drop k, force
count
list, noobs

display _n "===== D: duplicates drop, force （不写变量，加 force）====="
use `base', clear
capture noisily duplicates drop, force
count
list, noobs

log close