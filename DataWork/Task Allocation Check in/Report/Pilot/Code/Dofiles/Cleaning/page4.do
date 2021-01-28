
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
*						PART 5: TABLES FOR PAGE 4								*
********************************************************************************
	use "$onedrive\Intermediate\tud_v3.dta", clear
	
	/*DATA TO ADD ON TABLES 
	Analysis								|FOR					|BY
	****************************************************************************
	Instances 								|category_project		|All users
	Frequency (in %)						|type_activity			|Case
	Total Time Spent in Hours				|admin_activity
	Average Duration						|importance
	As a proportion of total time recorded*/
	
	*Average Duration
		
	local 	analysis 	category_project										///
						withsomeone 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {	
	
	gen 	instancec`var'				=	.	
	gen 	instancet`var'				=	.
	
	forvalues x							=	1/$case	{
	
	bysort 	`var':																///	
	egen 	instance`var'`x'			= 	count(`var')						///
						if 	caseid		==	`x'
						
	egen 	instancet`var'`x'			=	count(`var')						///
						if 	caseid		==	`x'
						
	replace instancec`var'				=	instance`var'`x'					///
					if	instancec`var'	==	.
					
	replace instancet`var'				=	instancet`var'`x'					///
					if	instancet`var'	==	.
	drop instancet`var'`x' instance`var'`x'
	}
	}
	local 	analysis 	category_project										///
						withsomeone 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {	
	gen 	avg_hhc`var'				=	hh_actc`var'/instancec`var'
	gen 	freq_cinstance`var'			=	(instancec`var'/instancet`var')*100
	
	}
	
	****************************************************************************
	*								Staff Average									*
	****************************************************************************
		*Average Duration
		
	local 	analysis 	category_project										///
						withsomeone 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {			
	bysort 	`var':																///	
	egen 	instance`var'				= 	count(`var')	
						
	egen 	instancet`var'all			=	count(`var')
	}
	
	local 	analysis 	category_project										///
						withsomeone 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {	
	gen 	avg_hh`var'					=	hh_act`var'/instance`var'
	gen 	freq_instance`var'			=	(instance`var'/instancet`var'all)*100
	gen `var'_pr						=	`var'_cpr							///
				if caseid				==	100
	bysort `var': egen max`var'_pr		=	max(`var'_pr)
	drop `var'_pr
	ren max`var'_pr `var'_pr
	replace hh_act`var'					=	hh_act`var'/$case
	}
	save "$onedrive\Intermediate\tud_v5.dta", replace
	
	local 	analysis 	category_project										///
						withsomeone 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {	

	use "$onedrive\Intermediate\tud_v5.dta", clear

	collapse (first) 	instancec`var' 		instance`var'						///
						freq_cinstance`var' freq_instance`var'					///
						hh_actc`var' 		hh_act`var' 						///
						avg_hhc`var' 		avg_hh`var'							///
						`var'_cpr			`var'_pr							///
						casenme,			by(`var' caseid)
						
	save "$onedrive\Intermediate\df_`var'.dta", replace
	}
	
	use "$onedrive\Intermediate\tud_v2.dta", clear
	
	keep caseid activity_descr withsomeone category_project admin_activity 		///
	planned importance activity_duration
	save "$onedrive\Intermediate\df_act.dta", replace
	

	



