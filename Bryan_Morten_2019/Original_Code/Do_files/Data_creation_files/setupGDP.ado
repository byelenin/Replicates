program setupGDP

	*! This program sets up GDP
	
	insheet using "$rawdata/World Bank GDP data/gdp.csv", comma clear
	
	rename gdp_percap_indonesia gdp_percap_ind
	
	adjust_inflation gdp_percap_ind, year(1) country(ind)
	drop cpi*
	adjust_inflation gdp_percap_us, year(1) country(us)
	drop cpi*

	gen gdp_percap_ind_usd = gdp_percap_ind*0.00011 //this using xe.com rate for 2010, 1 million approx $110 2010 USD//

	save $secdata/Compiled/gdp, replace
	


end



	

	
