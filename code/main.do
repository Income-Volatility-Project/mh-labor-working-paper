/*******
	Author: 	Simon Taye
	Purpose: 	Set up macros, folder structures and directories
*******/

// Settings to ensure clean working enviroment 
set more off
set varabbrev off
clear all
macro drop _all

************************************************
*****************START: Paths - JDE
************************************************

global mh_root 		"/Users/st2246/Work/JDE-SI"
cd "$mh_root"

global mh_code 		"$mh_root/code"
// We use the  two data macros exchangeably 
global mh_data 		"$mh_root/data/generated"
global data_gen 	"$mh_data"

global mh_scripts 	"$mh_root/external_scripts"
global mh_figures 	"$mh_root/manuscript/plot"
global mh_tables	"$mh_root/manuscript/table/updated"

// Ensure output directories exist
cap mkdir "$mh_figures"
cap mkdir "$mh_root/manuscript/table"
cap mkdir "$mh_tables"

************************************************
*****************START: Dependencies
************************************************

// The following code ensures that all user-written ado files needed for the project are saved within the project directory, not elsewhere.
tokenize `"$S_ADO"', parse(";")
while `"`1'"' != "" {
    if (`"`1'"'!="BASE") & (`"`1'"'!="SITE") cap adopath - `"`1'"'
    macro shift
}
// Set adoplus manually
sysdir set PLUS "$mh_scripts"
adopath ++ PLUS


************************************************
*****************END: Dependencies
************************************************

* Run figures
do "$mh_code/figures/fig_1.2_mh_distribution_all.do"
do "$mh_code/figures/fig_2_work_earning.do"
do "$mh_code/figures/fig_3_refuse_work.do"

* Run tables 
// Define constants for table formatting
do "$mh_code/tables/table_constants"
// Run table code
do "$mh_code/tables/tables_a_mental_health_and_offer_accept.do"
do "$mh_code/tables/tables_b_refusal_reason.do"
do "$mh_code/tables/tables_b_refusal_reason_controls.do"
do "$mh_code/tables/tables_c_work_mh_bl.do"
do "$mh_code/tables/tables_g_summary_stats_census.do"
do "$mh_code/tables/tables_h_mh_quit.do"
do "$mh_code/tables/tables_i_summary_stats_study.do"
