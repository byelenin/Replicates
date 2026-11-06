* 查 IPUMS 给这两个样本的官方名称
clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"
log using "sample_lab_out.log", replace text

use sample year using "D:\研一上\微观计量\ipumsi_00002.dta", clear

display "===== SAMPLE 变量的值标签 ====="
label list SAMPLE

display "===== sample x year 交叉表 ====="
tab sample year

log close