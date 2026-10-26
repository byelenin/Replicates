program setupRawData

	*! This file runs the data creation programs for *all* the raw data

	makeAllSupas95
	makeAllSusenas2011_12
	makeAllUSData

	* Up to here: did it on generic file
	* R1 wants robustness over males/females, so make different versions of our datasets.
	foreach hoh in yes no {
		foreach female in no yes {
			*cleanMadeData_30Sep2017, hoh(`hoh') female(`female') //this makes the estimation sample (i.e. males 16-65) and also merges on geo distances for the main Ind and US files//
			cleanMadeData_20Nov2017, hoh(`hoh') female(`female') //this makes the estimation sample (i.e. males 16-65) and also merges on geo distances for the main Ind and US files//
			}
		}

	*makeAllIFLS
	makeAllIFLS_8Dec2017
	setup_delaware_rainfall
	makeAllPODES
	*makeAmenityPCA
	makeAmenityPCA_15Oct2017
	make_housing_expend_susenas
	setupGDP //this makes the GDP dataset//

	* Make the structural datasets
	construct_struct_data, country(ind)
	construct_struct_data, country(us)
	setup_struct_data

end
