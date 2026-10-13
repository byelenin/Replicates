/* 复现作者Figures1_5的五类跨国关系。
   country_input.dta由原作者MAT文件逐值转出；模型曲线读取本次模型结果。
   图中散点为原始国家观测，曲线为模型；横轴GDP使用对数刻度。
   图4检验女性比例与农业就业份额的横截面关系。 */
version 16.0
clear all
set more off
set varabbrev off
set scheme s2mono
local base "`c(pwd)'"
local raw "`base'/country_input.dta"
capture confirm file "`raw'"
if _rc local raw "`base'/input_1.dta"
local mod "`base'/model_trends_demo.dta"
capture confirm file "`mod'"
if _rc local mod "`base'/input_2.dta"
tempfile model
use "`mod'", clear
summarize pa if point==20, meanonly
gen double relative_pa=pa/r(mean)
gen double agshare=100*Na
rename gdp_us model_x
keep model_x wage_ratio relative_pa agshare
save `model'
use "`raw'", clear
keep if kind==1
drop if missing(x,y) | x<=0
append using `model'
twoway (scatter y x, msize(small) mcolor(gs8)) (line wage_ratio model_x, sort lwidth(medthick) lcolor(black)), xscale(log range(.015625 2)) xlabel(.015625 "1/64" .0625 "1/16" .25 "1/4" 1 "1" 2 "2") xtitle("GDP per worker (US = 1)") ytitle("Agricultural / nonagricultural wage") legend(order(1 "Country data" 2 "Model") rows(1)) graphregion(color(white) margin(l+4 r+4 b+3)) title("Sector wage ratio") name(g1, replace)
graph export fig1_wages_demo.png, width(1800) replace
use "`raw'", clear
keep if kind==2
drop if missing(x,y) | x<=0
append using `model'
twoway (scatter y x, msize(small) mcolor(gs8)) (line agshare model_x, sort lwidth(medthick) lcolor(black)), xscale(log range(.0078125 2)) xlabel(.0078125 "1/128" .03125 "1/32" .125 "1/8" .5 "1/2" 2 "2") xtitle("GDP per worker (US = 1)") ytitle("Employment in agriculture (%)") ylabel(0(20)100) legend(order(1 "Country data" 2 "Model") rows(1)) graphregion(color(white) margin(l+4 r+4 b+3)) title("Agricultural employment") name(g2, replace)
graph export fig2_employment_demo.png, width(1800) replace
use "`raw'", clear
keep if kind==3
drop if missing(x,y) | x<=0 | y<=0
append using `model'
twoway (scatter y x, msize(small) mcolor(gs8)) (line relative_pa model_x, sort lwidth(medthick) lcolor(black)), xscale(log range(.0078125 2)) yscale(log range(.5 4)) xlabel(.0078125 "1/128" .03125 "1/32" .125 "1/8" .5 "1/2" 2 "2") ylabel(.5 "0.5" 1 "1" 2 "2" 4 "4") xtitle("GDP per worker (US = 1)") ytitle("Relative agricultural price (US = 1)") legend(order(1 "Consumer-price data" 2 "Model") rows(1)) graphregion(color(white) margin(l+4 r+4 b+3)) title("Relative consumer prices") name(g3, replace)
graph export fig3_prices_demo.png, width(1800) replace
use "`raw'", clear
keep if kind==4
drop if missing(x,y)
regress y x
matrix b=e(b)
matrix V=e(V)
preserve
clear
set obs 1
gen double slope=b[1,1]
gen double se=sqrt(V[1,1])
gen double p=2*ttail(e(df_r),abs(slope/se))
gen long n=e(N)
save country_regression.dta, replace
restore
twoway (scatter y x, msize(small) mcolor(gs8)) (lfit y x, lwidth(medthick) lcolor(black)), xtitle("Employment in agriculture (%)") ytitle("Women among agricultural workers (%)") xlabel(0(20)100) ylabel(0(20)80) legend(order(1 "Country data" 2 "Linear fit") rows(1)) graphregion(color(white) margin(l+4 r+4 b+3)) title("Women in agricultural employment") name(g4, replace)
graph export fig4_women.png, width(1800) replace
use "`raw'", clear
keep if kind==5
drop if missing(x,y) | x<=0 | y<=0
append using `model'
twoway (scatter y x, msize(small) mcolor(gs8)) (line relative_pa model_x, sort lwidth(medthick) lcolor(black)), xscale(log range(.015625 1)) yscale(log range(.5 8)) xlabel(.015625 "1/64" .0625 "1/16" .25 "1/4" 1 "1") ylabel(.5 "0.5" 1 "1" 2 "2" 4 "4" 8 "8") xtitle("GDP per worker (US = 1)") ytitle("Relative agricultural price (US = 1)") legend(order(1 "Producer-price data" 2 "Model") rows(1)) graphregion(color(white) margin(l+4 r+4 b+3)) title("Relative producer prices") name(g5, replace)
graph export fig5_producer_prices_demo.png, width(1800) replace
display "__COUNTRY_OK__"
