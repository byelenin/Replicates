*==============================================================
* 测试：isid 检查唯一性，以及 using 有重复 key 时 merge 会不会失败
*==============================================================
clear all
set more off
capture log close
log using "isid_out.log", replace text

* ---------- 1. isid 在正常情况下 ----------
clear
input long bcode double o_rural
1101 1
1102 0
1103 1
end
display _n "==== 1. isid bcode（编码都唯一，应成功）===="
capture noisily isid bcode
display "返回码 _rc = " _rc

* ---------- 2. isid 在编码撞车时 ----------
clear
input long bcode double o_rural
1101 1
1101 0
1102 0
end
display _n "==== 2. isid bcode（1101 撞车，应报错）===="
capture noisily isid bcode
display "返回码 _rc = " _rc

* ---------- 3. duplicates drop 能不能救回来 ----------
display _n "==== 3. duplicates drop（不加变量）能不能删掉撞车的行 ===="
capture noisily duplicates drop
count
list, noobs

* ---------- 4. 用有重复 key 的表做 using 去 merge ----------
display _n "==== 4. merge m:1 遇到 using key 重复会怎样 ===="
tempfile look
save `look'
clear
input long bcode double moved
1101 0
1102 1
end
capture noisily merge m:1 bcode using `look'
display "返回码 _rc = " _rc

log close