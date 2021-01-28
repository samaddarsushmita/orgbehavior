/****************************************************************************************************					SUSHMITA SAMADDAR 								   								*
*   					  PROJECT CLEANING DO								   						*
*   							   2019										   						*
****************************************************************************************************/
	local 	packages		0	// 	Install packages -- only needs to be ran 
									//	once in each computer

****************************************************************************************************
*			PART 1:  Set standard settings and install packages				   						*
****************************************************************************************************/
	
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
	
	
		
*****************************************************************************************************
*				PART 2:  Prepare globals and define paths					  					 *
*****************************************************************************************************
*NOTE: PLEASE USE '/' INSTEAD OF '\' FOR DIRECTORIES FOR COMPATABILITY WITH MACS

	* add your directory below
	 display c(username)  	


	* Set directories 
	* ---------------	
	* Sushmita
	if "`c(username)'" == "wb522556" {
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Admin Data\Dofiles\Cleaning"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Datasets"
		global onedriveRaw "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Encrypted\Raw Data"
	}

set more off
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Outputs\Raw"

*setting paths

	****************************************************************************
	*              CLEANING PROJECT MASTER FILE                                *
	****************************************************************************
	/*
	import delimited "$onedriveRaw\project_master.csv", clear bindquote(strict) 
	ren ïproj_id ProjectID
	save "$onedrive\Intermediate\project_master.dta", replace
	*/
	
	use "$onedrive\Intermediate\project_master.dta", clear			

/*
FIXING DATES
*************

DATES IN NUMERIC FORMAT 
************************
	coverage_start_date coverage_end_date
	date and time format
	lst_disb_dt: Last Disbursement Date

DATES IN YMD FORMAT
*******************
	Variable Name 					Label
	restructuring_date: 			Restructuring date 
	proj_drop_date: 				Project Drop Date
	midterm_review_date: 			Mid Term Revision Date 
	last_step_completed_date: 		Last Step Completed Date 
	pid_to_infoshop_date: 			Project/Program Identification Document 
									received by InfoShop date
	auth_apprs_neg_date: 	Authorizing Approval Negotiation Date 
	gp_clearance_date: 				Global Practice Clearance Date 
	do_change_date:  
	next_mid_term_rev_date: 		Next Mid Term Review Date 
	environ_assess_cat_date: 		Environment Assessment Category Date 
	isr_date: 						Implementation Status and Results date 
	icr_extended_date: 				Implementation Completion and Results Extended Date
	icr_due_date: 					Implementation Completion and Results Due Date 
	orig_act_preparation_date: 		Original Activity Preparation Date
	act_preparation_date: 			Activity Preparation Date 
	orig_acs_date: 					Original Activity Completion Summary Date
	orig_final_del_date: 			Original Final Delivery Date 
	final_delivery_date: 				Final Delivery Date 
	orig_del_to_client_date: 		Original Delivery to Client Date
	del_to_client_date: 			Delivery to Client Date 
	orig_decision_mtg_date: 		Original Decision Meeting Date 
	decision_mtg_date: 				Decision Meeting Date 
	orig_implementation_start_date: Original Implementation Start Date
	orig_ais_sign_off_date: 			Original Activity Initiation Summary Sign off Date
	ais_sign_off_date: 				Activity Initiation Summary Sign Off Date 
	ais_start_concept_note_date: 	Activity Initiation Summary Start Concept Note Date
	original_closing_date: 					Original Closing Date
	revised_closing_date: 				Revised Closing Date 
	bd_apprvl_date: 				Board Approval Date 
	icr_to_secbo_date: 				Implementation Completion and Results to SECPO
	icr_to_cd_date: 				Implementation Completion and Results to Country Date
	effectiveness_date: 			Effective Date 
	signing_date: 					Signing Date 
	negotiation_date: 				Negotiation Date 
	begin_appraisal_date: 			Appraisal Date 
	deactivation_date: 				Deactivation Date
	*/

local dates restructuring_date project_drop_date mid_term_rev_date 				///
last_step_completed_date pid_received_by_infoshop_date auth_apprs_neg_date 		///
gp_clearance_date do_change_date next_mid_term_rev_date isr_date 				///
icr_extended_date icr_due_date orig_act_preparation_date act_preparation_date 	///
orig_acs_date orig_final_del_date final_delivery_date orig_del_to_client_date 	///
del_to_client_date orig_decision_mtg_date decision_mtg_date 					///
orig_implementation_start_date orig_ais_sign_off_date ais_sign_off_date			///
ais_start_concept_note_date revised_closing_date board_date icr_to_secbo_date	/// 
icr_to_cd_date effective_date sign_date negotiation_date 						///
appraisal_date deactivation_date environ_ssessment_category_date original_closing_date

	foreach date of local dates {
		cap noi gen 	`date'n							=	date(`date', "MDY")
		cap noi format 	`date'n 	%td
		cap noi drop 	`date'
		cap noi rename 	`date'n 	`date'
	}
	
	tab 					project_status_nme
	
	keep 				if 	project_status_nme			==	"Active" 			| ///
							project_status_nme			==	"Closed" 
			
********************************************************************************
					*CALCULATING TIME OVERRUN
********************************************************************************
	
*TIME OVERRUN: ACTIVITY PREPARATION DATE
****************************************
gen 	tovr_act_prep		=	act_preparation_date							///
							-	orig_act_preparation_date 						///
							if 	orig_act_preparation_date	!=. 	& 			///
								act_preparation_date		!=.
sum 	tovr_act_prep

