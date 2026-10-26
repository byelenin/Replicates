program cleanMadeData_30Sep2017

	*! Melanie Morten, 5/31/2016
	*! This takes the files that we have created and then defines the sample in a common way across samples
	

	// FOR THE INDONESIA SAMPLE: WE END UP WITH THE FOLLOWING GEO COVERAGE, AFTER DROPPING EAST TIMOR AND PAPUA. THE ACTUAL DATASET IS A 283*283 SQUARE DATASET
	// For 1976, there are 184 current regencies and 273 birth regencies//
	// For 1995, there are 281 current regencies and 281 birth regencies//
	// For 2011, there are 280 current regencies and 281 birth regencies//
	// For 2012, there are 280 current regencies and 281 birth regencies//

	
	syntax [varlist], hoh(string) female(string)

	* If put hoh(yes) then only hoh. hoh(no) is all households
	* female(no) is only male. female(yes) is male+female
	
	// FOR THE US SAMPLE" 
	
	// First, fix up the distance files so both rgcy and prov are in the same file//
	makeSupas95_rgcy_prov_distance

	
	// NOW, DO THE CLEANING OF ALL THE COMPONENT DATASETS//
	
	foreach year in 1976 1995 2011 2012 1990 2010  { //Decided to split up 2011/2012 so that, within year, each is square. Then, we append back at end
		
		if `year' == 1976 {
			local file supas_1976
			}
		else if `year' == 1995 {
			local file supas_1995
			}
		else if `year' == 2011 {
			local file susenas_2011_2012
			}

		
		if `year' == 1990 | `year' == 2010 {
			local country us
			local type _state
			local yrs_school 12 //cutoff for low/high schooling//
			}
		else {
			local country ind
			local type _rgcy
			local yrs_school 3
			}

		if "`country'" == "ind" {
			use $secdata/Compiled/`file'_made, clear
			}
		else if "`country'" == "us" {
			use "$secdata/IPUMS USA/ipums_usa_made_`year'", clear
			}

	
		// First: adjust for inflation
		if `year' == 2011 { //have both 2011 and 2012 in here//
			keep if year == 2011
			drop year
			adjust_inflation wage_month wage_hour, year(2011) country(ind)
			}
		else if `year' == 2012 {
			keep if year == 2012
			drop year
			adjust_inflation wage_month wage_hour, year(2012) country(ind)
			}
		else {
			adjust_inflation wage_month wage_hour, year(`year') country(`country')
			}
		

		// SAMPLE RESTRICTION: SAME ACROSS US AND INDONESIA//
		// Baseline: Keep only male HOHs

		if "`hoh'" == "yes" {
			keep if hoh_relation == 1
			}
		if "`female'" == "no" {
			keep if female == 0
			}
	
		// Keep only those ages 15 to 65
		drop if age < 15 | age > 65

		// Keep only employees//
		keep if employee == 1

		// Generate high/low skill (need to _fillin so all pairs are there for distance, as we condition on this later in structural estimation)//
		gen dum_high_educ = (years_school >=`yrs_school') if years_school < .
		label var dum_high_educ "Has at least `yrs_school' yrs of schools"
		
		// Drop those who were born outside the country//
		if `year' == 1995 | `year' == 2011 | `year' == 2012 { // the >8200 are consistent between 1995 and 2011. These are either guys outside the country (8200) or for 2011/2012 are guys that end up in Papua/West Papua so we drop anyways
			assert birth_rgcy != .
			drop if birth_rgcy > 8200 
			}
		
		// Now merge on the distances//
		// Do this at the RGCY level, using 95 as the base.
		// May need to fix up some of the concordances for 1976 and 2011/12

		if "`country'" == "ind" {
			joinby current_rgcy birth_rgcy using $secdata/Compiled/supas95_birth_distances, unmatched(both)
		
			// East Timor, and then Papua/West Papua have been dropped from the distance matrix. If these appear in _merge==1, ok to drop //
			foreach ltype in current birth {
				drop if `ltype'_rgcy >= 5400 & `ltype'_rgcy < 5500 //54 = East Timor//
				drop if `ltype'_rgcy >=8200 & `ltype'_rgcy < 8300 //82 = Papua/West Papua//
				}
			}
		else if "`country'" == "us" {
			joinby current_state birth_state using "$secdata/IPUMS USA/birth_state_distances", unmatched(both)
			rename birth_distance birth_distance_state
			}

		capture rename _merge _mergeold
		fillin year current`type' birth`type' dum_high_educ //this is to make the distance matrix square//
		
		di in red "year is `year'"

		unique current`type'
		unique birth`type'

		unique current`type' if sample_wt != .
		unique birth`type' if sample_wt != .
		// For 1976, there are 184 current regencies and 273 birth regencies//
		// For 1995, there are 281 current regencies and 281 birth regencies//
		// For 2011, there are 280 current regencies and 281 birth regencies//
		// For 2012, there are 280 current regencies and 281 birth regencies//

		gen dum_phantom = (_fillin == 1)
		label var dum_phantom "This is just to make the bilateral distance matrix square"
		drop _merge
		
		if "`country'" == "ind" {

			replace current_prov = floor(current_rgcy/100) if dum_phantom == 1
			replace birth_prov = floor(birth_rgcy/100) if dum_phantom == 1
			
			assert current_prov != .
			assert birth_prov != .
			}
		else if "`country'" == "us" {
			assert current_state != .
			assert birth_state != .
			}

		* Make a suffix 
		if "`hoh'" == "yes" & "`female'" == "no" {  //leaves the baseline spec as is//
			local suffix
			}
		else {
			local suffix _hoh_`hoh'_female_`female'
			}
		
		if "`country'" == "ind" {

			if `year' != 2012 {
				save $secdata/Compiled/`file'_cleaned`suffix', replace
				}
			else { //for 2012, we want to append it back to the 2011 year. Split it apart so that, within-year, we make the dataset square.
				append using $secdata/Compiled/`file'_cleaned`suffix'
				save $secdata/Compiled/`file'_cleaned`suffix', replace
				}
			}
		else if "`country'" == "us" {
			save "$secdata/IPUMS USA/ipums_usa_cleaned_`year'`suffix'", replace
			}

		}
		
end
		
	
