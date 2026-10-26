/*******************************************************************************

Do-file "5. Replication analysis KLPS.do"

Replication code for 
Joan Hamory, Marieke Kleemans, Nicholas Y. Li, and Edward Miguel
Reevaluating Agricultural Productivity Gaps with Longitudinal Microdata
Created Aug 2020 using Stata version 14.2

This do-file uses the 4 datasets created by do-file "4. Creation of KLPS 
replication data.do" to replicate all figures and tables that use KLPS data 

Please contact Marieke Kleemans at kleemans@illinois.edu for questions

*******************************************************************************/



********************************************************************************
*** Figure 1: Productivity Gap in Total Earnings
********************************************************************************
use "Main_Analysis_KLPS.dta", clear

reg lninc urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc urban lnhour lnhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
xtreg lninc_h urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G

	preserve

	clear
	set obs 7
	gen num = _n
	gen coef = .
	gen sd = .
	gen pos_coef = 9

	* Our estimates
	local urban urban
	estimates restore A
	replace coef = _b[urban] if num == 4
	replace sd = _se[urban] if num  == 4
	estimates restore C
	replace coef = _b[urban] if num == 5
	replace sd = _se[urban] if num  == 5
	estimates restore F
	replace coef = _b[urban] if num == 6
	replace sd = _se[urban] if num  == 6
	estimates restore G
	replace coef = _b[urban] if num == 7
	replace sd = _se[urban] if num  == 7
	format coef %9.3f
	gen column = num
	gen ci_hi = coef + 1.96 * sd
	gen ci_lo = coef - 1.96 * sd

	#delimit ;
	twoway

	(rcap ci_hi ci_lo column if inrange(num, 6, 7), lwidth(thick) lcolor(gs6) msize(zero))
	(scatter coef column if inrange(num, 6, 7),
		msymbol(diamond) msize(2.8) mfcolor(gs6) mlcolor(gs6)
		mlabel(coef) mlabc(black) mlabv(pos_coef) mlabg(1) mlabsize(3))

	(rcap ci_hi ci_lo column if inrange(num, 4,5) , lwidth(thick) lcolor(gs12) msize(zero))
	(scatter coef column if inrange(num, 4, 5),
		msymbol(diamond) msize(2.8) mfcolor(gs12) mlcolor(gs12)
		mlabel(coef) mlabc(black) mlabv(pos_coef) mlabg(1) mlabsize(3)) ,
	yline(0, lcolor(gs5) lpattern(dash))
	xscale(range(3.5 6.5) off)
	yscale(range(-0.3 2.1) off)
	xsize(4)
	ysize(4)
	ylabel(0(0.5)2)
	fxsize(63.16)
	graphregion(color(white) margin(vlarge))
	legend(off)
	title("  D. Rural/Urban, Kenya", size(3.7) position(11) color(black))
	text(2.05 5 "KLPS", place(c) size(3.6))
	name(ken_ru, replace)
	;
	 #delimit cr

	graph save "Figure1_KLPS_ruralurban.gph", replace

	restore

*************************************************************************************
*** lninc_nonag_KLPS
reg lninc nonag [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc nonag lnhour lnhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
xtreg lninc_h nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G

	preserve

	clear
	set obs 7
	gen num = _n
	gen coef = .
	gen sd = .
	gen pos_coef = 9

	* GLW estimates
	replace coef = 1.273 if num == 1
	replace sd = 0 if num==1
	replace coef = 0.713 if num == 2
	replace sd = 0 if num==2

	replace num = 1.15 if num==1
	replace num = 1.85 if num==2

	* Our estimates
	estimates restore A
	replace coef = _b[nonag] if num == 4
	replace sd = _se[nonag] if num  == 4
	estimates restore C
	replace coef = _b[nonag] if num == 5
	replace sd = _se[nonag] if num  == 5
	estimates restore F
	replace coef = _b[nonag] if num == 6
	replace sd = _se[nonag] if num  == 6
	estimates restore G
	replace coef = _b[nonag] if num == 7
	replace sd = _se[nonag] if num  == 7
	format coef %9.3f
	gen column = num
	gen ci_hi = coef + 1.96 * sd
	gen ci_lo = coef - 1.96 * sd

	gen label = ""
	replace label = "Raw" in 1
	replace label = "Adjusted" in 2
	replace label = "Raw" in 4
	replace label = "Adjusted" in 5
	replace label = "FE, earnings" in 6
	replace label = "FE, inforinc_h" in 7

	gen pos_lab = 1

	* coef positioning
	replace pos_coef = 10 in 7

	#delimit ;
	twoway

	(rcap ci_hi ci_lo column if inrange(num, 6, 7), lwidth(thick) lcolor(gs6) msize(zero))
	(scatter coef column if inrange(num, 6, 7),
		msymbol(circle) msize(4) mfcolor(gs6) mlcolor(gs6)
		mlabel(coef) mlabc(black) mlabv(pos_coef) mlabg(1) mlabsize(3))
	(scatter ci_hi column if inrange(num, 6, 7),
		msymbol(circle) msize(zero) mfcolor(gs6) mlcolor(gs6)
		mlabel(label) mlabc(black) mlabv(pos_lab) mlabg(3) mlabsize(3.1))

	(rcap ci_hi ci_lo column if inrange(num, 4,5) , lwidth(thick) lcolor(gs12) msize(zero))
	(scatter coef column if inrange(num, 4,5),
		msymbol(circle) msize(4) mfcolor(gs12) mlcolor(gs12)
		mlabel(coef) mlabc(black) mlabv(pos_coef) mlabg(1) mlabsize(3))
	(scatter ci_hi column if inrange(num, 4,5),
		msymbol(circle) msize(zero) mfcolor(gs12) mlcolor(gs12)
		mlabel(label) mlabc(black) mlabv(pos_lab) mlabg(3) mlabsize(3.1))

	(rcap ci_hi ci_lo column if num < 3, lwidth(thick) lcolor(gs9) msize(zero))
	(scatter coef column if num <= 3,
		msymbol(circle) msize(4) mfcolor(white) mlcolor(gs12)
		mlabel(coef) mlabc(black) mlabv(pos_coef) mlabg(1) mlabsize(3))
	(scatter ci_hi column if num <= 3,
		msymbol(circle) msize(zero) mfcolor(none) mlcolor(none)
		mlabel(label) mlabc(black) mlabv(pos_lab) mlabg(3) mlabsize(3.1))  ,
	xline(2.9, noextend lcolor(gs8))
	yline(0, lcolor(gs5) lpattern(dash))
	l1title("Productivity Gap (log points)", size(3.6) margin(zero))
	xscale(range(0.5 7) off)
	yscale(range(-0.3 2.1))
	xsize(7.5)
	ysize(5)
	ylabel(0(0.5)2)
	fxsize(136.84)
	graphregion(color(white) margin(vlarge))
	legend(off)
	title("  B. Agriculture/Non-Agriculture, Kenya", size(3.7) position(11) color(black))
	text(2.05 5 "KLPS", place(c) size(3.6))
	text(2.05 1.5 "GLW", place(c) size(3.6))
	name(ken_ag, replace)
	;
	 #delimit cr

	graph save "Figure1_KLPS_agnonag.gph", replace
	restore

*** Combine figures ****

** End Figure Code Nonag Indonesia
	graph set eps fontface Garamond

* 	graph combine "D:\Documents\Research\KLPS migration study\Analysis\Panel do-files\Results IFLS\ind_nonag.gph" "D:\Documents\Research\KLPS migration study\Analysis\Panel do-files\Results IFLS\ind_urban.gph" "ken_nonag.gph" "ken_urban.gph" , ///
* graph combine "$folderIFLS\ind_nonag.gph" "$folderIFLS\ind_urban.gph" "ken_nonag.gph" "ken_urban.gph" , ///

graph combine Figure1_IFLS_agnonag.gph Figure1_IFLS_ruralurban.gph Figure1_KLPS_agnonag.gph Figure1_KLPS_ruralurban.gph , ///
		xsize(12) ///
		ysize(8) ///
		imargin(0 0 0 0) ///
		graphregion(color(white) lcolor(white))

graph save "Figure1.gph" , replace

		graph export "Figure1.eps" , replace

	graph set eps fontface default
	

********************************************************************************		
*** Figure 3: Event Study of Urban Migration
********************************************************************************
preserve
xtset pupid yrmth

*** Define move rural to urban
gen moveR2U = 1 if urban == 1 & l.urban == 0
gen temp = yrmth if moveR2U == 1
egen firstmoveR2U = min(temp) , by(pupid)
drop temp

* eventime
gen eventime = yrmth - firstmoveR2U

* generate event time dummies
	forvalues i = -60/60 {
		if `i' < 0 {
			gen timedum_`=-`i'' = eventime==`i'
		}
		else {
			gen timedum`i' = eventime==`i'
		}
	}

	* Event time -6 and 6 are endpoints
	gen endpoint_pre = eventime < -60
	gen endpoint_post = eventime > 60
	replace endpoint_post = 0 if missing(eventime)

	* Create continous stay dummy
	* Find first rural observation in post-eventime=0
	* stillurban is on before that and off after
	gen temp = eventime if urban==0 & eventime > 0
	egen first_postrural = min(temp) , by(pupid)
	drop temp

	gen stillurban = eventime < first_postrural & eventime >= 0


	* Partition event time dummies into Jakarta and not Jakarta
	gen temp = nairobi if eventime==0
	egen firsturban_nairobi = mean(temp), by(pupid)
	drop temp


	forvalues i=-60/60 {
		if `i' < 0 {
			gen timedum_nairobi_`=-`i'' = eventime==`i'&(firsturban_nairobi==1)
			gen timedum_notnairobi_`=-`i'' = eventime==`i'&(firsturban_nairobi==0)
		}
		else {
			gen timedum_nairobi`i' = eventime==`i'&(firsturban_nairobi==1)
			gen timedum_notnairobi`i' = eventime==`i'&(firsturban_nairobi==0)
		}
	}

	gen endpoint_nairobi_pre = endpoint_pre&(firsturban_nairobi==1)
	gen endpoint_notnairobi_pre = endpoint_pre&(firsturban_nairobi==0)

	gen endpoint_nairobi_post = endpoint_post&(firsturban_nairobi==1)
	gen endpoint_notnairobi_post = endpoint_post&(firsturban_nairobi==0)

	* Create continous stay dummy for nairobi
	gen stillurban_nairobi = stillurban if firsturban_nairobi==1
	gen stillurban_notnairobi = stillurban if firsturban_nairobi==0

	* Create interactions with urban for periods greater than 1
	* for survivor inforinc_h
	forvalues i=1/60 {
			gen timedum_survivor`i' = eventime==`i' & (stillurban==1)
			gen timedum_notsurvivor`i' = eventime==`i' & (stillurban==0)
  }

	gen endpoint_survivor_post = endpoint_post & (stillurban==1)
	gen endpoint_notsurvivor_post = endpoint_post & (stillurban==0)

	order timedum_notnairobi* , after(endpoint_nairobi_post)
	order endpoint_notnairobi* , after(timedum_notnairobi60)
	order stillurban_*nairobi , after(endpoint_notnairobi_post)
	order timedum_survivor*, after(stillurban_notnairobi)
	order timedum_notsurvivor*, after(timedum_survivor60)
	order endpoint_survivor*, after(timedum_notsurvivor60)
