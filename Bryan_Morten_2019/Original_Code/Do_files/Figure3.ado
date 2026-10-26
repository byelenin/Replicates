program define Figure3
	
	*! Source file: makeGraphsRelLang_22May2017
	
	local educ all
	local esttype nonparam
	local time _month
	
	local distance_var log_distance

	use "$secdata/Not_Public/dataset_structural_ind_prov`time'_educ_`educ'_est_`esttype'", clear
	gen country = "ind"

	capture drop log_distance
	gen log_distance = log(birth_distance)
	label var log_distance "Log Euclidean Distance"

	capture drop _merge
	merge 1:1 birth_prov current_prov year using $secdata/Not_Public/place_diffs_prov
	assert _merge ==3 if year == 1995 | year == 1976 //this should be the only year that merges, 1976 will merge just for lingusitc//
	drop _merge

	// We want to plot the partialized effect of both religion and linguistic similarity, taking out distance//

	drop if transport_costs > 0.99 //dropping the extensive margin ones//
	drop if log_distance == . //own pairs

	reg transport_costs i.year
	predict demean_transport_costs, res

	//First: against distance//
	reg demean_transport_costs log_distance
	predict demean_transport_costs_distance, res
	local beta: display %5.1g _b[log_distance]
	local t_stat: display %5.1g _b[log_distance]/_se[log_distance]

	twoway (scatter demean_transport_costs log_distance) (lfit demean_transport_costs log_distance), scheme(s1color) title("Distance") ytitle("Transport costs") name(distance, replace) legend(off) note("Beta = `beta'; t-stat = `t_stat'.")

	// Do against language//
	reg demean_transport_costs_distance exp_prob_match_language_home
	local beta: display %5.1g _b[exp_prob_match_language_home]
	local t_stat: display %5.1g _b[exp_prob_match_language_home]/_se[exp_prob_match_language_home]
	twoway (scatter demean_transport_costs_distance exp_prob_match_language_home) (lfit demean_transport_costs_distance exp_prob_match_language_home), scheme(s1color) title("Language") ytitle("Transport costs") name(language, replace) xtitle("Linguistic similiarity | Distance") legend(off) note("Beta = `beta'; t-stat = `t_stat'.")

	// Do against language//
	reg demean_transport_costs_distance exp_prob_match_religion
	local beta: display %5.1g _b[exp_prob_match_religion]
	local t_stat: display %5.1g _b[exp_prob_match_religion]/_se[exp_prob_match_religion]
	twoway (scatter demean_transport_costs_distance exp_prob_match_religion) (lfit demean_transport_costs_distance exp_prob_match_religion), scheme(s1color) title("Religion") xtitle("Religious similiarity | Distance") ytitle("Transport costs") name(religion, replace) legend(off) note("Beta = `beta'; t-stat = `t_stat'.")
 
	graph combine distance language religion, scheme(s1color) row(1) note("Data, demeaned by year, from 1995, 2011, 2012." "Graph shows intensive margin transport costs (less than upper bound).")
	graph export "$outpath/correlates_transport_cost`time'_educ_`educ'_est_`esttype'.eps", replace


end
