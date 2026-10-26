program read_in_literacy

	/////////////////////////////////////
	//   Read in literacy data: 2007   //
	/////////////////////////////////////
	
	// Add in proxy data
	use "$rawdata/IFLS/hh07_bp_dta/bp_dl1.dta", clear
	keep hhid07 pid07 pidlink dl02 //dl06 dl07
	
	rename hhid07 hhid_2007
	rename pid07 memberid_2007
	rename dl02 literacy_p_2007
	*rename dl06 educ_attain_p // doesn't add anything
	*rename dl07 educ_completed_p // doesn't add anything
	
	tempfile dlproxy_2007
	save `dlproxy_2007', replace
	
	// Literacy data
	use "$rawdata/IFLS/hh07_b3a_dta/b3a_dl1.dta", clear
	keep hhid07 pid07 pidlink dl02
		
	rename hhid07 hhid_2007
	rename pid07 memberid_2007
	rename dl02 literacy_2007
	
	// Merge in proxy data
	merge 1:1 hhid_2007 memberid_2007 using `dlproxy_2007'
	replace literacy_2007 = literacy_p_2007 if literacy_2007==.
	drop literacy_p_2007 _merge
	
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_2007
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/b3a_dl_premerge_2007.dta", replace	

	/////////////////////////////////////
	//   Read in literacy data: 2000   //
	/////////////////////////////////////
	
	// Add in proxy data
	use "$rawdata/IFLS/hh00_b3p_dta/b3p_dl1.dta", clear
	keep hhid00 pid00 pidlink dl02
	
	rename hhid00 hhid_2000
	rename pid00 memberid_2000
	rename dl02 literacy_p_2000
	
	tempfile dlproxy_2000
	save `dlproxy_2000', replace
	
	// Literacy data
	use "$rawdata/IFLS/hh00_b3a_dta/b3a_dl1.dta", clear
	keep hhid00 pid00 pidlink dl02
		
	rename hhid00 hhid_2000
	rename pid00 memberid_2000
	rename dl02 literacy_2000
	
	// Merge in proxy data
	merge 1:1 hhid_2000 memberid_2000 using `dlproxy_2000'
	replace literacy_2000 = literacy_p_2000 if literacy_2000==.
	drop literacy_p_2000 _merge
	
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_2000
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/b3a_dl_premerge_2000.dta", replace	

	/////////////////////////////////////
	//   Read in literacy data: 1997   //
	/////////////////////////////////////
	* Note: No adult proxy data here
	
	// Literacy data
	use "$rawdata/IFLS/hh97_b3_dta/b3a_dl1.dta", clear
	keep hhid97 pid97 pidlink dl02
		
	rename hhid97 hhid_1997
	rename pid97 memberid_1997
	rename dl02 literacy_1997
	
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_1997
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/b3a_dl_premerge_1997.dta", replace	
	
	/////////////////////////////////////
	//   Read in literacy data: 1993   //
	/////////////////////////////////////
	* Note: No adult proxy data here
	
	// Literacy data
	use "$rawdata/IFLS/hh93_dta/buk3dl1.dta", clear
	keep hhid93 pid93 pidlink dl02
		
	rename hhid93 hhid_1993
	rename pid93 memberid_1993
	rename dl02 literacy_1993
	
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_1993
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/b3a_dl_premerge_1993.dta", replace
	
	////////////////////////
	//   Merge All Data   //
	////////////////////////
	
	use "$secdata/IFLS/b3a_dl_premerge_2007.dta", clear
	merge 1:1 pidlink using "$secdata/IFLS/b3a_dl_premerge_2000.dta"
	drop _merge
	merge 1:1 pidlink using "$secdata/IFLS/b3a_dl_premerge_1997.dta"
	drop _merge
	merge 1:1 pidlink using "$secdata/IFLS/b3a_dl_premerge_1993.dta"
	drop _merge
	
	order hhid_2007, b(memberid_2007)
	order pidlink, b(hhid_2007)
	
	save "$secdata/IFLS/b3a_dl_premerge.dta", replace	
	
end
