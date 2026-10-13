/* CPS工资统计，依据作者Data/lw_cps.do逐步改写。
   输入CPS_input.dta仅抽取原始字段，未改写观测值；2001s补充样本不重复加入。
   与作者实际程序一致：最低工资过滤、CPI折算、相邻年匹配、年龄增加恰好1岁、
   剔除变换部门者、剔除重复匹配id。输出加权工资矩及匹配样本。
   开始前用Stata菜单将工作目录设为此文件所在文件夹。 */
version 16.0
clear all
set more off
set varabbrev off
local base "`c(pwd)'"
local raw "`base'/CPS_input.dta"
capture confirm file "`raw'"
if _rc local raw "`base'/input_1.dta"
use "`raw'", clear
assert inrange(year,1996,2010)
assert _N==2685662
tempfile rawall stacked
save `rawall'
local cpis "156.9 160.5 163.0 166.6 172.2 177.1 179.9 184.0 188.9 195.3 201.6 207.3 215.3 214.5 218.1"
tempname F
postfile `F' int year long raw_n long wage_n using cps_flow.dta, replace
forvalues yr=1996/2010 {
    use "`rawall'" if year==`yr', clear
    local nraw=_N
    gen byte agworker=cond(year>=2003,indly2d_03==1,indly2d_83==1)
    drop if missing(uhours,weeks,incp_wag,incp_sefrm,incp_senf)
    gen double hrs=uhours*weeks
    gen double inc=incp_wag+.46*incp_sefrm+.66*incp_senf
    drop if hrs==0 | missing(hrs) | inc==0 | missing(inc)
    gen double wage=inc/hrs
    local minimum=cond(`yr'==1996,4.75,cond(`yr'<=2006,5.15,cond(`yr'==2007,5.85,cond(`yr'==2008,6.55,7.25))))
    drop if wage<`minimum'
    local index=`yr'-1995
    local cpi: word `index' of `cpis'
    replace wage=wage*(218.1/`cpi')
    gen str40 id2=hhid+string(famno)+string(perno)
    keep id2 female wbho age agworker mig_sh wage wgt educ
    foreach v in female wbho age agworker mig_sh wage wgt educ {
        rename `v' `v'`yr'
    }
    sort id2
    tempfile y`yr'
    save `y`yr''
    post `F' (`yr') (`nraw') (_N)
}
postclose `F'
forvalues yr=1997/2010 {
    local prev=`yr'-1
    use `y`yr'', clear
    /* 保留原作者旧merge的多对多顺序匹配语义，随后原样剔除重复id。
       不能换成joinby，因为joinby生成笛卡尔组合，改变样本。 */
    merge m:m id2 using `y`prev'', keep(match) nogen
    keep if female`yr'==female`prev' & wbho`yr'==wbho`prev'
    keep if age`yr'-age`prev'==1 & mig_sh`yr'!=0
    keep if agworker`yr'==agworker`prev'
    gen str45 id=id2+string(`yr')
    foreach v in agworker wage female wbho age wgt educ {
        rename `v'`yr' `v'_curr
        rename `v'`prev' `v'_past
    }
    keep id *_curr *_past
    gen int year=`yr'
    if `yr'>1997 append using `stacked'
    save `stacked', replace
}
bysort id: gen long id_count=_N
drop if id_count>1
drop id_count
assert wage_curr>0 & wage_past>0 & wgt_curr>=0 & wgt_past>=0
isid id
sort year id
compress
save cps_matched.dta, replace
gen double ln_curr=ln(wage_curr)
gen double ln_past=ln(wage_past)
gen double wgt_min=min(wgt_curr,wgt_past)
tempname M
postfile `M' byte sector long pairs double covariance double sd_persistent using cps_covariance.dta, replace
forvalues a=0/1 {
    quietly count if agworker_curr==`a' & wgt_min>0
    local nn=r(N)
    quietly correlate ln_curr ln_past if agworker_curr==`a' [aw=wgt_min], covariance
    matrix C=r(C)
    post `M' (`a') (`nn') (C[1,2]) (sqrt(C[1,2]))
}
postclose `M'
drop ln_* wgt_min
rename (*_curr) (*1)
rename (*_past) (*0)
reshape long agworker wage female wbho age wgt educ, i(id) j(time)
gen double ln_wage=ln(wage)
tempname S
postfile `S' byte sector long n double mean_wage double sd_lnw using cps_moments.dta, replace
forvalues a=0/1 {
    quietly summarize wage if agworker==`a' [aw=wgt]
    local n=r(N)
    local m=r(mean)
    quietly summarize ln_wage if agworker==`a' [aw=wgt]
    post `S' (`a') (`n') (`m') (r(sd))
}
postclose `S'
use cps_moments.dta, clear
list, noobs
use cps_covariance.dta, clear
list, noobs
use cps_flow.dta, clear
list, noobs
display "__CPS_OK__"
