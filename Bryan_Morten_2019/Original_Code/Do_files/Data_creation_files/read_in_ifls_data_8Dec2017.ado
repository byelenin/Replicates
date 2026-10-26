program read_in_ifls_data_8Dec2017

* Version 1: December 22, 2013 (Allan Hsiao)
* Version 2: August 3, 2014 (Allan Hsiao)
* Version 3: August 19, 2014 (AH) Adding in IFLS waves 1, 2, and 3
* 8/10/2016: adding in employment
* 12/8/2017: adding in rents

	
 	read_in_roster
	* Output: "$secdata/IFLS/bk_premerge.dta"

	read_in_weights
	* Output: "$secdata/IFLS/trk_premerge.dta"
	
	read_in_literacy
	* Output: "$secdata/IFLS/b3a_dl_premerge.dta"
	
	read_in_migration
	* Output: "$secdata/IFLS/b3a_tk_premerge.dta"
	
	read_in_employment_10Aug2016
	* Output: "$secdata/IFLS/b3a_tk_premerge.dta"

	read_in_hh_enterprise
	* Output: "$secdata/IFLS/b2_premerge.dta"
	* Note: year 2007 only (for robustness check)

	read_in_rent



	
end

