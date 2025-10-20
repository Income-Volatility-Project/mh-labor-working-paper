// Survey response rate by treated (which is 1 or 0)
use "$data_gen/Pilot_3_Attrition.dta", clear

keep if period > 0

// Run t-tests for each period and store estimates
estimates clear

quietly estpost ttest survey if period == 1, by(treated)
estimates store period1

// Period 2
quietly estpost ttest survey if period == 2, by(treated)
estimates store period2

// Period 3
quietly estpost ttest survey if period == 3, by(treated)
estimates store period3

// Period 4
quietly estpost ttest survey if period == 4, by(treated)
estimates store period4

// Period 5
quietly estpost ttest survey if period == 5, by(treated)
estimates store period5

// Period 6
quietly estpost ttest survey if period == 6, by(treated)
estimates store period6

// Overall (all periods)
quietly estpost ttest survey, by(treated)
estimates store overall

// Create table with esttab
// Do model by model using fragments so that each period is a row
local header_prehead "{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{1}{ccc}} \hline\hline"
local footer_postfoot "\hline\hline \end{tabular}}"
local common_opts starlevels(* 0.10 ** 0.05 *** 0.01) cells("mu_1(fmt(3) label(Control)) mu_2(fmt(3) label(Treatment)) b(fmt(3) star label(Difference))") 

// Add 3 column spanning model header with underline called "Survey Response Rate"
esttab period1 using "$mh_tables/table_j_survey_response.tex", `common_opts' ///
    mlabels("Survey Response Rate", span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cline{@span})) ///
    replace fragment prefoot() postfoot() prehead("`header_prehead'") noobs nonumber varlabels(survey "Period 1")

forvalues i=2/6 {
    local model period`i'
    local label "Period `i'"
    if `i' == 6 {
        local label "Endline"
    }
    estout `model' using "$mh_tables/table_j_survey_response.tex", ///
        prehead() posthead() prefoot() postfoot() `common_opts' ///
        append mlabels(, none) collabels(, none)  style(tex) varlabels(survey "`label'") 
}

estout overall using "$mh_tables/table_j_survey_response.tex", ///
    `common_opts' mlabels(, none) collabels(, none) style(tex) ///
    append prehead() posthead("\hline")  postfoot("`footer_postfoot'") varlabels(survey "Overall")
    


 

// gen t_mean_str = string(t_mean, "%9.3f")
// gen c_mean_str = string(c_mean, "%9.3f") 
// gen diff_str = string(difference, "%9.3f") + stars
