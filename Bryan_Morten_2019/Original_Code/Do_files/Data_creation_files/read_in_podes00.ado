program read_in_podes00

	use "$rawdata/PODES/2000/PDS20001.dta", clear
	merge 1:1 prop kab kec desa drh using "$rawdata/PODES/2000/PDS20002.dta"
	drop _merge

	foreach var in _all {
		destring `var', replace
	}

	save "$secdata/PODES/podes_2000_raw.dta", replace

end
