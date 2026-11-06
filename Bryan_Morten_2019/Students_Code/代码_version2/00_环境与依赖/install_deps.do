*==============================================================
* 安装 reghdfe 缺失的依赖
*==============================================================
clear all
set more off
capture log close
cd "D:\研一上\微观计量\复现"
log using "install_out.log", replace text

display _n "===== 第 1 步：装 require（reghdfe v6 的依赖管理器）====="
capture noisily ssc install require, replace
display "  require 返回码 = " _rc

display _n "===== 第 2 步：装 gtools（ftools v2.5 依赖它）====="
capture noisily ssc install gtools, replace
display "  gtools 返回码 = " _rc

display _n "===== 第 3 步：装 moremata（fcollapse 分位数需要）====="
capture noisily ssc install moremata, replace
display "  moremata 返回码 = " _rc

display _n "===== 第 4 步：验证命令都在 ====="
capture noisily which require
display "  require  返回码 = " _rc
capture noisily which gtools
display "  gtools   返回码 = " _rc
capture noisily which gegen
display "  gegen    返回码 = " _rc

display _n "===== 第 5 步：实测 reghdfe 单维 absorb ====="
sysuse auto, clear
capture noisily reghdfe price weight, absorb(foreign)
display "  单维 absorb 返回码 = " _rc

display _n "===== 第 6 步：实测【双向聚类】====="
capture noisily reghdfe price weight, absorb(foreign rep78) cluster(foreign rep78)
display "  双向聚类 返回码 = " _rc

display _n "===== 完成 ====="
log close