*TIME OVERRUN: DELIVERY
***********************
gen 	tovr_delivery		=	final_delivery_date								///
							-	orig_final_del_date 							///
							if 	orig_final_del_date			!=. 	& 			///
								final_delivery_date			!=.
sum 	tovr_delivery

*TIME OVERRUN: DELIVERY TO CLIENT
*********************************
gen 	tovr_del_to_client	=	del_to_client_date							///
							-	orig_del_to_client_date 						///
							if 	orig_del_to_client_date	!=. 	& 			/// 
								del_to_client_date		!=.
sum 	tovr_del_to_client

*TIME OVERRUN: DECISION MEETING
*******************************
gen 	tovr_decision_mtg	=	decision_mtg_date								///	
							-	orig_decision_mtg_date 							///		
							if 	orig_decision_mtg_date		!=. 	& 			///
								decision_mtg_date			!=.
sum 	tovr_decision_mtg

*TIME OVERRUN: SIGN OFF
***********************
gen 	tovr_ais_signoff	=	ais_sign_off_date								///	
							-	orig_ais_sign_off_date 							///		
							if 	orig_ais_sign_off_date		!=. 	& 			///
								ais_sign_off_date			!=.
sum 	tovr_ais_signoff

*TIME OVERRUN: CLOSING DATE
***************************
gen 	tovr_closing_date	=	revised_closing_date							///		
							-	original_closing_date 							///			
							if 	original_closing_date		!=. 	& 			///
								revised_closing_date		!=.
sum 	tovr_closing_date

*TIME OVERRUN: ICR DUE DATE 
***************************
gen 	tovr_icr_due_date	=	icr_extended_date								///
							-	icr_due_date 									///			
							if 	icr_due_date				!=. 	& 			///
								icr_extended_date!=.
sum 	tovr_icr_due_date

********************************************************************************
*	NOTE: These time overruns have too many outliers. 
*	The next section checks the descriptions of each dates and creates a variable 
*	for possible processing periods to be able to assess whether the dates 
*	have outliers.
********************************************************************************

							**************
							*SIGN OFF DATE
							**************
*Checking for error: If activity preparation date is earlier than sign off						
sum     orig_ais_sign_off_date                                                   ///
        orig_act_preparation_date 				                                ///						
                                if 	orig_ais_sign_off_date	    !=. &           /// 
                                    orig_act_preparation_date	!=.
                                    
*Generating Sign off to Activity Preparation Period to check for average length

gen 	orig_aissign_actprep	=	orig_act_preparation_date	                ///
                                -	orig_ais_sign_off_date 		                ///
                                if 	orig_ais_sign_off_date		!=. &           /// 
                                    orig_act_preparation_date	!=.
                                    
*Checking for error: If decision meeting date is earlier than sign off

sum 	orig_ais_sign_off_date                                                   ///
        orig_decision_mtg_date 			                                        ///								
                                if 	orig_ais_sign_off_date		!=. &           /// 
                                    orig_decision_mtg_date      !=.
                                    
*Generating Sign off to Decision Period to check for average length

gen 	orig_aissign_decmtg		=	orig_decision_mtg_date		                ///
                                -	orig_ais_sign_off_date 		                ///
                                if 	orig_ais_sign_off_date		!=. &           /// 
                                    orig_decision_mtg_date      !=.

*Checking for error: If delivery to client is earlier than sign off

sum 	orig_ais_sign_off_date                                                   ///
        orig_del_to_client_date 				                                ///						
                                if 	orig_ais_sign_off_date		!=. &           /// 
                                    orig_del_to_client_date	!=.

*Generating Sign off to Delivery to Client to check for average length

gen 	orig_aissign_delcl		=	orig_del_to_client_date	                ///
                                -	orig_ais_sign_off_date 		                /// 
                                if 	orig_ais_sign_off_date		!=. &           /// 
                                    orig_del_to_client_date	!=.

*Checking for error: If final delivery is earlier than sign off

sum 	orig_ais_sign_off_date                                                   ///
        orig_final_del_date 				                                    ///							
                                if 	orig_ais_sign_off_date		!=. &           /// 
                                    orig_final_del_date		!=.
                                    
*Generating Sign off to Final Delivery to check for average length

gen 	orig_aissign_fdel		=	orig_final_del_date		                ///
                                -	orig_ais_sign_off_date 		                ///
                                if 	orig_ais_sign_off_date		!=. &           /// 
                                    orig_final_del_date		!=.

*Checking for error: If closing date is earlier than sign off

sum 	orig_ais_sign_off_date                                                   ///
        original_closing_date 					                                        ///								
                                if 	orig_ais_sign_off_date		!=. &           ///
                                    original_closing_date				!=.
                                    
*Generating Sign off to closing date to check for average length

gen 	orig_aissign_cl			=	original_closing_date		                        ///		
                                -	orig_ais_sign_off_date 	                    ///	
                                if 	orig_ais_sign_off_date		!=. &           /// 
									orig_final_del_date       !=.


					***********************************
					*ORIGINAL ACTIVITY PREPARATION DATE
					***********************************

*Checking for error: If decision meeting is earlier than activity preparation
sum 	orig_act_preparation_date                                               ///
        orig_decision_mtg_date 										            ///
                                if 	orig_act_preparation_date	!=. &           /// 
                                    orig_decision_mtg_date		!=.
                                    
*Generating Activity Preparation to Decision Period to check for average length
gen 	orig_actprep_decmtg		=	orig_decision_mtg_date		                ///
                                -	orig_act_preparation_date 	                /// 
                                if 	orig_act_preparation_date	!=. &           /// 
                                    orig_decision_mtg_date      !=.
                                    
