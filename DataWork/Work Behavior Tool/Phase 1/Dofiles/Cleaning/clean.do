/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   			WBT  CLEANING DO								   *
*   							   2019										   *
********************************************************************************
********************************************************************************
*						   SELECT PARTS TO RUN   							   *
********************************************************************************/
	
	* select which parts of this do-file to run
	local 	packages		0	// 	Install packages -- only needs to be ran 
									//	once in each computer
	local 	genderunit 		1 //will run the code only for the gender unit								
								
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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Work Behavior Tool\Phase 1\Dofiles\Cleaning"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Phase 1\Datasets"
	}
	* Sushmita for Gender Unit	
	if "`c(username)'" == "wb522556" & `genderunit' {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Gender\Datasets"
	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
set more off

global date `'
cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Phase 1\Outputs\Raw"

if `genderunit' {
cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Gender\Outputs\Raw"
}	
*********************************************************************************														
import delimited "$onedrive\Raw\Work Behavior Tool_WIDE.csv", clear

if `genderunit' {
    keep if gender_unit==1
}
										
save "$onedrive\Intermediate\wbt.dta", replace

********************************************************************************
*OBJECTIVE:
*	1. CLEAN DATES
*	2. STANDARDIZE SCORES VARIABLES
*	3. CLEAN AND LABEL ALL VARIABLES
*	3. ENVIRONMENT SCORES 
********************************************************************************
use "$onedrive\Intermediate\wbt.dta", clear

*Dropping Random Generated Variables
drop rand*

*Dropping duplicate variables on scores
drop item**_env_* item**_*

*GENERATING SUBMISSION DATE VARIABLE
rename submissiondate submissiondatetime
gen 		submissiondate	 = date(submissiondatetime, "MD20Yhms")
format 		submissiondate %td               
drop if _n==78

*GENERATING START TIME VARIABLE
gen 		starttime_n	 = clock(starttime, "MD20Yhms")
format 		starttime_n %tc             

*GENERATING END TIME VARIABLE
gen 		endtime_n	 = clock(endtime, "MD20Yhms")
format 		endtime_n %tc             

*calculating duration in minutes
gen			entry_duration						=	(endtime_n				///
												-	starttime_n)/(60*1000)

*LABELLING THE SCORES
foreach x in ""  {
labvars 	score1`x'	score2`x'	score3`x'	score4`x'	score5`x'	score6`x' ///
			score7`x' 	score8`x' 	score9`x' 	score10`x' 	score11`x' 	score12`x' ///
			score13`x' 	score14`x' 	score15`x' 	score16`x' 	score17`x' 	score18`x' ///
			score19`x' 	score20`x' 	score22`x' 	score23`x' 	score24`x' 	score25`x' ///
			score26`x' 	score27`x' 	score28`x' 	score29`x' 	score30`x' 	score31`x' ///
			score32`x' 	score33`x' 	score34`x' 	score35`x' 	score36`x' 	score37`x' ///
			score38`x' 	score39`x' 	score40`x' 	score41`x' 	score42`x' 	score48`x' ///
			score49`x' 	score50`x' 	score51`x' 	score52`x' 	score53`x' 	score54`x' ///
			score55`x' 	score56`x' 	///
	"Willing to help others" 															///1
	"Desirability in engaging others in social interaction" 							///2
	"Facilitate tasks with the team effectively" 										///3
	"Developing the abilities of team members by providing feedback and suggestions" 	///4
	"Providing team members with adequate opportunities to learn" 						///5
	"Respect people from different backgrounds"											///6
	"Fosters an inclusive workplace" 													///7
	"Comfortable working with people having different perspectives" 					///8
	"Genuinely regards people and easily forms close associations with them" 			///9
	"Adjust one's work style to accommodate individual differences" 					///10
	"Accurately assess and utilize the strengths of all the team members" 				///11
	"Coordinate and cooperate with a team productively" 								///12
	"Able to provide solutions during conflicts" 										///13
	"Desire to be collaborative instead of competitive" 								///14
	"Stay updated on company policies and trends that may impact their activities" 		///15
	"Stay updated on the external market to understand it affects the organization" 	///16
	"Capable of identifying and understanding the dynamics of the organization" 		///17
	"Capable of identifying root causes for a problem" 									///18
	"Gather and apply knowledge to strategically solve work-related problems" 			///19
	"Emotionally stable, reliable and dependent in times of crisis" 					///20
	"Deals with ambiguity by being methodical and patient" 								///22
	"Actively cope with tough situations, rather than being passive" 					///23
	"Good at imagination and originality" 												///24
	"Willing to consider new and unconventional ideas and solutions to problems" 		///25
	"Adding new dimensions to one's work" 												///26
	"Flexible approach to one’s work" 													///27
	"Desire to design and implement new programs/processes" 							///28
	"Constantly work towards deriving innovative solutions to problems" 				///29
	"Open to changes taking place in the organization" 									///30
	"Ability to take risks" 															///31
	"Impervious to social norms and judgement" 											///32
	"Determine objectives, set priorities and follow through one's plans" 				///33
	"Holds oneself accountable for high quality" 										///34
	"Holds oneself accountable for time-effective results" 								///35
	"Responsible and active at work to ensure desired results" 							///36
	"Strong commitment towards achieving individual and team goals" 					///37
	"Set challenging goals for oneself and for other team members" 						///38
	"Work towards personal growth and development" 										///39
	"Aware of one's own strength and limitations" 										///40
	"Improve oneself and acquire more knowledge" 										///41
	"Having confidence in one's own skills and hard work" 								///42
	"Attuned to others' emotions" 														///48
	"Trusting of others" 																///49
	"Cooperative, accomodating and understanding" 										///50
	"Able to include other people in decision making" 									///51
	"Comfortable in situations involving uncertainty and risks" 						///52
	"Effectively adapt to new situations" 												///53
	"Takes initiatives and guides others during challenging times" 						///54
	"Open to learning from failure" 													///55
	"Independent and assertive individual" 
}


