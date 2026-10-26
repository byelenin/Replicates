program podes00_to_supas95_rgcy

	use "$secdata/PODES/podes_2000_raw.dta", clear
	drop if inlist(prop, 54, 82) // Drop East Timor and West Papua
	
	// Confirming that regency codes are the same as those of SUPAS 1995
	insheet using "$rawdata/PODES/2000/MFD_2000.CSV", names clear
	drop if inlist(prop2000, 54, 82)
	bys prop2000 kab2000 kec2000 desa2000 drh2000 nama2000: drop if _n>1
	gen rgcycode = 100 * prop2000 + kab2000
	keep if kec2000==0
	rename nama2000 rgcyname
	rename rgcycode rgcycode_PODES00
	keep rgcyname rgcycode_PODES00
	
	// Fixes to PODES 2000 to match SUPAS 1995
	bys rgcyname: gen tochange = mod(rgcycode_PODES00, 100)  if _N > 1
	replace rgcyname = rgcyname + " regency" if tochange < 70 & tochange != .
	replace rgcyname = rgcyname + " city" if tochange >= 70 & tochange != .
	drop tochange
	
	replace rgcyname = "KENDARI" if rgcyname == "KENDARI regency"
	replace rgcyname = "KODYA KENDARI" if rgcyname == "KENDARI city"
	replace rgcyname = "ACEH SELATAN" if rgcyname == "ACEH SINGKIL"
	replace rgcyname = "BANGGAI" if rgcyname == "BANGGAI KEPULAUAN"
	replace rgcyname = "BANJAR" if rgcyname == "BANJARBARU"
	replace rgcyname = "BEKASI" if rgcyname == "BEKASI city"
	replace rgcyname = "BEKASI" if rgcyname == "BEKASI regency"
	replace rgcyname = "SAMBAS" if rgcyname == "BENGKAYANG"
	replace rgcyname = "ACEH BARAT" if rgcyname == "BIREUEN"
	replace rgcyname = "GORONTALO REGENCY" if rgcyname == "BOALEMO"
	replace rgcyname = "KUTAI" if rgcyname == "BONTANG"
	replace rgcyname = "BUNGO TEBO" if rgcyname == "BUNGO"
	replace rgcyname = "BUOL TOLI-TOLI" if rgcyname == "BUOL"
	replace rgcyname = "SERANG" if rgcyname == "CILEGON"
	replace rgcyname = "BOGOR REGENCY" if rgcyname == "DEPOK"
	replace rgcyname = "BENGKALIS" if rgcyname == "DUMAI"
	replace rgcyname = "KEPULAUAN RIAU" if rgcyname == "KARIMUN"
	replace rgcyname = "PADANG PARIAMAN" if rgcyname == "KEPULAUAN MENTAWAI"
	replace rgcyname = "INDRAGIRI HULU" if rgcyname == "KUANTAN SINGINGI"
	replace rgcyname = "KUTAI" if rgcyname == "KUTAI BARAT"
	replace rgcyname = "KUTAI" if rgcyname == "KUTAI TIMUR"
	replace rgcyname = "LAMPUNG TENGAH" if rgcyname == "LAMPUNG TIMUR"
	replace rgcyname = "PONTIANAK REGENCY" if rgcyname == "LANDAK"
	replace rgcyname = "FLORES TIMUR" if rgcyname == "LEMBATA"
	replace rgcyname = "LUWU" if rgcyname == "LUWU UTARA"
	replace rgcyname = "BULONGAN" if rgcyname == "MALINAU"
	replace rgcyname = "TAPANULI SELATAN" if rgcyname == "MANDAILING NATAL"
	replace rgcyname = "SARKO (SAROLANGUN BANGKO" if rgcyname == "MERANGIN"
	replace rgcyname = "LAMPUNG TENGAH" if rgcyname == "METRO"
	replace rgcyname = "POSO" if rgcyname == "MOROWALI"
	replace rgcyname = "BATANG HARI" if rgcyname == "MUARO JAMBI"
	replace rgcyname = "KEPULAUAN RIAU" if rgcyname == "NATUNA"
	replace rgcyname = "BULONGAN" if rgcyname == "NUNUKAN"
	replace rgcyname = "KAMPAR" if rgcyname == "PELALAWAN"
	replace rgcyname = "BENGKALIS" if rgcyname == "ROKAN HILIR"
	replace rgcyname = "KAMPAR" if rgcyname == "ROKAN HULU"
	replace rgcyname = "SARKO (SAROLANGUN BANGKO" if rgcyname == "SAROLANGUN"
	replace rgcyname = "BENGKALIS" if rgcyname == "SIAK"
	replace rgcyname = "ACEH BARAT" if rgcyname == "SIMEULUE"
	replace rgcyname = "LAMPUNG SELATAN" if rgcyname == "TANGGAMUS"
	replace rgcyname = "TANJUNG JABUNG" if rgcyname == "TANJUNG JABUNG BARAT"
	replace rgcyname = "TANJUNG JABUNG" if rgcyname == "TANJUNG JABUNG TIMUR"
	replace rgcyname = "BULONGAN" if rgcyname == "TARAKAN"
	replace rgcyname = "BUNGO TEBO" if rgcyname == "TEBO"
	replace rgcyname = "TAPANULI UTARA" if rgcyname == "TOBA SAMOSIR"
	replace rgcyname = "BUOL TOLI-TOLI" if rgcyname == "TOLI-TOLI"
	replace rgcyname = "LAMPUNG UTARA" if rgcyname == "TULANG BAWANG"
	replace rgcyname = "LAMPUNG UTARA" if rgcyname == "WAY KANAN"
	
	sort rgcyname
	replace rgcyname = upper(rgcyname)
	tempfile temp
	save `temp'
	
	insheet using "$rawdata/SUPAS/Supas 1995/Regencies_1995.csv", names clear
	drop if inlist(provincecode, 54, 82)
	gen rgcycode = 100 * provincecode + regencycode
	rename nameofprovinceregency rgcyname
	rename rgcycode rgcycode_SUPAS95
	keep rgcyname rgcycode_SUPAS95
	
	sort rgcyname
	replace rgcyname = upper(rgcyname)
	merge 1:m rgcyname using `temp'
	drop _merge
	
	save "$secdata/PODES/podes00_to_supas95_rgcy_key", replace

end
