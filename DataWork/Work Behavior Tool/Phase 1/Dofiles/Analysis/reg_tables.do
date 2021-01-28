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
		ssc install grstyle, 	replace
		ssc install palettes, 	replace
		ssc install coefplot, 	replace
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

set more off
cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Phase 1\Outputs\Raw"

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************

use "$onedrive\Intermediate\wbt_v3.dta", clear

keep if extreme_responses_75==0
keep if extreme_responses_env_75==0

global dimension peoplescore_sd solutionsscore_sd innovationscore_sd growthscore_sd agilityscore_sd
global dimensionstrength strengthpeople strengthsolutions strengthinnovation strengthgrowth
global dimensionenv peoplescore_env_sd solutionsscore_env_sd innovationscore_env_sd growthscore_env_sd agilityscore_env_sd

*DETERMINANTS OF DIMENSION SCORES
* Model 1: Reg with Female + Grade
* Model 2: Reg with Female + Experience
* Model 3: Reg with Female + Age
* Model 4: Reg with Female + Grade + mapping dummies
* Model 5: Reg with Female + Grade + mapping dummies + motivation
* Model 6: Reg with Female + Grade + mapping dummies + internal processes
* Model 7: Reg with Female + Grade + mapping dummies + uses core skills
* Model 8: Reg with Female + Grade + mapping dummies + all anchors
* Model 9: Reg with Female + Exp + mapping dummies
* Model 10: Reg with Female + Exp + mapping dummies + motivation
* Model 11: Reg with Female + Exp + mapping dummies + internal processes
* Model 12: Reg with Female + Exp + mapping dummies + uses core skills
* Model 13: Reg with Female + Grade + mapping dummies + all anchors

pwcorr gender_trunc above10exp above40age gg_above motiv_sd int_proc_sd use_skills_sd, star(0.05) sig

foreach var of global dimensionstrength {
    * Model 1: Reg with Female + Grade
	logit `var' gender_trunc gg_above, robust
	estimates store m1`var', title(OLS+F+G)
	* Model 2: Reg with Female + Experience	
	logit `var' gender_trunc above10exp, robust
	estimates store m2`var', title(OLS+F+E)
	* Model 3: Reg with Female + Age
	logit `var' gender_trunc above40age
	estimates store m3`var', title(OLS+F+A)
	* Model 4: Reg with Female + Grade + mapping dummies
	logit `var' gender_trunc gg_above i.region i.practice_trunc i.vpu_trunc, robust
	estimates store m4`var', title(FE+F+G)
	* Model 5: Reg with Female + Grade + mapping dummies + motivation
	logit `var' gender_trunc gg_above motiv_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m5`var', title(FE+F+G+M)
	* Model 6: Reg with Female + Grade + mapping dummies + internal processes
	logit `var' gender_trunc gg_above int_proc_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m6`var', title(FE+F+G+I)
	* Model 7: Reg with Female + Grade + mapping dummies + uses core skills
	logit `var' gender_trunc gg_above use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m7`var', title(FE+F+G+U)
	* Model 8: Reg with Female + Grade + mapping dummies + all anchors
	logit `var' gender_trunc gg_above motiv_sd int_proc_sd use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m8`var', title(FE+F+G+M+I+U)
	* Model 9: Reg with Female + Exp + mapping dummies
	logit `var' gender_trunc above10exp i.region i.practice_trunc i.vpu_trunc, robust
	estimates store m9`var', title(FE+F+E)
	* Model 10: Reg with Female + Exp + mapping dummies + motivation
	logit `var' gender_trunc above10exp motiv_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m10`var', title(FE+F+E+M)
	* Model 11: Reg with Female + Exp + mapping dummies + internal processes
	logit `var' gender_trunc above10exp int_proc_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m11`var', title(FE+F+E+I)
	* Model 12: Reg with Female + Exp + mapping dummies + uses core skills
	logit `var' gender_trunc above10exp use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m12`var', title(FE+F+E+U)
	* Model 13: Reg with Female + Exp + mapping dummies + all anchors
	logit `var' gender_trunc above10exp motiv_sd int_proc_sd use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m13`var', title(FE+F+E+M+I+U)
	
	estout m1`var' m2`var' m3`var' m4`var' m5`var' m6`var' m7`var' m8`var' m9`var' ///
			m10`var' m11`var' m12`var' m13`var' using `var'.xls, 				///
		cells(b(star fmt(3)) se(par fmt(2))) legend label 						///
		varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) 				///
		label(R-sqr dfres BIC)) replace
}

pwcorr gender_trunc above10exp above40age gg_above motiv_sd int_proc_sd use_skills_sd, star(0.05) sig

