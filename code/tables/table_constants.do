/*******
	Author: 	Simon Taye
	Date: 		Jan 21, 2025
	Purpose: 	Define certain constants used in all table regressions for cleanness
*******/

/// Below are the mental health measures used for the various tables
		// Changing below affects multiple tables
		// Mental Health Vars used in Census regressions
		global census_mental 						phq2_z_cs gad2_z_cs phq2_gad2_average_cs 

  	// Use by appendix version of various tables that use mental variables
		global census_mental_appendix 	phq2_high_cs gad2_high_cs phq_gad_high_cs

		// Mental Health Measures used when controlling for baseline mental health
		global study_mental_bl 					phq2_z_bl gad2_z_bl phq2_gad2_average_bl
		global study_mental_bl_full 		phq8_z_bl gad7_z_bl phq8_gad7_average_bl
		global study_mental_bl_appendix phq2_high_bl gad2_high_bl phq_gad_high_bl
		global study_mental_bl_appendix_full phq8_high_bl gad7_high_bl phq_gad_high_full_bl

		// Mental Health Measures used for study regressions
		global study_mental 						phq2_z gad2_z phq2_gad2_average
		global study_mental_appendix 		phq2_high gad2_high phq_gad_high

		// Mental Health Measures available during baseline / endline
		// Currently only used in table 9 / 10
		global study_mental_full 				phq8_z gad7_z phq8_gad7_aindex phq8_gad7_average


//// Below are some esttab options used to create multipanel tables
		// Every table should have format options and one of header, footer or segment as appropirate
		global header_options  postfoot("\midrule")  replace 
    global segment_options fragment append prehead(" ") nonumber prefoot("\bottomrule") 
		
		global results_format starlevels(* 0.10 ** 0.05 *** 0.01) label booktabs  cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)))

		global end_table 			postfoot("\midrule \end{tabular}}")

   	global format_options $results_format mlabels(,none) collabels(,none) nonote
	 	global footer_options append fragment $end_table ///
													prehead(" ") nonumber prefoot("\bottomrule") 
		
		global no_footer 			postfoot(" ") prefoot(" ")
		global no_header 			posthead(" ") prehead(" ")