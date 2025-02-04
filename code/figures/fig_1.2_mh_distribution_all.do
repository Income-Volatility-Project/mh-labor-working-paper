**plot for female decision makers only
use "$data_gen/Pilot_3_Census_Reshaped_Analysis.dta", clear

keep if female & respondent
	
	
* Clear any existing graphs
graph drop _all

set scheme plotplain


* Depressi* Thicker dashed line with increased width (w) parameter
twoway (histogram phq2_cs, frequency fcolor(white) discrete) /// color("0 71 171%30")  width(0.9)
     (pci 0 3 `=r(max)' 3, lcolor(black) lpattern(dash) lwidth(thick) legend(label(2 "cutoff ({&ge}3)"))), ///
	xtitle("PHQ-2 Score") /// title("Depression Score (PHQ-2)") /// ytitle("Frequency") 
    xline(3, lpattern(dash) lcolor(black) lwidth(thick)) ///
     legend(order(1 2) label(1 "Frequency")) ///
     name(phq2, replace) ysize(5) xsize(6) ///
     graphregion(color(white)) bgcolor(white) plotregion(style(none))  

// graph export "$mh_figures/mh_distribution_all_phq2.pdf", replace
	 
	 
graph twoway (histogram gad2_cs,  frequency fcolor(white) discrete) ///
     (pci 0 3 `=r(max)' 3, lcolor(black) lpattern(dash) lwidth(thick) legend(label(2 "cutoff ({&ge}3)"))), ///
   ///  title("Anxiety Score (GAD-2)") ///
     xtitle("GAD-2 Score") ///ytitle("Frequency") ///
     xline(3, lpattern(dash) lcolor(black) lwidth(thick)) ///
     legend(order(1 2) label(1 "Frequency")) ///
     name(gad2, replace) ysize(5) xsize(6) ///
	ylabel(0 50 100 150)	graphregion(color(white)) bgcolor(white) plotregion(style(none))  


// graph export "$mh_figures/mh_distribution_all_gad2.pdf", replace

graph combine phq2 gad2, ///
    rows(1) cols(2) ///
    title("Mental Health Scores Distribution for Women") ///
    note("") ///
    xsize(10) ysize(8)
grc1leg2 phq2 gad2, legendfrom(phq2)

graph export "$mh_figures/fig.1.2.mh_distribution_preview.png", width(1200) height(800) as(png) replace