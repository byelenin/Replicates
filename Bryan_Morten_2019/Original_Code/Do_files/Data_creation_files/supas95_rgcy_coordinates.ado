* Version 1: February 11, 2014 (Allan Hsiao)
* Make regency pairs distance table

program supas95_rgcy_coordinates

	insheet using "$rawdata/SUPAS/Supas 1995/Regencies_1995.csv", clear
	drop v6

	gen rgcy_code = 100 * provincecode + regencycode
	
	rename nameofprovinceregency regency
	order rgcy_code, b(regency)
	drop provincecode regencycode
	drop if latitude == .
	
	save "$secdata/Compiled/supas95_rgcy_coordinates", replace
	
	rename rgcy_code other_rgcy_code
	rename regency other_regency
	rename latitude other_latitude
	rename longitude other_longitude
	
	save "$secdata/Compiled/supas95_rgcy_coordinates_other", replace
	
end
