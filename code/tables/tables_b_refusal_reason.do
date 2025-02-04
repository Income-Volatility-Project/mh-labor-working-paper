//do "../0_1_setup.do"


*-------------------------------------------------------------------------------
* regression - census mental health and work willingness
*-------------------------------------------------------------------------------
use "$mh_data/Pilot_3_Census_Reshaped_Analysis.dta", clear
	// Rename vars for reshape
	local refusal_vars
	forvalues i=1/10 {
		rename work_home_refusal_reason_`i' refusal_reason_`i'_0
		rename work_out_refusal_reason_`i' 	refusal_reason_`i'_1
		local refusal_vars `refusal_vars' refusal_reason_`i'_
	}
	rename work_out_refusal_reason_11 	refusal_reason_11_1

	// Reshape so data is at the work-offer level
	rename work_home 	work0
	rename work_out 	work1
	reshape long work `refusal_vars' refusal_reason_11_, i(hh_id member_id) j(work_out)

 	// 11 is travel safety which is missing for the WFH offers
	// replace refusal_reason_11_ = 0 if !work_out

 	// Drop all acceptances
	drop if work
	// Create pooled reason vars
	gen reason_1 = refusal_reason_1_
	// 3 = Child Care, 4 = Household Work
	gen reason_2 = refusal_reason_3_ | refusal_reason_4_
	// 5 = do not want this job, 6 = too old or sick
	gen reason_3 = refusal_reason_5_ | refusal_reason_6_
	gen reason_4 = refusal_reason_10_
	// 11 -> travel safety; 
	// jump so loops are cleaner as 6 will only be relevant for others, not self
	gen reason_5 = refusal_reason_11_
	// 7 -> Not sure if they would be interested
	gen reason_6 = refusal_reason_7_
	// 7 (2) and 8 are never citied
	// They are: 	- Not allowed
	// 						- Cannot make decision for person
	gen reason_7 = refusal_reason_2_
	gen reason_8 = refusal_reason_8_
	
	label var reason_1 "Have work"
	label var reason_2 "Household work"
	label var reason_3 "Unable or unwilling"
	label var reason_4 "Student"
	label var reason_5 "Transportation"
	label var reason_6 "Not sure if person is interested"
	
	local cov  work_out_first head_and_spouse_present 

 // Scalar option for showing proportion of refusals
	local scalar_option noobs scalars("prop Reason Share" "N Observations")

*-------------------------------------------------------------------------------
* refusal reason for self
*-------------------------------------------------------------------------------
	// We need to use different esttab commands for the different 
	// orders of the regressions
	local reg_index 1
	// Store the number of mental health measures used
	// so code can know how to contruct the table
	local last_index 3
	preserve 
		keep if respondent & female
		// For each of the chosen mental health measures
		// run regression prediciting the reason of refusal
		// and pick the table option based on whether
		// it was the first, last or one of the middle regressions
		// to appear in the table
	foreach mental_measure of varlist $census_mental {
		est clear
		forvalues reason=1/5 {
				eststo: reghdfe reason_`reason' `mental_measure' 	`cov', 	vce(cluster hh_id)
				 	// Add proportion of times each reason is cited
					su reason_`reason' if e(sample)
					estadd scalar prop = r(mean)
		}
		// Pick table options
		// differs for table header, footer or middle section
		di "Counter is `reg_index'"

  	// Header part of the table
		if `reg_index' == 1 {
			esttab est* using "$mh_tables/table_b.1_mh_signup_reason.tex", ///
				postfoot(" ") prefoot(" ") $results_format noobs depvar drop(`cov' _cons) ///
				collabels(, none) replace
		}  
		else if `reg_index' != `last_index'  {
			// Middle Part
			esttab est* using "$mh_tables/table_b.1_mh_signup_reason.tex", ///
					$format_options fragment $no_footer $no_header append noobs ///
					drop(`cov' _cons) nonumber 
		}
		else {
			// Footer
			esttab est* using "$mh_tables/table_b.1_mh_signup_reason.tex", ///
				$format_options $footer_options `scalar_option' drop(`cov' _cons) posthead(" ")
		}
		// Increment our counter
		local reg_index = `reg_index' + 1
	}
	restore

*-------------------------------------------------------------------------------
* refusal reason for others
*-------------------------------------------------------------------------------
	// Re-run regressions 
	preserve
	// Other female people in the household
	keep if !respondent & female & respondent_female
	// We need to use different esttab commands for the different 
	// orders of the regressions
	local reg_index 1
	// Store the number of mental health measures used
	// so code can know how to contruct the table
	local last_index 3
	// For each of the chosen mental health measures
		// run regression prediciting the reason of refusal
		// and pick the table option based on whether
		// it was the first, last or one of the middle regressions
		// to appear in the table
	foreach mental_measure of varlist $census_mental {
		est clear
		forvalues reason=1/6 {
				eststo: reghdfe reason_`reason' `mental_measure' 	`cov', 	vce(cluster hh_id)
		}
		if `reg_index' == 1 {
			esttab est* using "$mh_tables/table_b.2_mh_signup_reason_other.tex", ///
				$no_footer $results_format noobs depvar drop(`cov' _cons) replace collabels(, none)
		}  
		else {
			esttab est* using "$mh_tables/table_b.2_mh_signup_reason_other.tex", ///
					$format_options fragment $no_footer append noobs ///
					drop(`cov' _cons) nonumber $no_header
		}
		// Increment our counter
		local reg_index = `reg_index' + 1
	}
	


	// Reset counter
	local reg_index 1
	// Re run all regressions but with small kids as a control
	foreach mental_measure of varlist $census_mental {
		est clear
		forvalues reason=1/6 {
				eststo: reghdfe reason_`reason' `mental_measure' nsmallkids `cov', 	vce(cluster hh_id)
				 	// Compute share of times this reason is cited
					su reason_`reason' if e(sample)
					estadd scalar prop = r(mean)

		}
		// First result after previous regressions, add separator and text
		if `reg_index' == 1 {
			esttab est* using "$mh_tables/table_b.2_mh_signup_reason_other.tex", ///
				$no_footer $format_options prehead("\midrule") drop(`cov' _cons) ///
				posthead("\multicolumn{@span}{c}{\textbf{Controlling for number of children}} \\ \midrule") ///
				append nonumber noobs
		}
		else if `reg_index' != `last_index' {
			esttab est* using "$mh_tables/table_b.2_mh_signup_reason_other.tex", ///
				$segment_options $format_options noobs drop(`cov' _cons)
				 
		}  
		else {
			esttab est* using "$mh_tables/table_b.2_mh_signup_reason_other.tex", ///
				$format_options $footer_options `scalar_option' drop(`cov' _cons) posthead(" ")
		}
		// Increment our counter
		local reg_index = `reg_index' + 1
		di "Counter is `reg_index'"
	}
	restore