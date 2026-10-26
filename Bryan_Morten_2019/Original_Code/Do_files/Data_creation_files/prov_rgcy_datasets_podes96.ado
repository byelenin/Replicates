program prov_rgcy_datasets_podes96

	// Collapse to province dataset
	use "$secdata/PODES/podes_1996.dta", replace
	drop type_geography type_topography source_income source_ag_income // Doesn't make sense to average
	foreach v of var * {
		local l`v' : variable label `v'
		if `"`l`v''"' == "" {
			local l`v' "`v'"
		}
	}
	*preserve
	collapse dum_rural - no_rural_banks [fw=podes_population], by(prop)
	*drop podes_population total_landarea rice_area nonrice_area
	*tempfile temp
	*save `temp'
	*restore
	*collapse (sum) podes_population total_landarea rice_area nonrice_area, by(prop)
	*merge 1:1 prop using `temp'
	*drop _merge
	foreach v of var * {
		label var `v' "`l`v''"
	}
	save "$secdata/PODES/podes_1996_prov", replace

	// Collapse to regency dataset
	use "$secdata/PODES/podes_1996.dta", replace
	drop type_geography type_topography source_income source_ag_income // Doesn't make sense to average
	foreach v of var * {
		local l`v' : variable label `v'
		if `"`l`v''"' == "" {
			local l`v' "`v'"
		}
	}
	*preserve
	collapse dum_rural - no_rural_banks [fw=podes_population], by(prop kab)
	*drop podes_population total_landarea rice_area nonrice_area
	*tempfile temp
	*save `temp'
	*restore
	*collapse (sum) podes_population total_landarea rice_area nonrice_area, by(prop kab)
	*merge 1:1 prop kab using `temp'
	*drop _merge
	foreach v of var * {
		label var `v' "`l`v''"
	}
	save "$secdata/PODES/podes_1996_rgcy", replace

end
