/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   			ADMIN DATA MASTER CLEANING DO								   *
*   							   2019										   *
********************************************************************************
********************************************************************************
*						   SELECT PARTS TO RUN   							   *
********************************************************************************/
	
	* select which parts of this do-file to run
	local 	packages		0	// 	Install packages -- only needs to be ran 
									//	once in each computer
								
********************************************************************************
*			PART 1:  Set standard settings and install packages				   *
********************************************************************************/
	
	* Install packages
	if `packages' 	{
		ssc install labutil, 	replace
		ssc install ietoolkit, 	replace
		ssc install winsor, 	replace
		ssc install sxpose, 	replace
		ssc install dataout, 	replace
		ssc install estout, 	replace
		ssc install reghdfe, 	replace
		ssc install unique, 	replace
	}	

	global sleep		1200		// Delay code for running so it doesn't crash
	
	
		
********************************************************************************
*				PART 2:  Prepare globals and define paths					   *
*******************************************************************************
*NOTE: PLEASE USE '/' INSTEAD OF '\' FOR DIRECTORIES FOR COMPATABILITY WITH MACS

	* add your directory below
	 display c(username)  	


	* Set directories 
	* ---------------	
	* Sushmita
	if "`c(username)'" == "wb522556" {
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Task Allocation Check in\Report\Pilot\Code\Dofiles\Cleaning"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Report\Pilot\Datasets"
	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
set more off
global date `'
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Report\Pilot\Outputs\Raw"

********************************************************************************
*						PART 4: VARIABLES FOR PAGE 3						   *
*						SAME THING BUT BY IMPORTANCE							*
********************************************************************************
	use "$onedrive\Intermediate\tud_v2.dta", clear
	
*CREATE VARIABLE FOR NUMBER OF DAYS FOR EACH CASE
********************************************************************************
*						UNIMPORTANT												*
********************************************************************************

	keep if imp_act == 1
	
	*Total time recorded for all check-ins

	local 	analysis 	category_project	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						combined_categories 	
						
	*Total Time Values for each case
	gen 		totalctime						=	.	
	
	*Total Time Values for all users
	egen		totaltime			 			=	total(activity_duration)	
	foreach var of local analysis {	
	gen 		`var'_cpr						=	.
	gen 		hh_actc`var'					=	.

	*Total time spent on each activity for all users
	bysort		`var'		:													///
	egen 		hh_act`var' 					=	total(activity_duration)
	
	*Proportion of time spent on an activity over total time recorded on check-in for all users
	gen 		`var'_tpr						=	(hh_act`var'/totaltime)*100	

	*Total duration Values by cases
	
	*total amount of time spent by each case on each activity
	forvalues 	caseid 							= 1/$case {
		bysort 	`var' 			: 												///
		egen 	hh_act`caseid'					=	total(activity_duration)	///
							if caseid			==	`caseid' 	&				///
								`var'			!=	.
		
		*total amount of time spent by each case on all activities
		egen	total`caseid'time				=	total(activity_duration)	///
								if caseid		==	`caseid'
								
		*Proportion of time spent on each activity for a case		
		gen 	`var'_cpr`caseid'				=	(hh_act`caseid'/total`caseid'time)*100 ///
							if caseid 			== 	`caseid'		
							
		replace `var'_cpr						=	`var'_cpr`caseid'			///
							if	`var'_cpr		==	.
							
		*Total amount of time recorded for each case				
		replace totalctime						=	total`caseid'time    		///
						if 	totalctime			==	.
		
		*Number of hours spent by the case on each activity	
		bysort `var':															///
		replace hh_actc`var'					=	hh_act`caseid'				///
							if 	hh_actc`var'	==	.
						
		drop	`var'_cpr`caseid' total`caseid'time hh_act`caseid'
	}
	}
	
