program define Table4

	*! SOURCE: TABLE_FRECHET_28NOV2017
	
	local educ all
	local time _month
	local esttype nonparam
	

	if "`time'" == "_month" {
		local title_time "month, educ is `educ', esttype is `esttype'"
		}
	else if "`time'" == "_hour" {
		local title_time "hour, educ is `educ', esttype is `esttype'"
		}

	foreach country in ind us {

		if "`country'" == "ind" {
			local type _prov
			local keep "if year == 1995 | year == 2011 | year == 2012"
			local n_region 25
			}
		else if "`country'" == "us" {
			local type _state
			local keep "if year == 1990 | year == 2010"
			local n_region 51
			}

		// Read in the bootstrap file//
		insheet using $secdata/Public/matlab_bootstrap_theta_1etarho_`country'`time'_educ_`educ'_est_`esttype'.csv, comma clear

		gen iter_no = _n
		rename v1 theta_1eta_bs
		rename v2 rho_bs

		egen se_theta_1eta_bs = sd(theta_1eta)
		egen se_rho_bs = sd(rho)
			
		tempfile temp
		save `temp', replace
			
		use $secdata/Not_Public/dataset_structural_`country'`type'`time'_educ_`educ'_est_`esttype', clear

		capture drop _merge
			
		gen iter_no = 1 if theta_1eta != .
		merge m:1 iter_no using `temp'

		replace se_theta_1eta = se_theta_1eta_bs
		replace se_beta_rho = se_rho_bs

		assert transport_costs != . if _merge !=2 //with Poisson, shouldn't be missing, except for the bootstrap ones which have merge=2//

		gen theta_1eta_tilde = theta_1eta*(1-beta_rho)
		gen se_theta_1eta_tilde = 0
				
		*replace beta_rho = . if beta_rho == 0
		*replace se_beta_rho = . if se_beta_rho == 0
		*replace se_theta_1eta = 999 if se_theta_1eta == .

		* Switching over to an annual thing

		trick_stata_bs beta_rho theta_1eta  `keep'
		eststo e_`country'_`educ'
		sum transport_costs `keep'
		estadd scalar mean_tc = `r(mean)'
		sum theta_1eta_tilde `keep'
		estadd scalar theta_1etatilde = `r(mean)'

		label var beta_rho "$\rho$ (correlation)"
		*label var theta_1eta "$\theta_1eta$ (dispersion)"
		label var theta_1eta "$\theta$ (dispersion)"
		*label var theta_1eta_tilde "\tilde{\theta_1eta}$ (dispersion)"
		label var transport_costs "Mean mig. cost"

		if "`esttype'" == "nonparam" {
			local table_note "Source: estimates from structural estimation of model. Transport costs estimated non-parametrically. Bootstrapped standard errors reported."
			local table_title "Estimated Frechet parameters"
			}
		else if "`esttype'" == "dist" {
			local table_note "Source: estimates from structural estimation of model. Transport costs constrained to be a function of log distance. Bootstrapped standard errors reported."
			local table_title "Estimated Frechet parameters (parameterized model)"
			}

		}	

	capture gen beta_rho = .
	label var beta_rho "$\rho$ (correlation)"
	capture gen theta_1eta = .
	label var theta_1eta "$\theta$ (dispersion)"

		
	estout e_ind_`educ' e_us_`educ' using "$outpath/structural_rho_both_`time'_educ_`educ'_est_`esttype'.tex", replace number style(melanie_fancy) cells(b(star fmt(a2)) se(par fmt(a2))) stat(theta_1etatilde mean_tc, label("$\tilde{\theta} = \theta(1-\rho)$" "Mean migration cost (iceberg)")) label drop(_cons *b.* *.year, relax) mlabels("Indonesia" "U.S.")  collabels(,none) varlabels( , elist(theta_1eta, "\midrule")) title("`table_title'") note("`table_note'")


	


end
