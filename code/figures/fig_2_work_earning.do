//do "../0_1_setup.do"


use "$data_gen/Pilot_3_MH_Census_Study.dta", clear


gen group = 1 if  work_home==0 & female==1 & participant_id!=member_id // treated_p always = 0 if work_in ==0
	replace group = 2 if  work_home==1 & female==1 & participant_id!=member_id
	replace group = 3 if  work_home==1 & female==1 & participant_id==member_id

gen one = 1
	drop if group ==.
	bysort group period: egen m = mean(work_income)
	bysort group period: egen sem = semean(work_income)  
	bysort group period: egen n = total(one)  

	keep m sem group period n
	duplicates drop

	gen 	l = m	-	1.96*sem 
	gen 	h = m	+	1.96*sem 

	gen x = period 
	replace x = x-.1 if group ==1
	replace x = x+.1 if group ==3

	twoway 	(scatter m x if group ==1, mcolor("206 17 38")) ///
				 	(scatter m x if group ==2, mcolor("252 209 22")) ///  
				 	(scatter m x if group ==3, mcolor("0 107 63"))  ///
					(rspike h l  x if group ==1, lcolor("206 17 38") ) ////
					(rspike h l  x if group ==2, lcolor("252 209 22")) ///
					(rspike h l  x if group ==3, lcolor("0 107 63")) ///
					, legend( ///
						size(small) ///
						order(1  "Not willing to work" 2 "Willing to work - no job offer" 3 "Willing to work  - job offer") ///
						col(3) position(6)) ///
	xtitle("") xlabel(0 "Baseline" 1 "PS1" 2 "PS2" 3 "PS3" 4 "PS4" 5 "PS5" 6 "Endline")
	
	
	// For easy finding
	graph export "$mh_figures/figure_2_imputed_scatter.pdf", replace
