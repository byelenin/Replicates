* Make regency pairs distance table

program state_dist_table_20150117 

	insheet using "$rawdata/IPUMS USA/States.csv", clear

	rename statecode state_code
	save "$secdata/IPUMS USA/state_coordinates", replace
	
	rename state_code other_state_code
	rename state other_state
	rename latitude other_latitude
	rename longitude other_longitude
	save "$secdata/IPUMS USA/state_coordinates_other", replace
	
end
