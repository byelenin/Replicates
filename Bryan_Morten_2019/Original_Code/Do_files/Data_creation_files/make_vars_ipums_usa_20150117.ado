* Version 1: February 22, 2014 (Allan Hsiao)

program make_vars_ipums_usa_20150117

	syntax [varlist], year(string)
	
	// Calculate regency distances
	
	// Use full IPUMS USA 1990 dataset
	use "$secdata/IPUMS USA/ipums_usa_`year'", clear
	
	
	// Generate variables
	replace incwage = . if incwage == 999999
	gen wage_month = incwage / 12
	drop incwage
	
	replace HRSWRK1 = . if HRSWRK1 == 999
	gen wage_hour = wage_month/HRSWRK1/4
	drop HRSWRK1
	
	* gen rural = 1 if urban == 1
	* replace rural = 0 if urban == 2
	cap drop urban
	
	drop related
	
	gen female = 1 if sex == 2
	replace female = 0 if sex == 1
	drop sex
	
	gen years_school = .
	replace years_school = . if educus == 000
	replace years_school = 0 if educus == 101
	replace years_school = 1 if educus == 102 | educ == 103
	replace years_school = 4 if educus == 200
	replace years_school = 8 if educus == 300
	replace years_school = 9 if educus == 400
	replace years_school = 10 if educus == 500
	replace years_school = 11 if educus == 600 | educus == 701
	replace years_school = 12 if educus == 702
	replace years_school = 14 if educus == 821 | educus == 822 | educus == 823
	replace years_school = 16 if educus == 825
	replace years_school = 18 if educus == 826 | educus == 827
	replace years_school = 20 if educus == 828
	drop educus
	
	gen employee = . if classwk == 0
	replace employee = 1 if classwk == 2
	replace employee = 0 if classwk == 1 | classwk == 3
	gen self_employed = . if classwk == 0
	replace self_employed = 1 if classwk == 1
	replace self_employed = 0 if classwk == 2 | classwk == 3
	drop classwk classwkd
	
	gen current_state = GEO1A_US-840000
	drop GEO1A_US
	
	// Rename relevant variables
	rename bplus birth_state
	order birth_state,b(current_state)
	rename wtper sample_wt
	rename relate hoh_relation
	
	// Drop foreign-born
	drop if birth_state == 98
	
	// Generate dummy variable for migrants
	gen birth_mig = 1 if birth_state != current_state
	replace birth_mig = 0 if birth_state == current_state
	
	save "$secdata/IPUMS USA/ipums_usa_made_`year'", replace
	
end


