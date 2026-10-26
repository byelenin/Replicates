program define read_in_rent

	*! This file reads in the rent data
	*! Based off Chris' file
	*! MM, 16/6/2017

	foreach year in 1993 1997 2000 2007 {

		*! We already have created the household roster
		*! This file just saves the rent

		if `year' == 1993 {
			use $rawdata/GB_IFLS/Raw_Data/hh93dta/buk1kr1.dta, clear
			local yearabr 93
			}
		else if `year' == 1997 {
			use "$rawdata/GB_IFLS/Raw_Data/hh97dta/b2_kr.dta", clear
			local yearabr 97
			}
		else if `year' == 2000 {
			use "$rawdata/GB_IFLS/Raw_Data/hh00_all_dta/b2_kr.dta", clear
			local yearabr 00
			}
		else if `year' == 2007 {
			use "$rawdata/GB_IFLS/Raw_Data/hh07_all_dta/b2_kr.dta", clear
			local yearabr 07
			}

		gen year = `year'

		if `year' != 2007 {
			gen actual_rent = kr04
			gen potential_rent = kr05
			}
		else {
			gen actual_rent = kr04a
			gen potential_rent = kr05a
			}

		keep year hhid* actual_rent potential_rent

		* Trim the top 1%: these are missing values (99999)
		winsor2 actual_rent potential_rent, trim replace cut(0 99) by(year)

		egen rent = rowtotal(actual_rent potential_rent), missing
		gen dum_renter = (actual_rent !=.)

		gen hhid_`year' = hhid`yearabr'
		drop hhid`yearabr'
		capture gen hhid = hhid_`year'
		replace hhid = hhid_`year'

		
		if `year' == 1993 {
			save $secdata/Compiled/IFLS_rent, replace
			}
		else {
			append using $secdata/Compiled/IFLS_rent
			save $secdata/Compiled/IFLS_rent, replace
			}

		}

	
end

	
	