*
  xtreg lninc_h timedum_60-timedum_2 /// pre
	              timedum0-timedum60 /// post
								endpoint_pre endpoint_post /// pooled endpoints
								age_sq i.yrmth , ///
	  fe i(pupid) cluster(pupid) robust // controls

	** Count number of individuals
	* At time period of move
	count if timedum0 == 1
	* After 5 years
	count if timedum60 == 1

	* Create matrix of coefficients and upper and lower CI
	matrix coef = J(121,10,.)
	matrix colnames coef = eventime /// 1
	  coef coef_lci coef_uci /// 4
	  frac_urban frac_urban_lci frac_urban_uci /// 7
		hazard_cont hazard_cont_lci hazard_cont_uci
	forvalues i=-60/60 {
		matrix coef[`i'+61,1] = `i'

		if `i' <= -2 {
		  *eventime coefficients
		  matrix coef[`i'+61,2] = _b[timedum_`=-`i'']
			matrix coef[`i'+61,3] = _b[timedum_`=-`i''] - _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef[`i'+61,4] = _b[timedum_`=-`i''] + _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)

			*hazards and fractions
			matrix coef[`i'+61,5] = 0
			matrix coef[`i'+61,8] = 0
		}
		if `i' == -1 {
		  *eventime coefficients
		  matrix coef[`i'+61,2] = 0
			*hazards and fractions
			matrix coef[`i'+61,5] = 0
			matrix coef[`i'+61,8] = 0
		}
		if `i' >= 0 {
		  *eventime coefficients
			matrix coef[`i'+61,2] = _b[timedum`i']
			matrix coef[`i'+61,3] = _b[timedum`i'] - _se[timedum`i']*invttail(e(df_r), 0.025)
			matrix coef[`i'+61,4] = _b[timedum`i'] + _se[timedum`i']*invttail(e(df_r), 0.025)
			*fraction urban
			* include max/min so lower ci doesn't go below zero or above 1
			quietly sum urban if eventime==`i'
			matrix coef[`i'+61,5] = 100*r(mean)
			matrix coef[`i'+61,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef[`i'+61,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			*urban survival
			* include max so lower ci doesn't go below zero or above 1
			quietly sum stillurban if eventime==`i'
			matrix coef[`i'+61,8] = 100*r(mean)
			matrix coef[`i'+61,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef[`i'+61,10] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}
	}


  xtreg lninc_h timedum_nairobi_60-timedum_nairobi_2 /// pre in Jakarta
	              timedum_nairobi0-timedum_nairobi60 /// post in Jakarta
								timedum_notnairobi_60-timedum_notnairobi_2 /// pre in not Jakarta
								timedum_notnairobi0-timedum_notnairobi60 /// post in not Jakarta
								endpoint_nairobi_pre endpoint_nairobi_post /// pooled endpoints in Jakarta
								endpoint_notnairobi_pre endpoint_notnairobi_post /// pooled endpoints in Jakarta
								age_sq i.yrmth , ///
	  fe i(pupid) cluster(pupid) robust // controls

	* Create matrix of coefficients and upper and lower CI for Jakarta and Not Jakarta
	matrix coef_nairobi = J(121,10,.)
	matrix coef_notnairobi = J(121,10,.)

	matrix colnames coef_nairobi = eventime /// 1
	  coef_nairobi coef_nairobi_lci coef_nairobi_uci /// 4
	  frac_urban_nairobi frac_urban_nairobi_lci frac_urban_nairobi_uci /// 7
		hazard_cont_nairobi hazard_cont_nairobi_lci hazard_cont_nairobi_uci

	matrix colnames coef_notnairobi = eventime /// 1
	  coef_notnairobi coef_notnairobi_lci coef_notnairobi_uci /// 4
	  frac_urban_notnairobi frac_urban_notnairobi_lci frac_urban_notnairobi_uci /// 7
		hazard_cont_notnairobi hazard_cont_notnairobi_lci hazard_cont_notnairobi_uci


	forvalues i=-60/60 {
		matrix coef_nairobi[`i'+61,1] = `i'
		matrix coef_notnairobi[`i'+61,1] = `i'


		** Nairobi
		if `i' <= -2 {
		  *eventime coefficients
		  matrix coef_nairobi[`i'+61,2] = _b[timedum_nairobi_`=-`i'']
			matrix coef_nairobi[`i'+61,3] = _b[timedum_nairobi_`=-`i''] - _se[timedum_nairobi_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef_nairobi[`i'+61,4] = _b[timedum_nairobi_`=-`i''] + _se[timedum_nairobi_`=-`i'']*invttail(e(df_r), 0.025)


			*hazards and fractions
			matrix coef_nairobi[`i'+61,5] = 0
			matrix coef_nairobi[`i'+61,8] = 0
		}
		if `i' == -1 {
		  *eventime coefficients
		  matrix coef_nairobi[`i'+61,2] = 0
			*hazards and fractions
			matrix coef_nairobi[`i'+61,5] = 0
			matrix coef_nairobi[`i'+61,8] = 0
		}
		if `i' >= 0 {
		  *eventime coefficients
			matrix coef_nairobi[`i'+61,2] = _b[timedum_nairobi`i']
			matrix coef_nairobi[`i'+61,3] = _b[timedum_nairobi`i'] - _se[timedum_nairobi`i']*invttail(e(df_r), 0.025)
			matrix coef_nairobi[`i'+61,4] = _b[timedum_nairobi`i'] + _se[timedum_nairobi`i']*invttail(e(df_r), 0.025)
			*fraction urban
			* include max/min so lower ci doesn't go below zero or above 1
			quietly sum urban if eventime==`i' & firsturban_nairobi==1
			matrix coef_nairobi[`i'+61,5] = 100*r(mean)
			matrix coef_nairobi[`i'+61,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_nairobi[`i'+61,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			*urban survival
			* include max so lower ci doesn't go below zero or above 1
			quietly sum stillurban_nairobi if eventime==`i'
			matrix coef_nairobi[`i'+61,8] = 100*r(mean)
			matrix coef_nairobi[`i'+61,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_nairobi[`i'+61,10] =100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}


		** Not Nairobi
		if `i' <= -2 {
		  *eventime coefficients
		  matrix coef_notnairobi[`i'+61,2] = _b[timedum_notnairobi_`=-`i'']
			matrix coef_notnairobi[`i'+61,3] = _b[timedum_notnairobi_`=-`i''] - _se[timedum_notnairobi_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef_notnairobi[`i'+61,4] = _b[timedum_notnairobi_`=-`i''] + _se[timedum_notnairobi_`=-`i'']*invttail(e(df_r), 0.025)


			*hazards and fractions
			matrix coef_notnairobi[`i'+61,5] = 0
			matrix coef_notnairobi[`i'+61,8] = 0
		}
		if `i' == -1 {
		  *eventime coefficients
		  matrix coef_notnairobi[`i'+61,2] = 0
			*hazards and fractions
			matrix coef_notnairobi[`i'+61,5] = 0
			matrix coef_notnairobi[`i'+61,8] = 0
		}
		if `i' >= 0 {
		  *eventime coefficients
			matrix coef_notnairobi[`i'+61,2] = _b[timedum_notnairobi`i']
			matrix coef_notnairobi[`i'+61,3] = _b[timedum_notnairobi`i'] - _se[timedum_notnairobi`i']*invttail(e(df_r), 0.025)
			matrix coef_notnairobi[`i'+61,4] = _b[timedum_notnairobi`i'] + _se[timedum_notnairobi`i']*invttail(e(df_r), 0.025)
			*fraction urban
			* include max/min so lower ci doesn't go below zero or above 1
			quietly sum urban if eventime==`i' & firsturban_nairobi==0
			matrix coef_notnairobi[`i'+61,5] = 100*r(mean)
			matrix coef_notnairobi[`i'+61,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_notnairobi[`i'+61,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			*urban survival
			* include max so lower ci doesn't go below zero or above 1
			quietly sum stillurban_notnairobi if eventime==`i'
			matrix coef_notnairobi[`i'+61,8] = 100*r(mean)
			matrix coef_notnairobi[`i'+61,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_notnairobi[`i'+61,10] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}
	}


  xtreg lninc_h timedum_60-timedum_2 /// pre
							  timedum0 /// first period
								timedum_survivor1-timedum_survivor60 /// post for survivors
								timedum_notsurvivor1-timedum_notsurvivor60 /// post for not survivors
								endpoint_pre /// pre end points
								endpoint_survivor_post endpoint_notsurvivor_post /// pooled endpoints for survivors
								age_sq i.yrmth , ///
	  fe i(pupid) cluster(pupid) robust // controls


	matrix coef_survivor = J(121,10,.)
	matrix coef_notsurvivor = J(121,10,.)

	matrix colnames coef_survivor = eventime /// 1
	  coef_survivor coef_survivor_lci coef_survivor_uci /// 4
	  frac_urban_survivor frac_urban_survivor_lci frac_urban_survivor_uci /// 7
		hazard_cont_survivor hazard_cont_survivor_lci hazard_cont_survivor_uci

	matrix colnames coef_notsurvivor = eventime /// 1
	  coef_notsurvivor coef_notsurvivor_lci coef_notsurvivor_uci /// 4
	  frac_urban_notsurvivor frac_urban_notsurvivor_lci frac_urban_notsurvivor_uci /// 7
		hazard_cont_notsurvivor hazard_cont_notsurvivor_lci hazard_cont_notsurvivor_uci


	forvalues i=-60/60 {
		matrix coef_survivor[`i'+61,1] = `i'
		matrix coef_notsurvivor[`i'+61,1] = `i'


		** Survivor
		if `i' <= -2 {
		  *eventime coefficients
		  matrix coef_survivor[`i'+61,2] = _b[timedum_`=-`i'']
			matrix coef_survivor[`i'+61,3] = _b[timedum_`=-`i''] - _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef_survivor[`i'+61,4] = _b[timedum_`=-`i''] + _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)


			*hazards and fractions
			matrix coef_survivor[`i'+61,5] = 0
			matrix coef_survivor[`i'+61,8] = 0
		}
		if `i' == -1 {
		  *eventime coefficients
		  matrix coef_survivor[`i'+61,2] = 0
			*hazards and fractions
			matrix coef_survivor[`i'+61,5] = 0
			matrix coef_survivor[`i'+61,8] = 0
		}
		if `i' == 0 {
			*eventime coefficients
		  matrix coef_survivor[`i'+61,2] = _b[timedum0]
			matrix coef_survivor[`i'+61,3] = _b[timedum0] - _se[timedum0]*invttail(e(df_r), 0.025)
			matrix coef_survivor[`i'+61,4] = _b[timedum0] + _se[timedum0]*invttail(e(df_r), 0.025)

			* Hazards and fractions
			* include max/min so lower ci doesn't go below zero or above 1
			quietly sum urban if eventime==`i'
			matrix coef_survivor[`i'+61,5] = 100*r(mean)
			matrix coef_survivor[`i'+61,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_survivor[`i'+61,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			*urban survival
			* include max so lower ci doesn't go below zero or above 1
			quietly sum stillurban if eventime==`i'
			matrix coef_survivor[`i'+61,8] = 100*r(mean)
			matrix coef_survivor[`i'+61,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_survivor[`i'+61,10] =100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}
		if `i' > 0 {
		  *eventime coefficients
			matrix coef_survivor[`i'+61,2] = _b[timedum_survivor`i']
			matrix coef_survivor[`i'+61,3] = _b[timedum_survivor`i'] - _se[timedum_survivor`i']*invttail(e(df_r), 0.025)
			matrix coef_survivor[`i'+61,4] = _b[timedum_survivor`i'] + _se[timedum_survivor`i']*invttail(e(df_r), 0.025)
			*fraction urban
			* include max/min so lower ci doesn't go below zero or above 1
			quietly sum urban if eventime==`i'
			matrix coef_survivor[`i'+61,5] = 100*r(mean)
			matrix coef_survivor[`i'+61,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_survivor[`i'+61,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			*urban survival
			* include max so lower ci doesn't go below zero or above 1
			quietly sum stillurban if eventime==`i'
			matrix coef_survivor[`i'+61,8] = 100*r(mean)
			matrix coef_survivor[`i'+61,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_survivor[`i'+61,10] =100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}

		** Not Survivor
		if `i' == 0 {
		  matrix coef_notsurvivor[`i'+61,2] = _b[timedum0]
			matrix coef_notsurvivor[`i'+61,3] = _b[timedum0] - _se[timedum0]*invttail(e(df_r), 0.025)
			matrix coef_notsurvivor[`i'+61,4] = _b[timedum0] + _se[timedum0]*invttail(e(df_r), 0.025)

		}
		if `i' > 0 {
		  *eventime coefficients
			matrix coef_notsurvivor[`i'+61,2] = _b[timedum_notsurvivor`i']
			matrix coef_notsurvivor[`i'+61,3] = _b[timedum_notsurvivor`i'] - _se[timedum_notsurvivor`i']*invttail(e(df_r), 0.025)
			matrix coef_notsurvivor[`i'+61,4] = _b[timedum_notsurvivor`i'] + _se[timedum_notsurvivor`i']*invttail(e(df_r), 0.025)

		}
	}

  ****************************
	clear

	svmat coef , names(col)

	label var eventime "Years relative to first urban move"
	replace eventime = eventime/12

	* Graph event study
	graph twoway ///
		(line coef_lci eventime, lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
		(line coef_uci eventime, lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
	  (line coef eventime, lcolor(black) lwidth(medthick)) ///
		(pcarrowi 0.8 -0.3 0.8 -0.8, lcolor(black) mcolor(black) mlabcolor(black)) ///
		(pcarrowi 0.8 0.1 0.8 0.6, lcolor(black) mcolor(black) mlabcolor(black)), /// arrows
		text(0.88 -0.63 "Rural") ///
		text(0.88 0.5 "Urban") ///
		xline(`=-1/12', lcolor(black) lpattern(dot)) ///
		yline(0, lcolor(black) lwidth(thin)) ///
		xlabel(-5(1)5, grid nolabels) ///
		ylabel(-1(0.5)1, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		xtitle("") ///
		ytitle("Urban Wage Gap (log points)") ///
		name(eventstudy_klps, replace) ///
		nodraw

	* Graph Survival Rate in Urban areas
	graph twoway ///
		(line hazard_cont_lci eventime if eventime >= 0, lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
		(line hazard_cont_uci eventime if eventime >= 0, lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
	  (line hazard_cont eventime if eventime >= 0, lcolor(black) lwidth(medthick)) , ///
		xline(`=-1/12', lcolor(black) lpattern(dot)) ///
		xlabel(-5(1)5, grid) ///
		ylabel(0(20)100, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		ytitle("Urban Survival Rate (percent)") ///
		name(survival_klps, replace) ///
		nodraw

  graph set eps fontface Garamond
	graph set window fontface Garamond

  graph combine eventstudy_klps survival_klps , ///
	  rows(2) ///
		imargin(0 0 0 0) ///
		graphregion(color(white) lcolor(white)) ///
		ysize(6)

	graph export "Figure3_KLPS.eps", replace

	graph set window fontface default
	graph set eps fontface default

restore	
********************************************************************************		
*** Table 1: Non-Agriculture/Agriculture and Urban/Rural
********************************************************************************
preserve

lab var nonag " "
lab var urban "Urban dummy"
label define lab_nonag 0 "Agriculture" 1 "Non-Agriculture"
label define lab_urban 0 "Rural" 1 "Urban"
label values nonag lab_nonag
label values urban lab_urban

** Populate a matrix
matrix xtab = J(3,3,.)

* Rural column
sum nonag if urban==0
matrix xtab[1,1] = round((1-r(mean))*100, 0.1) + 0.0333
matrix xtab[2,1] = round(r(mean)*100, 0.1) + 0.0333
matrix xtab[3,1] = r(N)

* Urban column
sum nonag if urban==1
matrix xtab[1,2] = round((1-r(mean))*100, 0.1) + 0.0333
matrix xtab[2,2] = round(r(mean)*100, 0.1) + 0.0333
matrix xtab[3,2] = r(N)

* All column
sum nonag
matrix xtab[1,3] = round((1-r(mean))*100, 0.1) + 0.0333
matrix xtab[2,3] = round(r(mean)*100, 0.1) + 0.0333
matrix xtab[3,3] = r(N)


esttab matrix(xtab, fmt("%7.4f %7.4f %10.0fc" "%7.4f %7.4f %10.0fc"  "%7.4f %7.4f %10.0fc" )) ///
  using "Table1_KLPS_PanelB.tex", replace ///
  type booktabs ///
  collabels("Rural" "Urban" "Total") ///
	varlabels(r1 "Agriculture" r2 "Non-Agriculture" r3 "Number of Observations") ///
	nomtitles ///
	width(0.7\textwidth) ///
	substitute(333 \%)
restore
********************************************************************************
preserve
use "Consumption_Analysis_KLPS.dta", clear
*** Adding restrictions for SubsistenceAg
keep if !missing(urban)
keep if !missing(female)
keep if !missing(age)
keep if !missing(educyr)

drop nonag
gen nonag = .
replace nonag = 1 if nonaghour > aghour_notdecmaker & aghour_notdecmaker ~= . & nonaghour ~= .
replace nonag = 0 if nonaghour < aghour_notdecmaker & aghour_notdecmaker ~= . & nonaghour ~= .
replace nonag = 1 if nonaghour > 0 & nonaghour ~= . & aghour_notdecmaker == .
replace nonag = 0 if aghour_notdecmaker > 0 & nonaghour == . & aghour_notdecmaker ~= .

replace nonag = 0 if (abs(aghour_notdecmaker - nonaghour) < 10^-2) & aghour_notdecmaker ~= . & nonaghour ~= .
replace nonag = . if nonaghour == 0 & aghour_notdecmaker == 0
replace nonag = . if nonaghour == 0 & aghour_notdecmaker == .
replace nonag = . if nonaghour == . & aghour_notdecmaker == 0

keep if !missing(nonag)
keep if !missing(lninc_notdecmaker)
keep if !missing(lnhour_notdecmaker)
keep if !missing(lninc_h_notdecmaker)

gen sampleKLPS3 = .
replace sampleKLPS3 = 1 if yrmth_interview_KLPS3 - yrmth < 12
keep if sampleKLPS3  == 1

lab var nonag " "
lab var urban "Urban dummy"
label define lab_nonag 0 "Agriculture" 1 "Non-Agriculture"
label define lab_urban 0 "Rural" 1 "Urban"
label values nonag lab_nonag
label values urban lab_urban

** Populate a matrix
matrix xtab = J(3,3,.)

* Rural column
sum nonag if urban==0
matrix xtab[1,1] = round((1-r(mean))*100, 0.1) + 0.0333
matrix xtab[2,1] = round(r(mean)*100, 0.1) + 0.0333
matrix xtab[3,1] = r(N)

* Urban column
sum nonag if urban==1
matrix xtab[1,2] = round((1-r(mean))*100, 0.1) + 0.0333
matrix xtab[2,2] = round(r(mean)*100, 0.1) + 0.0333
matrix xtab[3,2] = r(N)

* All column
sum nonag
matrix xtab[1,3] = round((1-r(mean))*100, 0.1) + 0.0333
matrix xtab[2,3] = round(r(mean)*100, 0.1) + 0.0333
matrix xtab[3,3] = r(N)

esttab matrix(xtab, fmt("%7.4f %7.4f %10.0fc" "%7.4f %7.4f %10.0fc"  "%7.4f %7.4f %10.0fc" )) ///
  using "Table1_KLPS_PanelC.tex", replace ///
  type booktabs ///
  collabels("Rural" "Urban" "Total") ///
	varlabels(r1 "Agriculture" r2 "Non-Agriculture" r3 "Number of Observations") ///
	nomtitles ///
	width(0.7\textwidth) ///
	substitute(333 \%)

restore


********************************************************************************		
*** Table 2_KLPS: Summary Statistics											 
********************************************************************************
egen nonag_ever = max(nonag) , by(pupid)

  drop educpri-educuni

  gen educpri = educlv >= 2 if !missing(educlv)
  gen educsec = educlv >= 6 if !missing(educlv)
  gen educcol = educlv >= 8 if !missing(educlv)

  * 585 kids have years of education = 7 but no education level.

  replace educpri = 0 if missing(educpri) & educyr == 7
  replace educsec = 0 if missing(educsec) & educyr == 7
  replace educcol = 0 if missing(educcol) & educyr == 7

  * To make consistent with years of education measure, only record for
  * kids not missing years of education
  replace educpri = . if missing(educyr)
  replace educsec = . if missing(educyr)
  replace educcol = . if missing(educyr)

  * Collapse the data to the individual level
  collapse (first) ravens educpri educsec educcol ///
	  migrU_ever migr_ever nonag_ever female, by(pupid)

  label var ravens "Raven's Z-score"
  label var educpri "Primary Ed."
  label var educsec "Secondary Ed."
  label var educcol "College"
  label var female "Female"
  label var migrU_ever "Urban Migrants"
  label var migr_ever "Ever Migrated"


  local covs educpri educsec educcol female ravens

  eststo all: estpost sum `covs'
  eststo neverU: estpost sum `covs' if migrU_ever==0
  eststo migrU: estpost sum `covs' if migrU_ever==1

  eststo counts: estpost sum `covs' if !missing(migrU_ever)

  * Columnwise counts
  quietly count
  local num_total = r(N)
  quietly count if migrU_ever==0
  local num_neverU = r(N)
  quietly count if migrU_ever==1
  local num_migrU = r(N)


  esttab all neverU migrU migrU migrU counts ///
    using "Table2_KLPS.tex", replace type fragment ///
	  cells(mean(pattern(1 1 1 0 0 0) fmt(%9.3f))& ///
          count(pattern(0 0 0 0 0 1) fmt(%9.0f)) ///
	        sd(par([ ]) pattern(1 1 1 0 0 0) fmt(%9.3f))) ///
	  noobs ///
		title("Kenya") ///
		mlabels("N=`num_total'" ///
						"N=`num_neverU'" ///
				    "N=`num_migrU'" ///
						"" ///
						"" ///
				    "") ///
		nonumbers ///
			mgroups("All" ///
					    "Always Rural" ///
				      "\shortstack{Rural-to-Urban\\Migrants}" ///
					    "Always Urban" ///
				      "\shortstack{Urban-to-Rural\\Migrants}" ///
				      "Obs" , ///
				pattern(1 1 1 1 1 1) ///
				span ///
				prefix(\multicolumn{@span}{c}{) ///
				suffix(})) ///
		collabels(none) ///
		label ///
		legend ///
		booktabs


********************************************************************************		
*** Table 3: Correlates of Employment in Non-Agriculture and Urban Migration
********************************************************************************
preserve

*** IFLS analysis
use "Table3_IFLS.dta", clear
rename ravens_norm ravens		// Only to fix labels
reg nonag_ever educpri educsec educcol female ravens if always_rural==1 | migrRU_ever==1, robust
est store A
reg migrRU_ever educpri educsec educcol female ravens if always_rural==1 | migrRU_ever==1, robust
est store C

restore

*** KLPS analysis
reg nonag_ever educpri educsec educcol female ravens, robust
est store B
reg migrU_ever educpri educsec educcol female ravens, robust
est store D

esttab A B C D using "Table3.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S S S) collabels(none) ///	// drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mgroups("\centering\shortstack{Dependent Variable:\\Non-Agricultural Employment}" "\centering\shortstack{Dependent Variable:\\Urban Migration}", pattern(1 0 1 0) prefix(\multicolumn{@span}{p{5.5cm}}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mtitle("Indonesia" "Kenya" "Indonesia" "Kenya")  /// // "Movers" "Urban Movers"
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	//	stats(N, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{S}{@}") labels(`"Observations"'))
	stats(N, fmt(0) ///
	labels(`"Observations"'))


********************************************************************************
*** Table 4: Non-Agricultural/Agricultural Gap in Earnings
********************************************************************************
use "Main_Analysis_KLPS.dta", clear

reg lninc nonag [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc nonag lnhour lnhour_sq i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store B
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq ravens ravens_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq ravens ravens_sq voced voced_treat_info voced_treat_voucher i.yrmth if NA_mover == 1 [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local moverUonly "Y" , replace
estadd local cluster `e(N_clust)', replace
est store E
xtreg lninc nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
xtreg lninc nonag lnhour lnhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lninc_h nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H
xtreg lninc_h_real nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store I

esttab A B C D E F G H I using "Table4_KLPS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons *yrmth* voced voced_treat_info voced_treat_voucher age age_sq) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "" "" "" "" "Log Wage" "Log Real Wage")  ///
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE timeFE moverUonly N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Time fixed effects"' `"Switchers only"' `"Number of observations"' `"Number of individuals"'))

	
********************************************************************************		
*** Table 5: Urban/Rural Gap in Earnings
********************************************************************************
*** lninc_urban_KLPS_extraC6
reg lninc urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc urban lnhour lnhour_sq i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store B
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq ravens ravens_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq ravens ravens_sq voced voced_treat_info voced_treat_voucher i.yrmth if U_mover == 1 [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local moverUonly "Y" , replace
estadd local cluster `e(N_clust)', replace
est store E
xtreg lninc urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
xtreg lninc urban lnhour lnhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lninc_h urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H
xtreg lninc_h_real urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store I

esttab A B C D E F G H I using "Table5_KLPS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons *yrmth* voced voced_treat_info voced_treat_voucher age age_sq) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "" "" "" "" "Log Wage" "Log Real Wage")  ///
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE timeFE moverUonly N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Time fixed effects"' `"Switchers only"' `"Number of observations"' `"Number of individuals"'))	

	
********************************************************************************
*** Appendix Figures and Tables
********************************************************************************
*** Figure A4: Event Study of Urban Migration for Urban Survivors
********************************************************************************
preserve

	clear

	svmat coef_survivor , names(col)
	drop eventime
	svmat coef_notsurvivor, names(col)
	//drop eventime
	//svmat coef, names(col)

	label var eventime "Years relative to first urban move"
	replace eventime = eventime/12


	* Interpolate to get the bounds equal to 1
  foreach point of varlist coef* {
	  sort eventime
		* 1) Identify points that outside of range
		gen oor = !inrange(`point', -1, 1) if !missing(`point')


		* 2) Figure out transition points that switch from out of range to in range
		gen out_in = oor == 1 & oor[_n+1] == 0

		gen Fdata = `point'[_n+1]

		* 3) For those points, generate a new point
		expand 2 if out_in==1, gen(new)
			* Need to make these points missing for other plotted variables
			foreach var of varlist coef* hazard* {
				if "`point'" != "`var'" {
					replace `var' = . if new==1
				}
			}
		sort eventime new

		* 4) Generate plotted points
		* Want to maintain slope. So this will be (y2-y1)/(x2-x1) = (y2-/+1)/(x2-??)
		* x2-?? = (y2-/+1)*(x2-x1)/(y2-y1)
		* ?? = x2 - (y2-/+1)*1/12/(y2-y1)
		replace eventime = eventime + 1/12 - ///
											 (Fdata - sign(Fdata))/12 / ///
											 (Fdata - `point') if new == 1

		replace `point' = sign(Fdata) if new==1


		//list if out_in==1

		drop new out_in Fdata

		* Do the same thing for points that switch from in to out


		* 2) Figure out transition points that switch from out of range to in range
		gen in_out = oor == 1 & oor[_n-1] == 0

		gen Ldata = `point'[_n-1]

		* 3) For those points, generate a new point
		expand 2 if in_out==1, gen(new)
			* Need to make these points missing for other plotted variables
			foreach var of varlist coef* hazard* {
				if "`point'" != "`var'" {
					replace `var' = . if new==1
				}
			}
		sort eventime new

		* 4) Generate plotted points
		* Want to maintain slope. So this will be (y2-y1)/(x2-x1) = (y2-/+1)/(??-x1)
		* ??-x1 = (y2-/+1)*(x2-x1)/(y2-y1)
		* ?? = x1 + (y2-/+1)*1/12/(y2-y1)
		replace eventime = eventime - 1/12 + ///
											 (Ldata - sign(Ldata))/12 / ///
											 (Ldata - `point') if new == 1

		replace `point' = sign(Ldata) if new==1


		//list if in_out==1

		drop new oor in_out Ldata

		* Generate a plot flag
		gen `point'_plotflag = !missing(`point')

		* Last step is to replace all the out of range data with missing
		replace `point' = . if !inrange(`point',-1,1)
	}


	* Graph event study
	local y_pos_survivor = coef_survivor_uci[102]+0.1
	local x_pos_survivor = eventime[102]

	local y_pos_notsurvivor = coef_notsurvivor_lci[108]-0.1
	local x_pos_notsurvivor = eventime[108]

	graph twoway ///
		(line coef_survivor_lci eventime if inrange(coef_survivor_lci,-1,1), lcolor(black) lwidth(thin) lpattern(dash) cmissing(n)) ///
		(line coef_survivor_uci eventime if inrange(coef_survivor_uci,-1,1), lcolor(black) lwidth(thin) lpattern(dash) cmissing(n)) ///
		(line coef_notsurvivor_lci eventime if inrange(coef_notsurvivor_lci,-1,1), lcolor(gs10) lwidth(thin) lpattern(dash) cmissing(n)) ///
		(line coef_notsurvivor_uci eventime if inrange(coef_notsurvivor_uci,-1,1), lcolor(gs10) lwidth(thin) lpattern(dash) cmissing(n)) ///
	  (line coef_survivor eventime if inrange(coef_survivor,-1,1), lcolor(black) lwidth(medthick)) ///
	  (line coef_notsurvivor eventime if inrange(coef_notsurvivor,-1,1), lcolor(gs10) lwidth(medthick)) ///
		(pcarrowi 0.8 -0.3 0.8 -0.8, lcolor(black) mcolor(black) mlabcolor(black)) ///
		(pcarrowi 0.8 0.1 0.8 0.6, lcolor(black) mcolor(black) mlabcolor(black)), /// arrows
		text(0.88 -0.63 "Rural") ///
		text(0.88 0.5 "Urban") ///
		xline(`=-1/12', lcolor(black) lpattern(dot)) ///
		yline(0, lcolor(black) lwidth(thin)) ///
		xlabel(-5(1)5, grid nolabels) ///
		ylabel(-1(0.5)1, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		xtitle("") ///
		ytitle("Urban Wage Gap (log points)") ///
		text(`y_pos_survivor' `x_pos_survivor'  "Survivor", placement(n) color(black)) ///
		text(`y_pos_notsurvivor' `x_pos_notsurvivor'  "Not Survivor", placement(s) color(gs7)) ///
		name(eventstudy_klps_survivor, replace) ///
		nodraw

	* Graph Survival Rate in Urban areas
	graph twoway ///
		(line hazard_cont_survivor_lci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(y)) ///
		(line hazard_cont_survivor_uci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(y)) ///
	  (line hazard_cont_survivor eventime if eventime >= 0 , lcolor(black) lwidth(medthick)) , ///
		xline(`=-1/12', lcolor(black) lpattern(dot)) ///
		xlabel(-5(1)5, grid) ///
		ylabel(0(20)100, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		ytitle("Urban Survival Rate (percent)") ///
		name(survival_klps, replace) ///
		nodraw

  graph set eps fontface Garamond
	graph set window fontface Garamond

  graph combine eventstudy_klps_survivor survival_klps , ///
	  rows(2) ///
		imargin(0 0 0 0) ///
		graphregion(color(white) lcolor(white)) ///
		ysize(6)

	graph export "FigureA4_KLPS.eps", replace

	graph set window fontface default
	graph set eps fontface default

restore


********************************************************************************
*** Figure A7: Marginal Distributions of Cognitive Ability
********************************************************************************
use "Intergen_Analysis_KLPS.dta", clear

egen hasmiss = rowmiss(`control5')
drop if hasmiss >0
drop hasmiss

foreach depvar in child_cogn_index {
	eststo `depvar'_reg1: reg `depvar' 1.child_urban_birth, cluster(pupid)
	estadd local square "N"
	eststo `depvar'_reg2: reg `depvar' 1.child_urban_birth child_female, cluster(pupid)
	estadd local square "N"
	eststo `depvar'_reg3: reg `depvar' 1.child_urban_birth child_female parent_female parent_age_atchildbirth, cluster(pupid)
	estadd local square "N"
	eststo `depvar'_reg4: reg `depvar' 1.child_urban_birth child_female parent_female parent_age_atchildbirth parent_educ parent_raven, cluster(pupid)
	estadd local square "N"
	eststo `depvar'_reg5: reg `depvar' 1.child_urban_birth child_female parent_female parent_age_atchildbirth parent_educ parent_raven parent_age_atchildbirth_sq parent_educ_sq parent_raven_sq, cluster(pupid)
	estadd local square "Y"
}

graph twoway ///
  (kdensity child_cogn_index if child_urban_birth==0, lcolor(gs7) lpattern(solid)) ///
	(kdensity child_cogn_index if child_urban_birth==1, lcolor(black) lpatter(dash)), ///
	  graphregion(color(white)) ///
		ytitle("Density") xtitle("Cognitive Ability, Normalized") ///
		legend(label(1 "Born Rural") label(2 "Born Urban")) ///
		xlabel(-4(2)4)
graph export "FigureA7_KLPS.eps", replace


********************************************************************************
*** Figure A8: Joint Distribution of Rural and Urban Productivities
********************************************************************************
use "Main_Analysis_KLPS.dta", clear
* Variable for first observation by pupid
sort pupid yrmth
by pupid: gen obsnum = _n

** Main estimates
gen double pupid_u = pupid*10+urban

areg lninc_h  age_sq i.yrmth [aw=weight], a(pupid_u)
predict pupid_fe, d

* Generate for each person their individual and urban effect
gen temp_r = pupid_fe if urban==0
gen temp_u = pupid_fe if urban==1

egen fe_r = mean(temp_r) , by(pupid)
egen fe_u = mean(temp_u) , by(pupid)

* Normalize to Rural FE for nonmovers
quietly sum fe_r if obsnum==1 & missing(fe_u)
replace fe_r = fe_r - r(mean)
replace fe_u = fe_u - r(mean)

egen fe_overall = mean(pupid_fe) , by(pupid)

gen fe_u_r = fe_u - fe_r

* Labels
label var fe_r "Rural FE"
label var fe_u "Urban FE"
label var fe_u_r "Difference"

* Graph urban FE against rural FE
sum fe_r fe_u if obsnum==1
reg fe_u fe_r if obsnum==1 , robust

local y_pos = _b[_cons] + 4.5*_b[fe_r]
local b = _b[fe_r]
local cons = _b[_cons]

quietly sum fe_r if obsnum==1 & !missing(fe_u)
local min = r(min)
local max = r(max)

graph twoway 	(function y = x, lcolor(gs10) lwidth(medthin) range(-6 6)) ///
	(scatter fe_u fe_r if obsnum==1 & inrange(fe_u, -6,6) & inrange(fe_r,-6,6), msymbol(circle_hollow) mcolor(black) mlwidth(thin)) ///
	(function y = `cons' + `b'*x, color(black) range(-6 6) lpattern(dash) lwidth(medthick))  , ///
graphregion(color(white) lcolor(white)) ///
legend(off) ///
ysca(alt range(-6 6)) ///
xsca(alt range(-6 6)) ///
ylabel(-6(3)6) ///
xlabel(-6(3)6 , grid gmax) ///
ytitle("") ///
xtitle("") ///
text(5 5 "45 degree line", placement(nw)) ///
text(`y_pos' 4.5 "{&beta} = `: di %4.3f `b''", placement(se)) ///
text(`=`y_pos'-0.45' 4.5 "     (`: di %4.3f bstat[2,1]')", placement(se)) ///
name(ur_scatter, replace) ///
nodraw

quietly sum fe_u if obsnum==1 & !missing(fe_r)
graph twoway ///
	(histogram fe_u if obsnum==1 & !missing(fe_r) & inrange(fe_u,-6,6) ,  ///
	start(-5.625) width(0.375) fcolor(none) lcolor(black) lwidth(medthick) horiz ) ///
(scatteri `r(mean)' 0 `r(mean)' 0.6, connect(direct) msymbol(none) lcolor(black) lpattern(dot) lwidth(thick)) , ///
	xsca(alt reverse)  ///
ylabel(-6(3)6, grid gmax) ///
xlabel(minmax, labcolor(white) tlcolor(none)) ///
graphregion(color(white) lcolor(white)) ///
ytitle("Average Urban Productivity") ///
xtitle("") ///
fxsize(25) ///
text(1.2 0.60 "{&mu} = `: di %4.3f r(mean)'", placement(n) orientation(vertical)) ///
text(1.2 0.48 "{&sigma} = `: di %4.3f r(sd)'", placement(n) orientation(vertical)) ///
legend(off) ///
name(ur_hist_u, replace) ///
nodraw


* Rural FE for nonmovers
quietly sum fe_r if obsnum==1 & missing(fe_u)
graph twoway ///
	(histogram fe_r if obsnum==1  & missing(fe_u) & inrange(fe_r,-5.625,6), start(-5.625) width(0.375) fcolor(gs13) lcolor(gs13) lwidth(none)) ///
	(scatteri 0 `r(mean)' 0.6 `r(mean)' , connect(direct) msymbol(none) lcolor(black) lpattern(dot) lwidth(thick)) , ///
ysca(alt) ///
ylabel(0(0.1)0.5 , nogrid labcolor(white) tlcolor(none)) ///
xlabel(-6(3)6, grid gmax) ///
ytitle("") ///
xtitle("Average Rural Productivity") ///
fysize(25) ///
legend(off) ///
graphregion(color(white) lcolor(white)) ///
text(0.63 0.1 "{&mu} = `: di %4.3f 0'", placement(e)) ///
text(0.53 0.1 "{&sigma} = `: di %4.3f r(sd)'", placement(e)) ///
text(0.46 -2.5 "Always Rural", placement(w)) ///
name(ur_hist_r_nonmigrants, replace) ///
nodraw

* Rural FE for Movers
quietly sum fe_r if obsnum==1 & !missing(fe_u)
graph twoway ///
	(histogram fe_r if obsnum==1  & !missing(fe_u) & inrange(fe_r,-5.625,6), start(-5.625) width(0.375) fcolor(white) lcolor(black) lwidth(medthick)) ///
	(scatteri 0 `r(mean)' 0.6 `r(mean)' , connect(direct) msymbol(none) lcolor(black) lpattern(dot) lwidth(thick)) , ///
ysca(alt) ///
ylabel(0(0.1)0.5 , nogrid labcolor(white) tlcolor(none)) ///
xlabel(-6(3)6, grid gmax nolabels) ///
ytitle("") ///
xtitle("") ///
fysize(22) ///
legend(off) ///
graphregion(color(white) lcolor(white)) ///
name(ur_hist_r_migrants, replace) ///
text(0.63 0.6 "{&mu} = `: di %4.3f r(mean)'", placement(e)) ///
text(0.53 0.6 "{&sigma} = `: di %4.3f r(sd)'", placement(e)) ///
text(0.46 -2.5 "Rural-to-Urban Migrants", placement(w)) ///
nodraw

graph set eps fontface Garamond

graph combine ur_hist_u ur_scatter ur_hist_r_migrants ur_hist_r_nonmigrants , ///
	hole(3 5) ///
cols(2) ///
graphregion(color(white) lcolor(white)) ///
xsize(5) ///
ysize(6) ///
imargin(0 0 0 0)

graph export "FigureA8_KLPS_rural.eps" , replace

graph set window fontface default
graph set eps fontface default


********************************************************************************		
*** Table A1: Correlates of Employment in Non-Agriculture
********************************************************************************
use "Main_Analysis_KLPS.dta", clear		
preserve
egen nonag_ever = max(nonag) , by(pupid)

  drop educpri-educuni

  gen educpri = educlv >= 2 if !missing(educlv)
  gen educsec = educlv >= 6 if !missing(educlv)
  gen educcol = educlv >= 8 if !missing(educlv)

  * 585 kids have years of education = 7 but no education level.

  replace educpri = 0 if missing(educpri) & educyr == 7
  replace educsec = 0 if missing(educsec) & educyr == 7
  replace educcol = 0 if missing(educcol) & educyr == 7

  * To make consistent with years of education measure, only record for
  * kids not missing years of education
  replace educpri = . if missing(educyr)
  replace educsec = . if missing(educyr)
  replace educcol = . if missing(educyr)


  * Collapse the data to the individual level
  collapse (first) ravens educpri educsec educcol ///
	  migrU_ever migr_ever nonag_ever female, by(pupid)


  label var ravens "Raven's Z-score"
  label var educpri "Primary Ed."
  label var educsec "Secondary Ed."
  label var educcol "College"
  label var female "Female"
  label var migrU_ever "Urban Migrants"
  label var migr_ever "Ever Migrated"


  foreach var of varlist educpri educsec educcol female ravens {
    eststo `var': reg nonag_ever `var', robust
  }

  eststo all1: reg nonag_ever educpri educsec educcol female ravens, robust
	eststo all2: reg nonag_ever educpri educsec educcol female, robust

	//blank

  esttab educpri educsec educcol female ravens all1 all2 ///
    using "TableA1_KLPS.tex", replace type fragment ///
	  label ///
		se(3) ///
		nomtitles ///
    title("Correlates of ever being employed in non-agriculture") ///
	  legend ///
	  booktabs ///
	  width(\hsize)

	  
********************************************************************************		
*** Table A2: Correlates of Urban Migration
********************************************************************************
  foreach var of varlist educpri educsec educcol female ravens {
    eststo `var': reg migrU_ever `var', robust
  }

  eststo all1: reg migrU_ever educpri educsec educcol female ravens, robust
	eststo all2: reg migrU_ever educpri educsec educcol female, robust

  esttab educpri educsec educcol female ravens all1 all2 ///
    using "TableA2_KLPS.tex", fragment replace type ///
		label ///
		se(3) ///
		nomtitles ///
		title("Correlates of ever migrating to urban") ///
		legend ///
		booktabs ///
		width(\hsize)

restore
********************************************************************************		
*** Table A5: Kenya Urban Towns
********************************************************************************
preserve

egen mean_obs = count(pupid) if urban==1, by(town)
quietly sum urban
replace mean_obs = mean_obs/r(sum)*100

egen group = group(mean_obs town) if urban==1, missing

replace group = -group
labmask group, values(town)
label var group town

* Put everything after #20 in a single group
quietly sum group
replace group = r(min)+20 if group >= r(min)+20 | missing(town_pop)
label define group `=r(min)+20' "Other" , modify

gen reported_town_pop = town_pop
replace reported_town_pop = . if group == `=r(min)+20'

* Create the new mean_obs
drop mean_obs
egen mean_obs = count(pupid) if urban==1 , by(group)
quietly sum urban
replace mean_obs = mean_obs/r(sum)*100

label var mean_obs "Percentage of Urban Person-Months"
label var reported_town_pop "Population"

* Also need the populations
bys town urban: gen temp = 1 if _n==1

eststo kenya_urban_town: estpost tabstat mean_obs reported_town_pop if urban==1 & temp==1, by(group) nototal statistic(mean)
esttab kenya_urban_town ///
    using "TableA5_KLPS.tex", fragment replace type ///
		cells("reported_town_pop(label(Population) fmt(%30.0fc)) mean_obs(fmt(1) label(\shortstack{Percentage of Urban\\Individual-Months}))") ///
		noobs ///
		nonumbers ///
		nomtitles ///
		booktabs
restore


********************************************************************************		
*** Table A6: Non-Agricultural/Agricultural Gap in Earnings using Alternative Definition of Agriculture
********************************************************************************
*** lninc_nonagonly_KLPS
reg lninc nonagonly [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc nonagonly lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc nonagonly lnhour lnhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lninc_h nonagonly age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H

*** lninc_nonagany_KLPS
reg lninc nonagany [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lninc nonagany lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lninc nonagany lnhour lnhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG
xtreg lninc_h nonagany age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store HH
esttab A C G H AA CC GG HH using "TableA6_KLPS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher age_sq *yrmth*) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  ///
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))


********************************************************************************		
*** Table A7: Non-Agricultural/Agricultural Gap in Earnings Within Rural Areas
********************************************************************************
*** If currently in rural area
preserve
keep if urban == 0

*** lninc_nonag_inrural_KLPS
reg lninc nonag [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc nonag lnhour lnhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lninc_h nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H

esttab A C G H using "TableA7_KLPS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons *yrmth* voced voced_treat_info voced_treat_voucher lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher age_sq) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage")  ///
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))
restore


********************************************************************************		
*** Table A8: Non-Agricultural/Agricultural Gap in Hours Worked
********************************************************************************
use "Main_Analysis_KLPS.dta", clear

*** lnhour_nonag_KLPS
reg lnhour nonag [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lnhour nonag female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
reg lnhour nonag female age age_sq educyr educyr_sq ravens ravens_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
reg lnhour nonag female age age_sq educyr educyr_sq ravens ravens_sq voced voced_treat_info voced_treat_voucher i.yrmth if NA_mover == 1 [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local moverUonly "Y" , replace
estadd local cluster `e(N_clust)', replace
est store E
xtreg lnhour nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G

esttab A C D E G using "TableA8_KLPS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons *yrmth* voced voced_treat_info voced_treat_voucher age age_sq) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "" "")  ///
	mgroups("Dependent variable: Log Hours", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE timeFE moverUonly N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Time fixed effects"' `"Switchers only"' `"Number of observations"' `"Number of individuals"'))


********************************************************************************		
*** Table A9: Urban/Rural Gap in Hours Worked
********************************************************************************
*** lnhour_urban_KLPS
reg lnhour urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lnhour urban female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
reg lnhour urban female age age_sq educyr educyr_sq ravens ravens_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
reg lnhour urban female age age_sq educyr educyr_sq ravens ravens_sq voced voced_treat_info voced_treat_voucher i.yrmth if U_mover == 1 [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local moverUonly "Y" , replace
estadd local cluster `e(N_clust)', replace
est store E
xtreg lnhour urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G

esttab A C D E G using "TableA9_KLPS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons *yrmth* voced voced_treat_info voced_treat_voucher age age_sq) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "" "")  ///
	mgroups("Dependent variable: Log Hours", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE timeFE moverUonly N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Time fixed effects"' `"Switchers only"' `"Number of observations"' `"Number of individuals"'))


********************************************************************************		
*** Table A10: Robustness to Alternative Agricultural Productivity Measures
********************************************************************************
xtreg lninc_h nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store A

xtreg lninc_h nonagonly age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store B

xtreg lninc_h nonagany age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store C

preserve
keep if !missing(lnforinc)
keep if !missing(lnforinc_h)
gen nonagW = nonag
lab var nonagW "Wage employment only"
xtreg lnforinc_h nonagW age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
restore

preserve
keep if !missing(lninforaginc)
keep if !missing(lninforaginc_h)
gen nonagSA = nonag
lab var nonagSA "Self-employment only"
xtreg lninforaginc_h nonagSA age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store E
restore

gen nonagW = nonag
gen nonagSA = nonag
lab var nonagW "Wage employment only"
lab var nonagSA "Self-employment only"

esttab A B C D E, se nostar drop(_cons age_sq *yrmth*)
matrix C = r(coefs)
eststo clear

local rnames: rownames C
matrix b = J(1,5,.)
matrix se = J(1,5,.)
matrix colnames b = `rnames'

forvalues i=1/5 {
  matrix b[1, `i'] = C[`i', `=(`i'-1)*2+1']
	matrix se[1, `i'] = C[`i', `=(`i'-1)*2+2']
}

matrix vcv = diag(se)*diag(se)
matrix colnames vcv = `rnames'
matrix rownames vcv = `rnames'

ereturn clear
ereturn post b vcv
eststo temp

esttab temp using "TableA10_KLPS.tex", replace f type ///
	label booktabs b(3) p(3) eqlabels(none) collabels(none) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	///mlabels("\shortstack{Dependent variable:\\Log Wage}") ///mgroups("Dependent variable: Log Wage", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nomtitles ///
	order(`rnames') 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") 	///
	labcol2(" $\checkmark$ \qquad\qquad\qquad\qquad $\checkmark$" ///
	        " $\checkmark$ \qquad\qquad\qquad\qquad $\checkmark$" ///
					" $\checkmark$ \qquad\qquad\qquad\qquad $\checkmark$" ///
					" $\checkmark$ \qquad\qquad\qquad\qquad \phantom{$\checkmark$}" ///
					" \phantom{$\checkmark$} \qquad\qquad\qquad\qquad $\checkmark$") ///
					///title("\shortstack[l]{Productivity Measure Includes...\\Formal inforinc_h \quad Self-Employed Profits}")) ///
	nonumbers noobs ///
  prehead("Definition of Agriculture&\shortstack[l]{Productivity Measure Includes...\\Formal inforinc_h \quad Self-Employed Profits}&\shortstack{Dependent variable:\\Log Wage}\\") ///
	varlabel(nonag "\textbf{\shortstack[l]{Majority of hours in agriculture\\Main Estimation}}" ///
	         nonagonly "Any hours in agriculture" ///
					 nonagany "All hours in agriculture" ///
					 nonagW "Majority of hours in agriculture" ///
					 nonagSA "Majority of hours in agriculture")

gen ag_forinc = 1 if !missing(forinc) & forinc > 0 & nonag==0
gen ag_self1 = 1 if !missing(inforinc) & inforinc > 0 & nonag==0
gen ag_ag1 = 1 if !missing(aginc) & aginc > 0 & nonag==0

bys ag_forinc pupid: gen first_forag = 1 if _n==1 & ag_forinc==1
bys ag_self1 pupid: gen first_self1 = 1 if _n==1 & ag_self1==1
bys ag_ag1 pupid: gen first_ag1 = 1 if _n==1 & ag_ag1==1

count if ag_forinc==1
count if first_forag==1

count if ag_self1==1
count if first_self1==1

count if ag_ag1==1
count if first_ag1==1

drop ag_forinc ag_self1 ag_ag1 first_forag first_self1 first_ag1


********************************************************************************		
*** Table A12: Gap in Wage Earnings
********************************************************************************
preserve
keep if !missing(lnforinc)
keep if !missing(lnforinc_h)

*** lnforinc_nonag_KLPS
reg lnforinc nonag [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lnforinc nonag lnforhour lnforhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lnforinc nonag lnforhour lnforhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lnforinc_h nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H

*** lnforinc_urban_KLPS
reg lnforinc urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lnforinc urban lnforhour lnforhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lnforinc urban lnforhour lnforhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG
xtreg lnforinc_h urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store HH
esttab A C G H AA CC GG HH using "TableA12_KLPS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons lnforhour lnforhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher age_sq *yrmth*) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  ///
	mgroups("Dependent variable: Log Wage Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore


********************************************************************************		
*** Table A13: Gap in Self-Employment Earnings
********************************************************************************
preserve
keep if !missing(lninforaginc)
keep if !missing(lninforaginc_h)

*** lninforinc_nonag_KLPS
reg lninforaginc nonag [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninforaginc nonag lninforaghour lnhourSA_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninforaginc nonag lninforaghour lnhourSA_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lninforaginc_h nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H

*** lninforinc_urban_KLPS
reg lninforaginc urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lninforaginc urban lninforaghour lnhourSA_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lninforaginc urban lninforaghour lnhourSA_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG
xtreg lninforaginc_h urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store HH
esttab A C G H AA CC GG HH using "TableA13_KLPS.tex", replace f type ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	keep(nonag urban) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  ///
	mgroups("Dependent variable: Log Self-Employment Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore


********************************************************************************		
*** Table A14: Alternative Samples Kenya
********************************************************************************
preserve

gen lnhour_allhours_sq = lnhour_allhours * lnhour_allhours

drop nonag
gen nonag = .
replace nonag = 1 if nonaghour > aghour_allhours & aghour_allhours ~= . & nonaghour ~= .
replace nonag = 0 if nonaghour < aghour_allhours & aghour_allhours ~= . & nonaghour ~= .
replace nonag = 1 if nonaghour > 0 & nonaghour ~= . & aghour_allhours == .
replace nonag = 0 if aghour_allhours > 0 & nonaghour == . & aghour_allhours ~= .

replace nonag = 0 if (abs(aghour_allhours - nonaghour) < 10^-2) & aghour_allhours ~= . & nonaghour ~= .
replace nonag = . if nonaghour == 0 & aghour_allhours == 0
replace nonag = . if nonaghour == 0 & aghour_allhours == .
replace nonag = . if nonaghour == . & aghour_allhours == 0
lab var nonag "Non-agricultural employment"

*** lnforinforinc_KLPS_allhours
reg lninc_allhours nonag [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc_allhours nonag lnhour_allhours lnhour_allhours_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc_allhours nonag lnhour_allhours lnhour_allhours_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
xtreg lninc_h_allhours nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G

*** lnforinforinc_KLPS_allhours
reg lninc_allhours urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lninc_allhours urban lnhour_allhours lnhour_allhours_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lninc_allhours urban lnhour_allhours lnhour_allhours_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store FF
xtreg lninc_h_allhours urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG
esttab A C F G AA CC FF GG using "TableA14_KLPS_PanelA.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons lnhour_allhours lnhour_allhours_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher age_sq *yrmth*) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  ///
	mgroups("Dependent variable: Log Wage Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore

preserve

gen lnforinforhour_sq = lnforinforhour * lnforinforhour

drop nonag
gen nonag = .
replace nonag = 1 if nonaghour > aghour & aghour ~= . & nonaghour ~= .
replace nonag = 0 if nonaghour < aghour & aghour ~= . & nonaghour ~= .
replace nonag = 1 if nonaghour > 0 & nonaghour ~= . & aghour == .
replace nonag = 0 if aghour > 0 & nonaghour == . & aghour ~= .

replace nonag = 0 if (abs(aghour - nonaghour) < 10^-2) & aghour ~= . & nonaghour ~= .
replace nonag = . if nonaghour == 0 & aghour == 0
replace nonag = . if nonaghour == 0 & aghour == .
replace nonag = . if nonaghour == . & aghour == 0
lab var nonag "Non-agricultural employment"

*** lnforinforinc_KLPS_NoAg
reg lnforinforinc nonag [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lnforinforinc nonag lnforinforhour lnforinforhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lnforinforinc nonag lnforinforhour lnforinforhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
xtreg lnforinforinc_h nonag age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G

*** lnforinforinc_KLPS_NoAg
reg lnforinforinc urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lnforinforinc urban lnforinforhour lnforinforhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lnforinforinc urban lnforinforhour lnforinforhour_sq age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store FF
xtreg lnforinforinc_h urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG
esttab A C F G AA CC FF GG using "TableA14_KLPS_PanelB.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons lnforinforhour lnforinforhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher age_sq *yrmth*) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  ///
	mgroups("Dependent variable: Log Wage Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore


********************************************************************************		
*** Table A15: Unemployment and Job Search Behavior, Kenya
********************************************************************************
use "Consumption_Analysis_KLPS.dta", clear

keep if !missing(urban)
keep if !missing(female)
keep if !missing(age)
keep if !missing(educyr)
keep if sample_unempl == 1
preserve
*** unempl_or_ag_urban_KLPS
reg unempl_or_ag urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local depmean `: di %05.3f `unempl_or_ag_mean'', replace
estadd local cluster `e(N_clust)', replace
est store A
reg unempl_or_ag urban female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local depmean `: di %05.3f `unempl_or_ag_mean'', replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg unempl_or_ag urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local depmean `: di %05.3f `unempl_or_ag_mean'', replace
estadd local cluster `e(N_clust)', replace
est store F
reg unempl urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local depmean `: di %05.3f `unempl_mean'', replace
estadd local cluster `e(N_clust)', replace
est store AA
reg unempl urban female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local depmean `: di %05.3f `unempl_mean'', replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg unempl urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local depmean `: di %05.3f `unempl_mean'', replace
estadd local cluster `e(N_clust)', replace
est store FF
esttab A C F AA CC FF using "TableA15_unemp.tex", fragment replace type ///
  label booktabs b(3) p(3) eqlabels(none) collabels(none) ///
	drop(_cons female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher age_sq *yrmth*) ///
	star(* 0.10 ** 0.05 *** 0.01) /// // mtitle(("test" "" "" "hello" "" "") pattern(1 0 0 1 0 0))  /// // "Movers" "Urban Movers"
	mgroups("\shortstack{Dependent Variable: Unemployment\\or Subsistence Agriculture}" "\shortstack{Dependent Variable: Unemployment\\ \ }", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nomtitles ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	//	stats(N, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{S}{@}") labels(`"Observations"'))
	stats(indFE contr depmean N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Mean dependent variable"' `"Number of observations"' `"Number of individuals"'))

*** searchtot_urban_KLPS
reg searchtot urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local depmean `: di %05.3f `searchtot_mean'', replace
estadd local cluster `e(N_clust)', replace
est store A
reg searchtot urban female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local depmean `: di %05.3f `searchtot_mean'', replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg searchtot urban age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local depmean `: di %05.3f `searchtot_mean'', replace
estadd local cluster `e(N_clust)', replace
est store F
esttab A C F using "TableA15_search.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	// drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher age_sq *yrmth*) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles	/// // 	mtitle("" "" "")  /// // "Movers" "Urban Movers"
	mgroups("Dependent variable: Total Hours Job Search", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	//	stats(N, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{S}{@}") labels(`"Observations"'))
	stats(indFE contr depmean N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Mean dependent variable"' `"Number of observations"' `"Number of individuals"'))
	
restore


********************************************************************************		
*** Table A16: Alternative Coefficient Standard Error Estimation
********************************************************************************
run "6. Cr23_ik_css_mod.do"
run "7. Edfreg_mod.do"
local bsreps = 1000

xtset, clear
local urban urban

* Recode the time FE
tab yrmth, gen(yrmth_)
drop yrmth_1
global timeFE yrmth_*


* Residualize some variables for Frisch-Waugh to accommodate CR2 and CR3 SE
foreach var of varlist lninc lninc_h `urban' nonag {
  xtreg `var', fe i(pupid)
	predict res_`var', e
}

* Residualize all the covariates with respect to FE
local residualized1
local residualized2
foreach var of varlist age_sq $timeFE {
  xtreg `var', fe i(pupid)
	predict res_`var', e
	local residualized1 `residualized1' res_`var'
}

local residualized2 `residualized1'
foreach var of varlist lnhour lnhour_sq {
  xtreg `var', fe i(pupid)
	predict res_`var', e
	local residualized2 `residualized2' res_`var'
}



reg lninc `urban', cluster(pupid)
est store A
estadd local contr "N" , replace: A
estadd local indFE "N" , replace: A
estadd local cluster `e(N_clust)', replace: A

* Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: A

** CR2 and 3 DOF corrections

predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(lninc) rhs(`urban') key_rhs(`urban') cluster(pupid)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: A

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: A

drop resid

reg lninc `urban', vce(bootstrap, cluster(pupid) reps(`bsreps'))

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)

estadd matrix stderr_bootstrap: A

edfreg lninc `urban', cluster(pupid)  select(`urban')

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: A

reg lninc `urban' lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth, cluster(pupid)
est store C
estadd local contr "Y" , replace: C
estadd local indFE "N" , replace: C
estadd local cluster `e(N_clust)', replace: C

* Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: C

** CR2 and 3 DOF corrections

predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(lninc) rhs(`urban' lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher $timeFE) key_rhs(`urban') cluster(pupid)


matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: C

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: C

drop resid

areg lninc `urban' lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher, vce(bootstrap, cluster(pupid) reps(`bsreps')) a(yrmth)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)

estadd matrix stderr_bootstrap: C

edfreg lninc `urban' lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher $timeFE, cluster(pupid) select(`urban')
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: C

xtreg lninc `urban' lnhour lnhour_sq age_sq i.yrmth, fe i(pupid) cluster(pupid)			// male educ_std
est store F
estadd local contr "Y" , replace: F
estadd local indFE "Y" , replace: F
estadd local cluster `e(N_clust)', replace: F

* Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: F

** CR2 and 3 DOF corrections
reg res_lninc res_`urban' `residualized2', cluster(pupid) noconstant
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(res_lninc) rhs(" res_`urban' `residualized2'") key_rhs(res_`urban') cluster(pupid) noconstant(1)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: F

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: F

drop resid

mata: findexternal("cr2cr3()")
bootstrap _b[`urban'], cluster(pupid) reps(`bsreps'): reghdfe lninc `urban' lnhour lnhour_sq age_sq, a(pupid yrmth)
mata: findexternal("cr2cr3()")
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)
matrix colnames stderr_bootstrap = `urban'
matrix rownames stderr_bootstrap = `urban'

estadd matrix stderr_bootstrap: F

mata: findexternal("cr2cr3()")
mata: mata set matastrict off
run "6. Cr23_ik_css_mod.do"

edfreg lninc `urban' lnhour lnhour_sq age_sq $timeFE, cluster(pupid) absorb(pupid) select(`urban')
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: F

xtreg lninc_h `urban' age_sq i.yrmth, fe i(pupid) cluster(pupid)			
est store G
estadd local contr "Y" , replace: G
estadd local indFE "Y" , replace: G
estadd local cluster `e(N_clust)', replace: G

* Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: G

** CR2 and 3 DOF corrections
reg res_lninc_h res_`urban' `residualized1', cluster(pupid) noconstant
predict resid, resid
matrix betavec = e(b)
CR23_IK_CSS, betavec(betavec) lhs(res_lninc_h) rhs("res_`urban' `residualized1'") key_rhs(res_`urban') cluster(pupid) noconstant(1)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: G

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: G

drop resid

bootstrap _b[`urban'], cluster(pupid) reps(`bsreps'): reghdfe lninc_h `urban' age_sq, a(yrmth pupid)
mata: findexternal("cr2cr3()")
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)
matrix colnames stderr_bootstrap = `urban'
matrix rownames stderr_bootstrap = `urban'

estadd matrix stderr_bootstrap: G

edfreg lninc_h `urban' age_sq $timeFE, cluster(pupid) absorb(pupid) select(`urban')
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: G

reg lninc nonag, cluster(pupid)
est store AA
estadd local contr "N" , replace: AA
estadd local indFE "N" , replace: AA
estadd local cluster `e(N_clust)', replace: AA

* Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: AA

** CR2 and 3 DOF corrections

predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(lninc) rhs(nonag) key_rhs(nonag) cluster(pupid)


matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: AA

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: AA

drop resid

reg lninc nonag, vce(bootstrap, cluster(pupid) reps(`bsreps'))
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)

estadd matrix stderr_bootstrap: AA

edfreg lninc nonag, cluster(pupid) select(nonag)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: AA

reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth, cluster(pupid)
est store CC
estadd local contr "Y" , replace: CC
estadd local indFE "N" , replace: CC
estadd local cluster `e(N_clust)', replace: CC

* Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: CC

** CR2 and 3 DOF corrections

predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(lninc) rhs(nonag lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher $timeFE) key_rhs(nonag) cluster(pupid)


matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: CC

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: CC

drop resid

areg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher, vce(bootstrap, cluster(pupid) reps(`bsreps')) a(yrmth)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)

estadd matrix stderr_bootstrap: CC

edfreg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher $timeFE, cluster(pupid) select(nonag)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: CC

xtreg lninc nonag lnhour lnhour_sq age_sq i.yrmth, fe i(pupid) cluster(pupid)			// male educ_std
est store FF
estadd local contr "Y" , replace: FF
estadd local indFE "Y" , replace: FF
estadd local cluster `e(N_clust)', replace: FF

* Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: FF

** CR2 and 3 DOF corrections
reg res_lninc res_nonag `residualized2', cluster(pupid) noconstant
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(res_lninc) rhs("res_nonag `residualized2'") key_rhs(res_nonag) cluster(pupid) noconstant(1)


matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: FF

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: FF

drop resid

mata: findexternal("cr2cr3()")
bootstrap _b[nonag], cluster(pupid) reps(`bsreps'): reghdfe lninc nonag lnhour lnhour_sq age_sq, a(pupid yrmth)
mata: findexternal("cr2cr3()")
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)
matrix colnames stderr_bootstrap = nonag
matrix rownames stderr_bootstrap = nonag

estadd matrix stderr_bootstrap: FF

* It does it here too
mata: findexternal("cr2cr3()")
mata: mata set matastrict off
run "6. Cr23_ik_css_mod.do"

edfreg lninc nonag lnhour lnhour_sq age_sq $timeFE, cluster(pupid) absorb(pupid) select(nonag)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: FF

xtreg lninc_h nonag age_sq i.yrmth, fe i(pupid) cluster(pupid)			
est store GG
estadd local contr "Y" , replace: GG
estadd local indFE "Y" , replace: GG
estadd local cluster `e(N_clust)', replace: GG

* Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: GG

** CR2 and 3 DOF corrections
reg res_lninc_h res_nonag `residualized1', cluster(pupid) noconstant
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(res_lninc_h) rhs("res_nonag `residualized1'") key_rhs(res_nonag) cluster(pupid) noconstant(1)


matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: GG

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: GG

drop resid


bootstrap _b[nonag], cluster(pupid) reps(`bsreps'): reghdfe lninc_h nonag age_sq, a(pupid yrmth)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)
matrix colnames stderr_bootstrap = nonag
matrix rownames stderr_bootstrap = nonag

estadd matrix stderr_bootstrap: GG

edfreg lninc_h nonag age_sq $timeFE, cluster(pupid) absorb(pupid) select(nonag)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: GG

esttab AA CC FF GG A C F G using "TableA16_KLPS.tex", replace type f ///
  cells(b(fmt(3)star) stderr_default(par(( ))) stderr_cr2(par([ ])) stderr_cr3(par(`"\$\\llbracket\$"' `"\$\\rrbracket\$"')) stderr_bootstrap(par(\{ \})) stderr_young(par(`"\$\\langle"' `"\\rangle\$"'))) ///
	keep(urban nonag) ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	// drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  /// // "Movers" "Urban Movers"
	mgroups("Dependent variable: Log Earnings (in IDR)", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))


drop res_lninc res_lninc_h res_`urban' res_nonag `residualized2'


********************************************************************************		
*** Table A17: Integenerational Correlations of Cognitive Measures
********************************************************************************
use "Intergen_Analysis_KLPS.dta", clear

local control2 child_female
local control3 child_female parent_female parent_age_atchildbirth
local control4 `control3' parent_educ parent_raven
local control5 `control4' parent_age_atchildbirth_sq parent_educ_sq parent_raven_sq

egen hasmiss = rowmiss(`control5')
drop if hasmiss >0
drop hasmiss

foreach depvar in child_cogn_index {
	eststo `depvar'_reg1: reg `depvar' 1.child_urban_birth, cluster(pupid)
	estadd local square "N"
	eststo `depvar'_reg2: reg `depvar' 1.child_urban_birth `control2', cluster(pupid)
	estadd local square "N"
	eststo `depvar'_reg3: reg `depvar' 1.child_urban_birth `control3', cluster(pupid)
	estadd local square "N"
	eststo `depvar'_reg4: reg `depvar' 1.child_urban_birth `control4', cluster(pupid)
	estadd local square "N"
	eststo `depvar'_reg5: reg `depvar' 1.child_urban_birth `control5', cluster(pupid)
	estadd local square "Y"
}

esttab child_cogn_index_reg* using "TableA17_KLPS.tex", ///
	booktabs type replace fragment ///
  b(%5.3f) se(%5.3f) ///
  star(* 0.10 ** 0.05 *** 0.01) ///
	mgroup("\shortstack{Dependent variable: Normalized Cognitive Ability Index}", ///
	         pattern(1 0 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabels(none) label interaction("$\times$") ///
	drop(_cons *_sq) ///
	varlabels( ///
	  child_female Female ///
	  parent_female Female ///
		parent_age_atchildbirth "Age at Birth" ///
		parent_educ "Years of Education" ///
		parent_raven "Normalized Ravens") ///
	refcat(1.child_urban_birth "\textbf{Child Covariates:}" ///
	       parent_female "\textbf{KLPS Parent Covariates:}", nolabel) ///
	stats(square N, ///
		labels("Age, Education, and Ravens Squared" ///
		       "Number of observations") ///
		fmt(%9.0g) ///
		layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}")) ///
	nonotes

	
********************************************************************************		
*** Table A18: Correlates of Meals Eaten—Kenya
********************************************************************************
use "Consumption_Analysis_KLPS.dta", clear

foreach var of varlist lncons_tot lninc lninc_h {
  eststo `var': reg `var' logmeals , cluster(pupid)
}

esttab lncons_tot lninc lninc_h ///
	using "TableA18_KLPS.tex", f replace type ///
	label ///
	mtitle("Log Consumption" "Log Earnings" "Log Wage")  ///
	drop(_cons) ///
	se(3) ///
	legend ///
	stats(N, fmt(0) layout("\multicolumn{1}{c}{@}") labels("Number of observations")) ///
	booktabs


********************************************************************************		
*** Table A19: Gaps in Consumption
********************************************************************************
use "Meals_Analysis_KLPS.dta", clear
xtset pupid yrmth

* generate logs of meals

*** lncons_food_IFLS
reg logmeals nonag [aw=weight], cluster(pupid)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store mealsgap_nonag_raw

reg logmeals nonag female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid)						// lnhour lnhour_sq
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store mealsgap_nonag_ctrl

xtreg logmeals nonag age_sq i.yrmth, fe i(pupid) cluster(pupid)	// lnhour lnhour_sq
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store mealsgap_nonag_fe

reg logmeals urban [aw=weight], cluster(pupid)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store mealsgap_urban_raw

reg logmeals urban female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid)						// lnhour lnhour_sq
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store mealsgap_urban_ctrl

xtreg logmeals urban age_sq i.yrmth, fe i(pupid) cluster(pupid)	// lnhour lnhour_sq
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store mealsgap_urban_fe

esttab ///
  mealsgap_nonag_raw ///
  mealsgap_nonag_ctrl ///
  mealsgap_nonag_fe ///
	mealsgap_urban_raw ///
  mealsgap_urban_ctrl ///
	mealsgap_urban_fe ///
  using "TableA19_KLPS.tex", replace f type ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none)	///	// indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher age_sq *yrmth*) ///	// female age age_sq educyr educyr_sq ravens ravens_sq voced voced_treat_info voced_treat_voucher
	star(* 0.10 ** 0.05 *** 0.01) /// //	collabels("\multicolumn{3}{c}{test}" "\multicolumn{3}{c}{test2}") ///
	nomtitles /// // mtitle("" "" "" "" "" "")  /// //
	mgroups("Dependent variable: Log Meals Eaten", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(nonag urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	//	stats(N, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{S}{@}") labels(`"Observations"'))
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))


********************************************************************************		
*** Table A23: Urban/Rural Gap in inforinc_h for Top 5 Cities
********************************************************************************
use "Main_Analysis_KLPS.dta", clear

reg lninc_h urban [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A0
reg lninc_h urban nairobi mombasa kisumu nakuru eldoret [aw=weight], cluster(pupid) robust
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc_h urban nairobi mombasa kisumu nakuru eldoret female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher i.yrmth [aw=weight], cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc_h urban nairobi mombasa kisumu nakuru eldoret age_sq i.yrmth [aw=weight], fe i(pupid) cluster(pupid) robust
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
esttab A0 A C F using "TableA23_KLPS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(c c) collabels(none) /// // alignment(S S)  // collabels("\multicolumn{1}{c}{$\beta$ / SE}" // drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.yrmth" "Individual FE = $test", labels(Y N)) ///
	drop(_cons female age age_sq educyr educyr_sq voced voced_treat_info voced_treat_voucher age_sq *yrmth*) ///
	star(* 0.10 ** 0.05 *** 0.01) ///	//
	nomtitles	/// // mtitle("" "" "" "")  ///
	mgroups("Dependent variable: Log inforinc_h", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