foreach x in "" {
labvars 	score44`x' 				score45`x' 					score46`x' /// 
			"Social Desirability 1" "Social Desirability 2" 	"Social Desirability 3" 
}


foreach x in "" {
cap noi labvars score3_env	score5_env	score7_env	score14_env	score16_env		///
				score20_env	score22_env	score25_env	score28_env	score30_env 	///
				score32_env	score33_env	score34_env score35_env	score50_env		///
	"Env: Facilitate tasks with the team effectively"										///3
	"Env: Providing team members with adequate opportunities to learn"	 					///5
	"Env: Fosters an inclusive workplace"													///7
	"Env: Desire to be collaborative instead of competitive" 								///14
	"Env: Stay updated on the external market to understand it affects the organization"	///16
	"Env: Emotionally stable, reliable and dependent in times of crisis"					///20
	"Env: Deals with ambiguity by being methodical and patient"								///22
	"Env: Willing to consider new and unconventional ideas and solutions to problems"		///25
	"Env: Desire to design and implement new programs/processes"							///28
	"Env: Open to changes taking place in the organization"									///30
	"Env: Impervious to social norms and judgement"											///32
	"Env: Determine objectives, set priorities and follow through one's plans"				///33
	"Env: Holds oneself accountable for high quality"										///34
	"Env: Holds oneself accountable for time-effective results"								///35
	"Env: Cooperative, accomodating and understanding"				
}

*LABELS FOR DEMOGRAPHIC VARIABLES
label define genderlbl 	1 "Female" 	2 "Male" 	3 "Transgender Female" 			///
						4 "Transgender Male" 	5 "Non-Conforming/Non-Binary/Gender Variant" ///
						6 "Not Listed" 			7 "Prefer Not to Answer"

label define gradelbl 	1 "GA-GD" 	2 "GE-GF" 	3 "GG" 	4 "GH and Above" 		///
						5 "Prefer Not to Answer"

label define apptlbl 	1 "Open-Ended" 	2 "Term" 	3 "ETC" 	4 "STC/STT" 	///
						5 "Other/Team Member"

label define agelbl 	1 "Less than 30 years" 		2 "31 to 40 years" 			///
						3 "41 to 50 years" 			4 "Above 50 years" 			///
						5 "Prefer Not to Answer"

label define explbl 	1 "Less than 5 years" 		2 "5 to 9 years" 			///
						3 "10 to 19 years" 			4 "20 to 29 years" 			///
						5 "More than 30 years" 		6 "Prefer Not to Answer"

label define rolelbl 	1 "Task Team Leader" 		2 "Program/Team Assistant" 		///
						3 "Safeguard Specialist" 	4 "Financial Management Specialist" ///
						5 "Procurement Specialist" 	6 "Lawyer/Legal Council" 	///
						7 "Practice Manager" 		8 "Director" 				///
						9 "Country Director or Country Manager" 	10 "Other"

label define practicelbl	0 "Not Mapped to a Global Practice" 				///
							1 "Finance, Competition and Innovation" 			///
							2 "Governance" 										///
							3 "Macroeconomics, Trade and Investment" 			///
							4 "Poverty and Equity" 								///
							5 "Education" 										///
							6 "Gender" 											///
							7 "Health, Nutrition and Population" 				///
							8 "Social Protection and Jobs" 						///
							9 "Agriculture" 									///
							10 "Climate Change" 								///
							11 "Environment and Natural Resources" 				///
							12 "Social, Urban and Rural Resilience" 			///
							13 "Water" 											///
							14 "Energy and Extractives" 						///
							15 "Infrastructure, PPPs and Guarantees" 			///
							16 "Transport and Digital Development"				///
							99	"Other"

