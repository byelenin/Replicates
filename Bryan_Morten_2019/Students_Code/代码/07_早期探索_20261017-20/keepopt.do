*==============================================================
* merge 的 keep() 各选项到底保留哪些行？
*==============================================================
clear all
set more off
capture log close
log using "keepopt_out.log", replace text

* master: 5 行（1101 x2, 1102, 1105, 9999主数据独有）
clear
input long bcode byte urban
1101 1
1101 2
1102 1
1105 2
9999 1
end
tempfile master
save `master'

* using: 4 行（1101, 1102, 1105 匹配；8888 只在 using 里）
clear
input long bcode byte o_rural
1101 0
1102 1
1105 0
8888 1
end
tempfile look
save `look'

display _n "==== 不加 keep：基准 ===="
use `master', clear
quietly merge m:1 bcode using `look'
quietly count
display "总行数 = " r(N)
tab _merge

foreach opt in "master match" "match" "match using" "using match" {
    display _n "==== keep(`opt') ===="
    use `master', clear
    quietly merge m:1 bcode using `look', keep(`opt')
    quietly count
    display "保留行数 = " r(N)
    quietly tab _merge
    display "各 _merge 取值人数："
    quietly levelsof _merge, local(lv)
    foreach m of local lv {
        quietly count if _merge == `m'
        display "   _merge==`m' : " r(N)
    }
}

log close