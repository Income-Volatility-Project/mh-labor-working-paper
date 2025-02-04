* MH per period - FE
use "$mh_data/Pilot_3_MH_Census_Study.dta", clear



// Replace missing with 0 for regression
replace money_earn_ = 0 if !work_engaged_
replace days_worked_ = 0 if !work_engaged_

winsor2 work_income money_earn_, cuts(0 95) suffix(_w)
rename money_earn__w money_earn_w

keep if participant

local controls num_adults hh_size_study age married_cs 

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

local scalar_option scalars("mean Control Mean" "N Observations") noobs

// Placeholder for getting esttab compacting table
gen mh_measure = .
gen mh_measure_X_treated = .
label var mh_measure "Mental health measure"
label var mh_measure_X_treated "Mental health measure x job offer"

label var phq8_gad7_average_bl "\shortstack{Ave. of PHQ-8 (std)\\ and GAD-7 (std)}"
label var phq2_gad2_average_bl "\shortstack{Ave. of PHQ-2 (std)\\ and GAD-2 (std)}"
label var phq_gad_high_bl      "\shortstack{High\\PHQ-2 and GAD-2}"

replace number_bags = 0 if !treated

est clear
foreach table in table1 table2 table3 table4 table5 {
    // First panel - Work Engagement
    local counter 1
    eststo `table'_w_`counter' : xtreg ``table'_working_var' treated i.period ``table'_controls' if period >0  , cluster(hh_id)
        su work_engaged_ if !treated
        estadd scalar mean = r(mean)

    eststo `table'_d_`counter': xtreg days_worked_ treated i.period ``table'_controls' if period >0  , cluster(hh_id)
        su days_worked_ if !treated
        estadd scalar mean = r(mean)

    eststo `table'_b_`counter': xtreg number_bags treated  i.period ``table'_controls' if period >0  , cluster(hh_id)

    eststo `table'_i_`counter': xtreg ``table'_income_var' treated i.period  ``table'_controls' if period >0  , cluster(hh_id)
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

        eststo `table'_w_`counter' : xtreg ``table'_working_var' mh_measure mh_measure_X_treated treated  i.period ``table'_controls' if period >0  , cluster(hh_id)
            su ``table'_working_var' if !treated
            estadd scalar mean = r(mean)
        
        eststo `table'_d_`counter': xtreg days_worked_ mh_measure mh_measure_X_treated treated  i.period ``table'_controls' if period >0  , cluster(hh_id)
            su days_worked_ if !treated
            estadd scalar mean = r(mean)

        eststo `table'_b_`counter': xtreg number_bags mh_measure treated  i.period ``table'_controls' if period >0  , cluster(hh_id)

        eststo `table'_i_`counter': xtreg ``table'_income_var' mh_measure mh_measure_X_treated treated i.period ``table'_controls' if period >0  , cluster(hh_id)
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
        drop(*period _cons ``table'_controls') scalars("N Observations") noobs ///
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