*THE SAME AS ABOVE BUT FOR TYPE VARIABLES	
local 	type			type_email 		type_meeting 		///
						type_strategy 		type_network 	type_develop_prj 	///
						type_hiring 		type_review_docs type_write 		///
						type_prep_ppt 		type_dta_analysis type_prj_mng 		///
						type_procure 		type_tm_mng 	type_int_report 	///
						type_career_dev 	type_ind_wrk 		type_oth

	foreach var of local type {	
	gen 		`var'_cpr						=	.
	gen 		hh_actc`var'					=	.
	
	*Total time spent on each activity for all users
	bysort		`var'		:													///
	egen 		hh_act`var' 					=	total(activity_duration)
	
	*Proportion of time spent on an activity over total time recorded on check-in for all users
	gen 		`var'_tpr						=	(hh_act`var'/totaltime)*100	

	*PAGE 2: Total duration Values by cases
	
	*total amount of time spent by each case on each activity
	forvalues 	caseid 							= 1/$case {
		egen 	hh_act`caseid'`var'				=	total(activity_duration)	///
							if caseid			==	`caseid' 	&				///
								`var'			==	1
		egen maxhh_act`caseid'`var' 			=	max(hh_act`caseid'`var')	///
							if caseid			==	`caseid' 	&				///
								`var'			==	1
		replace hh_act`caseid'`var'				= 	maxhh_act`caseid'`var'		///
							if caseid			==	`caseid'

		*Proportion of time spent on each activity for a case		
		gen 	`var'_cpr`caseid'				=	(hh_act`caseid'`var'/totalctime)*100 ///
							if caseid 			== 	`caseid'							
		replace `var'_cpr						=	`var'_cpr`caseid'			///
							if	`var'_cpr		==	.
								
		*Number of hours spent by the case on each activity	
		replace hh_actc`var'					=	hh_act`caseid'`var'			///
							if 	hh_actc`var'	==	.
						
		drop	`var'_cpr`caseid' hh_act`caseid'`var' maxhh_act`caseid'`var'
	}
	}
	save "$onedrive\Intermediate\tempa_unimp.dta", replace

	*PAGE 2: generating a new caseid which will hold all case data
	use "$onedrive\Intermediate\tempa_unimp.dta", clear
	
	local 	analysis 	category_project	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						combined_categories type_email 		type_meeting 		///
						type_strategy 		type_network 	type_develop_prj 	///
						type_hiring 		type_review_docs type_write 		///
						type_prep_ppt 		type_dta_analysis type_prj_mng 		///
						type_procure 		type_tm_mng 	type_int_report 	///
						type_career_dev 	type_ind_wrk 		type_oth							

	foreach var of local analysis {	
	preserve
	keep `var' `var'_tpr hh_act`var' totaltime nr_daysall	
	ren (`var'_tpr hh_act`var' totaltime) (`var'_cpr hh_actc`var' totalctime)
	drop if `var'_cpr ==.	| `var' == . | hh_actc`var' ==. | totalctime==.
	gen caseid = 100
	save "$onedrive\Intermediate\tempt`var'_unimp.dta", replace
	restore
	}
	
	local 	analysis 	category_project	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth		

	foreach var of local analysis {	
	use "$onedrive\Intermediate\tempt`var'_unimp.dta", clear
	collapse (max) `var'_cpr hh_actc`var' totalctime caseid nr_daysall, by(`var')
	save "$onedrive\Intermediate\tempt`var'_unimp.dta", replace
	use "$onedrive\Intermediate\tempa_unimp.dta", clear
	append using "$onedrive\Intermediate\tempt`var'_unimp.dta"
	save "$onedrive\Intermediate\tempa_unimp.dta", replace
	}

*Generating case name variable
	drop if caseid 	== .	
	replace casenme = 	"Staff Average"				if 		caseid 			==	100
		
*generating variable for activity with maximum hours spent by caseid
	cap noi drop 	temp
	
	gen type_activity_maxhh					=	.
	forvalues caseid = 1/100 {
	egen 	temp`caseid'		 			=	rowmax(hh_actctype_*)			///
					if caseid				==	`caseid'
	replace type_activity_maxhh				= 	temp`caseid'					///
					if type_activity_maxhh	==	.
	drop temp`caseid'
	}
	
	gen 	type_activity_max 			= 	""
	
	local 	type 		type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth		

	foreach x of local type		{
	decode `x', gen(`x'n)
	replace type_activity_max			=	`x'n								///
			if	type_activity_maxhh		==	hh_actc`x' 		&					///
				type_activity_max		==	""
				drop `x'n
			}

	encode type_activity_max, gen(type_activity_maxn)
	drop type_activity_max
	ren type_activity_maxn type_activity_max
	
	bysort caseid:																///
	egen 	temp						=	max(type_activity_max)
	replace type_activity_max			=	temp								///
				if type_activity_max	==	.	
	drop temp
	
	save "$onedrive\Intermediate\tud_v3_unimp.dta", replace
	
	*generating dataset for type of activity
	
	local 	type 		type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth		

	foreach x of local type			{
	forvalues y = 1/$case	 			{
	use "$onedrive\Intermediate\tud_v3_unimp.dta", clear	
	cap noi collapse (first) `x'_cpr hh_actc`x' casenme nr_days nr_daysall 		///
					if caseid 		== `y', by(`x')
				
	cap noi drop 	if 	`x'			==	0 |										///
						`x'			==	.
	cap noi decode `x', gen(`x'n)
	cap noi drop `x'
	cap noi ren (`x'_cpr `x'n) (type_cpr type)	
	cap noi save "$onedrive\Intermediate\tud_v3_`x'`y'_unimp.dta", replace
	}
	}
	
	foreach x of local type			{
	use "$onedrive\Intermediate\tud_v3_unimp.dta", clear	
	cap noi collapse (first) `x'_cpr hh_actc`x' casenme nr_days nr_daysall 		///
					if caseid 				== 100, by(`x')
					
	cap noi drop 	if 	`x'					==	0 |								///
						`x'					==	.
	cap noi decode `x', gen(`x'n)
	cap noi drop `x'
	cap noi ren (`x'_cpr `x'n) (type_cpr type)	
	cap noi save "$onedrive\Intermediate\tud_v3_`x'100_unimp.dta", replace
	}
	

	local 	type 		type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		
						

	forvalues y=1/$case {
	
	use "$onedrive\Intermediate\tud_v3_type_oth`y'_unimp.dta", clear	
	foreach x of local type		{
	cap noi append using "$onedrive\Intermediate\tud_v3_`x'`y'_unimp.dta"	
	}
	egen 	hh_actctype 		= 	rowtotal(hh_actc*)
	gen 	hh_actctypeday		=	hh_actctype/nr_days
	drop hh_actctype_* 
	save "$onedrive\Intermediate\tud_v3_type`y'_unimp.dta", replace								
	}
	
	use "$onedrive\Intermediate\tud_v3_type_oth100_unimp.dta", clear	
	foreach x of local type		{
	cap noi append using "$onedrive\Intermediate\tud_v3_`x'100_unimp.dta"
	}
	egen 	temp 			= 	rowtotal(hh_actc*)
	gen 	hh_actctype		=	(temp/$case)
	gen 	hh_actctypeday	=	temp/nr_daysall
	drop hh_actctype_* temp 
	save "$onedrive\Intermediate\tud_v3_type100_unimp.dta", replace	

	forvalues y=1/$case {
	cap noi use "$onedrive\Intermediate\tud_v3_type`y'_unimp.dta", clear
	cap noi drop if type_cpr <=20
	cap noi save "$onedrive\Intermediate\tud_v3_type`y'_trunc_unimp.dta", replace
	}

	forvalues y=1/$case {	
	cap noi use "$onedrive\Intermediate\tud_v3_type`y'_trunc_unimp.dta", clear
	append using "$onedrive\Intermediate\tud_v3_type100_unimp.dta"
	egen count = count(type), by(type)
	drop if count == 1
	drop count	
	cap noi save "$onedrive\Intermediate\tud_v3_type`y'_trunc_unimp.dta", replace	
	}

	forvalues y=1/$case {
	cap noi use "$onedrive\Intermediate\tud_v3_type`y'_unimp.dta", clear
	append using "$onedrive\Intermediate\tud_v3_type100_unimp.dta"
	cap noi save "$onedrive\Intermediate\tud_v4_type`y'_unimp.dta", replace
	}

	cap noi use "$onedrive\Intermediate\tud_v4_type1_unimp.dta", clear
	forvalues y=2/$case {
	append using "$onedrive\Intermediate\tud_v4_type`y'_unimp.dta"
	}
	bysort caseid type:  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup
	cap noi save "$onedrive\Intermediate\tud_v4_type_unimp.dta", replace


