* AH: Dec 9, 2014: Renamed vars to merge together

program clean_podes96_Dec9

	use "$secdata/PODES/podes_1996_raw.dta", clear
	drop if inlist(B1R1, 54, 82) // Drop East Timor and West Papua
	
	/*
	// Confirming that regency codes are the same as those of SUPAS 1995
	insheet using "$rawdata/PODES/1996/DESPOD96.CSV", names clear
	rename identitas2 rgcycode
	keep if mod(rgcycode, 1000000)==0
	drop if mod(rgcycode, 100000000)==0
	replace rgcycode = rgcycode/1000000
	rename desa PODES96
	keep rgcycode PODES96
	tempfile temp
	save `temp'

	insheet using "$rawdata/SUPAS/Supas 1995/Regencies_1995.csv", names clear
	gen rgcycode = 100 * provincecode + regencycode
	keep nameofprovinceregency rgcycode
	drop if mod(rgcycode, 100)==0
	rename nameofprovinceregency SUPAS95
	merge 1:1 rgcycode using `temp'
	drop _merge

	replace SUPAS95 = lower(subinstr(SUPAS95, " ", "", .))
	replace SUPAS95 = subinstr(SUPAS95, "regency", "", .)
	replace SUPAS95 = subinstr(SUPAS95, "city", "", .)
	replace SUPAS95 = subinstr(SUPAS95, "kodya", "", .)
	replace PODES96 = lower(subinstr(PODES96, " ", "", .))
	drop if SUPAS95 == PODES96
	*/

	keep B1R1 B1R2 B1R3 B1R4 B1R5 B3R1 B3R10 B3R11 B3R14A B3R14B B4AR2A B4AR2B B4AR2C ///
		 B4AR2D B4AR3 B4BR5AK2 B4BR5BK2 B4BR5CK2 B4BR5DK2 B4BR9A B4BR9B B4BR9C ///
		 B4BR10 B4BR14A B4BR14B1 B4BR14B2 B4BR14B3 ///
		 B5R1AK2 B5R1AK3 B5R1AK4 B5R1AK5 B5R1BK2 B5R1BK3 B5R1BK4 B5R1BK5 ///
		 B5R1CK2 B5R1CK3 B5R1CK4 B5R1CK5 B5R1DK2 B5R1DK3 B5R1DK4 B5R1DK5 ///
		 B5R1EK2 B5R1EK3 B5R1EK4 B5R1EK5 ///
		 B6AR1 B6AR2 B6AR3 B6AR4 B6AR5 B7R1A ///
		 B8R1AK2 B8R1BK2 B8R1CK2 B8R1DK2 B8R1EK2 B8R1FK2 B8R1GK2 B8R1HK2 B8R1IK2 ///
		 B8R1JK2 B8R1KK2 B8R2A1 B8R2A2 ///
		 B9AR4A B9AR4B B9AR4C B9AR4D B9AR4E B9AR5A B9AR5B B9AR5C B9AR5D ///
		 B10A B10B B10C B11AR1A B11AR2A ///
		 B11CR1A B11CR1B B11CR1C B11CR2A1 B11CR2A2 B11CR2B1 B11CR2B2 B11CR2C ///
		 B11ER4A B11ER7

	label var B1R1 "Province code"
	label var B1R2 "Regency code"
	label var B1R3 "District code"
	label var B1R4 "Village code"

	rename B1R1 prop
	rename B1R2 kab
	rename B1R3 kec
	rename B1R4 desa
	
	label var B1R5 "Rural status"
	replace B1R5 = B1R5 - 1
	label define lab_B1R5 0 "Urban" 1 "Rural"
	label values B1R5 lab_B1R5
	rename B1R5 dum_rural

	rename B3R1 upt
	recode upt (1=0) (2=0) (3=1) (4=0)
	label var upt "Transmigration village"
	
	label var B3R10 "Geography"
	label define lab_B3R10 1 "Shore" 2 "Valley" 3 "Hill" 4 "Land"
	label values B3R10 lab_B3R10
	rename B3R10 type_geography

	label var B3R11 "Topography"
	label define lab_B3R11 1 "High land" 2 "Low land"
	label values B3R11 lab_B3R11
	rename B3R11 type_topography

	label var B3R14A "Source income of majority population"
	label define lab_B3R14A 1 "Agriculture" 2 "Mining & quarrying" 3 "Industry" 4 "Electricity, gas, and water" ///
							5 "Construction" 6 "Wholesaler, retails, restaurant and accommodation" ///
							7 "Transportation, storage and communication" ///
							8 "Finances Institution, real-estate, renting, and service company" ///
							9 "Community services, social, and individual"
	label values B3R14A lab_B3R14A
	rename B3R14A source_income

	label var B3R14B "If source_income coded 1, main sub-sector"
	label define lab_B3R14B 1 "Food planting" 2 "Livestock" 3 "Plantation" 4 "Fishery" 5 "Forestry"
	label values B3R14B lab_B3R14B
	rename B3R14B source_ag_income

	label var B4AR2A "Population"
	rename B4AR2A podes_population
	label var B4AR2B "Female population" // Not in 2000
	rename B4AR2B podes_population_fem
	label var B4AR2C "Number of households"
	rename B4AR2C podes_no_hh
	label var B4AR2D "Number of households headed by women" // Not in 2000
	rename B4AR2D podes_no_hh_fem
	label var B4AR3 "Number of households that have sent their children/relatives to university" 
	rename B4AR3 no_hh_child_uni

	label var B4BR5AK2 "Water pollution (past year)"
	recode B4BR5AK2 (2 = 0)
	rename B4BR5AK2 dum_water_pollution
	label var B4BR5BK2 "Land pollution (past year)"
	recode B4BR5BK2 (2 = 0)
	rename B4BR5BK2 dum_land_pollution
	label var B4BR5CK2 "Air pollution (past year)"
	recode B4BR5CK2 (2 = 0)
	rename B4BR5CK2 dum_air_pollution
	label var B4BR5DK2 "Noise pollution (past year)"
	recode B4BR5DK2 (2 = 0)
	rename B4BR5DK2 dum_noise_pollution

	label var B4BR9A "Number of permanent houses"
	rename B4BR9A podes_no_perm_houses
	label var B4BR9B "Number of semi-permanent houses"
	rename B4BR9B podes_no_semiperm_house
	label var B4BR9C "Number of simple houses" // Not in 2000
	rename B4BR9C podes_no_simple_house
	label var B4BR10 "Number of buildings with 4+ stories" // Not in 2000
	rename B4BR10 podes_no_high_house

	label var B4BR14A "Any poor settlements in village?"
	recode B4BR14A (2=0)
	*rename B4BR14A dum_slums
	label var B4BR14B1 "Slums: Land area (Ha)"
	replace B4BR14B1 = 0 if B4BR14A == 0
	rename B4BR14B1 slums_area
	label var B4BR14B2 "Slums: Number of household members"
	replace B4BR14B2 = 0 if B4BR14A == 0
	rename B4BR14B2 podes_slums_no_hhmember
	label var B4BR14B3 "Slums: Number of households"
	replace B4BR14B3 = 0 if B4BR14A == 0
	rename B4BR14B3 podes_slums_no_hh
	rename B4BR14A dum_slums

	label var B5R1AK2 "Number of schools: Kindergarten, govt, has building"
	label var B5R1AK3 "Number of schools: Kindergarten, govt, no building" 
	gen no_kindergarten_gov = B5R1AK2+B5R1AK3
	lab var no_kindergarten_gov "Number of schools: Kindergarten, govt"
	drop B5R1AK2 B5R1AK3
	
	label var B5R1AK4 "Number of schools: Kindergarten, priv, has building" 
	label var B5R1AK5 "Number of schools: Kindergarten, priv, no building" 
	gen no_kindergarten_priv = B5R1AK4+B5R1AK5
	lab var no_kindergarten_priv "Number of schools: Kindergarten, priv"
	drop B5R1AK4 B5R1AK5
	
	label var B5R1BK2 "Number of schools: Primary school, govt, has building"
	label var B5R1BK3 "Number of schools: Primary school, govt, no building" 
	gen no_primary_gov = B5R1BK2+B5R1BK3
	lab var no_primary_gov "Number of schools: Primary school, govt"
	drop B5R1BK2 B5R1BK3
	
	label var B5R1BK4 "Number of schools: Primary school, priv, has building" 
	label var B5R1BK5 "Number of schools: Primary school, priv, no building" 
	gen no_primary_priv = B5R1BK4+B5R1BK5
	lab var no_primary_priv "Number of schools: Primary school, priv"
	drop B5R1BK4 B5R1BK5
	
	label var B5R1CK2 "Number of schools: Junior high school, govt, has building"
	label var B5R1CK3 "Number of schools: Junior high school, govt, no building" 
	gen no_juniorhigh_gov = B5R1CK2+B5R1CK3
	lab var no_juniorhigh_gov "Number of schools: Junior high school, govt"
	drop B5R1CK2 B5R1CK3
	
	label var B5R1CK4 "Number of schools: Junior high school, priv, has building" 
	label var B5R1CK5 "Number of schools: Junior high school, priv, no building" 
	gen no_juniorhigh_priv = B5R1CK4+B5R1CK5
	lab var no_juniorhigh_priv "Number of schools: Junior high school, priv"
	drop B5R1CK4 B5R1CK5
	
	label var B5R1DK2 "Number of schools: High school, govt, has building"
	label var B5R1DK3 "Number of schools: High school, govt, no building" 
	gen no_highschool_gov = B5R1DK2+B5R1DK3
	lab var no_highschool_gov "Number of schools: High school, govt"
	drop B5R1DK2 B5R1DK3
	
	label var B5R1DK4 "Number of schools: High school, priv, has building" 
	label var B5R1DK5 "Number of schools: High school, priv, no building" 
	gen no_highschool_priv = B5R1DK4+B5R1DK5
	lab var no_highschool_priv "Number of schools: High school, priv"
	drop B5R1DK4 B5R1DK5
	
	label var B5R1EK2 "Number of schools: University/academy, govt, has building"
	label var B5R1EK3 "Number of schools: University/academy, govt, no building" 
	gen no_university_gov = B5R1EK2+B5R1EK3
	lab var no_university_gov "Number of schools: University/academy, govt"
	drop B5R1EK2 B5R1EK3
	
	label var B5R1EK4 "Number of schools: University/academy, priv, has building" 
	label var B5R1EK5 "Number of schools: University/academy, priv, no building" 
	gen no_university_priv = B5R1EK4+B5R1EK5
	lab var no_university_priv "Number of schools: University/academy, priv"
	drop B5R1EK4 B5R1EK5
	
	label var B6AR1 "Number of mosques"
	rename B6AR1 no_mosques
	label var B6AR2 "Number of prayer houses (small mosques)"
	rename B6AR2 no_prayerhouse
	label var B6AR3 "Number of churches/chapels"
	rename B6AR3 no_church
	label var B6AR4 "Number of puras (Hindu)" 
	rename B6AR4 no_hindu_pura
	label var B6AR5 "Number of viharas (Buddhist)"
	rename B6AR5 no_buddhist_vihara

	label var B7R1A "Has movie theater"
	recode B7R1A (2=0)
	rename B7R1A dum_movietheater

	gen no_maternity_hosp = B8R1BK2 + B8R1CK2
	drop B8R1BK2 B8R1CK2
	label var no_maternity_hosp "Number of maternity hospitals/houses"
	
	label var B8R1AK2 "Number of hospitals"
	rename B8R1AK2 no_hosp
	label var B8R1DK2 "Number of polyclinics"
	rename B8R1DK2 no_polyclinic
	label var B8R1EK2 "Number of integrated health centers (puskesmas)"
	rename B8R1EK2 no_integrated_health
	label var B8R1FK2 "Number of supported puskesmas"
	rename B8R1FK2 no_supported_integrated_health
	label var B8R1GK2 "Number of medicinal treatment centers"
	rename B8R1GK2 no_medicinal
	label var B8R1HK2 "Number of doctors' practices"
	rename B8R1HK2 no_doctor_clinic
	label var B8R1IK2 "Number of village maternity posts (polindes)"
	rename B8R1IK2 no_village_maternity
	label var B8R1JK2 "Number of pharmacies"
	rename B8R1JK2 no_pharmacies
	label var B8R1KK2 "Number of drug stores"
	rename B8R1KK2 no_drugstore
	
	gen B8R2A = B8R2A1 + B8R2A2
	drop B8R2A1 B8R2A2
	label var B8R2A "Number of doctors"
	rename B8R2A no_doctors

	label var B9AR4A "Has public motor transport station/terminal" 
	recode B9AR4A (1=1) (2=0)
	rename B9AR4A dum_public_terminal
	label var B9AR4B "Has railway station" // Not in 2000
	recode B9AR4B (3=1) (4=0)
	rename B9AR4B dum_railway
	label var B9AR4C "Has seaport"
	recode B9AR4C (5=1) (6=0)
	rename B9AR4C dum_port
	label var B9AR4D "Has river pier" // Not in 2000
	recode B9AR4D (7=1) (8=0)
	rename B9AR4D dum_pier
	label var B9AR4E "Has airport"
	recode B9AR4E (1=1) (2=0)
	rename B9AR4E dum_airport

	label var B9AR5A "Ease of reaching hospital" // Not in 2000
	label define lab_B9AR5A 1 "Very easy" 2 "Easy" 3 "Difficult" 4 "Very difficult" 
	label values B9AR5A lab_B9AR5A
	rename B9AR5A ease_reach_hospital
	label var B9AR5B "Ease of reaching puskesmas/other health facility" // Not in 2000
	label define lab_B9AR5B 1 "Very easy" 2 "Easy" 3 "Difficult" 4 "Very difficult"
	label values B9AR5B lab_B9AR5B
	rename B9AR5B ease_reach_health
	label var B9AR5C "Ease of reaching market with permanent building" // Not in 2000
	label define lab_B9AR5C 1 "Very easy" 2 "Easy" 3 "Difficult" 4 "Very difficult"
	label values B9AR5C lab_B9AR5C
	rename B9AR5C ease_reach_market
	label var B9AR5D "Ease of reaching shopping complex" // Not in 2000
	label define lab_B9AR5D 1 "Very easy" 2 "Easy" 3 "Difficult" 4 "Very difficult"
	label values B9AR5D lab_B9AR5D
	rename B9AR5D ease_reach_shopping

	label var B10A "Village's land area (Sq km)"
	rename B10A total_landarea
	label var B10B "Rice field area (Sq km)" 
	rename B10B rice_area
	label var B10C "Non-rice field area (Sq km)"
	rename B10C nonrice_area
	foreach var of varlist total_landarea rice_area nonrice_area {
		replace `var' = `var' / 1000
	}

	label var B11AR1A "Has shopping complex"
	recode B11AR1A (2=0)
	rename B11AR1A dum_shopping_complex
	label var B11AR2A "Number of markets with permanent buildings"
	rename B11AR2A no_markets

	egen B11CR1 = rowtotal(B11CR1A B11CR1B B11CR1C)
	drop B11CR1A B11CR1B B11CR1C
	label var B11CR1 "Number of commerical banks"
	rename B11CR1 no_banks
	egen B11CR2 = rowtotal(B11CR2A1 B11CR2A2 B11CR2B1 B11CR2B2 B11CR2C)
	drop B11CR2A1 B11CR2A2 B11CR2B1 B11CR2B2 B11CR2C
	label var B11CR2 "Number of rural banks"
	rename B11CR2 no_rural_banks

	label var B11ER4A "Main road village lighting" // Not in 2000
	recode B11ER4A (2=0)
	rename B11ER4A main_road_lighting
	
	label var B11ER7 "Community socio-economic situation in general"
	label define lab_B11ER7 1 "Wealthiest" 2 "Wealthy" 3 "Rich" 4 "Poor" 5 "Poorest"
	label values B11ER7 lab_B11ER7
	rename B11ER7 overall_socioeconomic

	// Add year and save
	gen year = 1996
	save "$secdata/PODES/podes_1996.dta", replace 
	
end
