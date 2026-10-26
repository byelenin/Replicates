program prov_rgcy_datasets_podes11

	// Collapse to province dataset
	use "$secdata/PODES/podes_2011.dta", replace
	drop source_income source_ag_income // Doesn't make sense to average
	foreach v of var * {
		local l`v' : variable label `v'
		if `"`l`v''"' == "" {
			local l`v' "`v'"
		}
	}
	*preserve
	collapse dum_rural - no_church [fw=podes_population], by(prop)
	*drop podes_population 
	*tempfile temp
	*save `temp'
	*restore
	*collapse (sum) podes_population, by(prop)
	*merge 1:1 prop using `temp'
	*pause on; pause
	*drop _merge
	foreach v of var * {
		label var `v' "`l`v''"
	}
	save "$secdata/PODES/podes_2011_prov", replace

	// Collapse to regency dataset
	use "$secdata/PODES/podes_2011.dta", replace
	drop source_income source_ag_income // Doesn't make sense to average
	foreach v of var * {
		local l`v' : variable label `v'
		if `"`l`v''"' == "" {
			local l`v' "`v'"
		}
	}
	*preserve
	collapse dum_rural - no_church [fw=podes_population], by(prop kab)
	*drop podes_population 
	*tempfile temp
	*save `temp'
	*restore
	*collapse (sum) podes_population, by(prop kab)
	*merge 1:1 prop kab using `temp'
	*pause on; pause
	*drop _merge
	foreach v of var * {
		label var `v' "`l`v''"
	}
	save "$secdata/PODES/podes_2011_rgcy", replace

end
