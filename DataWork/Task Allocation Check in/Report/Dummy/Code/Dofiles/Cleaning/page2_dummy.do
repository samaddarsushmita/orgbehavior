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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Task Allocation Check in\Report\Dummy\Code\Dofiles\Cleaning"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Report\Dummy\Datasets"
	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
set more off

global date `'
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Report\Dummy\Outputs\Raw"


global case 2


use "$onedrive\Intermediate\tud_dummy_v2.dta", clear

*CREATE VARIABLE FOR NUMBER OF DAYS FOR EACH CASE
bysort 	caseid:																	///
egen 	nr_days 	=	count(caseid)											
egen 	nr_daysall	=	count(caseid)
********************************************************************************
*						PART 4: VARIABLES FOR PAGE 2						   *
********************************************************************************
	
	local 	analysis 	category_project	withsomeone 	admin_activity		///
						planned 			importance 		imp_act				///
						type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth
	

	foreach var of local analysis {	
	gen 		`var'_cpr						=	.
	gen 		hh_actc`var'					=	.
	gen 		totalctime_`var'					=	.
	egen		totaltime_`var'					=	total(activity_duration)	///
					if `var'					!=	.

	*PAGE 2: Total Time Values for all users
	bysort		`var'		:													///
	egen 		hh_act`var' 					=	total(activity_duration)
	
	gen 		`var'_tpr						=	(hh_act`var'/totaltime_`var')*100	

	*PAGE 2: Total Time Values by cases

	forvalues 	caseid 							= 1/2 {
		bysort 	`var' 			: 												///
		egen 	hh_act`caseid'					=	total(activity_duration)	///
							if caseid			==	`caseid' 	&				///
								`var'			!=	.
		
		egen	total`caseid'time_`var'			=	total(activity_duration)	///
								if `var'		!=	. 	&						///
								caseid			==	`caseid'
		
		gen 	`var'_cpr`caseid'				=	(hh_act`caseid'/total`caseid'time_`var')*100 ///
							if caseid 			== 	`caseid'
								
		replace `var'_cpr						=	`var'_cpr`caseid'			///
							if	`var'_cpr		==	.
		
		replace totalctime_`var'				=	total`caseid'time_`var'		///
						if 	totalctime_`var'	==	.
						
		replace hh_actc`var'					=	hh_act`caseid'				///
							if 	hh_actc`var'	==	.
						
		drop	`var'_cpr`caseid' total`caseid'time_`var' hh_act`caseid'
	}
	}
	save "$onedrive\Intermediate\tempa.dta", replace

	*PAGE 2: generating a new caseid which will hold all case data
	use "$onedrive\Intermediate\tempa.dta", clear
	
	local 	analysis 	category_project	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth

						

	foreach var of local analysis {	
	preserve
	keep `var' `var'_tpr hh_act`var' totaltime_`var' nr_daysall	
	ren (`var'_tpr hh_act`var' totaltime_`var') (`var'_cpr hh_actc`var' totalctime_`var')
	drop if `var'_cpr ==.	| `var' == . | hh_actc`var' ==. | totalctime_`var'==.
	gen caseid = 100
	save "$onedrive\Intermediate\tempt`var'.dta", replace
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
	use "$onedrive\Intermediate\tempt`var'.dta", clear
	collapse (max) `var'_cpr hh_actc`var' totalctime_`var' caseid nr_daysall, by(`var')
	save "$onedrive\Intermediate\tempt`var'.dta", replace
	use "$onedrive\Intermediate\tempa.dta", clear
	append using "$onedrive\Intermediate\tempt`var'.dta"
	save "$onedrive\Intermediate\tempa.dta", replace
	}

	local 	analysis 	category_project	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth

*Generating case name variable
	drop if caseid 	== .	
	gen 	casenme	=	""
	replace casenme = 	" Lisa Simpson"			if 		caseid 			==	1
	replace casenme = 	" Velma Dinkley"		if 		caseid 			==	2
	replace casenme = 	"All Cases"				if 		caseid 			==	100
	
	tab hh_actctype_email if caseid==1
	
	*filling all observations with max value for hh_actctype_*
	local 	analysis 	type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth
	
	foreach var of local analysis {	

	bysort 	caseid:																///
	egen 	temp`var' 						=	max(hh_actc`var')
	
	drop 	hh_actc`var'
	
	ren 	temp`var'  hh_actc`var'
	}
	
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

	save "$onedrive\Intermediate\tud_dummy_v3.dta", replace

	*generating dataset for type of activity
	
	local 	type 		type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth

	foreach x of local type			{
	forvalues y = 1/2	 			{
	use "$onedrive\Intermediate\tud_dummy_v3.dta", clear	
	cap noi collapse (first) `x'_cpr hh_actc`x' casenme nr_days nr_daysall 		///
					if caseid 		== `y', by(caseid `x')
				
	cap noi drop 	if 	`x'			==	0 |										///
				`x'					==	.
	cap noi decode `x', gen(`x'n)
	cap noi drop `x'
	cap noi ren (`x'_cpr `x'n) (type_cpr type)	
	cap noi save "$onedrive\Intermediate\tud_dummy_v3_`x'`y'.dta", replace
	}
	}
	
	foreach x of local type			{
	use "$onedrive\Intermediate\tud_dummy_v3.dta", clear	
	cap noi collapse (first) `x'_cpr hh_actc`x' casenme nr_days nr_daysall 		///
					if caseid 				== 100, by(caseid `x')
					
	cap noi drop 	if 	`x'					==	0 |								///
				`x'							==	.
	cap noi decode `x', gen(`x'n)
	cap noi drop `x'
	cap noi ren (`x'_cpr `x'n) (type_cpr type)	
	cap noi save "$onedrive\Intermediate\tud_dummy_v3_`x'100.dta", replace
	}
	

	local 	type 		type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 	
						

	forvalues y=1/$case {
	
	use "$onedrive\Intermediate\tud_dummy_v3_type_oth`y'.dta", clear	
	foreach x of local type		{
	cap noi append using "$onedrive\Intermediate\tud_dummy_v3_`x'`y'.dta"	
	}
	egen 	hh_actctype 		= 	rowtotal(hh_actc*)
	gen 	hh_actctypeday		=	hh_actctype/nr_days
	drop hh_actctype_* 
	save "$onedrive\Intermediate\tud_dummy_v3_type`y'.dta", replace								
	}
	
	use "$onedrive\Intermediate\tud_dummy_v3_type_oth100.dta", clear	
	foreach x of local type		{
	cap noi append using "$onedrive\Intermediate\tud_dummy_v3_`x'100.dta"
	}
	egen 	temp 			= 	rowtotal(hh_actc*)
	gen 	hh_actctype		=	(temp/$case)
	gen 	hh_actctypeday	=	temp/nr_daysall
	drop hh_actctype_* temp 
	save "$onedrive\Intermediate\tud_dummy_v3_type100.dta", replace	

	forvalues y=1/$case {
	cap noi use "$onedrive\Intermediate\tud_dummy_v3_type`y'.dta", clear
	cap noi drop if type_cpr <=20
	cap noi save "$onedrive\Intermediate\tud_dummy_v3_type`y'_trunc.dta", replace
	}

	forvalues y=1/$case {	
	cap noi use "$onedrive\Intermediate\tud_dummy_v3_type`y'_trunc.dta", clear
	append using "$onedrive\Intermediate\tud_dummy_v3_type100.dta"
	egen count = count(type), by(type)
	drop if count == 1
	drop count
	
	cap noi save "$onedrive\Intermediate\tud_dummy_v3_type`y'_trunc.dta", replace	
	}

	forvalues y=1/$case {
	cap noi use "$onedrive\Intermediate\tud_dummy_v3_type`y'.dta", clear
	append using "$onedrive\Intermediate\tud_dummy_v3_type100.dta"
	cap noi save "$onedrive\Intermediate\tud_dummy_v4_type`y'.dta", replace
	}

	cap noi use "$onedrive\Intermediate\tud_dummy_v4_type1.dta", clear
	forvalues y=2/$case {
	append using "$onedrive\Intermediate\tud_dummy_v4_type`y'.dta"
	}
	cap noi save "$onedrive\Intermediate\tud_dummy_v4_type.dta", replace


