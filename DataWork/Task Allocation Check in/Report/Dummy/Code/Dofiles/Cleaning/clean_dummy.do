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
														
*import delimited "$onedrive\Raw\Task Check-in_WIDE.txt", encoding(ISO-8859-2) clear 
import excel "$onedrive\Raw\Task_Checkin_dummy.xlsx", sheet("Sheet1") firstrow clear
											
save "$onedrive\Intermediate\tud_dummy.dta", replace

use "$onedrive\Intermediate\tud_dummy.dta", clear

/*cases
	Case 1: 	Lisa Simpson
	Case 2:		Velma Dinkley
*/
*rename variable

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

rename 	(type_activity_1	type_activity_2		type_activity_3					///
		type_activity_4		type_activity_5		type_activity_6					///
		type_activity_7		type_activity_8		type_activity_9					///
		type_activity_10	type_activity_11 	type_activity_12 				///
		type_activity_13 	type_activity_14 	type_activity_15 				///
		type_activity_16 	type_activity__9) 	(type_email 					///
		type_meeting 		type_strategy 		type_network 					///
		type_develop_prj 	type_hiring			type_review_docs				///
		type_write			type_prep_ppt		type_dta_analysis				///
		type_prj_mng 		type_procure 		type_tm_mng						///
		type_int_report		type_career_dev		type_ind_wrk					///
		type_oth)

*Labelling values

label 	define 	withsomeonelbl 			1 	"Meeting"			 				///
										2 	"Independent"				 			

label 	define 	category_projectlbl 	1 	"Lending"							///
										2 	"Analytical"						///
										3 	"Other"								
	

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

label 	define 	imp_actlbl 				1 	"Unimportant"			 			///
										2 	"Important"				 			


label 	define 	type_emaillbl 			1 	"Emails"						///		 			
										0	""
											
label 	define 	type_meetinglbl 		1 	"Meeting"						///		 			
										0	""
											
label 	define 	type_strategylbl 		1 	"Brainstorming or strategizing"	///		 			
										0	""

label 	define 	type_networklbl 		1 	"Networking or Mentoring"		///		 			
										0	""
											
label 	define 	type_develop_prjlbl 	1 	"Developing future projects"	///	 			
										0	""
											
label 	define 	type_hiringlbl 			1 	"Hiring or recruitment"			/// 			
										0	""

label 	define 	type_review_docslbl 	1 	"Reviewing Documents"			///			
										0	""

label 	define 	type_writelbl 			1 	"Writing"						///		
										0	""
											
label 	define 	type_prep_pptlbl 		1 	"Preparing a Presentation"		///		
										0	""
											
label 	define 	type_dta_analysislbl 	1 	"Data Analysis"					///	
										0	""
																					
label 	define 	type_prj_mnglbl 		1 	"Project Management"			///
										0	""
											
label 	define 	type_procurelbl 		1 	"Procurement"					///
										0	""
											
label 	define 	type_tm_mnglbl 			1 	"Team Management"				///
										0	""
											
label 	define 	type_int_reportlbl 		1 	"Internal Reporting"			///	
										0	""
	
label 	define 	type_career_devlbl 		1 	"Career development"			///	
										0	""
											
label 	define 	type_ind_wrklbl 		1 	"Independent work"				///	
										0	""
											
label 	define 	type_othlbl 			1 	"Other"							///	
										0	""

	local 	analysis 	category_project	withsomeone 	admin_activity 		///					
						planned 			importance 		imp_act				///
						type_email 			type_meeting 	type_strategy 		///
						type_network 		type_develop_prj type_hiring 		///
						type_review_docs 	type_write 		type_prep_ppt 		///
						type_dta_analysis 	type_prj_mng 	type_procure 		///
						type_tm_mng 		type_int_report type_career_dev 	///
						type_ind_wrk 		type_oth

foreach var of local analysis 	{
	label 	values	`var'				`var'lbl
}


*setting dates

local datetimes submissiondate starttime endtime

	foreach datetime of local datetimes {
		cap noi gen 	`datetime'n				=	clock(`datetime', "MD20Yhms")
		cap noi gen		`datetime'n_temp		=	date(`datetime'	, "MD20Yhms")
		format	`datetime'n		`datetime'n_temp	%tc
	}

	local datetimes activity_start_time activity_end_time

	foreach datetime of local datetimes {
		cap noi gen 	`datetime'nn			=	clock(`datetime', "hms")
				format	`datetime'nn		%tc
	}
		
	*Fixing the activity start and end time to include correct dates
		
	local datetimes activity_start_time activity_end_time
		gen 			temp 					=	submissiondaten_temp*24*60*60*1000
		format 			temp			%16.0f
		foreach datetime of local datetimes {
			gen 	`datetime'n					=	`datetime'nn				///
												+	submissiondaten_temp*24*60*60*1000
			format	`datetime'n		%tc
			}
	
	local datetimes submissiondate starttime endtime activity_start_time activity_end_time
		foreach datetime of local datetimes {
					drop 	`datetime'
					ren 	`datetime'n	`datetime'
			cap noi drop 	`datetime'n `datetime'n_temp `datetime'nn 
		}
			
	local datetimes submissiondate starttime endtime activity_start_time activity_end_time
	sort caseid
	list temp submissiondate 
	
		foreach datetime of local datetimes {
			gen 	`datetime'_est				=	.
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
	

	drop		temp
	
	bysort 	caseid:																///
	egen start_date 					=	min(submissiondate_est)
	format	start_date		%tc
	bysort 	caseid:																///
	egen end_date 						=	max(submissiondate_est)
	format	end_date		%tc

	save "$onedrive\Intermediate\tud_dummy_v2.dta", replace
	
