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
	}

set more off
cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Phase 1\Outputs\Raw"

********************************************************************************
*OBJECTIVE:
*	1. GENERATING TRUNCATED GENDER SCORE
*	2. GENERATE DIMENSION AND ENABLING ENVIRONMENT SCORES
*	3. GENERATE BINARY DEMOGRAPHIC SCORES
********************************************************************************
use "$onedrive\Intermediate\wbt_pilot_v2.dta", clear

*generating composite enabling env variable for both questions in one indicator
forvalues x=1/50{
cap noi replace score`x'a_env=0 if score`x'a_env==.
cap noi replace score`x'b_env=0 if score`x'b_env==.
cap noi gen score`x'_env=score`x'a_env+score`x'b_env
}

*GENERATING TRUNCATED GENDER SCORE
tab gender
tostring gender, gen(gender_trunc)
replace  gender_trunc="" if gender_trunc=="5"|gender_trunc=="7"
destring gender_trunc, replace
replace  gender_trunc=0 if gender_trunc==2
label define gender_trunclbl	1 "Female" 	0 "Male"		
label values gender_trunc gender_trunclbl

*GENERATING COUNT OF SUBMISSIONS FOR EACH DAY

bysort submissiondate: egen nr_subm = count(submissiondate)			
tab nr_subm	

*GENERATING BINARY VARIABLES FOR DEMOGRAPHICS
gen 		gg_above = 1 if grade==3|grade==4
replace 	gg_above = 0 if grade==1|grade==2|grade==5
label define gg_abovelbl	1 "GG and Above" 	0 "Below GG"		
label values gg_above gg_abovelbl
tab gg_above 

gen 		above10exp = 1 if experience==3|experience==4|experience==5
replace 	above10exp = 0 if experience==1|experience==2|experience==6
label define above10explbl	1 "> 10 Yrs Experience" 	0 "<= 10 Yrs Experience"		
label values above10exp above10explbl
tab above10exp

gen 		above40age = 1 if age==3|age==4
replace 	above40age = 0 if age==1|age==2
label define above40agelbl	1 "> 40 Yrs Age" 	0 "<= 40 Yrs Age"		
label values above40age above40agelbl
tab above40age

label variable gender_trunc "Female"
label variable above40age "Age>=40"
label variable above10exp "Experience>=40"
label variable gg_above ">=GG Grade"

*AGILITY SCORE
egen agilityscore = rowmean(peoplescore solutionsscore innovationscore growthscore)
format agilityscore %9.2f

*GENERATING A SCORE FOR AGILE ENVIRONMENT
egen agilityscore_env = rowmean(score*_env)
replace agilityscore_env = (agilityscore_env/4)*100
tab agilityscore_env

*GENERATING A SCORE FOR DIMENSIONS ENVIRONMENT
/*PEOPLE: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 48, 49, 50, 51
*PEOPLE ENV: score3_env score7_env score9_env score50_env

*SOLUTIONS: 14, 15, 16, 17, 18, 19, 20, 22, 23, 48, 50, 52, 53, 54
*SOLUTIONS ENV: score14_env score16_env score20_env score22_env score50_env

*INNOVATION: 25, 26, 27, 28, 29, 30, 31, 32, 52, 53, 55, 56
*INNOVATION ENV: score25_env score28_env score30_env score32_env

*GROWTH: 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 49, 51, 54, 55, 56
*GROWTH ENV: score33_env score37_env score41_env
*/

*PEOPLE ENVIRONMENT
egen peoplescore_env = rowmean(score3_env score7_env score9_env score50_env)
replace peoplescore_env = (peoplescore_env/4)*100
tab peoplescore_env

*PEOPLE TRUNCATED
egen peoplescore_trunc = rowmean(score3 score7 score9 score50)
replace peoplescore_trunc = (peoplescore_trunc/4)*100
tab peoplescore_trunc

*SOLUTIONS ENVIRONMENT
egen solutionsscore_env = rowmean(score14_env score16_env score20_env score22_env score50_env)
replace solutionsscore_env = (solutionsscore_env/4)*100
tab solutionsscore_env

*SOLUTIONS TRUNCATED
egen solutionsscore_trunc = rowmean(score14 score16 score20 score22 score50)
replace solutionsscore_trunc = (solutionsscore_trunc/4)*100
tab solutionsscore_trunc

*INNOVATIONS ENVIRONMENT
egen innovationscore_env = rowmean(score25_env score28_env score30_env score32_env)
replace innovationscore_env = (innovationscore_env/4)*100
tab innovationscore_env

*INNOVATIONS TRUNCATED
egen innovationscore_trunc = rowmean(score25 score28 score30 score32)
replace innovationscore_trunc = (innovationscore_trunc/4)*100
tab innovationscore_trunc

*GROWTH ENVIRONMENT
egen growthscore_env = rowmean(score33_env score37_env score41_env)
replace growthscore_env = (growthscore_env/4)*100
tab growthscore_env

*GROWTH TRUNCATED
egen growthscore_trunc = rowmean(score33 score37 score41)
replace growthscore_trunc = (growthscore_trunc/4)*100
tab growthscore_trunc

*AGILITY TRUNCATED
egen agilityscore_trunc = rowmean(peoplescore_trunc solutionsscore_trunc innovationscore_trunc growthscore_trunc)
tab agilityscore_trunc

*GENERATING FILTER VARIABLE FOR ROUND OF DATA COLLECTION
gen phase = 1

label define phaseslbl 	1 "Agile Champions Pilot" 2 "Phase 1" 
label values phase 		phaseslbl

*GENERATING PROPORTION VARIABLE FOR STRENGTH
local strength strengthpeople strengthsolutions strengthinnovation strengthgrowth
foreach var of local strength {
	egen `var'_p1 = count(`var') if `var'=="THIS IS YOUR STRENGTH!" & phase==1
	replace `var'_p1 = `var'_p1/51
	replace `var'_p1 = `var'_p1*100
	egen `var'_p2 = count(`var') if `var'=="THIS IS YOUR STRENGTH!" & phase==2	
	replace `var'_p2 = `var'_p2/334
	replace `var'_p2 = `var'_p2*100
	gen `var'_p = `var'_p1
	replace `var'_p = `var'_p2 if `var'_p==.
	drop `var'_p1 `var'_p2
	format `var'_p %9.2f
	gen `var'_n = 100 if `var'=="THIS IS YOUR STRENGTH!"
	replace `var'_n = 0 if `var'_n==.
	drop `var'
	ren `var'_n `var'
}

*GENERATING OBSERVATION ID
gen id = _n

*REMOVING NON-CONSENTING ENTRIES OR DUMMY ENTRIES FROM DATASET
drop if peoplescore<40|solutionsscore<40|innovationscore<40|growthscore<40

save "$onedrive\Intermediate\wbt_pilot_v3.dta", replace
