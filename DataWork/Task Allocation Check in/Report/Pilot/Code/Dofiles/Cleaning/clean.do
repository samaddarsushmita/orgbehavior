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
														
import excel "$onedrive\Raw\task_checkin_1218.xlsx", sheet("Sheet2") firstrow clear
											
save "$onedrive\Intermediate\tud.dta", replace

import excel "$onedrive\Raw\task_checkin_1218_casename.xlsx", sheet("Sheet1") firstrow clear

save "$onedrive\Intermediate\task_checkin_1218_casename.dta", replace

use "$onedrive\Intermediate\tud.dta", clear
merge m:1 caseid using "$onedrive\Intermediate\task_checkin_1218_casename.dta"
drop _merge
save "$onedrive\Intermediate\tud.dta", replace

*REMOVING CASES WITH LESS THAN 10 OBSERVATIONS
	bysort caseid: egen nr_obs=count(caseid)
	tab caseid if nr_obs<=10
	drop if nr_obs<=10
	collapse (first) casenme, by(caseid)
	gen caseid_n=_n
	drop caseid 
	ren caseid_n caseid
	save "$onedrive\Intermediate\tud_temp.dta", replace
	use "$onedrive\Intermediate\tud.dta", clear
	bysort caseid: egen nr_obs=count(caseid)
	tab caseid if nr_obs<=10
	drop if nr_obs<=10
	drop caseid
	merge m:1 casenme using "$onedrive\Intermediate\tud_temp.dta" 

	tab caseid
ren SubmissionDate submissiondate

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

label 	define 	withsomeonelbl 			1 	"Meetings"			 				///
										2 	"Independent work"				 			

label 	define 	category_projectlbl 	1 	"Lending"							///
										2 	"Analytical"						///
										4 	"Other"								
	

label 	define 	admin_activitylbl 		1 	"Administrative"			 		///
										2 	"Technical"				 			///
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
											
label 	define 	type_meetinglbl 		1 	"Meetings"						///		 			
										0	""
											
label 	define 	type_strategylbl 		1 	"Brainstorm"	///		 			
										0	""

label 	define 	type_networklbl 		1 	"Network/ Mentor"		///		 			
										0	""
											
label 	define 	type_develop_prjlbl 	1 	"Develop future projects"	///	 			
										0	""
											
label 	define 	type_hiringlbl 			1 	"Recruitment"			/// 			
										0	""

label 	define 	type_review_docslbl 	1 	"Review Documents"			///			
										0	""

label 	define 	type_writelbl 			1 	"Writing"						///		
										0	""
											
label 	define 	type_prep_pptlbl 		1 	"Prepare Presentation"		///		
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

*GENERATING VARIABLE FOR CONCATED CATEGORIES
local cat withsomeone admin_activity planned
foreach x of local cat {
decode `x', gen(`x'_s)
}
replace admin_activity_s="Admin" if admin_activity_s=="Administrative"

egen combined_categories 		=		concat(	planned_s 						///
												admin_activity_s				///
												withsomeone_s), 				///
										punct(" ")
gen filter = 1 if planned_s=="Other" | admin_activity_s=="Other" | withsomeone_s=="Other"
tab filter
replace combined_categories = "" if filter == 1																
encode combined_categories, gen(combined_categories_n)
drop combined_categories planned_s 	admin_activity_s withsomeone_s		
ren combined_categories_n combined_categories	

*setting dates
tostring 	submissiondate, g(submissiondate_s) format(%tCNN/DD/CCYY_HH:MM) force
split 		submissiondate_s, gen(submissiondate_n) parse(" ") 	
drop 		submissiondate_n2	submissiondate_s
rename		submissiondate_n1	submissiondate_n
ren 		submissiondate		submissiondatetime

gen 		submissiondate	 = date(submissiondate_n, "MD20Y")
format 		submissiondate %td

	*calculating durations
	gen		entry_duration						=	(endtime				///
												-	starttime)/(60*60*1000)
	gen 	activity_duration					=	(activity_end_time		///
												-	activity_start_time)/(60*60*1000)
	
	*checking whether durations were entered correctly
	replace activity_duration					=	activity_duration*(-1)	///
						if	activity_duration	<	0
	
	
	bysort 	caseid:																///
	egen start_date 					=	min(submissiondate)
	format	start_date		%td
	bysort 	caseid:																///
	egen end_date 						=	max(submissiondate)
	format	end_date		%td
	egen start_date_all					= 	min(submissiondate)
	format	start_date_all		%td
	egen end_date_all 					=	max(submissiondate)
	format	end_date_all		%td
	
	gen nr_days			= 		end_date-start_date
	gen nr_daysall 		=		end_date_all-start_date_all
	gen nr_weeks 		= 		nr_days/5

	save "$onedrive\Intermediate\tud_v2.dta", replace
	
