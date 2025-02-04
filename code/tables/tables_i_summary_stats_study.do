
  local format_options  cell(mean(pattern(1 1 0) fmt(2)) & p(pattern(0 0 1) star fmt(3)) sd(pattern(1 1 0) par fmt(2))) /// 
                        collabels(none) label nonote  booktabs ///
                         

  use "$data_gen/Pilot_3_MH_Census_Study.dta" if period == 0, clear
  
  // Count everyone who isn't just from the census
  gen one = !census_only
  collapse (sum) num_adults=adult size=one (mean) phq2_z_bl gad2_z_bl total_hh_income=total_income_hh, by(hh_id treated)


  winsor2 total_hh_income, cuts(0 95) suffix(_w)

  label var num_adults        "Number of Adults"
  label var size              "Number of Members"
  label var total_hh_income_w   "Income"


  local hh_vars num_adults size total_hh_income_w

  eststo clear
  eststo treatment:  estpost summarize `hh_vars' if treated
  eststo control:    estpost summarize `hh_vars' if !treated
  eststo diff:       estpost ttest `hh_vars', by(treated)


  esttab treatment control diff using "$mh_tables/table_i.1_mh_hh_summary.tex", ///
    posthead("\midrule \multicolumn{@span}{c}{\textbf{Household characteristics}} \\ \midrule") noobs ///
    mlabels("Treatment" "Control" "p-value: (1)==(2)")  `format_options' replace postfoot("\midrule")


use "$data_gen/Pilot_3_MH_Census_Study.dta" if period == 0, clear
  
  keep if participant

	
  local vars age married_cs education_years work_engaged_ agriculture_work wage_work_study  other_work_study  phq2_high gad2_high  // martial_status 

  label var work_engaged_ "Employed - 10 days"

  //replace education_years = 0 if missing(education_years)

  eststo clear
  eststo treatment:  estpost summarize `vars' if treated
  eststo control:    estpost summarize `vars' if !treated
  eststo diff:       estpost ttest `vars', by(treated)


  esttab treatment control diff using "$mh_tables/table_i.1_mh_hh_summary.tex", ///
    posthead("\multicolumn{@span}{c}{\textbf{Respondent characteristics}} \\ \midrule")   ///
    `format_options' postfoot("\midrule \end{tabular}}") prehead(" ") nonumber /// 
    prefoot("\bottomrule") mlabels(, none)  append fragment  mtitles(none)