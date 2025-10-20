/*
    Author: Simon Taye
    Purpose: Work completion rates across study periods (figure)
*/

// Load the study dataset
use "$mh_data/Pilot_3_MH_Census_Study.dta", clear

set scheme plotplain

local color_1 "gs1"
local color_2 "eltblue"
local color_3 "dknavy"

// Keep only participants with valid bag data OR keep the first obseravation (there should only be one) to impute 0 for completion
keep if participant | (!survey & one_obs_per_hh_id_period)
isid hh_id period
keep if treated
keep if period > 0

// Compute median phq2_z and gad2_z per period
bysort period: egen median_mh_average = median(phq2_gad2_average)
// Group participants by median phq2_z and gad2_z
gen mh_above_median = phq2_gad2_average > median_mh_average

replace number_bags = 0 if missing(number_bags)
// Create work completion variables
gen any_bag_produced = ((number_bags >= 1)) * 100
gen bag_completion_rate = (number_bags / maximum_possible_bags) * 100
gen bag_income_rate = (bag_income / (maximum_possible_bags * 12)) * 100
replace bag_completion_rate = 0 if maximum_possible_bags == 0 | missing(maximum_possible_bags)
replace bag_income_rate = 0 if maximum_possible_bags == 0 | missing(maximum_possible_bags)


// Create overall work completion
preserve
    collapse (mean) any_bag_produced bag_completion_rate bag_income_rate bag_income, by(period)
        gen group = 1
    tempfile overall
    save `overall', replace
restore

// Create completion split by mh
collapse (mean) any_bag_produced bag_completion_rate bag_income_rate bag_income, by(period mh_above_median)
    gen group = 2 if mh_above_median == 0
    replace group = 3 if mh_above_median == 1
// Append overall
append using `overall'


local barwidth 0.25

preserve
replace period = period - (`barwidth' + 0.02) if group == 1
replace period = period + (`barwidth' + 0.02) if group == 3

label define group_lbl 1 "Overall" 2 "Mental Health Index Below Median" 3 "Mental Health Index Above Median"
label values group group_lbl

local var1 any_bag_produced
local var1_title "Any Bag Produced (%)"
local var1_yscale 0(20)100

local var2 bag_completion_rate
local var2_title "Bag Completion Rate (%)"
local var2_yscale 0(20)100

local var3 bag_income
local var3_title "Bag Income (cedis)"
local var3_yscale 0(20)140



foreach var in var1 var2 var3 {
    local var_title ``var'_title'
    local yscale ``var'_yscale'   

    twoway  (bar ``var'' period if group == 1, barwidth(`barwidth') color(`color_1')) ///
            (bar ``var'' period if group == 2, barwidth(`barwidth')  color(`color_2')) ///
            (bar ``var'' period if group == 3, barwidth(`barwidth') lwidth(vthin) lpattern(shortdash) color(`color_3')), ///
            legend(order(1 "Overall" 2 "Mental Health Index Below Median" 3 "Mental Health Index Above Median") pos(6) rows(1)) ///
            title(`var_title') xtitle("Study Period") ytitle("") ///
            yscale(r(`yscale')) ylabel(`yscale') name(``var'', replace) bgcolor(ebg)

twoway  (bar ``var'' period if group == 1, barwidth(`barwidth') color(`color_1')) ///
        (bar ``var'' period if group == 2, barwidth(`barwidth')  color(`color_2')) ///
        (bar ``var'' period if group == 3, barwidth(`barwidth') lwidth(vthin) lpattern(shortdash) color(`color_3')), ///
        legend(order(2 "Mental Health Index Below Median" 3 "Mental Health Index Above Median" 1 "Overall") pos(6) rows(2)) ///
        ytitle(`var_title') yscale(r(`yscale')) ylabel(`yscale') xtitle("Period") name(``var''_vertical, replace) bgcolor(ebg)

}

grc1leg2 any_bag_produced bag_completion_rate bag_income, rows(1) xsize(7.5) legscale(2) iscale(1)
graph export "$mh_figures/fig_4_work_completion.pdf", replace
graph export "$mh_figures/fig_4_work_completion.jpg", replace width(1920) height(1080)

grc1leg2 any_bag_produced_vertical bag_completion_rate_vertical bag_income_vertical, cols(1) ysize(15) xsize(7.5) legscale(2.5) iscale(1)
graph export "$mh_figures/fig_4_work_completion_vertical.pdf", replace
graph export "$mh_figures/fig_4_work_completion_vertical.jpg", replace height(1920) width(1080)

grc1leg2 any_bag_produced bag_completion_rate , rows(1) xsize(15) legscale(3) name(fig_4_2, replace)
grc1leg2 fig_4_2 bag_income, rows(1) xsize(7.5) legscale(2) cols(1) name(fig_4_3, replace)
graph export "$mh_figures/fig_4_work_completion_stacked.pdf", replace
graph export "$mh_figures/fig_4_work_completion_stacked.jpg", replace width(1920) height(1080)