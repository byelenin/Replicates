/*******************************************************************************

Do-file "4. Creation of KLPS replication data.do"

Replication code for 
Joan Hamory, Marieke Kleemans, Nicholas Y. Li, and Edward Miguel
Reevaluating Agricultural Productivity Gaps with Longitudinal Microdata
Created Aug 2020 using Stata version 14.2

This do-file uses the data file "KLPS.dta" provided in the replication
packages and creates 4 datasets: 
- Main Analysis_KLPS.dta
- Meals_Analysis_KLPS.dta
- Consumption_Analysis_KLPS.dta 
- Intergen_Analysis_KLPS.dta

With these 4 datasets all figures and tables using KLPS data can be 
reproduced using the do-file "5. Replication analysis KLPS.do"

Please contact Marieke Kleemans at kleemans@illinois.edu for questions

*******************************************************************************/


use "KLPS.dta", clear
 
preserve
keep if sample_intergen == 1

* Gen squared variables
gen parent_educ_sq = parent_educ^2
gen parent_age_atchildbirth_sq = parent_age_atchildbirth^2
gen parent_raven_sq = parent_raven^2
gen child_age_sq = child_age^2

save "Intergen_Analysis_KLPS.dta", replace
restore

drop if sample_intergen == 1

*** Generate variables (ln, real, squared, norm, sector)

foreach var of varlist hour forhour inforhour forinc_h inforinc_h forinc inforinc ///
inc_h inc inc_notdecmaker inc_h_notdecmaker hour_notdecmaker ///
inforaginc inforaginc_h inforaghour hour_allhours ///
inc_allhours forinforinc inc_h_allhours forinforinc_h forinforhour  {
gen ln`var' = ln(`var')
}
*
gen age_sq = age * age
gen educyr_sq = educyr * educyr
gen logmeals = ln(meals)
gen lncons_tot = log(cons_tot)

gen hour_sq = hour * hour
gen lnforhour_sq = lnforhour * lnforhour
gen lninforhour_sq = lninforhour * lninforhour
gen lnhourSA_sq = lninforaghour * lninforaghour
gen lnhour_sq = lnhour * lnhour

gen inc_h_real = inc_h
replace inc_h_real = inc_h/1.081 if urban == 1
gen lninc_h_real = ln(inc_h_real)
lab var lninc_h_real "Log real wage"
order urban inc_h inc_h_real lninc_h lninc_h_real

gen inc_real = inc
replace inc_real = inc/1.081 if urban == 1
gen lninc_real = ln(inc_real)
lab var lninc_real "Log real earnings"
order urban inc inc_real lninc lninc_real

gen forinc_h_real = forinc_h
replace forinc_h_real = forinc_h/1.081 if urban == 1
gen lnforinc_h_real = ln(forinc_h_real)
lab var lnforinc_h_real "Log real wage"
order urban forinc_h forinc_h_real lnforinc_h lnforinc_h_real

gen forinc_real = forinc
replace forinc_real = forinc/1.081 if urban == 1
gen lnforinc_real = ln(forinc_real)
lab var lnforinc_real "Log real earnings"
order urban forinc forinc_real lnforinc lnforinc_real

gen inforinc_h_real = inforinc_h
replace inforinc_h_real = inforinc_h/1.081 if urban == 1
gen lninforinc_h_real = ln(inforinc_h_real)
lab var lninforinc_h_real "Log real wage"
order urban inforinc_h inforinc_h_real lninforinc_h lninforinc_h_real

gen inforinc_real = inforinc
replace inforinc_real = inforinc/1.081 if urban == 1
gen lninforinc_real = ln(inforinc_real)
lab var lninforinc_real "Log real earnings"
order urban inforinc inforinc_real lninforinc lninforinc_real

egen educyr_norm = std(educyr)
gen educyr_norm_sq = educyr_norm * educyr_norm
gen ravens_sq = ravens * ravens

