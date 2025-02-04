//do "../0_1_setup.do"
*-------------------------------------------------------------------------------
* regression - census mental health and work willingness
*-------------------------------------------------------------------------------

// Define common set of covariates for every table
local covariates work_out_first head_and_spouse_present 

// Define table specifications
local table1_filename "$mh_tables/table_a.1_mh_signup.tex"
local table1_sample "respondent & female"
local table1_mental_vars $census_mental
local table1_controls `covariates'

local table2_filename "$mh_tables/table_a.2_mh_signup_others.tex"
local table2_sample "!respondent & female & respondent_female"
local table2_mental_vars $census_mental
local table2_controls `covariates'

local table3_filename "$mh_tables/table_a.3_mh_signup.tex"
local table3_sample "respondent & female"
local table3_mental_vars $census_mental_appendix
local table3_controls `covariates' `additional_controls'

local table4_filename "$mh_tables/table_a.4_mh_signup_others.tex"
local table4_sample "!respondent & female & respondent_female"
local table4_mental_vars $census_mental_appendix
local table4_controls `covariates' `additional_controls'

local additional_controls num_adults_cs hh_size_cs  age_cs  married_cs 
// local community_fe        absorb(community)

// Additional control tables
local table5_filename "$mh_tables/table_a.5_mh_signup.tex"
local table5_sample "respondent & female"
local table5_mental_vars $census_mental
local table5_controls `covariates' `additional_controls'
local table5_fe `community_fe'

local table6_filename "$mh_tables/table_a.6_mh_signup_others.tex"
local table6_sample "!respondent & female & respondent_female"
local table6_mental_vars $census_mental
local table6_controls `covariates' `additional_controls'
local table6_fe `community_fe'

local scalar_option_top scalars("mean Dep. Var. Mean") sfmt("a2") noobs
local scalar_option_footer scalars("mean Dep. Var. Mean" "p p-value: W.f. Home  == W. outside" "N Observations") sfmt("a2") noobs

foreach table in table1 table2 table3 table4 table5 table6 {
    est clear
    use "$data_gen/Pilot_3_Census_Reshaped_Analysis.dta", clear
    
    // Apply sample restrictions
    keep if ``table'_sample'
    
    local counter 1
    foreach mental_measure of varlist ``table'_mental_vars' {
        eststo h_`counter' : reg  work_home `mental_measure' ``table'_controls'
        eststo o_`counter'  : reg  work_out `mental_measure' ``table'_controls'

        suest  h_`counter' o_`counter'
            test [o_`counter'_mean]`mental_measure'  -  [h_`counter'_mean]`mental_measure' = 0
            local diff_test_p = r(p)

        eststo home_`counter' : reghdfe  work_home `mental_measure' ``table'_controls', vce(robust) ``table'_fe'
            su work_home, meanonly
            estadd scalar mean = r(mean)
            
        eststo out_`counter'  : reghdfe  work_out `mental_measure' ``table'_controls', vce(robust) ``table'_fe'
            su work_out, meanonly
            estadd scalar mean = r(mean)
            estadd scalar p = `diff_test_p'

        local counter = `counter' + 1
    }

    // Panel A - Work From Home
    esttab home_* using "``table'_filename'",  ///
            $format_options `scalar_option_top' $header_options drop(_cons `covariates' ``table'_controls') ///
            posthead("\midrule \multicolumn{@span}{c}{\textbf{Willingness to work from home}} \\ \midrule")

    // Panel B - Work from Site
    esttab out_* using "``table'_filename'", ///
        drop(_cons `covariates' ``table'_controls') `scalar_option_footer' $format_options $footer_options ///
        posthead("\multicolumn{@span}{c}{\textbf{Willingness to work outside}} \\ \midrule")
}