*Checking for error: If original delivery date is earlier than activity preparation
sum 	orig_act_preparation_date                                               ///
        orig_del_to_client_date 									            ///
                                if 	orig_act_preparation_date	!=. &           /// 
                                    orig_del_to_client_date!=.

*Generating Activity Preparation to original delivery date to check for average length
gen 	orig_actprep_delcl      =   orig_del_to_client_date                   ///
                                -   orig_act_preparation_date 	                ///				
                                if 	orig_act_preparation_date	!=. &           /// 
                                    orig_del_to_client_date	!=.
                                        
*Checking for error: If original delivery date is earlier than activity preparation
sum 	orig_act_preparation_date                                               ///
        orig_final_del_date 			                                        ///							
                                if 	orig_act_preparation_date	!=. &           /// 
                                    orig_final_del_date       !=.

*Generating Activity Preparation to final delivery date to check for average length
gen 	orig_actprep_fdel       =   orig_final_del_date                       ///
                                -   orig_ais_sign_off_date 		                ///	
                                if  orig_act_preparation_date   !=. &           ///
                                    orig_final_del_date!=.

*Checking for error: If closing date is earlier than activity preparation
sum 	orig_act_preparation_date                                               ///
        original_closing_date 						                                    ///		
                                if  orig_act_preparation_date   !=. &           ///
                                    original_closing_date!=.

*Generating Activity Preparation to closing date to check for average length
gen 	orig_actprep_cl         =   original_closing_date                               ///
                                -   orig_act_preparation_date 	                ///			
                                if  orig_act_preparation_date   !=. &           ///
                                    orig_final_del_date!=.


					********************************
					*ORIGINAL DECISION MEETING DATE
					********************************
					
*Checking for error: If delivery to client is earlier than decision meeting
sum 	orig_decision_mtg_date                                                  ///
        orig_del_to_client_date 					                            ///	
                                if  orig_decision_mtg_date      !=. &           ///
                                    orig_del_to_client_date   !=.

*Generating decision meeting to delivery to client to check for average length
gen 	orig_decmtg_delcl       =   orig_del_to_client_date                   ///
                                -   orig_decision_mtg_date 		                ///
                                if  orig_decision_mtg_date      !=. &           ///
                                    orig_del_to_client_date   !=.

*Checking for error: If final delivery date is earlier than decision meeting
sum 	orig_decision_mtg_date                                                  ///
        orig_final_del_date 							                        ///
                                if  orig_decision_mtg_date      !=. &           ///
                                    orig_final_del_date       !=.

*Generating decision meeting to final delivery date to check for average length
gen 	orig_decmtg_fdel        =   orig_final_del_date                       ///
                                -   orig_ais_sign_off_date 		                ///	
                                if  orig_act_preparation_date   !=. &           ///
                                    orig_final_del_date!=.

*Checking for error: If closing date is earlier than decision meeting
sum 	orig_decision_mtg_date                                                  ///
        original_closing_date 				                                            ///					
                                if  orig_decision_mtg_date      !=. &           ///
                                    original_closing_date!=.

*Generating decision meeting to closing date to check for average length
gen 	orig_decmtg_cl          =   original_closing_date                               ///
                                -   orig_decision_mtg_date 		                ///			
                                if  orig_decision_mtg_date      !=. &           ///
                                    orig_final_del_date       !=.

********************************************************************************
*	DROPPING IMPROBABLE VALUES FROM 'ORIGINAL' DATE VARIABLES
*	USING PERIOD VARIABLES TO DROP IMPROBABLE VALUES
********************************************************************************

				***********************
				*ORIGINAL SIGN OFF DATE
				***********************
				
gen 	orig_ais_sign_off_date_n					=	orig_ais_sign_off_date
format 	orig_ais_sign_off_date_n 				%td

*	DROPPING IF THE FOLLOWING PERIODS ARE >365*5 OR <0:
*1. SIGN OFF TO DECISION MEETING PERIOD 
*2. SIGN OFF TO ACT PREP PERIOD IS LESS THAN 0 OR >365*5 (5 Years)

local var orig_aissign_decmtg orig_aissign_actprep
	foreach x of local var {
		replace orig_ais_sign_off_date_n 		=. if   `x'<    0       &       ///
                                                        `x'!=   .               
		
        replace orig_ais_sign_off_date_n 		=. if   `x'>=   365*5   &       ///
                                                        `x'!=   .
	}

*	DROPPING IF THE FOLLOWING PERIODS ARE >365*10 OR <0:
*1. SIGN OFF TO DELIVERY TO CLIENT
*2. SIGN OFF TO FINAL DELIVERY IS LESS THAN 0 OR >365*10 (10 Years)

local var orig_aissign_delcl orig_aissign_fdel orig_aissign_cl

	foreach x of local var {
		replace orig_ais_sign_off_date_n 		=. if   `x'<    0       &       ///
                                                        `x'!=   .               
		
        replace orig_ais_sign_off_date_n 		=. if   `x'>=   365*10  &       ///
                                                        `x'!=   .
	}
    
sum 	orig_ais_sign_off_date orig_ais_sign_off_date_n

				******************************
				*ORIGINAL ACTIVITY PREPARATION
				******************************
				
gen 	orig_act_preparation_date_n				=	orig_act_preparation_date
format 	orig_act_preparation_date_n     %td

*	DROPPING IF THE FOLLOWING PERIODS ARE >365*5 (5 Years) OR <0:
*1. ACTIVITY PREPARATION TO DECISION MEETING PERIOD 
*2. ACTIVITY PREPARATION TO ACT PREP PERIOD

