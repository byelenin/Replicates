*==============================================================
* 实验：重跑时旧文件会怎样
*==============================================================
clear all
set more off
capture log close
log using "erase_out.log", replace text

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace"

display _n "==== 1. erase 一个不存在的文件 ===="
capture noisily erase "test_lookup.dta"
display "返回码 _rc = " _rc

display _n "==== 2. 第一次 save（文件不存在）===="
clear
input long bcode byte o_rural
1101 1
1102 0
end
capture noisily save "test_lookup.dta"
display "返回码 _rc = " _rc

display _n "==== 3. 第二次 save，不加 replace（文件已存在）===="
capture noisily save "test_lookup.dta"
display "返回码 _rc = " _rc

display _n "==== 4. 第二次 save，加 replace ===="
capture noisily save "test_lookup.dta", replace
display "返回码 _rc = " _rc

display _n "==== 5. describe using —— 不加载数据就能看文件内容 ===="
capture noisily describe using "test_lookup.dta"
display "返回码 _rc = " _rc

display _n "==== 6. 清理 ===="
capture noisily erase "test_lookup.dta"
display "返回码 _rc = " _rc

log close