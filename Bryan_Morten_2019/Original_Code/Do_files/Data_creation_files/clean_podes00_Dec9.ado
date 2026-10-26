*! 9/5:MM - just renamed variables so we can merge between the two sets
* AH: Dec 9, 2014 - Just commented on which weren't in PODES 1996

program clean_podes00_Dec9
	
	use "$secdata/PODES/podes_2000_raw.dta", clear
	drop if inlist(prop, 54, 82) // Drop East Timor and West Papua	

	keep prop kab kec desa drh B3R1 B3R9 B3R10 B4AR2A B4AR2B B4AR2C B4AR6A B4AR6B ///
		 B4BR8A B4BR8B B4BR11A B4BR11B1 B4BR11B2 B4BR11B3 B4BR11B4 ///
		 B4BR14A2 B4BR14B2 B4BR14C2 B4BR14G2 B4BR15A - B4BR1510 ///
		 B5R1A2 B5R1A3 B5R1B2 B5R1B3 B5R1C2 B5R1C3 B5R1D2 B5R1D3 B5R1E2 B5R1E3 B5R4 ///
		 B6R1A2 B6R1B2 B6R1C2 B6R1D2 B6R1E2 B6R1F2 B7R3A ///
		 B8R1A2 B8R1B2 B8R1C2 B8R1D2 B8R1E2 B8R1F2 B8R1G2 B8R1H2 B8R1I2 B8R1J2 B8R1K2 B8R1L2 B8R1M2 B8R1N2 ///
		 B8R2A1 B8R2A2 B9AR5A B9AR5B B9AR5C B10A B10B B10C B11AR1A B11AR2A ///
		 B11BR1 B11BR2 B11CR1 B12R3A2 B12R3B2 B12R3C2 

	label var prop "Province code"
	label var kab "Regency code"
	label var kec "District code"
	label var desa "Village code"
	
	label var drh "Rural status"
	replace drh = drh - 1
	label define lab_drh 0 "Urban" 1 "Rural"
	label values drh lab_drh
	rename drh dum_rural

	rename B3R1 upt
	recode upt (1=0) (2=0) (3=1) (4=0)
	label var upt "Transmigration village"
	
	
	label var B3R9 "Geography"
	label define lab_B3R9 1 "Shore" 2 "Valley" 3 "Hill" 4 "Land"
	label values B3R9 lab_B3R9
	rename B3R9 type_geography

	label var B3R10 "Topography"
	label define lab_B3R10 1 "High land" 2 "Low land"
	label values B3R10 lab_B3R10
	rename B3R10 type_topography

	label var B4AR2A "Population"
	rename B4AR2A podes_population
	label var B4AR2B "Number of households"
	rename B4AR2B podes_no_hh
	label var B4AR2C "Number of agricultural households" // Not in 1996
	rename B4AR2C podes_no_ag_hh
	
	label var B4AR6A "Source income of majority population"
	label define lab_B4AR6A 1 "Agriculture" 2 "Mining & quarrying" 3 "Industry" ///
							4 "Big trade/retail, restaurant and accommodation" 5 "Other"
	label values B4AR6A lab_B4AR6A
	rename B4AR6A source_income

	label var B4AR6B "If source_income coded 1, main sub-sector"
	label define lab_B4AR6B 1 "Agricultural crops" 2 "Livestock" 3 "Forestry" ///
							4 "Plantation" 5 "Fisheries" 6 "Other agricultural"
	label values B4AR6B lab_B4AR6B
	rename B4AR6B source_ag_income
	
	label var B4BR8A "Number of permanent houses"
	rename B4BR8A podes_no_perm_houses
	label var B4BR8B "Number of semi-permanent houses"
	rename B4BR8B podes_no_semiperm_house
	
	label var B4BR11A "Any poor settlements in village?"
	recode B4BR11A (2=0)
	*rename B4BR11A dum_slums
	label var B4BR11B1 "Slums: Number of locations" // Not in 1996
	replace B4BR11B1 = 0 if B4BR11A == 0
	rename B4BR11B1 no_slums
	label var B4BR11B2 "Slums: Land area (Ha)"
	replace B4BR11B2 = 0 if B4BR11A == 0
	rename B4BR11B2 slums_area
	label var B4BR11B3 "Slums: Number of household"
	replace B4BR11B3 = 0 if B4BR11A == 0
	rename B4BR11B3 podes_slums_no_hh
	label var B4BR11B4 "Slums: Number of households members"
	replace B4BR11B4 = 0 if B4BR11A == 0
	rename B4BR11B4 podes_slums_no_hhmember
	rename B4BR11A dum_slums
	
	label var B4BR14A2 "Water pollution (past year)"
	recode B4BR14A2 (2 = 0)
	rename B4BR14A2 dum_water_pollution
	label var B4BR14B2 "Land pollution (past year)"
	recode B4BR14B2 (2 = 0)
	rename B4BR14B2 dum_land_pollution
	label var B4BR14C2 "Air pollution (past year)"
	recode B4BR14C2 (2 = 0)
	rename B4BR14C2 dum_air_pollution
	label var B4BR14G2 "Noise pollution (past year)"
	recode B4BR14G2 (2 = 0)
	rename B4BR14G2 dum_noise_pollution

	label var B4BR15A "Number of natural disasters in last 3 years" // Not in 1996
	rename B4BR15A no_natural_disasters
	
	label var B4BR15B1 "Earthquake" // Not in 1996
	recode B4BR15B1 (0=0) (1=1) (2=0)
	rename B4BR15B1 dum_earthquake
	label var B4BR15B2 "Volcanic eruption" // Not in 1996
	recode B4BR15B2 (0=0) (3=1) (4=0)
	rename B4BR15B2 dum_volcano
	label var B4BR15B3 "Drought" // Not in 1996
	recode B4BR15B3 (0=0) (5=1) (6=0)
	rename B4BR15B3 dum_drought
	label var B4BR15B4 "Forest and land fires" // Not in 1996
	recode B4BR15B4 (0=0) (7=1) (8=0)
	rename B4BR15B4 dum_fire
	label var B4BR15B5 "Flooding" // Not in 1996
	recode B4BR15B5 (0=0) (1=1) (2=0)
	rename B4BR15B5 dum_flooding
	label var B4BR15B6 "Smoke/haze" // Not in 1996
	recode B4BR15B6 (0=0) (3=1) (4=0)
	rename B4BR15B6 dum_smoke
	label var B4BR15B7 "Landslide" // Not in 1996
	recode B4BR15B7 (0=0) (5=1) (6=0)
	rename B4BR15B7 dum_landslide
	label var B4BR15B8 "Coastal erosion" // Not in 1996
	recode B4BR15B8 (0=0) (7=1) (8=0)
	rename B4BR15B8 dum_erosion
	label var B4BR15B9 "Tidal wave/tsunami" // Not in 1996
	recode B4BR15B9 (0=0) (1=1) (2=0)
	rename B4BR15B9 dum_tidalwave
	label var B4BR1510 "Other natural disaster" // Not in 1996
	recode B4BR1510 (0=0) (3=1) (4=0)
	rename B4BR1510 dum_other_disaster
	
	label var B5R1A2 "Number of schools: Kindergarten, govt"
	rename B5R1A2 no_kindergarten_gov
	label var B5R1A3 "Number of schools: Kindergarten, priv"
	rename B5R1A3 no_kindergarten_priv
	label var B5R1B2 "Number of schools: Primary school, govt"
	rename B5R1B2 no_primary_gov
	label var B5R1B3 "Number of schools: Primary school, priv"
	rename B5R1B3 no_primary_priv
	label var B5R1C2 "Number of schools: Junior high school, govt"
	rename B5R1C2 no_juniorhigh_gov
	label var B5R1C3 "Number of schools: Junior high school, priv"
	rename B5R1C3 no_juniorhigh_priv
	label var B5R1D2 "Number of schools: High school, govt"
	rename B5R1D2 no_highschool_gov
	label var B5R1D3 "Number of schools: High school, priv"
	rename B5R1D3 no_highschool_priv
	label var B5R1E2 "Number of schools: University/academy, govt"
	rename B5R1E2 no_university_gov
	label var B5R1E3 "Number of schools: University/academy, priv"
	rename B5R1E3 no_university_priv
	
	label var B5R4 "Number of households that have sent their children/relatives to university"
	rename B5R4 no_hh_child_uni
	
	label var B6R1A2 "Number of mosques"
	rename B6R1A2 no_mosques
	label var B6R1B2 "Number of prayer houses (small mosques)"
	rename B6R1B2 no_prayerhouse
	label var B6R1E2 "Number of puras (Hindu)"
	rename B6R1E2 no_hindu_pura
	label var B6R1F2 "Number of viharas (Buddhist)"
	rename B6R1F2 no_buddhist_vihara

	label var B6R1C2 "Number of churches/chapels - Protestant" // Combined as churches in 1996
	label var B6R1D2 "Number of churches/chapels - Catholic"
	gen no_church = B6R1C2+B6R1D2
	drop B6R1C2 B6R1D2
	label var no_church "Number of churches/chapels"
	
	label var B7R3A "Has movie theater"
	recode B7R3A (2=0)
	rename B7R3A dum_movietheater
	
	gen no_maternity_hosp = B8R1B2 + B8R1C2
	drop B8R1B2 B8R1C2
	label var no_maternity_hosp "Number of maternity hospitals/houses"
	
	label var B8R1A2 "Number of hospitals"
	rename B8R1A2 no_hosp
	label var B8R1D2 "Number of polyclinics"
	rename B8R1D2 no_polyclinic
	label var B8R1E2 "Number of integrated health centers (puskesmas)"
	rename B8R1E2 no_integrated_health
	label var B8R1F2 "Number of supported puskesmas"
	rename B8R1F2 no_supported_integrated_health
	label var B8R1G2 "Number of medicinal treatment centers"
	rename B8R1G2 no_medicinal
	label var B8R1H2 "Number of doctors' practices"
	rename B8R1H2 no_doctor_clinic
	label var B8R1I2 "Number of midwives' practices" // Not in 1996
	rename B8R1I2 no_midwife_clinic
	label var B8R1J2 "Number of neighborhood health centers (posyandu)" // Not in 1996
	rename B8R1J2 no_nbhd_health
	label var B8R1K2 "Number of village maternity posts (polindes)" 
	rename B8R1K2 no_village_maternity
	label var B8R1L2 "Number of pharmacies"
	rename B8R1L2 no_pharmacies
	label var B8R1M2 "Number of village medicine posts (POD)" // Not in 1996
	rename B8R1M2 no_village_medicine
	label var B8R1N2 "Number of drug stores"
	rename B8R1N2 no_drugstore
	
	gen B8R2A = B8R2A1 + B8R2A2
	drop B8R2A1 B8R2A2
	label var B8R2A "Number of doctors"
	rename B8R2A no_doctors

	label var B9AR5A "Has public motor transport station/terminal" 
	recode B9AR5A (1=1) (2=0)
	rename B9AR5A dum_public_terminal
	label var B9AR5B "Has dock/port"
	recode B9AR5B (3=1) (4=0)
	rename B9AR5B dum_port
	label var B9AR5C "Has airport"
	recode B9AR5C (5=1) (6=0)
	rename B9AR5C dum_airport

	label var B10A "Village's land area (Sq km)"
	rename B10A total_landarea
	label var B10B "Rice field area (Sq km)"
	rename B10B rice_area
	label var B10C "Non-rice field area (Sq km)"
	rename B10C nonrice_area
	foreach var of varlist total_landarea rice_area nonrice_area {
		replace `var' = `var' / 100
	}

	label var B11AR1A "Has shopping complex" 
	recode B11AR1A (2=0)
	rename B11AR1A dum_shopping_complex
	label var B11AR2A "Number of markets with permanent buildings" 
	rename B11AR2A no_markets

	label var B11BR1 "Has commercial banks"	
	recode B11BR1 (2=0)
	rename B11BR1 dum_banks
	label var B11BR2 "Has rural banks"
	recode B11BR2 (2=0)
	rename B11BR2 dum_rural_banks
	
	label var B11CR1 "Community socio-economic situation in general" 
	label define lab_B11CR1 1 "Wealthiest" 2 "Wealthy" 3 "Rich" 4 "Poor" 5 "Poorest"
	label values B11CR1 lab_B11CR1
	rename B11CR1 overall_socioeconomic
	
	label var B12R3A2 "Has a guard post (kamling)" // Not in 1996 
	recode B12R3A2 (2=0)
	rename B12R3A2 dum_guardpost
	label var B12R3B2 "Has a police post" // Not in 1996
	recode B12R3B2 (2=0)
	rename B12R3B2 dum_policepost
	label var B12R3C2 "Has a police station (Polsek)" // Not in 1996
	recode B12R3C2 (2=0)
	rename B12R3C2 dum_policestation

	//////////////////////////////////////////////
	// Change regencies to SUPAS 1995 regencies //
	//////////////////////////////////////////////
	
	gen rgcycode_PODES00 = 100 * prop + kab
	merge m:1 rgcycode_PODES00 using "$secdata/PODES/podes00_to_supas95_rgcy_key"
	drop if _merge == 2
	drop _merge
	replace prop = int(rgcycode_SUPAS95 / 100)
	replace kab = mod(rgcycode_SUPAS95, 100)
	drop rgcycode_PODES00 rgcyname rgcycode_SUPAS95
	
	// Add year and save
	gen year = 2000
	save "$secdata/PODES/podes_2000.dta", replace 
	
end
