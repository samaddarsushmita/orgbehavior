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
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Dummy\Outputs\Raw"


********************************************************************************
*							OBJECTIVE											*
*	1.	Unit based description of 
*		a. 	Planned vs Unplanned
*		b.	Administrative vs Technical
*		c.	Meetings vs Independent Work	
*		d.	Important vs Unimportant
*		e. 	Most popular type of activity
*	2

use "$onedrive\Intermediate\dummy_tud_v5.dta", replace
tab caseid
gl 	case 200

*BAR GRAPH OVERALL
graph bar (median) unplanned_p meeting_p admin_p unimp_act_p,					///
	outergap(20) bargap(30)														///
	blabel(bar, format(%9.1f) size(vsmall))										///
	legend(	label(1 "Unplanned Tasks")		label(2 "Unimportant Meetings") 					///
			label(3 "Unimportant Internal Processes") 	label(4 "Other Unimportant Tasks") size(small)) 	///
	ytitle("Proportion of total time recorded", size(small))					///
	graphregion(color(white)) bgcolor(white)									///
	title( "Proportion of time spent on each category of activity", size(medium))	///
	subtitle(" ")																///
	note("Source: Dummy data extrapolated through pilot Task Check-in", size(vsmall)) 
graph export bar_overall_activities.png, as(png) name("Graph") replace

*ABOVE AND BELOW AVERAGE DIFFERENCE BARS
local var 	unplanned 	meeting	admin	unimp_act	
foreach x of local var {
egen 	`x'_p_mean 			=	mean(`x'_p)

bysort division:																///
gen 	`x'_pdiff			=	`x'_dp-`x'_p_mean
egen 	max`x'_pdiff		=	max(`x'_pdiff)

global 		unplanned 	Unplanned Activities
global 		meeting 	Unimportant Meetings
global 		admin		Unimportant Internal Processes
global      unimp_act	Other Unimportant Activities

graph dot (mean) `x'_pdiff,														///
	over(division, label(labsize(small)) relabel(`r(relabel)')) outergap(20) 	///
	blabel(bar, format(%9.1f) size(small))										///
	ylabel(-4(1)4)																///
	legend() yline(0)															///
	ytitle("Proportion of time spent in $`x' (Difference from Average)", size(small)) ///
	graphregion(color(white)) bgcolor(white)									///
	title( "$`x'", size(medium))												///
	subtitle("Difference from Average", size(small))							///
	note("Source: Dummy data extrapolated through pilot Task Check-in", size(vsmall)) 
graph export dot_`x'_divisions.png, as(png) name("Graph") replace
}
*HBAR GRAPH MENU OF TASKS
graph hbar (median) type_email_p 		type_meeting_p 		type_strategy_p 	///
					type_network_p 		type_develop_prj_p 	type_hiring_p 		///
					type_review_docs_p 	type_write_p 		type_prep_ppt_p 	///
					type_dta_analysis_p type_prj_mng_p 		type_procure_p 		///
					type_tm_mng_p 		type_int_report_p 	type_ind_wrk_p,		///
	outergap(20) bargap(30) showyvars legend(off) 							///	
	yvaroptions(relabel(1 "Emails" 2 "Meetings" 3 "Brainstorming" 4 "Networking"	///
						5 "Developing Projects" 6 "Hiring" 7 "Review Documents" ///
						8 "Writing" 9 "Preparing Presentation" 10 "Data Analysis" ///
						11 "Project Management" 12 "Procurement" 13 "Team Management" ///
						14 "Internal Reporting" 15 "Independent Work"))			///
	blabel(bar, format(%9.1f) size(small)) 									///
	ytitle("Proportion of total time recorded", size(small))					///
	graphregion(color(white)) bgcolor(white)									///
	title( "Menu of Activities Performed by Staff", size(medium))				///
	subtitle(" ")																///
	note("Source: Dummy data extrapolated through pilot Task Check-in", size(vsmall)) 
graph export hbar_menutasks.png, as(png) name("Graph") replace

/*TIME TREND LINE GRAPH - DAYS

sort day	
twoway line 		unplanned_cpr meetings_cpr admin_cpr unimp_cpr day,			///
					legend(	label(1 "Unplanned")		label(2 "Meetings") 	///
							label(3 "Administrative") 	label(4 "Unimportant"))	///
					xlabel(1(1)3) sort											///
					ytitle("Proportion of total time recorded")					///
					xtitle("Work Week")											///
					title("Proportion of Time Spent on Activities over Work-Weeks")	///
					subtitle(" ")												///
					graphregion(color(white)) bgcolor(white)					///
					lwidth(medthick)	lcolor(green edkblue purple dkorange  maroon)	///
					note("Source: Dummy data extrapolated through pilot Task Check-in")	
graph export line_activities_day.png, as(png) name("Graph") replace			
	
/*TIME TREND LINE GRAPH
use "$onedrive\Intermediate\dummy_timetrend.dta", clear

preserve
collapse (mean) 	unplanned_cpr_week 		unplanned_d*_week					///
					meetings_cpr_week 		meetings_d*_week					///
					admin_cpr_week 			admin_d*_week											///
					unimp_cpr_week			unimp_d*_week, 											///
									by(	workweek 								///
										category)

sort 	workweek	
			
global 		unplanned 	Unplanned Activities
global 		meetings 	Meetings
global 		admin		Administrative Activities
global      unimp		Unimportant Activities

local var 	unplanned 	meetings	admin	unimp	
			
foreach x of local var {
twoway line 		`x'_d*_week 												///
					workweek,													///
					legend(	label(1 "Division 1")		label(2 "Division 2") 	///
							label(3 "Division 3") 		label(4 "Division 4")	///
							label(5 "Division 5"))				 				///
					xlabel(1(1)3)												///
					ytitle("Proportion of total time recorded")					///
					title("Proportion of $`x' over Work-Weeks")					///
					subtitle(" ")												///
					graphregion(color(white)) bgcolor(white)									///
					lwidth(medthick)	lcolor(green edkblue purple dkorange  maroon)	///
					note("Source: Dummy data extrapolated through pilot Task Check-in")
graph export line_`x'_week.png, as(png) name("Graph") replace				
}			
twoway line 		unplanned_cpr_week meetings_cpr_week admin_cpr_week			///
					unimp_cpr_week	workweek,									///
					legend(	label(1 "Unplanned")		label(2 "Meetings") 	///
							label(3 "Administrative") 	label(4 "Unimportant"))	///
					xlabel(1(1)3)												///
					ytitle("Proportion of total time recorded")					///
					xtitle("Work Week")											///
					title("Proportion of Time Spent on Activities over Work-Weeks")	///
					subtitle(" ")												///
					graphregion(color(white)) bgcolor(white)					///
					lwidth(medthick)	lcolor(green edkblue purple dkorange  maroon)	///
					note("Source: Dummy data extrapolated through pilot Task Check-in")	
graph export line_activities_week.png, as(png) name("Graph") replace			
					
restore