local var orig_actprep_decmtg orig_aissign_actprep

	foreach x of local var {
		replace orig_act_preparation_date_n 	=. if   `x'<    0       &       ///
                                                        `x'!=   .               
		
        replace orig_act_preparation_date_n 	=. if   `x'>=   365*5   &       ///
                                                        `x'!=   .
	}

*	DROPPING IF THE FOLLOWING PERIODS ARE >365*10 OR <0:
*1. ACTIVITY PREPARATION TO DELIVERY TO CLIENT
*2. ACTIVITY PREPARATION TO FINAL DELIVERY IS LESS THAN 0 OR >365*10 (10 Years)

local var orig_actprep_delcl orig_actprep_fdel orig_actprep_cl

	foreach x of local var {
		replace orig_act_preparation_date_n 	=.  if  `x'<    0      &        ///
                                                        `x'!=   .
                                                        
		replace orig_act_preparation_date_n 	=.  if  `x'>=   365*10 &        ///
                                                        `x'!=   .
	}
	
sum 	orig_act_preparation_date orig_act_preparation_date_n

				***************************
				*ORIGINAL DECISION MEETING
				***************************
				
gen 	orig_decision_mtg_date_n				=	orig_decision_mtg_date
format 	orig_decision_mtg_date_n 				%td

*	DROPPING IF THE FOLLOWING PERIODS ARE >365*5 (5 Years) OR <0:
*1. DECISION MEETING TO DELIVERY TO CLIENT
*2. DECISION MEETING TO FINAL DELIVERY 
*3. DECISION MEETING TO CLOSING
*4. SIGN OFF TO DECISION MEETING
*5. ACTIVITY PREP TO DECISION MEETING 

local var   orig_actprep_decmtg orig_aissign_decmtg orig_decmtg_delcl           ///
            orig_decmtg_fdel orig_decmtg_cl

	foreach x of local var {
		replace orig_decision_mtg_date_n        =. 	if  `x'<    0       &       ///
                                                        `x'!=   .
        
		replace orig_decision_mtg_date_n        =. 	if  `x'>=   365*5   &       ///
                                                        `x'!=   .
	}
    
sum 	orig_decision_mtg_date_n orig_decision_mtg_date

				******************************
				*ORIGINAL ACTIVITY PREPARATION
				******************************
				
gen 	orig_del_to_client_date_n				=	orig_del_to_client_date
format 	orig_del_to_client_date_n 			%td

*	DROPPING IF THE FOLLOWING PERIODS ARE >365*10 (10 Years) OR <0:
*1. SIGN OFF TO DELIVERY TO CLIENT
*2. ACTIVITY PREP TO DELIVERY TO CLIENT

local var orig_aissign_delcl orig_actprep_delcl 

	foreach x of local var {
		replace orig_del_to_client_date_n 	=.  if  `x'<    0       &       ///
                                                        `x'!=   .
                                                        
		replace orig_del_to_client_date_n 	=.  if  `x'>    365*10  &       ///
                                                        `x'!=   .
	}
	
*	DROPPING IF THE FOLLOWING PERIODS ARE >365*5 (5 Years) OR <0:
*1. DECISION MEETING TO DELIVERY TO CLIENT

local var orig_decmtg_delcl

	foreach x of local var {
		replace orig_del_to_client_date_n 	=.  if  `x'<    0       &       ///
                                                        `x'!=   .
                                                        
		replace orig_del_to_client_date_n 	=.  if  `x'>    365*5   &       ///
                                                        `x'!=   .
	}
sum 	orig_del_to_client_date orig_del_to_client_date_n

				**************************
				*ORIGINAL FINAL DELIVERY
				**************************
				
gen orig_final_del_date_n						=	orig_final_del_date
format orig_final_del_date_n 					%td

*	DROPPING IF THE FOLLOWING PERIODS ARE >365*10 (10 Years) OR <0:
*1. SIGN OFF TO FINAL DELIVERY
*2. ACTIVITY PREP TO FINAL DELIVERY

local var orig_aissign_fdel orig_actprep_fdel 

	foreach x of local var {
		replace orig_final_del_date_n			=.  if  `x'<    0       &       ///
                                                        `x'!=   .
                                                        
		replace orig_final_del_date_n 		=.  if  `x'>=   365*10  &       ///
                                                        `x'!=   .
	}
	
*	DROPPING IF THE FOLLOWING PERIODS ARE >365*10 (5 Years) OR <0:
*1. DECISION MEETING TO FINAL DELIVERY

local var orig_decmtg_fdel

	foreach x of local var {
		replace orig_final_del_date_n			=.  if  `x'<    0       &       ///
                                                        `x'!=   .
                                                        
		replace orig_final_del_date_n 		=.  if  `x'>=   365*5   &       ///
                                                        `x'!=.
	}
				**********************
                *ORIGINAL CLOSING DATE
                **********************
gen 	original_closing_date_n							=	original_closing_date
format 	original_closing_date_n 						%td

*	DROPPING IF THE FOLLOWING PERIODS ARE >365*10 (10 Years) OR <0:
*1. ACTIVITY PREP TO CLOSING DATE
*2. SIGN OFF TO CLOSING

local var orig_actprep_cl orig_aissign_cl 

	foreach x of local var {
		replace original_closing_date_n					=.  if  `x'<    0       &       ///
                                                        `x'!=   .
                                                        
		replace original_closing_date_n					=.  if  `x'>=   365*10  &       ///
                                                        `x'!=   .
	}

*	DROPPING IF THE FOLLOWING PERIODS ARE >365*5 (5 Years) OR <0:
*1. DECISION MEETING TO CLOSING DATE

