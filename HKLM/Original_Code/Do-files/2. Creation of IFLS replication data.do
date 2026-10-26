/*******************************************************************************

Do-file "2. Creation of IFLS replication data.do"

Replication code for 
Joan Hamory, Marieke Kleemans, Nicholas Y. Li, and Edward Miguel
Reevaluating Agricultural Productivity Gaps with Longitudinal Microdata
Created Aug 2020 using Stata version 14.2

This do-file uses the data file "IFLS.dta" provided in the replication
packages and creates 3 datasets: 
- Main Analysis_IFLS.dta
- Consumption_Analysis_IFLS.dta 
- Intergen_Analysis_IFLS.dta

With these 3 datasets all figures and tables using IFLS data can be 
reproduced using the do-file "3. Replication analysis IFLS.do"

Please contact Marieke Kleemans at kleemans@illinois.edu for questions

*******************************************************************************/


use "IFLS.dta", clear

* Year Indicator variables
forvalues x =1988(1)2015 {
gen year`x' = (year ==`x') 
lab var year`x' "Indicator for the year `x'"
}

*** Intergenerational Analysis
tab sect1 sect2, m

gen nonag = .
replace nonag = 0 if sect1 == 1
replace nonag = 1 if sect1 > 1 & sect1 ~= .
lab var nonag "Non-agricultural employment"

replace nonag = 0 if sect2 == 1 & nonag == .
replace nonag = 1 if sect2 > 1 & sect2 ~= . & nonag == .

gen nonagonly = .																
replace nonagonly = 1 if sect1 > 1  & sect1 ~= .
replace nonagonly = 1 if sect2 > 1  & sect2 ~= .
replace nonagonly = 0 if sect1 == 1
replace nonagonly = 0 if sect2 == 1
lab var nonagonly "Only non-agricultural employment"

gen nonagany = .																
replace nonagany = 0 if sect1 == 1
replace nonagany = 0 if sect2 == 1
replace nonagany = 1 if sect1 > 1  & sect1 ~= .
replace nonagany = 1 if sect2 > 1  & sect2 ~= .
lab var nonagany "Any non-agricultural employment"

sum nonag nonagonly nonagany
tab nonag nonagonly, m
tab nonag nonagany, m
tab nonagonly nonagany, m
*
gen lnhour = ln(hour)
gen lnhour_sq = lnhour * lnhour
gen lnhour_exp3 = lnhour * lnhour * lnhour
gen lnhour_exp4 = lnhour * lnhour * lnhour * lnhour
gen lnhour_exp5 = lnhour * lnhour * lnhour * lnhour * lnhour

sum lnhour lnhour_sq lnhour_exp3 lnhour_exp4 lnhour_exp5

gen lnforhour = ln(forhour)
gen lnforhour_sq = forhour * forhour

gen lninforhour = ln(inforhour)
gen lninforhour_sq = inforhour * inforhour
*
replace age = . if age > 100
drop if age < 16
egen age_norm = std(age)
gen age_norm_sq = age_norm * age_norm
*
egen educ_norm = std(educlv)
gen educ_norm_sq = educ_norm * educ_norm

gen lneducyr = ln(educyr)
gen lneducyr_sq = lneducyr * lneducyr

egen educyr_norm = std(educyr)
gen educyr_norm_sq = educyr_norm * educyr_norm

foreach var in ravens_mean {		
gen `var'_sq = `var' * `var'
}
sort pidlink year
rename ravens_mean ravens_norm
rename ravens_mean_sq ravens_norm_sq

gen male = 1 - female

gen age_sq = age * age

gen educyr_sq = educyr * educyr

*** Use as dependent variables: cons_tot cons_food cons_nfood
foreach var in cons_tot cons_food cons_nfood {									
replace `var' = `var' / hhsize													
}

foreach var in inc inc_h forinc forinc_h inforinc inforinc_h cons_tot cons_food cons_nfood {
gen `var'_real = `var'
replace `var'_real = `var' / 1.1005770736859937 if urban == 1
}

sort pidlink year

*** Label variables and label values
lab var male "Male"
lab var lnhour "Log hours"
lab var lnhour_sq "Log hours squared"
lab var lnhour_exp3 "Log hours cubed"
lab var lnhour_exp4 "Log hours quad"
lab var lnhour_exp5 "Log hours quint"
lab var educyr_sq "Years of education squared"
lab var lneducyr "Log years education"
lab var lneducyr_sq "Log years education squared"
lab var educyr_norm "Normalized years education"
lab var educyr_norm_sq "Normalized years education squared"
lab var ravens_norm "Normalized Ravens"
lab var ravens_norm_sq "Normalized Ravens squared"
lab var educ_norm "Normalized education"
lab var educ_norm_sq "Normalized education squared"
lab var age_sq "Age squared"
lab var age_norm "Normalized age"
lab var age_norm_sq "Normalized age squared"
label var lnforhour "Log formal hours worked"
label var lnforhour_sq "Log formal hours worked squared"
label var lninforhour "Log informal hours worked"
label var lninforhour_sq "Log informal hours worked squared"
label var inc_h_real "Real hourly income"
label var inc_real "Real income"
label var forinc_real "Real formal income"
label var forinc_h_real	"Real hourly formal income"
label var inforinc_real "Real informal income"
label var inforinc_h_real "Real hourly informal income"
lab var cons_tot_real "Real total consumption"
lab var cons_food_real "Real food consumption"
lab var cons_nfood_real "Real non-food consumption"
*
label define nonag 1 "Non-Agricultural" 0 "Agricultural"
label values nonag nonag

