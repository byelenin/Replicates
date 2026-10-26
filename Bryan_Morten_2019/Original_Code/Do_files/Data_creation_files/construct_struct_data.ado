program define construct_struct_data

	*! Source file: construct_struct_data_1Oct2017
	
	syntax [varlist], country(string)

	local educ all

	// Append ig data for each year
	if "`country'" == "us" {
		local year_list 1990 2010
		local type _state
		}
	else if "`country'" == "ind" {
		local year_list 1976 1995 2011 2012
		if "`type'" == "" {
			local type _prov
			}
		}

	foreach year in `year_list' {
	
		di in red "year is `year'"

		tokenize `year_list'
		if `year' == `1' { //first the first one of the list, save a fresh dataset//
			clear
			save "$structpath/Allan Structural Datasets/struct_dataset_`country'`type'_emp_educ_`educ'", emptyok replace
			}

		if "`country'" == "ind" {
			if `year' == 2012 {
				local dataset susenas_2011_2012
				}
			else if `year' == 2011 {
				local dataset susenas_2011_2012
				}
			else if `year' == 1995 {
				local dataset supas_1995
				}
			else if `year' == 1976 {
				local dataset supas_1976
				}
				
			// Read in appropriate dataset
			use "$secdata/Compiled/`dataset'_cleaned.dta", clear

			// Years 2011 and 2012 are in same file
			if `year' == 2011 | `year' == 2012 {
			keep if year == `year' 
				}
			
			}

		else if "`country'" == "us" {
			use "$secdata/IPUMS USA/ipums_usa_cleaned_`year'.dta", clear
			}
			

		if "`educ'" == "low" { //defined these in the cleanData file, currently 3 yrs for Indonesia and 12 yrs for US//
			keep if dum_high_educ == 0 | dum_phantom == 1
			}
		else if "`educ'" == "high" {
			keep if dum_high_educ == 1 | dum_phantom == 1
			}

		
		// Fix up the sample weight, remember we have some phantom guys in here to make the bilateral distance matrix square//
		replace sample_wt = 0 if dum_phantom == 1
		gen people_wt = sample_wt
		gen people_nowt = 1
		replace people_nowt = 0 if dum_phantom ==1 //these are the faux entries so bilateral matrix square//

		// Generate wage residuals
		capture drop ln_wage*
		gen ln_wage_month = log(wage_month)
		gen ln_wage_hour = log(wage_hour)

		reg ln_wage_month years_school age [aw=sample_wt]
		predict ln_wage_month_res, res
		gen wage_month_res = exp(ln_wage_month_res)
		reg ln_wage_hour years_school age [aw = sample_wt]
		predict ln_wage_hour_res, res
		gen wage_hour_res = exp(ln_wage_hour_res)
		
		////////////////////////////
		  //   Average Wages by i   //
		////////////////////////////

		preserve

		collapse (rawsum) sample_wt, by(current`type') //doing this intermediate step because if sample_wt ==0 it doesnt get included on the next step, so we cant check the merging later on in code.
		tempfile temp
		save `temp', replace
		restore, preserve
		
		collapse avg_wage_month_i = wage_month ///
		  avg_wage_month_res_i = wage_month_res ///
		  avg_wage_hour_i = wage_hour ///
		  avg_wage_hour_res_i = wage_hour_res ///
		  years_school_i=years_school  [aweight=sample_wt], ///
		  by(current`type')
		merge 1:1 current`type' using `temp'
		assert _merge != 1
		drop _merge
		
		label var avg_wage_month_i "Avg monthly wage over all ppl in i (current`type')"
		label var avg_wage_month_res_i "Avg monthly wage (res) over all ppl in i (current`type')"
		label var avg_wage_hour_i "Avg hourly wage over all ppl in i (current`type')"
		label var avg_wage_hour_res_i "Avg hourly wage (res) over all ppl in i (current`type')"
		label var years_school_i "Avg years school over all peope in i (current`type')"
		
		tempfile temp_avg_i
		save `temp_avg_i', replace
		
		restore ,preserve

		collapse (rawsum) sample_wt, by(birth`type') //doing this intermediate step because if sample_wt ==0 it doesnt get included on the next step, so we cant check the merging later on in code.
		tempfile temp
		save `temp', replace
		restore, preserve
		
		collapse years_school_g=years_school [aweight=sample_wt], by(birth`type')
		merge 1:1 birth`type' using `temp'
		assert _merge != 1
		drop _merge
		label var years_school_g "Avg years school over all peope in g (current`type')"
		tempfile temp_avg_g
		save `temp_avg_g', replace

		restore

		

		//////////////////////////////////////////////
		  //   Average Wages and Prop Migrate by ig   //
		//////////////////////////////////////////////

		preserve
		collapse (mean) wage_month_ig = wage_month wage_month_res_ig = wage_month_res wage_hour_ig = wage_hour wage_hour_res_ig = wage_hour_res years_school_ig=years_school ///
		  (sd) sd_wage_month_ig = wage_month sd_wage_month_res_ig = wage_month_res sd_wage_hour_ig = wage_hour sd_wage_hour_res_ig = wage_hour_res [aweight=sample_wt], ///
		  by(birth`type' current`type')
		tempfile merge1
		save `merge1', replace
		restore

		collapse (sum) people_wt people_nowt (mean) birth_distance`type', by(birth`type' current`type') //for pop counts, don't want this to be weighted by sample_wt like the means are. so do two collapses.
		merge 1:1 birth`type' current`type' using `merge1'
		assert _merge != 2
		drop _merge
		
		merge m:1 current`type' using `temp_avg_i'
		assert _merge == 3
		drop _merge
		
		merge m:1 birth`type' using `temp_avg_g'
		assert _merge == 3
		drop _merge
		
		// Drop 0 wages  
		
		///// Why do we do this? ????
		  replace wage_month_ig = . if wage_month_ig == 0
		replace sd_wage_month_ig = . if wage_month_ig == .
		replace wage_month_res_ig = . if wage_month_res_ig == 0
		replace sd_wage_month_res_ig = . if wage_month_res_ig == .
		replace wage_hour_ig = . if wage_hour_ig == 0
		replace sd_wage_hour_ig = . if wage_hour_ig == .
		replace wage_hour_res_ig = . if wage_hour_res_ig == 0
		replace sd_wage_hour_res_ig = . if wage_hour_res_ig == .

		egen i = group(current`type')
		egen g = group(birth`type')

		// Checking we have same numbers of origins and destinations
		unique i
		local n_i = `r(unique)'
		unique g
		local n_g = `r(unique)'

		if "`type'"!= "_rgcy" {
			assert `n_i' == `n_g'
			}
		
		// Create pair ids for all i!=g, accounting for symmetry of ig and gi
		egen pair_id = group(g i)
		egen pair_id2 = group(i g)
		replace pair_id = pair_id2 if i < g
		drop pair_id2

		// Calculate prob_ig (prob of going from birthplace g to current place i)
		bys g: egen L_0 = total(people_wt)
		bys i: egen L_1 = total(people_wt)
		gen prob_ig = people_wt/L_0
	
		// Generate variances
		gen var_wage_month_ig = sd_wage_month_ig^2
		gen var_wage_month_res_ig = sd_wage_month_res_ig^2
		gen var_wage_hour_ig = sd_wage_hour_ig^2
		gen var_wage_hour_res_ig = sd_wage_hour_res_ig^2
		drop sd_wage*
		gen var_mean_month_ig = var_wage_month_ig/(wage_month_ig)^2
		gen var_mean_month_res_ig = var_wage_month_res_ig/(wage_month_res_ig)^2
		gen var_mean_hour_ig = var_wage_hour_ig/(wage_hour_ig)^2
		gen var_mean_hour_res_ig = var_wage_hour_res_ig/(wage_hour_res_ig)^2
		label var var_mean_month_ig "variance/mean^2, monthly wage"
		label var var_mean_month_res_ig "variance/mean^2 (correcting age/educ), monthly wage"
		label var var_mean_hour_ig "variance/mean^2, hourly wage"
		label var var_mean_hour_res_ig "variance/mean^2 (correcting age/educ), hourly wage"

		
		////////////////////////
		  //   Final Datasets   //
		////////////////////////

		keep current* birth* i g pair_id prob_ig wage_* var_* L_0 L_1 avg_* people* birth_distance`type' years_school* // drops _fillin
		order current* birth* i g pair_id prob_ig wage_* var_* L_0 L_1 avg_* people* birth_distance`type'
		gen year = `year'
		
		order year current* birth* i g pair_id prob_ig wage_month_ig wage_hour_ig

		count // should be 281^2 = 78961 for regency
		append using "$structpath/Allan Structural Datasets/struct_dataset_`country'`type'_emp_educ_`educ'"
		save "$structpath/Allan Structural Datasets/struct_dataset_`country'`type'_emp_educ_`educ'", replace
		count

		

		}



end

	



		
		







	
	
			
	
	
