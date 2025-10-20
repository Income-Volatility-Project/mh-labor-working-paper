//do "../0_1_setup.do"
*-------------------------------------------------------------------------------
* regression - census mental health and work willingness
* modified versions
*-------------------------------------------------------------------------------

// Original specification
// Additional control tables
local covariates head_and_spouse_present work_out_first  
local additional_controls num_adults_cs hh_size_cs  age_cs  married_cs 
local table_sample "respondent & female"
local table_controls `covariates' `additional_controls' 
local table_filename "$mh_tables/table_ab.1_mh_signup_cs_bl.tex"

est clear
use "$data_gen/Pilot_3_Census_Reshaped_Analysis.dta", clear

// Apply sample restrictions
keep if `table_sample'

qui foreach mental_measure of varlist phq2_z_cs gad2_z_cs phq2_gad2_average_cs {
    eststo `mental_measure'_1: reghdfe  work_out `mental_measure' `table_controls' , vce(robust) // absorb(community)
        su work_out, meanonly
        estadd scalar mean = r(mean)
}

// Regressions on sub-sample of phase 1 - phase 2 overlap
** load baseline data 
* MH per period - FE
use "$mh_data/Pilot_3_MH_Census_Study.dta", clear

keep if  period ==0 // keep baseline, drop follow up surveys

// Generate max edu years by hh_id
bysort hh_id: egen hh_max_education_years = max(education_years)
// Generate sums of work sectors
local work_sectors salaried_cs daily_labor_cs agriculture_cs small_firm_cs unpaid_labor_cs
local hh_work_sectors
foreach var of varlist `work_sectors' {
    bysort hh_id: egen hh_total_`var' = total(`var')
    local hh_work_sectors `hh_work_sectors' hh_total_`var'
}



// Replace missing with 0 for regression
replace money_earn_ = 0 if !work_engaged_
replace days_worked_ = 0 if !work_engaged_
winsor2 work_income money_earn_, cuts(0 95) suffix(_w)
rename money_earn__w money_earn_w
keep if participant
* Select only people who were the census respondent
keep if resp_ind == participant_id

/* 2 = same specification as table 5, but with the overlapping sub-sample
3 = same as 2 + household size, the number of adults, and the participant’s age and marital status */
local cov2 `table_controls'
// 4 = same as 2 +participant’s years of education,  and sector of past employment,. total value of the household’s assets, and an index of household wealth.
local cov3 education_years hh_max_education_years total_assets_bl wealth_index `work_sectors' `hh_work_sectors' risk cfcs
*/ 5 = same as 2 + death of a relative, loss of livestock, other accident, job loss, natural disasters, and expenses linked to religious events and a measure of available social support (the ‘Multidimensional Scale Of Perceived Social Support’)
local cov4 shock_death_relative shock_death_livestock shock_accident shock_job_loss shock_natural_disaster shock_religious_event shock_costs mspss_total_z body_weight 
// 6 = same as 2 + an index of food security, an index of dietary diversity, the participant’s body weight
local cov5 food_insecurity_index hdds_z body_weight     //dietary_diversity_index 
// 7 - all the controls from 2-6
local cov6 `cov2' `cov3' `cov4' `cov5'

qui foreach mental_measure of varlist phq2_z_cs gad2_z_cs phq2_gad2_average_cs{
    forvalues i=2/6 {
        eststo `mental_measure'_`i': reghdfe  work_out `mental_measure' `cov`i''  , vce(robust) 
            su work_out, meanonly
            estadd scalar mean = r(mean)
    }
}

local scalar_option scalars("mean Dep. Var. Mean" "N Observations") sfmt("a2") noobs
local scalar_option_none scalars() noobs
// local scalar_option_top scalars("mean Dep. Var. Mean") sfmt("a2") noobs
// local scalar_option_footer scalars("mean Dep. Var. Mean" "N Observations") sfmt("a2") noobs

    // Panel A - PHQ2
    esttab phq2_z_cs* using "`table_filename'",  ///
            $format_options `scalar_option_none' $header_options keep(phq2_z_cs) ///
            posthead("\midrule & \multicolumn{6}{c}{\textbf{Willingness to work outside the home}} \\ \midrule")

    // Panel B - GAD2
    esttab gad2_z_cs* using "`table_filename'", ///
        keep(gad2_z_cs) `scalar_option_none' $format_options $segment_options ///
        posthead(" ")

    // Panel C - PHQ2 GAD2 index
    esttab phq2_gad2_average_cs* using "`table_filename'", ///
        keep(phq2_gad2_average_cs) `scalar_option' $format_options $footer_options ///
        posthead(" ")
	