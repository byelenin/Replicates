program read_in_podes96

	use "$rawdata/PODES/1996/POD96A.dta", clear
	merge 1:1 B1R1 B1R2 B1R3 B1R4 B1R5 using "$rawdata/PODES/1996/POD96B.dta"
	drop _merge

	foreach var in _all {
		destring `var', replace
	}

	save "$secdata/PODES/podes_1996_raw.dta", replace

end
