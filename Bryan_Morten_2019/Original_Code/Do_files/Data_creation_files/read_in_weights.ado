program read_in_weights

	////////////////////////////////////
	//   Read in weights data: 2007   //
	////////////////////////////////////
	
	use "$rawdata/IFLS/hh07_trk_dta/ptrack.dta", clear
	keep hhid07 pid07 pidlink pwt07xa
		
	rename hhid07 hhid_2007
	rename pid07 memberid_2007
	rename pwt07xa sample_wt_2007
	
	sort hhid_2007 memberid_2007
	drop if hhid_2007=="" & memberid_2007==.
	save "$secdata/IFLS/trk_premerge_2007.dta", replace

	////////////////////////////////////
	//   Read in weights data: 2000   //
	////////////////////////////////////
	
	use "$rawdata/IFLS/hh00_trk_dta/ptrack.dta", clear
	keep hhid00 pid00 pidlink pwt00xa
		
	rename hhid00 hhid_2000
	rename pid00 memberid_2000
	rename pwt00xa sample_wt_2000
	
	sort hhid_2000 memberid_2000
	drop if hhid_2000=="" & memberid_2000==.
	save "$secdata/IFLS/trk_premerge_2000.dta", replace

	////////////////////////////////////
	//   Read in weights data: 1997   //
	////////////////////////////////////
	
	use "$rawdata/IFLS/hh97_trk_dta/ptrack.dta", clear
	keep hhid97 pid97 pidlink pwt97x
		
	rename hhid97 hhid_1997
	rename pid97 memberid_1997
	rename pwt97x sample_wt_1997
	
	sort hhid_1997 memberid_1997
	drop if hhid_1997=="" & memberid_1997==.
	save "$secdata/IFLS/trk_premerge_1997.dta", replace	
	
	////////////////////////////////////
	//   Read in weights data: 1993   //
	////////////////////////////////////
	
	use "$rawdata/IFLS/hh93_trk_dta/indivwt.dta", clear
	keep hhid93 pid93 pidlink respwt
		
	rename hhid93 hhid_1993
	rename pid93 memberid_1993
	rename respwt sample_wt_1993
	
	sort hhid_1993 memberid_1993
	drop if hhid_1993=="" & memberid_1993==.
	save "$secdata/IFLS/trk_premerge_1993.dta", replace

	////////////////////////
	//   Merge All Data   //
	////////////////////////
	
	use "$secdata/IFLS/trk_premerge_2007.dta", clear
	merge 1:1 pidlink using "$secdata/IFLS/trk_premerge_2000.dta"
	drop _merge
	merge 1:1 pidlink using "$secdata/IFLS/trk_premerge_1997.dta"
	drop _merge
	merge 1:1 pidlink using "$secdata/IFLS/trk_premerge_1993.dta"
	drop _merge
	order pidlink, b(hhid_2007)
	
	save "$secdata/IFLS/trk_premerge.dta", replace	
	
end