********************************************************************************


	use "$onedrive\Intermediate\tud_v2.dta", clear
	
*CREATE VARIABLE FOR NUMBER OF DAYS FOR EACH CASE

********************************************************************************
*						IMPORTANT												*
********************************************************************************

	keep if imp_act == 2
	
	*Total time recorded for all check-ins

	local 	analysis 	category_project	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						combined_categories 	
						
	*Total Time Values for each case
	gen 		totalctime						=	.	
	
	*Total Time Values for all users
	egen		totaltime			 			=	total(activity_duration)	
	foreach var of local analysis {	
	gen 		`var'_cpr						=	.
	gen 		hh_actc`var'					=	.

	*Total time spent on each activity for all users
	bysort		`var'		:													///
	egen 		hh_act`var' 					=	total(activity_duration)
	
	*Proportion of time spent on an activity over total time recorded on check-in for all users
	gen 		`var'_tpr						=	(hh_act`var'/totaltime)*100	

	*Total duration Values by cases
	
	*total amount of time spent by each case on each activity
	forvalues 	caseid 							= 1/$case {
		bysort 	`var' 			: 												///
		egen 	hh_act`caseid'					=	total(activity_duration)	///
							if caseid			==	`caseid' 	&				///
								`var'			!=	.
		
		*total amount of time spent by each case on all activities
		egen	total`caseid'time				=	total(activity_duration)	///
								if caseid		==	`caseid'
								
		*Proportion of time spent on each activity for a case		
		gen 	`var'_cpr`caseid'				=	(hh_act`caseid'/total`caseid'time)*100 ///
							if caseid 			== 	`caseid'		
							
		replace `var'_cpr						=	`var'_cpr`caseid'			///
							if	`var'_cpr		==	.
							
		*Total amount of time recorded for each case				
		replace totalctime						=	total`caseid'time    		///
						if 	totalctime			==	.
		
		*Number of hours spent by the case on each activity	
		bysort `var':															///
		replace hh_actc`var'					=	hh_act`caseid'				///
							if 	hh_actc`var'	==	.
						
		drop	`var'_cpr`caseid' total`caseid'time hh_act`caseid'
	}
	}
	
