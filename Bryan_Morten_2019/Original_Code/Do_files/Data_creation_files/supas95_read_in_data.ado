* Version 1: February 11, 2014 (Allan Hsiao)
* Version 2: July 20, 2014 (AH) added self-employed, hours worked, literacy
* Version 3: October 2, 2014 (AH) added religion, language

program supas95_read_in_data

	set more off
	clear

	insheet using "$rawdata/SUPAS/Supas 1995/SUP95_04.csv"
	keep prop kab kec desa kp nks nus ///
		p501 p502 p503 p505 p509prop p509kab p509a p510prop ///
		p510kab p511 p514prop p514kab p514kec p514desa p514kota ///
		p515 p517 p518 p519 p601 p602 p606 p607 p609uang p609brng weight ///
		p516 p521 /*p604jam*/ p605 p608 ///
		p507 p522 p522l p522b p523 p523l p523b
	
	label variable prop "Province"
	label variable kab "Regency/Municipality"
	label variable kec "Sub region/Sub district"
	label variable desa "Village"
	label variable kp "Area (Urban - 1, Rural - 2)"
	label variable nks "Sample code number"
	label variable nus "Sample serial number"
	label variable p501 "Serial number of household member"
	label variable p502 "Relationship to head of HH"
	label variable p503 "Sex"
	label variable p505 "Age"
	label variable p509prop "Place of birth (province)"
	label variable p509kab "Place of birth (regency)"
	label variable p509a "Ever lived in other regency"
	label variable p510prop "Place of previous residance (province)"
	label variable p510kab "Place of previous residance (regency)"
	label variable p511 "Duration"
	label variable p514prop "Place of residance 5 years ago (province)"
	label variable p514kab "Place of residance 5 years ago (regency)"
	label variable p514kec "Place of residance 5 years ago (sub region)"
	label variable p514desa "Place of residance 5 years ago (village)"
	label variable p514kota "Place of residance 5 years ago [Area (Urban - 1, Rural - 2)]"
	label variable p515 "Main reason"
	label variable p516 "School attendance"
	label variable p517 "Highest level education attended"
	label variable p518 "Highest grade education"
	label variable p519 "Highest level education completed"
	label variable p521 "Literacy"
	label variable p601 "Primary activity in the previous week"
	label variable p602 "Worked for at least one hour"
	label variable p605 "Hours worked last week"
	label variable p606 "Occupation"
	label variable p607 "Type of industry"
	label variable p608 "Employment status"
	label variable p609uang "Average monthly salary (money)"
	label variable p609brng "Average monthly salary (goods)"
	label variable weight "Sample design weights"
	
	label variable p507 "Religion"
	label variable p522 "Mother tongue"
	label variable p522l "Mother tongue"
	label variable p522b "Mother tongue"
	label variable p523 "Home language"
	label variable p523l "Home language"
	label variable p523b "Home language"
	
	// Note: p601-p609 are all about primary activity
	
	save "$secdata/Compiled/supas_1995", replace
	
end
