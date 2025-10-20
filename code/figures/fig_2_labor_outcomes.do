use "$data_gen/Pilot_3_MH_Census_Study.dta", clear

local color_1 "gs2"
local color_2 "eltblue"
local color_3 "dknavy"

set scheme plotplain

gen productivity = work_income / days_worked_ 
count if missing(productivity) 
count

label var work_income "Work income (cedis)"
label var productivity "Productivity (work income / days worked)"
label var days_worked_ "Days worked"
label var work_engaged_ "Working"
label var worked_imputed "Working"

foreach var in days_worked_ worked_imputed work_income work_engaged_ productivity {
	preserve
		gen group = 1 if  work_home==0 & female==1 & participant_id!=member_id // treated_p always = 0 if work_in ==0
		replace group = 2 if  work_home==1 & female==1 & participant_id!=member_id
		replace group = 3 if  work_home==1 & female==1 & participant_id==member_id

		gen one = 1
		drop if group ==.
		bysort group period: egen m = mean(`var')
		bysort group period: egen sem = semean(`var')  
		bysort group period: egen n = total(one)  
		// Variable label
		local var_label : variable label `var'

		keep m sem group period n
		duplicates drop

		gen 	l = m	-	1.96*sem 
		gen 	h = m	+	1.96*sem 

		gen x = period 
		replace x = x-.1 if group ==1
		replace x = x+.1 if group ==3

		twoway 	(scatter m x if group ==1, mcolor(`color_1')) ///
						(scatter m x if group ==2, mcolor(`color_2')) ///  
						(scatter m x if group ==3, mcolor(`color_3'))  ///
						(rspike h l  x if group ==1, lcolor(`color_1') ) ////
						(rspike h l  x if group ==2, lcolor(`color_2')) ///
						(rspike h l  x if group ==3, lcolor(`color_3')) ///
						, legend( ///
							size(small) ///
							order(1  "Not willing to work" 2 "Willing to work - no job offer" 3 "Willing to work  - job offer") ///
							col(3) position(6)) ///
						xtitle("") xlabel(0 "Baseline" 1 "PS1" 2 "PS2" 3 "PS3" 4 "PS4" 5 "PS5" 6 "Endline") ///
						title("`var_label'") name("figure_b_`var'", replace)
		
		
		// For easy finding
		graph export "$mh_figures/fig_2_`var'.pdf", replace
	restore
}

// Two panel figure with days_worked_ and work_engaged_
grc1leg2 figure_b_work_engaged_ figure_b_days_worked_ ,  xsize(7.5) legscale(3)
graph export "$mh_figures/fig_2_2_panel.pdf", replace 
graph export "$mh_figures/fig_2_2_panel.jpg", replace 

/// Three panel figure with work_income days_worked_ and work_engaged_
grc1leg2 figure_b_work_engaged_ figure_b_days_worked_ , xsize(15) legscale(3) rows(1) name(fig_2_3_panel, replace)
grc1leg2 fig_2_3_panel figure_b_work_income, xsize(7.5) legscale(2) cols(1) name(fig_2_3_panel, replace)
graph export "$mh_figures/fig_2_3_panel_stacked.pdf", replace 
graph export "$mh_figures/fig_2_3_panel_stacked.jpg", replace width(1920) height(1080) 

grc1leg2 figure_b_work_engaged_ figure_b_days_worked_ figure_b_work_income , xsize(7.5) ysize(10) legscale(2) cols(1) iscale(0.75)
graph export "$mh_figures/fig_2_3_panel.pdf", replace 
graph export "$mh_figures/fig_2_3_panel.jpg", replace height(1920) width(1080) 