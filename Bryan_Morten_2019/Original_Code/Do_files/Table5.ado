program define Table5

	*! Source file: GE_selection_table_21Jan2018
	
	local esttype nonparam
	local multreduction 1
	local etatype 0

	* Update the 4 experiments just once, does it for all the tables
	global mlabel "Mig costs" "Amenities" "Mig costs, amenities"
	
	local educ all
	local dum_deletehc 

	local country ind

	use $secdata/Public/GE_dataset_`esttype'_`etatype', clear

	keep if zero_tc == 0
	keep if region == 1
	drop if year == 1976
	keep if parameters == 1
	keep if dum_deletehc == 0
	*keep if mult == 0
	replace mult_reduction = round(mult_reduction, 0.01)
	keep if mult_reduction == float(`multreduction')
			
	
	* We want to make a table with output gains, with and without selection
	* Will be easier to make it wide so can do US and Indonesia in one command
	* Can get rid of year

	collapse relative_GDP, by(country vartype dum_no_selection)

	reshape wide relative_GDP, i(vartype dum_no_selection) j(country) string
	reshape wide relative_GDPind relative_GDPus, i(vartype) j(dum_no_selection)

	quicktab relative_GDP* if vartype == 1
	eststo mig_cost

	quicktab relative_GDP* if vartype == 2
	eststo lambda_a

	quicktab relative_GDP* if vartype == 3
	eststo lambda_a_amenities
		
	quicktab relative_GDP* if vartype == 4
	eststo all
		
		
	label var relative_GDPind1 "No selection"
	label var relative_GDPind0 "Baseline"
	label var relative_GDPus1 "No selection"
	label var relative_GDPus0 "Baseline"

	local multreductionx = 100*`multreduction'

	if "`esttype'" == "nonparam" {
		local title2 Baseline
		}
	else if "`esttype'" == "dist" {
		local title "(Robustness: Distance)"
		local title2 "Migration costs parameteric fn. of distance"
		}
	else if "`esttype'" == "dist_asymmetric" {
		local title "(Robustness: Distance, lg pop interaction)"
		local title2 "Migration costs parameteric fn. of distance, lg pop interaction"
		}
	
	estout mig_cost lambda_a_amenities all using "$outpath/table_selection_policy_reduce`multreductionx'_`esttype'_`etatype'.tex", replace cells(b(fmt(3))) mlabel("$mlabel") collabels(,none) number style(melanie_fancy) label varlabels(,blist(relative_GDPind0 "\multicolumn{@span}{l}{\emph{Indonesia}} \\" relative_GDPus0 "\multicolumn{@span}{l}{\emph{US}} \\")) order(relative_GDPind0 relative_GDPind1 relative_GDPus0 relative_GDPus1) title("Output gain from reducing migration barriers `title'`title_dum_deletehc'") note("Table shows the output gain from removing the barrier completely. Data is 1995, 2011, 2012 for Indonesia; 1990 and 2010 for the US. No selection recalculates the output gain shutting down the role for comparative advantage.") drop(relative_GDPus*)

		
end