*** Order variables
order pidlink year wave hhsize age age_norm age_sq male female ///
urban_birth migr educlv educyr educyr_sq ravens ravens_norm ravens_norm_sq ///
nonag urban nonagonly nonagany inc inc_h forinc forinc_h inforinc inforinc_h inc_real ///
inc_h_real forinc_real forinc_h_real inforinc_real inforinc_h_real empl ///
hour forhour inforhour lnhour lnhour_sq lnhour_exp3 lnhour_exp4 lnhour_exp5 ///
lnforhour lnforhour_sq lninforhour lninforhour_sq cons_tot cons_food ///
cons_nfood cons_tot_real cons_food_real cons_nfood_real fath_pidlink ///
moth_pidlink jakarta surabaya bandung medan bekasi

save "Intergen_Analysis_IFLS.dta", replace


*** Consumption Analysis
keep if !missing(nonag)
keep if !missing(urban)
keep if !missing(female)
keep if !missing(age)
keep if !missing(educyr)
*
local outlier "1"
local top = 100 - `outlier'
foreach var in inc inc_h forinc forinc_h inforinc inforinc_h ///
inc_real inc_h_real forinc_real forinc_h_real inforinc_real inforinc_h_real {
gen `var'_raw = `var'
replace `var' = . if `var' <= 0		// Remove zero and negative monetary values because when taking logs these are not included either (never happens)
forvalues year =  1988 / 2015 {													// Min and max value of year variable
	display `year'
	_pctile `var' if year == `year', p(`outlier' `top')
	replace `var' = . if (`var' < r(r1) | `var' > r(r2)) & year == `year'
}
gen ln`var' = ln(`var')
drop `var'_raw
}
sum inc inc_h forinc forinc_h inforinc inforinc_h inc_real inc_h_real forinc_real forinc_h_real inforinc_real inforinc_h_real
*
sum cons_tot cons_food cons_nfood cons_tot_real cons_food_real cons_nfood_real 	// A handful of times 0 so delete these
sum cons_tot cons_food cons_nfood cons_tot_real cons_food_real cons_nfood_real pidlink year if wave == . // Sometimes happens, fine, leave as it (so don't delete outliers for those)
foreach var in cons_tot cons_food cons_nfood cons_tot_real cons_food_real cons_nfood_real {
gen `var'_raw = `var'
replace `var' = . if `var' <= 0		// Remove zero monetary values because when taking logs these are not included either (happens a few times)
	forvalues wave = 1/5 {		/* Delete outliers per wave (instead of per year as we do with income data). Note it happens occasionally that wave
	is missing while consumption data is available, fine leave those consumption values unchanged */
	display `wave'
	_pctile `var' if wave == `wave', p(`outlier' `top')
	replace `var' = . if (`var' < r(r1) | `var' > r(r2)) & wave == `wave'
}
gen ln`var' = ln(`var')
drop `var'_raw
}

drop lncons_tot lncons_food lncons_nfood			// This means that all consumption variables are now replaced with the real equivalents!
rename lncons_tot_real lncons_tot
rename lncons_food_real lncons_food
rename lncons_nfood_real lncons_nfood

* Label variables
lab var lninc "Log income"
lab var lninc_h "Log hourly income"
lab var lnforinc "Log formal income"
lab var lnforinc_h "Log hourly formla income"
lab var lninforinc "Log informal income"
lab var lninforinc_h "Log hourly informal income"
lab var lninc_real "Log real earnings"
lab var lninc_h_real "Log real wage"
lab var lnforinc_real "Log real earnings"
lab var lnforinc_h_real "Log real wage"
lab var lninforinc_real "Log real earnings"
lab var lninforinc_h_real "Log real wage"
lab var lncons_tot "Log total consumption"
lab var lncons_food "Log food consumption"
lab var lncons_nfood "Log non-food consumption"

*** Order variables
order pidlink year wave hhsize age age_norm age_sq male female ///
urban_birth migr educlv educyr educyr_sq ravens ravens_norm ravens_norm_sq ///
nonag urban nonagonly nonagany inc inc_h forinc forinc_h inforinc inforinc_h ///
inc_real inc_h_real forinc_real forinc_h_real inforinc_real inforinc_h_real ///
lninc lninc_h lnforinc lnforinc_h lninforinc lninforinc_h lninc_real ///
lninc_h_real lnforinc_real lnforinc_h_real lninforinc_real lninforinc_h_real ///
empl hour forhour inforhour lnhour lnhour_sq lnhour_exp3 lnhour_exp4 ///
lnhour_exp5 lnforhour lnforhour_sq lninforhour lninforhour_sq cons_tot ///
cons_food cons_nfood cons_tot_real cons_food_real cons_nfood_real lncons_tot ///
lncons_food lncons_nfood fath_pidlink moth_pidlink jakarta surabaya

save "Consumption_Analysis_IFLS.dta", replace


*** Main Analysis
keep if !missing(lninc)
keep if !missing(lnhour)
keep if !missing(lninc_h)

xtset pidlink year
sort pidlink year
*
tab migr, m

gen migrU = migr
replace migrU = 0 if urban == 0 & migrU ~= .
lab var migrU "Dummy for being an urban migrant"
tab migrU, m

by pidlink: egen migr_yeartot_88 = total(migr) // Total this is by pidlink  
replace migr_yeartot_88 = . if migr == .
lab var migr_yeartot_88 "Total number of years as a migrant since 1988"
by pidlink: egen migrU_yeartot_88 = total(migrU)		// Total this is by pidlink  
replace migrU_yeartot_88 = . if migrU == .
lab var migrU_yeartot_88 "Total number of years as an urban migrant since 1988"
*
gen migr_ever = .
replace migr_ever = 1 if migr_yeartot_88 >= 1
replace migr_ever = 0 if migr_yeartot_88 == 0
lab var migr_ever "Ever migrated away from home"
tab migr_ever, m
gen migrU_ever = .
replace migrU_ever = 1 if migrU_yeartot_88 >= 1
replace migrU_ever = 0 if migrU_yeartot_88 == 0
lab var migrU_ever "Ever migrated to an urban area"
tab migrU_ever, m
*
by pidlink: egen urban_ever = max(urban)
by pidlink: egen rural_ever = min(urban)
replace rural_ever = 1 - rural_ever
gen U_mover = .
replace U_mover = 1 if urban_ever == 1 & rural_ever == 1
order pidlink year urban urban_ever rural_ever U_mover
*
by pidlink: egen nonag_ever = max(nonag)
by pidlink: egen ag_ever = min(nonag)
replace ag_ever = 1 - ag_ever
gen NA_mover = .
replace NA_mover = 1 if nonag_ever == 1 & ag_ever == 1
order pidlink year nonag nonag_ever ag_ever NA_mover
drop *ag_ever
*
by pidlink: egen nonag_ever = max(nonagonly)
by pidlink: egen ag_ever = min(nonagonly)
replace ag_ever = 1 - ag_ever
gen NAonly_mover = .
replace NAonly_mover = 1 if nonag_ever == 1 & ag_ever == 1
order pidlink year nonagonly nonag_ever ag_ever NAonly_mover
drop *ag_ever
*
by pidlink: egen nonag_ever = max(nonagany)
by pidlink: egen ag_ever = min(nonagany)
replace ag_ever = 1 - ag_ever
gen NAany_mover = .
replace NAany_mover = 1 if nonag_ever == 1 & ag_ever == 1
order pidlink year nonagany nonag_ever ag_ever NAany_mover
drop *ag_ever

* Label variables
lab var ravens "Normalized score on cognitive Ravens test"
lab var NAany_mover "Moved to any non-agricultural employment"
lab var NAonly_mover "Moved to only non-agricultural employment"
lab var NA_mover "Moved to non-agricultural employment"
lab var urban_ever "Ever lived in urban area"
lab var rural_ever "Ever lived in rural area"
lab var U_mover "Moved to urban"

*** Order variables
order pidlink year wave hhsize age age_norm age_sq male female ///
urban_birth migr educlv educyr educyr_sq ravens ravens_norm ravens_norm_sq ///
nonag urban nonagonly nonagany NAany_mover NAonly_mover NA_mover urban_ever /// 
rural_ever U_mover migrU migr_yeartot_88 migrU_yeartot_88 migr_ever migrU_ever ///
inc inc_h forinc forinc_h inforinc inforinc_h inc_real inc_h_real forinc_real ///
forinc_h_real inforinc_real inforinc_h_real lninc lninc_h lnforinc lnforinc_h ///
lninforinc lninforinc_h lninc_real lninc_h_real lnforinc_real lnforinc_h_real ///
lninforinc_real lninforinc_h_real empl hour forhour inforhour lnhour lnhour_sq ///
lnhour_exp3 lnhour_exp4 lnhour_exp5 lnforhour lnforhour_sq lninforhour ///
lninforhour_sq cons_tot cons_food cons_nfood cons_tot_real cons_food_real ///
cons_nfood_real lncons_tot lncons_food lncons_nfood fath_pidlink moth_pidlink ///
jakarta surabaya

save "Main_Analysis_IFLS.dta", replace
