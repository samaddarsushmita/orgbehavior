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

********************************************************************************
*							EXTREME RESPONSES									*
********************************************************************************
twoway (hist extreme_responses, freq width(5) color(green)) 						///
       (hist extreme_responses_env, freq width(5) fcolor(none) lcolor(black)),  	///
	   legend(order(1 "Main" 2 "Environment" ))
graph export hist_extreme.png, as(png) name("Graph") replace

twoway (scatter agilityscore extreme_responses)						///
		(lfit 	agilityscore extreme_responses, lcolor(red)),			///
		xtitle("Extreme Responses") ytitle("Agility Score")				///
		title("Effect of Extreme Responses over Agility Score", size(medium)) legend(off)
graph export scatter_extreme.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  extreme_responses `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Extreme Responses Score") ylabel(-10(5)10)									///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_extreme_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

reg agilityscore extreme_responses, robust
*b = .1490594, p = 0
********************************************************************************
keep if extreme_responses_75==0

global dimension peoplescore_sd solutionsscore_sd innovationscore_sd growthscore_sd agilityscore_sd

set graphics off

/*COEF PLOT FOR DEMEANING OPERATOR
foreach var of global dimension {
reg `var' operator, robust
estimates store `var'
}
coefplot 	(peoplescore_sd, label(People))										///
			(solutionsscore_sd, label(Solution))								///
			(innovationscore_sd, label(Innovation))								///
			(growthscore_sd, label(Growth))										///
			(agilityscore_sd, label(Agility)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			vertical	xtitle("")										///
	graphregion(color(white)) bgcolor(white)								///
	title("Correlated with Demeaning Operator")																	///
	ysize(3) xsize(3)	ylabel(-1(0.5)3)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_operator_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}
*/

********************************************************************************
*							SOCIAL DESIRABILITY									*
********************************************************************************
hist social_desirability, freq color(green) lcolor(black) 						///
		xtitle("Social Desirability (mean)")						
graph export hist_sd.png, as(png) name("Graph") replace

twoway (scatter agilityscore social_desirability)						///
		(lfit 	agilityscore social_desirability, lcolor(red)),			///
		xtitle("Social Desirability") ytitle("Agility Score")				///
		title("Effect of Social Desirability over Agility Score", size(medium)) legend(off)
graph export scatter_sd.png, as(png) name("Graph") replace

reg agilityscore social_desirability, robust
*b = 1.907888, p = 0

twoway (scatter agilityscore_env social_desirability)						///
		(lfit 	agilityscore_env social_desirability, lcolor(red)),			///
		xtitle("Social Desirability") ytitle("Environment Agility Score")				///
		title("Effect of Social Desirability over Environment Agility Score", size(medium)) legend(off)
graph export scatter_sd_env.png, as(png) name("Graph") replace

reg agilityscore_env social_desirability, robust
*b = 2.137116, p = 0.013

local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
replace sd = 100 if sd == 1
reg  sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Social Desirability Score") ylabel(-30(10)30)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_sd_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*REGION CORRELATES
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
replace sd = 100 if sd == 1
reg  sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-50(10)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Social Desirability Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_sd_sd.png, as(png) name("Graph") replace
restore

*PRACTICE CORRELATES
preserve
replace int_proc_sd = 100 if int_proc_sd == 1
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
    replace sd = 100 if sd == 1
reg  sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-50(10)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Social Desirability Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_sd_sd.png, as(png) name("Graph") replace
restore

*VPU CORRELATES
preserve
replace int_proc_sd = 100 if int_proc_sd == 1
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
        replace sd = 100 if sd == 1
reg  sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-50(10)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Social Desirability Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_sd_sd.png, as(png) name("Graph") replace
restore

*******************************************************************************
*					ANCHOR QUESTIONS BY DEMOGRAPHIC CATEGORIES
********************************************************************************
*INTERNAL PROCESSES - COEF PLOT
preserve
replace int_proc_sd = 100 if int_proc_sd == 1
local dem gender_trunc above40age above10exp gg_above
foreach var of local dem {
reg  int_proc_sd `var', robust
estimates store `var'
}

coefplot 	(gender_trunc, 		label(Female) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(above40age, 	label(>=40 Age) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(above10exp, 	label(>=10 Experience) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(gg_above, 		label(>=GG Grade) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange))),						///
			drop(_cons) yline(0)  format(%9.2f) 	xlabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) ylabel(-20(10)30)								///
			graphregion(color(white)) bgcolor(white) vertical							///
	title( "Likelihood of Scoring Internal Processes as Useful", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_intproc_dem_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}
restore

*MOTIVATION - COEF PLOT
preserve
replace motiv_sd = 100 if motiv_sd == 1
local dem gender_trunc above40age above10exp gg_above
foreach var of local dem {
reg  motiv_sd `var', robust
estimates store `var'
}

coefplot 	(gender_trunc, 		label(Female) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(above40age, 	label(>=40 Age) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(above10exp, 	label(>=10 Experience) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(gg_above, 		label(>=GG Grade) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange))),						///
			drop(_cons) yline(0)  format(%9.2f) 	xlabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) ylabel(-20(10)30)								///
			graphregion(color(white)) bgcolor(white) vertical							///
	title( "Likelihood of being Motivated", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_motiv_dem_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}
restore

*USE SKILLS - COEF PLOT
preserve
replace use_skills_sd = 100 if use_skills_sd == 1
local dem gender_trunc above40age above10exp gg_above
foreach var of local dem {
reg  use_skills_sd `var', robust
estimates store `var'
}

coefplot 	(gender_trunc, 		label(Female) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(above40age, 	label(>=40 Age) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(above10exp, 	label(>=10 Experience) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(gg_above, 		label(>=GG Grade) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange))),						///
			drop(_cons) yline(0)  format(%9.2f) 	xlabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) ylabel(-20(10)30)								///
			graphregion(color(white)) bgcolor(white) vertical							///
	title( "Likelihood of using Core Skills at Work", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_use_skills_dem_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}
restore
********************************************************************************
*					ANCHOR QUESTIONS BY REGION MAPPING
********************************************************************************
*INTERNAL PROCESSES - COEF PLOT
preserve
replace int_proc_sd = 100 if int_proc_sd == 1
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  int_proc_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Internal Processes Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_int_proc_sd.png, as(png) name("Graph") replace
restore

*MOTIV - COEF PLOT
preserve
replace motiv_sd = 100 if motiv_sd == 1
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  motiv_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Motivation Score", size(medium))						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_motiv_sd.png, as(png) name("Graph") replace
restore


*USE SKILLS - COEF PLOT
preserve
replace use_skills_sd = 100 if use_skills_sd == 1
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  use_skills_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Use Skills Score", size(medium))					///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_useskills_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*					ANCHOR QUESTIONS BY PRACTICE MAPPING
********************************************************************************
*INTERNAL PROCESSES - COEF PLOT
preserve
replace int_proc_sd = 100 if int_proc_sd == 1
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  int_proc_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-50(10)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Internal Processes Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_int_proc_sd.png, as(png) name("Graph") replace
restore

*MOTIV - COEF PLOT
preserve
replace motiv_sd = 100 if motiv_sd == 1
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  motiv_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-50(10)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Motivation Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_motiv_sd.png, as(png) name("Graph") replace
restore


*USE SKILLS - COEF PLOT
preserve
replace use_skills_sd = 100 if use_skills_sd == 1
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  use_skills_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-50(10)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Use Skills Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_use_skills_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*					ANCHOR QUESTIONS BY VPU MAPPING
********************************************************************************
*INTERNAL PROCESSES - COEF PLOT
preserve
replace int_proc_sd = 100 if int_proc_sd == 1
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  int_proc_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-50(10)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Internal Processes Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_int_proc_sd.png, as(png) name("Graph") replace
restore

*MOTIV - COEF PLOT
preserve
replace motiv_sd = 100 if motiv_sd == 1
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  motiv_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-50(10)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Motivation Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_motiv_sd.png, as(png) name("Graph") replace
restore


*USE SKILLS - COEF PLOT
preserve
replace use_skills_sd = 100 if use_skills_sd == 1
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  use_skills_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-50(10)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Uses Skills Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_use_skills_sd.png, as(png) name("Graph") replace
restore


********************************************************************************
*				WHAT ARE THE DETERMINANTS OF DIMENSION STRENGTHS
********************************************************************************
*AVERAGE DIMENSION SCORES 
grstyle init
grstyle set plain, horizontal
grstyle set color Accent: p#bar p#barline
grstyle set intensity 40: bar

foreach var of global dimension {
egen med_`var' = median(`var')
tab med_`var'
*people 80.02 , solutions 84.49, innovation 71.42, growth 79.55, agility 79.03
}

graph box $dimension,															///
	yvaroptions(relabel(1 "People" 		2 "Solutions"							///
						3 "Innovation"	4 "Growth"	5 "Overall Agility"))		///						
	ylabel(40(10)100)outergap(20) bargap(30) showyvars legend(off) nooutsides 				///	
	box(1, fcolor(green) lcolor(green)) 										///
	box(2, fcolor(edkblue) lcolor(edkblue))										///
	box(3, fcolor(purple) lcolor(purple))										///
	box(4, fcolor(dkorange) lcolor(dkorange))									///
	box(5, fcolor(black) lcolor(black)) 										///
	ytitle("Dimension Scores", size(small))										///
	graphregion(color(white)) bgcolor(white)									///
	title( "Average Scores on each Dimension", size(medium))					///
	note("Source: Data Collected from 311 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_scores_sd.png, as(png) name("Graph") replace

*PEOPLE
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  strengthpeople `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("People Strength")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_peoplestrength_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*SOLUTIONS
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  strengthsolutions `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Solutions Strength")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_solutionsstrength_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*INNOVATION
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  strengthinnovation `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Innovation Strength")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_innovationstrength_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*GROWTH
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  strengthgrowth `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical	ylabel(-30(10)30)										///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Growth Strength")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_growthstrength_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}
********************************************************************************
*						REGIONAL DISTRIBUTION OF SCORES
********************************************************************************

*COEF PLOT - PEOPLE
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  strengthpeople region`x', robust
estimates store region`x'
}
coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("People Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_peoplestrength_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  strengthsolutions region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical ylabel(-30(10)30)								///
	graphregion(color(white)) bgcolor(white)									///
	title("Solutions Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_solutionsstrength_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  strengthinnovation region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Innovation Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_innovationstrength_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  strengthgrowth region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Growth Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_growthstrength_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*						PRACTICE DISTRIBUTION OF SCORES
********************************************************************************
*COEF PLOT - PEOPLE
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  strengthpeople practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-50(20)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("People Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_peoplestrength_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  strengthsolutions practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-50(20)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Solutions Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_solutionsstrength_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  strengthinnovation practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-50(20)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Innovation Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_innovationstrength_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  strengthgrowth practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-50(20)50)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Growth Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_growthstrength_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*						VPU DISTRIBUTION OF SCORES
********************************************************************************
*COEF PLOT - PEOPLE
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  strengthpeople vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-100(20)100)								///
	graphregion(color(white)) bgcolor(white)									///
	title("People Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_peoplestrength_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  strengthsolutions vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-100(20)100)								///
	graphregion(color(white)) bgcolor(white)									///
	title("Solutions Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_solutionsstrength_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  strengthinnovation vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-100(20)100)								///
	graphregion(color(white)) bgcolor(white)									///
	title("Innovation Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_innovationstrength_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  strengthgrowth vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-100(20)100)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Growth Strength", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_growthstrength_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*						WHAT ARE THE DETERMINANTS OF HIGH SCORES
********************************************************************************

*AGILITY SCORES

local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  agilityscore_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Agility Score")																	///
	ysize(3) xsize(3)	ylabel(-2(2)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_agility_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*PEOPLE
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  peoplescore_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("People Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_people_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*SOLUTIONS
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  solutionsscore_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Solutions Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_solutions_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*INNOVATION
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  innovationscore_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Innovation Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_innovation_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*GROWTH
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  growthscore_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical	ylabel(-10(5)10)										///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Growth Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_growth_sd.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}
********************************************************************************
*						REGIONAL DISTRIBUTION OF SCORES
********************************************************************************
*COEF PLOT - AGILITY
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  agilityscore_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Agility Score", size(medium))						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_agility_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - PEOPLE
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  peoplescore_sd region`x', robust
estimates store region`x'
}
coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("People Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_people_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  solutionsscore_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical ylabel(-10(5)10)								///
	graphregion(color(white)) bgcolor(white)									///
	title("Solutions Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_solutions_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  innovationscore_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Innovation Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_innovation_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  growthscore_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Growth Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_growth_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*						PRACTICE DISTRIBUTION OF SCORES
********************************************************************************
*COEF PLOT - AGILITY
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  agilityscore_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Agility Score", size(medium))						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_agility_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - PEOPLE
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  peoplescore_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("People Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_people_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  solutionsscore_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Solutions Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_solutions_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  innovationscore_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Innovation Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_innovation_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  growthscore_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Growth Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_growth_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*						VPU DISTRIBUTION OF SCORES
********************************************************************************
*COEF PLOT - AGILITY
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  agilityscore_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Agility Score", size(medium))						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_agility_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - PEOPLE
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  peoplescore_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("People Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_people_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  solutionsscore_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Solutions Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_solutions_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  innovationscore_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Innovation Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_innovation_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  growthscore_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Growth Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_growth_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*								ENVIRONMENT SCORES
*********************************************************************************

global dimension_env peoplescore_env_sd solutionsscore_env_sd innovationscore_env_sd growthscore_env_sd agilityscore_env_sd
global dimension_trunc peoplescore_trunc_sd solutionsscore_trunc_sd innovationscore_trunc_sd growthscore_trunc_sd agilityscore_trunc_sd

global dimensions_env_trunc $dimension_env $dimension_trunc

foreach var of global dimensions_env_trunc {
egen med_`var' = median(`var')
tab med_`var'
*people_env 68.75, solutions_env 65, innovation_env 62.5, growth_env 66.67, agility_env 65,
*people_trunc 62.5, solutionsscore_trunc 65, innovationscore_trunc 62.5 growth_trunc 66.67 agility_trunc 64.11
}

*DOT PLOT WITH ALL DIFFERENCE IN MEANS FOR ENV AND PERSONAL

*TTEST
foreach var in peoplescore solutionsscore innovationscore growthscore {
	ttest `var'_env_sd=`var'_trunc_sd
}

