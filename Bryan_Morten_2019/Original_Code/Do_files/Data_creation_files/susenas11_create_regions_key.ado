* Version 1: March 21, 2014 (Allan Hsiao)

program susenas11_create_regions_key
	
	// List of all current and origin regencies for SUPAS 1995
	foreach rgcy in current birth prev five_yrs {
		use "$secdata/Compiled/supas_1995_cleaned", clear
		collapse age, by(`rgcy'_rgcy)
		keep `rgcy'_rgcy
		rename `rgcy'_rgcy rgcy_code
		merge m:1 rgcy_code using "$secdata/Compiled/supas95_rgcy_coordinates"
		drop if _merge != 3
		drop _merge latitude longitude
		save "$secdata/Compiled/supas_1995_regencies_`rgcy'", replace
	}
	
	use "$secdata/Compiled/supas_1995_regencies_current", clear
	foreach origin in birth prev five_yrs {
		append using "$secdata/Compiled/supas_1995_regencies_`origin'"
		cap erase "$secdata/Compiled/supas_1995_regencies_`origin'.dta"
	}
	cap erase "$secdata/Compiled/supas_1995_regencies_current.dta"
	
	sort regency
	by regency: gen unique = _n
	keep if unique == 1
	drop unique
	rename rgcy_code supas95_rgcy_code
	
	save "$secdata/Compiled/supas_1995_regencies", replace
	
	// List of all current and origin regencies for SUSENAS 2011-2012
	foreach rgcy in current birth five_yrs {
		use "$secdata/Compiled/susenas_2011_2012", clear
		
		replace b5_tl2 = . if b5_tl2 == 0
		gen birth_rgcy = 100 * b5_tl1 + b5_tl2
		
		replace b5_tt1 = . if b5_tt1 == 0
		replace b5_tt2 = . if b5_tt2 == 0
		gen five_yrs_rgcy = 100 * b5_tt1 + b5_tt2
		
		rename kabu current_rgcy
		rename umur age
	
		collapse age, by(`rgcy'_rgcy)
		keep `rgcy'_rgcy
		rename `rgcy'_rgcy rgcy_code
		merge m:1 rgcy_code using "$secdata/Compiled/susenas11_rgcy_coordinates"
		drop if _merge != 3
		drop _merge latitude longitude
		save "$secdata/Compiled/susenas_2011_2012_regencies_`rgcy'", replace
	}
	
	use "$secdata/Compiled/susenas_2011_2012_regencies_current", clear
	foreach origin in birth five_yrs {
		append using "$secdata/Compiled/susenas_2011_2012_regencies_`origin'"
		cap erase "$secdata/Compiled/susenas_2011_2012_regencies_`origin'.dta"
	}
	cap erase "$secdata/Compiled/susenas_2011_2012_regencies_current.dta"
	
	sort regency
	by regency: gen unique = _n
	keep if unique == 1
	drop unique
	rename rgcy_code susenas11_rgcy_code
	save "$secdata/Compiled/susenas_2011_2012_regencies", replace
	
	*****************
	
	use "$secdata/Compiled/susenas_2011_2012_regencies", clear
	replace regency = upper(regency)
	
	replace regency = "ACEH SELATAN" if regency == "ACEH BARAT DAYA"
	replace regency = "ACEH BARAT" if regency == "ACEH JAYA"
	replace regency = "ACEH SELATAN" if regency == "ACEH SINGKIL"
	replace regency = "ACEH TIMUR" if regency == "ACEH TAMIANG"
	replace regency = "BATAM" if regency == "B A T A M"
	replace regency = "HULU SUNGAI UTARA" if regency == "BALANGAN"
	replace regency = "BANDUNG REGENCY" if regency == "BANDUNG BARAT"
	replace regency = "BANGGAI" if regency == "BANGGAI KEPULAUAN"
	replace regency = "BANGKA" if regency == "BANGKA BARAT"
	replace regency = "BANGKA" if regency == "BANGKA SELATAN"
	replace regency = "BANGKA" if regency == "BANGKA TENGAH"
	replace regency = "BANJAR" if regency == "BANJAR BARU"
	replace regency = "CIAMIS" if regency == "BANJAR CITY"
	replace regency = "CIAMIS" if regency == "BANJAR REGENCY"
	replace regency = "MUSI BANYUASIN" if regency == "BANYU ASIN"
	replace regency = "BARITO SELATAN" if regency == "BARITO TIMUR"
	replace regency = "MALANG REGENCY" if regency == "BATU"
	replace regency = "ASAHAN" if regency == "BATU BARA"
	replace regency = "BUTON" if regency == "BAU-BAU"
	replace regency = "BEKASI" if regency == "BEKASI CITY"
	replace regency = "BEKASI" if regency == "BEKASI REGENCY"
	replace regency = "BELITUNG" if regency == "BELITUNG TIMUR"
	replace regency = "ACEH TENGAH" if regency == "BENER MERIAH"
	replace regency = "SAMBAS" if regency == "BENGKAYANG"
	replace regency = "BENGKULU UTARA" if regency == "BENGKULU TENGAH"
	replace regency = "BIMA" if regency == "BIMA CITY"
	replace regency = "BIMA" if regency == "BIMA REGENCY"
	replace regency = "KEPULAUAN RIAU" if regency == "BINTAN"
	replace regency = "ACEH BARAT" if regency == "BIREUEN"
	replace regency = "GORONTALO REGENCY" if regency == "BOALEMO"
	replace regency = "BOLAANG MENGONDOW" if regency == "BOLAANG MONGONDOW"
	replace regency = "BOLAANG MENGONDOW" if regency == "BOLAANG MONGONDOW SELATAN"
	replace regency = "BOLAANG MENGONDOW" if regency == "BOLAANG MONGONDOW TIMUR"
	replace regency = "BOLAANG MENGONDOW" if regency == "BOLAANG MONGONDOW UTARA"
	replace regency = "BUTON" if regency == "BOMBANA"
	replace regency = "GORONTALO REGENCY" if regency == "BONE BOLANGO"
	replace regency = "KUTAI" if regency == "BONTANG"
	replace regency = "BULONGAN" if regency == "BULUNGAN"
	replace regency = "BUNGO TEBO" if regency == "BUNGO"
	replace regency = "BUOL TOLI-TOLI" if regency == "BUOL"
	replace regency = "MALUKU TENGAH" if regency == "BURU"
	replace regency = "MALUKU TENGAH" if regency == "BURU SELATAN"
	replace regency = "MUNA" if regency == "BUTON UTARA"
	replace regency = "SERANG" if regency == "CILEGON"
	replace regency = "BANDUNG REGENCY" if regency == "CIMAHI CITY"
	replace regency = "BENGKALIS" if regency == "D U M A I"
	replace regency = "BOGOR REGENCY" if regency == "DEPOK"
	replace regency = "SAWAH LUNTO" if regency == "DHARMASRAYA"
	replace regency = "LAHAT" if regency == "EMPAT LAWANG"
	replace regency = "ACEH TENGGARA" if regency == "GAYO LUES"
	replace regency = "GORONTALO REGENCY" if regency == "GORONTALO UTARA"
	replace regency = "KAPUAS" if regency == "GUNUNG MAS"
	replace regency = "NIAS" if regency == "GUNUNGSITOLI"
	replace regency = "HALMAHERA TENGAH" if regency == "HALMAHERA BARAT"
	replace regency = "HALMAHERA TENGAH" if regency == "HALMAHERA SELATAN"
	replace regency = "HALMAHERA TENGAH" if regency == "HALMAHERA TIMUR"
	replace regency = "HALMAHERA TENGAH" if regency == "HALMAHERA UTARA"
	replace regency = "TAPANULI UTARA" if regency == "HUMBANG HASUNDUTAN"
	replace regency = "KEPULAUAN RIAU" if regency == "KARIMUN"
	replace regency = "KOTAWARINGIN TIMUR" if regency == "KATINGAN"
	replace regency = "BENGKULU SELATAN" if regency == "KAUR"
	replace regency = "KETAPANG" if regency == "KAYONG UTARA"
	replace regency = "REJANG LEBONG" if regency == "KEPAHIANG"
	replace regency = "KEPULAUAN RIAU" if regency == "KEPULAUAN ANAMBAS"
	replace regency = "MALUKU TENGGARA" if regency == "KEPULAUAN ARU"
	replace regency = "PADANG PARIAMAN" if regency == "KEPULAUAN MENTAWAI"
	replace regency = "BENGKALIS" if regency == "KEPULAUAN MERANTI"
	replace regency = "SANGIHE TALAUD" if regency == "KEPULAUAN SANGIHE"
	replace regency = "JAKARTA UTARA" if regency == "KEPULAUAN SERIBU"
	replace regency = "HALMAHERA TENGAH" if regency == "KEPULAUAN SULA"
	replace regency = "SANGIHE TALAUD" if regency == "KEPULAUAN TALAUD"
	replace regency = "KOLAKA" if regency == "KOLAKA UTARA"
	replace regency = "KENDARI" if regency == "KONAWE"
	replace regency = "KENDARI" if regency == "KONAWE SELATAN"
	replace regency = "KENDARI" if regency == "KONAWE UTARA"
	replace regency = "BOLAANG MENGONDOW" if regency == "KOTAMOBAGU"
	replace regency = "INDRAGIRI HULU" if regency == "KUANTAN SINGINGI"
	replace regency = "PONTIANAK REGENCY" if regency == "KUBU RAYA"
	replace regency = "KUPANG REGENCY" if regency == "KUPANG CITY"
	replace regency = "KUTAI" if regency == "KUTAI BARAT"
	replace regency = "KUTAI" if regency == "KUTAI KARTANEGARA"
	replace regency = "KUTAI" if regency == "KUTAI TIMUR"
	replace regency = "LABUHAN BATU" if regency == "LABUHAN BATU SELATAN"
	replace regency = "LABUHAN BATU" if regency == "LABUHAN BATU UTARA"
	replace regency = "KOTAWARINGIN BARAT" if regency == "LAMANDAU"
	replace regency = "LAMPUNG TENGAH" if regency == "LAMPUNG TIMUR"
	replace regency = "PONTIANAK REGENCY" if regency == "LANDAK"
	replace regency = "ACEH TIMUR" if regency == "LANGSA"
	replace regency = "REJANG LEBONG" if regency == "LEBONG"
	replace regency = "FLORES TIMUR" if regency == "LEMBATA"
	replace regency = "ACEH UTARA" if regency == "LHOKSEUMAWE"
	replace regency = "LIMA PULUH KOTO" if regency == "LIMA PULUH KOTA"
	replace regency = "KEPULAUAN RIAU" if regency == "LINGGA"
	replace regency = "LOMBOK BARAT" if regency == "LOMBOK UTARA"
	replace regency = "MUSI RAWAS" if regency == "LUBUKLINGGAU"
	replace regency = "LUWU" if regency == "LUWU TIMUR"
	replace regency = "LUWU" if regency == "LUWU UTARA"
	replace regency = "UJUNG PANDANG" if regency == "MAKASSAR"
	replace regency = "BULONGAN" if regency == "MALINAU"
	replace regency = "MALUKU TENGGARA" if regency == "MALUKU BARAT DAYA"
	replace regency = "MALUKU TENGGARA" if regency == "MALUKU TENGGARA BARAT"
	replace regency = "POLEWALI MAMASA" if regency == "MAMASA"
	replace regency = "MAMUJU" if regency == "MAMUJU UTARA"
	replace regency = "TAPANULI SELATAN" if regency == "MANDAILING NATAL"
	replace regency = "MANGGARAI" if regency == "MANGGARAI BARAT"
	replace regency = "MANGGARAI" if regency == "MANGGARAI TIMUR"
	replace regency = "SINTANG" if regency == "MELAWI"
	replace regency = "SARKO (SAROLANGUN BANGKO" if regency == "MERANGIN"
	replace regency = "LAMPUNG UTARA" if regency == "MESUJI"
	replace regency = "LAMPUNG TENGAH" if regency == "METRO"
	replace regency = "MINAHASA" if regency == "MINAHASA SELATAN"
	replace regency = "MINAHASA" if regency == "MINAHASA TENGGARA"
	replace regency = "MINAHASA" if regency == "MINAHASA UTARA"
	replace regency = "POSO" if regency == "MOROWALI"
	replace regency = "BATANG HARI" if regency == "MUARO JAMBI"
	replace regency = "BENGKULU UTARA" if regency == "MUKOMUKO"
	replace regency = "BARITO UTARA" if regency == "MURUNG RAYA"
	replace regency = "MUSI BANYU ASIN" if regency == "MUSI BANYUASIN"
	replace regency = "ACEH BARAT" if regency == "NAGAN RAYA"
	replace regency = "NGADA" if regency == "NAGEKEO"
	replace regency = "KEPULAUAN RIAU" if regency == "NATUNA"
	replace regency = "NIAS" if regency == "NIAS BARAT"
	replace regency = "NIAS" if regency == "NIAS SELATAN"
	replace regency = "NIAS" if regency == "NIAS UTARA"
	replace regency = "BULONGAN" if regency == "NUNUKAN"
	replace regency = "OGAN KOMERING ILIR" if regency == "OGAN ILIR"
	replace regency = "OGAN KOMERING ULU" if regency == "OGAN KOMERING ULU SELATAN"
	replace regency = "OGAN KOMERING ULU" if regency == "OGAN KOMERING ULU TIMUR"
	replace regency = "TAPANULI SELATAN" if regency == "PADANG LAWAS"
	replace regency = "TAPANULI SELATAN" if regency == "PADANG LAWAS UTARA"
	replace regency = "TAPANULI SELATAN" if regency == "PADANGSIDIMPUAN"
	replace regency = "LAHAT" if regency == "PAGAR ALAM"
	replace regency = "DAIRI" if regency == "PAKPAK BHARAT"
	replace regency = "LUWU" if regency == "PALOPO"
	replace regency = "PANGKAJENE KEPULAUAN" if regency == "PANGKAJENE DAN KEPULAUAN"
	replace regency = "PADANG PARIAMAN" if regency == "PARIAMAN"
	replace regency = "DONGGALA" if regency == "PARIGI MOUTONG"
	replace regency = "PASAMAN" if regency == "PASAMAN BARAT"
	replace regency = "PASIR" if regency == "PASER"
	replace regency = "PEKAN BARU" if regency == "PEKANBARU"
	replace regency = "KAMPAR" if regency == "PELALAWAN"
	replace regency = "PASIR" if regency == "PENAJAM PASER UTARA"
	replace regency = "LAMPUNG SELATAN" if regency == "PESAWARAN"
	replace regency = "PIDIE" if regency == "PIDIE JAYA"
	replace regency = "GORONTALO REGENCY" if regency == "POHUWATO"
	replace regency = "POLEWALI MAMASA" if regency == "POLEWALI MANDAR"
	replace regency = "MUARA ENIM" if regency == "PRABUMULIH"
	replace regency = "LAMPUNG SELATAN" if regency == "PRINGSEWU"
	replace regency = "KAPUAS" if regency == "PULANG PISAU"
	replace regency = "HALMAHERA TENGAH" if regency == "PULAU MOROTAI"
	replace regency = "BENGKALIS" if regency == "ROKAN HILIR"
	replace regency = "KAMPAR" if regency == "ROKAN HULU"
	replace regency = "KUPANG REGENCY" if regency == "ROTE NDAO"
	replace regency = "BENGKALIS" if regency == "S I A K"
	replace regency = "KUPANG REGENCY" if regency == "SABU RAIJUA"
	replace regency = "TAPANULI UTARA" if regency == "SAMOSIR"
	replace regency = "SARKO (SAROLANGUN BANGKO" if regency == "SAROLANGUN"
	replace regency = "SANGGAU" if regency == "SEKADAU"
	replace regency = "BENGKULU SELATAN" if regency == "SELUMA"
	replace regency = "MALUKU TENGAH" if regency == "SERAM BAGIAN BARAT"
	replace regency = "MALUKU TENGAH" if regency == "SERAM BAGIAN TIMUR"
	replace regency = "SERANG" if regency == "SERANG CITY"
	replace regency = "SERANG" if regency == "SERANG REGENCY"
	replace regency = "DELI SERDANG" if regency == "SERDANG BEDAGAI"
	replace regency = "KOTAWARINGIN TIMUR" if regency == "SERUYAN"
	replace regency = "SANGIHE TALAUD" if regency == "SIAU TAGULANDANG BIARO"
	replace regency = "DONGGALA" if regency == "SIGI"
	replace regency = "SAWAHLUNTO/SIJUNJUNG" if regency == "SIJUNJUNG"
	replace regency = "ACEH BARAT" if regency == "SIMEULUE"
	replace regency = "SAMBAS" if regency == "SINGKAWANG"
	replace regency = "SOLOK REGENCY" if regency == "SOLOK SELATAN"
	replace regency = "ACEH SELATAN" if regency == "SUBULUSSALAM"
	replace regency = "KOTAWARINGIN BARAT" if regency == "SUKAMARA"
	replace regency = "SUMBA BARAT" if regency == "SUMBA BARAT DAYA"
	replace regency = "SUMBA BARAT" if regency == "SUMBA TENGAH"
	replace regency = "SUMBAWA" if regency == "SUMBAWA BARAT"
	replace regency = "KERINCI" if regency == "SUNGAI PENUH"
	replace regency = "BULONGAN" if regency == "TANA TIDUNG"
	replace regency = "KOTA BARU" if regency == "TANAH BUMBU"
	replace regency = "TANGERANG REGENCY" if regency == "TANGERANG SELATAN"
	replace regency = "LAMPUNG SELATAN" if regency == "TANGGAMUS"
	replace regency = "TANJUNG JABUNG" if regency == "TANJUNG JABUNG BARAT"
	replace regency = "TANJUNG JABUNG" if regency == "TANJUNG JABUNG TIMUR"
	replace regency = "KEPULAUAN RIAU" if regency == "TANJUNG PINANG"
	replace regency = "BULONGAN" if regency == "TARAKAN"
	replace regency = "TASIKMALAYA" if regency == "TASIKMALAYA CITY"
	replace regency = "TASIKMALAYA" if regency == "TASIKMALAYA REGENCY"
	replace regency = "BUNGO TEBO" if regency == "TEBO"
	replace regency = "MALUKU UTARA" if regency == "TERNATE"
	replace regency = "HALMAHERA TENGAH" if regency == "TIDORE KEPULAUAN"
	replace regency = "TAPANULI UTARA" if regency == "TOBA SAMOSIR"
	replace regency = "POSO" if regency == "TOJO UNA-UNA"
	replace regency = "BUOL TOLI-TOLI" if regency == "TOLI-TOLI"
	replace regency = "MINAHASA" if regency == "TOMOHON"
	replace regency = "TANA TORAJA" if regency == "TORAJA UTARA"
	replace regency = "MALUKU TENGGARA" if regency == "TUAL"
	replace regency = "LAMPUNG UTARA" if regency == "TULANG BAWANG BARAT"
	replace regency = "LAMPUNG UTARA" if regency == "TULANGBAWANG"
	replace regency = "BUTON" if regency == "WAKATOBI"
	replace regency = "LAMPUNG UTARA" if regency == "WAY KANAN"
		
	*****************
	
	merge m:1 regency using "$secdata/Compiled/supas_1995_regencies"
	keep if _merge == 3
	drop _merge
	sort supas95_rgcy_code susenas11_rgcy_code
	keep susenas11_rgcy_code supas95_rgcy_code
	
	save "$secdata/Compiled/susenas11_to_supas95_rgcy_key", replace
	
end
