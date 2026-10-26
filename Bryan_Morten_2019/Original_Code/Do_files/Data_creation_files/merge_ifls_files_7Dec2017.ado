program merge_ifls_files_7Dec2017

	* Version 1: December 22, 2013 (Allan Hsiao)
* Version 2: August 3, 2014 (Allan Hsiao)
* 12/7/2017: merging on the rent/potential rent variable (at the hh level)


	
	/////////////////////////
	//   Merge data   //
	/////////////////////////	

	use "$secdata/IFLS/b3a_tk_premerge.dta", clear
	
	// Merge roster and employment data
	sort pidlink
	merge 1:1 pidlink using "$secdata/IFLS/bk_premerge.dta"
	drop _merge
	
	// Merge in weights data
	sort pidlink
	merge 1:1 pidlink using "$secdata/IFLS/trk_premerge.dta"
	drop _merge
	
	// Merge in literacy data
	sort pidlink
	merge 1:1 pidlink using "$secdata/IFLS/b3a_dl_premerge.dta"
	drop _merge
	
	// Merge in migration data
	sort pidlink
	merge 1:1 pidlink using "$secdata/IFLS/b3a_mg_premerge.dta"
	drop _merge
	
	// Merge in household enterprise data (2007 only)
	sort hhid_2007
	merge m:1 hhid_2007 using "$secdata/IFLS/b2_premerge.dta"
	drop _merge

	// Merge in rents data, do this year-by-year at the hhid level
	foreach year in 1993 1997 2000 2007 {
		preserve

		use $secdata/Compiled/IFLS_rent, clear
		keep if year == `year'
		drop if hhid_`year' == ""
		keep hhid_`year' *rent*
		foreach var of varlist *rent* {
			rename `var' `var'_`year'
			}
		tempfile temp
		save `temp', replace

		restore
		merge m:1 hhid_`year' using `temp'
		drop if _merge == 2
		drop _merge
		}
	
		
	//////////////
	//   SAVE   //
	//////////////
	
	drop memberid*
	
	save "$secdata/IFLS/ifls_2007", replace

end

