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
// Additional SES controls requested by reviewer; coped from table aa
local cov_cs_ses head spouse child sibling grand_child parent child_in_law  log_total_meal	employed_cs salaried_cs daily_labor_cs self_employed_cs help_hh_enterprise_cs help_hh_farm_cs livestock_cs wage_work_cs small_firm_cs  nkids nsmallkids

est clear
use "$data_gen/Pilot_3_Census_Reshaped_Analysis.dta", clear

// Apply sample restrictions
keep if `table_sample'

qui foreach mental_measure of varlist phq2_z_cs gad2_z_cs phq2_gad2_average_cs {
    // Regression naming scheme
    // f -> indicates full sample
    // o -> indicates work out
    // h -> indicates work home

    // Save covariates in a single macro for re-use and to avoid drift
    local covs `mental_measure' `table_controls'

    // Run p-value test
    eststo h_1 : reg  work_home `covs'
    eststo o_1  : reg  work_out `covs'

    suest  h_1 o_1
        test [o_1_mean]`mental_measure'  -  [h_1_mean]`mental_measure' = 0
        local diff_test_p = r(p)


    eststo `mental_measure'_fo_1: reghdfe  work_out  `covs', vce(robust) // absorb(community)
        su work_out, meanonly
        estadd scalar mean = r(mean)
        estadd scalar p = `diff_test_p'

    eststo `mental_measure'_fh_1: reghdfe  work_home `covs' , vce(robust) // absorb(community)
        su work_home, meanonly
        estadd scalar mean = r(mean)
        estadd scalar p = `diff_test_p'

}

// Second set of regressions with additional SES controls
qui foreach mental_measure of varlist phq2_z_cs gad2_z_cs phq2_gad2_average_cs {
    // Regression naming scheme; see above for more definitions
    // h -> indicates work home
    local covs `mental_measure' `table_controls' `cov_cs_ses'
     // Run p-value test
    eststo h_2 : reg  work_home `covs'
    eststo o_2  : reg  work_out `covs'
    suest  h_2 o_2
        test [o_2_mean]`mental_measure'  -  [h_2_mean]`mental_measure' = 0
        local diff_test_p = r(p)

    eststo `mental_measure'_fo_2: reghdfe  work_out `covs' , vce(robust) // absorb(community)
        su work_out, meanonly
        estadd scalar mean = r(mean)
        estadd scalar p = `diff_test_p'

    eststo `mental_measure'_fh_2: reghdfe  work_home `covs', vce(robust) // absorb(community)
        su work_home, meanonly
        estadd scalar mean = r(mean)
        estadd scalar p = `diff_test_p'
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
local cov1 `table_controls'
// 4 = same as 2 +participant’s years of education,  and sector of past employment,. total value of the household’s assets, and an index of household wealth.
local cov2 education_years hh_max_education_years total_assets_bl wealth_index `work_sectors' `hh_work_sectors' risk cfcs
*/ 5 = same as 2 + death of a relative, loss of livestock, other accident, job loss, natural disasters, and expenses linked to religious events and a measure of available social support (the ‘Multidimensional Scale Of Perceived Social Support’)
local cov3 shock_death_relative shock_death_livestock shock_accident shock_job_loss shock_natural_disaster shock_religious_event shock_costs mspss_total_z body_weight 
// 6 = same as 2 + an index of food security, an index of dietary diversity, the participant’s body weight
local cov4 food_insecurity_index hdds_z body_weight     //dietary_diversity_index 
// 7 - all the controls from 2-6
local cov5 `cov2' `cov3' `cov4' `cov5'

qui foreach mental_measure of varlist phq2_z_cs gad2_z_cs phq2_gad2_average_cs{
    forvalues i=1/5 {
        // s -> indicates sub-sample
        // see prior loop for definition of other suffixes
        eststo `mental_measure'_so_`i': reghdfe  work_out `mental_measure' `cov`i''  , vce(robust) 
            su work_out, meanonly
            estadd scalar mean = r(mean)

        eststo `mental_measure'_sh_`i': reghdfe  work_home `mental_measure' `cov`i''  , vce(robust) 
            su work_home, meanonly
            estadd scalar mean = r(mean)

    }
}

local table_filename "$mh_tables/table_ab.1_mh_signup_cs_bl.tex"
local scalar_option scalars("mean Dep. Var. Mean" "N Observations") sfmt("a2") noobs
local scalar_option_none scalars() noobs
// local scalar_option_top scalars("mean Dep. Var. Mean") sfmt("a2") noobs
// local scalar_option_footer scalars("mean Dep. Var. Mean" "N Observations") sfmt("a2") noobs

    // Panel A - PHQ2
    esttab phq2_z_cs_fo_1 phq2_z_cs_so_*  using "`table_filename'",  ///
            $format_options `scalar_option_none' $header_options keep(phq2_z_cs) ///
            posthead("\midrule & \multicolumn{6}{c}{\textbf{Willingness to work outside the home}} \\ \midrule")

    // Panel B - GAD2
    esttab gad2_z_cs_fo_1 gad2_z_cs_so_*  using "`table_filename'", ///
        keep(gad2_z_cs) `scalar_option_none' $format_options $segment_options ///
        posthead(" ")

    // Panel C - PHQ2 GAD2 index
    esttab phq2_gad2_average_cs_fo_1 phq2_gad2_average_cs_so_* using "`table_filename'", ///
        keep(phq2_gad2_average_cs) `scalar_option' $format_options $footer_options ///
        posthead(" ")
	
local table_filename "$mh_tables/table_ab.2_mh_signup_cs_bl.tex"
/// Make 2nd R&R requested version of this table; identical expect columns 2 now is from Table A.4's column 2
    // Panel A - PHQ2
    esttab phq2_z_cs_fo_* phq2_z_cs_so_*  using "`table_filename'",  ///
            $format_options `scalar_option_none' $header_options keep(phq2_z_cs) ///
            posthead("\midrule & \multicolumn{6}{c}{\textbf{Willingness to work outside the home}} \\ \midrule")

    // Panel B - GAD2
    esttab gad2_z_cs_fo_* gad2_z_cs_so_*  using "`table_filename'", ///
        keep(gad2_z_cs) `scalar_option_none' $format_options $segment_options ///
        posthead(" ")

    // Panel C - PHQ2 GAD2 index
    esttab phq2_gad2_average_cs_fo_* phq2_gad2_average_cs_so_* using "`table_filename'", ///
        keep(phq2_gad2_average_cs) `scalar_option' $format_options $footer_options ///
        posthead(" ")


local table_filename "$mh_tables/table_ab.3_mh_signup_cs_bl.tex"
local scalar_option scalars("mean Dep. Var. Mean" "N Observations") sfmt("a2") noobs
local scalar_option_none scalars() noobs
local scalar_option_top scalars("mean Dep. Var. Mean") sfmt("a2") noobs
local scalar_option_footer scalars("mean Dep. Var. Mean" "N Observations") sfmt("a2") noobs
/// Make 2nd R&R requested version of this table; identical expect columns 2 now is from Table A.4's column 2
    esttab phq2_z_cs_fo_* phq2_z_cs_so_*  using "`table_filename'",  ///
            $format_options `scalar_option_none' $header_options keep(phq2_z_cs) ///
            posthead("\midrule & \multicolumn{6}{c}{\textbf{Willingness to work outside the home}} \\ \midrule")

    esttab gad2_z_cs_fo_* gad2_z_cs_so_*  using "`table_filename'", ///
        keep(gad2_z_cs) `scalar_option_none' $format_options $segment_options ///
        posthead(" ")

    esttab phq2_gad2_average_cs_fo_* phq2_gad2_average_cs_so_* using "`table_filename'", ///
        keep(phq2_gad2_average_cs) `scalar_option_top' $format_options $segment_options ///
        posthead(" ")

    esttab phq2_z_cs_fh_* phq2_z_cs_sh_*  using "`table_filename'",  ///
            $format_options `scalar_option_none' $segment_options keep(phq2_z_cs) ///
            posthead("\midrule & \multicolumn{6}{c}{\textbf{Willingness to work from home}} \\ \midrule")

    esttab gad2_z_cs_fh_* gad2_z_cs_sh_*  using "`table_filename'", ///
        keep(gad2_z_cs) `scalar_option_none' $format_options $segment_options ///
        posthead(" ")

    esttab phq2_gad2_average_cs_fh_* phq2_gad2_average_cs_sh_* using "`table_filename'", ///
        keep(phq2_gad2_average_cs) `scalar_option_footer' $format_options $footer_options ///
        posthead(" ")
