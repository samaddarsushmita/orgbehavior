
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


********************************************************************************
*						PART 5: TABLES FOR PAGE 4								*
********************************************************************************
	use "$onedrive\Intermediate\tud_dummy_v3.dta", clear
	
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
	
	forvalues x							=	1/100	{
	
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
	save "$onedrive\Intermediate\tud_dummy_v5.dta", replace
	
	local 	analysis 	category_project										///
						withsomeone 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {	

	use "$onedrive\Intermediate\tud_dummy_v5.dta", clear

	collapse (first) 	instancec`var' 		freq_cinstance`var' 				///
						hh_actc`var' 		avg_hhc`var' 						///
						`var'_cpr			casenme,							///
						by(`var' caseid)
						
	save "$onedrive\Intermediate\df_dummy_`var'.dta", replace
	}
	
	local 	analysis 	category_project										///
						withsomeone 											///
						admin_activity 											///
						planned 												///
						importance imp_act

	foreach var of local analysis {		
	use "$onedrive\Intermediate\tud_dummy_v5.dta", clear

	collapse (first) 	instancec`var' 		freq_cinstance`var' 				///
						hh_actc`var' 		avg_hhc`var' 						///
						`var'_cpr			casenme,							///
						by(`var' caseid)
						
	save "$onedrive\Intermediate\df_dummy_`var'.dta", replace
	}

	
