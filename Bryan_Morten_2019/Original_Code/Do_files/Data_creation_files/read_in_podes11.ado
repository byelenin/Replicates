program read_in_podes11

	insheet using "$rawdata/PODES/2011/podes_desa_2011_d2.csv", clear
	tempfile podes_desa_2
	save `podes_desa_2'
	
	insheet using "$rawdata/PODES/2011/podes_desa_2011_d3.csv", clear
	tempfile podes_desa_3
	save `podes_desa_3'
	
	insheet using "$rawdata/PODES/2011/podes_desa_2011_d1.csv", clear
	merge 1:1 kode_prov kode_kab kode_kec kode_desa using `podes_desa_2'
	drop _merge
	merge 1:1 kode_prov kode_kab kode_kec kode_desa using `podes_desa_3'
	drop _merge
	
	save "$secdata/PODES/podes_2011_raw.dta", replace	

end