gen nonag = .
replace nonag = 1 if nonaghour > aghour_decmaker & aghour_decmaker ~= . & nonaghour ~= .
replace nonag = 0 if nonaghour < aghour_decmaker & aghour_decmaker ~= . & nonaghour ~= .
replace nonag = 1 if nonaghour > 0 & nonaghour ~= . & aghour_decmaker == .
replace nonag = 0 if aghour_decmaker > 0 & nonaghour == . & aghour_decmaker ~= .
replace nonag = 0 if (abs(aghour_decmaker - nonaghour) < 10^-2) & aghour_decmaker ~= . & nonaghour ~= .
replace nonag = . if nonaghour == 0 & aghour_decmaker == 0
replace nonag = . if nonaghour == 0 & aghour_decmaker == .
replace nonag = . if nonaghour == . & aghour_decmaker == 0
lab var nonag "Non-agricultural employment"

gen nonagonly = .															
replace nonagonly = 1 if nonaghour > 0 & nonaghour ~= .
replace nonagonly = 0 if aghour_decmaker > 0 & aghour_decmaker ~= .
lab var nonagonly "Only non-agricultural employment"

gen nonagany = .																
replace nonagany = 0 if aghour_decmaker > 0 & aghour_decmaker ~= .
replace nonagany = 1 if nonaghour > 0 & nonaghour ~= .
lab var nonagany "Any non-agricultural employment"

*** Add labels to variables
lab var lnhour "Log hours"
lab var lnhour_sq "Log hours squared"
lab var educyr_sq "Years of education squared"
lab var ravens "Normalized Ravens"
lab var ravens_sq "Normalized Ravens squared"
lab var inforinc_h "Wages"
lab var logmeals "Log(Meals)"

save "Consumption_Analysis_KLPS.dta", replace

keep if !missing(urban)
keep if !missing(female)
keep if !missing(age)
keep if !missing(educyr)
keep if !missing(nonag)

********************************************************************************
*** Delete outliers monetary variables
local outlier "1"
local top = 100 - `outlier'
foreach var in inc inc_h forinc forinc_h inforinc inforinc_h inc_h_real inc_real forinc_h_real forinc_real inforinc_h_real inforinc_real {
gen `var'_raw = `var'
replace `var' = . if `var' <= 0			// Remove zero and negative monetary values because when taking logs these are not included either
forvalues yrmth = 456/657 {		// Min and max value of time variable
	display `yrmth'
	_pctile `var' if yrmth == `yrmth', p(`outlier' `top')
	replace `var' = . if (`var' < r(r1) | `var' > r(r2)) & yrmth == `yrmth'
}
drop ln`var'				
gen ln`var' = ln(`var')
drop `var'_raw
}
********************************************************************************

save "Meals_Analysis_KLPS.dta", replace

*** Sample restrictions of earnings data
keep if !missing(lninc)
keep if !missing(lnhour)
keep if !missing(lninc_h)

xtset pupid yrmth
sort pupid yrmth

sort pupid yrmth

*** Create urban_mover
by pupid: egen urban_ever = max(urban)
by pupid: egen rural_ever = min(urban)
replace rural_ever = 1 - rural_ever
gen U_mover = .
replace U_mover = 1 if urban_ever == 1 & rural_ever == 1
order pupid year urban urban_ever rural_ever U_mover

*** Create nonag_mover
by pupid: egen nonag_ever = max(nonag)
by pupid: egen ag_ever = min(nonag)
replace ag_ever = 1 - ag_ever
gen NA_mover = .
replace NA_mover = 1 if nonag_ever == 1 & ag_ever == 1
order pupid year nonag nonag_ever ag_ever NA_mover
drop *ag_ever

*** Create nonagonly_mover
by pupid: egen nonag_ever = max(nonagonly)
by pupid: egen ag_ever = min(nonagonly)
replace ag_ever = 1 - ag_ever
gen NAonly_mover = .
replace NAonly_mover = 1 if nonag_ever == 1 & ag_ever == 1
order pupid year nonagonly nonag_ever ag_ever NAonly_mover
drop *ag_ever

*** Create nonagonly_mover
by pupid: egen nonag_ever = max(nonagany)
by pupid: egen ag_ever = min(nonagany)
replace ag_ever = 1 - ag_ever
gen NAany_mover = .
replace NAany_mover = 1 if nonag_ever == 1 & ag_ever == 1
order pupid year nonagany nonag_ever ag_ever NAany_mover
drop *ag_ever

save "Main_Analysis_KLPS.dta", replace
