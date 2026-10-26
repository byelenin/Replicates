program define makeAllSusenas2011_12
	
	*! MM, 30 May 2016
	*! Adopted from Main_Compiled_Prov_30May2016
	*! We now have *all* the bilateral distance obs, so can do the zero poisson regressions easily

	susenas11_read_in_data_2011
	susenas11_read_in_data_2012
	susenas11_combine_2011_2012
  
	// Read in province distances
	susenas11_province_distances

	// Calculate regency distances	
	susenas11_rgcy_coordinates
	susenas11_calc_rgcy_distances

	// Adjust SUSENAS 2011-2012 geographic regions to match SUPAS 1995
	susenas11_create_regions_key
	susenas11_adjust_regions
  
	// Make variables and clean
	susenas11_make_vars_30May2016
	
	
end
