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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Task Allocation Check in\Dummy\Dofiles\Cleaning"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Dummy\Datasets"
	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
set more off

global date `'
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Dummy\Outputs"


********************************************************************************
*							OBJECTIVE											*
*	1.	Unit based description of 
*		a. 	Planned vs Unplanned
*		b.	Administrative vs Technical
*		c.	Meetings vs Independent Work	
*		d.	Important vs Unimportant
*		e. 	Most popular type of activity
*	2

use "$onedrive\Intermediate\dummy_tud_v2.dta", replace
tab caseid
gl 	case 200
********************************************************************************
*					*GENERATING PROPORTIONS FOR ACTIVITIES						   *
********************************************************************************

	*Total time recorded for all check-ins

	local 	analysis 	withsomeone 	admin_activity 		///					
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
	save "$onedrive\Intermediate\tempa.dta", replace

	*PAGE 2: generating a new caseid which will hold all case data
	use "$onedrive\Intermediate\tempa.dta", clear
	
	local 	analysis 	withsomeone 	admin_activity 		///					
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
	save "$onedrive\Intermediate\tempt`var'.dta", replace
	restore
	}
	
	local 	analysis 	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						combined_categories type_email 		type_meeting 		///
						type_strategy 		type_network 	type_develop_prj 	///
						type_hiring 		type_review_docs type_write 		///
						type_prep_ppt 		type_dta_analysis type_prj_mng 		///
						type_procure 		type_tm_mng 	type_int_report 	///
						type_career_dev 	type_ind_wrk 		type_oth		

	foreach var of local analysis {	
	use "$onedrive\Intermediate\tempt`var'.dta", clear
	collapse (max) `var'_cpr hh_actc`var' totalctime caseid nr_daysall, by(`var')
	save "$onedrive\Intermediate\tempt`var'.dta", replace
	use "$onedrive\Intermediate\tempa.dta", clear
	append using "$onedrive\Intermediate\tempt`var'.dta"
	save "$onedrive\Intermediate\tempa.dta", replace
	}

	local 	analysis 	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						combined_categories type_email 		type_meeting 		///
						type_strategy 		type_network 	type_develop_prj 	///
						type_hiring 		type_review_docs type_write 		///
						type_prep_ppt 		type_dta_analysis type_prj_mng 		///
						type_procure 		type_tm_mng 	type_int_report 	///
						type_career_dev 	type_ind_wrk 		type_oth		

*Generating case name variable
	drop if caseid 	== .	
	replace casenme = 	"Staff Average"				if 		caseid 			==	100
	
	tab hh_actctype_email if caseid==1
	
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

	save "$onedrive\Intermediate\dummy_tud_v3.dta", replace

*PREPPING VARIABLES FOR BAR GRAPH
use "$onedrive\Intermediate\dummy_tud_v3.dta", replace

*UNPLANNED
bysort caseid:																	///
	gen 	unplanned_p				=	planned_cpr								///
		if	planned 				== 	1	
	*by division
	bysort division:															///
	gen 	unplanned_dp			=	planned_cpr								///
		if	planned 				== 	1	

*MEETING
bysort caseid:																	///
	gen 	meeting_p				=	withsomeone_cpr							///
		if	withsomeone 			== 	1

	*by division
	bysort division:															///
	gen 	meeting_dp				=	withsomeone_cpr							///
		if	withsomeone 			== 	1

*ADMIN		
bysort caseid:																	///
	gen 	admin_p					=	admin_activity_cpr						///
		if	admin_activity 			== 	1

	*by division
	bysort division:															///
	gen 	admin_dp					=	admin_activity_cpr						///
		if	admin_activity 			== 	1
		
*IMPORTANT		
bysort caseid:																	///
	gen 	unimp_act_p				=	imp_act_cpr								///
		if	imp_act 				== 	1

	*by division
	bysort division:															///
	gen 	unimp_act_dp			=	imp_act_cpr								///
		if	imp_act 				== 	1

********************************************************************************
*					MENU OF TASKS 												*
*	1.	Email: 				type_email
*	2.	Meeting: 			type_meeting 
*	3.	Strategy:			type_strategy 
*	4.	Network: 			type_network 
*	5.	Develop Proj		type_develop_prj
*	6.	Hiring				type_hiring 
*	7.	Review Docs 		type_review_docs 
*	8. 	Writing 			type_write 
*	9.	Preparing PPT 		type_prep_ppt 
*	10.	Data Analysis 		type_dta_analysis 
*	11.	Project Mngmt 		type_prj_mng 
*	12. Procurement 		type_procure 
*	13. Team Mngmt 			type_tm_mng 
*	14. Internal Report 	type_int_report 
*	15. Career Dev 			type_career_dev 
*	16. Independent Work 	type_ind_wrk	
********************************************************************************

local type 	type_email type_meeting type_strategy type_network type_develop_prj ///
			type_hiring type_review_docs type_write type_prep_ppt type_dta_analysis ///
			type_prj_mng type_procure type_tm_mng type_int_report type_ind_wrk
