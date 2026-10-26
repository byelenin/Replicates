* Version 1: March 21, 2014 (Allan Hsiao)

program susenas11_adjust_regions
	
	// Create key for each regency variable
	foreach rgcy in current birth five_yrs {
		use "$secdata/Compiled/susenas11_to_supas95_rgcy_key", clear
		rename susenas11_rgcy_code `rgcy'_rgcy
		save "$secdata/Compiled/susenas11_to_supas95_rgcy_key_`rgcy'", replace
	}
	
	// Convert all regency variables to SUPAS 1995 regencies
	use "$secdata/Compiled/susenas_2011_2012", clear
	
	replace b5_tl2 = . if b5_tl2 == 0
	gen birth_rgcy = 100 * b5_tl1 + b5_tl2
	
	replace b5_tt1 = . if b5_tt1 == 0
	replace b5_tt2 = . if b5_tt2 == 0
	gen five_yrs_rgcy = 100 * b5_tt1 + b5_tt2
	
	rename kabu current_rgcy
	rename umur age
	
	foreach rgcy in current birth five_yrs {

		di in red "rgcy is `rgcy'"
		merge m:1 `rgcy'_rgcy using "$secdata/Compiled/susenas11_to_supas95_rgcy_key_`rgcy'"
		cap erase "$secdata/Compiled/susenas11_to_supas95_rgcy_key_`rgcy'.dta"
		
		drop if _merge != 3
		drop _merge
		
		replace `rgcy'_rgcy = supas95_rgcy_code
		drop supas95_rgcy_code
	}
	
	save "$secdata/Compiled/susenas_2011_2012_premade", replace
	
	
	// Confirm that all updated regencies are consistent with SUPAS 1995 regencies
	foreach rgcy in current birth five_yrs {
		use "$secdata/Compiled/susenas_2011_2012_premade", clear
		collapse age, by(`rgcy'_rgcy)
		rename `rgcy'_rgcy supas95_rgcy_code
		save "$secdata/Compiled/susenas_`rgcy'_regencies", replace
		use "$secdata/Compiled/supas_1995_regencies", clear
		merge 1:1 supas95_rgcy_code using "$secdata/Compiled/susenas_`rgcy'_regencies"
		assert _merge != 2
		cap erase "$secdata/Compiled/susenas_`rgcy'_regencies.dta"
	}
	
end