label define regionlbl 	0 "Not Mapped to a Region" 		1 "Africa" 					///
						2 "East Asia and Pacific" 		3 "Europe and Central Asia" ///
						4 "Latin America and Caribbean" 5 "Middle East and Central Asia" 6 "South Asia" 

label define vpulbl 	1 "SEC" 	2 "DEC" 	3 "ECR" 	4 "HRD" 	5 "GIA" ///
						6 "LEG" 	7 "OPCS" 	8 "BPS" 	9 "GCS" 	10 "HSD" ///
						11 "ITS" 	12 "SPA" 	13 "CRO" 	14 "DFI" 	15 "TRE" ///
						16 "WFA" 	17 "GGE" 	18 "GGH" 	19 "GGI" 	20 "GGS" ///
						21 "WBT" 	22 "EBC" 	23 "IJS" 	24 "MEF" 	25 "OMB" ///
						26 "PRS" 	27 "EDS" 	28 "IEG" 	29 "IPN" 	30 "INT" ///
						31 "OSD" 	32 "SBS" 	33 "EXC" 	34 "CAO" 	35 "MDO" ///
						36 "CFO"	37 "Region VPU" 0 "Other"

label define educationlbl 	1 "Undergraduate" 				2 "Graduate" 		///
							3 "Professional Diploma/Certificate" 	4 "Doctorate" 	///
							5 "Post Doctorate" 				-6 "Other" 
						
*GENERATING SKILLS VARIABLE

*Skills 1: Project Design
label define 	skills_1lbl	1 "Project Design" 							0 ""							

*Skills 2: Project Management and Implementation
label define 	skills_2lbl	1 "Project Management and Implementation" 	0 ""							

*Skills 3: Research and Analysis
label define 	skills_3lbl	1 "Research and Analysis" 					0 ""							

*Skills 4: Monitoring and Evaluation
label define 	skills_4lbl	1 "Monitoring and Evaluation" 				0 ""							

*Skills 5: Resource Management and Budget
label define 	skills_5lbl	1 "Resource Management and Budget" 			0 ""							

*Skills 6: Writing and Editing
label define 	skills_6lbl	1 "Writing and Editing" 					0 ""							

*Skills 7: Capacity Building
label define 	skills_7lbl	1 "Capacity Building" 						0 ""							

*Skills 8: Legal Counsel and Analysis
label define 	skills_8lbl	1 "Legal Counsel and Analysis" 				0 ""							

*Skills 9: Client Engagement
label define 	skills_9lbl	1 "Client Engagement" 						0 ""							

*Skills 10: Data Analysis and Statistical Programming
label define 	skills_10lbl	1 "Data Analysis and Statistical Programming" 	0 ""							

*Skills 11: Strategy and Policy Dialogue
label define 	skills_11lbl	1 "Strategy and Policy Dialogue" 		0 ""							

*Skills 12: Information Technology
label define 	skills_12lbl	1 "Information Technology" 				0 ""							

*Skills 13: Financial Analysis
label define 	skills_13lbl	1 "Financial Analysis" 					0 ""							

*Skills 14: Administrative Assistance
label define 	skills_14lbl	1 "Administrative Assistance" 			0 ""							

*Skills 15: Event Management
label define 	skills_15lbl	1 "Event Management" 					0 ""							

*Skills 16: Media and Strategic Communications
label define 	skills_16lbl	1 "Media and Strategic Communications" 	0 ""							

*Skills 17: Team Management
label define 	skills_17lbl	1 "Team Management" 					0 ""							

*Skills 18: Human Resources Management
label define 	skills_18lbl	1 "Human Resources Management" 			0 ""							

*Skills 19: Training
label define 	skills_19lbl	1 "Training" 							0 ""							

*Skills 20: Team Player
label define 	skills_20lbl	1 "Team Player" 						0 ""							

label define demo3_intproclbl	1 "Unhelpful"			2 "Somewhat Unhelpful"		///
								3 "Somewhat Helpful"	4 "Helpful"

label define demo_motivlbl		1 "Unmotivated"			2 "Somewhat Unmotivated"		///
								3 "Somewhat Motivated"	4 "Motivated"

label define demo2_skillslbl	1 "Unused Skills"			2 "Somewhat Unused Skills"		///
								3 "Somewhat Used Skills"	4 "Used Skills"
						
label values gender 		genderlbl
label values appointment 	apptlbl
label values age 			agelbl
label values experience 	explbl
label values grade 			gradelbl 
label values practice 		practicelbl 
label values region 		regionlbl 
label values vpu 			vpulbl 
label values education 		educationlbl 
label values demo3_intproc 	demo3_intproclbl
label values demo_motiv 	demo_motivlbl
label values demo2_skills 	demo2_skillslbl

forvalues x=1/20 {
label values skills_`x' 	skills_`x'lbl
}

*ANCHOR QUESTIONS
sum demo_motiv
sum demo2_skills
sum demo3_intproc

save "$onedrive\Intermediate\wbt_v2.dta", replace

