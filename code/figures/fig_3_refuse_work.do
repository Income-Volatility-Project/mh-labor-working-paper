**plot for female decision makers only
use "$data_gen/Pilot_3_Census_Reshaped_Analysis.dta", clear

keep if female & respondent
	
	// Reshape so data is at the work-offer level
	rename work_home work0
	rename work_out work1
	reshape long work , i(hh_id) j(work_out)
	
	pause
	
// Create separate binary indicators for each mental health category
* neither, both, depress_high, anxiety_high already exist

gen nowork = (work == 0)
replace nowork =. if work ==.
replace nowork = 100*nowork
gen neither_mh = (gad2_high_cs==0 & phq2_high_cs==0)
gen both_mh = ((gad2_high_cs==1 & phq2_high_cs==1))

foreach x of var neither_mh gad2_high_cs phq2_high_cs both_mh {
	egen `x'_m = mean(nowork) if `x'==1
	egen `x'_sem = semean(nowork) if `x'==1
}
keep neither_mh* gad2_high_cs* phq2_high_cs* both_mh*
duplicates drop
gen 	x = 0 if neither_mh ==1
replace x = 1 if gad2_high_cs ==1  
replace x = 2 if phq2_high_cs ==1  
replace x = 3 if both_mh ==1  
gen 	m = neither_mh_m if neither_mh ==1
replace m = gad2_high_cs_m if gad2_high_cs ==1  
replace m = phq2_high_cs_m if phq2_high_cs ==1  
replace m = both_mh_m if both_mh ==1  
gen 	l = neither_mh_m	-	neither_mh_sem if neither_mh ==1
replace l = gad2_high_cs_m	-	gad2_high_cs_sem if gad2_high_cs ==1  
replace l = phq2_high_cs_m	-	phq2_high_cs_sem if phq2_high_cs ==1  
replace l = both_mh_m		-	both_mh_sem if both_mh ==1  
gen 	h = neither_mh_m	+	neither_mh_sem if neither_mh ==1
replace h = gad2_high_cs_m	+	gad2_high_cs_sem if gad2_high_cs ==1  
replace h = phq2_high_cs_m	+	phq2_high_cs_sem if phq2_high_cs ==1  
replace h = both_mh_m		+	both_mh_sem if both_mh ==1  

twoway (bar m x, barw(.65) fc(white) lc(black) mlabel(m) mlabf(%9.2f) mlabp(1) mlabc(black))  (rspike h l  x, color(black)) ///
	, legend(off) xtitle("") xlabel(0 "Neither" 1 "High Anxiety" 2 "High depression" 3 `""High depression""and anxiety""', notick) ///
	plotregion(style(none)) yscale(off) xscale(lstyle(none))  

	graph export "$mh_figures/refuse_work_sem.pdf", replace