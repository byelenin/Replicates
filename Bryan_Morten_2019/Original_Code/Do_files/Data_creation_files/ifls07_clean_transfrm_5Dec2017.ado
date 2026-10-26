program ifls07_clean_transfrm_5Dec2017

	
use "$secdata/IFLS/ifls_2007_premade_prov", clear


	
	/////////////////////
	  //                 //
	//  Dropping data  //
	//                 //
	/////////////////////

	foreach year in 1993 1997 2000 2007 {
	
		preserve
	
		// Keep only those ages 15 to 65
		drop if age_`year' < 15 | age_`year' > 65

		// Drop Papua (province 82)
		drop if current_prov_`year' == 82
		drop if birth_prov == 82
		
		// Drop East Timor (province 54)
		drop if current_prov_`year' == 54
		drop if birth_prov == 54
		
		// Drop variables for other years
		keep pidlink birth_prov birth_rgcy *_`year'

		// Clean variable names to remove year tags
		rename *_`year' *
		
		// Adjust for inflation
		gen wage_month = wage_month1
		gen wage_hour = wage_hour1

		// Trim top 1% of wages (drop top 1%)
		winsor2 wage_month wage_hour, replace trim cut(0 99)
		adjust_inflation wage_month wage_hour, year(`year') country(ind)

		
		save "$secdata/IFLS/ifls_2007_cleaned_prov_all_`year'", replace
		save "$secdata/Compiled/ifls_2007_cleaned_prov_all_`year'", replace

		// Keep only HOHs
		keep if hoh_relation == 1
		// Keep only men
		keep if female == 0

		
		save "$secdata/IFLS/ifls_2007_cleaned_prov_`year'", replace
		save "$secdata/Compiled/ifls_2007_cleaned_prov_`year'", replace
		
		restore
	
		}
	
end
