* Version 1: February 11, 2014 (Allan Hsiao)
* Make regency pairs distance table

program susenas11_rgcy_coordinates

	insheet using "$rawdata/SUSENAS/Susenas 2011 Kor/Regencies_2011.csv", clear
	
	rename regencycode rgcy_code
	save "$secdata/Compiled/susenas11_rgcy_coordinates", replace
	
	rename rgcy_code other_rgcy_code
	rename regency other_regency
	rename latitude other_latitude
	rename longitude other_longitude
	save "$secdata/Compiled/susenas11_rgcy_coordinates_other", replace
	
end
