* Version 1: December 22, 2013 (Allan Hsiao)
* Version 2: August 3, 2014 (Allan Hsiao)
* Version 3: August 19, 2014 (Allan Hsiao)

program make_ifls_vars_Aug19

	use "$secdata/IFLS/ifls_2007", clear
	
	foreach year in _1993 _1997 _2000 _2007 {
	
		// Make/recode vars
		foreach hours in hours_lastweek_1`year' hours_usualweek_1`year' hours_lastweek_2`year' hours_usualweek_2`year' {
			replace `hours' = . if `hours' > 168
		}
		foreach weeks in weeks_year_1`year' weeks_year_2`year' {
			replace `weeks' = . if `weeks' > 52
		}
		foreach job in 1 2 {
			gen self_employed_`job'`year' = empl_status_`job'`year'
			recode self_employed_`job'`year' (1=1) (2=1) (3=1) (4=0) (5=0) (6=0) (7=0) (8=0) (9=.)
			gen employee_`job'`year' = empl_status_`job'`year'
			recode employee_`job'`year' (1=0) (2=0) (3=0) (4=1) (5=1) (6=0) (7=1) (8=1) (9=.)
		}
		
		replace wage_lastyear_1`year' = . if wage_lastyear_1`year' == 999999999
		recode sex`year' (3=1) (1=0)
		rename sex`year' female`year'
		replace age`year' = . if age`year' > 120
		replace rural`year' = rural`year' - 1 // Make 1 rural, 0 urban
		recode literacy`year' (3=0) (9=.)
		
		if "`year'" != "_1993" {
			replace wage_year`year' = . if wage_year`year' > 950000000
			}
		
		// Recode education to years of schooling
		gen years_school`year' = .
		replace years_school`year' = 0 if inlist(educ_attain`year', 1)
		replace years_school`year' = 1 if inlist(educ_attain`year', 90)
		replace years_school`year' = 6 if inlist(educ_attain`year', 2, 72)
		replace years_school`year' = 9 if inlist(educ_attain`year', 3, 4, 73)
		replace years_school`year' = 12 if inlist(educ_attain`year', 5, 6, 74)
		replace years_school`year' = 14 if inlist(educ_attain`year', 60)
		replace years_school`year' = 16 if inlist(educ_attain`year', 61)
		replace years_school`year' = 18 if inlist(educ_attain`year', 62)
		replace years_school`year' = 20 if inlist(educ_attain`year', 63)
		
		// Correct for years completed
		replace years_school`year' = 3 if educ_attain`year' == 2 & educ_completed`year' == 98 
		replace years_school`year' = 0 if inlist(educ_attain`year', 90) & inlist(educ_completed`year', 0)
		replace years_school`year' = educ_completed`year' if inlist(educ_attain`year', 2, 72) & inlist(educ_completed`year', 0, 1, 2, 3, 4, 5, 6)
		replace years_school`year' = 6 + educ_completed`year' if inlist(educ_attain`year', 3, 4, 73) & inlist(educ_completed`year', 0, 1, 2, 3)
		replace years_school`year' = 9 + educ_completed`year' if inlist(educ_attain`year', 5, 6, 74) & inlist(educ_completed`year', 0, 1, 2, 3)
		replace years_school`year' = 12 + educ_completed`year' if inlist(educ_attain`year', 60) & inlist(educ_completed`year', 0, 1, 2)
		replace years_school`year' = 12 + educ_completed`year' if inlist(educ_attain`year', 61) & inlist(educ_completed`year', 0, 1, 2, 3, 4)
		replace years_school`year' = 16 + educ_completed`year' if inlist(educ_attain`year', 62) & inlist(educ_completed`year', 0, 1, 2)
		replace years_school`year' = 16 + educ_completed`year' if inlist(educ_attain`year', 63) & inlist(educ_completed`year', 0, 1, 2)
		
		*drop educ_attain educ_completed
		
		// Clean occupation variable
		if "`year'" == "_2007" {
			replace occupation_2007 = "." if occupation_2007 == "999"	
			replace occupation_2007 = substr(occupation_2007, 2, 2)
			}
		if "`year'" == "_1993" {
			replace occupation_1993 = substr(occupation_1993, 1, 1) + "0" if substr(occupation_1993, 2, 1) == "X"
			}

		// Group occupation codes by type
		replace occupation`year' = "100" if occupation`year' == "MM" | occupation`year' == "M1" | occupation`year' == "M2"
		replace occupation`year' = "110" if occupation`year' == "X2" | occupation`year' == "XX"
		replace occupation`year' = "120" if occupation`year' == "SS"
		destring(occupation`year'), replace
		
		gen occupation_group`year' = "Professional/Technical" if occupation`year' <= 19
		replace occupation_group`year' = "Administrative and Managerial" if 20 <= occupation`year' & occupation`year' <=29
		replace occupation_group`year' = "Clerical and Related Workers" if 30 <= occupation`year' & occupation`year' <=39
		replace occupation_group`year' = "Sales Workers" if 40 <= occupation`year' & occupation`year' <=49
		replace occupation_group`year' = "Service Workers" if 50 <= occupation`year' & occupation`year' <=59
		replace occupation_group`year' = "Agricultural, Animal Husbandry, Forestry workers, Fisherman and Hunters" if 60 <= occupation`year' & occupation`year' <=69
		replace occupation_group`year' = "Production and Related Workers, Transport Operators, and Laborers" if 70 <= occupation`year' & occupation`year' <=99
		replace occupation_group`year' = "Military and Police" if occupation`year' == 100
		replace occupation_group`year' = "Miscellaneous" if occupation`year' == 110
		replace occupation_group`year' = "Student" if occupation`year' == 120
		
		order occupation`year', b(occupation_group`year')
		
		// Rename variables to be same as SUPAS 1995
		rename prov`year' current_prov`year'
		rename regency`year' current_rgcy`year'
		*rename occupation`year' occupation
		rename occupation_group`year' industry`year'
		
		// Make wage_month, wage_hour, self_employed, employee variables (based on primary job last month)
		*gen wage_month = wage_lastyear_1 / 12 if wage_lastyear_1 != .
		*replace wage_month = netprofit_lastyear_1 / 12 if netprofit_lastyear_1 != .
		if "`year'" == "_2007" {
			gen inc_imputed`year' = inc_farm`year' + inc_nonfarm_prof`year'
			gen inc_imputed2`year' = inc_harvest`year' + inc_farmassets`year' + inc_nonfarm_prof`year'
			}
		
		replace netprofit_lastyear_2`year' = 0 if netprofit_lastyear_2`year' == .
		gen netprofit_lastyear`year' = netprofit_lastyear_1`year' + netprofit_lastyear_2`year'
		
		replace wage_lastyear_2`year' = 0 if wage_lastyear_2`year' == .
		gen wage_lastyear`year' = wage_lastyear_1`year' + wage_lastyear_2`year' 
		
		replace hours_lastweek_2`year' = 0 if hours_lastweek_2`year' == .
		gen hours_lastweek`year' = hours_lastweek_1`year' + hours_lastweek_2`year'
		
		gen self_employed`year' = self_employed_1`year'
		gen employee`year' = employee_1`year'

*pause on
*pause
		
		* Choices for self-employed wage: netprofit_lastmonth_1 netprofit_lastyear_1 netprofit_lastyear wage_year inc_imputed
		gen wage_month1`year' = wage_lastmonth_1`year' if employee`year' == 1
		replace wage_month1`year' = netprofit_lastmonth_1`year' if self_employed`year' == 1	
		
		gen wage_month2`year' = wage_lastyear_1`year' / 12 if employee`year' == 1
		replace wage_month2`year' = netprofit_lastyear_1`year' / 12 if self_employed`year' == 1
		
		gen wage_month3`year' = wage_lastyear`year' / 12 if employee`year' == 1
		replace wage_month3`year' = netprofit_lastyear`year' / 12 if self_employed`year' == 1

		if "`year'" != "_1993" {
			gen wage_month4`year' = wage_year`year' / 12
			}
		
		if "`year'" == "_2007" {
			gen wage_month5`year' = wage_lastyear`year' / 12 if employee`year' == 1
			replace wage_month5`year' = inc_imputed`year' / 12 if self_employed`year' == 1
			gen wage_month6`year' = wage_lastyear`year' / 12 if employee`year' == 1
			replace wage_month6`year' = inc_imputed2`year' / 12 if self_employed`year' == 1
			}
			
		* Wage per hour
		gen wage_hour1`year' = wage_month1`year' / (4*hours_lastweek_1`year')
		gen wage_hour2`year' = wage_month2`year' / (4*hours_lastweek_1`year')
		gen wage_hour3`year' = wage_month3`year' / (4*hours_lastweek`year')
		if "`year'" != "_1993" {
			gen wage_hour4`year' = wage_month4`year' / (4*hours_lastweek`year')
			}
		if "`year'" == "_2007" {		
			gen wage_hour5`year' = wage_month5`year' / (4*hours_lastweek`year')
			gen wage_hour6`year' = wage_month6`year' / (4*hours_lastweek`year')
			}
	
	}	

	// Adjusting provinces to reflect regencies where SUPAS 1995 regency is in a different province
	foreach year in _1993 _1997 _2000 _2007 {
		replace current_prov`year' = int(current_rgcy`year'/100) if current_prov`year' != int(current_rgcy`year'/100) & current_rgcy`year' != . 
		}
	rename prov_birth birth_prov
	rename regency_birth birth_rgcy
	replace birth_prov = int(birth_rgcy/100) if birth_prov != int(birth_rgcy/100) & birth_rgcy != .
	replace birth_prov = 81 if birth_prov == 82 //
	
	////////////////////////////////////////////////////////////////////////////

	/*
	// Merge in province-pair distances for birth_prov
	foreach year in _1993 _1997 _2000 _2007 {
		preserve
		use "$secdata/Compiled/supas95_birth_prov_distances", clear
		rename birth_distance birth_mst_distance
		rename birth_str_distance birth_distance_prov
		foreach var in current_prov birth_traveltime birth_distance birth_mst_distance {
			rename `var' `var'`year'
			}
		tempfile distances
		save `distances'
		restore
		
		sort current_prov`year' birth_prov
		joinby current_prov`year' birth_prov using `distances', unmatched(both)
		*merge m:1 current_prov`year' birth_prov using `distances'
		*drop if _merge == 2
		drop _merge

	
		// Generate dummy variable for migrants (migrant if current location != birth location)
		gen birth_migrant`year' = (birth_distance`year' >0) if birth_distance`year' < .
		
	}
	*/
	
	// Note: Papua and West Papua observations get dropped here as their distances aren't in the distance matrix.
	
	save "$secdata/IFLS/ifls_2007_premade_prov", replace
	
end
