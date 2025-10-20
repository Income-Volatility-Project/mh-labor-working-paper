/*******
	Author: 	Simon Taye
	Purpose: 	Set up macros, folder structures and directories
*******/

************************************************
*****************START: Paths - JDE
************************************************

// If MH Root is not set already then set it here
if "$mh_root" == "" {
	local cwd : pwd
	global mh_root "`cwd'"
}
cd "$mh_root"

global mh_code 		"$mh_root/code"
global code 			"$mh_code"
// We use the  two data macros exchangeably 
global mh_data 		"$mh_root/data/generated"
global data_gen 	"$mh_data"
global mh_raw "$mh_root/data/raw"

// Copy-paste of Pilot 3 cleaning dummies so we can update the code
global p3_raw "$mh_raw"
global cal "$p3_raw/calories_database.dta"
global ps "$p3_raw/04_Phone_surveys"
global bl "$p3_raw/02_Baseline"
global el "$p3_raw/08_Endline_data"
global fcm "$p3_raw/07_Food_Consumption_Measure"
global census "$p3_raw/01_Census"
global referral "$p3_raw/11_Refferals/"
* Nested structure for intervention data
global intervention "$p3_raw/03_Intervention_data"
global training "$intervention/03_Treatment dissemination"
global dropoff "$intervention/02_Drop_off"
global pickup "$intervention/01_pick_up"

global mh_scripts 	"$mh_root/external_scripts"
global mh_figures 	"$mh_root/manuscript/plot"
global mh_tables	"$mh_root/manuscript/table/updated"
global mh_tables_variations 	"$mh_root/manuscript/variations/tables"
global mh_figures_variations 	"$mh_root/manuscript/variations/plot"

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

**************************************************
**************** Table Helpers
**************************************************
	do "$mh_code/tables/table_constants.do"


***************************************************
****************** KEY IDs
***************************************************
global key_id hh_id participant_id period treat stable control treated predictable unpredictable hh_rank
