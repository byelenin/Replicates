program define Figure1_Table1
	
	*! SOURCE FILE: SUMMARY_RURAL_URBAN_28APR2017
	
	syntax [varlist]

	use "$secdata/Not_Public/supas_1976_cleaned", clear
	append using $secdata/Not_Public/supas_1995_cleaned
	append using $secdata/Not_Public/susenas_2011_2012_cleaned

	local type _rgcy

	replace wage_month = wage_month*0.00011 //this using xe.com rate for 2010, 1 million approx $110 2010 USD// 
				
	foreach location in _rgcy _prov {
		capture gen birth_migrant`location' = (current`location' != birth`location')
		}

	drop if year == .
	drop if _fillin == 1
	tempfile data_appended
	save `data_appended', replace


	// First: draw the individual wage distributions//
	local bwidth 0.3
	*local range range(2 8)
	local range
	gen log_wage_month = log(wage_month)

	reg log_wage_month i.year [aw=sample_wt]
	predict log_wage_month_yr, res
	
	
	foreach year in  1995 2011 2012 {
		twoway (kdensity log_wage_month if year == `year' [aw=sample_wt], bwidth(`bwidth') `range')  (kdensity log_wage_month if year == `year' & rural == 1 [aw=sample_wt],bwidth(`bwidth' ) lpattern(shortdash) `range') (kdensity log_wage_month if year == `year' & rural == 0 [aw=sample_wt],bwidth(`bwidth') lpattern(longdash) `range'), scheme(s1mono) legend(label(1 "All") label(2 "Rural") label(3 "Urban") row(1)) title("`year'") xtitle("Log monthly wage") ytitle("Density") name(y`year', replace) nodraw
		}

	grc1leg  y1995 y2011 y2012, scheme(s1mono) ycommon xcommon note("Unit of observation is the individual." "Source: 1995 SUPAS, 2011 SUSENAS; 2012 SUSENAS.")
	di "`date'"
	
	graph export "$outpath/wage_distributions_individual.eps", replace

	*! Do the yr one
	twoway (kdensity log_wage_month_yr [aw=sample_wt], bwidth(`bwidth') `range')  (kdensity log_wage_month_yr if rural == 1 [aw=sample_wt],bwidth(`bwidth' ) lpattern(shortdash) `range') (kdensity log_wage_month_yr if rural == 0 [aw=sample_wt],bwidth(`bwidth') lpattern(longdash) `range'), scheme(s1mono) legend(label(1 "All") label(2 "Rural") label(3 "Urban") row(1)) title("`year'") xtitle("Log monthly wage") ytitle("Density") name(y`year', replace) note("Log monthly wage is demeaned of year fixed effects. Unit of observation is the individual." "Source: 1995 SUPAS, 2011 SUSENAS; 2012 SUSENAS.")
	
	graph export "$outpath/wage_distributions_individual_yr.eps", replace

	drop if _fillin == 1 //this just to get square matrix//

	tabstat rural [aw=sample_wt], by(year)

	// Next: show the regency-level distributions//
	gen no_obs = 1
	gen rural_sample_wt = rural*sample_wt
	collapse (rawsum) sample_wt rural_sample_wt no_obs  (mean) log_wage_month wage_month rural [aw=sample_wt], by(current_rgcy year)

	gen log_avg_wage_month = log(wage_month)

	reg log_avg_wage_month i.year [aw=sample_wt]
	predict log_avg_wage_month_yr, res

	tabstat rural [aw=sample_wt], by(year)

* We want to choose the rural-cut off such that we match the share of ppl nationally who are rural
	egen quantile = xtile(rural), nquantiles(10) by(year)

* Now want to assign everything less than the quantile as urban, find the threshold that matches weighted national average
	forvalues i = 1/100 {
		gen dum_rural`i' = (quantile>=`i')
		}

	foreach year in 1995 2011 2012 {
	
		tabstat rural dum_rural* [aw=sample_wt] if year == `year', save

		matrix mean = r(StatTotal)
		svmat mean
		sum mean1
		foreach var of varlist mean*{
			replace `var' = `var'-`r(mean)'
			replace `var' = abs(`var')
			}
		drop mean1
		egen best_quartile = rowmin(mean*)
		sum best_quartile
		local best_quartile = `r(mean)'
		foreach var of varlist mean*{
			qui sum `var'
			if `r(mean)' != `best_quartile' {
				drop `var'
				}
			}
* Now figure out which quartile is left
		foreach var of varlist mean*{
			local qstar = subinstr("`var'","mean","",.)
			di "`qstar'"
			}
		capture gen quartile_star = .
		replace quartile_star = `qstar' if year == `year'
		drop mean* best_quartile
		}

	replace quartile_star = quartile_star-1 //because the first element in the matrix was the baseline level of rural we are matching, so we are 1 off with the name//

	drop dum_rural*
	gen dum_rural = (quantile>=quartile_star)

	tabstat rural dum_rural [aw=sample_wt], by(year) //cant get there exactly because have discrete number of regencies, so this is closest can get//


	// Now draw the regency-level plot, unweighted, as unit of observation is now the regency
	*local range range(2 6)
	local range
	foreach year in  1995 2011 2012 {
		twoway (kdensity log_avg_wage_month if year == `year', bwidth(`bwidth') `range')  (kdensity log_avg_wage_month if year == `year' & dum_rural == 1 ,bwidth(`bwidth' ) lpattern(shortdash) `range') (kdensity log_avg_wage_month if year == `year' & dum_rural == 0, bwidth(`bwidth') lpattern(longdash) `range'), scheme(s1mono) legend(label(1 "All") label(2 "Rural") label(3 "Urban") row(1)) title("`year'") xtitle("Log average monthly wage") ytitle("Density") name(y`year', replace) nodraw
		}

	grc1leg y1995 y2011 y2012, scheme(s1mono) ycommon xcommon note("Unit of observation is the regency." "Regency is defined as either rural or urban to match the national share of rural." "Source: 1995 SUPAS, 2011 SUSENAS; 2012 SUSENAS.")
	graph export "$outpath/wage_distributions_regency.eps", replace

	*! Do the combined one
	twoway (kdensity log_avg_wage_month_yr [aw=sample_wt], bwidth(`bwidth') `range')  (kdensity log_avg_wage_month_yr if rural == 1 [aw=sample_wt],bwidth(`bwidth' ) lpattern(shortdash) `range') (kdensity log_avg_wage_month_yr if rural == 0 [aw=sample_wt],bwidth(`bwidth') lpattern(longdash) `range'), scheme(s1mono) legend(label(1 "All") label(2 "Rural") label(3 "Urban") row(1)) title("`year'") xtitle("Log average monthly wage") ytitle("Density") name(y`year', replace) note("Log average monthly wage is demeaned of year fixed effects. Unit of observation is the regency." "Regency is defined as either rural or urban to match the national share of rural." "Source: 1995 SUPAS, 2011 SUSENAS; 2012 SUSENAS.")
	
	graph export "$outpath/wage_distributions_regency_yr.eps", replace


	// Now make the transition matrices showing migration patterns//
	// For this, keep our threshold of rural that we have defined optimally here
	keep current_rgcy rural dum_rural year
	rename rural current_rural
	rename dum_rural current_dum_rural
	tempfile current_rgcy_rural
	save `current_rgcy_rural', replace


	rename current_rgcy birth_rgcy
	rename current_rural birth_rural
	rename current_dum_rural birth_dum_rural
	tempfile birth_rgcy_rural
	save `birth_rgcy_rural', replace

	use `data_appended', clear
	merge m:1 current_rgcy year using `current_rgcy_rural'
	assert _merge == 3
	drop _merge

	merge m:1 birth_rgcy year using `birth_rgcy_rural' //some missing, not sure why? is the regency concordance not consistent over time?//
	drop _merge

	gen dum_migrant = (birth_rgcy != current_rgcy)
	drop if birth_dum_rural == . | current_dum_rural == . //come back and fix//

	gen move_within = (current_dum_rural == birth_dum_rural) if dum_migrant == 1

	// Now do the tables

	label var dum_migrant "Migration rate"
	label var move_within "Moves within category"

	foreach year in /*1976*/ 1995 2011 2012 {

		quicktab dum_migrant move_within if birth_dum_rural == 1 & year == `year' [aw=sample_wt]
		eststo rural_`year'
	
		quicktab dum_migrant move_within if birth_dum_rural == 0 & year == `year' [aw=sample_wt]
		eststo urban_`year'

		quicktab dum_migrant move_within if  year == `year' [aw=sample_wt]
		eststo all_`year'

		if `year' == 1995 {
			estout rural_`year' urban_`year' all_`year' using "$outpath/within_mig.tex", style(tex) replace prehead(\begin{table} \begin{small} \begin{center}\begin{threeparttable}[b] \caption{@title} \label{@title} \begin{tabular}{l*{@M}c} \toprule) posthead("\midrule") varlabels(,blist(dum_migrant "\multicolumn{@span}{l}{\emph{`year'}} \\")) collabels(,none) label mlabel("Rural" "Urban" "All") cell(b(fmt(1))) transform(@*100) title("Migration rates by origin, Indonesia")
			}
		else if  `year' == 2011 {
			estout rural_`year' urban_`year' all_`year' using "$outpath/within_mig.tex", style(tex) append varlabels(,blist(dum_migrant "\multicolumn{@span}{l}{\emph{`year'}} \\"))  collabels( ,none) mlabels(,none) label cell(b(fmt(1))) transform(@*100)
			}
		else if `year' == 2012 {
			estout rural_`year' urban_`year' all_`year' using "$outpath/within_mig.tex", style(tex) append postfoot(\bottomrule \end{tabular} \label{@title} \begin{tablenotes} \item {\footnotesize \emph{Notes: } @note } \end{tablenotes} \end{threeparttable} \end{center} \end{small} \end{table}) varlabels(,blist(dum_migrant "\multicolumn{@span}{l}{\emph{`year'}} \\")) note("Data source:  1995 Supas; 2011 Susenas; 2012 Susenas. Migration is measured as living in a regency other than the birth regency. Regencies are classified as rural or urban based on the share of their population that report being rural; we choose the cutoff to classify the regency as rural to match the national urbanization rate for each year.") collabels(,none) mlabels(,none) label cell(b(fmt(1))) transform(@*100)
			}
		}

end



	
