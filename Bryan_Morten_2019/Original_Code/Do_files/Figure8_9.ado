program define Figure8_9

	* Source: GE_draw_histograms_30Jan2018

	syntax [varlist], [multreduction(real 1)]

	*! Multreduction is if we want to do different baseline multreduction than 1
	
	local etatype 0
	local educ all
	local esttype nonparam
	
	foreach country in ind us {

		if "`multreduction'" != "" {
			local multreductionx = 100*`multreduction'
			}
		
		use $secdata/Public/GE_dataset_`esttype'_`etatype', clear

		drop if year == 1976
		drop if dum_deletehc == 1
		keep if country == "`country'"

		if "`country'" == "ind" {
			local country_title Indonesia
			local data_note "Shows a reduction of costs of `multreductionx'%. Data is 1995, 2011, 2012"
			}
		else if "`country'" == "us" {
			local country_title US
			local data_note "Shows a reduction of costs of `multreductionx'%. Data is 1990, 2010"
			}

		keep if parameters == 1
		
		replace mult_reduction = round(mult_reduction, 0.01) //working on the precision piece

		keep if (mult_reduction == float(0) | mult_reduction == float(`multreduction')) & zero_tc == 0 & dum_no_selection == 0 //here is stata's FAQ on precision:http://blog.stata.com/2012/04/02/the-penultimate-guide-to-precision/. See section 6.5//

		keep pop* *wage* year mult_reduction country region vartype relative_GDP

		egen mult_group = group(mult_reduction) //so can reshape wlog//
		replace mult_group = mult_group - 1
		tab mult_group
		drop mult_reduction
		
		// Want to do something about which regions would grow and which would shrink//
		reshape wide pop_dest pop_origin wage_dest tot_wages_origin tot_wages_destination relative_GDP, i(country region year vartype ) j(mult_group)

		* reduction is from 100% to 0% transport costs
		foreach var in pop_dest pop_origin wage_dest tot_wages_origin tot_wages_destination {
			gen `var'_change = 100*(`var'1-`var'0)/`var'0
			}

		tabstat tot_wages_origin_change, by(vartype) stat(min mean max)

		bys year vartype: egen sum_tot_wages_origin0 = total(tot_wages_origin0)
		bys year vartype: egen sum_tot_wages_origin1 = total(tot_wages_origin1)
		gen gdp_change_check = (sum_tot_wages_origin1-sum_tot_wages_origin0)/sum_tot_wages_origin0

		assert abs(gdp_change_check + 1 - relative_GDP1) < 0.01
		* If this fails, then it means that GDP from wages and GDP from GDP arent the same
		replace gdp_change_check = gdp_change_check*100

		foreach vartype in 1 2 3 4 {

			if `vartype' == 1 {
				local title "Mig cost"
				}
			else if `vartype' == 2 {
				local title "Mig cost, housing"
				}
			else if `vartype' == 3 {
				local title "Amenities"
				}
			else if `vartype' == 4 {
				local title "Mig cost & amenities"
				}


			* just need to get the mean to line up.
			* for the mean, use relative_GDP1. This will match exactly with the other tables
			qui sum gdp_change_check if vartype == `vartype'
			local wmean = `r(mean)'

			* For the min/max, sum the tot_wages_oriign_change. Dont need to weight
			qui sum tot_wages_origin_change if vartype == `vartype'
			local wmax = `r(max)'
			local wmin = `r(min)'
			
			local wmean2: display %6.1f `wmean'
			local wmax2: display %6.1f `wmax'
			local wmin2: display %6.1f `wmin'
	
			loc max 30 //since combining on ycommon, doenst really work to automate it//
		
			twoway (histogram tot_wages_origin_change if vartype == `vartype', percent bin(10)) (function y=`wmean', hor ra(0 `max') lcolor(red)), scheme(s1mono) name(g`vartype', replace) title("`title'") xtitle("Wage gain (%)") legend(off) xlabel(,grid) note("Mean/Min/Max" "`wmean2'/`wmin2'/`wmax2'")
			
			}

		graph combine g1 /*g2*/ g3 g4, xcommon ycommon scheme(s1mono) row(1) title("Distributional impacts, `country_title'") note("Figure shows average wage gain. The unit of observation is an origin-year." "National average (weighted by population) shown in red line." "`data_note'.")

	
		graph export "$outpath/distributional_histogram`country'_reduce`multreductionx'_`esttype'_`etatype'.eps", replace

		// Lets just make the migration cost reduction one by itself (for the 40% case)
		graph combine g1, scheme(s1mono) title("Distributional impacts, `country_title'") note("Figure shows average wage gain. The unit of observation is an origin-year." "National average (weighted by population) shown in red line." "`data_note'.")

		graph export "$outpath/distributional_histogram_mig_`country'_reduce`multreductionx'_`esttype'_`etatype'.eps", replace
		

		}


end



	