*THE SAME AS ABOVE BUT FOR TYPE VARIABLES	
local 	type			type_email 		type_meeting 		///
						type_strategy 		type_network 	type_develop_prj 	///
						type_hiring 		type_review_docs type_write 		///
						type_prep_ppt 		type_dta_analysis type_prj_mng 		///
						type_procure 		type_tm_mng 	type_int_report 	///
						type_career_dev 	type_ind_wrk 		type_oth

	foreach var of local type {	
	gen 		`var'_cpr						=	.
	gen 		hh_actc`var'					=	.
	
	*Total time spent on each activity for all users
	bysort		`var'		:													///
	egen 		hh_act`var' 					=	total(activity_duration)
	
	*Proportion of time spent on an activity over total time recorded on check-in for all users
	gen 		`var'_tpr						=	(hh_act`var'/totaltime)*100	

	*PAGE 2: Total duration Values by cases
	
	*total amount of time spent by each case on each activity
	forvalues 	caseid 							= 1/$case {
		egen 	hh_act`caseid'`var'				=	total(activity_duration)	///
							if caseid			==	`caseid' 	&				///
								`var'			==	1
		egen maxhh_act`caseid'`var' 			=	max(hh_act`caseid'`var')	///
							if caseid			==	`caseid' 	&				///
								`var'			==	1
		replace hh_act`caseid'`var'				= 	maxhh_act`caseid'`var'		///
							if caseid			==	`caseid'

		*Proportion of time spent on each activity for a case		
		gen 	`var'_cpr`caseid'				=	(hh_act`caseid'`var'/totalctime)*100 ///
							if caseid 			== 	`caseid'							
		replace `var'_cpr						=	`var'_cpr`caseid'			///
							if	`var'_cpr		==	.
								
		*Number of hours spent by the case on each activity	
		replace hh_actc`var'					=	hh_act`caseid'`var'			///
							if 	hh_actc`var'	==	.
						
		drop	`var'_cpr`caseid' hh_act`caseid'`var' maxhh_act`caseid'`var'
	}
	}
	save "$onedrive\Intermediate\tempa_imp.dta", replace

	use "$onedrive\Intermediate\tempa_imp.dta", clear
	
	local 	analysis 	category_project	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						combined_categories type_email 		type_meeting 		///
						type_strategy 		type_network 	type_develop_prj 	///
						type_hiring 		type_review_docs type_write 		///
						type_prep_ppt 		type_dta_analysis type_prj_mng 		///
						type_procure 		type_tm_mng 	type_int_report 	///
						type_career_dev 	type_ind_wrk 		type_oth							

	foreach var of local analysis {	
	preserve
	keep `var' `var'_tpr hh_act`var' totaltime nr_daysall	
	ren (`var'_tpr hh_act`var' totaltime) (`var'_cpr hh_actc`var' totalctime)
	drop if `var'_cpr ==.	| `var' == . | hh_actc`var' ==. | totalctime==.
	gen caseid = 100
	save "$onedrive\Intermediate\tempt`var'_imp.dta", replace
	restore
	}
	
	local 	analysis 	category_project	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth		

	foreach var of local analysis {	
	use "$onedrive\Intermediate\tempt`var'_imp.dta", clear
	collapse (max) `var'_cpr hh_actc`var' totalctime caseid nr_daysall, by(`var')
	save "$onedrive\Intermediate\tempt`var'_imp.dta", replace
	use "$onedrive\Intermediate\tempa_imp.dta", clear
	append using "$onedrive\Intermediate\tempt`var'_imp.dta"
	save "$onedrive\Intermediate\tempa_imp.dta", replace
	}
	
	use "$onedrive\Intermediate\tempa_imp.dta", clear

*Generating case name variable
	drop if caseid 	== .	
	replace casenme = 	"Staff Average"				if 		caseid 			==	100
		
*generating variable for activity with maximum hours spent by caseid
	cap noi drop 	temp
	
	gen type_activity_maxhh					=	.
	forvalues caseid = 1/100 {
	egen 	temp`caseid'		 			=	rowmax(hh_actctype_*)			///
					if caseid				==	`caseid'
	replace type_activity_maxhh				= 	temp`caseid'					///
					if type_activity_maxhh	==	.
	drop temp`caseid'
	}
	
	gen 	type_activity_max 			= 	""
	
	local 	type 		type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth		

	foreach x of local type		{
	decode `x', gen(`x'n)
	replace type_activity_max			=	`x'n								///
			if	type_activity_maxhh		==	hh_actc`x' 		&					///
				type_activity_max		==	""
				drop `x'n
			}

	encode type_activity_max, gen(type_activity_maxn)
	drop type_activity_max
	ren type_activity_maxn type_activity_max
	
	bysort caseid:																///
	egen 	temp						=	max(type_activity_max)
	replace type_activity_max			=	temp								///
				if type_activity_max	==	.	
	drop temp

	save "$onedrive\Intermediate\tud_v3_imp.dta", replace

	
	*generating dataset for type of activity
	
	local 	type 		type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth		

	foreach x of local type			{
	forvalues y = 1/$case	 			{
	use "$onedrive\Intermediate\tud_v3_imp.dta", clear	
	cap noi collapse (first) `x'_cpr hh_actc`x' casenme nr_days nr_daysall 		///
					if caseid 		== `y', by(caseid `x')
				
	cap noi drop 	if 	`x'			==	0 |										///
				`x'					==	.
	cap noi decode `x', gen(`x'n)
	cap noi drop `x'
	cap noi ren (`x'_cpr `x'n) (type_cpr type)	
	cap noi save "$onedrive\Intermediate\tud_v3_`x'`y'_imp.dta", replace
	}
	}
	
	foreach x of local type			{
	use "$onedrive\Intermediate\tud_v3_imp.dta", clear	
	cap noi collapse (first) `x'_cpr hh_actc`x' casenme nr_days nr_daysall 		///
					if caseid 				== 100, by(caseid `x')
					
	cap noi drop 	if 	`x'					==	0 |								///
				`x'							==	.
	cap noi decode `x', gen(`x'n)
	cap noi drop `x'
	cap noi ren (`x'_cpr `x'n) (type_cpr type)	
	cap noi save "$onedrive\Intermediate\tud_v3_`x'100_imp.dta", replace
	}
	

	local 	type 		type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		
						

	forvalues y=1/$case {
	
	use "$onedrive\Intermediate\tud_v3_type_oth`y'_imp.dta", clear	
	foreach x of local type		{
	cap noi append using "$onedrive\Intermediate\tud_v3_`x'`y'_imp.dta"	
	}
	egen 	hh_actctype 		= 	rowtotal(hh_actc*)
	gen 	hh_actctypeday		=	hh_actctype/nr_days
	drop hh_actctype_* 
	save "$onedrive\Intermediate\tud_v3_type`y'_imp.dta", replace								
	}
	
	use "$onedrive\Intermediate\tud_v3_type_oth100_imp.dta", clear	
	foreach x of local type		{
	cap noi append using "$onedrive\Intermediate\tud_v3_`x'100_imp.dta"
	}
	egen 	temp 			= 	rowtotal(hh_actc*)
	gen 	hh_actctype		=	(temp/$case)
	gen 	hh_actctypeday	=	temp/nr_daysall
	drop hh_actctype_* temp 
	save "$onedrive\Intermediate\tud_v3_type100_imp.dta", replace	

	forvalues y=1/$case {
	cap noi use "$onedrive\Intermediate\tud_v3_type`y'_imp.dta", clear
	cap noi drop if type_cpr <=20
	cap noi save "$onedrive\Intermediate\tud_v3_type`y'_trunc_imp.dta", replace
	}

	forvalues y=1/$case {	
	cap noi use "$onedrive\Intermediate\tud_v3_type`y'_trunc_imp.dta", clear
	append using "$onedrive\Intermediate\tud_v3_type100_imp.dta"
	egen count = count(type), by(type)
	drop if count == 1
	drop count
	
	cap noi save "$onedrive\Intermediate\tud_v3_type`y'_trunc_imp.dta", replace	
	}

	forvalues y=1/$case {
	cap noi use "$onedrive\Intermediate\tud_v3_type`y'_imp.dta", clear
	append using "$onedrive\Intermediate\tud_v3_type100_imp.dta"
	cap noi save "$onedrive\Intermediate\tud_v4_type`y'_imp.dta", replace
	}

	cap noi use "$onedrive\Intermediate\tud_v4_type1_imp.dta", clear
	forvalues y=2/$case {
	append using "$onedrive\Intermediate\tud_v4_type`y'_imp.dta"
	}
	bysort caseid type:  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup
	cap noi save "$onedrive\Intermediate\tud_v4_type_imp.dta", replace





	

	