*GENERATING DIFFERENCE IN MEANS VARIABLES
foreach var in peoplescore solutionsscore innovationscore growthscore {
gen `var'_env_trunc_sd=`var'_env_sd-`var'_trunc_sd
}

*TTEST RESULTS
*Significant: peoplescore***, innovationscore***
preserve
gen allaverage = 1 
collapse (mean) peoplescore_env_trunc_sd solutionsscore_env_trunc_sd 					///
				innovationscore_env_trunc_sd growthscore_env_trunc_sd, by(allaverage)
rename (peoplescore_env_trunc_sd solutionsscore_env_trunc_sd innovationscore_env_trunc_sd growthscore_env_trunc_sd)	///
		(score_env_trunc1 score_env_trunc2 score_env_trunc3 score_env_trunc4)
reshape long score_env_trunc, i(allaverage) j(score_name)

label define score_namelbl	1 "People" 		2 "Solutions"						///
							3 "Innovation" 	4 "Growth"
label values score_name score_namelbl
format score_env_trunc %9.1f
sort score_name
twoway (scatter score_name score_env_trunc, mlabel(score_env_trunc)), 			///
	legend(label(1 "Environment Vs Personal (Trunc)"))									///
	ylabel(1 "People" 2 "Solutions" 3 "Innovation" 4 "Growth", angle(90))		///
	xlabel(-10(10)10) legend() xline(0) xtitle("Difference from Average")		 	///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")				///s
	title( "Environment vs Personal Scores", size(medium))									///
	subtitle("Difference from Average", size(small))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export diff_env_personal_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*			EFFECT OF ENVIRONMENT ON PERSONAL
