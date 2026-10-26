*==============================================================
* 检验：出生地(县级) 和 现居地(个人级) 两个口径是否打架
*   以及这种不一致对 Table 1「同类内迁移」的影响
*==============================================================
clear all
set more off
capture log close
log using "defn_out.log", replace text

cd "D:\研一上\微观计量\复现"

use year geo2_id1995 id1995a_bplreg urban perwt using "D:\研一上\微观计量\ipumsi_00002.dta", clear
keep if year == 1995

gen long bcode   = id1995a_bplreg
gen long geo_key = floor(geo2_id1995/1000)*100 + mod(geo2_id1995,100)
gen byte moved   = (geo_key != bcode) if !missing(id1995a_bplreg)

* ---- 出生地【县】级标签 ----
merge m:1 bcode using "tab1_lookup.dta", keep(master match) nogen
rename o_rural o_rural_birth

* ---- 目的地【县】级标签（把 geo_key 临时命名为 bcode 去查同一张表）----
drop bcode
rename geo_key bcode
merge m:1 bcode using "tab1_lookup.dta", keep(master match) nogen
rename o_rural d_rural_reg
rename bcode geo_key
rename o_rural_birth o_rural

* ---- 目的地【个人/村】级标签：论文原版口径 ----
gen byte d_rural = (urban == 1)

* ================= 检验 1 =================
display _n "==== 检验1  非迁移者：出生地【县】级  vs  现居地【个人】级（论文口径）===="
tab o_rural d_rural if moved == 0, row

display _n "==== 检验1b 非迁移者：出生地【县】级  vs  现居地【县】级（口径统一）===="
tab o_rural d_rural_reg if moved == 0, row

* ================= 检验 2 =================
display _n "==== 检验2  非迁移者里两种口径打架的加权比例 ===="
gen byte disagree = (o_rural != d_rural) if moved == 0
tab disagree [aw = perwt]

* ================= 检验 3 =================
display _n "==== 检验3  迁移者的「同类内」—— 论文原版口径 ===="
tab o_rural d_rural if moved == 1 [aw = perwt], row

display _n "==== 检验3b 迁移者的「同类内」—— 统一为县级口径 ===="
tab o_rural d_rural_reg if moved == 1 [aw = perwt], row

log close