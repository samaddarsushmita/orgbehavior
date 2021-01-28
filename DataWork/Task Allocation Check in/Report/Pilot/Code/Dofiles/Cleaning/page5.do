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
global case 12
********************************************************************************
*						PART 4: TIME TREND FOR LONG TIME USERS					*
********************************************************************************
	use "$onedrive\Intermediate\tud_v3.dta", clear
	cap noi drop _merge
	save "$onedrive\Intermediate\tud_v3.dta", replace
	forvalues 	case	= 1/$case	{
	preserve 
	keep if 	caseid 	== `case'
	collapse (first) caseid, by(submissiondate)
	sort 		submissiondate
	gen 		day		=	_n
	save "$onedrive\Intermediate\temp_day_`case'.dta", replace
	restore
	}
	use "$onedrive\Intermediate\temp_day_1.dta", clear
	forvalues 	case	= 2/$case	{
	append using "$onedrive\Intermediate\temp_day_`case'.dta"
	}
	save "$onedrive\Intermediate\tud_timetrend.dta", replace
	merge m:m submissiondate caseid using "$onedrive\Intermediate\tud_v3.dta"

	gen 		workweek	=	.
	forvalues 	weeks 		=	1/100	{
	bysort 		caseid: 														///
	replace		workweek 	=	`weeks'											///
			if	day 		<=	5*`weeks'										///
			&	workweek	==	.
	}
	
	****************************************************************************
	*					Weekly activity duration								*
	*****************************************************************************
		*Total time recorded for all check-ins
rename (planned withsomeone admin_activity imp_act) (unplanned meetings administrative unimportant)	
		
	local 	analysis 	meetings 	administrative 		///					
						unplanned  		unimportant			 	
						
	*Total Time Values for each case
	gen 		totalctime_week						=	.	
	
	*Total Time Values for all users
	bysort		workweek:														///
	egen		totaltime_week			 			=	total(activity_duration)	
	foreach var of local analysis {	
	gen 		`var'_cpr_week						=	.
	gen 		hh_actc`var'_week					=	.

	*Total time spent on each activity for all users
	bysort		`var'	workweek	:													///
	egen 		hh_act`var'_week 				=	total(activity_duration)
	
	*Proportion of time spent on an activity over total time recorded on check-in for all users
	gen 		`var'_tpr_week					=	(hh_act`var'_week/totaltime_week)*100	

	*Total duration Values by cases
	
	*total amount of time spent by each case on each activity
	forvalues 	caseid 							= 1/$case {
		bysort 	`var' workweek			: 												///
		egen 	hh_act`caseid'_week					=	total(activity_duration)	///
							if caseid				==	`caseid' 	&				///
								`var'				!=	.
		
		*total amount of time spent by each case on all activities
		bysort workweek	:														///
		egen	total`caseid'time_week				=	total(activity_duration)	///
								if caseid			==	`caseid'
								
		*Proportion of time spent on each activity for a case		
		gen 	`var'_cpr`caseid'_week				=	(hh_act`caseid'_week/total`caseid'time_week)*100 ///
							if caseid 				== 	`caseid'		
							
		replace `var'_cpr_week						=	`var'_cpr`caseid'_week			///
							if	`var'_cpr_week		==	.
							
		*Total amount of time recorded for each case				
		replace totalctime_week						=	total`caseid'time_week    		///
						if 	totalctime_week			==	.
		
		*Number of hours spent by the case on each activity	
		bysort `var' workweek:															///
		replace hh_actc`var'_week					=	hh_act`caseid'_week				///
							if 	hh_actc`var'_week	==	.
						
		drop	`var'_cpr`caseid'_week total`caseid'time_week hh_act`caseid'_week
	}
	}
	save "$onedrive\Intermediate\tud_timetrend_v2.dta", replace

	local var 	unplanned														///
				meetings														///
				administrative													///
				unimportant
foreach x of local var 	{
	replace 	`x'_cpr_week		=	0										///
		if 		`x'					!=	1
	replace 	hh_actc`x'_week		=	0										///
		if		`x'					!=	1
	replace 	`x'					=	1										///
		if		`x'					!=	1
bysort	caseid workweek:														///
	egen 		max`x'_cpr_week		=	max(`x'_cpr_week)	
	replace 	`x'_cpr_week		= 	max`x'_cpr_week
drop max`x'_cpr_week
tab `x'_cpr_week workweek if caseid==1
bysort	caseid workweek:														///
	egen 		maxhh_actc`x'_week	=	max(hh_actc`x'_week)	
	replace 	hh_actc`x'_week		= 	maxhh_actc`x'_week
drop maxhh_actc`x'_week
tab hh_actc`x'_week workweek if caseid==1
}
save "$onedrive\Intermediate\tud_timetrend_v3.dta", replace
	local var 	unplanned														///
				meetings														///
				administrative													///
				unimportant
foreach x of local var 	{
	forvalues 	case	= 1/$case	{	
	preserve 
	keep if 	caseid 	== `case'
	collapse (first) hh_actc`x'_week `x'_cpr_week, by(workweek caseid)
	gen 	hh_actc_week		=	hh_actc`x'_week
	gen 	cpr_week			=	`x'_cpr_week
	gen 	category			=	"`x'"
	save "$onedrive\Intermediate\timetrend_`x'_`case'.dta", replace
	restore
	}
	}
	local var 	unplanned														///
				meetings														///
				administrative													///
				unimportant
	foreach x of local var 	{
	use "$onedrive\Intermediate\timetrend_`x'_1.dta", clear
	forvalues 	case	= 2/$case	{
	append using "$onedrive\Intermediate\timetrend_`x'_`case'.dta"
	}
	save "$onedrive\Intermediate\timetrend_`x'.dta", replace
}

	use "$onedrive\Intermediate\timetrend_unplanned.dta", clear
	local var 	meetings														///
				administrative													///
				unimportant
	foreach x of local var 	{
	append using "$onedrive\Intermediate\timetrend_`x'.dta"
}	
	local var 	unplanned														///
				meetings														///
				administrative													///
				unimportant
	foreach x of local var 	{
drop 	hh_actc`x'_week `x'_cpr_week
}

label 	define 	workweeklbl 			1 	"Week 1"			 			///
										2 	"Week 2"						///
										3	"Week 3"						///
										4	"Week 4"						///
										5	"Week 5"							
	label 	values	workweek				workweeklbl

	save "$onedrive\Intermediate\timetrend.dta", replace

																	

	
	

