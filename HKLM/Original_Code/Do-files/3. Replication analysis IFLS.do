/*******************************************************************************

Do-file "3. Replication analysis IFLS.do"

Replication code for 
Joan Hamory, Marieke Kleemans, Nicholas Y. Li, and Edward Miguel
Reevaluating Agricultural Productivity Gaps with Longitudinal Microdata
Created Aug 2020 using Stata version 14.2

This do-file uses the 3 datasets created by do-file "2. Creation of IFLS 
replication data.do" to replicate all figures and tables that use IFLS data 

Please contact Marieke Kleemans at kleemans@illinois.edu for questions

*******************************************************************************/



********************************************************************************
*** Figure 1: Productivity Gap in Total Earnings
********************************************************************************
use "Main_Analysis_IFLS.dta", clear														

reg lninc urban, cluster(pidlink)			
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc urban lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
xtreg lninc_h urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
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

	replace pos_coef = 9 in 6

	#delimit ;
	twoway

	(rcap ci_hi ci_lo column if inrange(num, 6, 7), lwidth(thick) lcolor(gs6) msize(zero))
	(scatter coef column if inrange(num, 6, 7),
		msymbol(diamond) msize(2.8) mfcolor(gs6) mlcolor(gs6)
		mlabel(coef) mlabc(black) mlabv(pos_coef) mlabg(1) mlabsize(3))

	(rcap ci_hi ci_lo column if inrange(num, 4,5) , lwidth(thick) lcolor(gs12) msize(zero))
	(scatter coef column if inrange(num, 4,5),
		msymbol(diamond) msize(2.8) mfcolor(gs12) mlcolor(gs12)
		mlabel(coef) mlabc(black) mlabv(pos_coef) mlabg(1) mlabsize(3)) ,
	yline(0, lcolor(gs5) lpattern(dash))
	xscale(range(3.5 6.5) off)
	yscale(range(-0.3 2.1) off)
	xsize(4)
	ysize(5)
	ylabel(0(0.5)2)
	fxsize(63.16)
	graphregion(color(white) margin(vlarge))
	legend(off)
	title("  C. Rural/Urban, Indonesia", size(3.7) position(11) color(black))
	text(2.05 5 "IFLS", place(c) size(3.6))
	name(ind_ru, replace)
	;
	 #delimit cr

	graph save "Figure1_IFLS_ruralurban.gph", replace

	restore

reg lninc nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc nonag lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
xtreg lninc_h nonag age_sq i.year, fe i(pidlink) cluster(pidlink)			
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

	replace coef = 1.381 if num == 1
	replace sd = 0 if num==1
	replace coef = 1.075 if num == 2
	replace sd = 0 if num==2
	replace num = 1.15 if num==1
	replace num = 1.85 if num==2

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
	replace label = "FE, wages" in 7

	gen pos_lab = 1

	replace pos_coef = 9 in 6

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
	title("  A. Agriculture/Non-Agriculture, Indonesia", size(3.7) position(11))
	text(2.05 5 "IFLS", place(c) size(3.6))
	text(2.05 1.5 "GLW", place(c) size(3.6))
	name(ind_ag, replace)
	;
	 #delimit cr

	graph save "Figure1_IFLS_agnonag.gph", replace

	restore
	
	
********************************************************************************		
*** Figure 3: Event Study of Urban Migration
********************************************************************************
	preserve	

	sort pidlink year
	by pidlink: gen obsnum = _n

	gen moveR2U = 1 if urban == 1 & l.urban == 0 & urban_birth == 0
	gen temp = year if moveR2U == 1
	egen firstmoveR2U = min(temp) , by(pidlink)
	drop temp

