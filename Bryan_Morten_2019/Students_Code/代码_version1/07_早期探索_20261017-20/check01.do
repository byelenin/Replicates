* ============================================================
* BM2019 美国侧复现 —— 第 0 步：环境与数据自检
* 目的：确认 Stata 批处理可用、CSV 能正确导入、变量长什么样
* 运行：StataMP-64.exe /e do check01.do
* ============================================================

clear all
set more off

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace"

* --- 1. 导入：o 和 d 必须是字符串，否则前导零会丢（'06' 变 6）---
import delimited "usa_od.csv", clear stringcols(1 2)

* --- 2. 数据长什么样 ---
describe

* --- 3. 行数 / 年份分布 ---
count
tab year

* --- 4. 关键变量分布 ---
summarize wage w age educ

* --- 5. 看前几行原始值 ---
list o d year wage w age in 1/8

* --- 6. o / d 的取值个数（应该是 51 和 51）---
preserve
contract o
count
restore

preserve
contract d
count
restore

* --- 7. 工资是否有缺失/负值 ---
count if missing(wage)
count if wage <= 0
count if missing(w)

display "=== CHECK01 DONE ==="