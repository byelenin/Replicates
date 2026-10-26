program define makeAllSupas95

	*! MM, 30 May 2016
	*! Adopted from Main_Compiled_Prov_30May2016
	*! We now have *all* the bilateral distance obs, so can do the zero poisson regressions easily

	// Read in data
	supas95_read_in_data

	// Read in province distances
	supas95_province_distances

	// Calculate regency distances	
	supas95_rgcy_coordinates
	supas95_calc_rgcy_distances

	// Make variables and clean
	supas95_make_vars_30May2016
	
end
