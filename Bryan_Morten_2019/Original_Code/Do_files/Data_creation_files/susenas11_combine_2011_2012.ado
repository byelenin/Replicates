* Version 1: February 15, 2014 (Allan Hsiao)

program susenas11_combine_2011_2012

	use "$secdata/Compiled/susenas_2011", clear
	append using "$secdata/Compiled/susenas_2012"
	
	save "$secdata/Compiled/susenas_2011_2012", replace
	
	
	
end






