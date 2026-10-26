program read_in_employment_10Aug2016

	
	///////////////////////////////////////
	//   Read in employment data: 2007   //
	///////////////////////////////////////
	
	use "$rawdata/IFLS/hh07_bp_dta/bp_tk2.dta", clear
	merge 1:1 hhid07 pid07 using "$rawdata/IFLS/hh07_bp_dta/bp_tk1.dta"
	drop _merge 
	
	keep hhid07 pid07 pidlink tk21a tk21b tk22a tk22b tk23a tk23b ///
		 tk24a tk24b tk25a1 tk25b1 tk25a2 tk25b2 tk26a1 tk26b1 tk26a3 tk26b3
	
	rename hhid07 hhid_2007
	rename pid07 memberid_2007
	rename tk21a hours_lastweek_1_p_2007
	rename tk21b hours_lastweek_2_p_2007
	rename tk22a hours_usualweek_1_p_2007	
	rename tk22b hours_usualweek_2_p_2007
	rename tk23a weeks_year_1_p_2007
	rename tk23b weeks_year_2_p_2007
	rename tk24a empl_status_1_p_2007
	rename tk24b empl_status_2_p_2007
	rename tk25a1 wage_lastmonth_1_p_2007
	rename tk25b1 wage_lastmonth_2_p_2007
	rename tk25a2 wage_lastyear_1_p_2007
	rename tk25b2 wage_lastyear_2_p_2007
	rename tk26a1 netprofit_lastmonth_1_p_2007
	rename tk26b1 netprofit_lastmonth_2_p_2007
	rename tk26a3 netprofit_lastyear_1_p_2007
	rename tk26b3 netprofit_lastyear_2_p_2007

	
	tempfile tkproxy_2007
	save `tkproxy_2007', replace
	
	// Employment data
	
	use "$rawdata/IFLS/hh07_b3a_dta/b3a_tk2.dta", clear
	keep hhid07 pid07 pidlink tk21a tk21b tk22a tk22b tk23a tk23b ///
		 tk24a tk24b tk25a1 tk25b1 tk25a2 tk25b2 tk26a1 tk26b1 tk26a3 tk26b3
	
	rename hhid07 hhid_2007
	rename pid07 memberid_2007
	rename tk21a hours_lastweek_1_2007
	rename tk21b hours_lastweek_2_2007
	rename tk22a hours_usualweek_1_2007	
	rename tk22b hours_usualweek_2_2007
	rename tk23a weeks_year_1_2007
	rename tk23b weeks_year_2_2007
	rename tk24a empl_status_1_2007
	rename tk24b empl_status_2_2007
	rename tk25a1 wage_lastmonth_1_2007
	rename tk25b1 wage_lastmonth_2_2007
	rename tk25a2 wage_lastyear_1_2007
	rename tk25b2 wage_lastyear_2_2007
	rename tk26a1 netprofit_lastmonth_1_2007
	rename tk26b1 netprofit_lastmonth_2_2007
	rename tk26a3 netprofit_lastyear_1_2007
	rename tk26b3 netprofit_lastyear_2_2007
	
	// Merge in proxy data
	merge 1:1 hhid_2007 memberid_2007 using `tkproxy_2007'
	
	replace hours_lastweek_1_2007 = hours_lastweek_1_p_2007 if hours_lastweek_1_2007==.
	replace hours_lastweek_2_2007 = hours_lastweek_2_p_2007 if hours_lastweek_2_2007==.
	replace hours_usualweek_1_2007 = hours_usualweek_1_p_2007 if hours_usualweek_1_2007==.
	replace hours_usualweek_2_2007 = hours_usualweek_2_p_2007 if hours_usualweek_2_2007==.
	replace weeks_year_1_2007 = weeks_year_1_p_2007 if weeks_year_1_2007==.
	replace weeks_year_2_2007 = weeks_year_2_p_2007 if weeks_year_2_2007==.
	replace empl_status_1_2007 = empl_status_1_p_2007 if empl_status_1_2007==.
	replace empl_status_2_2007 = empl_status_2_p_2007 if empl_status_2_2007==.
	replace wage_lastmonth_1_2007 = wage_lastmonth_1_p_2007 if wage_lastmonth_1_2007==.
	replace wage_lastmonth_2_2007 = wage_lastmonth_2_p_2007 if wage_lastmonth_2_2007==.
	replace wage_lastyear_1_2007 = wage_lastyear_1_p_2007 if wage_lastyear_1_2007==.
	replace wage_lastyear_2_2007 = wage_lastyear_2_p_2007 if wage_lastyear_2_2007==.
	replace netprofit_lastmonth_1_2007 = netprofit_lastmonth_1_p_2007 if netprofit_lastmonth_1_2007==.
	replace netprofit_lastmonth_2_2007 = netprofit_lastmonth_2_p_2007 if netprofit_lastmonth_2_2007==.
	replace netprofit_lastyear_1_2007 = netprofit_lastyear_1_p_2007 if netprofit_lastyear_1_2007==.
	*replace netprofit_lastyear_2_2007 = netprofit_lastyear_2_p_2007 if netprofit_lastyear_2_2007==. // No values here
	
	drop *_p_2007 _merge

	
	// MM: fixing miscoded vars//
	/*
	replace wage_lastmonth_1 = .a if wage_lastmonth_1 >= 99999
	replace wage_lastmonth_2 = .a if wage_lastmonth_1 >= 99999
	replace netprofit_lastmonth_1 = .a if wage_lastmonth_1 >= 99999
	replace netprofit_lastmonth_2 = .a if wage_lastmonth_1 >= 99999
*/
	
	sum wage_last* netprofit_last*

	sort hhid_2007 memberid_2007
	tempfile tktemp_2007
	save `tktemp_2007', replace
	
	// Add in occupation data (no proxy he re)
	use "$rawdata/IFLS/hh07_b3a_dta/b3a_tk3.dta", clear
	keep hhid07 pid07 pidlink tk28year occ2007 //hhid07_9
	
	// Keep only 2007 occupation data
	keep if tk28year == 2007
	drop tk28year
	
	rename hhid07 hhid_2007
	rename pid07 memberid_2007
	rename occ2007 occupation_2007
	
	sort hhid_2007 memberid_2007
	merge m:1 hhid_2007 memberid_2007 using `tktemp_2007'
	drop _merge
	
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_2007
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/b3a_tk_premerge_2007.dta", replace
	
	///////////////////////////////////////
	//   Read in employment data: 2000   //
	///////////////////////////////////////
	
	use "$rawdata/IFLS/hh00_b3p_dta/b3p_tk2.dta", clear
	merge 1:1 hhid00 pid00 using "$rawdata/IFLS/hh00_b3p_dta/b3p_tk1.dta"
	drop _merge 
	
	keep hhid00 pid00 pidlink tk21a tk21b tk22a tk22b tk23a tk23b ///
		 tk24a tk24b tk25a1 tk25b1 tk25a2 tk25b2 tk26a1 tk26b1 
	
	rename hhid00 hhid_2000
	rename pid00 memberid_2000
	rename tk21a hours_lastweek_1_p_2000
	rename tk21b hours_lastweek_2_p_2000
	rename tk22a hours_usualweek_1_p_2000	
	rename tk22b hours_usualweek_2_p_2000
	rename tk23a weeks_year_1_p_2000
	rename tk23b weeks_year_2_p_2000
	rename tk24a empl_status_1_p_2000
	rename tk24b empl_status_2_p_2000
	rename tk25a1 wage_lastmonth_1_p_2000
	rename tk25b1 wage_lastmonth_2_p_2000
	rename tk25a2 wage_lastyear_1_p_2000
	rename tk25b2 wage_lastyear_2_p_2000
	rename tk26a1 netprofit_lastmonth_1_p_2000
	rename tk26b1 netprofit_lastmonth_2_p_2000
		
	tempfile tkproxy_2000
	save `tkproxy_2000', replace
	
	// Employment data
	
	use "$rawdata/IFLS/hh00_b3a_dta/b3a_tk2.dta", clear
	keep hhid00 pid00 pidlink tk21a tk21b tk22a tk22b tk23a tk23b ///
		 tk24a tk24b tk25a1 tk25b1 tk25a2 tk25b2 tk26amn tk26bmn tk26ayn tk26byn
	
	rename hhid00 hhid_2000
	rename pid00 memberid_2000
	rename tk21a hours_lastweek_1_2000
	rename tk21b hours_lastweek_2_2000
	rename tk22a hours_usualweek_1_2000	
	rename tk22b hours_usualweek_2_2000
	rename tk23a weeks_year_1_2000
	rename tk23b weeks_year_2_2000
	rename tk24a empl_status_1_2000
	rename tk24b empl_status_2_2000
	rename tk25a1 wage_lastmonth_1_2000
	rename tk25b1 wage_lastmonth_2_2000
	rename tk25a2 wage_lastyear_1_2000
	rename tk25b2 wage_lastyear_2_2000
	rename tk26amn netprofit_lastmonth_1_2000
	rename tk26bmn netprofit_lastmonth_2_2000
	rename tk26ayn netprofit_lastyear_1_2000
	rename tk26byn netprofit_lastyear_2_2000
	
	// Merge in proxy data
	merge 1:1 hhid_2000 memberid_2000 using `tkproxy_2000'
	
	replace hours_lastweek_1_2000 = hours_lastweek_1_p_2000 if hours_lastweek_1_2000==.
	replace hours_lastweek_2_2000 = hours_lastweek_2_p_2000 if hours_lastweek_2_2000==.
	replace hours_usualweek_1_2000 = hours_usualweek_1_p_2000 if hours_usualweek_1_2000==.
	replace hours_usualweek_2_2000 = hours_usualweek_2_p_2000 if hours_usualweek_2_2000==.
	replace weeks_year_1_2000 = weeks_year_1_p_2000 if weeks_year_1_2000==.
	replace weeks_year_2_2000 = weeks_year_2_p_2000 if weeks_year_2_2000==.
	replace empl_status_1_2000 = empl_status_1_p_2000 if empl_status_1_2000==.
	replace empl_status_2_2000 = empl_status_2_p_2000 if empl_status_2_2000==.
	replace wage_lastmonth_1_2000 = wage_lastmonth_1_p_2000 if wage_lastmonth_1_2000==.
	replace wage_lastmonth_2_2000 = wage_lastmonth_2_p_2000 if wage_lastmonth_2_2000==.
	replace wage_lastyear_1_2000 = wage_lastyear_1_p_2000 if wage_lastyear_1_2000==.
	replace wage_lastyear_2_2000 = wage_lastyear_2_p_2000 if wage_lastyear_2_2000==.
	replace netprofit_lastmonth_1_2000 = netprofit_lastmonth_1_p_2000 if netprofit_lastmonth_1_2000==.
	replace netprofit_lastmonth_2_2000 = netprofit_lastmonth_2_p_2000 if netprofit_lastmonth_2_2000==.
	*replace netprofit_lastyear_1_2000 = netprofit_lastyear_1_p_2000 if netprofit_lastyear_1_2000==. // No values here
	
	drop *_p_2000 _merge

	// MM: fixing miscoded vars//
	/*
	replace wage_lastmonth_1 = .a if wage_lastmonth_1 >= 99999
	replace wage_lastmonth_2 = .a if wage_lastmonth_1 >= 99999
	replace netprofit_lastmonth_1 = .a if wage_lastmonth_1 >= 99999
	replace netprofit_lastmonth_2 = .a if wage_lastmonth_1 >= 99999
*/
	
	sum wage_last* netprofit_last*

	
	sort hhid_2000 memberid_2000
	tempfile tktemp_2000
	save `tktemp_2000', replace
	
	// Add in occupation data (no proxy here)
	use "$rawdata/IFLS/hh00_b3a_dta/b3a_tk3.dta", clear
	keep hhid00 pid00 pidlink tk28yr tk32b 
	
	// Keep only 2000 occupation data
	keep if tk28yr == 1999
	drop tk28yr
	
	rename hhid00 hhid_2000
	rename pid00 memberid_2000
	rename tk32b occupation_2000
	
	sort hhid_2000 memberid_2000
	merge m:1 hhid_2000 memberid_2000 using `tktemp_2000'
	drop _merge
	
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_2000
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/b3a_tk_premerge_2000.dta", replace	

	///////////////////////////////////////
	//   Read in employment data: 1997   //
	///////////////////////////////////////
	* Note: No proxy data here
	
	// Employment data
	
	use "$rawdata/IFLS/hh97_b3_dta/b3a_tk2.dta", clear
	keep hhid97 pid97 pidlink tk21a tk21b tk22a tk22b tk23a tk23b ///
		 tk24a tk24b tk25am tk25bm tk25ay tk25by tk26amn tk26bmn tk26ayn tk26byn
	
	rename hhid97 hhid_1997
	rename pid97 memberid_1997
	rename tk21a hours_lastweek_1_1997
	rename tk21b hours_lastweek_2_1997
	rename tk22a hours_usualweek_1_1997	
	rename tk22b hours_usualweek_2_1997
	rename tk23a weeks_year_1_1997
	rename tk23b weeks_year_2_1997
	rename tk24a empl_status_1_1997
	rename tk24b empl_status_2_1997
	rename tk25am wage_lastmonth_1_1997
	rename tk25bm wage_lastmonth_2_1997
	rename tk25ay wage_lastyear_1_1997
	rename tk25by wage_lastyear_2_1997
	rename tk26amn netprofit_lastmonth_1_1997
	rename tk26bmn netprofit_lastmonth_2_1997
	rename tk26ayn netprofit_lastyear_1_1997
	rename tk26byn netprofit_lastyear_2_1997

	// MM: fixing miscoded vars//
	/*
	replace wage_lastmonth_1 = .a if wage_lastmonth_1 >= 9999999
	replace wage_lastmonth_2 = .a if wage_lastmonth_1 >= 999999
	replace netprofit_lastmonth_1 = .a if wage_lastmonth_1 >= 9999999
	replace netprofit_lastmonth_2 = .a if wage_lastmonth_1 >= 9999999
*/
	sum wage_last* netprofit_last*
	
	sort hhid_1997 memberid_1997
	tempfile tktemp_1997
	save `tktemp_1997', replace
	
	// Add in occupation data
	use "$rawdata/IFLS/hh97_b3_dta/b3a_tk3.dta", clear
	keep hhid97 pid97 pidlink tk28yr tk32occ
	
	// Keep only 1997 occupation data
	keep if tk28yr == 1996
	drop tk28yr
	
	rename hhid97 hhid_1997
	rename pid97 memberid_1997
	rename tk32occ occupation_1997
	
	sort hhid_1997 memberid_1997
	merge m:1 hhid_1997 memberid_1997 using `tktemp_1997'
	drop _merge
	
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_1997
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/b3a_tk_premerge_1997.dta", replace	

	///////////////////////////////////////
	//   Read in employment data: 1993   //
	///////////////////////////////////////
	* Note: No proxy data here
	
	// Employment data
	
	use "$rawdata/IFLS/hh93_dta/buk3tk2.dta", clear
	keep hhid93 pid93 pidlink tk21a tk21b tk22a tk22b tk23a tk23b ///
		 tk24a tk24b tk25r1_m t25br1_m tk25r1_y t25br1_y tk26r1_m t26br1_m tk26r1_y t26br1_y
	
	rename hhid93 hhid_1993
	rename pid93 memberid_1993
	rename tk21a hours_lastweek_1_1993
	rename tk21b hours_lastweek_2_1993
	rename tk22a hours_usualweek_1_1993	
	rename tk22b hours_usualweek_2_1993
	rename tk23a weeks_year_1_1993
	rename tk23b weeks_year_2_1993
	rename tk24a empl_status_1_1993
	rename tk24b empl_status_2_1993
	rename tk25r1_m wage_lastmonth_1_1993
	rename t25br1_m wage_lastmonth_2_1993
	rename tk25r1_y wage_lastyear_1_1993
	rename t25br1_y wage_lastyear_2_1993
	rename tk26r1_m netprofit_lastmonth_1_1993
	rename t26br1_m netprofit_lastmonth_2_1993
	rename tk26r1_y netprofit_lastyear_1_1993
	rename t26br1_y netprofit_lastyear_2_1993


	// MM: adding in some coding for missing vars//
	recode wage_lastmonth_1_1993 (9996/999999 = .a)
	recode wage_lastmonth_2_1993 (9996/999999 = .a)
	recode netprofit_lastmonth_1_1993 (99990/99999 = .a)
	recode netprofit_lastmonth_2_1993 (99990/99999 = .a)
	sum wage_lastmonth*
	
	foreach job in 1 2 {
		foreach time in lastmonth lastyear {
			replace wage_`time'_`job'_1993 = 1000 * wage_`time'_`job'_1993
			replace netprofit_`time'_`job'_1993 = 1000 * netprofit_`time'_`job'_1993
		}
	}

		
	sort hhid_1993 memberid_1993
	tempfile tktemp_1993
	save `tktemp_1993', replace
	
	// Add in occupation data
	use "$rawdata/IFLS/hh93_dta/buk3tk3.dta", clear
	keep hhid93 pid93 pidlink year occ32
	
	// Keep only 1993 occupation data
	keep if year == 92
	drop year
	
	rename hhid93 hhid_1993
	rename pid93 memberid_1993
	rename occ32 occupation_1993
	
	sort hhid_1993 memberid_1993
	merge m:1 hhid_1993 memberid_1993 using `tktemp_1993'
	drop _merge
	
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_1993
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/b3a_tk_premerge_1993.dta", replace	
	
	////////////////////////
	//   Merge All Data   //
	////////////////////////
	
	use "$secdata/IFLS/b3a_tk_premerge_2007.dta", clear
	merge 1:1 pidlink using "$secdata/IFLS/b3a_tk_premerge_2000.dta"
	drop _merge
	merge 1:1 pidlink using "$secdata/IFLS/b3a_tk_premerge_1997.dta"
	drop _merge
	merge 1:1 pidlink using "$secdata/IFLS/b3a_tk_premerge_1993.dta"
	drop _merge
	
	order hhid_2007, b(memberid_2007)
	order pidlink, b(hhid_2007)
	
	save "$secdata/IFLS/b3a_tk_premerge.dta", replace

end
