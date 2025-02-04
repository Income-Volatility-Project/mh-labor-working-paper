* MH per period - FE
use "$mh_data/Pilot_3_MH_Census_Study.dta", clear

// Replace missing with 0 for regression
replace money_earn_ = 0 if !work_engaged_
replace days_worked_ = 0 if !work_engaged_

keep if participant & treated

// Define table specifications
local table0_filename "$mh_tables/table_h.0_mh_quit.tex"
local table0_mental_vars $study_mental_bl
local table6_filename "$mh_tables/table_h.6_mh_quit.tex"
local table6_mental_vars $study_mental_full

foreach period in 0 6 {
    est clear
    local tablename "table`period'"
    
    // Panel A - Quit Variable 1
    local counter 1
    foreach mental_measure of varlist ``tablename'_mental_vars' {
        eststo `tablename'_q1_`counter': reg quit_pickup_v1 `mental_measure' if period == `period', robust
            su quit_pickup_v1 if e(sample)
            estadd scalar mean = r(mean)
    
        eststo `tablename'_q2_`counter': reg quit_pickup_v2 `mental_measure' if period == `period', robust
            su quit_pickup_v2 if e(sample)
            estadd scalar mean = r(mean)

        eststo `tablename'_q3_`counter': reg quit_pickup_v3 `mental_measure' if period == `period', robust
            su quit_pickup_v3 if e(sample)
            estadd scalar mean = r(mean)

        eststo `tablename'_q4_`counter': reg quit_pickup_v4 `mental_measure' if period == `period', robust
            su quit_pickup_v4 if e(sample)
            estadd scalar mean = r(mean)
        
        local counter = `counter' + 1
    }
    
    // Output the tables
    esttab `tablename'_q1_* using "``tablename'_filename'", ///
        $format_options $header_options ///
        scalars("mean Dep. Var. Mean") drop(_cons) ///
        posthead("\midrule \multicolumn{@span}{c}{\textbf{Didn't turn in bags at endline}} \\ \midrule")
        
    /*esttab `tablename'_q2_* using "``tablename'_filename'", ///
        $format_options $segment_options ///
        scalars("mean Dep. Var. Mean") drop(_cons) ///
        posthead("\multicolumn{@span}{c}{\textbf{Didn't Turn in Bags in Period 5 or 6}} \\ \midrule")
    */
        
    esttab `tablename'_q4_* using "``tablename'_filename'", ///
        $format_options $footer_options ///
        scalars("mean Dep. Var. Mean") drop(_cons) ///
        posthead("\multicolumn{@span}{c}{\textbf{Last period in which participant submits bags}} \\ \midrule")
}