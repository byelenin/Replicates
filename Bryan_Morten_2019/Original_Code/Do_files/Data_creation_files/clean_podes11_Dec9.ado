program clean_podes11_Dec9

	use "$secdata/PODES/podes_2011_raw.dta", clear
	drop if inlist(kode_prov, 91, 94) // Drop Papua and West Papua
	
	keep kode_prov kode_kab kode_kec kode_desa ///
		 r301 r401a r401b r401c r401d r402a r402b r403a r403b r502a ///
		 r510a r510b1 r510b2 r510b3 r511ak2 r511bk2 r511ck2 ///
		 r60101k2 r60102k2 r60103k2 r60104k2 r60105k2 r60106k2 r60107k2 r60108k2 r60109k2 r60110k2 ///
		 r60101k3 r60102k3 r60103k3 r60104k3 r60105k3 r60106k3 r60107k3 r60108k3 r60109k3 r60110k3 ///
		 r701ak2 r701ak3  r701bk2 r701bk3 r701ck2 r701ck3 r701dk2 r701dk3 r701ek2 r701ek3 r701fk2 r701fk3 ///
		 r704ak3 r704bk3 r704ck3 r704dk3 r704ek3 r704fk3 r704gk3 r704hk3 r704ik3 r704jk3 r704kk3 r704lk2 ///
		 r707a1 r707a2 r708ak2 r708bk2 r708ck2 r708dk2 r708ek2 r708fk2 r708gk2 r708hk2 ///
		 r803a r803b r803c r803d r803e r803f r803g r803h ///
		 r901a r1010a r1203a r1205a r1208 r1209 r1210 r1211 r1215ak2 r1215ak3 r1215bk2 r1215bk3 ///
		 r1309ak2 r1309bk2 r704ak5 r704dk5 r1309bk4
	
	label var kode_prov "Province code"
	label var kode_kab "Regency code"
	label var kode_kec "District code"
	label var kode_desa "Village code"
	rename kode_prov prop
	rename kode_kab kab
	rename kode_kec kec
	rename kode_desa desa
	
	// Rural status missing
	
	rename r301 upt
	recode upt (1=0) (2=0) (3=1) (4=0)
	label var upt "Transmigration village"

	gen podes_population = r401a + r401b
	drop r401a
	label var podes_population "Population"
	label var r401b "Female population" 
	rename r401b podes_population_fem
	label var r401c "Number of households"
	rename r401c podes_no_hh
	label var r401d "Number of agricultural households"
	rename r401d podes_no_ag_hh
	// Also have number of farm laborer households
	
	label var r402a "Number of villagers working as migrant workers overseas (male)"
	rename r402a podes_pop_overseas_m
	label var r402b "Number of villagers working as migrant workers overseas (female)"
	rename r402b podes_pop_overseas_f
	
	label var r403a "Source income of majority population"
	label define lab_r403a 1 "Agriculture" 2 "Mining & quarrying" 3 "Industry" ///
						   4 "Big trade/retail" 5 "Trasnport" 6 "Services" ///
						   7 "Other"
	label values r403a lab_r403a
	rename r403a source_income

	label var r403b "If source_income coded 1, main sub-sector"
	label define lab_r403b 1 "Rice paddies" 2 "Crops" 3 "Horticulture (fruits/veg)" ///
							4 "Plantation" 5 "Livestock" 6 "Fisheries" ///
							7 "Aquaculture" 8 "Forestry" 9 "Agricultual services"
	label values r403b lab_r403b
	rename r403b source_ag_income
	
	label var r502a "Main road village lighting" 
	recode r502a (2=0)
	rename r502a main_road_lighting
	
	label var r510a "Any poor settlements in village?"
	recode r510a (2=0)
	rename r510a dum_slums
	label var r510b1 "Slums: Number of locations" 
	replace r510b1 = 0 if dum_slums == 0
	rename r510b1 no_slums
	label var r510b2 "Slums: Number of housing units"
	replace r510b2 = 0 if dum_slums == 0
	rename r510b2 no_slums_housing_units
	label var r510b3 "Slums: Number of households"
	replace r510b3 = 0 if dum_slums == 0
	rename r510b3 podes_slums_no_hh
	
	label var r511ak2 "Water pollution (past year)"
	recode r511ak2 (2 = 0)
	rename r511ak2 dum_water_pollution
	label var r511bk2 "Land pollution (past year)"
	recode r511bk2 (2 = 0)
	rename r511bk2 dum_land_pollution
	label var r511ck2 "Air pollution (past year)"
	recode r511ck2 (2 = 0)
	rename r511ck2 dum_air_pollution
	
	egen no_natural_disasters = rowtotal(r60101k3 r60102k3 r60103k3 r60104k3 r60105k3 r60106k3 r60107k3 r60108k3 r60109k3 r60110k3)
	drop r60101k3 r60102k3 r60103k3 r60104k3 r60105k3 r60106k3 r60107k3 r60108k3 r60109k3 r60110k3
	label var no_natural_disasters "Number of natural disasters in last 3 years" 
	
	label var r60101k2 "Landslide" 
	recode r60101k2 (2=0)
	rename r60101k2 dum_landslide
	label var r60102k2 "Flooding" 
	recode r60102k2 (2=0) (9=.)
	rename r60102k2 dum_flooding
	label var r60103k2 "Flash flood"
	recode r60103k2 (2=0)
	rename r60103k2 dum_flashflood
	label var r60104k2 "Earthquake" 
	recode r60104k2 (2=0) (9=.)
	rename r60104k2 dum_earthquake
	
	recode r60105k2 (2=0)
	recode r60106k2 (2=0)
	gen dum_tidalwave = r60105k2 + r60106k2
	drop r60105k2 r60106k2
	label var dum_tidalwave "Tidal wave/tsunami"
	recode dum_tidalwave (2=1)
	
	label var r60107k2 "Whirlwind/tornado/hurricane"
	recode r60107k2 (2=0)
	rename r60107k2 dum_hurricane
	label var r60108k2 "Volcanic eruption"
	recode r60108k2 (2=0)
	rename r60108k2 dum_volcano
	label var r60109k2 "Forest fire"
	recode r60109k2 (2=0)
	rename r60109k2 dum_fire
	label var r60110k2 "Drought"
	recode r60110k2 (2=0)
	rename r60110k2 dum_drought
	// Also have number of events, casualities, losses (millions of USD), aid, and types of aid
	// Errorts made to anticipate natural disasters, sources of help to anticipate
	
	label var r701ak2 "Number of schools: Kindergarten, govt"
	rename r701ak2 no_kindergarten_gov
	label var r701ak3 "Number of schools: Kindergarten, priv"
	rename r701ak3 no_kindergarten_priv
	label var r701bk2 "Number of schools: Primary school, govt"
	rename r701bk2 no_primary_gov
	label var r701bk3 "Number of schools: Primary school, priv"
	rename r701bk3 no_primary_priv
	label var r701ck2 "Number of schools: Junior high school, govt"
	rename r701ck2 no_juniorhigh_gov
	label var r701ck3 "Number of schools: Junior high school, priv"
	rename r701ck3 no_juniorhigh_priv
	
	gen no_highschool_gov = r701dk2 + r701ek2 
	label var no_highschool_gov "Number of schools: High school, govt"
	gen no_highschool_priv = r701dk3 + r701ek3
	label var no_highschool_gov "Number of schools: High school, priv"
	drop r701dk2 r701dk3 r701ek2 r701ek3
	
	label var r701fk2 "Number of schools: University/academy, govt"
	rename r701fk2 no_university_gov
	label var r701fk3 "Number of schools: University/academy, priv"
	rename r701fk3 no_university_priv
	// Also have distance to closest
	
	foreach var in r704ak3 r704bk3 r704ck3 r704dk3 r704ek3 r704fk3 r704gk3 r704hk3 r704ik3 r704jk3 r704kk3 {
		recode `var' (.=0)
	}
	label var r704ak3 "Number of hospitals"
	rename r704ak3 no_hosp
	label var r704bk3 "Number of maternity hospitals/houses"
	rename r704bk3 no_maternity_hosp
	label var r704ck3 "Number of polyclinics"
	rename r704ck3 no_polyclinic
	label var r704dk3 "Number of integrated health centers (puskesmas)"
	rename r704dk3 no_integrated_health
	label var r704ek3 "Number of supported puskesmas"
	rename r704ek3 no_supported_integrated_health
	label var r704fk3 "Number of doctors' practices"
	rename r704fk3 no_doctor_clinic
	label var r704gk3 "Number of midwives' practices"
	rename r704gk3 no_midwife_clinic
	label var r704hk3 "Number of village medicine posts (POD)" 	
	rename r704hk3 no_village_medicine
	label var r704ik3 "Number of village maternity posts (polindes)" 
	rename r704ik3 no_village_maternity
	label var r704jk3 "Number of neighborhood health centers (posyandu)"
	rename r704jk3 no_nbhd_health
	label var r704kk3 "Number of pharmacies"
	rename r704kk3 no_pharmacies
	label var r704lk2 "Number of drug stores" // Don't have number -- only dummy
	recode r704lk2 (2=0)
	rename r704lk2 no_drugstore
	// Also have distance and easy of reaching each
	
	gen no_doctors = r707a1 + r707a2
	drop r707a1 r707a2
	label var no_doctors "Number of doctors"
	
	foreach var in r708ak2 r708bk2 r708ck2 r708dk2 r708ek2 r708fk2 r708gk2 r708hk2 {
		recode `var' (2=0)
	}
	label var r708ak2 "Outbreak (last year): Vomiting/diarrhea"
	rename r708ak2 outbreak_vomiting_diarrhea
	label var r708bk2 "Outbreak (last year): Scarlet fever"
	rename r708bk2 outbreak_scarletfever
	label var r708ck2 "Outbreak (last year): Measles"
	rename r708ck2 outbreak_measles
	label var r708dk2 "Outbreak (last year): Acute respiratory infection"
	rename r708dk2 outbreak_respiratory
	label var r708ek2 "Outbreak (last year): Malaria"
	rename r708ek2 outbreak_malaria
	label var r708fk2 "Outbreak (last year): Bird flu (1 case is considered an outbreak)"
	rename r708fk2 outbreak_birdflu
	label var r708gk2 "Outbreak (last year): Tuberculosis"
	rename r708gk2 outbreak_tuberculosis
	label var r708hk2 "Outbreak (last year): Other"
	rename r708hk2 outbreak_other
	
	label var r803a "Number of mosques"
	rename r803a no_mosques
	label var r803b "Number of prayer houses (small mosques)"
	rename r803b no_prayerhouse
	label var r803f "Number of puras (Hindu)"
	rename r803f no_hindu_pura
	label var r803g "Number of viharas (Buddhist)"
	rename r803g no_buddhist_vihara
	label var r803h "Number of klentengs (Daoist)"
	rename r803h no_daoist_klenteng

	gen no_church = r803c + r803d + r803e
	drop r803c r803d r803e
	label var no_church "Number of churches/chapels"
	
	label var r901a "Has movie theater"
	recode r901a (2=0)
	rename r901a dum_movietheater
	
	label var r1010a "Has post office"
	recode r1010a (2=0)
	rename r1010a dum_postoffice
	
	// Land area, agricultural (rice), agricultural (non-rice), non-agricultural missing
	 
	label var r1203a "Has shopping complex" 
	recode r1203a (2=0)
	rename r1203a dum_shopping_complex
	label var r1205a "Has markets with permanent buildings" 
	recode r1205a (2=0)
	rename r1205a dum_markets
	label var r1208 "Number of stores" 
	rename r1208 no_stores
	label var r1209 "Number of food stalls" 
	rename r1209 no_food_stalls
	label var r1210 "Number of restaurants" 
	rename r1210 no_restaurants
	label var r1211 "Number of hotels" 
	rename r1211 no_hotels
	
	label var r1215ak2 "Has commercial banks"	
	recode r1215ak2 (2=0)
	rename r1215ak2 dum_banks
	label var r1215bk2 "Has rural banks"
	recode r1215bk2 (2=0)
	rename r1215bk2 dum_rural_banks
	label var r1215ak3 "Number of commercial banks"
	replace r1215ak3 = 0 if dum_banks == 0
	rename r1215ak3 no_banks
	label var r1215bk3 "Number of rural banks"
	replace r1215bk3 = 0 if dum_rural_banks == 0
	rename r1215bk3 no_rural_banks
	
	// Have some stuff on crime, but can't really compare across cities
	
	label var r1309ak2 "Has a guard post (kamling)" 
	recode r1309ak2 (2=0)
	rename r1309ak2 dum_guardpost
	label var r1309bk2 "Has a police post" 
	recode r1309bk2 (2=0)
	rename r1309bk2 dum_policepost
	
	label var r704ak5 "Ease of reaching hospital" 
	label define lab_r704ak5 1 "Very easy" 2 "Easy" 3 "Difficult" 4 "Very difficult" 
	label values r704ak5 lab_r704ak5
	rename r704ak5 ease_reach_hospital
	label var r704dk5 "Ease of reaching puskesmas" // Doesn't include other health facility, as in 2000
	label define lab_r704dk5 1 "Very easy" 2 "Easy" 3 "Difficult" 4 "Very difficult"
	label values r704dk5 lab_r704dk5
	rename r704dk5 ease_reach_health
	label var r1309bk4 "Ease of reaching police post" 
	label define lab_r1309bk4 1 "Very easy" 2 "Easy" 3 "Difficult" 4 "Very difficult"
	label values r1309bk4 lab_r1309bk4
	rename r1309bk4 ease_reach_police_post
	
	////////////////////////////////////////////////////
	// Add rural status from 2011 Infrastructure file //
	////////////////////////////////////////////////////
	preserve
	use "$rawdata/PODES/2011 Infrastructure?/Data/Podes11-Listing Faskesdik 1", clear
	keep r101 r102 r103 r104 r105
	drop if inlist(r101, 91, 94)
	rename r101 prop
	rename r102 kab
	rename r103 kec
	rename r104 desa
	gen dum_rural = r105 - 1
	drop r105
	label var dum_rural "Rural status"
	tempfile podes_rural
	save `podes_rural'
	restore
	merge 1:1 prop kab kec desa using `podes_rural'
	// Missing 3: for prop-kab-kec-desa 13-1-41-1/2/3
	drop if _merge == 2
	drop _merge
	order dum_rural, a(desa)
	
	//////////////////////////////////////////////
	// Change regencies to SUPAS 1995 regencies //
	//////////////////////////////////////////////
	
	gen rgcycode_PODES11 = 100 * prop + kab
	merge m:1 rgcycode_PODES11 using "$secdata/PODES/podes11_to_supas95_rgcy_key"
	drop if _merge == 2
	drop _merge
	replace prop = int(rgcycode_SUPAS95 / 100)
	replace kab = mod(rgcycode_SUPAS95, 100)
	drop rgcycode_PODES11 rgcyname rgcycode_SUPAS95
	
	// Add year and save
	gen year = 2011
	save "$secdata/PODES/podes_2011.dta", replace 
	
end
