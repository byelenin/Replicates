program read_in_roster

	/////////////////////////////
	//   Roster data: IFLS 4   //
	/////////////////////////////
	
	use "$rawdata/IFLS/hh07_bk_dta/bk_sc.dta", clear
	* keep hhid07 sc05 hhid07 sc010707 sc020707 sc030707 sc21 //hhid07_9
	keep hhid07 sc05 sc010707 sc020707 
	 
	rename hhid07 hhid_2007
	rename sc05 rural_2007
	rename sc010707 prov_2007
	rename sc020707 regency_2007
	
	// Adjust to SUPAS 1995 Regencies
	replace regency_2007 = 100*prov_2007 + regency_2007
	rename regency_2007 susenas11_rgcy_code
	merge m:1 susenas11_rgcy_code using "$secdata/compiled/susenas11_to_supas95_rgcy_key"
	drop if _merge != 3
	drop susenas11_rgcy_code _merge
	rename supas95_rgcy_code regency_2007
	
	// Adjust to SUPAS 1995 Provinces
	* Need to correct provinces after regencies because we use prov_2007 to calculate regency_2007 above
	replace prov_2007 = 16 if inlist(prov_2007, 19)
	replace prov_2007 = 14 if inlist(prov_2007, 21)
	replace prov_2007 = 32 if inlist(prov_2007, 36)
	replace prov_2007 = 73 if inlist(prov_2007, 76)
	
	sort hhid_2007
	tempfile bktemp_2007
	save `bktemp_2007', replace
	
	// Demographics data
	use "$rawdata/IFLS/hh07_bk_dta/bk_ar1.dta", clear
	keep hhid07 ar00 pidlink ar02b ar07 ar09 ar15b ar15d ar16 ar17 //ar02 ar15a ar15c
	
	rename hhid07 hhid_2007
	rename ar00 memberid_2007
	rename ar02b hoh_relation_2007
	rename ar07 sex_2007
	rename ar09 age_2007
	*rename ar15a work_last_year_2007
	rename ar15b wage_year_2007
	*rename ar15c activity_last_week_2007
	rename ar15d ethnic_group_2007
	rename ar16 educ_attain_2007
	rename ar17 educ_completed_2007
	
	sort hhid_2007 memberid_2007
	merge m:1 hhid using `bktemp_2007'
	drop _merge
	order hhid_2007 memberid_2007 sex_2007 age_2007
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_2007
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/bk_premerge_2007.dta", replace

	/////////////////////////////
	//   Roster data: IFLS 3   //
	/////////////////////////////
	
	use "$rawdata/IFLS/hh00_bk_dta/bk_sc.dta", clear
	keep hhid00 sc05 sc01 sc02
	 
	rename hhid00 hhid_2000
	rename sc05 rural_2000
	rename sc01 prov_2000
	rename sc02 regency_2000
	
	// Adjust to SUPAS 1995 Regencies
	replace regency_2000 = 100*prov_2000 + regency_2000
	rename regency_2000 susenas11_rgcy_code
	merge m:1 susenas11_rgcy_code using "$secdata/compiled/susenas11_to_supas95_rgcy_key"
	// Keep valid regencies that are missing from key
	replace supas95_rgcy_code = 1403 if susenas11_rgcy_code == 1411
	replace supas95_rgcy_code = 1472 if susenas11_rgcy_code == 1472
	replace supas95_rgcy_code = 3218 if susenas11_rgcy_code == 3218
	replace supas95_rgcy_code = 3219 if susenas11_rgcy_code == 3219
	replace supas95_rgcy_code = 3220 if susenas11_rgcy_code == 3220
	replace supas95_rgcy_code = 7319 if susenas11_rgcy_code == 7319
	replace supas95_rgcy_code = 7321 if susenas11_rgcy_code == 7321
	replace _merge = 3 if inlist(susenas11_rgcy_code, 1411, 1472, 3218, 3219, 3220, 7319, 7321)
	drop if _merge == 2 
	drop susenas11_rgcy_code _merge
	rename supas95_rgcy_code regency_2000

	sort hhid_2000
	tempfile bktemp_2000
	save `bktemp_2000', replace
	
	// Demographics data
	use "$rawdata/IFLS/hh00_bk_dta/bk_ar1.dta", clear
	keep hhid00 ar00a pidlink ar02b ar07 ar09 ar15b ar16 ar17
	
	rename hhid00 hhid_2000
	rename ar00a memberid_2000
	rename ar02b hoh_relation_2000
	rename ar07 sex_2000
	rename ar09 age_2000
	rename ar15b wage_year_2000
	rename ar16 educ_attain_2000
	rename ar17 educ_completed_2000
	
	sort hhid_2000 memberid_2000
	merge m:1 hhid using `bktemp_2000'
	drop _merge
	order hhid_2000 memberid_2000 sex_2000 age_2000
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_2000
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/bk_premerge_2000.dta", replace	
	
	/////////////////////////////
	//   Roster data: IFLS 2   //
	/////////////////////////////
	
	use "$rawdata/IFLS/hh97_bk_dta/bk_sc.dta", clear
	keep hhid97 sc05 sc01 sc02
	 
	rename hhid97 hhid_1997
	rename sc05 rural_1997
	rename sc01 prov_1997
	rename sc02 regency_1997
	
	// Adjust to SUPAS 1995 Regencies
	replace regency_1997 = 100*prov_1997 + regency_1997
	rename regency_1997 susenas11_rgcy_code
	merge m:1 susenas11_rgcy_code using "$secdata/compiled/susenas11_to_supas95_rgcy_key"
	// Keep valid regencies that are missing from key
	replace supas95_rgcy_code = 3218 if susenas11_rgcy_code == 3218
	replace supas95_rgcy_code = 3219 if susenas11_rgcy_code == 3219
	replace supas95_rgcy_code = 3220 if susenas11_rgcy_code == 3220
	replace supas95_rgcy_code = 7319 if susenas11_rgcy_code == 7319
	replace supas95_rgcy_code = 7321 if susenas11_rgcy_code == 7321
	replace _merge = 3 if inlist(susenas11_rgcy_code, 3218, 3219, 3220, 7319, 7321)
	drop if _merge == 2 
	drop susenas11_rgcy_code _merge
	rename supas95_rgcy_code regency_1997

	sort hhid_1997
	tempfile bktemp_1997
	save `bktemp_1997', replace
	
	// Demographics data
	use "$rawdata/IFLS/hh97_bk_dta/bk_ar1.dta", clear
	keep hhid97 pid97 pidlink ar02b ar07 ar09 ar15b ar16 ar17
	
	rename hhid97 hhid_1997
	rename pid97 memberid_1997
	rename ar02b hoh_relation_1997
	rename ar07 sex_1997
	rename ar09 age_1997
	rename ar15b wage_year_1997
	rename ar16 educ_attain_1997
	rename ar17 educ_completed_1997
	
	sort hhid_1997 memberid_1997
	merge m:1 hhid using `bktemp_1997'
	drop _merge
	order hhid_1997 memberid_1997 sex_1997 age_1997
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_1997
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/bk_premerge_1997.dta", replace	

	/////////////////////////////
	//   Roster data: IFLS 1   //
	/////////////////////////////
	
	use "$rawdata/IFLS/hh93_bk_dta/bukksc1.dta", clear
	keep hhid93 sc05 sc01 sc02
	 
	rename hhid93 hhid_1993
	rename sc05 rural_1993
	rename sc01 prov_1993
	rename sc02 regency_1993
	
	// Adjust to SUPAS 1995 Regencies
	replace regency_1993 = 100*prov_1993 + regency_1993
	rename regency_1993 susenas11_rgcy_code
	merge m:1 susenas11_rgcy_code using "$secdata/compiled/susenas11_to_supas95_rgcy_key"

	// Keep valid regencies that are missing from key
	replace supas95_rgcy_code = 3218 if susenas11_rgcy_code == 3218
	replace supas95_rgcy_code = 3219 if susenas11_rgcy_code == 3219
	replace supas95_rgcy_code = 3220 if susenas11_rgcy_code == 3220
	replace supas95_rgcy_code = 7319 if susenas11_rgcy_code == 7319
	replace _merge = 3 if inlist(susenas11_rgcy_code, 3218, 3219, 3220, 7319)
	drop if _merge == 2 
	drop susenas11_rgcy_code _merge
	rename supas95_rgcy_code regency_1993

	sort hhid_1993
	tempfile bktemp_1993
	save `bktemp_1993', replace
	
	// Demographics data
	use "$rawdata/IFLS/hh93_bk_dta/bukkar2.dta", clear
	keep hhid93 pid93 pidlink ar02 ar07 ar09yr /*ar15b*/ ar16 ar17
	
	rename hhid93 hhid_1993
	rename pid93 memberid_1993
	rename ar02 hoh_relation_1993
	rename ar07 sex_1993
	rename ar09yr age_1993
	*rename ar15b wage_year_1993
	rename ar16 educ_attain_1993
	rename ar17 educ_completed_1993
	
	sort hhid_1993 memberid_1993
	merge m:1 hhid using `bktemp_1993'
	drop _merge
	order hhid_1993 memberid_1993 sex_1993 age_1993
	* Keeping only most up-to-date pidlink where multiple
	sort pidlink hhid_1993
	by pidlink: drop if _n != _N
	
	save "$secdata/IFLS/bk_premerge_1993.dta", replace	
	
	////////////////////////
	//   Merge All Data   //
	////////////////////////
	
	use "$secdata/IFLS/bk_premerge_2007.dta", clear
	merge 1:1 pidlink using "$secdata/IFLS/bk_premerge_2000.dta"
	drop _merge
	merge 1:1 pidlink using "$secdata/IFLS/bk_premerge_1997.dta"
	drop _merge
	merge 1:1 pidlink using "$secdata/IFLS/bk_premerge_1993.dta"
	drop _merge
	order pidlink, b(hhid_2007)
	
	save "$secdata/IFLS/bk_premerge.dta", replace	
	
end

