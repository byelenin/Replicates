program Figure4

*! Source: makeIndUS_graphs_22May2017

	local educ all
	local esttype nonparam
	local time _month
	local distance_var log_distance

	use "$structpath/data/dataset_structural_ind_prov`time'_educ_`educ'_est_`esttype'", clear
	gen country = "ind"

	append using "$structpath/data/dataset_structural_us_state`time'_educ_`educ'_est_`esttype'"
	replace country = "us" if country == ""

	capture drop log_distance
	gen log_distance = log(birth_distance_state) if country == "us"
	replace log_distance = log(birth_distance_prov) if country == "ind"
	label var log_distance "Log Euclidean Distance"

	drop if year == 1976

	reg transport_costs `distance_var' if country == "us"
	local corr_us : di %4.3f _b[log_distance]
	reg transport_costs `distance_var' if country == "ind"
	local corr_ind : di %4.3f _b[log_distance]


	reg transport_costs i.year if country == "us"
	predict transport_costs_demean_us, res
	reg transport_costs i.year if country == "ind"
	predict transport_costs_demean_ind, res

	// Now plot US vs Indonesia//
	gen transport_costs_us = transport_costs if country == "us"
	gen transport_costs_ind = transport_costs if country == "ind"

	twoway (scatter transport_costs log_distance if country == "us") (lfit transport_costs log_distance if country == "us")  (scatter transport_costs log_distance if country == "ind") (lfit transport_costs log_distance if country == "ind"), scheme(s1mono) legend(order(1 3) label(1 "US (slope: `corr_us')") label(3 "Indonesia (slope: `corr_ind')")) ytitle("Migration cost") note("Data from 1990 and 2010 for the US; from 1995, 2011 and 2012 for Indonesia.")
	graph export  "$outpath/us_ind_distance`time'_educ_`educ'_est_`esttype'.eps", replace



end
