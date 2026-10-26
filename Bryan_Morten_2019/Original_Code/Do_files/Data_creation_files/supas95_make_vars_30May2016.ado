* Version 1: February 11, 2014 (Allan Hsiao)
* Version 2: July 20, 2014 (AH) added self-employed, hours worked, literacy
* Version 3: July 28, 2014 (AH) Changed to province-level
* Version 4, 30 May 2016 (MM) joinby instead of merge to get all pairwise combos.

program supas95_make_vars_30May2016

	// Use full SUPAS 1995 dataset
	use "$secdata/Compiled/supas_1995", clear
	
	//Generate relevant variables
	gen hh_number = 100 * nks + nus
	drop nks nus
	
	gen current_rgcy = 100 * prop + kab
	drop prop kab kec desa
	
	gen birth_rgcy = 100 * p509prop + p509kab
	drop p509prop p509kab
	
	gen prev_rgcy = 100 * p510prop + p510kab
	drop p510prop p510kab
	
	gen five_yrs_rgcy = 100 * p514prop + p514kab
	drop p514prop p514kab p514kec p514desa
	
	gen wage_month = p609uang + p609brng // wage includes money and goods received
	drop p609uang p609brng
	
	gen employed = 1 if p601 == 1
	replace employed = 0 if p601 == 2 | p601 == 3 | p601 == 6
	drop p601
	
	// Rename relevant variables
	rename weight sample_wt
	rename p501 indiv_number
	rename p502 hoh_relation
	rename p503 sex
	rename p505 age 
	rename p509a ever_lived_elsewhere
	rename p511 dur_resid
	rename p515 five_yrs_mig_reason
	rename p519 educ_attain
	drop p517 p518
	rename p606 occupation
	rename p607 industry
	drop p602
	
	rename p521 literacy
	rename p605 hours_week
	rename p608 empl_status
	
	// Replace missing literacy values for those who attended school
	replace literacy = 1 if inlist(p516, 2, 3)
	drop p516
	
	// Create self-employer and employee indicators
	// Self-employed if "self-employed," "self-employed assisted by family," or "employer"
	gen self_employed = 1 if inlist(empl_status, 1, 2, 3)
	replace self_employed = 0 if inlist(empl_status, 4, 5)
	gen employee = 1 if inlist(empl_status, 4)
	replace employee = 0 if inlist(empl_status, 1, 2, 3, 5)
	*drop empl_status
	
	// Clean religion data
	rename p507 religion
	label define lab_religion 1 "Muslim" 2 "Catholic" 3 "Protestant/Other Christian" 4 "Hindu" 5 "Buddhist" 6 "Other"
	label values religion lab_religion
	
	// Clean language data
	foreach var in p522 p523 {
		replace `var'b = 1000 if `var' == 1 // Indonesian
		replace `var'b = 999999 if `var'b == 999 // Label "999" local languages as other
		replace `var'b = 999999 if `var' == 3 // Label foreign languages as other
		drop `var' `var'l
	}
	
	rename p522b language_mother
	rename p523b language_home
	
	// Generate wage per hour
	replace wage_month = . if wage_month >=   9000000 //MM, 9/1/9/2014: switch to missing//
	gen wage_hour = wage_month / (4 * hours_week)
	
	// Recode education to years of schooling
	replace educ_attain = . if educ_attain == 0
	gen years_school = 0 if educ_attain == 1
	replace years_school = 6 if educ_attain == 2
	replace years_school = 9 if educ_attain == 3
	replace years_school = 12 if educ_attain == 4
	replace years_school = 9 if educ_attain == 5
	replace years_school = 12 if educ_attain == 6
	replace years_school = 14 if educ_attain == 7
	replace years_school = 15 if educ_attain == 8
	replace years_school = 16 if educ_attain == 9
	drop educ_attain
	
	// Place of birth: recode to current location if lived there since 5 years old
	replace birth_rgcy = current_rgcy if dur_resid >= age - 5
	
	// Previous residence: recode to current location if lived in current location since 15 years old
	replace prev_rgcy = current_rgcy if dur_resid >= age - 15
	// Previous residence: recode to current location if they've always lived there (NIU == 99 and 9999)
	replace prev_rgcy = current_rgcy if ever_lived_elsewhere == 2
	
	// Five years ago residence: recode to current location if they've been there all five years
	replace five_yrs_rgcy = current_rgcy if age < 5 | dur_resid >= 5
	// Five years ago residence: recode to missing to drop out people who moved not for occupation/job search (~6%)
	//replace five_yrs_rgcy = . if five_yrs_mig_reason != . & (five_yrs_mig_reason != 1 & five_yrs_mig_reason != 2)
	// This takes out those who didn't move across regencies but still have a reason for moving
	
	// Generate Rural and Female dummies
	gen female = sex - 1
	gen rural = kp - 1
	drop kp sex
	
	save "$secdata/Compiled/supas_1995_made", replace
		
end


