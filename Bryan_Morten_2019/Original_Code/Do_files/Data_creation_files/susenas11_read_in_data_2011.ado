* Version 1: February 11, 2014 (Allan Hsiao)

program susenas11_read_in_data_2011

	set more off
	clear

	insheet using "$rawdata/SUSENAS/Susenas 2011 Kor/kor11ind.csv"
	keep kabu b1r5 series hb jk umur b5_tl1 b5_tl2 ///
		 b5_tt1 b5_tt2 b5r15 b5r16 b5r17 b5r29 b5r30 fwt exp_cap ///
		 b5r24a1 b5r24a2 b5r24a3 b5r24a4 ///
		 b5r19a b5r19b b5r19c b5r28b b5r31
		 // b1r1 b1r2 b1r7 b1r8
	
	label variable kabu "Regency Code"
	label variable b1r5 "Rural/urban"
	label variable series "Household code"
	label variable hb "Relationship to head of hh"
	label variable jk "Sex"
	label variable umur "Age"
	label variable b5_tl1 "Place of birth (province)"
	label variable b5_tl2 "Place of birth (regency)"
	label variable b5_tt1 "Place of residance five years ago (province)"
	label variable b5_tt2 "Place of residance five years ago (regency)"
	label variable b5r15 "Highest education type and level currently studied/passed "
	label variable b5r16 "Highest class/level studied/currently studied"
	label variable b5r17 "Highest diploma obtained"
	label variable b5r24a1 "Past week activity: Work"
	label variable b5r24a2 "Past week activity: School"
	label variable b5r24a3 "Past week activity: Care of household"
	label variable b5r24a4 "Past week activity: Other"
	label variable b5r29 "Average monthly wage (money and goods) from main job"
	label variable b5r30 "Main field of work"
	label variable fwt "Sample weighting"
	label variable exp_cap "Monthly spending per capita"
	
	label variable b5r19a "Can read Latin letters"
	label variable b5r19b "Can read Arabic letters"
	label variable b5r19c "Can read other letters"
	label variable b5r28b "Hours worked last week (all jobs)"
	label variable b5r31 "Employment status"
	
	gen year = 2011
	
	save "$secdata/Compiled/susenas_2011", replace
	
end



