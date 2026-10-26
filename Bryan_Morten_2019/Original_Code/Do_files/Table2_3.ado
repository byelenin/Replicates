program Table2_3

	* SOURCE FILE: REDUCED_FORM_TESTS_27APR2018
	
	*! This file reproduces Table 2, 3
	
	syntax [varlist]

	local dataset_loop ifls ifls_wage ifls_self baseline_prov baseline_rgcy us 
	
	foreach dataset in `dataset_loop' {

		estimates drop _all

		if "`dataset'" == "baseline_rgcy" | "`dataset'" == "baseline_prov" {
				
			local country ind

			if "`dataset'" == "baseline_rgcy" {
				local type _rgcy
				local obs "An observation is an origin-destination regency pair."
				local title "Five facts about migration in Indonesia"
				}
			else if "`dataset'" == "baseline_prov" {
				local type _prov
				local obs "An observation is an origin-destination province pair."
				local title "Five facts about migration in Indonesia, province-level"
					
				}

			use "$secdata/Not_Public/supas_1976_cleaned`suffix'", clear
			append using $secdata/Not_Public/supas_1995_cleaned`suffix'
			append using $secdata/Not_Public/susenas_2011_2012_cleaned`suffix'
			local datasource_note "Datasource: 1995 SUSENAS, 2011 SUSENAS, 2012 SUSENAS. Two-way clustering of standard errors at the origin-year and destination-year reported in Columns (1)-(4). Clustered standard errors, at the level of the origin-year, reported in Column (5)."
			
			drop if year == 1976
			}

		else if regexm("`dataset'","ifls")==1 {

			local country ind
			local type _prov
				
			use "$secdata/Not_Public/ifls_2007_cleaned_prov_1993.dta", clear
			append using "$secdata/Not_Public/ifls_2007_cleaned_prov_1997.dta"
			append using "$secdata/Not_Public/ifls_2007_cleaned_prov_2000.dta"
			append using "$secdata/Not_Public/ifls_2007_cleaned_prov_2007.dta"
			
			local datasource_note "Datasource: 1993, 1997, 2000, 2007 IFLS. Two-way clustering of standard errors at the origin-year and destination-year reported in Columns (1)-(4)."
			local obs "An observation is an origin-destination province pair." 

			if "`dataset'" == "ifls_self" {
				keep if self_employed == 1
				local titleadd "(self-employed only)"
				}
			else if "`dataset'" == "ifls_wage" {
				keep if self_employed == 0
				local titleadd "(wage employees only)"
				}

			local title "Four facts about migration in Indonesia, IFLS data `titleadd'"
				
			}

		else if "`dataset'" == "us" {

			local country us
			local type _state
				
			use "$secdata/Not_Public/ipums_usa_cleaned_1990`suffix'.dta", clear
			append using "$secdata/Not_Public/ipums_usa_cleaned_2010`suffix'.dta"

			local datasource_note "Datasource: 1990 Census, 2010 ACS. Two-way clustering of standard errors at the origin-year and destination-year reported in Columns (1)-(4)."

			local title "Four facts about migration in the U.S."
			local obs "An observation is an origin-destination state pair."
				
			}
			
		gen log_wage = log(wage_month)
		gen no_obs = 1

		local educfe
		local ieducfe
		local destyearlabel "Destination x Year FE"
		local origyearlabel "Origin x Year FE"
		local destlabel "Destination FE"
		local r3titlenote
		
		
		// Collapse the dataset//
		preserve
		collapse   (mean) /*log_distance*/ wage_month log_wage  (rawsum) no_obs sample_wt [pw=sample_wt] , by(birth`type' current`type' `educfe' year)

		fillin birth`type' current`type' `educfe' year
		replace sample_wt = 0 if _fillin == 1
		tempfile temp
		save `temp', replace
		restore

		* We want to have the average wage at destination for one of the regressions, not at origin/destination. Make this here and merge back
		collapse (mean) wage_month log_wage [pw=sample_wt], by(current`type' `educfe' year)
		rename wage_month wage_month_current`type'
		rename log_wage log_wage_current`type'
		merge 1:m current`type' `educfe' year using `temp'
		assert _merge == 3 if _fillin == 0
		drop _merge

			
		if "`country'" == "ind" {

			joinby birth`type' current`type' using $secdata/Public/susenas11_birth`type'_distances, unmatched(both)
			*merge m:1 birth`type' current`type' using $secdata/Not_Public/susenas11_birth`type'_distances
			keep if _merge==3
			drop _merge
			}
		else if "`country'" == "us" {
			preserve
			use "$secdata/Public/state_distances", clear
			rename state_code birth_state
			rename other_state_code current_state
			rename distance birth_distance
			tempfile temp
			save `temp', replace
			restore
			joinby birth`type' current`type' using `temp', unmatched(both)
			*merge m:1 birth`type' current`type' using `temp'
			keep if _merge==3
			drop _merge
			}

	

		if regexm("`dataset'", "baseline") {

			joinby current`type' year using $secdata/Not_Public/pca_amenities`type', unmatched(both)
			*merge m:1 current`type' year using $secdata/Not_Public/pca_amenities`type'
			if "`dataset'" == "baseline" {
				assert _merge == 3 if year != 1976
				}
			drop _merge

			// Now merge on housing from IFLS
			joinby current`type' year using $secdata/Not_Public/housing_expenditure_ifls`type', unmatched(both)
			drop _merge

			}

		bys year birth`type' `educfe': egen total_pop_birth = total(sample_wt)
		gen prob_igt = sample_wt/total_pop_birth

		gen log_prob_igt = log(prob_igt)
		gen log_distance = log(1+birth_distance)

		gen log_avg_wage = log(wage_month)
		gen log_avg_wage_destination = log(wage_month_current`type')
		rename log_wage_current`type' avg_log_wage_destination

			
		// 1. Gravity equation//
		reghdfe log_prob_igt log_distance [aw=no_obs], absorb(current`type'#year`ieducfe' birth`type'#year`ieducfe') vce(cluster current`type'#year`ieducfe' birth`type'#year`ieducfe')
		qui sum no_obs if e(sample)
		local total_obs = `r(sum)'
		estimates store f1_gravity
		estadd local current_year "yes"
		estadd local birth_year  "yes"
		estadd local pair_fe "no"
		estadd scalar total_obs = `total_obs'
		estimates store f1_gravity
			
		* Add a robustness for small/large regions
		bys current`type' `educfe' year: egen dest_pop = total(sample_wt)
		bys year: egen med_dest_pop = median(dest_pop)
		gen dum_lg_pop = (dest_pop>=med_dest_pop)
			
		if "`dataset'" != "us" {
			gen dum_jakarta = (current_prov == 31)
			gen dum_java = (floor(current_prov/10) == 3)

			foreach heterog in lg_pop jakarta java {

				reghdfe log_prob_igt log_distance c.dum_`heterog'#c.log_distance [aw=no_obs], absorb(current`type'#year`ieducfe' birth`type'#year`ieducfe') vce(cluster current`type'#year`ieducfe' birth`type'#year`ieducfe')
				qui sum no_obs if e(sample)
				local total_obs = `r(sum)'
				estimates store r1_gravity_`heterog'
				estadd local current_year "yes"
				estadd local birth_year  "yes"
				estadd local pair_fe "no"
				estadd scalar total_obs = `total_obs'
				estimates store r1_gravity_`heterog'
				}
			}
			
	
		// 2. Wage on distance
		reghdfe log_avg_wage log_distance [aw=no_obs], absorb(current`type'#year`ieducfe' birth`type'#year`ieducfe') vce(cluster current`type'#year`ieducfe' birth`type'#year`ieducfe')
		qui sum no_obs if e(sample)
		local total_obs = `r(sum)'
		estimates store f2_distance_wage
		estadd local current_year "yes"
		estadd local birth_year  "yes"
		estadd local pair_fe "no"
		estadd scalar total_obs = `total_obs'

		// 3. Selection: wage on prob

		reghdfe log_avg_wage log_prob_igt [aw=no_obs], absorb(current`type'#year`ieducfe' birth`type'#year`ieducfe' /*current`type'#birth`type'*/) vce(cluster current`type'#year`ieducfe' birth`type'#year`ieducfe')
		qui sum no_obs if e(sample)
		local total_obs = `r(sum)'
		estimates store f3_wage_prob
		estadd local current_year "yes"
		estadd local birth_year  "yes"
		estadd local pair_fe "yes"
		estadd scalar total_obs = `total_obs'

		reghdfe log_avg_wage log_prob_igt log_distance [aw=no_obs], absorb(current`type'#year`ieducfe' birth`type'#year`ieducfe') vce(cluster current`type'#year`ieducfe' birth`type'#year`ieducfe')
		qui sum no_obs if e(sample)
		local total_obs = `r(sum)'
		estimates store f4_wage_prob_distance
		estadd local current_year  "yes"
		estadd local birth_year  "yes"
		estadd local pair_fe "no"
		estadd scalar total_obs = `total_obs'

		di in red "dataset is `dataset'"

		// 5. Compensating differential
		if regexm("`dataset'", "baseline")  {

			reghdfe log_avg_wage pca_ease [aw=no_obs], absorb(birth`type'#year`ieducfe' current`type'`ieducfe') vce(cluster birth`type'#year`ieducfe') //note, is a little sensitive to what level we cluster SE at//
			qui sum no_obs if e(sample)
			local total_obs = `r(sum)'
			estimates store f5_compensating
			estadd local current_year "no"
			estadd local birth_year "yes"
			estadd local pair_fe "no"
			estadd local current "yes"
			estadd scalar total_obs = `total_obs'

			}


		label var log_prob_ig "Log share migrating"
		label var log_distance "Log distance"
		capture label var pca_ease "Amenities"
		label var log_avg_wage_destination "Log avg. wage in destination"
		label var avg_log_wage_destination "Avg. log wage in destination"

		if "`hoh'" == "" & "female" == "" {
			local sample "Baseline sample: male head-of-household."
			local sample_title ""
			}
		else if "`hoh'" == "no" & "`female'" == "no" {
			local sample "(extended sample: all males)"
			local sample_title `sample'
			}
		else if "`hoh'" == "no" & "`female'" == "yes" {
			local sample "(extended sample: males and females)"
			local sample_title `sample'
			}

		estout f* using "$outpath/reduced_form_facts_`dataset'.tex", style(melanie_fancy) label replace mgroups("Movement costs" "Selection" "Compensating Diff." , pattern(1 0 1 0 1 0 ) span prefix(\multicolumn{@span}{c}{) suffix(}) ) collabels(,none) mlabel("$\log \pi_{odt}$" "$\log w_{odt}$ " "$\log w_{odt}$ " "$\log w_{odt}$ " "$\log w_{odt}$ " "$\log \pi_{odt}$ ", lhs("Dep. variable")) number cells(b(fmt(3)) se(par fmt(3) star)) stat(current_year birth_year current total_obs /*pair_fe*/ N, fmt("" "" "" 0) label("`destyearlabel'" "`origyearlabel'" "`destlabel'" "No. of individuals" "No. of region pairs")) note("$\log \pi_{odt}$ is the log of the share of population migrating from $ o $ to $ d $ in year $ t $. $\log w_{odt}$ is the log of the average wage of migrants from origin $ o $ in destination $ d $ in time $ t $. `obs' `datasource_note' Number of observations changes between columns because not all pairs with positive migration flows have observed wages. Amenity measure is the standardized value of the first principal component.") substitute("") title("`title' `sample'  `dropnativenote' `r3titlenote'")

		*! For the IFLS, I want to stack the wage-only with all. Easiest way to do this is to do two tables.
		if "`dataset'" == "ifls" | "`dataset'" == "ifls_wage" {

			if "`dataset'" == "ifls" {
				estout f* using "$outpath/reduced_form_facts_IFLS_stacked.tex", style(tex) replace label prehead(\begin{table} \begin{small} \begin{center}\begin{threeparttable}[b] \caption{ {@title}} \label{@title} \begin{tabular}{l*{@M}c} \toprule) posthead("\midrule") cells(b(fmt(3)) se(par fmt(3) star)) mgroups("Movement costs" "Selection" "Compensating Diff." , pattern(1 0 1 0 1 0 ) span prefix(\multicolumn{@span}{c}{) suffix(}) ) collabels(,none) mlabel("$\log \pi_{odt}$" "$\log w_{odt}$ " "$\log w_{odt}$ " "$\log w_{odt}$ " "$\log w_{odt}$ " "$\log \pi_{odt}$ ", lhs("Dep. variable")) number varlabels(,blist(log_distance "\multicolumn{@span}{l}{\emph{All individuals}} \\") elist(log_prob_igt "\midrule"))  title("`title' `sample'  `dropnativenote' `r3titlenote'") substitute("") stat(current_year birth_year total_obs /*pair_fe*/ N, fmt("" "" "" 0) label("`destyearlabel'" "`origyearlabel'"  "No. of individuals" "No. of region pairs")) 
				}

			else if "`dataset'" == "ifls_wage" {
				estout f* using "$outpath/reduced_form_facts_IFLS_stacked.tex", style(tex) append label postfoot(\bottomrule \end{tabular} \label{@title} \begin{tablenotes} \item {\footnotesize \emph{Notes: } @note } \end{tablenotes} \end{threeparttable} \end{center} \end{small} \end{table})  cells(b(fmt(3)) se(par fmt(3) star)) mlabel(,none) collabel(,none) varlabels(,blist(log_distance "\midrule \multicolumn{@span}{l}{\emph{Wage employees only}} \\") elist(log_prob_igt "\midrule")) note("$\log \pi_{odt}$ is the log of the share of population migrating from $ o $ to $ d $ in year $ t $. $\log w_{odt}$ is the log of the average wage of migrants from origin $ o $ in destination $ d $ in time $ t $. `obs' `datasource_note' Number of observations changes between columns because not all pairs with positive migration flows have observed wages. Amenity measure is the standardized value of the first principal component. Two-way clustering of standard errors at the origin-year and destination-year reported in Columns (1)-(4). Clustered standard errors, at the level of the origin-year, reported in Column (5).") stat(current_year birth_year  total_obs /*pair_fe*/ N, fmt("" "" "" 0) label("`destyearlabel'" "`origyearlabel'"  "No. of individuals" "No. of region pairs")) 
				}
			}
		
		}
		
end
