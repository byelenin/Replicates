program define makeAmenityPCA_15Oct2017

	*! This file constructs PCA analysis for the summary facts
	
	syntax [varlist]

	foreach type in _prov _rgcy {
		
		use "$secdata/PODES/podes_1996`type'", clear
		gen year = 1995
		append using "$secdata/PODES/podes_2011`type'"
		replace year = 2011 if year == .

		expand 2 if year == 2011, generate(_fillin) //so we can get 2012//
		replace year = 2012 if _fillin == 1
		drop _fillin
	
		rename prop current_prov

		if "`type'" == "_rgcy" {
			tostring current_prov, gen(prop_string)
			tostring kab, gen(rgcy_string)
			replace rgcy_string = "0" + rgcy_string if length(rgcy_string) == 1
			gen current_rgcy = prop_string + rgcy_string
			destring current_rgcy, replace
			drop prop_string rgcy_string
			}
	

		// Make pollution
		local polllist_1995 dum_*_pollution
		local polllist_2011 dum_water_pollution dum_land_pollution dum_air_pollution

		pca `polllist_1995' if year == 1995
		predict pca
		gen pca_pollution = pca if year == 1995
		drop pca

		pca `polllist_2011' if year == 2011 | year == 2012
		predict pca
		replace pca_pollution = pca if year == 2011 | year == 2012
		drop pca

		// Make ease of access
		local easelist_1995 ease_reach_hosp ease_reach_hea ease_reach_market ease_reach_shop
		local easelist_2011 ease_reach_hosp ease_reach_hea ease_reach_pol
		
		pca `easelist_1995' if year == 1995
		predict pca
		gen pca_ease = pca if year == 1995
		drop pca

		pca `easelist_2011' if year == 2011 | year == 2012
		predict pca
		replace pca_ease = pca if year == 2011 | year == 2012
		drop pca

		// Make a summary measure of all//
		pca `polllist_1995' `easelist_1995' if year == 1995
		predict pca
		gen pca_all = pca if year == 1995
		drop pca

		pca `polllist_2011' `easelist_2011' if year == 2011 | year == 2012
		predict pca
		replace pca_all = pca if year == 2011 | year == 2012
		drop pca


		* Lets standardize the pca
		foreach var in ease pollution all {
			bys year: egen mean_pca_`var' = mean(pca_`var')
			bys year: egen sd_pca_`var' = sd(pca_`var')
			gen pca_`var'_nostd = pca_`var'
			replace pca_`var' = (pca_`var' - mean_pca_`var')/sd_pca_`var'
			drop mean_pca_`var' sd_pca_`var'
			}

		
		save $secdata/pca_amenities`type', replace
		}
	


end