local var orig_decmtg_cl

	foreach x of local var {
		replace original_closing_date_n					=.  if  `x'<    0 &             ///  
                                                        `x'!=.
                                                        
		replace original_closing_date_n					=.  if  `x'>=   365*5 &         ///
                                                        `x'!=   .
	}

*PROJECT CYCLE
/*
Milestones in order: orig_ais_sign_off_date --> ais_sign_off_date -->
ais_start_concept_note_date-->orig_decision_mtg_date-->decision_mtg_date -->
auth_apprs_neg_date-->orig_del_to_client_date-->del_to_client_date-->
orig_final_del_date-->final_delivery_date-->

Activity Preparation to Activity Completion Summary Date
orig_act_preparation_date-->act_preparation_date-->orig_acs_date-->
original_closing_date-->revised_closing_date
*/

*AIS TO CONCEPT NOTE DATE
*************************

sum     ais_sign_off_date                                                        ///
        orig_ais_sign_off_date                                                   ///
       ais_start_concept_note_date

sum     orig_ais_sign_off_date       if  ais_sign_off_date                ==.

gen     ais_cn_p                    =  ais_start_concept_note_date              ///  
                                    -   ais_sign_off_date                        ///
                                    if ais_start_concept_note_date      !=. &   ///
                                       ais_start_concept_note_date      !=.

*AIS TO DECISION DATE
*********************

sum 	decision_mtg_date 														///
		orig_decision_mtg_date 													///
		ais_sign_off_date
	
sum 	orig_decision_mtg_date 		if 	decision_mtg_date				==.

gen 	ais_dec_p					=	decision_mtg_date						///
									-	ais_sign_off_date 						///
									if 	decision_mtg_date				!=. & 	///
										ais_sign_off_date!=.

*AIS TO APPROVAL
****************

gen 	ais_appr_p					=	auth_apprs_neg_date				///
									-	ais_sign_off_date 						///
									if 	auth_apprs_neg_date		!=. & 	///
										ais_sign_off_date				!=.

*AIS TO FINAL DELIVERY
gen 	ais_fdel_p					=	final_delivery_date						///
									-	ais_sign_off_date 						///
									if 	final_delivery_date				!=. & 	///
										ais_sign_off_date				!=.

*AIS TO DELIVERY TO CLIENT
gen 	ais_delcl_p					=	del_to_client_date					///
									-	ais_sign_off_date 						///
									if 	del_to_client_date			!=. & 	///
										ais_sign_off_date				!=.

*CONCEPT NOTE TO DECISION DATE	
sum 	decision_mtg_date 														///
		orig_decision_mtg_date 													///
		ais_start_concept_note_date												///

sum 	orig_decision_mtg_date 		if 	decision_mtg_date				==.		

gen 	cn_dec_p					=	decision_mtg_date						///
									-	ais_start_concept_note_date 				///
									if 	decision_mtg_date				!=. & 	///
										ais_start_concept_note_date		!=. 

*CONCEPT NOTE TO APPROVAL
gen 	cn_appr_p					=	auth_apprs_neg_date				///
									-	ais_start_concept_note_date 				///
									if 	auth_apprs_neg_date		!=. & 	///
										ais_start_concept_note_date		!=. 

*CONCEPT NOTE TO DELIVERY TO CLIENT
gen 	cn_delcl_p					=	del_to_client_date					///
									-	ais_start_concept_note_date 				///
									if 	del_to_client_date			!=. & 	///
										ais_start_concept_note_date		!=. 

*CONCEPT NOTE TO FINAL DELIVERY
gen 	cn_fdel_p					=	final_delivery_date						///
									-	ais_start_concept_note_date 				///
									if 	final_delivery_date				!=. & 	///
										ais_start_concept_note_date		!=. 

*DECISION TO APPROVAL DATE
gen 	dec_appr_p					=	auth_apprs_neg_date				///
									-	decision_mtg_date 						///
									if 	auth_apprs_neg_date		!=. & 	///
										decision_mtg_date				!=.

*DECISION TO DELIVERY TO CLIENT
gen 	dec_delcl_p					=	del_to_client_date					///
									-	decision_mtg_date 						///
									if 	del_to_client_date			!=. &	/// 
										decision_mtg_date				!=.

*DECISION TO FINAL DELIVERY
sum 	decision_mtg_date 														///
		orig_final_del_date 													///
		final_delivery_date
		
gen 	dec_fdel_p					=	final_delivery_date						///
									-	decision_mtg_date 						///
									if 	final_delivery_date				!=. & 	///
										decision_mtg_date				!=. 

*APPROVAL TO DELIVERY TO CLIENT
gen 	appr_delcl_p				=	del_to_client_date					///
									-	auth_apprs_neg_date 				///
									if 	del_to_client_date			!=. & 	///
										auth_apprs_neg_date		!=. 

*DROPPING IMPROBABLE VALUES FROM 'ACTUAL' DATE VARIABLES

*ais_sign_off_date
gen 	ais_sign_off_date_n			=	ais_sign_off_date
format 	ais_sign_off_date_n 			%td

replace ais_sign_off_date_n 			=. 											///
									if 	ais_cn_p	<=	365 & 					///
										ais_cn_p	!=.

local var ais_dec_p ais_appr_p 

	foreach x of local var {
		replace 	ais_sign_off_date_n 	=. if 	`x'<	0 & 					///
												`x'!=	.						
												
		replace 	ais_sign_off_date_n 	=. if 	`x'>=	365*5 & 				///
												`x'!=.							
	}
	
local var ais_delcl_p ais_fdel_p

	foreach x of local var {
		replace 	ais_sign_off_date_n 	=. if 	`x'<	0 & 					///
												`x'!=	.
												
		replace 	ais_sign_off_date_n 	=. if 	`x'>=	365*10 & 				///
												`x'!=	.
	}
	
