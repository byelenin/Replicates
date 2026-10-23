/* 读取已完成的16个固定参数情景，生成汇报对照图。
   不重新估计参数，也不重新生成模型工人。
   将工作目录设为本文件所在的“修改后 V2”文件夹；输入默认读取上一级交付目录。 */
version 16.0
clear all
set more off
set varabbrev off
set scheme s2mono
graph set window fontface "Microsoft YaHei"
local base "`c(pwd)'"
local raw "`base'/model_ratios_demo.dta"
capture confirm file "`raw'"
if _rc local raw "`base'/../model_ratios_demo.dta"
capture confirm file "`raw'"
if _rc local raw "`base'/input_1.dta"
use "`raw'", clear
assert _N==16
isid scenario
assert abs(gap_ratio-gap_a/gap_n)<1e-10
gen byte group=cond(scenario<=3,1,cond(scenario<=9,2,cond(scenario<=13,3,4)))
format gap_a gap_gdp gap_n gap_ratio %9.3f
sort scenario
list scenario gap_a gap_gdp gap_n gap_ratio, noobs separator(0) abbreviate(16)
twoway (scatter scenario gap_ratio if group==1, msymbol(O) msize(medium) mcolor(black) mlabel(gap_ratio) mlabposition(3) mlabcolor(black) mlabsize(small)) (scatter scenario gap_ratio if group==2, msymbol(D) msize(medium) mcolor(black) mlabel(gap_ratio) mlabposition(3) mlabcolor(black) mlabsize(small)) (scatter scenario gap_ratio if group==3, msymbol(T) msize(medium) mcolor(black) mlabel(gap_ratio) mlabposition(3) mlabcolor(black) mlabsize(small)) (scatter scenario gap_ratio if group==4, msymbol(S) msize(medium) mcolor(black) mlabel(gap_ratio) mlabposition(3) mlabcolor(black) mlabsize(small)), yscale(reverse range(.5 16.5)) ylabel(1 "S01 基准（表2、3）" 2 "S02 中等收入（表4）" 3 "S03 同质（表2）" 4 "S04 相关性τ=0（表5）" 5 "S05 相关性τ=0.20（表5）" 6 "S06 相关性τ=0.30（表5）" 7 "S07 相关性τ=0.40（表5）" 8 "S08 相关性τ=0.50（表5）" 9 "S09 相关性τ=0.99（表5）" 10 "S10 降A有选择（补充）" 11 "S11 降A近似无选择（补充）" 12 "S12 降A、Aa有选择（表6）" 13 "S13 降A、Aa近似无选择（表6）" 14 "S14 资本土地有选择（表7）" 15 "S15 资本土地近似无选择（表7）" 16 "S16 近似无选择/无土地（表7）", angle(0) labsize(vsmall) nogrid) xlabel(0(2)10, format(%3.0f) labsize(small)) xscale(range(0 10.5)) xline(1, lpattern(shortdash) lcolor(gs10)) xtitle("农业差距 / 非农业差距", size(small)) ytitle("") title("16个固定参数情景的部门差距比", size(small)) subtitle("情景编号与原PDF表号对应", size(vsmall)) legend(order(1 "基准及中等收入" 2 "相关性敏感性" 3 "替代与补充实验" 4 "资本土地扩展") rows(2) size(vsmall)) note("虚线为差距比=1。各实验使用相应固定参数。" "跨组比较不是单因素效应；完整定义见情景对应表。", size(vsmall)) graphregion(color(white) margin(l+2 r+5)) xsize(10) ysize(10) name(scenario_map, replace)
graph export 情景1至16部门差距比_演示.png, width(2100) replace
/* 原PDF已发表值按对应实验并列，不用舍入后的农业、非农列重新计算。
   表5的Spearman与本套Kendall不同，情景10/11无独立表行，不硬配数值。 */
preserve
keep if inlist(scenario,1,2,3,12,13,14,15,16)
sort scenario
gen byte ordinal=_n
/* 两版数值接近时上下略错开，只调整画图位置，不改差距比。 */
gen double paper_y=ordinal-.20
gen double stata_y=ordinal+.20
gen double paper_ratio=cond(scenario==1,2.3,cond(scenario==2,1.3,cond(scenario==3,1,cond(scenario==12,9.9,cond(scenario==13,3.4,cond(scenario==14,3.9,cond(scenario==15,2.1,1.1)))))))
format paper_ratio %4.1f
twoway (scatter paper_y paper_ratio, msymbol(Oh) msize(medium) mcolor(gs5) mlabel(paper_ratio) mlabposition(3) mlabsize(small) mlabcolor(gs5)) (scatter stata_y gap_ratio, msymbol(D) msize(medium) mcolor(black) mlabel(gap_ratio) mlabposition(3) mlabsize(small) mlabcolor(black)), yscale(reverse range(.3 8.7)) ylabel(1 "S01 表2基准" 2 "S02 表4中等收入" 3 "S03 表2同质" 4 "S12 表6有选择" 5 "S13 表6近似无选择" 6 "S14 表7有选择" 7 "S15 表7近似无选择" 8 "S16 表7近似无选择/无土地", angle(0) labsize(vsmall) nogrid) xlabel(0(2)10, format(%3.0f) labsize(small)) xscale(range(0 11)) xline(1, lpattern(shortdash) lcolor(gs10)) xtitle("农业差距 / 非农业差距", size(small)) ytitle("") title("主要实验：论文与Stata的部门差距比", size(small)) subtitle("对应实验并列；版本及固定参数不同", size(vsmall)) legend(order(1 "原论文报告值" 2 "本套Stata值") rows(1) size(small)) note("表5系数类型不同，情景10、11无独立表行，未作数值硬配。" "同质与近似无选择的设置区别见正文。", size(vsmall)) graphregion(color(white) margin(l+3 r+5)) xsize(10) ysize(7) name(paper_comparison, replace)
graph export 论文与Stata主要实验对照_演示.png, width(2100) replace
restore
display "情景对照图生成完成"
display "__SCENARIO_GRAPH_OK__"
