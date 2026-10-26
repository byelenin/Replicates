program define Figure7

	*! SOURCE: draw_reduce_alphatau_19Jan2018

	local esttype nonparam
	local etatype 0
	
	foreach vartype in 1 2 3 4 {

		use $secdata/Public/GE_dataset_`esttype'_`etatype', clear

		if "`coutry'" == "ind" {
			local countrytitle Indonesia
			}
		else if "`country'" == "us" {
			local countrytitle United States
			}

		*keep if zero_tc == 1
		keep if zero_tc == 0
		keep if parameters == 1
		keep if dum_deletehc == 0
		
		keep if mult_reduction >= 0
		keep if region == 1
		drop if year == 1976
		keep if dum_no_selection == 0

		* Just make one figure for each country
		collapse  relative_GDP mean_1_minus_tau mean_log_1_minus_tau, by(country mult_reduction vartype)

		sum mean_1_minus_tau if country == "ind" & mult_reduction == 0
		local mean_ind = `r(mean)'
		sum mean_1_minus_tau if country == "us" & mult_reduction == 0
		local mean_us = `r(mean)'

		local kappa_ind = 1-`mean_ind'/`mean_us' //get something like 0.31//
		di in red "kappa ind is `kappa_ind'"
		
		if `vartype' == 1 {
			local title "Mig cost"
			*local xline
			local xline xline(`kappa_ind', lpattern(dash)) /*text(1.15 `kappa_ind' "US-level", place(w))*/
			}
		else if `vartype' == 2 {
			local title "Mig cost, housing"
			local xline 
			}
		else if `vartype' == 3 {
			local title "Amenities"
			local xline 
			}
		else if `vartype' == 4 {
			local title "Mig cost & amenities"
			local xline 
			}

		twoway (scatter relative_GDP mult_reduction  if vartype == `vartype' & country == "ind", sort connect(direct)), ylabel(, grid gmax)  scheme(s1color) xlabel(,grid gmax) xtitle("Proportion reduction ({&kappa})") ytitle("Relative output") title("`title'") `xline' legend(off) name(var`vartype', replace)

		}

	graph combine var1 var3 var4, scheme(s1color) row(1) title("Output gain from reducing barriers to movement") note("Data is average across 1995, 2011, 2012 for Indonesia." "The proportion reduction, {&kappa}, is defined in the text." "The red dashed line shows the US-level of migration costs.") ycommon xcommon  
	graph export "$outpath/output_multchange_all_`esttype'_`etatype'.eps", replace

	
end
	
	
