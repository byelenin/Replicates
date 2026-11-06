*==============================================================================
* alpha_d_probe.do —— 看看现成的 dta 里有没有 α_d 需要的变量
*==============================================================================
clear all
set more off
set linesize 200
capture log close
log using "alpha_d_probe_out.log", replace text

local root "D:\研一上\微观计量\复现"

foreach f in idn_od_panel idn_od_panel_malehead idn_od_panel_regency {
    display _n(2) "{hline 78}"
    display "  文件：`f'.dta"
    display "{hline 78}"
    capture confirm file "`root'\\`f'.dta"
    if _rc {
        display "  ❌ 不存在"
        continue
    }
    use "`root'\\`f'.dta", clear
    display "  观测数 = " _N
    display _n "  变量："
    describe, short
    display _n "  关键变量是否存在："
    foreach v in o d ln_p ln_p_rev ln_poo ln_pdd ln_pdnoto ln_wage wage_od dist_km {
        capture confirm variable `v'
        if _rc {
            display "    `v'  ❌"
        }
        else {
            quietly summarize `v'
            display "    `v'  ✅   非缺失 = " %6.0f r(N) "   均值 = " %12.5f r(mean)
        }
    }
}

display _n(2) "{hline 78}"
display "  完成"
display "{hline 78}"
log close