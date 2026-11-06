* 测一下从 ipumsi_00002.dta 读 1995 要多久
clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"
log using "timing_out.log", replace text

timer clear

timer on 1
use year perwt hhwt geo1_id bplid relate sex age incwage geo2_id geo2_id1995 id1995a_bplreg ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear
timer off 1

timer on 2
keep if year == 1995
timer off 2

count
describe, short

timer list

log close