*==============================================================
* 实验：merge 失败到底是「值标签」还是「变量类型」造成的？
*==============================================================
clear all
set more off
capture log close
log using "mrgtest_out.log", replace text

* ---------- 主数据：k = long 型 + 带值标签 ----------
clear
input long k double v
1101 10
1102 20
1103 30
end
label define LBL 1101 "aceh" 1102 "sumut" 1103 "sumbar"
label values k LBL
tempfile master
save `master'

* ---------- 查找表 A：k = long 型，无标签 ----------
clear
input long k double w
1101 100
1102 200
end
tempfile usingL
save `usingL'

* ---------- 查找表 B：k = double 型，无标签 ----------
clear
input double k double w
1101 100
1102 200
end
tempfile usingD
save `usingD'

* ===== 测试 1：master(long+标签) vs using(long 无标签) =====
display _n "===== 测试1: master long+标签   vs  using long 无标签 ====="
use `master', clear
merge 1:1 k using `usingL'
tab _merge

* ===== 测试 2：master(long+标签) vs using(double 无标签) =====
display _n "===== 测试2: master long+标签   vs  using double 无标签 ====="
use `master', clear
merge 1:1 k using `usingD'
tab _merge

* ===== 测试 3：master(long 无标签) vs using(long 无标签) =====
display _n "===== 测试3: master long 无标签  vs  using long 无标签 ====="
use `master', clear
label values k .
merge 1:1 k using `usingL'
tab _merge

* ===== 测试 4：master(long+标签) vs using(long 也有标签，同一套) =====
display _n "===== 测试4: master 有标签  vs  using 也有同一套标签 ====="
use `usingL', clear
label values k LBL
tempfile usingLab
save `usingLab'
use `master', clear
merge 1:1 k using `usingLab'
tab _merge

* ===== 测试 5：主数据的 key 带标签，但去标签的写法是 label drop =====
display _n "===== 测试5: 用 label drop 而不是 label values . ====="
use `master', clear
label drop LBL
merge 1:1 k using `usingL'
tab _merge

log close