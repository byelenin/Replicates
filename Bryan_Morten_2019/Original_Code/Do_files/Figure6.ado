program Figure6

	*! Source: makeGraphSchoolingEduc_22May2017

	local time _month
	local educ all
	local esttype nonparam
	
	use "$secdata/Not_Public/dataset_structural_ind_prov`time'_educ_`educ'_est_`esttype'", clear
	gen country = "ind"
	append using "$secdata/Not_Public/dataset_structural_us_state`time'_educ_`educ'_est_`esttype'"
	replace country = "us" if country == ""

	drop if year == 1976
	keep if i == g

	reg log_q_0 years_school_g i.year if country == "us"
	local beta: display %5.1g _b[years_school_g]
	local t_stat: display %5.1g _b[years_school_g]/_se[years_school_g]
	
	binscatter log_q_0 years_school_g if country == "us", control(i.year) scheme(s1mono) name(school_us, replace) title("US") xtitle("Avg. years schooling") ytitle("Estimated schooling quality") note("Beta is `beta'; t-stat is `t_stat'.")

	reg log_q_0 years_school_g i.year if country == "ind"
	local beta: display %5.1g _b[years_school_g]
	local t_stat: display %5.1g _b[years_school_g]/_se[years_school_g]

	binscatter log_q_0 years_school_g if country == "ind", control(i.year) scheme(s1mono) name(school_ind, replace) title("Indonesia") xtitle("Avg. years schooling") ytitle("Estimated schooling quality") note("Beta is `beta'; t-stat is `t_stat'.") 

	graph combine school_ind school_us , scheme(s1mono) note("Data is: 1990, 2010 for the US. 1995, 2011, 2012 for Indonesia." "Figure shows a binned scatterplot. Year effects are removed from both graphs.") title("Estimated schooling quality against schooling attainment")
	graph export "$outpath/loq_q_0_educ_all`time'_educ_`educ'_est_`esttype'.eps", replace		
	
	
end
