* Version 1: May 17, 2014 (Allan Hsiao)

program susenas11_province_distances

	// Province codes
	*insheet using "/Users/allanhsiao/Google Drive/Migration/Data/Indonesia Road Maps/Google Static Maps/province_codes.csv", clear
	insheet using "$googlepath/province_codes.csv", clear
	drop susenasname
	rename centroidsname origin
	save "$secdata/Compiled/prov_orig_codes", replace
	
	rename origin destination
	save "$secdata/Compiled/prov_dest_codes", replace
	
	// Merge in province codes to distance matrix
	*insheet using "/Users/allanhsiao/Google Drive/Migration/Data/Indonesia Road Maps/Google Static Maps/province_distances_1995.csv", clear
	insheet using "$googlepath/province_distances_1995.csv", clear
	
	merge m:1 origin using "$secdata/Compiled/prov_orig_codes"
	rename susenascode origin_code
	drop if _merge != 3
	drop _merge
	cap erase "$secdata/Compiled/prov_orig_codes.dta"
	
	merge m:1 destination using "$secdata/Compiled/prov_dest_codes"
	rename susenascode destination_code
	drop if _merge != 3
	drop _merge
	cap erase "$secdata/Compiled/prov_dest_codes.dta"
	
	drop origin destination
	sort origin_code destination_code
	keep origin_code destination_code traveltime distance straightlinedistance
	
	// Save birth_prov and five_yrs_prov versions
	rename origin_code birth_prov
	rename destination_code current_prov
	rename traveltime birth_traveltime
	rename distance birth_distance
	rename straightlinedistance birth_str_distance
	save "$secdata/Compiled/susenas11_birth_prov_distances", replace
	
	rename birth_prov five_yrs_prov
	rename birth_traveltime five_yrs_traveltime
	rename birth_distance five_yrs_distance
	rename birth_str_distance five_yrs_str_distance
	save "$secdata/Compiled/susenas11_five_yrs_prov_distances", replace

end
