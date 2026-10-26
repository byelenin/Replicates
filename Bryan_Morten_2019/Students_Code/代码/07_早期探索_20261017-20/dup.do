*==============================================================
* 实验：duplicates drop 到底怎么定义"重复"
*==============================================================
clear all
set more off
capture log close
log using "dup_out.log", replace text

* 造数据：k=1 出现 3 次（其中两行完全相同），k=2 出现 2 次，k=3 出现 1 次
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

display _n "================ 原始数据 ================"
use `base', clear
list, noobs

display _n "================ duplicates report ================"
duplicates report

display _n "================ duplicates report k ================"
duplicates report k

* ---------- 测试 A：不写变量，不加 force ----------
display _n "===== A: duplicates drop  （不写变量） ====="
use `base', clear
duplicates drop
count
list, noobs

* ---------- 测试 B：写变量，不加 force ----------
display _n "===== B: duplicates drop k  （写变量，不加 force） ====="
use `base', clear
duplicates drop k
count
list, noobs

* ---------- 测试 C：写变量，加 force ----------
display _n "===== C: duplicates drop k, force ====="
use `base', clear
duplicates drop k, force
count
list, noobs

* ---------- 测试 D：不写变量，加 force ----------
display _n "===== D: duplicates drop, force ====="
use `base', clear
duplicates drop, force
count
list, noobs

log close