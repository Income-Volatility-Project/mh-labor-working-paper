use "$mh_data/Pilot_3_Census_Reshaped_Analysis.dta", clear

  keep if respondent & respondent_eligible
  local format_options nostar label cells(mean(pattern(1 0 0) fmt(%9.2f)) & b(pattern(0 1 1) star fmt(%9.2f)) sd(pattern(1 0 0) par fmt(%9.3f)) & se(pattern(0 1 1) par fmt(%9.3f))) booktabs nonote collabels(,none) nostar
  // First panel - Household characteristics

  // Winsorize to 95%
  winsor2 hh_income, cuts(0 95) suffix(_w)
  label var hh_income_w     "Income (30 days)"

  local hh_vars num_adults_cs hh_size_cs hh_income_w

  est clear
  eststo sum_mean: estpost summarize `hh_vars'

  eststo corr_phq2: corrse phq2_z_cs `hh_vars' 
  eststo corr_gad2: corrse gad2_z_cs `hh_vars' 

  esttab sum_mean corr_phq2 corr_gad2 using "$mh_tables/table_g.1_mh_hh_summary.tex", ///
        `format_options'  mlabels("Mean" "Corr. with PHQ-2" "Corr. with GAD-2") ///
        posthead("\midrule \multicolumn{@span}{c}{\textbf{Household characteristics}} \\ \midrule") ///
        postfoot("\midrule") replace noobs

use "$mh_data/Pilot_3_Census_Reshaped_Analysis.dta", clear

  keep if respondent & respondent_eligible

  local vars age_cs married_cs head spouse other_relation employed_cs small_firm_cs agriculture_cs wage_work_cs
  label var female "Female"
  label var employed_cs "Employed (12 months)"

  est clear
  eststo sum_mean_resp: estpost summarize `vars' phq2_high_cs gad2_high_cs
  eststo corr_phq2: corrse phq2_z_cs `vars' 
  eststo corr_gad2: corrse gad2_z_cs `vars' 


  esttab sum_mean_resp corr_phq2 corr_gad2 using "$mh_tables/table_g.1_mh_hh_summary.tex", ///
        obs posthead("\multicolumn{@span}{c}{\textbf{Respondent characteristics}} \\ \midrule") ///
        `format_options' append fragment postfoot("\midrule \end{tabular}") ///
				prehead(" ") nonumber prefoot("\bottomrule") mlabels(, none)
