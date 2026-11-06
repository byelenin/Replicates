* 读取 ipumsi_00002.dta 的变量清单（不加载数据，只读文件头）
clear all
set more off
set linesize 250

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"

log using "desc00002_out.log", replace text

display "===== ipumsi_00002.dta 变量清单 ====="
describe using "D:\研一上\微观计量\ipumsi_00002.dta"

log close