foreach var of global dimension {
    * Model 1: Reg with Female + Grade
	reg `var' gender_trunc gg_above, robust
	estimates store m1`var', title(OLS+F+G)
	* Model 2: Reg with Female + Experience	
	reg `var' gender_trunc above10exp, robust
	estimates store m2`var', title(OLS+F+E)
	* Model 3: Reg with Female + Age
	reg `var' gender_trunc above40age
	estimates store m3`var', title(OLS+F+A)
	* Model 4: Reg with Female + Grade + mapping dummies
	reg `var' gender_trunc gg_above i.region i.practice_trunc i.vpu_trunc, robust
	estimates store m4`var', title(FE+F+G)
	* Model 5: Reg with Female + Grade + mapping dummies + motivation
	reg `var' gender_trunc gg_above motiv_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m5`var', title(FE+F+G+M)
	* Model 6: Reg with Female + Grade + mapping dummies + internal processes
	reg `var' gender_trunc gg_above int_proc_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m6`var', title(FE+F+G+I)
	* Model 7: Reg with Female + Grade + mapping dummies + uses core skills
	reg `var' gender_trunc gg_above use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m7`var', title(FE+F+G+U)
	* Model 8: Reg with Female + Grade + mapping dummies + all anchors
	reg `var' gender_trunc gg_above motiv_sd int_proc_sd use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m8`var', title(FE+F+G+M+I+U)
	* Model 9: Reg with Female + Exp + mapping dummies
	reg `var' gender_trunc above10exp i.region i.practice_trunc i.vpu_trunc, robust
	estimates store m9`var', title(FE+F+E)
	* Model 10: Reg with Female + Exp + mapping dummies + motivation
	reg `var' gender_trunc above10exp motiv_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m10`var', title(FE+F+E+M)
	* Model 11: Reg with Female + Exp + mapping dummies + internal processes
	reg `var' gender_trunc above10exp int_proc_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m11`var', title(FE+F+E+I)
	* Model 12: Reg with Female + Exp + mapping dummies + uses core skills
	reg `var' gender_trunc above10exp use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m12`var', title(FE+F+E+U)
	* Model 13: Reg with Female + Exp + mapping dummies + all anchors
	reg `var' gender_trunc above10exp motiv_sd int_proc_sd use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m13`var', title(FE+F+E+M+I+U)
	
	estout m1`var' m2`var' m3`var' m4`var' m5`var' m6`var' m7`var' m8`var' m9`var' ///
			m10`var' m11`var' m12`var' m13`var' using `var'.xls, 				///
		cells(b(star fmt(3)) se(par fmt(2))) legend label 						///
		varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) 				///
		label(R-sqr dfres BIC)) replace
}

foreach var of global dimensionenv {
    * Model 1: Reg with Female + Grade
	reg `var' gender_trunc gg_above, robust
	estimates store m1`var', title(OLS+F+G)
	* Model 2: Reg with Female + Experience	
	reg `var' gender_trunc above10exp, robust
	estimates store m2`var', title(OLS+F+E)
	* Model 3: Reg with Female + Age
	reg `var' gender_trunc above40age
	estimates store m3`var', title(OLS+F+A)
	* Model 4: Reg with Female + Grade + mapping dummies
	reg `var' gender_trunc gg_above i.region i.practice_trunc i.vpu_trunc, robust
	estimates store m4`var', title(FE+F+G)
	* Model 5: Reg with Female + Grade + mapping dummies + motivation
	reg `var' gender_trunc gg_above motiv_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m5`var', title(FE+F+G+M)
	* Model 6: Reg with Female + Grade + mapping dummies + internal processes
	reg `var' gender_trunc gg_above int_proc_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m6`var', title(FE+F+G+I)
	* Model 7: Reg with Female + Grade + mapping dummies + uses core skills
	reg `var' gender_trunc gg_above use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m7`var', title(FE+F+G+U)
	* Model 8: Reg with Female + Grade + mapping dummies + all anchors
	reg `var' gender_trunc gg_above motiv_sd int_proc_sd use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m8`var', title(FE+F+G+M+I+U)
	* Model 9: Reg with Female + Exp + mapping dummies
	reg `var' gender_trunc above10exp i.region i.practice_trunc i.vpu_trunc, robust
	estimates store m9`var', title(FE+F+E)
	* Model 10: Reg with Female + Exp + mapping dummies + motivation
	reg `var' gender_trunc above10exp motiv_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m10`var', title(FE+F+E+M)
	* Model 11: Reg with Female + Exp + mapping dummies + internal processes
	reg `var' gender_trunc above10exp int_proc_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m11`var', title(FE+F+E+I)
	* Model 12: Reg with Female + Exp + mapping dummies + uses core skills
	reg `var' gender_trunc above10exp use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m12`var', title(FE+F+E+U)
	* Model 13: Reg with Female + Exp + mapping dummies + all anchors
	reg `var' gender_trunc above10exp motiv_sd int_proc_sd use_skills_sd i.region i.practice_trunc i.vpu_trunc
	estimates store m13`var', title(FE+F+E+M+I+U)
	
	estout m1`var' m2`var' m3`var' m4`var' m5`var' m6`var' m7`var' m8`var' m9`var' ///
			m10`var' m11`var' m12`var' m13`var' using `var'.xls, 				///
		cells(b(star fmt(3)) se(par fmt(2))) legend label 						///
		varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) 				///
		label(R-sqr dfres BIC)) replace
}