gen eventime = year - firstmoveR2U

	forvalues i = -5/5 {
		if `i' < 0 {
			gen timedum_`=-`i'' = eventime==`i'
		}
		else {
			gen timedum`i' = eventime==`i'
		}
	}

	gen endpoint_pre = eventime <= -6
	gen endpoint_post = eventime >= 6
	replace endpoint_post = 0 if missing(eventime)

	gen temp = eventime if urban==0 & eventime > 0
	egen first_postrural = min(temp) , by(pidlink)
	drop temp

	gen stillurban = eventime < first_postrural & eventime >= 0

	gen temp = jakarta if eventime==0
	egen firsturban_jakarta = mean(temp), by(pidlink)
	drop temp

	forvalues i=-5/5 {
		if `i' < 0 {
			gen timedum_jakarta_`=-`i'' = eventime==`i'&(firsturban_jakarta==1)
			gen timedum_notjakarta_`=-`i'' = eventime==`i'&(firsturban_jakarta==0)
		}
		else {
			gen timedum_jakarta`i' = eventime==`i'&(firsturban_jakarta==1)
			gen timedum_notjakarta`i' = eventime==`i'&(firsturban_jakarta==0)
		}
	}

	gen endpoint_jakarta_pre = endpoint_pre & (firsturban_jakarta==1)
	gen endpoint_notjakarta_pre = endpoint_pre & (firsturban_jakarta==0)

	gen endpoint_jakarta_post = endpoint_post & (firsturban_jakarta==1)
	gen endpoint_notjakarta_post = endpoint_post & (firsturban_jakarta==0)

	gen stillurban_jakarta = stillurban if firsturban_jakarta==1
	gen stillurban_notjakarta = stillurban if firsturban_jakarta==0

	forvalues i=1/5 {
			gen timedum_survivor`i' = eventime==`i' & (stillurban==1)
			gen timedum_notsurvivor`i' = eventime==`i' & (stillurban==0)
  }

	gen endpoint_survivor_post = endpoint_post & (stillurban==1)
	gen endpoint_notsurvivor_post = endpoint_post & (stillurban==0)

	order timedum_notjakarta* , after(endpoint_jakarta_post)
	order endpoint_notjakarta* , after(timedum_notjakarta5)
	order stillurban_*jakarta , after(endpoint_notjakarta_post)
	order timedum_survivor*, after(stillurban_notjakarta)
	order timedum_notsurvivor*, after(timedum_survivor5)
	order endpoint_survivor*, after(timedum_notsurvivor5)

  xtreg lninc_h timedum_5-timedum_2 /// pre
	              timedum0-timedum5 /// post
								endpoint_pre endpoint_post /// pooled endpoints
								age_sq i.year , ///
	  fe i(pidlink) cluster(pidlink) robust // controls

	count if timedum0 == 1
	count if timedum5 == 1

	matrix coef = J(11,10,.)
	matrix colnames coef = eventime /// 1
	  coef coef_lci coef_uci /// 4
	  frac_urban frac_urban_lci frac_urban_uci /// 7
		hazard_cont hazard_cont_lci hazard_cont_uci
	forvalues i=-5/5 {
		matrix coef[`i'+6,1] = `i'

		if `i' <= -2 {
		  
		  matrix coef[`i'+6,2] = _b[timedum_`=-`i'']
			matrix coef[`i'+6,3] = _b[timedum_`=-`i''] - _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef[`i'+6,4] = _b[timedum_`=-`i''] + _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)

			matrix coef[`i'+6,5] = 0
			matrix coef[`i'+6,8] = 0
		}
		if `i' == -1 {
		  
		  matrix coef[`i'+6,2] = 0
			
			matrix coef[`i'+6,5] = 0
			matrix coef[`i'+6,8] = 0
		}
		if `i' >= 0 {
		  
			matrix coef[`i'+6,2] = _b[timedum`i']
			matrix coef[`i'+6,3] = _b[timedum`i'] - _se[timedum`i']*invttail(e(df_r), 0.025)
			matrix coef[`i'+6,4] = _b[timedum`i'] + _se[timedum`i']*invttail(e(df_r), 0.025)

			quietly sum urban if eventime==`i'
			matrix coef[`i'+6,5] = 100*r(mean)
			matrix coef[`i'+6,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef[`i'+6,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
	
			quietly sum stillurban if eventime==`i'
			matrix coef[`i'+6,8] = 100*r(mean)
			matrix coef[`i'+6,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef[`i'+6,10] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}
	}

  xtreg lninc_h timedum_jakarta_5-timedum_jakarta_2 /// pre in Jakarta
	              timedum_jakarta0-timedum_jakarta5 /// post in Jakarta
								timedum_notjakarta_5-timedum_notjakarta_2 /// pre in not Jakarta
								timedum_notjakarta0-timedum_notjakarta5 /// post in not Jakarta
								endpoint_jakarta_pre endpoint_jakarta_post /// pooled endpoints in Jakarta
								endpoint_notjakarta_pre endpoint_notjakarta_post /// pooled endpoints in Jakarta
								age_sq i.year , ///
	  fe i(pidlink) cluster(pidlink) robust // controls

	matrix coef_jakarta = J(11,10,.)
	matrix coef_notjakarta = J(11,10,.)

	matrix colnames coef_jakarta = eventime /// 1
	  coef_jakarta coef_jakarta_lci coef_jakarta_uci /// 4
	  frac_urban_jakarta frac_urban_jakarta_lci frac_urban_jakarta_uci /// 7
		hazard_cont_jakarta hazard_cont_jakarta_lci hazard_cont_jakarta_uci

	matrix colnames coef_notjakarta = eventime /// 1
	  coef_notjakarta coef_notjakarta_lci coef_notjakarta_uci /// 4
	  frac_urban_notjakarta frac_urban_notjakarta_lci frac_urban_notjakarta_uci /// 7
		hazard_cont_notjakarta hazard_cont_notjakarta_lci hazard_cont_notjakarta_uci

	forvalues i=-5/5 {
		matrix coef_jakarta[`i'+6,1] = `i'
		matrix coef_notjakarta[`i'+6,1] = `i'

		if `i' <= -2 {

		  matrix coef_jakarta[`i'+6,2] = _b[timedum_jakarta_`=-`i'']
			matrix coef_jakarta[`i'+6,3] = _b[timedum_jakarta_`=-`i''] - _se[timedum_jakarta_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef_jakarta[`i'+6,4] = _b[timedum_jakarta_`=-`i''] + _se[timedum_jakarta_`=-`i'']*invttail(e(df_r), 0.025)

			matrix coef_jakarta[`i'+6,5] = 0
			matrix coef_jakarta[`i'+6,8] = 0
		}
		if `i' == -1 {

		  matrix coef_jakarta[`i'+6,2] = 0
			
			matrix coef_jakarta[`i'+6,5] = 0
			matrix coef_jakarta[`i'+6,8] = 0
		}
		if `i' >= 0 {
	
			matrix coef_jakarta[`i'+6,2] = _b[timedum_jakarta`i']
			matrix coef_jakarta[`i'+6,3] = _b[timedum_jakarta`i'] - _se[timedum_jakarta`i']*invttail(e(df_r), 0.025)
			matrix coef_jakarta[`i'+6,4] = _b[timedum_jakarta`i'] + _se[timedum_jakarta`i']*invttail(e(df_r), 0.025)

			quietly sum urban if eventime==`i' & firsturban_jakarta==1
			matrix coef_jakarta[`i'+6,5] = 100*r(mean)
			matrix coef_jakarta[`i'+6,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_jakarta[`i'+6,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		
			quietly sum stillurban_jakarta if eventime==`i'
			matrix coef_jakarta[`i'+6,8] = 100*r(mean)
			matrix coef_jakarta[`i'+6,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_jakarta[`i'+6,10] =100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}

		
		if `i' <= -2 {
		  
		  matrix coef_notjakarta[`i'+6,2] = _b[timedum_notjakarta_`=-`i'']
			matrix coef_notjakarta[`i'+6,3] = _b[timedum_notjakarta_`=-`i''] - _se[timedum_notjakarta_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef_notjakarta[`i'+6,4] = _b[timedum_notjakarta_`=-`i''] + _se[timedum_notjakarta_`=-`i'']*invttail(e(df_r), 0.025)

			
			matrix coef_notjakarta[`i'+6,5] = 0
			matrix coef_notjakarta[`i'+6,8] = 0
		}
		if `i' == -1 {
		  
		  matrix coef_notjakarta[`i'+6,2] = 0
			
			matrix coef_notjakarta[`i'+6,5] = 0
			matrix coef_notjakarta[`i'+6,8] = 0
		}
		if `i' >= 0 {

			matrix coef_notjakarta[`i'+6,2] = _b[timedum_notjakarta`i']
			matrix coef_notjakarta[`i'+6,3] = _b[timedum_notjakarta`i'] - _se[timedum_notjakarta`i']*invttail(e(df_r), 0.025)
			matrix coef_notjakarta[`i'+6,4] = _b[timedum_notjakarta`i'] + _se[timedum_notjakarta`i']*invttail(e(df_r), 0.025)

			quietly sum urban if eventime==`i' & firsturban_jakarta==0
			matrix coef_notjakarta[`i'+6,5] = 100*r(mean)
			matrix coef_notjakarta[`i'+6,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_notjakarta[`i'+6,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)

			quietly sum stillurban_notjakarta if eventime==`i'
			matrix coef_notjakarta[`i'+6,8] = 100*r(mean)
			matrix coef_notjakarta[`i'+6,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_notjakarta[`i'+6,10] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}
	}


  xtreg lninc_h timedum_5-timedum_2 /// pre
							  timedum0 /// first period
								timedum_survivor1-timedum_survivor5 /// post for survivors
								timedum_notsurvivor1-timedum_notsurvivor5 /// post for not survivors
								endpoint_pre /// pre end points
								endpoint_survivor_post endpoint_notsurvivor_post /// pooled endpoints for survivors
								age_sq i.year , ///
	  fe i(pidlink) cluster(pidlink) robust // controls
	  

	matrix coef_survivor = J(11,10,.)
	matrix coef_notsurvivor = J(11,10,.)

	matrix colnames coef_survivor = eventime /// 1
	  coef_survivor coef_survivor_lci coef_survivor_uci /// 4
	  frac_urban_survivor frac_urban_survivor_lci frac_urban_survivor_uci /// 7
		hazard_cont_survivor hazard_cont_survivor_lci hazard_cont_survivor_uci

	matrix colnames coef_notsurvivor = eventime /// 1
	  coef_notsurvivor coef_notsurvivor_lci coef_notsurvivor_uci /// 4
	  frac_urban_notsurvivor frac_urban_notsurvivor_lci frac_urban_notsurvivor_uci /// 7
		hazard_cont_notsurvivor hazard_cont_notsurvivor_lci hazard_cont_notsurvivor_uci


	forvalues i=-5/5 {
		matrix coef_survivor[`i'+6,1] = `i'
		matrix coef_notsurvivor[`i'+6,1] = `i'

		if `i' <= -2 {
		  
		  matrix coef_survivor[`i'+6,2] = _b[timedum_`=-`i'']
			matrix coef_survivor[`i'+6,3] = _b[timedum_`=-`i''] - _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef_survivor[`i'+6,4] = _b[timedum_`=-`i''] + _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)

			matrix coef_survivor[`i'+6,5] = 0
			matrix coef_survivor[`i'+6,8] = 0
		}
		if `i' == -1 {
		  
		  matrix coef_survivor[`i'+6,2] = 0
			
			matrix coef_survivor[`i'+6,5] = 0
			matrix coef_survivor[`i'+6,8] = 0
		}
		if `i' == 0 {
			
		  matrix coef_survivor[`i'+6,2] = _b[timedum0]
			matrix coef_survivor[`i'+6,3] = _b[timedum0] - _se[timedum0]*invttail(e(df_r), 0.025)
			matrix coef_survivor[`i'+6,4] = _b[timedum0] + _se[timedum0]*invttail(e(df_r), 0.025)

			quietly sum urban if eventime==`i'
			matrix coef_survivor[`i'+6,5] = 100*r(mean)
			matrix coef_survivor[`i'+6,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_survivor[`i'+6,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			
			quietly sum stillurban if eventime==`i'
			matrix coef_survivor[`i'+6,8] = 100*r(mean)
			matrix coef_survivor[`i'+6,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_survivor[`i'+6,10] =100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}
		if `i' > 0 {
		  
			matrix coef_survivor[`i'+6,2] = _b[timedum_survivor`i']
			matrix coef_survivor[`i'+6,3] = _b[timedum_survivor`i'] - _se[timedum_survivor`i']*invttail(e(df_r), 0.025)
			matrix coef_survivor[`i'+6,4] = _b[timedum_survivor`i'] + _se[timedum_survivor`i']*invttail(e(df_r), 0.025)
			
			quietly sum urban if eventime==`i'
			matrix coef_survivor[`i'+6,5] = 100*r(mean)
			matrix coef_survivor[`i'+6,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_survivor[`i'+6,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			
			quietly sum stillurban if eventime==`i'
			matrix coef_survivor[`i'+6,8] = 100*r(mean)
			matrix coef_survivor[`i'+6,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_survivor[`i'+6,10] =100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}

		if `i' == 0 {
		  matrix coef_notsurvivor[`i'+6,2] = _b[timedum0]
			matrix coef_notsurvivor[`i'+6,3] = _b[timedum0] - _se[timedum0]*invttail(e(df_r), 0.025)
			matrix coef_notsurvivor[`i'+6,4] = _b[timedum0] + _se[timedum0]*invttail(e(df_r), 0.025)

		}
		if `i' > 0 {
		  
			matrix coef_notsurvivor[`i'+6,2] = _b[timedum_notsurvivor`i']
			matrix coef_notsurvivor[`i'+6,3] = coef_notsurvivor[`i'+6,2] - _se[timedum_notsurvivor`i']*invttail(e(df_r), 0.025)
			matrix coef_notsurvivor[`i'+6,4] = coef_notsurvivor[`i'+6,2] + _se[timedum_notsurvivor`i']*invttail(e(df_r), 0.025)

		}
	}

	clear

	svmat coef , names(col)

	label var eventime "Years relative to first urban move"
*** Graph event study
	graph twoway ///
		(line coef_lci eventime, lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
		(line coef_uci eventime, lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
	  (line coef eventime, lcolor(black) lwidth(medthick)) ///
		(pcarrowi 0.8 -1.2 0.8 -1.7, lcolor(black) mcolor(black) mlabcolor(black)) ///
		(pcarrowi 0.8 -0.8 0.8 -0.3, lcolor(black) mcolor(black) mlabcolor(black)), /// arrows
		text(0.88 -1.54 "Rural") ///
		text(0.88 -0.4 "Urban") ///
		xline(-1, lcolor(black) lpattern(dot)) ///
		yline(0, lcolor(black) lwidth(thin)) ///
		xlabel(-5(1)5, grid nolabels) ///
		ylabel(-1(0.5)1, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		xtitle("") ///
		ytitle("Urban Wage Gap (log points)") ///
		name(eventstudy_ifls, replace) ///
		nodraw
*** Graph Survival Rate in Urban areas
	graph twoway ///
		(line hazard_cont_lci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
		(line hazard_cont_uci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
	  (line hazard_cont eventime if eventime >= 0 , lcolor(black) lwidth(medthick)) , ///
		xline(-1, lcolor(black) lpattern(dot)) ///
		xlabel(-5(1)5, grid) ///
		ylabel(0(20)100, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		ytitle("Urban Survival Rate (percent)") ///
		name(survival_ifls, replace) ///
		nodraw

  graph set eps fontface Garamond
	graph set window fontface Garamond

  graph combine eventstudy_ifls survival_ifls , ///
	  rows(2) ///
		imargin(0 0 0 0) ///
		graphregion(color(white) lcolor(white)) ///
		ysize(6)

	graph export "Figure3_IFLS.eps", replace

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
  using "Table1_IFLS.tex", replace ///
  type booktabs ///
  collabels("Rural" "Urban" "Total") ///
	varlabels(r1 "Agriculture" r2 "Non-Agriculture" r3 "Number of Observations") ///
	nomtitles ///
	width(0.7\textwidth) ///
	substitute(333 \%)

restore


********************************************************************************		
*** Table 2_IFLS: Summary Statistics											 
********************************************************************************
preserve
*** Education dummies
  gen educpri = educlv >= 1 if !missing(educlv)
  gen educsec = educlv >= 3 if !missing(educlv)
  gen educcol = educlv == 4 if !missing(educlv)
*** Different categories
  *** Always rural
  egen always_rural = max(max(urban,urban_birth)), by(pidlink)
  replace always_rural = 1 - always_rural
  *** Always urban
  egen always_urban = min(min(urban,urban_birth)), by(pidlink)
  *** Rural non-migrants
	  gen rural_nonmigrants = migr_ever == 0 & always_rural == 1
  *** Rural-to-Rural migrants
	  gen migrRR_ever = always_rural==1 & migr_ever==1
  *** Rural-to-Urban migrants
  gen migrRU_ever = always_rural==0 & urban_birth==0
  gen migrUR_ever = always_urban==0 & urban_birth==1
  
  egen nonag_ever = max(nonag) , by(pidlink)
*** Collapse the data to the individual level
  collapse (first) ravens_norm educpri educsec educcol female ///
    always_rural migrRU_ever migrUR_ever always_urban ///
	  nonag_ever urban_birth, by(pidlink)

  label var ravens_norm "Raven's Z-score"
  label var educpri "Primary Ed."
  label var educsec "Secondary Ed."
  label var educcol "College"
  label var female "Female"
  label var always_rural "Always Rural"
  label var migrRU_ever "Rural-to-Urban Migrants"
  label var migrUR_ever "Urban-to-Rural Migrants"
  label var always_urban "Always Urban"
  label var nonag_ever "Ever Non-ag"

  eststo all: estpost sum educpri educsec educcol female ravens_norm
  eststo always_rural: estpost sum educpri educsec educcol female ravens_norm if always_rural==1
  eststo migrRU_ever: estpost sum educpri educsec educcol female ravens_norm if migrRU_ever==1
  eststo migrUR_ever: estpost sum educpri educsec educcol female ravens_norm if migrUR_ever==1
  eststo always_urban: estpost sum educpri educsec educcol female ravens_norm if always_urban==1

  eststo counts: estpost sum educpri educsec educcol female ravens_norm

  quietly count
  local num_all = r(N)
  quietly count if always_rural==1
  local num_always_rural = r(N)
  quietly count if migrRU_ever==1
  local num_migrRU_ever = r(N)
  quietly count if migrUR_ever==1
  local num_migrUR_ever = r(N)
  quietly count if always_urban==1
  local num_always_urban = r(N)

  esttab all always_rural migrRU_ever always_urban migrUR_ever counts ///
    using "Table2_IFLS.tex", replace type fragment ///
	cells(mean(pattern(1 1 1 1 1 0) fmt(%9.3f))& ///
          count(pattern(0 0 0 0 0 1) fmt(%9.0f)) ///
	      sd(par([ ]) pattern(1 1 1 1 1 0) fmt(%9.3f))) ///
    noobs ///
	title("Indonesia") ///
	mlabels("N=`num_all'" ///
			"N=`num_always_rural'" ///
	        "N=`num_migrRU_ever'" ///
			"N=`num_always_urban'" ///
			"N=`num_migrUR_ever'" ///
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
keep pidlink migrRU_ever nonag_ever educpri educsec educcol female ravens_norm always_rural
save "Table3_IFLS.dta", replace							
restore																	


********************************************************************************
*** Table 4: Non-Agricultural/Agricultural Gap in Earnings
********************************************************************************
reg lninc nonag, cluster(pidlink)					
estadd local timeFE "N" , replace					
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc nonag lnhour lnhour_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store B
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq ravens_norm ravens_norm_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq i.year if NA_mover == 1, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local moverUonly "Y" , replace
estadd local cluster `e(N_clust)', replace
est store E
xtreg lninc nonag age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F																	
xtreg lninc nonag lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G																		
xtreg lninc_h nonag age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H																		
xtreg lninc_h_real nonag age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store I																		

esttab A B C D E F G H I using "Table4_IFLS.tex", replace f ///			
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///
	drop(_cons *year* age age_sq) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "" "" "" "" "Log Wage" "Log Real Wage")  /// 
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///
	stats(indFE timeFE moverUonly N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Time fixed effects"' `"Switchers only"' `"Number of observations"' `"Number of individuals"'))	
	
	
********************************************************************************		
*** Table 5: Urban/Rural Gap in Earnings
********************************************************************************
reg lninc urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc urban lnhour lnhour_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store B
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq ravens_norm ravens_norm_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq i.year if U_mover == 1, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local moverUonly "Y" , replace
estadd local cluster `e(N_clust)', replace
est store E
xtreg lninc urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store F
xtreg lninc urban lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lninc_h urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H
xtreg lninc_h_real urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store I

esttab A B C D E F G H I using "Table5_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons *year* age age_sq) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "" "" "" "" "Log Wage" "Log Real Wage")  /// 
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE timeFE moverUonly N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Time fixed effects"' `"Switchers only"' `"Number of observations"' `"Number of individuals"'))

	
********************************************************************************		
*** Table 6: Gap in Earnings, Indonesia. For Individuals Born Rural and Urban
********************************************************************************
*** Panel A
preserve
*** Born in rural area
keep if urban_birth == 0

reg lninc urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local contr "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc_h urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H																		

esttab A C H using "Table6_IFLS_rural.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons lnhour lnhour_sq female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "Log Wage")  /// 
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))
	
restore


********************************************************************************
*** Panel B
preserve
*** Born in urban area
keep if urban_birth == 1

reg lninc urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local contr "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc_h urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H

esttab A C H using "Table6_IFLS_urban.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons lnhour lnhour_sq female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "Log Wage")  /// 
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore


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

	label var eventime "Years relative to first urban move"
*** Graph event study
	local y_pos_survivor = coef_survivor_lci[10]
	local x_pos_survivor = eventime[10]

	local y_pos_notsurvivor = coef_notsurvivor_lci[7]
	local x_pos_notsurvivor = eventime[7]

	graph twoway ///
		(line coef_survivor_lci eventime, lcolor(black) lwidth(thin) lpattern(dash) cmissing(n)) ///
		(line coef_survivor_uci eventime, lcolor(black) lwidth(thin) lpattern(dash) cmissing(n)) ///
		(line coef_notsurvivor_lci eventime, lcolor(gs10) lwidth(thin) lpattern(dash) cmissing(n)) ///
		(line coef_notsurvivor_uci eventime, lcolor(gs10) lwidth(thin) lpattern(dash) cmissing(n)) ///
	  (line coef_survivor eventime, lcolor(black) lwidth(medthick)) ///
	  (line coef_notsurvivor eventime, lcolor(gs10) lwidth(medthick)) ///
		(pcarrowi 0.8 -1.2 0.8 -1.7, lcolor(black) mcolor(black) mlabcolor(black)) ///
		(pcarrowi 0.8 -0.8 0.8 -0.3, lcolor(black) mcolor(black) mlabcolor(black)), /// 
		text(0.88 -1.54 "Rural") ///
		text(0.88 -0.4 "Urban") ///
		xline(-1, lcolor(black) lpattern(dot)) ///
		yline(0, lcolor(black) lwidth(thin)) ///
		xlabel(-5(1)5, grid nolabels) ///
		ylabel(-1(0.5)1, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		xtitle("") ///
		ytitle("Urban Wage Gap (log points)") ///
		text(`y_pos_survivor' `x_pos_survivor'  "Survivor", placement(s) color(black)) ///
		text(`y_pos_notsurvivor' `x_pos_notsurvivor'  "Not Survivor", placement(s) color(gs7)) ///
		name(eventstudy_ifls_survivor, replace) ///
		nodraw
*** Graph Survival Rate in Urban areas
	graph twoway ///
		(line hazard_cont_survivor_lci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
		(line hazard_cont_survivor_uci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
	  (line hazard_cont_survivor eventime if eventime >= 0 , lcolor(black) lwidth(medthick)) , ///
		xline(-1, lcolor(black) lpattern(dot)) ///
		xlabel(-5(1)5, grid) ///
		ylabel(0(20)100, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		ytitle("Urban Survival Rate (percent)") ///
		name(survival_ifls, replace) ///
		nodraw

  graph set eps fontface Garamond
	graph set window fontface Garamond

  graph combine eventstudy_ifls_survivor survival_ifls , ///
	  rows(2) ///
		imargin(0 0 0 0) ///
		graphregion(color(white) lcolor(white)) ///
		ysize(6)

	graph export "FigureA4_IFLS.eps" , replace

	graph set window fontface default
	graph set eps fontface default

restore


********************************************************************************
*** Figure A5: Event Study of Rural Migration
********************************************************************************
preserve

	sort pidlink year
	by pidlink: gen obsnum = _n

	gen moveU2R = 1 if urban == 0 & l.urban == 1 & urban_birth == 1
	gen temp = year if moveU2R == 1
	egen firstmoveU2R = min(temp) , by(pidlink)
	drop temp
	
	gen eventime = year - firstmoveU2R

	forvalues i = -5/5 {
		if `i' < 0 {
			gen timedum_`=-`i'' = eventime==`i'
		}
		else {
			gen timedum`i' = eventime==`i'
		}
	}

	gen endpoint_pre = eventime <= -6
	gen endpoint_post = eventime >= 6
	replace endpoint_post = 0 if missing(eventime)

	gen temp = eventime if urban==1 & eventime > 0
	egen first_posturban = min(temp) , by(pidlink)
	drop temp

	gen stillurban = eventime < first_posturban & eventime >= 0

	forvalues i=1/5 {
			gen timedum_survivor`i' = eventime==`i' & (stillurban==1)
			gen timedum_notsurvivor`i' = eventime==`i' & (stillurban==0)
  }

	gen endpoint_survivor_post = endpoint_post & (stillurban==1)
	gen endpoint_notsurvivor_post = endpoint_post & (stillurban==0)

	order timedum_survivor*, after(endpoint_post)
	order timedum_notsurvivor*, after(timedum_survivor5)
	order endpoint_survivor*, after(timedum_notsurvivor5)

	xtreg lninc_h timedum_5-timedum5 endpoint_pre endpoint_post i.year, fe
	xtreg lninc_h timedum_5-timedum0 timedum_survivor* timedum_notsurvivor* endpoint_pre endpoint_survivor_post endpoint_notsurvivor_post i.year, fe

  xtreg lninc_h timedum_5-timedum_2 /// pre
	              timedum0-timedum5 /// post
								endpoint_pre endpoint_post /// pooled endpoints
								age_sq i.year , ///
	  fe i(pidlink) cluster(pidlink) robust // controls

	matrix coef_u2r = J(11,10,.)
	matrix colnames coef_u2r = eventime /// 1
	  coef coef_lci coef_uci /// 4
	  frac_urban frac_urban_lci frac_urban_uci /// 7
		hazard_cont hazard_cont_lci hazard_cont_uci
	forvalues i=-5/5 {
		matrix coef_u2r[`i'+6,1] = `i'

		if `i' <= -2 {
		  
		  matrix coef_u2r[`i'+6,2] = _b[timedum_`=-`i'']
			matrix coef_u2r[`i'+6,3] = _b[timedum_`=-`i''] - _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef_u2r[`i'+6,4] = _b[timedum_`=-`i''] + _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)

			matrix coef_u2r[`i'+6,5] = 0
			matrix coef_u2r[`i'+6,8] = 0
		}
		if `i' == -1 {
		  
		  matrix coef_u2r[`i'+6,2] = 0
			
			matrix coef_u2r[`i'+6,5] = 0
			matrix coef_u2r[`i'+6,8] = 0
		}
		if `i' >= 0 {
		  
			matrix coef_u2r[`i'+6,2] = _b[timedum`i']
			matrix coef_u2r[`i'+6,3] = _b[timedum`i'] - _se[timedum`i']*invttail(e(df_r), 0.025)
			matrix coef_u2r[`i'+6,4] = _b[timedum`i'] + _se[timedum`i']*invttail(e(df_r), 0.025)
			
			quietly sum urban if eventime==`i'
			matrix coef_u2r[`i'+6,5] = 100*r(mean)
			matrix coef_u2r[`i'+6,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_u2r[`i'+6,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			
			quietly sum stillurban if eventime==`i'
			matrix coef_u2r[`i'+6,8] = 100*r(mean)
			matrix coef_u2r[`i'+6,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_u2r[`i'+6,10] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}
	}

  xtreg lninc_h timedum_5-timedum_2 /// pre
							  timedum0 /// first period
								timedum_survivor1-timedum_survivor5 /// post for survivors
								timedum_notsurvivor1-timedum_notsurvivor5 /// post for not survivors
								endpoint_pre /// pre end points
								endpoint_survivor_post endpoint_notsurvivor_post /// pooled endpoints for survivors
								age_sq i.year , ///
	  fe i(pidlink) cluster(pidlink) robust // controls

	matrix coef_u2r_survivor = J(11,10,.)
	matrix coef_u2r_notsurvivor = J(11,10,.)

	matrix colnames coef_u2r_survivor = eventime /// 1
	  coef_survivor coef_survivor_lci coef_survivor_uci /// 4
	  frac_urban_survivor frac_urban_survivor_lci frac_urban_survivor_uci /// 7
		hazard_cont_survivor hazard_cont_survivor_lci hazard_cont_survivor_uci

	matrix colnames coef_u2r_notsurvivor = eventime /// 1
	  coef_notsurvivor coef_notsurvivor_lci coef_notsurvivor_uci /// 4
	  frac_urban_notsurvivor frac_urban_notsurvivor_lci frac_urban_notsurvivor_uci /// 7
		hazard_cont_notsurvivor hazard_cont_notsurvivor_lci hazard_cont_notsurvivor_uci

	forvalues i=-5/5 {
		matrix coef_u2r_survivor[`i'+6,1] = `i'
		matrix coef_u2r_notsurvivor[`i'+6,1] = `i'

		if `i' <= -2 {
		  
		  matrix coef_u2r_survivor[`i'+6,2] = _b[timedum_`=-`i'']
			matrix coef_u2r_survivor[`i'+6,3] = _b[timedum_`=-`i''] - _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)
			matrix coef_u2r_survivor[`i'+6,4] = _b[timedum_`=-`i''] + _se[timedum_`=-`i'']*invttail(e(df_r), 0.025)

			matrix coef_u2r_survivor[`i'+6,5] = 0
			matrix coef_u2r_survivor[`i'+6,8] = 0
		}
		if `i' == -1 {
		  
		  matrix coef_u2r_survivor[`i'+6,2] = 0
			
			matrix coef_u2r_survivor[`i'+6,5] = 0
			matrix coef_u2r_survivor[`i'+6,8] = 0
		}
		if `i' == 0 {
			
		  matrix coef_u2r_survivor[`i'+6,2] = _b[timedum0]
			matrix coef_u2r_survivor[`i'+6,3] = _b[timedum0] - _se[timedum0]*invttail(e(df_r), 0.025)
			matrix coef_u2r_survivor[`i'+6,4] = _b[timedum0] + _se[timedum0]*invttail(e(df_r), 0.025)

			quietly sum urban if eventime==`i'
			matrix coef_u2r_survivor[`i'+6,5] = 100*r(mean)
			matrix coef_u2r_survivor[`i'+6,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_u2r_survivor[`i'+6,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			
			quietly sum stillurban if eventime==`i'
			matrix coef_u2r_survivor[`i'+6,8] = 100*r(mean)
			matrix coef_u2r_survivor[`i'+6,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_u2r_survivor[`i'+6,10] =100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}
		if `i' > 0 {
		  
			matrix coef_u2r_survivor[`i'+6,2] = _b[timedum_survivor`i']
			matrix coef_u2r_survivor[`i'+6,3] = _b[timedum_survivor`i'] - _se[timedum_survivor`i']*invttail(e(df_r), 0.025)
			matrix coef_u2r_survivor[`i'+6,4] = _b[timedum_survivor`i'] + _se[timedum_survivor`i']*invttail(e(df_r), 0.025)
			
			quietly sum urban if eventime==`i'
			matrix coef_u2r_survivor[`i'+6,5] = 100*r(mean)
			matrix coef_u2r_survivor[`i'+6,6] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_u2r_survivor[`i'+6,7] = 100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			
			quietly sum stillurban if eventime==`i'
			matrix coef_u2r_survivor[`i'+6,8] = 100*r(mean)
			matrix coef_u2r_survivor[`i'+6,9] = 100*min(max(r(mean) - r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
			matrix coef_u2r_survivor[`i'+6,10] =100*min(max(r(mean) + r(sd)/sqrt(r(N))*invttail(r(N)-1, 0.025),0),1)
		}

		if `i' == 0 {
		  matrix coef_u2r_notsurvivor[`i'+6,2] = _b[timedum0]
			matrix coef_u2r_notsurvivor[`i'+6,3] = _b[timedum0] - _se[timedum0]*invttail(e(df_r), 0.025)
			matrix coef_u2r_notsurvivor[`i'+6,4] = _b[timedum0] + _se[timedum0]*invttail(e(df_r), 0.025)

		}
		if `i' > 0 {
		  
			matrix coef_u2r_notsurvivor[`i'+6,2] = _b[timedum_notsurvivor`i']
			matrix coef_u2r_notsurvivor[`i'+6,3] = coef_u2r_notsurvivor[`i'+6,2] - _se[timedum_notsurvivor`i']*invttail(e(df_r), 0.025)
			matrix coef_u2r_notsurvivor[`i'+6,4] = coef_u2r_notsurvivor[`i'+6,2] + _se[timedum_notsurvivor`i']*invttail(e(df_r), 0.025)

		}
	}


	clear

	svmat coef_u2r , names(col)
*** Turn rural wage gap in to urban wage gap
	foreach var of varlist coef* {
	  replace `var' = -`var'
	}

	label var eventime "Years relative to first rural move"
*** Graph event study
	graph twoway ///
		(line coef_lci eventime, lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
		(line coef_uci eventime, lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
	  (line coef eventime, lcolor(black) lwidth(medthick)) ///
		(pcarrowi 0.8 -1.2 0.8 -1.7, lcolor(black) mcolor(black) mlabcolor(black)) ///
		(pcarrowi 0.8 -0.8 0.8 -0.3, lcolor(black) mcolor(black) mlabcolor(black)), /// arrows
		text(0.88 -1.54 "Urban") ///
		text(0.88 -0.4 "Rural") ///
		xline(-1, lcolor(black) lpattern(dot)) ///
		yline(0, lcolor(black) lwidth(thin)) ///
		xlabel(-5(1)5, grid nolabels) ///
		ylabel(-1(0.5)1, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		xtitle("") ///
		ytitle("Urban Wage Gap (log points)") ///
		name(eventstudy_ifls_u2r, replace) ///
		nodraw
*** Graph Survival Rate in Urban areas		
	graph twoway ///
		(line hazard_cont_lci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
		(line hazard_cont_uci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
	  (line hazard_cont eventime if eventime >= 0 , lcolor(black) lwidth(medthick)) , ///
		xline(-1, lcolor(black) lpattern(dot)) ///
		xlabel(-5(1)5, grid) ///
		ylabel(0(20)100, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		ytitle("Rural Survival Rate (percent)") ///
		name(survival_ifls_u2r, replace) ///
		nodraw

  graph set eps fontface Garamond
	graph set window fontface Garamond

  graph combine eventstudy_ifls_u2r survival_ifls_u2r , ///
	  rows(2) ///
		imargin(0 0 0 0) ///
		graphregion(color(white) lcolor(white)) ///
		ysize(6)

	graph export "FigureA5_IFLS.eps" , replace

	graph set window fontface default
	graph set eps fontface default

restore


********************************************************************************
*** Figure A6: Event Study of Rural Migration for Survivors
********************************************************************************
preserve
	clear

	svmat coef_u2r_survivor , names(col)
	drop eventime
	svmat coef_u2r_notsurvivor, names(col)
*** Turn rural wage gap in to urban wage gap
	foreach var of varlist coef* {
	  replace `var' = -`var'
	}

	label var eventime "Years relative to first rural move"
*** Graph event study
	local y_pos_survivor = coef_survivor_uci[10]
	local x_pos_survivor = eventime[10]

	local y_pos_notsurvivor = coef_notsurvivor_uci[7]
	local x_pos_notsurvivor = eventime[7]

	graph twoway ///
		(line coef_survivor_lci eventime, lcolor(black) lwidth(thin) lpattern(dash) cmissing(n)) ///
		(line coef_survivor_uci eventime, lcolor(black) lwidth(thin) lpattern(dash) cmissing(n)) ///
		(line coef_notsurvivor_lci eventime, lcolor(gs10) lwidth(thin) lpattern(dash) cmissing(n)) ///
		(line coef_notsurvivor_uci eventime, lcolor(gs10) lwidth(thin) lpattern(dash) cmissing(n)) ///
	  (line coef_survivor eventime, lcolor(black) lwidth(medthick)) ///
	  (line coef_notsurvivor eventime, lcolor(gs10) lwidth(medthick)) ///
		(pcarrowi 0.8 -1.2 0.8 -1.7, lcolor(black) mcolor(black) mlabcolor(black)) ///
		(pcarrowi 0.8 -0.8 0.8 -0.3, lcolor(black) mcolor(black) mlabcolor(black)), /// arrows
		text(0.88 -1.54 "Urban") ///
		text(0.88 -0.4 "Rural") ///
		xline(-1, lcolor(black) lpattern(dot)) ///
		yline(0, lcolor(black) lwidth(thin)) ///
		xlabel(-5(1)5, grid nolabels) ///
		ylabel(-1(0.5)1, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		xtitle("") ///
		ytitle("Urban Wage Gap (log points)") ///
		text(`y_pos_survivor' `x_pos_survivor'  "Survivor", placement(s) color(black)) ///
		text(`y_pos_notsurvivor' `x_pos_notsurvivor'  "Not Survivor", placement(s) color(gs7)) ///
		name(eventstudy_ifls_u2r_survivor, replace) ///
		nodraw
*** Graph Survival Rate in Rural areas
	graph twoway ///
		(line hazard_cont_survivor_lci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
		(line hazard_cont_survivor_uci eventime if eventime >= 0 , lwidth(thin) lcolor(black) lpattern(dash) cmissing(n)) ///
	  (line hazard_cont_survivor eventime if eventime >= 0 , lcolor(black) lwidth(medthick)) , ///
		xline(-1, lcolor(black) lpattern(dot)) ///
		xlabel(-5(1)5, grid) ///
		ylabel(0(20)100, nogrid) ///
		graphregion(color(white) lcolor(white)) ///
		legend(off) ///
		ytitle("Rural Survival Rate (percent)") ///
		name(survival_ifls_u2r, replace) ///
		nodraw

  graph set eps fontface Garamond
	graph set window fontface Garamond

  graph combine eventstudy_ifls_u2r_survivor survival_ifls_u2r , ///
	  rows(2) ///
		imargin(0 0 0 0) ///
		graphregion(color(white) lcolor(white)) ///
		ysize(6)

	graph export "FigureA6_IFLS.eps", replace

	graph set window fontface default
	graph set eps fontface default

restore


********************************************************************************
*** Figure A7: Marginal Distributions of Cognitive Ability
********************************************************************************
use "Intergen_Analysis_IFLS.dta", clear
xtset pidlink year
tostring fath_pidlink moth_pidlink, replace								

tempfile dadfile momfile

keep pidlink year female age ravens_norm ravens_norm_sq educyr urban_birth

egen max_educ = max(educyr), by(pidlink)
drop educyr

reshape wide age, i(pidlink) j(year)

preserve
rename pidlink fath_pidlink
foreach var of varlist age1988-max_educ {
  rename `var' fath_`var'
}
tostring fath_pidlink , replace
save `dadfile', replace
restore

rename pidlink moth_pidlink
foreach var of varlist age1988-max_educ {
  rename `var' moth_`var'
}
tostring moth_pidlink , replace
save `momfile', replace

use "Intergen_Analysis_IFLS.dta", clear
keep pidlink year age female ravens_norm ravens_norm_sq educyr urban_birth moth_pidlink fath_pidlink

egen max_educ = max(educyr), by(pidlink)
drop educyr

tostring fath_pidlink moth_pidlink, replace

tempfile fathlink mothlink

foreach parent in fath moth {
	replace `parent'_pidlink = "" if `parent'_pidlink == "."
	preserve
	keep pidlink `parent'_pidlink
	drop if missing(`parent'_pidlink)
	duplicates drop
	destring `parent'_pidlink, replace 
	egen check = count(`parent'_pidlink), by(pidlink)
	count if check > 1
	assert r(N) == 0
	tostring `parent'_pidlink, replace		
	save ``parent'link'
	restore	
}

drop fath_pidlink moth_pidlink
merge m:1 pidlink using `fathlink', assert(1 3)
drop _merge
merge m:1 pidlink using `mothlink', assert(1 3)
drop _merge

reshape wide age, i(pidlink) j(year)

merge m:1 fath_pidlink using `dadfile'
drop if _merge==2
gen has_fath = _merge==3
drop _merge

merge m:1 moth_pidlink using `momfile'
drop if _merge==2
gen has_moth = _merge==3
drop _merge
*** Generate mom and dad age at birth
forvalues i = 1988/2015 {
  gen fath_temp`i' = fath_age`i' - age`i'
	gen moth_temp`i' = moth_age`i' - age`i'

	drop fath_age`i' moth_age`i' age`i'
}

egen fath_ageatbirth = rowmean(fath_temp*)
egen moth_ageatbirth = rowmean(moth_temp*)

egen has_parent = rowmax(has_fath has_moth)

drop fath_temp* moth_temp*

estimates clear

label define bornurban 0 "Born Rural" 1 "Born Urban"
label values urban_birth bornurban

gen fath_max_educ_sq = fath_max_educ^2
gen moth_max_educ_sq = moth_max_educ^2

gen fath_ageatbirth_sq = fath_ageatbirth^2
gen moth_ageatbirth_sq = moth_ageatbirth^2

*** Generate parent variables to create the same table without father/mother distinction
egen parent_urban_birth = rowmean(fath_urban_birth moth_urban_birth)

egen parent_max_educ = rowmean(fath_max_educ moth_max_educ)
gen parent_max_educ_sq = parent_max_educ^2

egen parent_ageatbirth = rowmean(fath_ageatbirth moth_ageatbirth)
gen parent_ageatbirth_sq = parent_ageatbirth^2

egen parent_ravens_norm = rowmean(fath_ravens_norm moth_ravens_norm)
gen parent_ravens_norm_sq = parent_ravens_norm^2

*** Tables
local control2 female
local control3 female parent_urban_birth parent_ageatbirth
local control4 `control3' parent_max_educ parent_ravens_norm
local control5 `control4' parent_ageatbirth_sq ///
                          parent_max_educ_sq ///
													parent_ravens_norm_sq

egen hasmiss = rowmiss(`control5')
drop if hasmiss >0
drop hasmiss

eststo raven_regb1: reg ravens_norm urban_birth if has_parent==1, robust
estadd local square "N"
eststo raven_regb2: reg ravens_norm urban_birth `control2' if has_parent==1, robust
estadd local square "N"
eststo raven_regb3: reg ravens_norm urban_birth `control3' if has_parent==1, robust
estadd local square "N"
eststo raven_regb4: reg ravens_norm urban_birth `control4' if has_parent==1, robust
estadd local square "N"
eststo raven_regb5: reg ravens_norm urban_birth `control5' if has_parent==1, robust
estadd local square "Y"

*** Figures
graph twoway ///
  (kdensity ravens_norm if has_parent==1 & urban_birth==0, lcolor(gs7) lpattern(solid)) ///
	(kdensity ravens_norm if has_parent==1 & urban_birth==1, lcolor(black) lpatter(dash)), ///
	  graphregion(color(white)) ///
		ytitle("Density") xtitle("Raven's Score, Normalized") ///
		legend(label(1 "Born Rural") label(2 "Born Urban"))
graph export "FigureA7_IFLS.eps", replace
						

********************************************************************************
*** Figure A8: Joint Distribution of Rural and Urban Productivities
********************************************************************************
use "Main_Analysis_IFLS.dta", clear														
preserve

capture program drop crc_boot
program define crc_boot , rclass
  preserve
    bsample, cluster(pidlink) idcluster(temp_id)

		gen double pidlink_u = temp_id*10+urban


		areg lninc_h age_sq i.year, a(pidlink_u)
		predict pidlink_fe, d

		gen temp_r = pidlink_fe if urban==0
		gen temp_u = pidlink_fe if urban==1

		egen fe_r = mean(temp_r) , by(pidlink)
		egen fe_u = mean(temp_u) , by(pidlink)

		quietly sum fe_r if obsnum==1 & missing(fe_u) & urban_birth==0
		replace fe_r = fe_r - r(mean)
		replace fe_u = fe_u - r(mean)

		reg fe_u fe_r if obsnum==1 & urban_birth==0
		return scalar coef_rural = _b[fe_r]

		corr fe_u fe_r if obsnum==1 & urban_birth==0
		return scalar corr_rural = r(rho)

		reg fe_u fe_r if obsnum==1 & urban_birth==1
		return scalar coef_urban = _b[fe_r]

		corr fe_u fe_r if obsnum==1 & urban_birth==1
		return scalar corr_urban = r(rho)

  restore
end

sort pidlink year
by pidlink: gen obsnum = _n
*** Generate an urban by pidlink variable
gen double pidlink_u = pidlink*10+urban

areg lninc_h age_sq i.year, a(pidlink_u)
predict pidlink_fe, d
*** Generate for each person their individual and urban effect
gen temp_r = pidlink_fe if urban==0
gen temp_u = pidlink_fe if urban==1

egen fe_r = mean(temp_r) , by(pidlink)
egen fe_u = mean(temp_u) , by(pidlink)

quietly sum fe_r if obsnum==1 & missing(fe_u) & urban_birth==0
replace fe_r = fe_r - r(mean)
replace fe_u = fe_u - r(mean)

egen fe_overall = mean(pidlink_fe) , by(pidlink)

gen fe_u_r = fe_u - fe_r

label var fe_r "Rural FE"
label var fe_u "Urban FE"
label var fe_u_r "Difference"
*** Rural starters
*** Graph urban FE against rural FE
sum fe_r fe_u if obsnum==1 & urban_birth==0
reg fe_u fe_r if obsnum==1 & urban_birth==0

local y_pos = _b[_cons] + 3.2*_b[fe_r]
local b = _b[fe_r]

quietly sum fe_r if obsnum==1 & !missing(fe_u) & urban_birth==0
local min = r(min)
local max = r(max)

graph twoway 	(function y = x, lcolor(gs10) lwidth(medthin) range(-6 6)) ///
	(scatter fe_u fe_r if obsnum==1 & urban_birth==0 , msymbol(circle_hollow) mcolor(black) mlwidth(thin)) ///
	(lfit fe_u fe_r if obsnum==1 & urban_birth==0, color(black) range(-6 6) lpattern(dash) lwidth(medthick))  , ///
graphregion(color(white) lcolor(white)) ///
legend(off) ///
ysca(alt range(-6 6)) ///
xsca(alt range(-6 6)) ///
ylabel(-6(3)6) ///
xlabel(-6(3)6 , grid gmax) ///
ytitle("") ///
xtitle("") ///
text(5 5 "45 degree line", placement(nw)) ///
text(`y_pos' 3.2 "{&beta} = `: di %4.3f `b''", placement(se)) ///
text(`=`y_pos'-0.45' 3.2 "     (`: di %4.3f bstat[2,1]')", placement(se)) ///
name(ur_scatter_rural, replace) ///
nodraw
*** Histogram of urban fixed effect for those who move
quietly sum fe_u if obsnum==1 & !missing(fe_r) & urban_birth==0
graph twoway ///
	(histogram fe_u if obsnum==1 & !missing(fe_r) & urban_birth==0,  ///
		start(-5.625) width(0.375) fcolor(none) lcolor(black) lwidth(medthick) horiz ) ///
	(scatteri `r(mean)' 0 `r(mean)' 0.6, connect(direct) msymbol(none) lcolor(black) lpattern(dot) lwidth(thick)) , ///
xsca(alt reverse)  ///
ylabel(-6(3)6, grid gmax) ///
xlabel(minmax, labcolor(white) tlcolor(none)) ///
graphregion(color(white) lcolor(white)) ///
xtitle("") ///
ytitle("Average Urban Productivity") ///
fxsize(25) ///
text(1.2 0.58 "{&mu} = `: di %4.3f r(mean)'", placement(n) orientation(vertical)) ///
text(1.2 0.48 "{&sigma} = `: di %4.3f r(sd)'", placement(n) orientation(vertical)) ///
legend(off) ///
name(ur_hist_u_rural, replace) ///
nodraw
*** Histogram of rural fixed effect for those who don't move
quietly sum fe_r if obsnum==1 & missing(fe_u) & urban_birth==0
graph twoway ///
	(histogram fe_r if obsnum==1  & missing(fe_u) & urban_birth==0, start(-5.625) width(0.375) fcolor(gs13) lcolor(gs13) lwidth(none)) ///
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
name(ur_hist_r_ruralnonmigrants, replace) ///
nodraw
*** Histogram of rural fixed effect for those who move
quietly sum fe_r if obsnum==1 & !missing(fe_u) & urban_birth==0
graph twoway ///
	(histogram fe_r if obsnum==1  & !missing(fe_u) & urban_birth==0, start(-5.625) width(0.375) fcolor(white) lcolor(black) lwidth(medthick)) ///
	(scatteri 0 `r(mean)' 0.6 `r(mean)' , connect(direct) msymbol(none) lcolor(black) lpattern(dot) lwidth(thick)) , ///
ysca(alt) ///
ylabel(0(0.1)0.5 , nogrid labcolor(white) tlcolor(none)) ///
xlabel(-6(3)6, grid gmax nolabels) ///
ytitle("") ///
xtitle("") ///
fysize(25) ///
legend(off) ///
graphregion(color(white) lcolor(white)) ///
name(ur_hist_r_ruralmigrants, replace) ///
text(0.63 0.5 "{&mu} = `: di %4.3f r(mean)'", placement(e)) ///
text(0.56 0.5 "{&sigma} = `: di %4.3f r(sd)'", placement(e)) ///
text(0.46 -2.5 "Rural-to-Urban Migrants", placement(w)) ///
nodraw

graph set eps fontface Garamond

graph combine ur_hist_u_rural ur_scatter_rural ur_hist_r_ruralmigrants ur_hist_r_ruralnonmigrants , ///
	hole(3 5) ///
cols(2) ///
graphregion(color(white) lcolor(white)) ///
ysize(7) ///
imargin(0 0 0 0)

graph export "FigureA8_IFLS_rural.eps" , replace

graph set eps fontface default

*** Graph urban FE against rural FE
  sum fe_r fe_u if obsnum==1 & urban_birth==1
  reg fe_u fe_r if obsnum==1 & urban_birth==1


  local y_pos = _b[_cons] + 3.2*_b[fe_r]
  local b = _b[fe_r]

  quietly sum fe_r if obsnum==1 & !missing(fe_u) & urban_birth==1
  local min = r(min)
  local max = r(max)

  graph twoway 	(function y = x, lcolor(gs10) lwidth(medthin) range(-6 6)) ///
	  (scatter fe_u fe_r if obsnum==1 & urban_birth==1, msymbol(circle_hollow) mcolor(black) mlwidth(thin)) ///
		(lfit fe_u fe_r if obsnum==1 & urban_birth==1, color(black) range(-6 6) lpattern(dash) lwidth(medthick))  , ///
	graphregion(color(white) lcolor(white)) ///
	legend(off) ///
	ysca(alt range(-6 6)) ///
	xsca(alt range(-6 6)) ///
	ylabel(-6(3)6) ///
	xlabel(-6(3)6 , grid gmax) ///
	ytitle("") ///
	xtitle("") ///
	text(5 5 "45 degree line", placement(nw)) ///
	text(`y_pos' 3.2 "{&beta} = `: di %4.3f `b''", placement(se)) ///
  text(`=`y_pos'-0.45' 3.2 "     (`: di %4.3f bstat[2,3]')", placement(se)) ///
	name(ur_scatter_urban, replace) ///
	nodraw
	
*** Histogram of urban fixed effect for those who move
  quietly sum fe_u if obsnum==1 & !missing(fe_r) & urban_birth==1
  graph twoway ///
    (histogram fe_u if obsnum==1 & !missing(fe_r) & urban_birth==1,  ///
	    start(-7.625) width(0.375) fcolor(none) lcolor(black) lwidth(medthick) horiz ) ///
	  (scatteri `r(mean)' 0 `r(mean)' 0.6, connect(direct) msymbol(none) lcolor(black) lpattern(dot) lwidth(thick)) , ///
	xsca(alt reverse)  ///
	ylabel(-8(4)8, grid gmax nolabel) ///
	xlabel(minmax, labcolor(white) tlcolor(none)) ///
	graphregion(color(white) lcolor(white)) ///
	xtitle("") ///
	fxsize(22) ///
	text(1.0 0.62 "{&mu} = `: di %4.3f r(mean)'", placement(n) orientation(vertical)) ///
	text(1.0 0.53 "{&sigma} = `: di %4.3f r(sd)'", placement(n) orientation(vertical)) ///
	text(-2 0.4 "Urban-to-Rural Migrants", placement(s) orientation(vertical)) ///
	legend(off) ///
	name(ur_hist_u_urbanmigrants, replace) ///
	nodraw
	
*** Histogram of urban fixed effect for those who don't move
  quietly sum fe_u if obsnum==1 & missing(fe_r) & urban_birth==1
  graph twoway ///
    (histogram fe_u if obsnum==1 & missing(fe_r) & urban_birth==1,  ///
	    start(-7.625) width(0.375) fcolor(gs13) lcolor(gs13) lwidth(none) horiz ) ///
	  (scatteri `r(mean)' 0 `r(mean)' 0.6, connect(direct) msymbol(none) lcolor(black) lpattern(dot) lwidth(thick)) , ///
	xsca(alt reverse)  ///
	ylabel(-8(4)8, grid gmax) ///
	xlabel(minmax, labcolor(white) tlcolor(none)) ///
	graphregion(color(white) lcolor(white)) ///
	xtitle("") ///
	ytitle("Average Urban Productivity") ///
	fxsize(25) ///
	text(0.9 0.61 "{&mu} = `: di %4.3f r(mean)'", placement(n) orientation(vertical)) ///
	text(0.9 0.52 "{&sigma} = `: di %4.3f r(sd)'", placement(n) orientation(vertical)) ///
	text(-2 0.4 "Always Urban", placement(s) orientation(vertical)) ///
	legend(off) ///
	name(ur_hist_u_urbannonmigrants, replace) ///
	nodraw
	
*** Rural fixed effect for those who move
  quietly sum fe_r if obsnum==1 & !missing(fe_u) & urban_birth==1
  graph twoway ///
		(histogram fe_r if obsnum==1  & !missing(fe_u) & urban_birth==1, start(-7.625) width(0.375) fcolor(white) lcolor(black) lwidth(medthick)) ///
		(scatteri 0 `r(mean)' 0.6 `r(mean)' , connect(direct) msymbol(none) lcolor(black) lpattern(dot) lwidth(thick)) , ///
  ysca(alt) ///
	ylabel(0(0.1)0.5 , nogrid labcolor(white) tlcolor(none)) ///
	xlabel(-8(4)8, grid gmax) ///
	ytitle("") ///
	xtitle("Average Rural Productivity") ///
	fysize(25) ///
	legend(off) ///
	graphregion(color(white) lcolor(white)) ///
	text(0.63 0.6 "{&mu} = `: di %4.3f r(mean)'", placement(e)) ///
	text(0.54 0.6 "{&sigma} = `: di %4.3f r(sd)'", placement(e)) ///
	name(ur_hist_r_urban, replace) ///
	nodraw

	graph set eps fontface Garamond

  graph combine ur_hist_u_urbannonmigrants ur_hist_u_urbanmigrants ///
	  ur_scatter_urban ur_hist_r_urban , ///
    hole(4 5) ///
	cols(3) ///
	graphregion(color(white) lcolor(white)) ///
	xsize(6) ///
	ysize(5) ///
	imargin(0 0 0 0)

  graph export "FigureA8_IFLS_urban.eps" , replace
	
	graph set eps fontface default

restore


********************************************************************************		
*** Table A1: Correlates of Employment in Non-Agriculture
********************************************************************************		
preserve
 
  gen educpri = educlv >= 1 if !missing(educlv)
  gen educsec = educlv >= 3 if !missing(educlv)
  gen educcol = educlv == 4 if !missing(educlv)

  egen always_rural = max(max(urban,urban_birth)), by(pidlink)
  replace always_rural = 1 - always_rural
  
  egen always_urban = min(min(urban,urban_birth)), by(pidlink)

	  gen rural_nonmigrants = migr_ever == 0 & always_rural == 1
   
	  gen migrRR_ever = always_rural==1 & migr_ever==1

  gen migrRU_ever = always_rural==0 & urban_birth==0
  gen migrUR_ever = always_urban==0 & urban_birth==1

  egen nonag_ever = max(nonag) , by(pidlink)

  collapse (first) ravens_norm educpri educsec educcol female ///
    always_rural migrRU_ever migrUR_ever always_urban ///
	  nonag_ever urban_birth, by(pidlink)

  label var ravens_norm "Raven's Z-score"
  label var educpri "Primary Ed."
  label var educsec "Secondary Ed."
  label var educcol "College"
  label var female "Female"
  label var always_rural "Always Rural"
  label var migrRU_ever "Rural-to-Urban Migrants"
  label var migrUR_ever "Urban-to-Rural Migrants"
  label var always_urban "Always Urban"
  label var nonag_ever "Ever Non-ag"

  eststo all: estpost sum educpri educsec educcol female ravens_norm
  eststo always_rural: estpost sum educpri educsec educcol female ravens_norm if always_rural==1
  eststo migrRU_ever: estpost sum educpri educsec educcol female ravens_norm if migrRU_ever==1
  eststo migrUR_ever: estpost sum educpri educsec educcol female ravens_norm if migrUR_ever==1
  eststo always_urban: estpost sum educpri educsec educcol female ravens_norm if always_urban==1

  eststo counts: estpost sum educpri educsec educcol female ravens_norm

  quietly count
  local num_all = r(N)
  quietly count if always_rural==1
  local num_always_rural = r(N)
  quietly count if migrRU_ever==1
  local num_migrRU_ever = r(N)
  quietly count if migrUR_ever==1
  local num_migrUR_ever = r(N)
  quietly count if always_urban==1
  local num_always_urban = r(N)

  esttab all always_rural migrRU_ever always_urban migrUR_ever counts ///
    using "Table2_IFLS.tex", replace type fragment ///
	cells(mean(pattern(1 1 1 1 1 0) fmt(%9.3f))& ///
          count(pattern(0 0 0 0 0 1) fmt(%9.0f)) ///
	      sd(par([ ]) pattern(1 1 1 1 1 0) fmt(%9.3f))) ///
    noobs ///
	title("Indonesia") ///
	mlabels("N=`num_all'" ///
			"N=`num_always_rural'" ///
	        "N=`num_migrRU_ever'" ///
			"N=`num_always_urban'" ///
			"N=`num_migrUR_ever'" ///
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

  local regs

  foreach var of varlist educpri educsec educcol female ravens_norm {
    eststo `var': reg nonag_ever `var' if (always_rural==1 | migrRU_ever==1), robust
  }

  eststo all1: reg nonag_ever educpri educsec educcol female  ///
	if (always_rural==1 | migrRU_ever==1), robust
  eststo all2: reg nonag_ever educpri educsec educcol female ravens_norm ///
	if (always_rural==1 | migrRU_ever==1), robust

  esttab educpri educsec educcol female ravens_norm all2 all1 ///
    using "TableA1_IFLS.tex", replace type fragment ///
	  label se(3) nomtitles ///
    title("Correlates of Employment in Non-agriculture (among those who start in rural)") ///
	  nonotes ///
	  addnote("Robust standard errors in parenthesis. Sample in all columns restricted to individuals who report" ///
	          "income, hours, and location.") ///
	  legend ///
	  booktabs ///
	  width(\hsize)

	  
********************************************************************************		
*** Table A2: Correlates of Urban Migration
********************************************************************************		
*** Regression predicting rural-urban migrants relative to always rural
  local regs

	eststo all2: reg migrRU_ever educpri educsec educcol female ravens_norm ///
 	  if (always_rural==1 | migrRU_ever==1), robust

  esttab all2 ///
    using "TableA2_IFLS.tex", replace type fragment ///
	  label ///
		se(3) ///
		nomtitles ///
    title("Correlates of Rural-Urban Migration (among those who start in rural)") ///
 	  nonotes ///
	  addnote("Robust standard errors in parenthesis. Sample in all columns restricted to individuals who report" ///
	          "income, hours, and location.") ///
	  legend ///
	  booktabs ///
	  width(\hsize)

	local regs
 

  foreach var of varlist educpri educsec educcol female ravens_norm {
    eststo `var': reg migrRU_ever `var' if (always_rural==1 | migrRU_ever==1), robust
  }

  eststo all1: reg migrRU_ever educpri educsec educcol female  ///
	  if (always_rural==1 | migrRU_ever==1), robust
  eststo all2: reg migrRU_ever educpri educsec educcol female ravens_norm ///
	  if (always_rural==1 | migrRU_ever==1), robust

  esttab educpri educsec educcol female ravens_norm all2 all1 ///
    using "TableA2_IFLS.tex", replace type fragment ///
	  label ///
		se(3) ///
		nomtitles ///
    title("Correlates of Rural-Urban Migration (among those who start in rural)") ///
 	  nonotes ///
	  addnote("Robust standard errors in parenthesis. Sample in all columns restricted to individuals who report" ///
	          "income, hours, and location.") ///
	  legend ///
	  booktabs ///
	  width(\hsize)

	  
********************************************************************************		
*** Table A3: Correlates of Employment in Non-Agriculture—Indonesia (Born Urban)
********************************************************************************
*** Regression predicting ag-nonag relative to always urban
  local regs

  foreach var of varlist educpri educsec educcol female ravens_norm {
    eststo `var': reg nonag_ever `var' if (always_urban==1 | migrUR_ever==1), robust
  }

  eststo all1: reg nonag_ever educpri educsec educcol female  ///
	if (always_urban==1 | migrUR_ever==1), robust
  eststo all2: reg nonag_ever educpri educsec educcol female ravens_norm ///
	if (always_urban==1 | migrUR_ever==1), robust

  esttab educpri educsec educcol female ravens_norm all2 all1 ///
    using "TableA3_IFLS.tex", replace type fragment ///
	  label se(3) nomtitles ///
    title("Correlates of Employment in Non-agriculture (among those who start in urban)") ///
	  nonotes ///
	  addnote("Robust standard errors in parenthesis. Sample in all columns restricted to individuals who report" ///
	          "income, hours, and location.") ///
	  legend ///
	  booktabs ///
	  width(\hsize)

	  
********************************************************************************		
*** Table A4: Correlates of Rural Migration—Indonesia (Born Urban)
********************************************************************************
*** Regression predicting urban-rural migrants relative to always urban
  local regs

  foreach var of varlist educpri educsec educcol female ravens_norm {
    eststo `var': reg migrUR_ever `var' if (always_urban==1 | migrUR_ever==1), robust
  }

  eststo all1: reg migrUR_ever educpri educsec educcol female  ///
	  if (always_urban==1 | migrUR_ever==1), robust
  eststo all2: reg migrUR_ever educpri educsec educcol female ravens_norm ///
	  if (always_urban==1 | migrUR_ever==1), robust

  esttab educpri educsec educcol female ravens_norm all2 all1 ///
    using "TableA4_IFLS.tex", replace type fragment ///
	  label ///
		se(3) ///
		nomtitles ///
    title("Correlates of Urban-Rural Migration (among those who start in urban)") ///
 	  nonotes ///
	  addnote("Robust standard errors in parenthesis. Sample in all columns restricted to individuals who report" ///
	          "income, hours, and location.") ///
	  legend ///
	  booktabs ///
	  width(\hsize)

restore


********************************************************************************		
*** Table A6: Non-Agricultural/Agricultural Gap in Earnings using Alternative Definition of Agriculture
********************************************************************************
*** nonagonly
reg lninc nonagonly, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc nonagonly lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc nonagonly lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G																		
xtreg lninc_h nonagonly age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H																		
	
*** nonagany
reg lninc nonagany, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lninc nonagany lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lninc nonagany lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG																	
xtreg lninc_h nonagany age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store HH																	

esttab A C G H AA CC GG HH using "TableA6_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons lnhour lnhour_sq female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  ///
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

	
********************************************************************************		
*** Table A7: Non-Agricultural/Agricultural Gap in Earnings Within Rural Areas
********************************************************************************
preserve
*** If currently in rural area
keep if urban == 0

reg lninc nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc nonag lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lninc_h nonag age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H

esttab A C G H using "TableA7_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons lnhour lnhour_sq female age age_sq educyr educyr_sq age_sq *year*) ///
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
reg lnhour nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lnhour nonag female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
reg lnhour nonag female age age_sq educyr educyr_sq ravens_norm ravens_norm_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
reg lnhour nonag female age age_sq educyr educyr_sq i.year if NA_mover == 1, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local moverUonly "Y" , replace
estadd local cluster `e(N_clust)', replace
est store E
xtreg lnhour nonag age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G

esttab A C D E G using "TableA8_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons *year* age age_sq) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "" "" "")  /// 
	mgroups("Dependent variable: Log Hours", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE timeFE moverUonly N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Time fixed effects"' `"Switchers only"' `"Number of observations"' `"Number of individuals"'))

	
********************************************************************************		
*** Table A9: Urban/Rural Gap in Hours Worked
********************************************************************************
reg lnhour urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lnhour urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
reg lnhour urban female age age_sq educyr educyr_sq ravens_norm ravens_norm_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
reg lnhour urban female age age_sq educyr educyr_sq i.year if U_mover == 1, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local moverUonly "Y" , replace
estadd local cluster `e(N_clust)', replace
est store E
xtreg lnhour urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G

esttab A C D E G using "TableA9_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons *year* age age_sq) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "" "" "")  /// 
	mgroups("Dependent variable: Log Hours", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE timeFE moverUonly N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Time fixed effects"' `"Switchers only"' `"Number of observations"' `"Number of individuals"'))

	
********************************************************************************		
*** Table A10: Robustness to Alternative Agricultural Productivity Measures
********************************************************************************
*** Wage
xtreg lninc_h nonag age_sq i.year, fe i(pidlink) cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
xtreg lninc_h nonagonly age_sq i.year, fe i(pidlink) cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store B
xtreg lninc_h nonagany age_sq i.year, fe i(pidlink) cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store C

preserve
keep if !missing(lnforinc)
keep if !missing(lnforinc_h)
keep if !missing(lnforhour)
gen nonagW = nonag
lab var nonagW "Wage employment only"
xtreg lnforinc_h nonagW age_sq i.year, fe i(pidlink) cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store D
restore

preserve
keep if !missing(lninforinc)
keep if !missing(lninforinc_h)
keep if !missing(lninforhour)
gen nonagS = nonag
lab var nonagS "Self-employment only"
xtreg lninforinc_h nonagS age_sq i.year, fe i(pidlink) cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local contrhours "N" , replace
estadd local cluster `e(N_clust)', replace
est store E
restore

gen nonagW = nonag
gen nonagS = nonag
lab var nonagW "Wage employment only"
lab var nonagS "Self-employment only"

esttab A B C D E, se nostar drop(_cons age_sq *year*)
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

esttab temp using "TableA10_IFLS.tex", replace f type ///
	label booktabs b(3) p(3) eqlabels(none) collabels(none) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	///mlabels("\shortstack{Dependent variable:\\Log Wage (in KSh)}") ///mgroups("Dependent variable: Log Wage (in KSh)", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nomtitles ///
	order(`rnames') 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") 	///
	labcol2(" $\checkmark$ \qquad\qquad\qquad\qquad $\checkmark$" ///
	        " $\checkmark$ \qquad\qquad\qquad\qquad $\checkmark$" ///
					" $\checkmark$ \qquad\qquad\qquad\qquad $\checkmark$" ///
					" $\checkmark$ \qquad\qquad\qquad\qquad \phantom{$\checkmark$}" ///
					" \phantom{$\checkmark$} \qquad\qquad\qquad\qquad $\checkmark$") ///
					///title("\shortstack[l]{Productivity Measure Includes...\\Formal Wages \quad Self-Employed Profits}")) ///
	nonumbers noobs ///
  prehead("Definition of Agriculture&\shortstack[l]{Productivity Measure Includes...\\Formal Wages \quad Self-Employed Profits}&\shortstack{Dependent variable:\\Log Wage}\\") ///
	varlabel(nonag "\textbf{\shortstack[l]{Majority of hours in agriculture\\Main Estimation}}" ///
	         nonagonly "Any hours in agriculture" ///
					 nonagany "All hours in agriculture" ///
					 nonagW "Majority of hours in agriculture" ///
					 nonagS "Self-employment only")

gen has_forinc = !missing(lnforinc) & nonag==0
gen has_inforinc = !missing(lninforinc) & nonag==0

bys has_forinc pidlink: gen first_forinc = 1 if _n==1 & has_forinc==1
bys has_inforinc pidlink: gen first_inforinc = 1 if _n==1 & has_inforinc==1

count if has_forinc==1
count if first_forinc==1

count if has_inforinc==1
count if first_inforinc==1

drop has_forinc first_forinc has_inforinc first_inforinc


********************************************************************************		
*** Table A11: Gap in Earnings for those Aged 30 or Younger, Indonesia
********************************************************************************
preserve
*** Only for those aged 30 or younger
drop if age > 30

*** urban
reg lninc urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local contr "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc urban lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lninc_h urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H

*** nonag
reg lninc nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local indFE "N" , replace
estadd local contr "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local indFE "N" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lninc nonag lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG
xtreg lninc_h nonag age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local indFE "Y" , replace
estadd local contr "Y" , replace
estadd local cluster `e(N_clust)', replace
est store HH

esttab AA CC GG HH A C G H using "TableA11_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	// drop(yr1998mth1 yr1998mth2) ///	//	indicate("Time FE =i.year" "Individual FE = $test", labels(Y N)) ///
	drop(_cons lnhour lnhour_sq female age age_sq educyr educyr_sq age_sq *year*) ///	// female age age_sq educyr educyr_sq ravens_norm ravens_norm_sq
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  /// // "Movers" "Urban Movers"
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	//	stats(N, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{S}{@}") labels(`"Observations"'))
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore


********************************************************************************		
*** Table A12: Gap in Wage Earnings
********************************************************************************
preserve
*** Formal employment only
keep if !missing(lnforinc)
keep if !missing(lnforinc_h)
keep if !missing(lnforhour)

*** lnforinc_IFLS
reg lnforinc nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lnforinc nonag lnforhour lnforhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lnforinc nonag lnforhour lnforhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lnforinc_h nonag age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H
reg lnforinc urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lnforinc urban lnforhour lnforhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lnforinc urban lnforhour lnforhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG
xtreg lnforinc_h urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store HH

esttab A C G H AA CC GG HH using "TableA12_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons lnforhour lnforhour_sq female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  /// 
	mgroups("Dependent variable: Log Wage Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(nonag urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore


********************************************************************************		
*** Table A13: Gap in Self-Employment Earnings
********************************************************************************
preserve
*** Informal employment only
keep if !missing(lninforinc)
keep if !missing(lninforinc_h)
keep if !missing(lninforhour)

*** lninforinc_IFLS
reg lninforinc nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninforinc nonag lninforhour lninforhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninforinc nonag lninforhour lninforhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
xtreg lninforinc_h nonag age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store H
reg lninforinc urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lninforinc urban lninforhour lninforhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lninforinc urban lninforhour lninforhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG
xtreg lninforinc_h urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store HH
esttab A C G H AA CC GG HH using "TableA13_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons lninforhour lninforhour_sq female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  /// 
	mgroups("Dependent variable: Log Self-Employment Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(nonag urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore


********************************************************************************		
*** Table A16: Alternative Coefficient Standard Error Estimation
********************************************************************************
run "6. Cr23_ik_css_mod.do"
run "7. Edfreg_mod.do"

local bsreps = 1000

xtset, clear

*** Recode the time Fixed Effects
tab year, gen(time_)
drop time_1
global timeFE time_*

*** Residualize some variables for Frisch-Waugh to accommodate CR2 and CR3 SE
foreach var of varlist lninc lninc_h urban nonag {
  xtreg `var', fe i(pidlink)
	predict res_`var', e
}
*** Residualize all the covariates with respect to Fixed Effects
local residualized1
local residualized2
foreach var of varlist age_sq $timeFE {
  xtreg `var', fe i(pidlink)
	predict res_`var', e
	local residualized1 `residualized1' res_`var'
}

local residualized2 `residualized1'
foreach var of varlist lnhour lnhour_sq {
  xtreg `var', fe i(pidlink)
	predict res_`var', e
	local residualized2 `residualized2' res_`var'
}
*** Standard errors for urban
reg lninc urban, cluster(pidlink)
est store A
estadd local contr "N" , replace: A
estadd local indFE "N" , replace: A
estadd local cluster `e(N_clust)', replace: A

*** Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: A
*** CR2 and 3 Degrees of Freedom corrections
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(lninc) rhs(urban) key_rhs(urban) cluster(pidlink)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: A

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: A
drop resid

reg lninc urban, vce(bootstrap, cluster(pidlink) reps(`bsreps'))

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)

estadd matrix stderr_bootstrap: A

edfreg lninc urban, cluster(pidlink) select(urban)

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: A

reg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
est store C
estadd local contr "Y" , replace: C
estadd local indFE "N" , replace: C
estadd local cluster `e(N_clust)', replace: C
*** Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: C
*** CR2 and 3 Degrees of Freedom corrections
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(lninc) rhs(urban lnhour lnhour_sq female age age_sq educyr educyr_sq $timeFE) key_rhs(urban) cluster(pidlink)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: C

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: C
drop resid

areg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq, vce(bootstrap, cluster(pidlink) reps(`bsreps')) a(year)

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)

estadd matrix stderr_bootstrap: C

edfreg lninc urban lnhour lnhour_sq female age age_sq educyr educyr_sq $timeFE, cluster(pidlink) select(urban)

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: C


xtreg lninc urban lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
est store F
estadd local contr "Y" , replace: F
estadd local indFE "Y" , replace: F
estadd local cluster `e(N_clust)', replace: F
*** Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: F
*** CR2 and 3 Degrees of Freedom corrections
reg res_lninc res_urban `residualized2', cluster(pidlink) noconstant
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS, betavec(betavec) lhs(res_lninc) rhs("res_urban `residualized2'") key_rhs(res_urban) cluster(pidlink) noconstant(1)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: F

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: F
drop resid

mata: findexternal("cr2cr3()")
bootstrap _b[urban], reps(`bsreps') cluster(pidlink): reghdfe lninc urban lnhour lnhour_sq age_sq, a(pidlink year)
mata: findexternal("cr2cr3()")

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)
matrix colnames stderr_bootstrap = urban
matrix rownames stderr_bootstrap = urban

estadd matrix stderr_bootstrap: F

mata: findexternal("cr2cr3()")
mata: mata set matastrict off
*
run "6. Cr23_ik_css_mod.do"
*
edfreg lninc urban lnhour lnhour_sq age_sq $timeFE, cluster(pidlink) absorb(pidlink) select(urban)

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: F

xtreg lninc_h urban age_sq i.year, fe i(pidlink) cluster(pidlink)			
est store G
estadd local contr "Y" , replace: G
estadd local indFE "Y" , replace: G
estadd local cluster `e(N_clust)', replace: G
*** Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: G
*** CR2 and 3 Degrees of Freedom corrections
reg res_lninc_h res_urban `residualized1', cluster(pidlink) noconstant
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(res_lninc_h) rhs("res_urban `residualized1'") key_rhs(res_urban) cluster(pidlink) noconstant(1)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: G

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: G

drop resid

bootstrap _b[urban], cluster(pidlink) reps(`bsreps'): reghdfe lninc_h urban age_sq, a(pidlink year)

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)
matrix colnames stderr_bootstrap = urban
matrix rownames stderr_bootstrap = urban

estadd matrix stderr_bootstrap: G

edfreg lninc_h urban age_sq $timeFE, cluster(pidlink) absorb(pidlink) select(urban)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)
estadd matrix stderr_young: G
*** Standard errors for nonag
reg lninc nonag, cluster(pidlink)
est store AA
estadd local contr "N" , replace: AA
estadd local indFE "N" , replace: AA
estadd local cluster `e(N_clust)', replace: AA
*** Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: AA
*** CR2 and 3 Degrees of Freedom corrections
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(lninc) rhs(nonag) key_rhs(nonag) cluster(pidlink)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: AA

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: AA

drop resid


reg lninc nonag, vce(bootstrap, cluster(pidlink) reps(`bsreps'))
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)

estadd matrix stderr_bootstrap: AA

edfreg lninc nonag, cluster(pidlink) select(nonag)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: AA

reg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq i.year, cluster(pidlink)
est store CC
estadd local contr "Y" , replace: CC
estadd local indFE "N" , replace: CC
estadd local cluster `e(N_clust)', replace: CC

*** Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: CC
*** CR2 and 3 Degrees of Freedom corrections
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(lninc) rhs(nonag lnhour lnhour_sq female age age_sq educyr educyr_sq $timeFE) key_rhs(nonag) cluster(pidlink)


matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: CC

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: CC
drop resid

areg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq, vce(bootstrap, cluster(pidlink) reps(`bsreps')) a(year)
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)

estadd matrix stderr_bootstrap: CC

edfreg lninc nonag lnhour lnhour_sq female age age_sq educyr educyr_sq $timeFE, cluster(pidlink) select(nonag)

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: CC

xtreg lninc nonag lnhour lnhour_sq age_sq i.year, fe i(pidlink) cluster(pidlink)			
est store FF
estadd local contr "Y" , replace: FF
estadd local indFE "Y" , replace: FF
estadd local cluster `e(N_clust)', replace: FF
*** Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: FF
*** CR2 and 3 Degrees of Freedom corrections
reg res_lninc res_nonag `residualized2', cluster(pidlink) noconstant
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(res_lninc) rhs("res_nonag `residualized2'") key_rhs(res_nonag) cluster(pidlink) noconstant(1)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: FF

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: FF

drop resid

mata: findexternal("cr2cr3()")
bootstrap _b[nonag], cluster(pidlink) reps(`bsreps'): reghdfe lninc nonag lnhour lnhour_sq age_sq, a(pidlink year)
mata: findexternal("cr2cr3()")
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)
matrix colnames stderr_bootstrap = nonag
matrix rownames stderr_bootstrap = nonag

estadd matrix stderr_bootstrap: FF

edfreg lninc nonag lnhour lnhour_sq age_sq $timeFE, cluster(pidlink) absorb(pidlink) select(nonag)

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: FF


xtreg lninc_h nonag age_sq i.year, fe i(pidlink) cluster(pidlink)			
est store GG
estadd local contr "Y" , replace: GG
estadd local indFE "Y" , replace: GG
estadd local cluster `e(N_clust)', replace: GG
*** Regular clustering
matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_default = vecdiag(temp)

estadd matrix stderr_default: GG
*** CR2 and 3 Degrees of Freedom corrections
reg res_lninc_h res_nonag `residualized1', cluster(pidlink) noconstant
predict resid, resid
matrix betavec = e(b)

CR23_IK_CSS , betavec(betavec) lhs(res_lninc_h) rhs("res_nonag `residualized1'") key_rhs(res_nonag) cluster(pidlink) noconstant(1)

matrix stderr_cr2 = stderr_default
matrix stderr_cr2[1, 1] = r(se_CR2)
estadd matrix stderr_cr2: GG

matrix stderr_cr3 = stderr_default
matrix stderr_cr3[1, 1] = r(se_CR3)
estadd matrix stderr_cr3: GG
drop resid

bootstrap _b[nonag], cluster(pidlink) reps(`bsreps'): reghdfe lninc_h nonag age_sq, a(pidlink year)

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_bootstrap = vecdiag(temp)
matrix colnames stderr_bootstrap = nonag
matrix rownames stderr_bootstrap = nonag

estadd matrix stderr_bootstrap: GG

edfreg lninc_h nonag age_sq $timeFE, cluster(pidlink) absorb(pidlink) select(nonag)

matrix diagonal = diag(vecdiag(e(V)))
matmap diagonal temp, map(sqrt(@))
matrix stderr_young = vecdiag(temp)

estadd matrix stderr_young: GG

esttab AA CC FF GG A C F G using "TableA16_IFLS.tex", replace type f ///
  cells(b(fmt(3)star) stderr_default(par(( ))) stderr_cr2(par([ ])) stderr_cr3(par(`"\$\\llbracket\$"' `"\$\\rrbracket\$"')) stderr_bootstrap(par(\{ \})) stderr_young(par(`"\$\\langle\$"' `"\$\\rangle\$"'))) ///
	keep(urban nonag) ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitle("" "" "" "Log Wage" "" "" "" "Log Wage")  /// 
	mgroups("Dependent variable: Log Earnings", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

	
********************************************************************************		
*** Table A17: Integenerational Correlations of Cognitive Measures
********************************************************************************
use "Intergen_Analysis_IFLS.dta", clear								
xtset pidlink year
tostring fath_pidlink moth_pidlink, replace										

tempfile dadfile momfile

keep pidlink year female age ravens_norm ravens_norm_sq educyr urban_birth

egen max_educ = max(educyr), by(pidlink)
drop educyr

reshape wide age, i(pidlink) j(year)

preserve
rename pidlink fath_pidlink
foreach var of varlist age1988-max_educ {
  rename `var' fath_`var'
}
tostring fath_pidlink , replace
save `dadfile', replace
restore

rename pidlink moth_pidlink
foreach var of varlist age1988-max_educ {
  rename `var' moth_`var'
}
tostring moth_pidlink , replace
save `momfile', replace

use "Intergen_Analysis_IFLS.dta", clear
keep pidlink year age female ravens_norm ravens_norm_sq educyr urban_birth moth_pidlink fath_pidlink

egen max_educ = max(educyr), by(pidlink)
drop educyr

tostring fath_pidlink moth_pidlink, replace

tempfile fathlink mothlink

foreach parent in fath moth {
	replace `parent'_pidlink = "" if `parent'_pidlink == "."
	preserve
	keep pidlink `parent'_pidlink
	drop if missing(`parent'_pidlink)
	duplicates drop
	destring `parent'_pidlink, replace	
	egen check = count(`parent'_pidlink), by(pidlink)
	tostring `parent'_pidlink, replace				
	count if check > 1
	assert r(N) == 0
	save ``parent'link'
	restore	
}

drop fath_pidlink moth_pidlink
merge m:1 pidlink using `fathlink', assert(1 3)
drop _merge
merge m:1 pidlink using `mothlink', assert(1 3)
drop _merge

reshape wide age, i(pidlink) j(year)

merge m:1 fath_pidlink using `dadfile'
drop if _merge==2
gen has_fath = _merge==3
drop _merge

merge m:1 moth_pidlink using `momfile'
drop if _merge==2
gen has_moth = _merge==3
drop _merge

*** Generate mom and dad age at birth
forvalues i = 1988/2015 {
  gen fath_temp`i' = fath_age`i' - age`i'
	gen moth_temp`i' = moth_age`i' - age`i'

	drop fath_age`i' moth_age`i' age`i'
}

egen fath_ageatbirth = rowmean(fath_temp*)
egen moth_ageatbirth = rowmean(moth_temp*)

egen has_parent = rowmax(has_fath has_moth)

drop fath_temp* moth_temp*

estimates clear

label define bornurban 0 "Born Rural" 1 "Born Urban"
label values urban_birth bornurban

gen fath_max_educ_sq = fath_max_educ^2
gen moth_max_educ_sq = moth_max_educ^2

gen fath_ageatbirth_sq = fath_ageatbirth^2
gen moth_ageatbirth_sq = moth_ageatbirth^2

*** Generate parent variables to create the same table without father/mother distinction
egen parent_urban_birth = rowmean(fath_urban_birth moth_urban_birth)

egen parent_max_educ = rowmean(fath_max_educ moth_max_educ)
gen parent_max_educ_sq = parent_max_educ^2

egen parent_ageatbirth = rowmean(fath_ageatbirth moth_ageatbirth)
gen parent_ageatbirth_sq = parent_ageatbirth^2

egen parent_ravens_norm = rowmean(fath_ravens_norm moth_ravens_norm)
gen parent_ravens_norm_sq = parent_ravens_norm^2

*** Tables
local control2 female
local control3 female parent_urban_birth parent_ageatbirth
local control4 `control3' parent_max_educ parent_ravens_norm
local control5 `control4' parent_ageatbirth_sq ///
                          parent_max_educ_sq ///
													parent_ravens_norm_sq

egen hasmiss = rowmiss(`control5')
drop if hasmiss >0
drop hasmiss

eststo raven_regb1: reg ravens_norm urban_birth if has_parent==1, robust
estadd local square "N"
eststo raven_regb2: reg ravens_norm urban_birth `control2' if has_parent==1, robust
estadd local square "N"
eststo raven_regb3: reg ravens_norm urban_birth `control3' if has_parent==1, robust
estadd local square "N"
eststo raven_regb4: reg ravens_norm urban_birth `control4' if has_parent==1, robust
estadd local square "N"
eststo raven_regb5: reg ravens_norm urban_birth `control5' if has_parent==1, robust
estadd local square "Y"

esttab raven_regb* using "TableA17_IFLS.tex", ///
	booktabs type replace fragment ///
  b(%5.3f) se(%5.3f) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mgroup("Dependent variable: Normalized Ravens", ///
	  pattern(1 0 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabels(none) label interaction("$\times$") ///
	drop(_cons *_sq) ///
	order(urban_birth ///
	      female ///
	      parent_urban_birth parent_ageatbirth parent_max_educ parent_ravens_norm) ///
	varlabels( ///
	  urban_birth "Born Urban" ///
		female Female ///
		parent_urban_birth "Born Urban" ///
		parent_ageatbirth "Age at Birth" ///
		parent_max_educ "Years of Education" ///
		parent_ravens_norm "Normalized Ravens") ///
	refcat(urban_birth "\textbf{Child Covariates:}" ///
	       parent_urban_birth "\textbf{Parent (Averaged) Covariates:}", nolabel) ///
	stats(square N, ///
		labels("Age, Education, and Ravens Squared" ///
		       "Number of observations") ///
		fmt(%9.0g) ///
		layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}")) ///
	nonotes

	
********************************************************************************		
*** Table A19: Gaps in Consumption
********************************************************************************
*** Regression total consumption - full sample
use "Consumption_Analysis_IFLS.dta", clear
preserve
xtset pidlink year

keep if !missing(lncons_tot)
keep if !missing(lncons_food)
keep if !missing(lncons_nfood)

sort pidlink year
xtset pidlink year
*
reg lncons_tot nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lncons_tot nonag female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lncons_tot nonag age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
reg lncons_tot urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lncons_tot urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lncons_tot urban age_sq i.year, fe i(pidlink) cluster(pidlink)	
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG

esttab A C G AA CC GG using "TableA19_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none)	///	
	drop(_cons female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) /// 
	nomtitles /// 
	mgroups("Dependent variable: Log Consumption", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(nonag urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

	
********************************************************************************		
*** Table A20: Gap in Food and Non-Food Consumption, Indonesia
********************************************************************************
*** Regression food consumption - full sample
reg lncons_food nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lncons_food nonag female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lncons_food nonag age_sq i.year, fe i(pidlink) cluster(pidlink)	
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
reg lncons_food urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lncons_food urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lncons_food urban age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG

esttab A C G AA CC GG using "TableA20_IFLS_food.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none)	///	
	drop(_cons female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) /// 
	nomtitles /// 
	mgroups("Dependent variable: Log Food Consumption", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(nonag urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

reg lncons_nfood nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lncons_nfood nonag female age age_sq educyr educyr_sq i.year, cluster(pidlink)					
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lncons_nfood nonag age_sq i.year, fe i(pidlink) cluster(pidlink)	
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
reg lncons_nfood urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lncons_nfood urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lncons_nfood urban age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG

esttab A C G AA CC GG using "TableA20_IFLS_nfood.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none)	///	// indicate("Time FE =i.year" "Individual FE = $test", labels(Y N)) ///
	drop(_cons female age age_sq educyr educyr_sq age_sq *year*) ///	// female age age_sq educyr educyr_sq ravens_norm ravens_norm_sq
	star(* 0.10 ** 0.05 *** 0.01) /// //	collabels("\multicolumn{3}{c}{test}" "\multicolumn{3}{c}{test2}") ///
	nomtitles /// // mtitle("" "" "" "" "" "")  /// //
	mgroups("Dependent variable: Log Non-Food Consumption", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(nonag urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	//	stats(N, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{S}{@}") labels(`"Observations"'))
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore	


********************************************************************************		
*** Table A21: Gap in Consumption (Main Analysis Sample), Indonesia
********************************************************************************
*** Regression total consumption
use "Main_Analysis_IFLS.dta", clear														

keep if !missing(lncons_tot)
keep if !missing(lncons_food)
keep if !missing(lncons_nfood)
*
reg lncons_tot nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lncons_tot nonag female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lncons_tot nonag age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
reg lncons_tot urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lncons_tot urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lncons_tot urban age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG

esttab A C G AA CC GG using "TableA21_IFLS_tot.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none)	///	
	drop(_cons female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) /// 
	nomtitles /// 
	mgroups("Dependent variable: Log Consumption", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(nonag urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

*** Regression food consumption
reg lncons_food nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lncons_food nonag female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lncons_food nonag age_sq i.year, fe i(pidlink) cluster(pidlink)	
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
reg lncons_food urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lncons_food urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lncons_food urban age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG

esttab A C G AA CC GG using "TableA21_IFLS_food.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none)	///	
	drop(_cons female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) /// 
	nomtitles /// 
	mgroups("Dependent variable: Log Food Consumption", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(nonag urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

*** Regression non-food consumption
reg lncons_nfood nonag, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lncons_nfood nonag female age age_sq educyr educyr_sq i.year, cluster(pidlink)					
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lncons_nfood nonag age_sq i.year, fe i(pidlink) cluster(pidlink)	
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G
reg lncons_nfood urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA
reg lncons_nfood urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC
xtreg lncons_nfood urban age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG

esttab A C G AA CC GG using "TableA21_IFLS_nfood.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none)	///	
	drop(_cons female age age_sq educyr educyr_sq age_sq *year*) ///	// female age age_sq educyr educyr_sq ravens_norm ravens_norm_sq
	star(* 0.10 ** 0.05 *** 0.01) /// 
	nomtitles /// 
	mgroups("Dependent variable: Log Non-Food Consumption", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(nonag urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

	
********************************************************************************		
*** Table A22: Gap in Consumption for those Born in Rural and Urban Areas, Indonesia
********************************************************************************
use "Main_Analysis_IFLS.dta", clear														

*** Regression total consumption - Full sample but only those born in rural area
preserve
keep if urban_birth == 0

reg lncons_tot urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA_rural_IFLS
reg lncons_tot urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC_rural_IFLS
xtreg lncons_tot urban age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG_rural_IFLS

restore

*** Regression total consumption - Full sample but only those born in urban area
preserve
keep if urban_birth == 1

reg lncons_tot urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA_urban_IFLS
reg lncons_tot urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC_urban_IFLS
xtreg lncons_tot urban age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG_urban_IFLS

restore
** Consumption
use "Consumption_Analysis_IFLS.dta", clear

xtset pidlink year

keep if !missing(lncons_tot)
keep if !missing(lncons_food)
keep if !missing(lncons_nfood)

sort pidlink year
xtset pidlink year

preserve
keep if urban_birth == 0

reg lncons_tot urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA_rural_IFLSall
reg lncons_tot urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC_rural_IFLSall
xtreg lncons_tot urban age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG_rural_IFLSall

restore

preserve
keep if urban_birth == 1

reg lncons_tot urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store AA_urban_IFLSall
reg lncons_tot urban female age age_sq educyr educyr_sq i.year, cluster(pidlink)						
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store CC_urban_IFLSall
xtreg lncons_tot urban age_sq i.year, fe i(pidlink) cluster(pidlink)		
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store GG_urban_IFLSall

restore
*
esttab AA_rural_IFLSall CC_rural_IFLSall GG_rural_IFLSall AA_rural_IFLS CC_rural_IFLS GG_rural_IFLS using "TableA22_IFLS_rural.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none)	///	// indicate("Time FE =i.year" "Individual FE = $test", labels(Y N)) ///
	drop(_cons female age age_sq educyr educyr_sq age_sq *year*) ///	// $controls_all
	star(* 0.10 ** 0.05 *** 0.01) /// //	collabels("\multicolumn{3}{c}{test}" "\multicolumn{3}{c}{test2}") ///
	nomtitles /// // mtitle("" "" "" "" "" "")  /// //
	mgroups("Full Consumption Sample" "Main Analysis Sample", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	//	stats(N, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{S}{@}") labels(`"Observations"'))
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

esttab AA_urban_IFLSall CC_urban_IFLSall GG_urban_IFLSall AA_urban_IFLS CC_urban_IFLS GG_urban_IFLS using "TableA22_IFLS_urban.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none)	///	// indicate("Time FE =i.year" "Individual FE = $test", labels(Y N)) ///
	drop(_cons female age age_sq educyr educyr_sq age_sq *year*) ///	// $controls_all
	star(* 0.10 ** 0.05 *** 0.01) /// //	collabels("\multicolumn{3}{c}{test}" "\multicolumn{3}{c}{test2}") ///
	nomtitles /// // mtitle("" "" "" "" "" "")  /// //
	mgroups("Full Consumption Sample" "Main Analysis Sample", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(urban) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	//	stats(N, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{S}{@}") labels(`"Observations"'))
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

	
********************************************************************************		
*** Table A23: Urban/Rural Gap in Wages for Top 5 Cities
********************************************************************************
use "Main_Analysis_IFLS.dta", clear												
*** Cities in top 5
preserve
keep if !missing(jakarta)
keep if !missing(surabaya)
keep if !missing(bandung)
keep if !missing(medan)
keep if !missing(bekasi)

reg lninc_h urban, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A0
reg lninc_h urban jakarta surabaya bandung medan bekasi, cluster(pidlink)
estadd local timeFE "N" , replace
estadd local contr "N" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store A
reg lninc_h urban jakarta surabaya bandung medan bekasi female age age_sq educyr educyr_sq i.year, cluster(pidlink)
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "N" , replace
estadd local cluster `e(N_clust)', replace
est store C
xtreg lninc_h urban jakarta surabaya bandung medan bekasi age_sq i.year, fe i(pidlink) cluster(pidlink)			
estadd local timeFE "Y" , replace
estadd local contr "Y" , replace
estadd local indFE "Y" , replace
estadd local cluster `e(N_clust)', replace
est store G

esttab A0 A C G using "TableA23_IFLS.tex", replace f ///
	label booktabs b(3) p(3) eqlabels(none) alignment(S S) collabels(none) ///	
	drop(_cons female age age_sq educyr educyr_sq age_sq *year*) ///	
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles	/// 
	mgroups("Dependent variable: Log Wages", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(urban jakarta surabaya bandung medan bekasi) 			///
	cells("b(fmt(3)star)" "se(fmt(3)par)") ///	
	stats(indFE contr N cluster, fmt(0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Individual fixed effects"' `"Control variables and time FE"' `"Number of observations"' `"Number of individuals"'))

restore


exit
