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

import excel "$onedrive\Raw\Time Use Diagnostic_11182019.xlsx", 					///
														sheet ("Sheet1") 		///
														firstrow				///
														clear
														
save "$onedrive\Intermediate\tud_11182019.dta", replace

use "$onedrive\Intermediate\tud_11182019.dta", clear

/*cases
	Case 1: 	Dan Rogger
	Case 2:		Kerenssa M. Kay
	Case 3: 	Leyla Castillo
	Case 4: 	Sushmita Samaddar
	Case 5: 	Vincenzo Di Maro
*/
*rename variable
ren collaborative_activity type_activity

*Generating short importance scale
gen 	imp_act 								= 	.
replace imp_act									=	1		///
							if 	importance		==	1|							///
								importance		==	2|							///
								importance 		==	3

replace imp_act									=	2							///
							if 	importance		==	4|							///
								importance		==	5|							///
								importance 		==	6

*Labelling values
label 	define 	category_projectlbl 	1 	"Lending"							///
										2 	"Analytical"						///
										3 	"Standard"							///
										4 	"Other"								///
										5	"Personal Activity"					///
										6	"Haven't started work today"

label 	define 	other_catprojectlbl 	1 	"Checking emails/Calendar"			///
										2 	"Having an informal chat"			///
										3 	"Networking/Mentoring"				///
										4 	"Working on a potential project"	///
										5	"Hiring/Recruitment activities"		///
										6	"Meeting with supervisor/manager"	///
										7	"Unit or team meeting"				///
										-9	"Other"
	
label 	define 	type_activitylbl 		1 	"Meetings"				 			///
										2 	"Independent"				 		///
										-9	"Other"

label 	define 	admin_activitylbl 		1 	"Administrative"			 		///
										2 	"Project Related"				 	///
										3	"Other"

label 	define 	plannedlbl 				1 	"Unplanned"			 		///
										2 	"Planned"				 	///
										-9	"Other"

label 	define 	importancelbl 			1 	"Very unimportant"			 		///
										2 	"Mostly unimportant"				 	///
										3	"Slightly unimportant"				///
										4	"Slightly important"				///
										5	"Mostly important"					///
										6	"Very important"					///

	label 	define 	imp_actlbl 			1 	"Unimportant"			 			///
										2 	"Important"				 			


foreach var in 	category_project	other_catproject							///
				type_activity		admin_activity								///
				planned		importance	 imp_act {

label 	values	`var'				`var'lbl
}

*setting dates

local datetimes SubmissionDate starttime endtime

	foreach datetime of local datetimes {
		cap noi gen 	`datetime'n				=	clock(`datetime', "YMD#hms#")
		cap noi gen		`datetime'n_temp		=	date(`datetime'	, "YMD#hms#")
		format	`datetime'n		`datetime'n_temp	%tc
	}

	local datetimes activity_start_time activity_end_time

	foreach datetime of local datetimes {
		cap noi gen 	`datetime'nn			=	clock(`datetime', "hms#")
				format	`datetime'nn		%tc
	}
		
	*Fixing the activity start and end time to include correct dates
		
	local datetimes activity_start_time activity_end_time
		gen 			temp 					=	SubmissionDaten_temp*24*60*60*1000
		format 			temp			%16.0f
		foreach datetime of local datetimes {
			gen 	`datetime'n					=	`datetime'nn				///
												+	SubmissionDaten_temp*24*60*60*1000
			format	`datetime'n		%tc
			}
	
	local datetimes SubmissionDate starttime endtime activity_start_time activity_end_time
		foreach datetime of local datetimes {
					drop `datetime'
					ren `datetime'n	`datetime'
			cap noi drop `datetime'n `datetime'n_temp `datetime'nn 
		}
		
		
	*Converting times from gmt to the timezone of the user
	*Cases				Timezone	Dates			Timezone 		Dates
	*Case 1: Dan: 		GMT +1	 	23rd to 25th	GMT -5			>25th
	*Case 2: Kerenssa: 	GMT	+1		23rd to 25th	GMT -5			>25th	
	*Case 3: Leyla: 	GMT	-5		23rd to 25th	GMT -5			>25th
	*Case 4: Sushmita:	GMT	-5		23rd to 25th	GMT -5			>25th
	*Case 5: Vincenzo: 	GMT	+1		23rd to 25th	GMT -5			>25th
	
	local datetimes SubmissionDate starttime endtime activity_start_time activity_end_time
	sort caseid
	list temp SubmissionDate 
	
		foreach datetime of local datetimes {
		gen `datetime'_est						=	.
			/*replace 	`datetime'_est				=	`datetime'				///
												+	1*60*60*1000			///
							if 	SubmissionDate	<= 1887580848128		&	///
								(caseid			==	1	|					///
								caseid			==	2	|					///
								caseid			==	5)*/
			replace	`datetime'_est				=	`datetime'				///
												-	5*60*60*1000			///
							if	`datetime'_est	==	. 
			format	`datetime'_est		%tc
		}

	*calculating durations
	gen		entry_duration						=	(endtime				///
												-	starttime)/(60*60*1000)
	gen 	activity_duration					=	(activity_end_time		///
												-	activity_start_time)/(60*60*1000)
	
	*checking whether durations were entered correctly
	replace activity_duration					=	activity_duration*(-1)	///
						if	activity_duration	<	0
	

	*PAGE 2: generating variable for total time 
	egen		totaltime_case					=	total(activity_duration),	///
								by(caseid)
	egen		totaltime						=	total(activity_duration)
	tab			totaltime_case
	tab 		totaltime	
	drop		temp
	
	bysort 	caseid:																///
	egen start_date 					=	min(SubmissionDate_est)
	format	start_date		%tc
	bysort 	caseid:																///
	egen end_date 						=	max(SubmissionDate_est)
	format	end_date		%tc

	save "$onedrive\Intermediate\tud_11182019_v2.dta", replace
	
