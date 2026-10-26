* Version 1: February 11, 2014 (Allan Hsiao)
* Creates a square table with distances for each location pair

program susenas11_calc_rgcy_distances

	// Read in latitude and longitude coordinates
	use "$secdata/Compiled/susenas11_rgcy_coordinates", clear
	
	gen other_rgcy_code = rgcy_code
	fillin rgcy_code other_rgcy_code
	
	gsort rgcy_code -regency
	by rgcy_code: carryforward regency latitude longitude, replace
	
	drop _fillin
	sort other_rgcy_code
	merge m:1 other_rgcy_code using "$secdata/Compiled/susenas11_rgcy_coordinates_other"
	drop _merge
	cap erase "$secdata/Compiled/susenas11_rgcy_coordinates_other.dta"
	
	//Convert to radians
	foreach var in latitude longitude other_latitude other_longitude {
		replace `var' = `var' * c(pi) / 180
	}
	// Calculate distances using Haversine formula (http://andrew.hedges.name/experiments/haversine)
	gen dlat = other_latitude - latitude
	gen dlon = other_longitude - longitude
	gen a = (sin(dlat/2))^2 + cos(latitude) * cos(other_latitude) * (sin(dlon/2))^2 
	gen c = 2 * atan2(sqrt(a), sqrt(1-a)) 
	
	gen distance = 6373 * c //(6373 km is the radius of the Earth)
	drop dlat dlon a c latitude longitude other_latitude other_longitude
	drop regency other_regency
	
	sort rgcy_code other_rgcy_code
	save "$secdata/Compiled/susenas11_rgcy_distances", replace
	
	// Distance table for birth_distance
	use "$secdata/Compiled/susenas11_rgcy_distances", clear
	rename rgcy_code current_rgcy
	rename other_rgcy_code birth_rgcy
	rename distance birth_distance
	save "$secdata/Compiled/susenas11_birth_rgcy_distances", replace
	
	// Distance table for five_yrs_distance
	use "$secdata/Compiled/susenas11_rgcy_distances", clear
	rename rgcy_code current_rgcy
	rename other_rgcy_code five_yrs_rgcy
	rename distance five_yrs_distance
	save "$secdata/Compiled/susenas11_five_yrs_rgcy_distances", replace
	

end	

