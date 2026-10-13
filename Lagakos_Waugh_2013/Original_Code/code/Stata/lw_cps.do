/*
* lw_cps.do
* Compute wage moments for paper by Lagakos and Waugh AER 2012
* "Selection, Agriculture and Cross-Country Productivity Differences" 
* Uses CPS micro data downloaded from CEPR, available here:
* http://ceprdata.org/cps-uniform-data-extracts/march-cps-supplement/
* David Lagakos
* July 2012
*/

clear all
set more off
set mem 1000m


**************************************************
* load and format the CEPR CPS data for each year 
**************************************************

**** each user must change directory here (but not elsewhere)
cd /Users/dlagakos/Desktop/David/Projects/Specialization/CPS/CEPR/

local years 2010 2009 2008 2007 2006 2005 2004 2003 2002 2001 2000 1999 1998 1997 1996 

foreach year of local years {
	use cepr_march_`year'.dta,replace
	
	** Create agriculture worker dummy -- 2003 industry codes
	gen agworker=.
	replace agworker=1 if indly2d_03==1 & year>=2003
	replace agworker=0 if indly2d_03~=1 & year>=2003
	
	** Create agriculture worker dummy -- 1983 industry codes
	replace agworker=1 if indly2d_83==1 & year<2003
	replace agworker=0 if indly2d_83~=1 & year<2003
	
	** Create hours, labor income and wage data
	gen hrs = uhours*weeks
	gen inc = incp_wag + 0.46*incp_sefrm + 0.66*incp_senf
	drop if hrs==0 | hrs==. | inc==0 | inc==. 
	gen wage = inc/hrs
	
	** drop if lower than federal minimum wage
	drop if wage<4.75 & year==1996
	drop if wage<5.15 & year==1997
	drop if wage<5.15 & year==1998
	drop if wage<5.15 & year==1999
	drop if wage<5.15 & year==2000
	drop if wage<5.15 & year==2001
	drop if wage<5.15 & year==2002
	drop if wage<5.15 & year==2003
	drop if wage<5.15 & year==2004
	drop if wage<5.15 & year==2005
	drop if wage<5.15 & year==2006
	drop if wage<5.85 & year==2007
	drop if wage<6.55 & year==2008
	drop if wage<7.25 & year==2009
	drop if wage<7.25 & year==2010
			
	** adjust for inflation
	replace wage = wage*(218.1/156.9) if year==1996								
	replace wage = wage*(218.1/160.5) if year==1997
	replace wage = wage*(218.1/163.0) if year==1998
	replace wage = wage*(218.1/166.6) if year==1999
	replace wage = wage*(218.1/172.2) if year==2000
	replace wage = wage*(218.1/177.1) if year==2001
	replace wage = wage*(218.1/179.9) if year==2002
	replace wage = wage*(218.1/184.0) if year==2003
	replace wage = wage*(218.1/188.9) if year==2004
	replace wage = wage*(218.1/195.3) if year==2005
	replace wage = wage*(218.1/201.6) if year==2006
	replace wage = wage*(218.1/207.3) if year==2007
	replace wage = wage*(218.1/215.3) if year==2008
	replace wage = wage*(218.1/214.5) if year==2009
	replace wage = wage*(218.1/218.1) if year==2010
	
	** Generate "unique" person identifier for matching across years
	** note: perno is "lineno" in original cps naming
	gen id2= hhid+string(famno)+string(perno)
	
	** Add on year names
	rename female female`year'
	rename wbho wbho`year'
	rename age age`year'
	rename state state`year'
	rename agworker agworker`year'
	rename wgt wgt`year'
	rename hrs hrs`year'
	rename inc inc`year'
	rename wage wage`year'
	rename incp_wag incp_wag`year'
	rename incp_sefrm incp_sefrm`year'
	rename incp_senf incp_senf`year'
	rename mig_sh mig_sh_`year'
	rename educ educ`year'
	
	** Clean, save		
	keep id2 female`year' wbho`year' age`year' state`year' agworker`year' mig_sh_`year' hrs`year' inc`year' wage`year' wgt`year' incp_wag`year' incp_sefrm`year' incp_senf`year' educ`year'
	order id2
	sort id2 
	save CPS_`year'.dta,replace
}




****************************************************************
* Merge consecutive years, match workers over time
****************************************************************

local years 2010 2009 2008 2007 2006 2005 2004 2003 2002 2001 2000 1999 1998 1997 

foreach year of local years {

	*** define local for previous year
	local year_1 = `year'-1
	
	*** load this year's data
	use CPS_`year'.dta,replace
	
	*** merge with previous year's data 
	merge id2 using CPS_`year_1.dta'
	
	*** drop if person only available in one year
	keep if _merge==3
	drop _merge
	
	*** drop "false positives"
	*** drop if sex changed, age was off by <-1 or >3 years, race changed, or household reported they had moved
	drop if female`year' ~= female`year_1'
	drop if (age`year' -age`year_1')>1
	drop if (age`year_1'-age`year')>0
	drop if wbho`year'~= wbho`year_1' 
	drop if mig_sh_`year'==0

	drop if (age`year' -age`year_1')>3
	drop if (age`year_1'-age`year')>-1
	drop if wbho`year'~= wbho`year_1' 
	drop if mig_sh_`year'==0
	
	** record industry move from `year_1' to `year'
	** 1 means ag,ag
	** 2 means nonag,nonag
	** 3 means ag,nonag
	** 4 means nonag, ag
	gen info=.
	replace info=1 if (agworker`year_1'==1 & agworker`year'==1)
	replace info=2 if (agworker`year_1'==0 & agworker`year'==0)
	replace info=3 if (agworker`year_1'==1 & agworker`year'==0)
	replace info=4 if (agworker`year_1'==0 & agworker`year'==1)
	
	drop if info==3
	drop if info==4

	* generate new id, specific to this time period
	gen str25 id=id2+"`year'"

	*replace with _t and _t-1 lables
	rename agworker`year' agworker_curr
	rename agworker`year_1' agworker_past
	rename wage`year' wage_curr
	rename wage`year_1' wage_past
	rename female`year' female_curr
	rename female`year_1' female_past
	rename wbho`year' wbho_curr
	rename wbho`year_1' wbho_past
	rename age`year' age_curr
	rename age`year_1' age_past
	rename wgt`year' wgt_curr
	rename wgt`year_1' wgt_past
	rename educ`year' educ_curr
	rename educ`year_1' educ_past
	keep id agworker_curr agworker_past wage_curr wage_past female_curr female_past wbho_curr wbho_past age_curr age_past wgt_curr wgt_past educ_curr educ_past
	order id agworker_curr agworker_past wage_curr wage_past female_curr female_past wbho_curr wbho_past age_curr age_past wgt_curr wgt_past educ_curr educ_past
	gen year=`year'
	save CPS_cleaned`year'_merged.dta,replace	
}


****************************************************************
* Merge years together again
****************************************************************

local years 2009 2008 2007 2006 2005 2004 2003 2002 2001 2000 1999 1998 1997 

use CPS_cleaned2010_merged.dta,replace
foreach year of local years {
	append using CPS_cleaned`year'_merged.dta
}

** Drop multiple records of same id (<1%), which are highly likely to 
** be coding error (see Madrian & Lefgren 2000)
egen id_count=count(year),by(id)
drop if id_count>1
drop id_count

save CPS_all_merged.dta,replace


****************************************************************
* Compute moments
****************************************************************

*** Compute covariances
use CPS_all_merged.dta,replace
gen double id2=_n
keep id id2 agworker_curr wage_curr female_curr wbho_curr age_curr wgt_curr educ_curr year
rename agworker_curr agworker
rename wage_curr wage
rename female_curr female
rename age_curr age
rename wbho_curr wbho
rename wgt_curr wgt
rename educ_curr educ
save CPS_curr.dta,replace
use CPS_all_merged.dta,replace
gen double id2=_n
keep id id2 agworker_past wage_past female_past wbho_past age_past wgt_past educ_past year
rename agworker_past agworker
rename wage_past wage
rename female_past female
rename age_past age
rename wbho_past wbho
rename wgt_past wgt
rename educ_past educ
replace year=year-1
save CPS_past.dta,replace
append using CPS_curr.dta

** Moments of wage and ln wage distributions
gen ln_wage = ln(wage)
sum ln_wage [aw=wgt] if agworker==1,detail
sum ln_wage [aw=wgt] if agworker==0,detail
sum wage [aw=wgt] if agworker==1,detail
sum wage [aw=wgt] if agworker==0,detail

** Covariances of ln y_t by sector
egen past_yr=min(year),by(id)
egen curr_yr=max(year),by(id)
gen ln_wage_curr=ln_wage if year==curr_yr
gen ln_wage_past=ln_wage if year==past_yr
collapse (min) ln_wage_curr ln_wage_past wgt agworker, by(id)
corr ln_wage_curr ln_wage_past if agworker==1 [aw=wgt],cov
corr ln_wage_curr ln_wage_past if agworker==0 [aw=wgt],cov


exit

