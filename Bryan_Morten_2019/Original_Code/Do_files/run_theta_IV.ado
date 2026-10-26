program define run_theta_IV

	*! Source file: run_theta_IV_28Nov2017

	syntax [varlist], nrep(real)	
	
	foreach country in ind us {

		foreach educ in all low high {

			foreach robusttype in "" droplarge dropclose {
	
				if "`country'" == "ind" {
					local type _prov
					}
				else if "`country'" == "us" {
					local type _state
					}

				forvalues rep = 1/`nrep' {

					use	"$structpath/Allan Structural Datasets/struct_dataset_`country'`type'_emp_educ_`educ'.dta", clear
					drop if year == 1976
					gen freq_wt_bootstrap = 1

					if `rep' != 1 {
						bsample, strata(year) weight(freq_wt_bootstrap)
						}

					gen current_rep = `rep'
					tempfile current_loop_data
					save `current_loop_data', replace


					if "`robusttype'" == "droplarge" {
						qui sum people_wt, detail
						drop if people_wt >= `r(p95)'
						}

					if "`robusttype'" == "dropclose" {
						drop if birth_distance <= 500
						}

				
*! First: make the instrument

					// Reshape to get all probs into current`type' from all birth`type'
					keep current`type' birth`type' year prob_ig
					rename prob_ig prob_i
					reshape wide prob_i, i(year current`type') j(birth`type')
					tempfile temp
					save `temp', replace

					// Merge onto dataset
					use `current_loop_data', clear
					merge m:1 year current`type' using `temp'
					assert _merge == 3
					drop _merge

					// Make own prob = 1 so doesn't appear when take the log
					levelsof current`type', local(levels)
					foreach prov of local levels {
						replace prob_i`prov' = 1 if birth`type' == `prov'
						}

					sort year current`type' birth`type'
					order year current`type' birth`type' prob_i*

					rename prob_ig prob_depvar
					gen log_prob_depvar = log(prob_depvar)
					gen log_wage_ig = log(wage_month_ig)
					gen log_distance = log(birth_distance`type')


					// Create the log terms and the square log terms
					foreach var of varlist prob_i* {
						gen logx_`var' = log(`var')
						replace logx_`var' = 0 if logx_`var' == . //for the instruments which have zero flows so this doesnt drop out of regression//
						gen sq_logx_`var' = log(`var')*log(`var')
						replace sq_logx_`var' = 0 if sq_logx_`var' == .
						}

					
					reg log_prob_depvar logx* sq_logx*
					predict pred_log_prob, xb


					replace people_nowt = people_nowt*freq_wt_bootstrap //so now some obs will get weight zero if not in the boostrap regression, others overweighted//
				
					// Here is the endogenous version//
					reghdfe log_wage_ig log_prob_depvar [aw=people_nowt], absorb(current`type'#year birth`type'#year)
					*poisson log_wage_ig log_prob_depvar  i.current`type'#year i.birth`type'#year [fw=freq_wt_bootstrap]
*reghdfe log_wage_ig log_prob_depvar , absorb(current`type'#year birth`type'#year)
					gen theta_1eta_endog = -1/_b[log_prob_depvar]

					// Here is the IV version//
					*ivpoisson gmm log_wage_ig (log_prob_depvar=pred_log_prob) i.current`type'#year i.birth`type'#year [fw=freq_wt_bootstrap], onestep
					reghdfe log_wage_ig (log_prob_depvar = pred_log_prob) [aw=people_nowt], absorb(current`type'#year birth`type'#year)
*reghdfe log_wage_ig (log_prob_depvar = pred_log_prob) , absorb(current`type'#year birth`type'#year)
					gen theta_1eta_iv = -1/_b[log_prob_depvar]

					* Add the first stage
					if `rep' == 1 {
						reghdfe log_prob_depvar pred_log_prob [aw=people_nowt], absorb(current`type'#year birth`type'#year)
						estimates store first_stage`robusttype'
						estadd local destXyear = "yes"
						estadd local origXyear = "yes"
						}


					
* Save var/mean moment for matlab					
* The equation is: Gamma(1-2/theta_1eta)/Gamma(1-1/theta_1eta)^2 - 1 = var_mean_ig
					
					di "current rep is `rep'"

					qui sum var_mean_month_ig [aw=freq_wt_bootstrap] //again, accounting for the boostrap. not weighting this by sample as wasnt' weigthing in matlab.//
					gen var_moment_save= `r(mean)'

					keep theta_1eta_endog theta_1eta_iv var_moment_save current_rep `bvar' `ovar'
					keep if _n == 1
					
					if `rep' == 1 {
						tempfile bootstrap_collect
						save `bootstrap_collect', replace
						}
					else {
						append using `bootstrap_collect'
						save `bootstrap_collect', replace
						}
					}

		
				sort current_rep
				outsheet theta_1eta_endog theta_1eta_iv  var_moment_save current_rep using "$structpath/data/theta_1eta_`country'_`educ'`robusttype'.csv" , comma replace //this is what we use in matlab//
				save "$structpath/data/theta_1eta_`country'_`educ'`robusttype'" , replace //this is for runnign the robustness region-by-region//
		

				}

			
			capture gen pred_log_prob = .
			label var pred_log_prob "Predicted log probability"

			estout first_stage* using "$outpath/first_stage_`country'_`educ'_`c(current_date)'.tex", style(melanie_fancy) replace number label mlabel("Baseline" "Drop large" "Drop close",lhs("Dep var: Log prob")) collabels(,none) cells(b(fmt(3)) se(par fmt(3) star)) stat(destXyear origXyear N r2 F, fmt(0 0 0 2 2) label("Destination X Year FE" "Origin X Year FE" "N")) title("First stage regression for migration flows") note("Table shows first-stage regression of migration probability on predicted probability. The unit of observation is a province-to-province-year flow. Column (2) drops the largest 5\% of flows when constructing the instrument. Column (3) drops observations within 500 km of a location when constructing the instrument.")

			}

		}

	
end
	

