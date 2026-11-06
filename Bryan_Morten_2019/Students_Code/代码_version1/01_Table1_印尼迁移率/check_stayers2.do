* ============================================================
* 续查：留在家乡的比例、以及 p_od 是否加总为 1
* ============================================================
clear all
set more off
use "D:\研一上\微观计量\复现\idn_od_panel.dta", clear

display _n(2) "{hline 76}"
display "1) 面板里有几年？"
display "{hline 76}"
tabulate year

display _n(2) "{hline 76}"
display "2) 对角线（不迁移）的观测"
display "{hline 76}"
gen byte stay = (o == d)
label define stayl 0 "迁移(o≠d)" 1 "不迁移(o=d)"
label values stay stayl

display "  p_od = 出生在 o 的人里，住在 d 的比例"
display ""
table stay, statistic(mean p_od) statistic(min p_od) statistic(max p_od) ///
      statistic(count p_od) nformat(%9.4f)

display _n "  >>> 对角线上的 p_od 就是【留在老家的人占本省出生人口的比例】"
display ""
list year o d p_od n n_o wage_od if o == d, noobs sep(0)

display _n(2) "{hline 76}"
display "3) 检查：对每个出发地 o，p_od 加起来是不是 1"
display "{hline 76}"
preserve
    collapse (sum) sum_p = p_od (count) ncell = p_od, by(year o)
    display ""
    summarize sum_p
    display ""
    display "  如果每行加起来接近 1，说明分母用的是【所有出生在 o 的人】，"
    display "  也就是把不迁移的人算进去了。"
    display ""
    list year o sum_p ncell in 1/20, noobs sep(0)
restore

display _n(2) "{hline 76}"
display "4) 不迁移 vs 迁移：人数和工资"
display "{hline 76}"
table stay, statistic(sum n) statistic(sum n_o) statistic(mean wage_od) ///
      statistic(count wage_od) nformat(%12.0f)

display _n(2) "{hline 76}"
display "5) 只保留有工资的观测后，对角线还在吗？"
display "{hline 76}"
quietly count if !missing(wage_od)
display "  有 wage_od 的观测数 = " r(N)
quietly count if !missing(wage_od) & o == d
display "  其中有 wage_od 的 (o,o) 观测 = " r(N)
quietly count if !missing(wage_od) & o != d
display "  其中有 wage_od 的 (o≠d) 观测 = " r(N)
display ""
display "  论文要求：丢掉观测到的迁移人数少于 5 的样本（第 909 行）"
quietly count if !missing(wage_od) & n >= 5
display "  加上 n >= 5 之后 = " r(N)
quietly count if !missing(wage_od) & n >= 5 & o == d
display "  其中 (o,o) 还有 = " r(N)

display _n(2) "{hline 76}"