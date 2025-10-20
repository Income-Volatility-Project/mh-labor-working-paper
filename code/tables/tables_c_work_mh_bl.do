* MH per period - FE
use "$mh_data/Pilot_3_MH_Census_Study.dta", clear



// Replace missing with 0 for regression
replace money_earn_ = 0 if !work_engaged_ & survey
replace days_worked_ = 0 if !work_engaged_ & survey

winsor2 work_income money_earn_, cuts(0 95) suffix(_w)
rename money_earn__w money_earn_w


// Keep participant data OR keep one observation per hh_id-period to impute 0 for bags produced when survey was not completed
keep if participant | (!survey & one_obs_per_hh_id_period)

label var respondent_self "Census Respondent"
label var respondent_other_male "Referred by Male"
label var respondent_other_female "Referred by Female"

assert (respondent_self + respondent_other_male + respondent_other_female) == 1

local controls num_adults hh_size_study age_participant married_cs_participant respondent_self respondent_other_female 

// File name to save macro in
local table1_filename "$mh_tables/table_c.1_mh_work_bl.tex"
// Macro for which set of mental health variables to use
// defined in table_constants
local table1_varlist $study_mental_bl
// Macro for determining the dependent variables
local table1_working_var work_engaged_
local table1_income_var work_income_w
local table1_controls `controls'

// Appendix table
local table2_filename "$mh_tables/table_c.2_mh_work_bl.tex"
local table2_varlist $study_mental_bl_appendix
local table2_working_var work_engaged_
local table2_income_var work_income_w
local table2_controls `controls'

// Appendix table 2 - work income not imputted
// NOTE: overwritten to only have single panel
local table3_filename "$mh_tables/table_c.3_mh_work_bl.tex"
local table3_varlist $study_mental_bl
local table3_working_var work_engaged_
local table3_income_var money_earn_w
local table3_controls `controls'

// File name to save macro in
local table4_filename "$mh_tables/table_c.4_mh_work_bl.tex"
// Macro for which set of mental health variables to use
// defined in table_constants
local table4_varlist $study_mental_bl
// Macro for determining the dependent variables
local table4_working_var work_engaged_
local table4_income_var work_income_w
local table4_controls 


// Appendix table 4 - Using mental health measures
local table5_filename "$mh_tables/table_c.5_mh_work_bl.tex"
local table5_varlist $study_mental_bl_full
local table5_working_var work_engaged_
local table5_income_var work_income_w
local table5_controls `controls'


// Preview Table 6 -> Use bag income for the income var and worked_imputed for the working var
local table6_filename "$mh_tables/table_c.6_mh_work_bl.tex"
local table6_varlist $study_mental_bl_full
local table6_working_var worked_imputed
local table6_income_var work_income_w
local table6_controls `controls'

// File name to save macro in
local table7_filename "$mh_tables/table_c.7_mh_work_bl.tex"
// Macro for which set of mental health variables to use
// defined in table_constants
local table7_varlist $study_mental_bl_full
// Macro for determining the dependent variables
local table7_working_var work_engaged_
local table7_income_var work_income_w
local table7_controls 

// Appendix table
local table8_filename "$mh_tables/table_c.8_mh_work_bl.tex"
local table8_varlist $study_mental_bl_appendix_full
local table8_working_var work_engaged_
local table8_income_var work_income_w
local table8_controls `controls'

local scalar_option scalars("mean Control Mean" "N Observations") noobs

// Placeholder for getting esttab compacting table
gen mh_measure = .
gen mh_measure_X_treated = .
label var mh_measure "Baseline mental health measure"
label var mh_measure_X_treated "Baseline mental health measure x job offer"

label var phq8_z_bl "\makecell[t]{PHQ-8 (std)}"
label var gad7_z_bl "\makecell[t]{GAD-7 (std)}"
label var phq8_gad7_average_bl "\makecell[t]{Ave. of PHQ-8 (std)\\ and GAD-7 (std)}"

label var phq2_z_bl "\makecell[t]{PHQ-2 (std)}"
label var gad2_z_bl "\makecell[t]{GAD-2 (std)}"
label var phq2_gad2_average_bl "\makecell[t]{Ave. of PHQ-2 (std)\\ and GAD-2 (std)}"

label var phq8_high_bl      "\makecell[t]{High PHQ-8}"
label var gad7_high_bl      "\makecell[t]{High GAD-7}"
label var phq_gad_high_full_bl      "\makecell[t]{High PHQ-8\\ and GAD-7}"

replace number_bags = 0 if !treated
replace number_bags = 0 if missing(number_bags)

