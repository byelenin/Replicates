* Creates a square table with distances for each location pair

program calc_state_dist_20150117

	// Read in latitude and longitude coordinates
	use "$secdata/IPUMS USA/state_coordinates", clear
	
	gen other_state_code = state_code
	fillin state_code other_state_code
	
	gsort state_code -state
	by state_code: carryforward state latitude longitude, replace
	
	drop _fillin
	sort other_state_code
	merge m:1 other_state_code using "$secdata/IPUMS USA/state_coordinates_other"
	drop _merge
	
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
	drop state other_state
	
	sort state_code other_state_code
	save "$secdata/IPUMS USA/state_distances", replace
	
	// Distance table for birth_distance
	use "$secdata/IPUMS USA/state_distances", clear
	rename state_code current_state
	rename other_state_code birth_state
	rename distance birth_distance
	save "$secdata/IPUMS USA/birth_state_distances", replace

end	

