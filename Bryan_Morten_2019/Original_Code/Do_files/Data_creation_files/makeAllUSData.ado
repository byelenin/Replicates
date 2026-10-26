program define makeAllUSData

	*! This calls files that are in the IPUMS USA subfolder

	state_dist_table_20150117
	calc_state_dist_20150117

foreach year in 1990 2010 {
	read_in_data_ipums_usa_20150117, year(`year')
	make_vars_ipums_usa_20150117, year(`year')
	
}

end
