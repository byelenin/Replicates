program define makeAllIFLS_8Dec2017

	*! MM, 5/30/2016
	*! Based on Allan's do file Prelim_Analysis_IFLS_Aug19

	read_in_ifls_data_8Dec2017 //addign rents//
	merge_ifls_files_7Dec2017 // adding rents//
	make_ifls_vars_Aug19

	ifls07_clean_transfrm_5Dec2017 //trimming top 1% of wages//
	

end
