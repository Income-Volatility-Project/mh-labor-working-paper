/*******
	Author: 	Simon Taye
	Purpose: 	Run the necessary do-s to recreate results
*******/

// Settings to ensure clean working enviroment 
set more off
set varabbrev off
clear all
macro drop _all


// SET PATH TO FOLDER HERE
global mh_root

// Try to automatically set path if none detected.
if "$mh_root" == "" {
	local cwd : pwd
	cd "`cwd'/.."
	local cwd : pwd
	global mh_root "`cwd'"
}


// Create necessary directories if they don't exist
cap mkdir "$mh_root/manuscript"
cap mkdir "$mh_root/manuscript/plot"
cap mkdir "$mh_root/manuscript/table"
cap mkdir "$mh_root/manuscript/table/updated"

do "$mh_root/code/setup.do"


* Run figures
do "$mh_code/figures/fig_1.2_mh_distribution_all.do"
do "$mh_code/figures/fig_2_labor_outcomes.do"
do "$mh_code/figures/fig_3_refuse_work.do"
do "$mh_code/figures/fig_4_work_completion.do"

* Run tables 
// Define constants for table formatting
do "$mh_code/tables/table_constants"
// Run table code
do "$mh_code/tables/tables_a_mental_health_and_offer_accept.do"
do "$mh_code/tables/tables_aa_mh_offer_control_comparison.do"
do "$mh_code/tables/tables_ab_mh_offer_subsample.do"
do "$mh_code/tables/tables_b_refusal_reason.do"
do "$mh_code/tables/tables_b_refusal_reason_controls.do"
do "$mh_code/tables/tables_c_work_mh_bl.do"
do "$mh_code/tables/tables_g_summary_stats_census.do"
do "$mh_code/tables/tables_h_mh_quit.do"
do "$mh_code/tables/tables_i_summary_stats_study.do"
do "$mh_code/tables/tables_j_survey_response_rate.do"