sum ais_sign_off_date_n ais_sign_off_date

*ais_start_concept_note_date
gen 	ais_start_concept_note_date_n	=	ais_start_concept_note_date
format 	ais_start_concept_note_date_n 	%td

replace ais_start_concept_note_date_n 	=. 										///
										if 	ais_cn_p	<=	365 & 				///
											ais_cn_p	!=	.

local var cn_dec_p 

	foreach x of local var {
		replace 	ais_start_concept_note_date_n 	=.	if 	`x'<	0 & 		///
															`x'!=	.
															
		replace 	ais_start_concept_note_date_n 	=. 	if 	`x'>=	365*5 & 	///
															`x'!=	.
	}
	
local var cn_delcl_p cn_fdel_p

	foreach x of local var {
		replace 	ais_start_concept_note_date_n 	=. 	if 	`x'<	0 & 		///
															`x'!=	.
															
		replace 	ais_start_concept_note_date_n 	=. if 	`x'>=	365*10 & 	///
															`x'!=	.
	}
	
sum ais_start_concept_note_date_n ais_start_concept_note_date

*decision_mtg_date
gen 	decision_mtg_date_n		=	decision_mtg_date
format 	decision_mtg_date_n 	%td

local var cn_dec_p ais_dec_p dec_appr_p

	foreach x of local var {
		replace 	decision_mtg_date_n 	=. 	if 	`x'<	0 & 				///
													`x'!=	.
													
		replace 	decision_mtg_date_n 	=. 	if 	`x'>=	365*5 & 			///
													`x'!=	.
	}
	
local var dec_delcl_p dec_fdel_p

	foreach x of local var {
		replace 	decision_mtg_date_n 	=. 	if 	`x'<	0 & 				///
													`x'!=	.
													
		replace 	decision_mtg_date_n 	=. 	if 	`x'>=	365*10 & 			///
													`x'!=	.
	}
	
sum decision_mtg_date_n decision_mtg_date

*auth_apprs_neg_date
gen 	auth_apprs_neg_date_n	=	auth_apprs_neg_date
format 	auth_apprs_neg_date_n 	%td

local var cn_appr_p ais_appr_p dec_appr_p

	foreach x of local var {
		replace 	auth_apprs_neg_date_n 	=. 	if 	`x'<	0 & 		///
															`x'!=	.
															
		replace 	auth_apprs_neg_date_n 	=. 	if 	`x'>=	365*5 &		/// 
															`x'!=	.
	}
	
local var appr_delcl_p

	foreach x of local var {
		replace 	auth_apprs_neg_date_n 	=. 	if 	`x'<	0 & 		///
															`x'!=	.
															
		replace 	auth_apprs_neg_date_n 	=. 	if 	`x'>=	365*10 & 	///
															`x'!=	.
	}
	
sum auth_apprs_neg_date_n auth_apprs_neg_date

*del_to_client_date
gen 	del_to_client_date_n	=	del_to_client_date
format 	del_to_client_date_n 	%td

local var cn_delcl_p ais_delcl_p dec_delcl_p

	foreach x of local var {
		replace 	del_to_client_date_n 	=. 	if 	`x'<	0 & 				///
													`x'!=	.
													
		replace 	del_to_client_date_n 	=. 	if 	`x'>=	365*10 & 			///
													`x'!=	.
	}
sum del_to_client_date_n del_to_client_date

*final_delivery_date
gen 	final_delivery_date_n	=	final_delivery_date
format 	final_delivery_date_n 	%td

local var cn_fdel_p ais_fdel_p dec_fdel_p 

	foreach x of local var {
		replace 	final_delivery_date_n 	=. 	if 	`x'<	0 & 					///
												`x'!=	.
												
		replace 	final_delivery_date_n 	=. 	if 	`x'>=	365*10 & 				///
												`x'!=	.
	}
	
sum final_delivery_date_n final_delivery_date

			
********************************************************************************
					*CALCULATING NEW TIME OVERRUN
********************************************************************************


*ACTIVITY PREPARATION
*********************
gen 		tovr_act_prep_n		=	act_preparation_date						///
								-	orig_act_preparation_date_n 				///
								if 	orig_act_preparation_date_n		!=. & 		///
									act_preparation_date			!=.

sum 		tovr_act_prep_n 													///
			tovr_act_prep
		
*still too many outliers

replace 	tovr_act_prep_n		=. 												///
								if 	tovr_act_prep_n					<=	0 	| 	///
									tovr_act_prep_n					>=	365

gen 		tovr_delivery_n		=	final_delivery_date_n							///
								-	orig_final_del_date_n 					///
								if 	orig_final_del_date_n			!=. & 		///
									final_delivery_date_n				!=.

*DELIVERY
**********
sum 	tovr_delivery_n
replace tovr_delivery_n			=. 												///
								if 	tovr_delivery_n					<=	0 	| 	///
									tovr_delivery_n					>=	365*5

*DELIVERY TO CLIENT
*******************
gen 	tovr_del_to_client_n	=	del_to_client_date_n						///
								-	orig_del_to_client_date_n 				///
								if 	orig_del_to_client_date_n		!=. & 		///
									del_to_client_date_n			!=.
									
sum 	tovr_del_to_client_n
replace tovr_del_to_client_n	=. 												///
								if 	tovr_del_to_client_n			<=	0 	| 	///
									tovr_del_to_client_n			>=	365*5

