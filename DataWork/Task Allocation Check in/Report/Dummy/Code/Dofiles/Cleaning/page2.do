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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Task Allocation Check in\Report\Code\Dofiles\Cleaning"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Report\Datasets"
	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
set more off

global date `'
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Report\Outputs\Raw"

use "$onedrive\Intermediate\tud_11182019_v2.dta", clear

********************************************************************************
*						PART 4: VARIABLES FOR PAGE 2						   *
********************************************************************************
	
	local 	analysis 	category_project										///
						type_activity 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {	
	gen 		`var'_cpr						=	.
	gen 		totalctime_`var'				=	.
	gen 		hh_actc`var'					=	.
	
	*PAGE 2: Total Time Values for all users
	bysort		`var'		:													///
	egen 		hh_act`var' 					=	total(activity_duration)
	
	egen		totaltime_`var'					=	total(activity_duration)	///
								if `var'		!=	. 							

	gen 		`var'_tpr						=	(hh_act`var'/totaltime_`var')*100	

	*PAGE 2: Total Time Values by cases

	forvalues 	caseid 							= 1/5 {
		bysort 	`var' 			: 												///
		egen 	hh_act`caseid'					=	total(activity_duration)	///
								if caseid		==	`caseid' &					///
								`var'			!=	.
		
		egen	total`caseid'time_`var'			=	total(activity_duration)	///
								if `var'		!=	. 	&						///
								caseid			==	`caseid'
		
		gen 	`var'_cpr`caseid'				=	(hh_act`caseid'/total`caseid'time_`var')*100 ///
								if	caseid		==	`caseid'
								
		replace `var'_cpr						=	`var'_cpr`caseid'			///
					if	`var'_cpr				==	.
		
		replace totalctime_`var'				=	total`caseid'time_`var'		///
						if 	totalctime_`var'	==	.
						
		replace hh_actc`var'					=	hh_act`caseid'				///
						if 	hh_actc`var'		==	.
						
		drop	`var'_cpr`caseid' total`caseid'time_`var' hh_act`caseid'
	}
	}
	save "$onedrive\Intermediate\tempa.dta", replace

	*PAGE 2: generating a new caseid which will hold all case data
	use "$onedrive\Intermediate\tempa.dta", clear
	
	local 	analysis 	category_project										///
						type_activity 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {	
	preserve
	keep `var' `var'_tpr hh_act`var' totaltime_`var' 	
	ren (`var'_tpr hh_act totaltime_`var') (`var'_cpr hh_actc`var' totalctime_`var')
	drop if `var'_cpr ==.	| `var' == . | hh_actc`var' ==. | totalctime_`var'==.
	gen caseid = 100
	save "$onedrive\Intermediate\tempt`var'.dta", replace
	restore
	}
	
	local 	analysis 	category_project										///
						type_activity 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {	
	use "$onedrive\Intermediate\tempt`var'.dta", clear
	collapse (max) `var'_cpr hh_actc`var' totalctime_`var' caseid, by(`var')
	save "$onedrive\Intermediate\tempt`var'.dta", replace
	use "$onedrive\Intermediate\tempa.dta", clear
	append using "$onedrive\Intermediate\tempt`var'.dta"
	save "$onedrive\Intermediate\tempa.dta", replace
	}

	local 	analysis 	category_project										///
						type_activity 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {		
	*PAGE 2: Round to two decimals
	replace `var'_cpr			=round(`var'_cpr, 2)
	replace hh_actc`var' 		=round(hh_actc`var', 2)
	replace totalctime_`var'	=round(totalctime_`var', 2)
	}

*Generating case name variable
	drop if caseid == .
	
	gen 	casenme	=	""
	replace casenme = 	"Dan Rogger"		if 		caseid 			==	1
	replace casenme = 	"Kerenssa M. Kay"	if 		caseid 			==	2
	replace casenme = 	"Leyla Castillo"	if 		caseid 			==	3
	replace casenme = 	"Sushmita Samaddar"	if 		caseid 			==	4
	replace casenme = 	"Vincenzo Di Maro"	if 		caseid 			==	5
	replace casenme = 	"All Cases"			if 		caseid 			==	100

		
	save "$onedrive\Intermediate\tud_11182019_v3.dta", replace

