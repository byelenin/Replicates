program read_in_hh_enterprise

	////////////////////////////////////
	//   Read in HH enterprise data   //
	////////////////////////////////////
	
	* Income from non-business assets
	use "$rawdata/IFLS/hh07_b2_dta/b2_hr1.dta", clear
	keep hhid07 hrtype /*hr06 hr07 hr12x*/ hr12a /*hr12b hr02*/ hr05
	replace hr05 = 0 if hr05 == .
	replace hr12a = 100 if hr12a == .
	replace hr12a = hr12a / 100.00 
	gen inc_assets = hr05 * hr12a
	keep hhid07 inc_assets
	collapse (sum) inc_assets, by(hhid07)
	tempfile inc_nonbusassets
	save `inc_nonbusassets'
	
	* Income from non-farm business
	use "$rawdata/IFLS/hh07_b2_dta/b2_nt2.dta", clear
	keep hhid07 nt_num nt02 nt03 nt22 nt23 nt05g nt07 nt08 nt09 nt09b nt09d nt09f nt24 nt25 nt26 
	order hhid07, b(nt_num)
	replace nt03 = 100 if nt02 == 1
	gen inc_nonfarm_prof = (nt09 + nt09b) * nt03 / 100.00
	gen inc_nonfarm_profused = nt09d + nt09b
	drop nt_num nt02 nt03 nt22 nt23 nt05g nt07 nt08 nt09* nt24 nt25 nt26
	collapse (sum) inc_nonfarm_prof inc_nonfarm_profused, by(hhid07)
	tempfile inc_nonfarm
	save `inc_nonfarm'
	
	* Income from farm business
	use "$rawdata/IFLS/hh07_b2_dta/b2_ut1.dta", clear
	keep hhid07 ut07 ut08 ut09 
	replace ut07 = 0 if ut07 == .
	replace ut08 = 0 if ut08 == .
	replace ut09 = ut07 - ut08 if ut09 == .
	rename ut09 inc_farm
	keep hhid07 inc_farm
	tempfile inc_farm
	save `inc_farm'
	
	* Income from farm harvest
	use "$rawdata/IFLS/hh07_b2_dta/b2_ut2.dta", clear
	keep hhid07 ut07l ut07m ut07n ut07o ut07p ut07q ut07r
	replace ut07o = ut07p * ut07q if ut07o == .
	replace ut07r = 0 if ut07r == .
	gen inc_harvest = ut07o - ut07r
	collapse (sum) inc_harvest, by(hhid07)
	tempfile inc_harvest
	save `inc_harvest'
	
	* Income from farm assets
	use "$rawdata/IFLS/hh07_b2_dta/b2_ut4.dta", clear
	keep hhid07 uttype ut11 ut12 ut13 ut14
	replace ut12 = 0 if ut12 == .
	replace ut13 = 0 if ut13 == .
	replace ut14 = 0 if ut14 == .
	gen inc_farmassets = ut13 + ut14 - ut12
	collapse (sum) inc_farmassets, by(hhid07)
	tempfile inc_farmassets
	save `inc_farmassets'
	
	* Merge all household enterprise incomes together
	use `inc_nonfarm'
	merge 1:1 hhid07 using "`inc_farm'"
	drop _merge
	merge 1:1 hhid07 using "`inc_harvest'"
	drop _merge
	merge 1:1 hhid07 using "`inc_farmassets'"
	drop _merge
	
	foreach var in inc_nonfarm_prof inc_nonfarm_profused inc_farm inc_harvest inc_farmassets {
		replace `var' = 0 if `var' == .
		rename `var' `var'_2007
	}
	
	rename hhid07 hhid_2007
	save "$secdata/IFLS/b2_premerge.dta", replace

end
