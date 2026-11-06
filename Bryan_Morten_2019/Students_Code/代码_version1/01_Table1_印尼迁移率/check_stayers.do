* ============================================================
* 检查：不迁移的人（留在老家）在不在面板里？
* ============================================================
clear all
set more off

use "D:\研一上\微观计量\复现\idn_od_panel.dta", clear

display _n(2) "{hline 76}"
display "面板结构"
display "{hline 76}"
describe, short
display ""
describe

display _n(2) "{hline 76}"
display "关键检查：有没有 o == d 的观测（即留在老家的人）"
display "{hline 76}"

capture confirm variable o
local has_o = (_rc == 0)
capture confirm variable d
local has_d = (_rc == 0)

if `has_o' & `has_d' {
    quietly count
    local Ntot = r(N)
    quietly count if o == d
    local Ndiag = r(N)
    display "  总 OD 对数            = `Ntot'"
    display "  其中 o == d（不迁移）  = `Ndiag'"
    display "  非对角线（迁移）       = " `Ntot' - `Ndiag'
    display ""

    if `Ndiag' > 0 {
        display "  >>> 结论：不迁移的人在面板里，共有 `Ndiag' 个 (o,o) 观测"
    }
    else {
        display "  >>> 结论：面板里【没有】o == d 的观测"
    }

    display _n "  按是否迁移分组，看迁移比例和工资"
    gen byte stay = (o == d)
    label define stayl 0 "迁移(o≠d)" 1 "不迁移(o=d)"
    label values stay stayl

    capture confirm variable pi
    if _rc != 0 {
        capture confirm variable pi_do
    }
    local pivar ""
    foreach v in pi pi_do share_pi {
        capture confirm variable `v'
        if _rc == 0 & "`pivar'" == "" local pivar "`v'"
    }
    display "  找到的迁移比例变量：`pivar'"

    local wvar ""
    foreach v in wage_od wage ln_wage wagedo {
        capture confirm variable `v'
        if _rc == 0 & "`wvar'" == "" local wvar "`v'"
    }
    display "  找到的工资变量：`wvar'"

    if "`pivar'" != "" {
        display _n "  迁移比例 `pivar' 的分组统计"
        table stay, statistic(mean `pivar') statistic(min `pivar') ///
              statistic(max `pivar') statistic(count `pivar') nformat(%9.4f)
    }
    if "`wvar'" != "" {
        display _n "  工资 `wvar' 的分组统计"
        table stay, statistic(mean `wvar') statistic(count `wvar') nformat(%9.4f)
    }

    display _n "  对角线上的迁移比例（每个省留在本省的比例）"
    if "`pivar'" != "" {
        list o d `pivar' if o == d, noobs sep(0)
    }
}
else {
    display "  面板里没有 o / d 变量，实际变量名如下："
    describe, short
}

display _n(2) "{hline 76}"