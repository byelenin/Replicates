program define makeAllPODES

	*! This file does all the data creation for PODES
	

	foreach year in 00 11 96 {
		read_in_podes`year'
		capture podes`year'_to_supas95_rgcy //for 96, dont need it as already have 95 geographies//
		clean_podes`year'_Dec9
		prov_rgcy_datasets_podes`year'
		}


end

