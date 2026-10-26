program define make_housing_expend_susenas

	*! This uses the SUSENAS micro data to get the rental price data
	
*! 1995
	
	use $rawdata/SUSENAS_from_JPAL/1995/susenas95_kr.dta, clear

	keep k1r1 k1r2 k2r2 k9r17* k8r1 wert95

	gen year = 1995

	rename k1r1 province
	rename k1r2 regency

	rename k2r2 no_hh_members
	rename k8r1 floor_area
	* there are a few other variables, but lets see what is consistent across surveys first

	rename k9r17a housing_expend_last_month
	rename k9r17b housing_expend_last_12month

	label var housing_expend_last_month "Housing, lighting, fuel expenses"

	gen avg_housing_floor_area = housing_expend_last_month/floor_area

	collapse (mean) avg_housing = housing_expend_last_month avg_housing_floor_area [pw=wert95],by(province year)

	rename province current_prov
	destring current_prov, replace

	save $secdata/housing_expenditure_susenas, replace

	

	* I found this page helpful for getting the right codes: http://nesstar.ada.edu.au/webview/index.jsp?v=2&mode=documentation&submode=abstract&study=http://nesstar.ada.edu.au:80/obj/fStudy/au.edu.anu.ada.ddi.01307&top=yes
	*! 2012
	*! Want: blok42. Code for housing expenditure, as per ada website, is:
	/*230 	A. HOUSINGAND HOUSEHOLD FACILITY (R.231-R.260) 	286113 	
	3.8%
	231 	House ownership (1. Owned 2. Leased 3. Rented 4. Rent-free 5 	0 	
	0.0%
	232 	If owned or rent-free, the predicted rent value per month 	257801 	


	Sn12_m423.4%
	233 	If leased, the predicted lease value per month 	8937 	
	0.1%
	234 	If rented, the predicted rent value per month 	5487 	
	0.1%
	235 	If government/company provided or other, the predicted rent 	17058 	
	0.2%
*/

	// 2012//

	use $rawdata/SUSENAS_from_JPAL/2012/sn12_krt.dta, clear
	rename b2r1 no_hh_members
	rename b6r8 floor_area
	keep urut no_hh_members floor_area
	tempfile temp
	save `temp', replace

	use $rawdata/SUSENAS_from_JPAL/2012/Sn12_m42.dta, clear
	rename B1R1 province
	rename B1R2 regency
	rename B42K2 quantity
	rename B42K3 housing_expend_3_month_ago
	rename B42K4 housing_expend_2_month_ago
	rename B42K5 housing_expend_last_month
	rename B42K6 housing_expend_last_3months

	merge m:1 urut using `temp'

	*! Now we just need to keep the housing expenses
	keep if kode >=232 & kode <= 235

	* Is unique on urut/kode
	* So: drop if housing_expend_last_month == 0
	drop if housing_expend_last_month == 0

	* still not unique. keep the lowest kode: this is rent for house owned (rather than rent for govt owned house)
	bys urut (kode): keep if _n == 1

	gen avg_housing_floor_area = housing_expend_last_month/floor_area

	gen year = 2012

	* Merge on the adjustment for province changes
	preserve
	use "$secdata/Compiled/susenas11_to_supas95_rgcy_key", clear
	gen province = floor(susenas11_rgcy_code/100)
	gen current_prov = floor(supas95_rgcy_code/100)
	contract province current_prov
	bys province (_freq): keep if _n == _N
	drop _freq
	tempfile temp_prov
	save `temp_prov', replace
	restore

	capture drop _merge
	merge m:1 province using `temp_prov'

	collapse (mean) avg_housing = housing_expend_last_month avg_housing_floor_area [pw=wert], by(current_prov year)

	append using $secdata/housing_expenditure_susenas
	save $secdata/housing_expenditure_susenas, replace


	// 2011: I cant work out what the merging variable is here, so didnt add on floor area. But: 1995/2011 doesnt really change//
	
	use $rawdata/SUSENAS_from_JPAL/2011/Sn11_m42.dta, clear
	rename b1r1 province
	rename b1r2 regency
	rename b1r3 subdistrict
	rename b1r4 village
	keep if kode >=230 & kode <= 235
	rename b42k2 quantity
	rename b42k3 housing_expend_3_month_ago
	rename b42k4 housing_expend_2_month_ago
	rename b42k5 housing_expend_last_month
	rename b42k6 housing_expend_last_3months

	gen year = 2011
	
	capture drop _merge
	merge m:1 province using `temp_prov'
	
	collapse (mean) avg_housing = housing_expend_last_month [pw=fwt], by(current_prov year)

	append using $secdata/housing_expenditure_susenas
	save $secdata/housing_expenditure_susenas, replace

	gen log_avg_housing = log(avg_housing)


	save $secdata/housing_expenditure_susenas, replace


	// Just check to see what kind of elasticity we get//

	use "$structpath/Allan Structural Datasets/struct_dataset_ind_prov_emp_educ_all", clear
	bys year current_prov (birth_prov): keep if _n == 1

	merge 1:1 year current_prov using $secdata/housing_expenditure_susenas, update //for now, just 1995
	
	gen log_L_1 = log(L_1)
	capture drop log_avg_housing
	gen log_avg_housing = log(avg_housing)
	gen log_avg_housing_floor_area = log(avg_housing_floor_area)

	reg log_avg_housing log_L_1
	reghdfe log_avg_housing log_L_1, absorb(current_prov year)

	reg log_avg_housing_floor_area log_L_1
	reghdfe log_avg_housing_floor_area log_L_1, absorb(current_prov year)

	
end

