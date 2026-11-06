* ============================================================
* 县级编码对齐诊断：三个 regency 变量到底是什么关系
* geo2_id        = 360 + 省(3) + 县(3)   例 360011002
* geo2_id1995    =       省(2) + 县(3)   例 11002
* id1995a_bplreg =       省(2) + 县(2)?  例 1101  （待验证）
* ============================================================

clear all
set more off
set linesize 200

cd "C:\Users\任娜\Documents\deepseek-harness\default-workspace\bm2019_replication\stata"

log using "check_codes_out.log", replace text

use year perwt geo2_id geo2_id1995 id1995a_bplreg relate sex incwage ///
    using "D:\研一上\微观计量\ipumsi_00002.dta", clear

keep if year == 1995
count

* ---------- A. geo2_id 与 geo2_id1995 的关系 ----------
display _n "===== A. geo2_id 减 360000000 后 是否等于 geo2_id1995 ====="

gen long d95 = geo2_id - 360000000
count if d95 != geo2_id1995
display "  不相等 的观测数 = " r(N)
count
display "  总观测数     = " r(N)

display _n "  抽查前 15 个不同的取值组合："
preserve
    keep geo2_id geo2_id1995
    duplicates drop
    sort geo2_id
    list geo2_id geo2_id1995 in 1/15, noobs
restore


* ---------- B. id1995a_bplreg 与 geo2_id1995 的对照 ----------
display _n "===== B. id1995a_bplreg 与 geo2_id1995 并排看 ====="

preserve
    keep id1995a_bplreg geo2_id1995
    duplicates drop
    sort id1995a_bplreg
    count
    display "  不同的 (bplreg, geo2_id1995) 组合数 = " r(N)
    display _n "  前 30 个组合："
    list id1995a_bplreg geo2_id1995 in 1/30, noobs
restore


* ---------- C. 尝试把 4 位转成 5 位 ----------
display _n "===== C. 4位 -> 5位 转换尝试 ====="

gen long bpl5 = int(id1995a_bplreg/100)*1000 + mod(id1995a_bplreg,100)
label var bpl5 "id1995a_bplreg 按 省(2)+县(2) 转成 省(2)+县(3)"

count if bpl5 == geo2_id1995
display "  转换后 bpl5 == geo2_id1995 的观测数 = " r(N)
count
display "  总观测数 = " r(N)

display _n "  转换后仍不匹配的，抽查一下："
preserve
    keep id1995a_bplreg bpl5 geo2_id1995
    duplicates drop
    sort id1995a_bplreg
    list id1995a_bplreg bpl5 geo2_id1995 in 1/30, noobs
restore


* ---------- D. 最要紧的问题：有没有「原地不动」的人 ----------
display _n "===== D. 非迁移者的识别情况 ====="

* 用转换后的 bpl5 去配 geo2_id1995
count if bpl5 == geo2_id1995
display "  用 bpl5  --- 出生县 == 现居县 的人 = " r(N)

* 用原始 geo2_id1995 当出生地的代理，看对角线
* （先确认 id1995a_bplreg 的最前面几位是否就是省）
gen int prov_o = int(id1995a_bplreg/100)
gen int prov_d = int(geo2_id1995/1000)

display _n "  出生省 与 现居省 是否一致（这是能对上的）："
count if prov_o == prov_d
display "  同省 = " r(N)

display _n "  id1995a_bplreg 的省码取值范围："
summarize prov_o
display _n "  geo2_id1995 的省码取值范围："
summarize prov_d

display _n "===== 诊断完成 ====="

log close