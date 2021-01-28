/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   						ASA CLEANING DO									   *
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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Admin Data"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vivian De Fatima Amorim - Governance\WB Admin ODBC Data\II. Projects\1. ASA\DataWork_Quality\Data"
	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
set more off

global date `'
cd 				"C:\Users\wb522556\WBG\Vivian De Fatima Amorim - Governance\WB Admin ODBC Data\II. Projects\1. ASA\DataWork_Quality\Outputs\Raw"

********************************************************************************
*							DATA SOURCE											*
*Link: http://operationsmonitoring.worldbank.org/view/index.html#details/global/allprojects/asadetailscompinfy/0601/$plandelincurrfy$delincurrfy2$finaldeldate/
*Link: http://operationsmonitoring.worldbank.org/view/index.html#details/global/allprojects/asadeliverablesdetails/0619/$~Total$asadel$actact/
********************************************************************************
/*											
import excel "$onedrive\Raw\Activities_Table_A8.8 ASA Activity Details - Completed in Current and Last 4 Years.xlsx", sheet("ASA") firstrow clear

drop AINSignOffColor ConceptNoteApprovalColor ACSOriginalRevisedDateColo ACSActualColor ConceptNoteReviewColor

save "$onedrive\Intermediate\asa_completed.dta", replace	
									
use "$onedrive\Intermediate\asa_completed.dta", clear											

import excel "$onedrive\Raw\Knowledge_Activities_Table_A8.1 ASA Activity Details - Active.xlsx", sheet("ASA") firstrow clear

drop AINSignOffColor ConceptNoteApprovalColor ACSOriginalRevisedDateColo ACSActualColor ConceptNoteReviewColor

save "$onedrive\Intermediate\asa_active.dta", replace	
									
use "$onedrive\Intermediate\asa_active.dta", clear			
append using "$onedrive\Intermediate\asa_completed.dta"

save "$onedrive\Intermediate\asa_all.dta", replace	
			
import excel "$onedrive\Raw\Knowledge_Activities_Table_A9.2 Deliverables Details of ASA Tasks.xlsx", sheet("ASA") firstrow clear

save "$onedrive\Intermediate\asa_deliverables.dta", replace		

merge m:1 TaskID using "$onedrive\Intermediate\asa_all.dta"
drop _merge 

save "$onedrive\Intermediate\asa_all_deliverables.dta", replace	
*/
use "$onedrive\Intermediate\asa_all_deliverables.dta", clear

tab DeliverableStatus		
gen year = year(DeliverableCompletionDate)
tab year if DeliverableStatus=="Completed"

keep if TaskType =="Analytical"
keep if DeliverableStatus=="Completed"

gen random = runiform()
sort random

*CREATING A VARIABLE FOR DELIVERABLE TYPE

gen 			deliverable_name						=	lower(DeliverableName)

*WORKSHOP
gen 			workshop 								= "Workshop" 			///
	if 			strpos(deliverable_name, "workshop") 	!= 0
replace 		workshop 								= "Workshop" 			///
	if 			strpos(deliverable_name, "workshops") 	!= 0					
*TRAINING	
gen 			training 								= "Training" 			///
	if 			strpos(deliverable_name, "training") 	!= 0
replace 		training		 						= "Training" 			///
	if 			strpos(deliverable_name, "trainings") 	!= 0
*CONFERENCE	
gen		 		conference 								= "Conference" 			///
	if 			strpos(deliverable_name, "conference") 	!= 0
replace 		conference		 						= "Conference" 			///
	if 			strpos(deliverable_name, "conferences") != 0
*MEETING
gen		 		meeting 								= "Meeting" 		///
	if 			strpos(deliverable_name, "meeting") 	!= 0
replace		 	meeting 								= "Meeting" 		///
	if 			strpos(deliverable_name, "meetings") 	!= 0	
*REPORT
gen		 		report 									= "Report" 				///
	if 			strpos(deliverable_name, "report") 		!= 0
replace 		report			 						= "Report" 				///
	if 			strpos(deliverable_name, "reports") 	!= 0
*REVIEW
gen		 		review 									= "Review" 				///
	if 			strpos(deliverable_name, "review") 		!= 0
replace 		review			 						= "Report" 				///
	if 			strpos(deliverable_name, "reviews") 	!= 0
*NOTE
gen		 		note 									= "Note" 				///
	if 			strpos(deliverable_name, "note") 		!= 0
replace 		note			 						= "Note" 				///
	if 			strpos(deliverable_name, "notes") 		!= 0
*ASSESSMENT
gen		 		assessment 								= "Assessment" 			///
	if 			strpos(deliverable_name, "assessment") 	!= 0
replace 		assessment			 					= "Assessment" 			///
	if 			strpos(deliverable_name, "assessments") != 0
*TECHNICAL
gen		 		technical 								= "Technical" 			///
	if 			strpos(deliverable_name, "technical") 	!= 0
replace 		technical			 					= "Technical" 			///
	if 			strpos(deliverable_name, "technicals") 	!= 0
*SUPPORT
gen		 		support 								= "Support" 			///
	if 			strpos(deliverable_name, "support") 	!= 0
*ANALYSIS
gen		 		analysis 								= "Analysis" 			///
	if 			strpos(deliverable_name, "analysis") 	!= 0
replace		 	analysis 								= "Analysis" 			///
	if 			strpos(deliverable_name, "analytical") 	!= 0
*STRATEGY
gen		 		strategy 								= "Strategy" 			///
	if 			strpos(deliverable_name, "strategy") 	!= 0
*FRAMEWORK
gen		 		framework 								= "Framework" 			///
	if 			strpos(deliverable_name, "framework") 	!= 0
*STUDY
gen		 		study 									= "Study" 				///
	if 			strpos(deliverable_name, "study") 		!= 0
*RECOMMENDATIONS
gen		 		recommendation 							= "Recommendation" 		///
	if 			strpos(deliverable_name, "recommendation") 		!= 0
replace		 	recommendation 							= "Recommendation" 		///
	if 			strpos(deliverable_name, "recommendations") 		!= 0
*EVALUATION
gen		 		evaluation 								= "Evaluation" 		///
	if 			strpos(deliverable_name, "evaluation") 		!= 0
replace		 	evaluation 								= "Evaluation" 		///
	if 			strpos(deliverable_name, "evaluations") 		!= 0
*PLAN
gen		 		plan 									= "Plan" 		///
	if 			strpos(deliverable_name, "plan") 		!= 0
replace		 	plan 									= "Plan" 		///
	if 			strpos(deliverable_name, "plans") 		!= 0
*POLICY
gen		 		policy 									= "Policy" 		///
	if 			strpos(deliverable_name, "policy") 		!= 0
*PAPER
gen		 		paper 									= "Paper" 		///
	if 			strpos(deliverable_name, "paper") 		!= 0
replace		 	paper 									= "Paper" 		///
	if 			strpos(deliverable_name, "papers") 		!= 0
	

egen 			deliverable_type						=	concat(	workshop 	///
																	training 	///
																	conference	///
																	meeting		///
																	report 		///
																	review 		///
																	note		///
																	assessment	///
																	technical	///
																	support		///
																	analysis	///
																	strategy	///
																	framework	///
																	study		///
																	recommendation	///
																	evaluation	///
																	plan 		///
																	policy		///
																	paper)	
																	
tab deliverable_type ProcessingTrack

export excel using deliverables.xlsx, firstrow(variables) replace




