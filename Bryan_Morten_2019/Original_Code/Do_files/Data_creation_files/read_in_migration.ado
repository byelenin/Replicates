program read_in_migration

	/////////////////////////////////////
	//   Read in 2007 migration data   //
	/////////////////////////////////////
	
	// Add in proxy data
	use "$rawdata/IFLS/hh07_bp_dta/bp_mg.dta", clear
	keep hhid07 pid07 pidlink mg01d mg01c
	
	rename hhid07 hhid
	rename pid07 memberid
	rename mg01d prov_birth_p
	rename mg01c regency_birth_p
	
	tempfile mgproxy
	save `mgproxy', replace
	
	// Migration data
	use "$rawdata/IFLS/hh07_b3a_dta/b3a_mg1.dta", clear
	keep hhid07 pid07 pidlink mg01d mg01c //idrt3a
	
	rename hhid07 hhid
	rename pid07 memberid
	rename mg01d prov_birth
	rename mg01c regency_birth
	
	// Merge in proxy data
	merge 1:1 hhid memberid using `mgproxy'
	replace prov_birth = prov_birth_p if prov_birth==.
	replace regency_birth = regency_birth_p if prov_birth==.
	drop prov_birth_p regency_birth_p _merge
	
	// Adjust to SUPAS 1995 Regencies
	replace regency_birth = 100*prov_birth + regency_birth
	rename regency_birth susenas11_rgcy_code
	merge m:1 susenas11_rgcy_code using "$secdata/compiled/susenas11_to_supas95_rgcy_key"
	// Keep valid regencies that are missing from key
	replace supas95_rgcy_code = 7319 if susenas11_rgcy_code == 7319
	replace supas95_rgcy_code = 7320 if susenas11_rgcy_code == 7320
	replace supas95_rgcy_code = 7321 if susenas11_rgcy_code == 7321
	replace _merge = 3 if inlist(susenas11_rgcy_code, 7319, 7320, 7321)
	drop if _merge == 2
	drop if _merge == 1 & prov_birth == . & susenas11_rgcy_code == .
	* For _merge == 1, mostly missing and unknown (98 or 99) birth regencies. The remaining are from province 94 (Papua, which we drop anyway) and province 73
	drop susenas11_rgcy_code _merge
	rename supas95_rgcy_code regency_birth	
	
	// Adjust to SUPAS 1995 Provinces
	replace prov_birth = 16 if inlist(prov_birth, 19)
	replace prov_birth = 32 if inlist(prov_birth, 36)
	replace prov_birth = . if inlist(prov_birth, 98, 99)
	
	sort pidlink hhid
	by pidlink: drop if _n != _N
	save "$secdata/IFLS/b3a_mg_premerge_2007.dta", replace
	
	/////////////////////////////////////
	//   Read in 2000 migration data   //
	/////////////////////////////////////
	
	// Add in proxy data
	use "$rawdata/IFLS/hh00_b3p_dta/b3p_mg.dta", clear
	keep hhid00 pid00 pidlink mg01d mg01c
	
	rename hhid00 hhid
	rename pid00 memberid
	rename mg01d prov_birth_p
	rename mg01c regency_birth_p
	
	save `mgproxy', replace
	
	// Migration data
	use "$rawdata/IFLS/hh00_b3a_dta/b3a_mg1.dta", clear
	keep hhid00 pid00 pidlink mg01d mg01c
	
	rename hhid00 hhid
	rename pid00 memberid
	rename mg01d prov_birth_2000
	rename mg01c regency_birth_2000
	order hhid, b(memberid)
	
	// Merge in proxy data
	merge 1:1 hhid memberid using `mgproxy'
	replace prov_birth_2000 = prov_birth_p if prov_birth_2000==.
	replace regency_birth_2000 = regency_birth_p if regency_birth_2000==.
	drop prov_birth_p regency_birth_p _merge
	
	// Adjust to SUPAS 1995 Regencies
	replace regency_birth_2000 = 100*prov_birth_2000 + regency_birth_2000
	rename regency_birth_2000 susenas11_rgcy_code
	merge m:1 susenas11_rgcy_code using "$secdata/compiled/susenas11_to_supas95_rgcy_key"
	// Keep valid regencies that are missing from key
	replace supas95_rgcy_code = 3218 if susenas11_rgcy_code == 3218
	replace supas95_rgcy_code = 3219 if susenas11_rgcy_code == 3219
	replace supas95_rgcy_code = 3220 if susenas11_rgcy_code == 3220
	replace supas95_rgcy_code = 7319 if susenas11_rgcy_code == 7319
	replace supas95_rgcy_code = 7320 if susenas11_rgcy_code == 7320
	replace _merge = 3 if inlist(susenas11_rgcy_code, 3218, 3219, 3220, 7319, 7320)
	drop if _merge == 2 
	drop if _merge == 1 & prov_birth == . & susenas11_rgcy_code == .
	* For _merge == 1, mostly unknown (98 or 99) birth regencies. The remaining are from province 54 (East Timor, which we drop anyway) and province 73
	drop susenas11_rgcy_code _merge
	rename supas95_rgcy_code regency_birth_2000
	
	// Adjust to SUPAS 1995 Provinces
	replace prov_birth_2000 = 81 if inlist(prov_birth_2000, 82)
	replace prov_birth_2000 = . if inlist(prov_birth_2000, 98, 99, 54)
	
	sort pidlink hhid
	by pidlink: drop if _n != _N
	save "$secdata/IFLS/b3a_mg_premerge_2000.dta", replace

	/////////////////////////////////////
	//   Read in 1997 migration data   //
	/////////////////////////////////////
	* Note: No adult proxy data here
	
	use "$rawdata/IFLS/hh97_b3_dta/b3a_mg1.dta", clear
	keep hhid97 pid97 pidlink mg01d mg01c
	
	rename hhid97 hhid
	rename pid97 memberid
	rename mg01d prov_birth_1997
	rename mg01c regency_birth_1997
	order hhid, b(memberid)
	
	// Adjust to SUPAS 1995 Regencies
	replace regency_birth_1997 = 100*prov_birth_1997 + regency_birth_1997
	rename regency_birth_1997 susenas11_rgcy_code
	merge m:1 susenas11_rgcy_code using "$secdata/compiled/susenas11_to_supas95_rgcy_key"
	// Keep valid regencies that are missing from key
	replace supas95_rgcy_code = 3218 if susenas11_rgcy_code == 3218
	replace supas95_rgcy_code = 3219 if susenas11_rgcy_code == 3219
	replace supas95_rgcy_code = 3220 if susenas11_rgcy_code == 3220
	replace supas95_rgcy_code = 7319 if susenas11_rgcy_code == 7319
	replace supas95_rgcy_code = 8104 if susenas11_rgcy_code == 8209 // I think, but not sure (1 obs only)
	replace _merge = 3 if inlist(susenas11_rgcy_code, 3218, 3219, 3220, 7319, 8209)
	drop if _merge == 2
	drop if _merge == 1 & prov_birth == . & susenas11_rgcy_code == .
	drop susenas11_rgcy_code _merge
	rename supas95_rgcy_code regency_birth_1997
	
	// Adjust to SUPAS 1995 Provinces
	replace prov_birth_1997 = 81 if inlist(prov_birth_1997, 82)
	replace prov_birth_1997 = . if inlist(prov_birth_1997, 10)
	
	sort pidlink hhid
	by pidlink: drop if _n != _N
	save "$secdata/IFLS/b3a_mg_premerge_1997.dta", replace
	
	/////////////////////////////////////
	//   Read in 1993 migration data   //
	/////////////////////////////////////
	* Note: No adult proxy data here
	
	use "$rawdata/IFLS/hh93_dta/buk3mg1.dta", clear
	keep hhid93 pid93 pidlink mg01d2 mg01c2
	
	rename hhid93 hhid
	rename pid93 memberid
	rename mg01d2 prov_birth_1993
	rename mg01c2 regency_birth_1993
	order hhid, b(memberid)

	replace prov_birth_1993 = . if prov_birth_1993 >= 96 | prov_birth_1993 == 3
	replace regency_birth_1993 = . if regency_birth_1993 >= 80
	
	// Adjust to SUPAS 1995 Regencies
	replace regency_birth_1993 = 100*prov_birth_1993 + regency_birth_1993
	rename regency_birth_1993 susenas11_rgcy_code
	merge m:1 susenas11_rgcy_code using "$secdata/compiled/susenas11_to_supas95_rgcy_key"
	// Keep valid regencies that are missing from key
	replace supas95_rgcy_code = 3218 if susenas11_rgcy_code == 3218
	replace supas95_rgcy_code = 3219 if susenas11_rgcy_code == 3219
	replace supas95_rgcy_code = 3220 if susenas11_rgcy_code == 3220
	replace supas95_rgcy_code = 7319 if susenas11_rgcy_code == 7319
	replace supas95_rgcy_code = 7320 if susenas11_rgcy_code == 7320
	replace _merge = 3 if inlist(susenas11_rgcy_code, 3218, 3219, 3220, 7319, 7320)
	* Can't match regencies 1240, 1315, 1320, 1612, 1640, 1870, 3123, 3222, 5109, 5174, 5220, 7118 to a SUPAS 1995 regency (21 obs)
	drop if _merge == 2
	drop if _merge == 1 & prov_birth == . & susenas11_rgcy_code == .
	drop susenas11_rgcy_code _merge
	rename supas95_rgcy_code regency_birth_1993
	
	// Adjust to SUPAS 1995 Provinces
	replace prov_birth_1993 = 81 if inlist(prov_birth_1993, 82)
	replace prov_birth_1993 = . if inlist(prov_birth_1993, 98, 99, 180, 512, 531, 532, 533, 534, 563, 996, 998, 999, 3, 28, 36, 96)
	
	sort pidlink hhid
	by pidlink: drop if _n != _N
	save "$secdata/IFLS/b3a_mg_premerge_1993.dta", replace

	/////////////////////////
	//   Merge all years   //
	/////////////////////////
	
	use "$secdata/IFLS/b3a_mg_premerge_2007.dta", clear
	
	// Merge in 2000 migration data
	sort pidlink
	merge 1:1 pidlink using "$secdata/IFLS/b3a_mg_premerge_2000.dta"
	*drop if _merge == 2
	drop _merge
	replace prov_birth = prov_birth_2000 if prov_birth == .
	replace regency_birth = regency_birth_2000 if regency_birth == .
	drop prov_birth_2000 regency_birth_2000
	
	// Merge in 1997 migration data
	sort pidlink
	merge 1:1 pidlink using "$secdata/IFLS/b3a_mg_premerge_1997.dta"
	*drop if _merge == 2
	drop _merge
	replace prov_birth = prov_birth_1997 if prov_birth == .
	replace regency_birth = regency_birth_1997 if regency_birth == .
	drop prov_birth_1997 regency_birth_1997
	// 789 where birthplace != birthplace_1997 (but we keep 2007 birthplace info)
	
	// Merge in 1993 migration data
	sort pidlink
	merge 1:1 pidlink using "$secdata/IFLS/b3a_mg_premerge_1993.dta"
	*drop if _merge == 2
	drop _merge
	replace prov_birth = prov_birth_1993 if prov_birth == .
	replace regency_birth = regency_birth_1993 if regency_birth == .
	drop prov_birth_1993 regency_birth_1993
	// 2088 where birthplace != birthplace_1993 (but we keep 2007 birthplace info)
	
	save "$secdata/IFLS/b3a_mg_premerge.dta", replace
	
end
