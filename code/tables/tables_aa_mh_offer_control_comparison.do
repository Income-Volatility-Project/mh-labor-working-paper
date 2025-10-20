//do "../0_1_setup.do"
*-------------------------------------------------------------------------------
* regression - census mental health and work willingness
* modified versions
*-------------------------------------------------------------------------------

// Define common set of covariates for every table
local covariates head_and_spouse_present work_out_first  
local additional_controls num_adults_cs hh_size_cs  age_cs  married_cs 
// local cov_cs_soc_norm speak_badly_unmarr speak_badly_marr resp_decides_work_out
local cov_cs_ses head spouse child sibling grand_child parent child_in_law  log_total_meal	employed_cs salaried_cs daily_labor_cs self_employed_cs help_hh_enterprise_cs help_hh_farm_cs livestock_cs wage_work_cs small_firm_cs  nkids nsmallkids

local table7_filename "$mh_tables/table_aa.7_mh_signup_cov1.tex"
local table7_sample  "respondent & female"
local table7_mental_vars $census_mental
local table7_controls `covariates' `additional_controls' 

local scalar_option_top scalars("mean Dep. Var. Mean") sfmt("a2") noobs
local scalar_option_footer scalars("mean Dep. Var. Mean" "p p-value: W.f. Home  == W. outside" "N Observations") sfmt("a2") noobs

local table table7

foreach table in table7 {
  est clear
  use "$data_gen/Pilot_3_Census_Reshaped_Analysis.dta", clear

  // Apply sample restrictions
  keep if ``table'_sample'

  label var work_out_first "Outside question asked first"

  local counter 1

  foreach mental_measure of varlist ``table'_mental_vars' {
      eststo h_`counter' : reg  work_home `mental_measure' ``table'_controls'
      eststo o_`counter'  : reg  work_out `mental_measure' ``table'_controls'

      suest  h_`counter' o_`counter'
          test [o_`counter'_mean]`mental_measure'  -  [h_`counter'_mean]`mental_measure' = 0
          local diff_test_p = r(p)

      eststo home_`counter' : reghdfe  work_home `mental_measure' ``table'_controls' , vce(robust)  
          su work_home, meanonly
          estadd scalar mean = r(mean)
          estadd scalar p = `diff_test_p'
          
      eststo out_`counter'  : reghdfe  work_out `mental_measure' ``table'_controls', vce(robust) 
          su work_out, meanonly
          estadd scalar mean = r(mean)
          estadd scalar p = `diff_test_p'

      local counter = `counter' + 1

      eststo h_`counter' : reg  work_home `mental_measure' ``table'_controls' `cov_cs_ses'
      eststo o_`counter'  : reg  work_out `mental_measure' ``table'_controls' `cov_cs_ses'

      suest  h_`counter' o_`counter'
          test [o_`counter'_mean]`mental_measure'  -  [h_`counter'_mean]`mental_measure' = 0
          local diff_test_p = r(p)

      eststo home_`counter' : reghdfe  work_home `mental_measure' ``table'_controls' `cov_cs_ses', vce(robust)  
          su work_home, meanonly
          estadd scalar mean = r(mean)
          estadd scalar p = `diff_test_p'
          
      eststo out_`counter'  : reghdfe  work_out `mental_measure' ``table'_controls' `cov_cs_ses', vce(robust) 
          su work_out, meanonly
          estadd scalar mean = r(mean)
          estadd scalar p = `diff_test_p'

      local counter = `counter' + 1

  }

    // Panel A - Work From Out
    esttab out_* using "``table'_filename'",  ///
            $format_options `scalar_option_top' $header_options keep(``table'_mental_vars') ///
            order(``table'_mental_vars') ///
            posthead("\midrule \multicolumn{@span}{c}{\textbf{Willingness to work outside}} \\ \midrule")

    // Panel B - Work from Home
    esttab home_* using "``table'_filename'", ///
        keep(``table'_mental_vars' ) `scalar_option_footer' $format_options $footer_options ///
        order(``table'_mental_vars') ///
        posthead("\multicolumn{@span}{c}{\textbf{Willingness to work from home}} \\ \midrule")
  }