*DECISION MEETING
******************
gen 	tovr_decision_mtg_n		=	decision_mtg_date_n							///
								-	orig_decision_mtg_date_n 					///
								if 	orig_decision_mtg_date_n		!=. & 		///
									decision_mtg_date_n				!=.
									
sum 	tovr_decision_mtg_n
replace tovr_decision_mtg_n		=. 												///
								if tovr_decision_mtg_n				<=	0 	| 	///	
									tovr_decision_mtg_n				>=	365*3

*SIGN OFF
**********
gen 	tovr_ais_signoff_n		=	ais_sign_off_date_n							///
								-	orig_ais_sign_off_date_n 					///
								if 	orig_ais_sign_off_date_n			!=. & 		///
									ais_sign_off_date_n				!=.
sum 	tovr_ais_signoff_n
replace tovr_ais_signoff_n		=. 												///
								if 	tovr_ais_signoff_n				<=	0 	| 	///
									tovr_ais_signoff_n				>=	365

*CLOSING DATE
*************
gen 	tovr_closing_date_n		=	revised_closing_date							///
								-	original_closing_date_n 							///
								if 	original_closing_date_n					!=. & 		///
									revised_closing_date				!=.
									
sum 	tovr_closing_date
replace tovr_closing_date_n		=. 												///
								if 	tovr_closing_date_n				<=	0 	| 	///
									tovr_closing_date_n				>=	365*10

********************************************************************************
					*PROPORTION OF PROJECTS WITH TIME OVERRUN
********************************************************************************

*ACTIVITY PREPARATION
*********************
egen 	nr_tovr_act_prep		=	count(tovr_act_prep_n) 						///
								if 	tovr_act_prep_n						!=.
								
egen 	temp1					=	count(orig_act_preparation_date_n) 			///
								if 	orig_act_preparation_date_n			!=.
								
egen 	temp2					=	count(act_preparation_date) 				///
								if 	act_preparation_date				!=. & 	///
									orig_act_preparation_date_n			==.
									
egen 	maxtemp1				=	max(temp1)

replace maxtemp1				=										0 		///
								if 	maxtemp1							==.
								
egen 	maxtemp2				=	max(temp2)

replace maxtemp2				=										0 		///
								if 	maxtemp2							==.
								
gen 	temp					=	maxtemp1									///
								+	maxtemp2
								
gen 	prop_tovr_act_prep_n	=	nr_tovr_act_prep/temp

drop 	temp temp1 temp2 maxtemp1 maxtemp2

*DELIVERY
**********
egen 	nr_tovr_delivery_n		=	count(tovr_delivery_n) 						///
								if 	tovr_delivery_n						!=.
								
egen 	temp1					=	count(orig_final_del_date_n) 				///
								if 	orig_final_del_date_n				!=.
								
egen 	temp2					=	count(final_delivery_date_n) 					///
								if 	final_delivery_date_n					!=. & 	///
									orig_final_del_date_n				==.
									
egen 	maxtemp1				=	max(temp1)

replace maxtemp1				=										0 		///
								if 	maxtemp1							==.
								
egen 	maxtemp2				=	max(temp2)

replace maxtemp2				=										0 		///
								if 	maxtemp2							==.
gen 	temp					=	maxtemp1									///
								+	maxtemp2
								
gen 	prop_tovr_delivery_n	=	nr_tovr_delivery_n/temp

drop temp temp1 temp2 maxtemp1 maxtemp2

*DELIVERY TO CLIENT
*******************
egen 	nr_tovr_del_to_client_n	=	count(tovr_del_to_client_n) 				///
								if 	tovr_del_to_client_n				!=.
								
egen 	temp1					=	count(orig_del_to_client_date_n) 			///
								if 	orig_del_to_client_date_n!=.
								
egen 	temp2					=	count(del_to_client_date_n) 				///
								if 	del_to_client_date_n				!=. & 	///
									orig_del_to_client_date_n			==.
									
egen 	maxtemp1				=	max(temp1)

replace maxtemp1				=										0 		///
								if 	maxtemp1							==.
								
egen 	maxtemp2				=	max(temp2)

replace maxtemp2				=										0 		///
								if 	maxtemp2==.
								
gen 	temp					=	maxtemp1									///
								+	maxtemp2
								
gen 	prop_tovr_del_to_client_n	=	nr_tovr_del_to_client_n/temp

drop temp temp1 temp2 maxtemp1 maxtemp2

*DECISION MEETING
******************	
egen 	nr_tovr_decision_mtg_n	=	count(tovr_decision_mtg_n) 					///
								if 	tovr_decision_mtg_n					!=.
								
egen 	temp1					=	count(orig_decision_mtg_date_n) 			///
								if 	orig_decision_mtg_date_n			!=.
								
egen 	temp2					=	count(decision_mtg_date_n) 					///
								if 	decision_mtg_date_n					!=. & 	///
									orig_decision_mtg_date_n			==.
									
egen 	maxtemp1				=	max(temp1)

replace maxtemp1				=										0 		///
								if 	maxtemp1							==.
								
egen 	maxtemp2				=	max(temp2)

replace maxtemp2				=										0 		///
								if 	maxtemp2							==.
								
gen 	temp					=	maxtemp1									///
								+	maxtemp2
								
gen 	prop_tovr_decision_mtg_n	=	nr_tovr_decision_mtg_n/temp

drop temp temp1 temp2 maxtemp1 maxtemp2

*SIGN OFF
**********
egen 	nr_tovr_ais_signoff_n	=	count(tovr_ais_signoff_n) 					///
								if 	tovr_ais_signoff_n					!=.
								
egen 	temp1					=	count(orig_ais_sign_off_date_n) 				///
								if 	orig_ais_sign_off_date_n				!=.
								