est clear
foreach table in table1 table2 table3 table4 table5 table6 table7 table8 {
    // First panel - Work Engagement
    local counter 1
    eststo `table'_w_`counter' : reghdfe ``table'_working_var' treated i.period ``table'_controls' if period >0  , cluster(hh_id) // absorb(community)
        su work_engaged_ if !treated
        estadd scalar mean = r(mean)

    eststo `table'_d_`counter': reghdfe days_worked_ treated i.period ``table'_controls' if period >0  , cluster(hh_id) // absorb(community)
        su days_worked_ if !treated
        estadd scalar mean = r(mean)

    eststo `table'_b_`counter': reghdfe number_bags i.period ``table'_controls' if period >0  , cluster(hh_id) // absorb(community)
        // Replace the obs scalar with "-"
        estadd local N  " ", replace

    eststo `table'_i_`counter': reghdfe ``table'_income_var' treated i.period  ``table'_controls' if period >0  , cluster(hh_id) // absorb(community)
        su ``table'_income_var' if !treated
        estadd scalar mean = r(mean)
    // Read the mental health vars for the appropriate table
    local counter 2

    local header_label "-"
    foreach mental_measure of varlist ``table'_varlist' {
        // Pick the correct mental health measure
        replace mh_measure = `mental_measure' 
        replace mh_measure_X_treated = `mental_measure'_X_treated
        // Store label in macro to use as table header
        local varlabel : variable label `mental_measure' 
        local header_label `header_label' "`varlabel'"

        eststo `table'_w_`counter' : reghdfe ``table'_working_var' mh_measure mh_measure_X_treated treated  i.period ``table'_controls' if period >0  , cluster(hh_id) // absorb(community)
            su ``table'_working_var' if !treated
            estadd scalar mean = r(mean)
        
        eststo `table'_d_`counter': reghdfe days_worked_ mh_measure mh_measure_X_treated treated  i.period ``table'_controls' if period >0  , cluster(hh_id) // absorb(community)
            su days_worked_ if !treated
            estadd scalar mean = r(mean)

        eststo `table'_b_`counter': reghdfe number_bags mh_measure i.period ``table'_controls' if period >0 & treated , cluster(hh_id) // absorb(community)
            su number_bags if e(sample)
            estadd scalar mean = r(mean)

        eststo `table'_i_`counter': reghdfe ``table'_income_var' mh_measure mh_measure_X_treated treated i.period ``table'_controls' if period >0  , cluster(hh_id) // absorb(community)
            su ``table'_income_var' if !treated
            estadd scalar mean = r(mean)

        
        local counter = `counter' + 1
    }

    esttab `table'_w_* using "``table'_filename'", ///
        $results_format $header_options collabels(, none) mlabels(`header_label') ///
        drop(*period _cons ``table'_controls') `scalar_option' ///
        posthead("\midrule \multicolumn{@span}{c}{\textbf{Working}} \\ \midrule") 

    esttab `table'_d_* using "``table'_filename'", ///
        $format_options $segment_options postfoot("\midrule") ///
        drop(*period _cons ``table'_controls') `scalar_option' ///
        posthead("\multicolumn{@span}{c}{\textbf{Days worked}} \\ \midrule") 

    esttab `table'_b_* using "``table'_filename'", ///
        $format_options $segment_options postfoot("\midrule") ///
        drop(*period _cons ``table'_controls') scalars("mean Mean" "N Observations") noobs ///
        posthead("\multicolumn{@span}{c}{\textbf{Bags produced}} \\ \midrule")

    esttab `table'_i_* using "``table'_filename'", ///
        $format_options $footer_options ///
        drop(*period _cons ``table'_controls') `scalar_option' ///
        posthead("\multicolumn{@span}{c}{\textbf{Work income}} \\ \midrule")

    }

// Appendix table 5 - work income not imputted w/ only single panel
    esttab table3_i_* using "$mh_tables/table_c.3_mh_work_bl.tex", ///
        $format_options replace ///
        drop(*period _cons) $end_table `scalar_option' ///
        posthead("\midrule \multicolumn{@span}{c}{\textbf{Work income}} \\ \midrule")


    local header_label "-"
    foreach mental_measure of varlist phq8_z_bl gad7_z_bl phq8_gad7_average_bl     {
        // Store label in macro to use as table header
        local varlabel : variable label `mental_measure' 
        local header_label `header_label' "`varlabel'"
    } 

    esttab table6_w_* using "$mh_tables/table_c.6_mh_work_bl.tex", ///
        $results_format replace collabels(, none) mlabels(`header_label') ///
        drop(*period _cons `table6_controls') `scalar_option' ///
        posthead("\midrule \multicolumn{@span}{c}{\textbf{Working (imputed)}} \\ \midrule")

