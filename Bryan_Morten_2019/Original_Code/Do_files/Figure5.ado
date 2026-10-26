program define Figure5

	*! Source file: merge_PODES_22Jan2018

	local educ all
	local esttype nonparam
	local country ind
	local type _prov
	local time _month

	use "$secdata/Not_Public/dataset_structural_`country'`type'`time'_educ_`educ'_est_`esttype'", clear
	bys current_prov year: keep if _n == 1

	drop if year == 1976


	// Merge on the PCA//
	capture drop _merge
	merge 1:1 current_prov year using $secdata/Not_Public/pca_amenities_prov
	assert _merge == 3
	drop _merge

	merge 1:1 current_prov year using "$secdata/Not_Public/housing_expenditure_susenas"
	drop _merge
	


	reg log_alpha_rel_i pca_pollution
	local beta: display %5.1g _b[pca_pollution]
	local t_stat: display %5.1g _b[pca_pollution]/_se[pca_pollution]
	twoway (scatter log_alpha_rel_i pca_pollution) (lfit log_alpha_rel_i pca_pollution), title("Pollution") ytitle("Relative amenities") xtitle("Pollution") legend(off) note("Water, land, air and noise pollution." "Beta = `beta'; t-stat = `t_stat'.") scheme(s1color) name(pollution, replace) 
	
	reg log_alpha_rel_i pca_ease
	local beta: display %5.1g _b[pca_ease]
	local t_stat: display %5.1g _b[pca_ease]/_se[pca_ease]

	twoway (scatter log_alpha_rel_i pca_ease) (lfit log_alpha_rel_i pca_ease), title("Health/Markets") ytitle("Relative amenities") xtitle("Ease of access") legend(off) note("Hospitals, health care, markets" "and shopping center." "Beta = `beta'; t-stat = `t_stat'.") scheme(s1color) name(ease, replace)
	

	reg log_alpha_rel_i log_avg_housing
	local beta: display %5.1g _b[log_avg_housing]
	local t_stat: display %5.1g _b[log_avg_housing]/_se[log_avg_housing]

	twoway (scatter log_alpha_rel_i log_avg_housing) (lfit log_alpha_rel_i log_avg_housing), title("Avg housing costs ") ytitle("Relative amenities") xtitle("Log housing cost") legend(off) note("Source: SUSENAS 1995, 2011, 2012" "Beta = `beta'; t-stat = `t_stat'.") scheme(s1color) name(housing, replace)
	
	
	graph combine pollution ease housing, scheme(s1color) title("Correlates of estimated amenities, Indonesia") note("Estimated amenities from 1995, 2011, 2012." "Variable is first principal component of each group of amenities.") row(1)
	graph export "$outpath/figure_pca_amenities_`time'_educ_`educ'_est_`esttype'.eps", replace
	
	
	
	
	

end


