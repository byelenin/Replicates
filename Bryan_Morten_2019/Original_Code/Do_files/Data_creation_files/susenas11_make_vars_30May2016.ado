* Version 1: May 17, 2014 (Allan Hsiao)
* V2 (5/30/2016, MM): Taking out the distance merge and putting in in clean_transform file instead

program susenas11_make_vars_30May2016
	

	// Use full SUSENAS 2011/2012 dataset
	use "$secdata/Compiled/susenas_2011_2012_premade", clear
	
	//Generate relevant variables 
	*replace b5_tl2 = . if b5_tl2 == 0
	*gen birth_rgcy = 100 * b5_tl1 + b5_tl2
	drop b5_tl1 b5_tl2
	
	*replace b5_tt1 = . if b5_tt1 == 0
	*replace b5_tt2 = . if b5_tt2 == 0
	*gen five_yrs_rgcy = 100 * b5_tt1 + b5_tt2
	drop b5_tt1 b5_tt2
	
	gen employed = 1 if b5r24a1 == 1
	replace employed = 0 if b5r24a1 == 2
	drop b5r24a1 b5r24a2 b5r24a3 b5r24a4 
	
	// Generate Rural and Female dummies
	gen female = jk - 1
	gen rural = b1r5 - 1
	drop b1r5 jk
	
	// Rename relevant variables
	*rename kabu current_rgcy
	rename series hh_id
	rename hb hoh_relation
	*rename umur age
	rename b5r17 educ_attain
	drop b5r15 b5r16
	rename b5r29 wage_month
	rename b5r30 industry
	rename fwt sample_wt
	rename exp_cap exp_pc_month
	
	rename b5r19a literacy_latin
	rename b5r19b literacy_arabic
	rename b5r19c literacy_other
	rename b5r28b hours_week
	rename b5r31 empl_status
	
	// Generate literacy variable (literacy==1 if can read latin)
	gen literacy = 1 if literacy_latin==1
	replace literacy = 0 if literacy_latin==2
	drop literacy_latin literacy_arabic literacy_other
	
	// Create self-employer and employee indicators
	// Self-employed if "self-employed," "self-employed assisted by permanent workers"
	gen self_employed = 1 if inlist(empl_status, 1, 2, 3)
	replace self_employed = 0 if inlist(empl_status, 4, 5, 6)
	gen employee = 1 if inlist(empl_status, 4)
	replace employee = 0 if inlist(empl_status, 1, 2, 3, 5, 6)
	*drop empl_status
	
	// Generate wage per hour
	replace wage_month = . if wage_month >= 9000000 //MM, 9/19/2014: replace invalid numbers//
	gen wage_hour = wage_month / (4 * hours_week)
	
	// Recode education to years of schooling
	gen years_school = 0 if educ_attain == 1
	replace years_school = 6 if educ_attain == 2
	replace years_school = 6 if educ_attain == 3
	replace years_school = 6 if educ_attain == 4
	replace years_school = 9 if educ_attain == 5
	replace years_school = 9 if educ_attain == 6
	replace years_school = 9 if educ_attain == 7
	replace years_school = 12 if educ_attain == 8
	replace years_school = 12 if educ_attain == 9
	replace years_school = 12 if educ_attain == 10
	replace years_school = 12 if educ_attain == 11
	replace years_school = 14 if educ_attain == 12
	replace years_school = 15 if educ_attain == 13
	replace years_school = 16 if educ_attain == 14
	replace years_school = 18 if educ_attain == 15
	//drop educ_attain
	
	save "$secdata/Compiled/susenas_2011_2012_made", replace
	
end


