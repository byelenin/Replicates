program read_in_data_ipums_usa_20150117

	syntax [varlist], year(string)

	set more off
	clear

	use "$rawdata/IPUMS USA/ipums_usa_`year'", replace
	gen year = `year'
	
	save "$secdata/IPUMS USA/ipums_usa_`year'", replace
	
end