egen 	temp2					=	count(ais_sign_off_date_n) 					///
								if 	ais_sign_off_date_n					!=. & 	///
									orig_ais_sign_off_date_n				==.
									
egen 	maxtemp1				=	max(temp1)

replace maxtemp1				=										0 		///
								if 	maxtemp1							==.
								
egen 	maxtemp2				=	max(temp2)

replace maxtemp2				=										0 		///
								if 	maxtemp2							==.
								
gen 	temp					=	maxtemp1									///
								+	maxtemp2
								
gen 	prop_tovr_ais_signoff_n	=	nr_tovr_ais_signoff_n/temp

drop temp temp1 temp2 maxtemp1 maxtemp2

*CLOSING DATE
*************
egen 	nr_tovr_closing_date_n	=	count(tovr_closing_date_n) 					///
								if 	tovr_closing_date_n					!=.
								
egen 	temp1					=	count(original_closing_date_n) 						///
								if 	original_closing_date_n						!=.
								
egen 	temp2					=	count(revised_closing_date) 					///
								if 	revised_closing_date					!=. & 	///
									original_closing_date_n						==.
									
egen 	maxtemp1				=	max(temp1)

replace maxtemp1				=										0 		///
								if 	maxtemp1							==.
								
egen 	maxtemp2				=	max(temp2)

replace maxtemp2				=										0 		///
								if 	maxtemp2							==.
								
gen 	temp					=	maxtemp1									///
								+	maxtemp2
								
gen 	prop_tovr_closing_date_n	=	nr_tovr_closing_date_n/temp

drop temp temp1 temp2 maxtemp1 maxtemp2

*CALCULATING NEW ACTUAL PROJECT CYCLE 
*AIS TO CONCEPT NOTE DATE
gen 	ais_cn_pn		=	ais_start_concept_note_date_n						///
						-	ais_sign_off_date_n 									///
						if 	ais_start_concept_note_date_n			!=	. & 	///
							ais_start_concept_note_date_n			!=	.

*AIS TO DECISION DATE
gen 	ais_dec_pn		=	decision_mtg_date_n									///
						-	ais_sign_off_date_n 									///
						if 	decision_mtg_date_n						!=	. & 	///
							ais_sign_off_date_n						!=	.

*AIS TO APPROVAL
gen 	ais_appr_pn		=	auth_apprs_neg_date_n						///
						-	ais_sign_off_date_n 									///
						if 	auth_apprs_neg_date_n			!=	. &		/// 
							ais_sign_off_date_n						!=	.

*AIS TO FINAL DELIVERY
gen 	ais_fdel_pn		=	final_delivery_date_n									///
						-	ais_sign_off_date_n 									///
						if 	final_delivery_date_n						!=	. & 	///
							ais_sign_off_date_n						!=	.

*AIS TO DELIVERY TO CLIENT
gen 	ais_delcl_pn	=	del_to_client_date_n								///
						-	ais_sign_off_date_n 									///
						if 	del_to_client_date_n					!=	. & 	///
							ais_sign_off_date_n						!=	.

*CONCEPT NOTE TO DECISION DATE
gen 	cn_dec_pn		=	decision_mtg_date_n									///
						-	ais_start_concept_note_date_n 						///
						if 	decision_mtg_date_n						!=	. & 	///
							ais_start_concept_note_date_n			!=	. 

*CONCEPT NOTE TO DELIVERY TO CLIENT
gen 	cn_delcl_pn		=	del_to_client_date_n								///
						-	ais_start_concept_note_date_n 						///
						if 	del_to_client_date_n					!=	. & 	///
							ais_start_concept_note_date_n			!=	. 

*CONCEPT NOTE TO FINAL DELIVERY
gen 	cn_fdel_pn		=	final_delivery_date_n									///
						-	ais_start_concept_note_date_n 						///
						if 	final_delivery_date_n						!=	. & 	///
							ais_start_concept_note_date_n			!=	. 

*DECISION TO APPROVAL DATE
gen 	dec_appr_pn		=	auth_apprs_neg_date_n						///
						-	decision_mtg_date_n 								///
						if 	auth_apprs_neg_date_n			!=	. & 	///
							decision_mtg_date_n						!=	.

*DECISION TO DELIVERY TO CLIENT
gen 	dec_delcl_pn	=	del_to_client_date_n								///
						-	decision_mtg_date_n 								///
						if 	del_to_client_date_n					!=	. & 	///
							decision_mtg_date_n						!=	.

*DECISION TO FINAL DELIVERY
gen 	dec_fdel_pn		=	final_delivery_date_n									///
						-	decision_mtg_date_n 								///
						if 	final_delivery_date_n						!=	. & 	///
							decision_mtg_date_n						!=	. 

*DECISION TO CLOSING DATE
gen 	dec_cl_pn		=	revised_closing_date									///
						-	decision_mtg_date_n 								///
						if 	revised_closing_date						!=	. & 	///
							decision_mtg_date_n						!=	. 

*APPROVAL TO DELIVERY TO CLIENT
gen 	appr_delcl_pn	=	del_to_client_date_n								///
						-	auth_apprs_neg_date_n 						///
						if 	del_to_client_date_n					!=	. & 	///
							auth_apprs_neg_date_n			!=	. 

global 	period ais_cn_pn 	cn_dec_pn dec_appr_pn 	appr_delcl_pn 				///
		dec_delcl_pn 		dec_fdel_pn dec_cl_pn 	ais_fdel_pn

*PROCESSING PERIOD
******************
	
save "$onedrive\Intermediate\project_master_v2.dta", replace
