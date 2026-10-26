program define setup_struct_data

	*! Source file: setup_struct_data_19Nov2017

	local educ all

	foreach country in ind us {
		
		foreach time in _month _hour {

			if "`country'" == "us" {
				use "$structpath/Allan Structural Datasets/struct_dataset_us_state_emp_educ_`educ'", clear
				}
			else if "`country'" == "ind" {
				use "$structpath/Allan Structural Datasets/struct_dataset_ind_prov_emp_educ_`educ'", clear
				}

			replace wage`time'_ig = . if wage`time'_ig == 0
			replace prob = 0 if wage`time'_ig == . //will make it consistent//
			
			replace people_nowt = 0 if wage`time'_ig == .
			replace people_wt = 0 if wage`time'_ig == .

			assert people_nowt == 0 if prob == 0 //checking no issues//
			
			gen temp = 1
			bys pair_id year: egen count = total(temp)

			gen dum_missing = (wage`time'_ig == .)
			bys pair_id year: egen count_missing = total(dum_missing) //add in this "count missing" so we can differentiate between where it's not there for either vs it's not there just for one//

			replace count_missing = . if (i==g)

			gen N_ig = prob*L_0

			sort year g i //need to sort because order matters in Matlab//
			
			assert birth_distance !=.

			outsheet year i g prob_ig wage`time'_ig var_mean`time'_ig L_0 L_1 N_ig count_missing pair_id people_wt people_nowt birth_distance avg_wage_month_i dum_lg_pop using "$structpath/data/prov_data_matlab_`country'`time'_educ_`educ'.csv", comma nolabel nonames replace
				
			}
		}

end