********************************************************************************

*COEF PLOT OF ENV DIMENSIONS BY CHARACTERISTICS
local dim people solutions innovation growth agility
foreach var of local dim {
reg  `var'score_sd `var'score_env_sd, robust
estimates store `var'
}
coefplot 	(people, label(People))									///
			(solutions, label(Solutions))							///
			(innovation, label(Innovation))							///
			(growth, label(Growth))									///
			(agility, label(Agility)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "People" 2 "Solutions" 3 "Innovation" 4 "Growth" 	///
					5 "Agility", angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Effect of Environment on Personal Scores")	ylabel(-1(0.5)1)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_env_personal_sd.png, as(png) name("Graph") replace



*PEOPLE
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  peoplescore_env_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment People Score")											///
	ysize(3) xsize(3)	ylabel(-10(5)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_people_env_sd.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
estimates drop `var'
}

*SOLUTIONS
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  solutionsscore_env_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment Solutions Score")											///
	ysize(3) xsize(3)	ylabel(-10(5)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_solutions_env_sd.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
estimates drop `var'
}

*INNOVATION
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  innovationscore_env_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment Innovation Score")											///
	ysize(3) xsize(3)	ylabel(-10(5)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_innovation_env_sd.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
estimates drop `var'
}

*GROWTH
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  growthscore_env_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment Growth Score")											///
	ysize(3) xsize(3)	ylabel(-10(5)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_growth_env_sd.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
estimates drop `var'
}

*AGILITY
local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
reg  agilityscore_env_sd `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(use_skills_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment Agility Score")											///
	ysize(3) xsize(3)	ylabel(-10(5)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_agility_env_sd.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc_sd motiv_sd use_skills_sd
foreach var of local score {
estimates drop `var'
}

********************************************************************************
*					REGIONAL DISTRIBUTION OF ENVIRONMENT SCORES
********************************************************************************

*COEF PLOT - AGILITY
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  agilityscore_env_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical								///
	graphregion(color(white)) bgcolor(white)	ylabel(-10(5)10)								///
	title("Environment Agility Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_agility_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - PEOPLE
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  peoplescore_env_sd region`x', robust
estimates store region`x'
}
coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical								///
	graphregion(color(white)) bgcolor(white)	ylabel(-10(5)10)								///
	title("Environment People Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_people_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  solutionsscore_env_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical								///
	graphregion(color(white)) bgcolor(white)	ylabel(-10(5)10)								///
	title("Environment Solutions Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_solutions_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  innovationscore_env_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical ylabel(-10(5)10)								///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Innovation Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_innovation_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  growthscore_env_sd region`x', robust
estimates store region`x'
}

coefplot 	(region1, label("AFR"))												///
			(region2, label("EAP"))												///
			(region3, label("ECA"))												///
			(region4, label("LAC"))												///
			(region5, label("MENA"))											///
			(region6, label("SAR"))												///
			(region7, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AFR" 2 "EAP" 3 "ECA" 4 "LAC" 5 "MENA" 6 "SAR" 7 "Not Mapped", ///
			labsize(small)) legend(off)	vertical 	ylabel(-10(5)10)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Growth Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_growth_env_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*					PRACTICE DISTRIBUTION OF ENVIRONMENT SCORES
********************************************************************************

*COEF PLOT - AGILITY
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  agilityscore_env_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Agility Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_agility_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - PEOPLE
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  peoplescore_env_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment People Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_people_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  solutionsscore_env_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Solutions Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_solutions_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  innovationscore_env_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Innovation Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_innovation_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
tab practice_trunc, gen(practice_trunc)
forvalues x = 1/9 {
reg  growthscore_env_sd practice_trunc`x', robust
estimates store practice_trunc`x'
}

coefplot 	(practice_trunc1, label("AGR"))												///
			(practice_trunc2, label("FCI"))												///
			(practice_trunc3, label("GOV"))												///
			(practice_trunc4, label("MTI"))												///
			(practice_trunc7, label("SURR"))											///
			(practice_trunc8, label("TR"))												///
			(practice_trunc9, label("WATER"))										///
			(practice_trunc6, label("Other"))										///
			(practice_trunc5, label("Not Mapped")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "AGR" 2 "FCI" 3 "GOV" 4 "MTI" 5 "SURR" 6 "TR" 7 "WATER"	///
					8 "Other" 9 "Not Mapped", 									///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)							///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Growth Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_practice_growth_env_sd.png, as(png) name("Graph") replace
restore

********************************************************************************
*					VPU DISTRIBUTION OF ENVIRONMENT SCORES
********************************************************************************

*COEF PLOT - AGILITY
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  agilityscore_env_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)								///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Agility Score", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_agility_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - PEOPLE
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  peoplescore_env_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))												///
			(vpu_trunc2, label("ECR"))												///
			(vpu_trunc3, label("GGE"))												///
			(vpu_trunc4, label("GGH"))												///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))												///
			(vpu_trunc7, label("ITS"))										///
			(vpu_trunc8, label("OPCS"))										///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"	///
					8 "OPCS" 9 "Region VPU" 10 "Other", ///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)								///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment People Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_people_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  solutionsscore_env_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))											///
			(vpu_trunc2, label("ECR"))											///
			(vpu_trunc3, label("GGE"))											///
			(vpu_trunc4, label("GGH"))											///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))											///
			(vpu_trunc7, label("ITS"))											///
			(vpu_trunc8, label("OPCS"))											///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 					///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"		///
					8 "OPCS" 9 "Region VPU" 10 "Other", 						///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)				///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Solutions Score", size(medium))	ysize(3) xsize(3)		///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_solutions_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  innovationscore_env_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))											///
			(vpu_trunc2, label("ECR"))											///
			(vpu_trunc3, label("GGE"))											///
			(vpu_trunc4, label("GGH"))											///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))											///
			(vpu_trunc7, label("ITS"))											///
			(vpu_trunc8, label("OPCS"))											///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 					///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"		///
					8 "OPCS" 9 "Region VPU" 10 "Other", 						///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)				///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Innovation Score", size(medium))	ysize(3) xsize(3)		///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_innovation_env_sd.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
tab vpu_trunc, gen(vpu_trunc)
forvalues x = 1/10 {
reg  growthscore_env_sd vpu_trunc`x', robust
estimates store vpu_trunc`x'
}

coefplot 	(vpu_trunc1, label("BPS"))											///
			(vpu_trunc2, label("ECR"))											///
			(vpu_trunc3, label("GGE"))											///
			(vpu_trunc4, label("GGH"))											///
			(vpu_trunc5, label("GGS"))											///
			(vpu_trunc6, label("HRD"))											///
			(vpu_trunc7, label("ITS"))											///
			(vpu_trunc8, label("OPCS"))											///
			(vpu_trunc10, label("Region VPU"))									///
			(vpu_trunc9, label("Other")), drop(_cons) yline(0) 					///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)				///
			xlabel(1 "BPS" 2 "ECR" 3 "GGE" 4 "GGH" 5 "GGS" 6 "HRD" 7 "ITS"		///
					8 "OPCS" 9 "Region VPU" 10 "Other", 						///
			labsize(small)) legend(off)	vertical	ylabel(-30(10)30)				///
	graphregion(color(white)) bgcolor(white)									///
	title("Environment Growth Score", size(medium))	ysize(3) xsize(3)			///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_vpu_growth_env_sd.png, as(png) name("Graph") replace
restore