foreach x of local type {
bysort caseid:																	///
	gen 	`x'_p			=	`x'_cpr								///
		if	`x'				== 	1
}			

label 		var		type_email_p 		"Emails" 
label 		var 	type_meeting_p 		"Meetings"	
label  		var 	type_strategy_p 	"Brainstorming"
label 		var 	type_network_p 		"Networking" 
label  		var   	type_develop_prj_p 	"Developing Future Projects"
label    	var   	type_hiring_p 		"Hiring"
label  		var  	type_review_docs_p 	"Reviewing documents"
label   	var   	type_write_p 		"Writing"	
label   	var   	type_prep_ppt_p 	"Preparing a Presentation" 
label   	var  	type_dta_analysis_p "Data Analysis"
label   	var  	type_prj_mng_p 		"Project Management"
label    	var   	type_procure_p 		"Procurement"
label    	var   	type_tm_mng_p 		"Team Management"
label    	var   	type_int_report_p 	"Internal Reporting"
label     	var    	type_ind_wrk_p	 	"Independent Work"
					 
save "$onedrive\Intermediate\dummy_tud_v4.dta", replace


********************************************************************************
*						PART 4: TIME TREND FOR LONG TIME USERS-WEEKS					*
********************************************************************************
	use "$onedrive\Intermediate\dummy_tud_v4.dta", clear
	cap noi drop _merge
	save "$onedrive\Intermediate\dummy_tud_v4.dta", replace
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
	save "$onedrive\Intermediate\dummy_tud_timetrend.dta", replace
	merge m:m submissiondate caseid using "$onedrive\Intermediate\dummy_tud_v4.dta"

	gen 		workweek	=	.
	forvalues 	weeks 		=	1/3	{
	bysort 		caseid: 														///
	replace		workweek 	=	`weeks'											///
			if	day 		<=	5*`weeks'										///
			&	workweek	==	.
	}
	save "$onedrive\Intermediate\dummy_tud_v5.dta", replace
	/****************************************************************************
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
	save "$onedrive\Intermediate\dummy_tud_timetrend_v2.dta", replace

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
save "$onedrive\Intermediate\dummy_tud_timetrend_v3.dta", replace
	local var 	unplanned														///
				meetings														///
				administrative													///
				unimportant
foreach x of local var 	{
	forvalues 	case	= 1/$case	{	
	preserve 
	keep if 	caseid 	== `case'
	collapse (first) hh_actc`x'_week `x'_cpr_week unit division, by(workweek caseid)
	gen 	hh_actc_week		=	hh_actc`x'_week
	gen 	cpr_week			=	`x'_cpr_week
	gen 	category			=	"`x'"
	save "$onedrive\Intermediate\dummy_timetrend_`x'_`case'.dta", replace
	restore
	}
	}
	local var 	unplanned														///
				meetings														///
				administrative													///
				unimportant
	foreach x of local var 	{
	use "$onedrive\Intermediate\dummy_timetrend_`x'_1.dta", clear
	forvalues 	case	= 2/$case	{
	append using "$onedrive\Intermediate\dummy_timetrend_`x'_`case'.dta"
	}
	save "$onedrive\Intermediate\dummy_timetrend_`x'.dta", replace
}

	use "$onedrive\Intermediate\dummy_timetrend_unplanned.dta", clear
	local var 	meetings														///
				administrative													///
				unimportant
	foreach x of local var 	{
	append using "$onedrive\Intermediate\dummy_timetrend_`x'.dta"
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

*UNPLANNED CPR VARIABLE 
bysort caseid: 																	///
	gen 	unplanned_cpr_week 	=	cpr_week									///
		if 	category			==	"unplanned"		
	*by division
forvalues 	x=1/5					{	
	bysort caseid: 																	///
	egen 	unplanned_d`x'_week 	=	mean(cpr_week)									///
		if 	category				==	"unplanned"									///
		&	division				==	`x'
}
	
*MEETINGS CPR VARIABLE 		
bysort caseid: 																	///
	gen 	meetings_cpr_week 	=	cpr_week									///
		if 	category			==	"meetings"	
		
	*by division
forvalues 	x=1/5					{	
	bysort caseid: 																	///
	egen 	meetings_d`x'_week 		=	mean(cpr_week)									///
		if 	category				==	"meetings"									///
		&	division				==	`x'
}

*ADMINISTRATIVE CPR VARIABLE 		
bysort caseid: 																	///
	gen 	admin_cpr_week 	=	cpr_week										///
		if 	category			==	"administrative"		

	*by division
forvalues 	x=1/5					{	
	bysort caseid: 																	///
	egen 	admin_d`x'_week 		=	mean(cpr_week)									///
		if 	category				==	"administrative"									///
		&	division				==	`x'
}
*UNIMPORTANT CPR VARIABLE 		
bysort caseid: 																	///
	gen 	unimp_cpr_week 		=	cpr_week									///
		if 	category			==	"unimportant"		
		
	*by division
forvalues 	x=1/5					{	
	bysort caseid: 																	///
	egen 	unimp_d`x'_week 		=	mean(cpr_week)									///
		if 	category				==	"unimportant"									///
		&	division				==	`x'
}

		
save "$onedrive\Intermediate\dummy_timetrend.dta", replace

	
	
