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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Work Behavior Tool\Phase 1\Dofiles\Cleaning"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Phase 1\Datasets"
		global onedrivePilot	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Pilot\Encrypted\Raw Data"

	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
set more off

global date `'
cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Phase 1\Outputs\Raw"
														
import excel "$onedrivePilot\Work Behavior Tool.xlsx", clear firstrow
											
save "$onedrive\Intermediate\wbt_pilot.dta", replace

********************************************************************************
*OBJECTIVE:
*	1. CLEAN DATES
*	2. STANDARDIZE SCORES VARIABLES
*	3. CLEAN AND LABEL ALL VARIABLES
*	3. ENVIRONMENT SCORES 
********************************************************************************

use "$onedrive\Intermediate\wbt_pilot.dta", clear

*Dropping Random Generated Variables
drop rand*

*Dropping duplicate variables on scores
drop item**_env_* item**_*

*GENERATING SUBMISSION DATE VARIABLE
rename 		SubmissionDate 	submissiondate
split 		submissiondate, gen(submissiondate_n) parse("T") 	
drop 		submissiondate_n2
rename		submissiondate_n1	submissiondate_n
ren 		submissiondate		submissiondatetime

gen 		submissiondate	 = date(submissiondate_n, "YMD")
format 		submissiondate %td
drop		submissiondate_n

*LABELLING THE SCORES
foreach x in "" "a" "b" {
labvars 	score1`x' score2`x' score3`x' score4`x' score5`x' score6`x' score7`x' ///
			score8`x' score9`x' score10`x' score11`x' score12`x' score13`x' score14`x' ///
			score15`x' score16`x' score17`x' score18`x' score19`x' score20`x' score22`x' ///
			score23`x' score24`x' score25`x' score26`x' score27`x' score28`x' score29`x' ///
			score30`x' score31`x' score32`x' score33`x' score34`x' score35`x' score36`x' ///
			score37`x' score38`x' score39`x' score40`x' score41`x' score42`x' score48`x' ///
			score49`x' score50`x' score51`x' score52`x' score53`x' score54`x' score55`x' score56`x' ///
			"Willing to help others" 											///1
			"Desirability in engaging others in social interaction" 			///2
			"Facilitate tasks with the team effectively" 						///3
			"Developing abilities of team members by providing feedback" 		///4
			"Providing team members with adequate opportunities to learn" 		///5
			"Respect people from different backgrounds" 						///6
			"Fosters an inclusive workplace" 									///7
			"Comfortable working with people having different perspectives" 	///8
			"Genuinely regards people and forms close associations with them" 	///9
			"Adjust one's work style to accommodate individual differences" 	///10
			"Accurately assess and use the strengths of all the team members" 	///11
			"Coordinate and cooperate with a team productively" 				///12
			"Able to provide solutions during conflicts" 						///13
			"Desire to be collaborative instead of competitive" 				///14
			"Stay updated on company policies that may impact their activities" ///15
			"Stay updated on external market to understand it affects" 			///16
			"Capable of identifying the dynamics of the organization" 			///17
			"Capable of identifying root causes for a problem" 					///18
			"Gather and apply knowledge to strategically solve work problems" 	///19
			"Emotionally stable, reliable and dependent in times of crisis" 	///20
			"Deals with ambiguity by being methodical and patient" 				///22
			"Actively cope with tough situations, rather than being passive" 	///23
			"Good at imagination and originality" 								///24
			"Willing to consider unconventional solutions to problems" 			///25
			"Adding new dimensions to one's work" 								///26
			"Flexible approach to one’s work" 									///27
			"Desire to design and implement new programs/processes" 			///28
			"Constantly work towards deriving innovative solutions to problems" ///29
			"Open to changes taking place in the organization" 					///30
			"Ability to take risks" 											///31
			"Impervious to social norms and judgement" 							///32
			"Determine objectives, set priorities and follow through plans" 	///33
			"Holds oneself accountable for high quality" 						///34
			"Holds oneself accountable for time-effective results" 				///35
			"Responsible and active at work to ensure desired results" 			///36
			"Strong commitment towards achieving individual and team goals" 	///37
			"Set challenging goals for oneself and for other team members" 		///38
			"Work towards personal growth and development" 						///39
			"Aware of one's own strength and limitations" 						///40
			"Improve oneself and acquire more knowledge" 						///41
			"Having confidence in one's own skills and hard work" 				///42
			"Attuned to others' emotions" 										///48
			"Trusting of others" 												///49
			"Cooperative, accomodating and understanding" 						///50
			"Able to include other people in decision making" 					///51
			"Comfortable in situations involving uncertainty and risks" 		///52
			"Effectively adapt to new situations" 								///53
			"Takes initiatives and guides others during challenging times" 		///54
			"Open to learning from failure" 									///55
			"Independent and assertive individual"								//56
}

