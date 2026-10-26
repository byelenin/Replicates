program setupRawData

	*! This file runs the data creation programs for *all* the raw data

	makeAllSupas95
	makeAllSusenas2011_12
	makeAllUSData

	cleanMadeData_20Nov2017, hoh(yes) female(no) //this makes the estimation sample (i.e. males 16-65) and also merges on geo distances for the main Ind and US files//
	
	makeAllIFLS_8Dec2017
	setup_delaware_rainfall
	makeAllPODES
	*makeAmenityPCA
	makeAmenityPCA_15Oct2017
	make_housing_expend
	setupGDP //this makes the GDP dataset//

end