foreach x in a b {
labvars score43`x' score44`x' score45`x' score46`x' score47`x' 					/// 
"Social Desirability 1" "Social Desirability 2" "Social Desirability 3" 		///
"Social Desirability 4" "Social Desirability 5"
}



foreach x in "" "a" "b" {
cap noi labvars 	score14`x'_env score16`x'_env score20`x'_env score22`x'_env ///
					score25`x'_enc score28`x'_env score30`x'_env score32`x'_env ///
					score33`x'_env score37`x'_env score3`x'_env score41`x'_env 	///
					score50`x'_env score7`x'_env score9`x'_env 					///
"Env: Desire to be collaborative instead of competitive"  						///14
"Env: Stay updated on the external market to understand it affects"				///16
"Env: Emotionally stable, reliable and dependent in times of crisis"			///20
"Env: Deals with ambiguity by being methodical and patient"						///22
"Env: Willing to consider new and unconventional solutions to problems"			///25
"Env: Desire to design and implement new programs/processes"					///28
"Env: Facilitate tasks with the team effectively"								///30
"Env: Open to changes taking place in the organization"							///32
"Env: Impervious to social norms and judgement"									///33
"Env: Determine objectives, set priorities and follow through one's plans"		///37
"Env: Strong commitment towards achieving individual and team goals"			///3
"Env: Improve oneself and acquire more knowledge"								///41
"Env: Cooperative, accomodating and understanding"								///50
"Env: Fosters an inclusive workplace"											///7
"Env: Genuinely regards people and easily forms close associations with them"	//9					
}

*DESCRIPTIVES
label define genderlbl 	1 "Female" 	2 "Male" 	3 "Transgender Female" 			///
						4 "Transgender Male" 	5 "Non-Conforming" 				///
						6 "Not Listed" 			7 "Prefer Not to Answer"

label define gradelbl 	1 "GA-GD" 	2 "GE-GF" 	3 "GG" 	4 "GH and Above" 		///
						5 "Prefer Not to Answer"

label define apptlbl 	1 "Open-Ended" 	2 "Term" 	3 "ETC" 	4 "STC/STT" 	///
						5 "Other/Team Member"

label define agelbl 	1 "Less than 30 years" 	2 "31 to 40 years" 				///
						3 "41 to 50 years" 		4 "Above 50 years" 				///
						5 "Prefer Not to Answer"

label define explbl 	1 "Less than 5 years" 	2 "5 to 9 years" 				///
						3 "10 to 19 years" 		4 "20 to 29 years" 				///
						5 "More than 30 years" 	6 "Prefer Not to Answer"

label define rolelbl 	1 "Task Team Leader" 	2 "Program/Team Assistant" 		///
						3 "Safeguard Specialist" 4 "Financial Management Specialist" ///
						5 "Procurement Specialist" 6 "Lawyer/Legal Council" 	///
						7 "Practice Manager" 	8 "Director" 					///
						9 "Country Director or Country Manager" 10 "Other"

label define practicelbl 	0 "Not Mapped to a Global Practice" 				///
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
							16 "Transport and Digital Development"

label define regionlbl 	0 "Not Mapped to a Region" 	1 "Africa" 					///
						2 "East Asia and Pacific" 	3 "Europe and Central Asia" ///
						4 "Latin America and Caribbean" 						///
						5 "Middle East and Central Asia" 6 "South Asia" 

label define vpulbl 	1 "SEC" 	2 "DEC" 	3 "ECR" 	4 "HRD"	 5 "IAD" 	///
						6 "LEG" 	7 "OPCS" 	8 "BPS" 	9 "GCS" 10 "HSD" 	///
						11 "ITS" 	12 "SPA" 	13 "CRO" 	14 "DFI" 15 "TRE" 	///
						16 "WFA" 	17 "GGE" 	18 "GGH" 	19 "GGI" 20 "GGS" 	///
						21 "WBT" 	22 "EBC" 	23 "IJS" 	24 "MEF" 25 "OMB" 	///
						26 "PRS" 	27 "EDS" 	28 "IEG" 	29 "IPN" 30 "INT" 	///
						31 "OSD" 	32 "SBS" 	33 "EXC" 	34 "CAO" 35 "CEO" 	///
						36 "CFO"

label values gender 		genderlbl
label values appointment 	apptlbl
label values age 			agelbl
label values experience 	explbl
label values grade 			gradelbl 
label values practice 		practicelbl 
label values region 		regionlbl 
label values vpu 			vpulbl 

save "$onedrive\Intermediate\wbt_pilot_v2.dta", replace



