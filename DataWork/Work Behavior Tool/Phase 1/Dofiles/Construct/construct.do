/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   				WBT DATA MASTER CLEANING DO								   *
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

set more off
cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Phase 1\Outputs\Raw"

if `genderunit' {
cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Gender\Outputs\Raw"
}	
********************************************************************************
*OBJECTIVE:
*	1. GENERATING TRUNCATED GENDER SCORE
*	2. GENERATE DIMENSION AND ENABLING ENVIRONMENT SCORES
*	3. GENERATE BINARY DEMOGRAPHIC SCORES
********************************************************************************
use "$onedrive\Intermediate\wbt_v2.dta", clear

gen 	total_resp 	=	_N

*GENERATING TRUNCATED GENDER SCORE
tab gender
tostring gender, gen(gend)
replace  gend="" if gend=="5"|gend=="7"
destring gend, replace
replace  gend=0 if gend==2
label define gendlbl	1 "Female" 	0 "Male"		
label values gend gendlbl
					
*GENERATING COUNT OF SUBMISSIONS FOR EACH DAY

bysort submissiondate: egen nr_subm = count(submissiondate)			
tab nr_subm	
	
*GENERATING BINARY VARIABLES FOR ANCHOR QUESTIONS
gen 		ip = 1 if demo3_intproc==3|demo3_intproc==4
replace 	ip = 0 if demo3_intproc==1|demo3_intproc==2|demo3_intproc==0
label define iplbl	1 "Helpful Internal Processes" 	0 "Unhelpful Internal Processes"		
label values ip iplbl
tab ip 

gen 		motiv = 1 if demo_motiv==3|demo_motiv==4
replace 	motiv = 0 if demo_motiv==1|demo_motiv==2|demo_motiv==0
label define motivlbl	1 "Motivated" 	0 "Demotivated"		
label values motiv motivlbl
tab motiv

gen 		usk = 1 if demo2_skills==3|demo2_skills==4
replace 	usk = 0 if demo2_skills==1|demo2_skills==2|demo2_skills==0
label define usklbl	1 "Use Core Skills" 	0 "Don't Use Core Skills"		
label values usk usklbl
tab usk

*GENERATING BINARY VARIABLES FOR DEMOGRAPHICS
gen 		gg_above = 1 if grade==3|grade==4
replace 	gg_above = 0 if grade==1|grade==2|grade==5
label define gg_abovelbl	1 "GG and Above" 	0 "Below GG"		
label values gg_above gg_abovelbl
tab gg_above 

gen 		expb = 1 if experience==3|experience==4|experience==5
replace 	expb = 0 if experience==1|experience==2|experience==6
label define expblbl	1 "> 10 Yrs Experience" 	0 "<= 10 Yrs Experience"		
label values expb expblbl
tab expb

gen 		ageb = 1 if age==3|age==4
replace 	ageb = 0 if age==1|age==2
label define ageblbl	1 "> 40 Yrs Age" 	0 "<= 40 Yrs Age"		
label values ageb ageblbl
tab ageb

label variable gend "Female"
label variable ageb "Age>=40"
label variable expb "Experience>=40"
label variable gg_above ">=GG Grade"
label variable ip "Helpful Internal Proc"
label variable motiv "Motivated"
label variable usk "Uses Core Skills"

*GENERATING REGIONAL LEVEL PERCENT ANCHOR QUESTIONS
foreach anchor in ip motiv usk {
bysort region: egen temp1 = count(`anchor')
bysort region: egen temp2 = count(`anchor') if `anchor'==1
gen `anchor'_r = (temp2/temp1)*100
format `anchor'_r %9.2f
drop temp*
tab `anchor'_r
}

*AGILITY SCORE
egen agilityscore = rowmean(peoplescore solutionsscore innovationscore growthscore)
format agilityscore %9.2f
*DIFFERENCE FROM MEAN VALUES FOR SCORES
local y 	peoplescore solutionsscore innovationscore growthscore	
foreach x of local y {
egen 	`x'_mean 			=	mean(`x')
gen 	`x'_diff			=	`x'-`x'`var'_mean
}

*GENERATING A SCORE FOR AGILE ENVIRONMENT
egen agilityscore_env = rowmean(score*_env)
replace agilityscore_env = (agilityscore_env/4)*100
tab agilityscore_env

*GENERATING A SCORE FOR DIMENSIONS ENVIRONMENT
/*PEOPLE: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 48, 49, 50, 51
*PEOPLE ENV: score3_env score5_env score7_env score50_env

*SOLUTIONS: 13, 14, 15, 16, 17, 18, 19, 20, 22, 23, 48, 50, 52, 53, 54
*SOLUTIONS ENV: score14_env score16_env score20_env score22_env score50_env

*INNOVATION: 24, 25, 26, 27, 28, 29, 30, 31, 32, 52, 53, 55, 56
*INNOVATION ENV: score25_env score28_env score30_env score32_env

*GROWTH: 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 49, 51, 54, 55, 56
*GROWTH ENV: score33_env score34_env score35_env
*/

*PEOPLE ENVIRONMENT
egen peoplescore_env = rowmean(score3_env score5_env score7_env score50_env)
replace peoplescore_env = (peoplescore_env/4)*100
tab peoplescore_env

*PEOPLE TRUNCATED
egen peoplescore_trunc = rowmean(score3 score5 score7 score50)
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
egen growthscore_env = rowmean(score33_env score34_env score35_env)
replace growthscore_env = (growthscore_env/4)*100
tab growthscore_env

*GROWTH TRUNCATED
egen growthscore_trunc = rowmean(score33 score34 score35)
replace growthscore_trunc = (growthscore_trunc/4)*100
tab growthscore_trunc

*AGILITY TRUNCATED
egen agilityscore_trunc = rowmean(peoplescore_trunc solutionsscore_trunc innovationscore_trunc growthscore_trunc)
tab agilityscore_trunc

*GENERATING FILTER VARIABLE FOR ROUND OF DATA COLLECTION
gen phase = 2
label define phaseslbl 	1 "Agile Champions Pilot" 2 "Phase 1" 
label values phase 		phaseslbl

*GENERATING PROPORTION VARIABLE FOR STRENGTH
local strength strengthpeople strengthsolutions strengthinnovation strengthgrowth
foreach var of local strength {
	egen `var'_p1 = count(`var') if `var'=="THIS IS YOUR STRENGTH!" & phase==1
	replace `var'_p1 = `var'_p1/51
	replace `var'_p1 = `var'_p1*100
	egen `var'_p2 = count(`var') if `var'=="THIS IS YOUR STRENGTH!" & phase==2	
	replace `var'_p2 = `var'_p2/total_resp
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

*GENERATING TRUNCATED VPU VARIABLE

bysort vpu: egen countvpu = count(vpu)
gen vpu_trunc = vpu if countvpu>=10
replace vpu_trunc = 0 if countvpu<10

tab vpu_trunc
label values vpu_trunc 			vpulbl 
decode vpu_trunc, gen(vpu_trunc_n)
encode vpu_trunc_n, gen(vpu_trunc_nn)
drop vpu_trunc_n vpu_trunc countvpu
ren vpu_trunc_nn vpu_trunc
tab vpu_trunc

*GENERATING TRUNCATED PRACTICE VARIABLE

bysort practice: egen countpractice = count(practice)
gen practice_trunc = practice if countpractice>=10
replace practice_trunc = 99 if countpractice<10

tab practice_trunc
label values practice_trunc 			practicelbl 
decode practice_trunc, gen(practice_trunc_n)
encode practice_trunc_n, gen(practice_trunc_nn)
drop practice_trunc_n practice_trunc countpractice
ren practice_trunc_nn practice_trunc
tab practice_trunc

*GENERATING TRUNCATED DEMOGRAPHIC VARIABLES
gen age_trunc = age
replace age_trunc = . if age == 5

gen exp_trunc = experience
replace exp_trunc = . if experience == 6

gen grade_trunc = grade
replace grade_trunc = . if grade == 5

label values age_trunc 			agelbl
label values exp_trunc 	explbl
label values grade_trunc 			gradelbl 

********************************************************************************
*						 ITEMS IN EACH DIMENSIONS								*
********************************************************************************

*GENERATING PERCENT SCORE FOR EACH KEY ITEM

forvalues x = 1/56 {
	cap noi gen score`x'_p = (score`x'/4)*100	
}

*GENERATING PERCENT SCORE FOR EACH ENV ITEM

forvalues x = 1/56 {
	cap noi gen score`x'_env_p = (score`x'_env/4)*100	
}

*GENERATING OBSERVATION ID
gen id = _n

*REMOVING NON-CONSENTING ENTRIES OR DUMMY ENTRIES FROM DATASET
drop if peoplescore<40|solutionsscore<40|innovationscore<40|growthscore<40


********************************************************************************
* 						EXTREME RESPONSES										*
********************************************************************************
*EXTREME RESPONSES
forvalues x = 1/56 {
cap noi gen 	temp`x' = 1 if score`x' == 4|score`x' == 1
}
egen 	extreme_responses = rowtotal(temp*)
replace extreme_responses = extreme_responses/53
replace extreme_responses = extreme_responses*100
drop temp*

gen 	extreme_responses_75 = 1 if extreme_responses>=75
replace extreme_responses_75 = 0 if extreme_responses_75==.
tab 	extreme_responses_75

*EXTREME ENVIRONMENT RESPONSES
forvalues x = 1/56 {
cap noi gen 	temp`x'_env = 1 if score`x'_env == 4|score`x'_env == 1
}
egen 	extreme_responses_env = rowtotal(temp*_env)
replace extreme_responses_env = extreme_responses_env/15
replace extreme_responses_env = extreme_responses_env*100
drop temp*_env
gen 	extreme_responses_env_75 = 1 if extreme_responses_env>=75
replace extreme_responses_env_75 = 0 if extreme_responses_env_75==.
tab 	extreme_responses_env_75

********************************************************************************
*					ADJUSTING FOR FOR SOCIAL DESIRABILITY
********************************************************************************
*GENERATING SOCIAL DESIRABILITY VARIABLE
egen social_desirability = rowmean(score44 score45 score45)
tab social_desirability

*ADJUSTING SCORES FOR SOCIAL DESIRABILITY FACTOR
*GENERAL RULE: 
*1. 	If social desirability between 2 to 3 then subtract all scores by 0.5
*2. 	If social desirability between 3 to 4 then subtract all scores by 1
*3. 	Since social desirability only looks at personal assessments we will only adjust personal scores

*GENERATING FILTERS FOR OPERATIONS
gen sd1 = 1 if social_desirability <=3.5 & social_desirability>3
gen sd2 = 1 if social_desirability >3.5 & social_desirability<=4
gen sd = 1 if sd2==1|sd1==1
replace sd = 0 if sd==.
*GENERATING ADJUSTED SOCIAL DESIRABILITY SCORES
forvalues x=1/56 {
	cap noi gen score`x'_sd = score`x'
	cap noi replace score`x'_sd = score`x'_sd-0.5 if sd1 == 1 
	cap noi replace score`x'_sd = 0 if score`x'==0 
	cap noi replace score`x'_sd =. if score`x'==.
}

forvalues x=1/56 {
	cap noi replace score`x'_sd = score`x'_sd-1 if sd2 == 1 
	cap noi replace score`x'_sd = 0 if score`x'==0 
	cap noi replace score`x'_sd =. if score`x'==.
}

foreach x in demo3_intproc demo_motiv demo2_skills {
	cap noi gen `x'_sd = `x'
	cap noi replace `x'_sd = `x'_sd-0.5 if sd1 == 1 
	cap noi replace `x'_sd = 0 if `x'==0 
	cap noi replace `x'_sd =. if `x'==.
}
foreach x in demo3_intproc demo_motiv demo2_skills {
	cap noi replace `x'_sd = `x'_sd-1 if sd2 == 1 
	cap noi replace `x'_sd = 0 if `x'==0 
	cap noi replace `x'_sd =. if `x'==.
}
*ADJUSTED ENVIRONMENT SCORES
forvalues x=1/56 {
	cap noi gen score`x'_env_sd = score`x'_env
	cap noi replace score`x'_env_sd = score`x'_env_sd-0.5 if sd1 == 1 
	cap noi replace score`x'_env_sd = 0 if score`x'_env==0 
	cap noi replace score`x'__env_sd =. if score`x'==.
}

forvalues x=1/56 {
	cap noi replace score`x'_env_sd = score`x'_env_sd-1 if sd2 == 1 
	cap noi replace score`x'_env_sd = 0 if score`x'_env==0 
	cap noi replace score`x'_env_sd =. if score`x'_env==.
}

*********************************************************************************
*				ADJUSTING ALL SCORES FOR SOCIAL DESIRABILITY 
*********************************************************************************

*PEOPLE
egen peoplescore_sd = rowtotal(	score1_sd score2_sd score3_sd score4_sd score5_sd ///
								score6_sd score7_sd score8_sd score9_sd score10_sd	///
								score11_sd score12_sd score48_sd score49_sd score50_sd ///
								score51_sd)
replace peoplescore_sd = peoplescore_sd/64
replace peoplescore_sd = peoplescore_sd*100	if peoplescore_sd!=0 |peoplescore_sd!=.	
egen 	maxpeoplescore = max(peoplescore_sd)
gen 	temp 		=	maxpeoplescore-100						
replace peoplescore_sd = peoplescore_sd-temp 
replace peoplescore_sd = 0 if peoplescore_sd<0
drop maxpeoplescore temp

*SOLUTIONS
egen solutionsscore_sd = rowtotal(score13_sd score14_sd score15_sd score16_sd score17_sd ///
								score18_sd score19_sd score20_sd score22_sd score23_sd ///
								score48_sd score50_sd score52_sd score53_sd score54_sd)
replace solutionsscore_sd = solutionsscore_sd/60
replace solutionsscore_sd = solutionsscore_sd*100 if solutionsscore_sd!=0 |solutionsscore_sd!=.									
egen 	maxsolutionsscore = max(solutionsscore_sd)
gen 	temp 		=	maxsolutionsscore-100						
replace solutionsscore_sd = solutionsscore_sd-temp 
replace solutionsscore_sd = 0 if solutionsscore_sd<0
drop maxsolutionsscore temp

*INNOVATION
egen innovationscore_sd = rowtotal(	score24 score25_sd score26_sd score27_sd 	///
									score28_sd score29_sd score30_sd score31_sd ///
									score32_sd score52_sd score53_sd score55_sd ///
									score56_sd)
replace innovationscore_sd = innovationscore_sd/52
replace innovationscore_sd = innovationscore_sd*100	if innovationscore_sd!=0 |innovationscore_sd!=.							
egen 	maxinnovationscore = max(innovationscore_sd)
gen 	temp 		=	maxinnovationscore-100						
replace innovationscore_sd = innovationscore_sd-temp 
replace innovationscore_sd = 0 if innovationscore_sd<0
drop maxinnovationscore temp

*GROWTH
egen growthscore_sd = rowtotal(	score33_sd score34_sd score35_sd score36_sd score37_sd ///
								score38_sd score39_sd score40_sd score41_sd score42_sd ///
								score49_sd score51_sd score54_sd score55_sd score56_sd)
replace growthscore_sd = growthscore_sd/60
replace growthscore_sd = growthscore_sd*100	if growthscore_sd!=0 |growthscore_sd!=.								
egen 	maxgrowthscore = max(growthscore_sd)
gen 	temp 		=	maxgrowthscore-100						
replace growthscore_sd = growthscore_sd-temp 
replace growthscore_sd = 0 if growthscore_sd<0
drop maxgrowthscore temp

*AGILITY 
egen agilityscore_sd = rowmean(peoplescore_sd solutionsscore_sd innovationscore_sd growthscore_sd)

*DEMEANED ENVIRONMENT DIMENSION SCORES
*PEOPLE ENVIRONMENT
egen peoplescore_env_sd = rowtotal(score3_env_sd score5_env_sd score7_env_sd score50_env_sd)
replace peoplescore_env_sd = peoplescore_env_sd/16
replace peoplescore_env_sd = peoplescore_env_sd*100	if peoplescore_env_sd!=0 |peoplescore_env_sd!=.								
egen 	maxpeoplescore = max(peoplescore_env_sd)
gen 	temp 		=	maxpeoplescore-100						
replace peoplescore_env_sd = peoplescore_env_sd-temp 
replace peoplescore_env_sd = 0 if peoplescore_env_sd<0
drop maxpeoplescore temp

*PEOPLE TRUNCATED
egen peoplescore_trunc_sd = rowmean(score3_sd score5_sd score7_sd score50_sd)
replace peoplescore_trunc_sd = (peoplescore_trunc_sd/4)*100
egen 	maxpeoplescore = max(peoplescore_trunc_sd)
gen 	temp 		=	maxpeoplescore-100						
replace peoplescore_trunc_sd = peoplescore_trunc_sd-temp 
replace peoplescore_trunc_sd = 0 if peoplescore_trunc_sd<0
drop maxpeoplescore temp

*SOLUTIONS
egen solutionsscore_env_sd = rowtotal(score14_env_sd score16_env_sd score20_env_sd ///
									score22_env_sd score50_env_sd)
replace solutionsscore_env_sd = solutionsscore_env_sd/20
replace solutionsscore_env_sd = solutionsscore_env_sd*100 if solutionsscore_env_sd!=0 |solutionsscore_env_sd!=.											
egen 	maxsolutionsscore = max(solutionsscore_env_sd)
gen 	temp 		=	maxsolutionsscore-100						
replace solutionsscore_env_sd = solutionsscore_env_sd-temp 
replace solutionsscore_env_sd = 0 if solutionsscore_env_sd<0
drop maxsolutionsscore temp


*SOLUTIONS TRUNCATED
egen solutionsscore_trunc_sd = rowmean(score14_sd score16_sd score20_sd score22_sd score50_sd)
replace solutionsscore_trunc_sd = (solutionsscore_trunc_sd/4)*100
egen 	maxsolutionsscore = max(solutionsscore_trunc_sd)
gen 	temp 		=	maxsolutionsscore-100						
replace solutionsscore_trunc_sd = solutionsscore_trunc_sd-temp 
replace solutionsscore_trunc_sd = 0 if solutionsscore_trunc_sd<0
drop maxsolutionsscore temp

*INNOVATION
egen innovationscore_env_sd = rowtotal(score25_env_sd score28_env_sd score30_env_sd ///
									score32_env_sd)
replace innovationscore_env_sd = innovationscore_env_sd/16
replace innovationscore_env_sd = innovationscore_env_sd*100 if innovationscore_env_sd!=0 |innovationscore_env_sd!=.									
egen 	maxinnovationscore = max(innovationscore_env_sd)
gen 	temp 		=	maxinnovationscore-100						
replace innovationscore_env_sd = innovationscore_env_sd-temp 
replace innovationscore_env_sd = 0 if innovationscore_env_sd<0
drop maxinnovationscore temp

*INNOVATIONS TRUNCATED
egen innovationscore_trunc_sd = rowmean(score25_sd score28_sd score30_sd score32_sd)
replace innovationscore_trunc_sd = (innovationscore_trunc_sd/4)*100
egen 	maxinnovationscore = max(innovationscore_trunc_sd)
gen 	temp 		=	maxinnovationscore-100						
replace innovationscore_trunc_sd = innovationscore_trunc_sd-temp 
replace innovationscore_trunc_sd = 0 if innovationscore_trunc_sd<0
drop maxinnovationscore temp

*GROWTH
egen growthscore_env_sd = rowtotal(score33_env_sd score34_env_sd score35_env_sd)
replace growthscore_env_sd = growthscore_env_sd/12
replace growthscore_env_sd = growthscore_env_sd*100	if growthscore_env_sd!=0 |growthscore_env_sd!=.									
egen 	maxgrowthscore = max(growthscore_env_sd)
gen 	temp 		=	maxgrowthscore-100						
replace growthscore_env_sd = growthscore_env_sd-temp 
replace growthscore_env_sd = 0 if growthscore_env_sd<0
drop maxgrowthscore temp

*GROWTH TRUNCATED
egen growthscore_trunc_sd = rowmean(score33_sd score34_sd score35_sd)
replace growthscore_trunc_sd = (growthscore_trunc_sd/4)*100
egen 	maxgrowthscore = max(growthscore_trunc_sd)
gen 	temp 		=	maxgrowthscore-100						
replace growthscore_trunc_sd = growthscore_trunc_sd-temp 
replace growthscore_trunc_sd = 0 if growthscore_trunc_sd<0
drop maxgrowthscore temp

*AGILITY 
egen agilityscore_env_sd = rowmean(peoplescore_env_sd solutionsscore_env_sd innovationscore_env_sd growthscore_env_sd)

*AGILITY TRUNCATED
egen agilityscore_trunc_sd = rowmean(peoplescore_trunc_sd solutionsscore_trunc_sd innovationscore_trunc_sd growthscore_trunc_sd)
tab agilityscore_trunc_sd

*GENERATING ADJUSTED BINARY VARIABLES FOR ANCHOR QUESTIONS
gen 		ip_sd = 1 if demo3_intproc_sd>2.5
replace 	ip_sd = 0 if demo3_intproc_sd<=2.5|demo3_intproc_sd==0
label values ip_sd iplbl
tab ip_sd 

gen 		motiv_sd = 1 if demo_motiv_sd>2.5
replace 	motiv_sd = 0 if demo_motiv_sd<=2.5|demo_motiv_sd==0
label values motiv_sd motivlbl
tab motiv_sd

gen 		usk_sd = 1 if demo2_skills_sd>2.5
replace 	usk_sd = 0 if demo2_skills_sd<=2.5
label values usk_sd usklbl
tab usk_sd

label variable ip_sd "Helpful Internal Proc"
label variable motiv_sd "Motivated"
label variable usk_sd "Uses Core Skills"

*GENERATING CATEGORICAL VARIABLES FOR ANCHOR QUESTIONS
gen 		internal_processes = 1 if demo3_intproc_sd <=1.5
replace 	internal_processes = 2 if demo3_intproc_sd >1.5 & demo3_intproc_sd <=2.5
replace		internal_processes = 3 if demo3_intproc_sd >2.5 & demo3_intproc_sd <=3.5
replace		internal_processes = 4 if demo3_intproc_sd >3.5 

gen 		motivation = 1 if demo_motiv_sd <=1.5
replace 	motivation = 2 if demo_motiv_sd >1.5 & demo_motiv_sd <=2.5
replace		motivation = 3 if demo_motiv_sd >2.5 & demo_motiv_sd <=3.5
replace		motivation = 4 if demo_motiv_sd >3.5 

gen 		use_core_skills = 1 if demo2_skills_sd <=1.5
replace 	use_core_skills = 2 if demo2_skills_sd >1.5 & demo2_skills_sd <=2.5
replace		use_core_skills = 3 if demo2_skills_sd >2.5 & demo2_skills_sd <=3.5
replace		use_core_skills = 4 if demo2_skills_sd >3.5 

label values internal_processes 	demo3_intproclbl
label values motivation 			demo_motivlbl
label values use_core_skills 		demo2_skillslbl

********************************************************************************
*							CORE	SKILLS 										
********************************************************************************
gen skills_first = .
gen skills_second = .
gen skills_third = .

forvalues x=1/20 {
	replace skills_first = `x' if skills_`x'!=0 & skills_first==.
}

forvalues x=1/20 {
	replace skills_second = `x' if skills_`x'!=0 & skills_first!=`x' & skills_second==.
}

forvalues x=1/20 {
	replace skills_third = `x' if skills_`x'!=0 & skills_first!=`x' & skills_second!=`x' & skills_third==.
}

*LABELLING SKILLS

label define skillslbl	1	"Project Design"	2 	"Project Management and Implementation" ///
						3	"Research and Analysis"		4	"Monitoring and Evaluation"		///
						5	"Resource Management and Budget"	6	"Writing and Editing" 	///
						7	"Capacity Building" 	8	"Legal Counsel and Analysis" 		///
						9	"Client Engagement" 	10	"Data Analysis and Statistical Programming"	///
						11	"Strategy and Policy Dialogue"	12	"Information Technology" 	///
						13	"Financial Analysis" 	14	"Administrative Assistance" 		///
						15	"Event Management"	16	"Media and Strategic Communications"	///
						17	"Team Management"	18	"Human Resources Management" 			///
						19	"Training"	20	"Team Player" 	
label values skills_first skillslbl
label values skills_second skillslbl
label values skills_third skillslbl

*GENERATING PERCENT OF TOTAL SKILLS VARIABLE
forvalues x =1/20 {
	egen skills_`x'p = count(skills_`x') if skills_`x'==1
	replace skills_`x'p = skills_`x'p/total_resp
	replace skills_`x'p = skills_`x'p*100
}

*********************************************************************************
*			PERCENTILE SCORES FOR ALL DIMENSIONS
*********************************************************************************
foreach dim in peoplescore_sd solutionsscore_sd innovationscore_sd growthscore_sd agilityscore_sd {
	sort `dim' 
	gen `dim'_p = int(100*(_n-1)/_N)+1
	tab `dim'_p
}

foreach dim in peoplescore_sd solutionsscore_sd innovationscore_sd growthscore_sd agilityscore_sd {
	gen `dim'40p = 1 if `dim'_p>=60
	replace `dim'40p = 0 if `dim'40p==.
}

foreach dim in peoplescore_sd solutionsscore_sd innovationscore_sd growthscore_sd agilityscore_sd {
sum `dim'40p if `dim'40p==1
}
gen agile_scorer = 1 if peoplescore_sd40p==1 & solutionsscore_sd40p==1 & innovationscore_sd40p==1 & growthscore_sd40p==1
replace agile_scorer = 0 if agile_scorer==.

*********************************************************************************
*					AGILE SCORERS
*********************************************************************************

foreach dim in peoplescore_sd solutionsscore_sd innovationscore_sd growthscore_sd {
	sort `dim' 
	gen `dim'_ag = int(100*(_n-1)/_N)+1
	tab `dim'_p
}

foreach dim in peoplescore_sd solutionsscore_sd innovationscore_sd growthscore_sd agilityscore_sd {
	gen `dim'30p = 1 if `dim'_p>=70
	replace `dim'30p = 0 if `dim'30p==.
}

save "$onedrive\Intermediate\wbt_v3.dta", replace

/********************************************************************************
*			DEMEANING AFTER FILTERING EXTREME RESPONSES							*
********************************************************************************

*GENERATING DEMEAN SCORES VARIABLE
	egen rowmeanscore = rowmean(score48_sd score17_sd score35_sd score8_sd score20_sd score10_sd 	///
								score9_sd score3_sd score16_sd score14_sd score36_sd 	///
								score7_sd score5_sd score2_sd score37_sd score27_sd score18_sd 	///
								score39_sd score22_sd score51_sd score40_sd score11_sd ///
								score4_sd score34_sd score25_sd score38_sd score33_sd 	///
								score56_sd score15_sd score55_sd score19_sd score41_sd score6_sd 	///
								score42_sd score54_sd score50_sd score13_sd score23_sd score28_sd ///
								score30_sd score52_sd score32_sd score26_sd score1_sd score29_sd 	///
								score24_sd score53_sd score31_sd score49_sd score12_sd 		///
								demo3_intproc_sd demo_motiv_sd demo2_skills_sd)			///
								if extreme_responses_75 != 1
	egen meanscore = mean(rowmeanscore)  if rowmeanscore!=.
	gen demeanscore = rowmeanscore-meanscore

	tab meanscore

	*DEMEANING SCORES
	
	forvalues x = 1/56 {
		cap noi gen score`x'_dm = score`x'_sd-demeanscore if score`x'_sd!=0|score`x'_sd!=.
		cap noi replace score`x'_dm = 0 if score`x'_sd==0
		cap noi replace score`x'_dm = . if score`x'_sd==.
		cap noi format score`x'_dm %9.2f
}
	*ANCHORS
	foreach x in demo3_intproc demo_motiv demo2_skills {
		cap noi gen `x'_dm = `x'-demeanscore if `x'!=0|`x'!=.
		cap noi replace `x'_dm = 0 if `x'==0
		cap noi replace `x'_dm = . if `x'==.
		cap noi format `x'_dm %9.2f
}

drop meanscore

	egen rowmeanscore_env = rowmean(score5_env score7_env score34_env score3_env 	///
								score30_env score32_env score50_env score20_env ///
								score33_env score28_env score14_env score35_env ///
								score22_env score16_env score25_env)
	egen meanscore = mean(rowmeanscore_env) if rowmeanscore!=.
	gen demeanscore_env = rowmeanscore_env-meanscore

	tab meanscore

	*ENVIRONMENT SCORES
	forvalues x = 1/56 {
		cap noi gen score`x'_env_dm = score`x'_env-demeanscore if score`x'_env!=0|score`x'_env!=.
		cap noi replace score`x'_env_dm = 0 if score`x'_env==0
		cap noi replace score`x'_env_dm = . if score`x'_env==.
		cap noi format score`x'_env_dm %9.2f
}

drop meanscore

*DEMEANED DIMENSION SCORES
*PEOPLE
egen peoplescore_dm = rowtotal(	score1_dm score2_dm score3_dm score4_dm score5_dm ///
								score6_dm score7_dm score8_dm score9_dm score10_dm	///
								score11_dm score12_dm score48_dm score49_dm score50_dm ///
								score51_dm)
replace peoplescore_dm = peoplescore_dm/64
replace peoplescore_dm = peoplescore_dm*100	if peoplescore_dm!=0 |peoplescore_dm!=.	
egen 	maxpeoplescore = max(peoplescore_dm)
gen 	temp 		=	maxpeoplescore-100						
replace peoplescore_dm = peoplescore_dm-temp 
replace peoplescore_dm = 0 if peoplescore_dm<0
drop maxpeoplescore temp

*SOLUTIONS
egen solutionsscore_dm = rowtotal(score13_dm score14_dm score15_dm score16_dm score17_dm ///
								score18_dm score19_dm score20_dm score22_dm score23_dm ///
								score48_dm score50_dm score52_dm score53_dm score54_dm)
replace solutionsscore_dm = solutionsscore_dm/60
replace solutionsscore_dm = solutionsscore_dm*100 if solutionsscore_dm!=0 |solutionsscore_dm!=.									
egen 	maxsolutionsscore = max(solutionsscore_dm)
gen 	temp 		=	maxsolutionsscore-100						
replace solutionsscore_dm = solutionsscore_dm-temp 
replace solutionsscore_dm = 0 if solutionsscore_dm<0
drop maxsolutionsscore temp

*INNOVATION
egen innovationscore_dm = rowtotal(	score24 score25_dm score26_dm score27_dm 	///
									score28_dm score29_dm score30_dm score31_dm ///
									score32_dm score52_dm score53_dm score55_dm ///
									score56_dm)
replace innovationscore_dm = innovationscore_dm/52
replace innovationscore_dm = innovationscore_dm*100	if innovationscore_dm!=0 |innovationscore_dm!=.							
egen 	maxinnovationscore = max(innovationscore_dm)
gen 	temp 		=	maxinnovationscore-100						
replace innovationscore_dm = innovationscore_dm-temp 
replace innovationscore_dm = 0 if innovationscore_dm<0
drop maxinnovationscore temp

*GROWTH
egen growthscore_dm = rowtotal(	score33_dm score34_dm score35_dm score36_dm score37_dm ///
								score38_dm score39_dm score40_dm score41_dm score42_dm ///
								score49_dm score51_dm score54_dm score55_dm score56_dm)
replace growthscore_dm = growthscore_dm/60
replace growthscore_dm = growthscore_dm*100	if growthscore_dm!=0 |growthscore_dm!=.								
egen 	maxgrowthscore = max(growthscore_dm)
gen 	temp 		=	maxgrowthscore-100						
replace growthscore_dm = growthscore_dm-temp 
replace growthscore_dm = 0 if growthscore_dm<0
drop maxgrowthscore temp

*AGILITY 
egen agilityscore_dm = rowmean(peoplescore_dm solutionsscore_dm innovationscore_dm growthscore_dm)

*DEMEANED ENVIRONMENT DIMENSION SCORES
*PEOPLE ENVIRONMENT
egen peoplescore_env_dm = rowtotal(score3_env_dm score5_env_dm score7_env_dm score50_env_dm)
replace peoplescore_env_dm = peoplescore_env_dm/16
replace peoplescore_env_dm = peoplescore_env_dm*100	if peoplescore_env_dm!=0 |peoplescore_env_dm!=.								
egen 	maxpeoplescore = max(peoplescore_env_dm)
gen 	temp 		=	maxpeoplescore-100						
replace peoplescore_env_dm = peoplescore_env_dm-temp 
replace peoplescore_env_dm = 0 if peoplescore_env_dm<0
drop maxpeoplescore temp

*PEOPLE TRUNCATED
egen peoplescore_trunc_dm = rowmean(score3_dm score5_dm score7_dm score50_dm)
replace peoplescore_trunc_dm = (peoplescore_trunc_dm/4)*100
egen 	maxpeoplescore = max(peoplescore_trunc_dm)
gen 	temp 		=	maxpeoplescore-100						
replace peoplescore_trunc_dm = peoplescore_trunc_dm-temp 
replace peoplescore_trunc_dm = 0 if peoplescore_trunc_dm<0
drop maxpeoplescore temp

*SOLUTIONS
egen solutionsscore_env_dm = rowtotal(score14_env_dm score16_env_dm score20_env_dm ///
									score22_env_dm score50_env_dm)
replace solutionsscore_env_dm = solutionsscore_env_dm/20
replace solutionsscore_env_dm = solutionsscore_env_dm*100 if solutionsscore_env_dm!=0 |solutionsscore_env_dm!=.											
egen 	maxsolutionsscore = max(solutionsscore_env_dm)
gen 	temp 		=	maxsolutionsscore-100						
replace solutionsscore_env_dm = solutionsscore_env_dm-temp 
replace solutionsscore_env_dm = 0 if solutionsscore_env_dm<0
drop maxsolutionsscore temp


*SOLUTIONS TRUNCATED
egen solutionsscore_trunc_dm = rowmean(score14_dm score16_dm score20_dm score22_dm score50_dm)
replace solutionsscore_trunc_dm = (solutionsscore_trunc_dm/4)*100
egen 	maxsolutionsscore = max(solutionsscore_trunc_dm)
gen 	temp 		=	maxsolutionsscore-100						
replace solutionsscore_trunc_dm = solutionsscore_trunc_dm-temp 
replace solutionsscore_trunc_dm = 0 if solutionsscore_trunc_dm<0
drop maxsolutionsscore temp

*INNOVATION
egen innovationscore_env_dm = rowtotal(score25_env_dm score28_env_dm score30_env_dm ///
									score32_env_dm)
replace innovationscore_env_dm = innovationscore_env_dm/16
replace innovationscore_env_dm = innovationscore_env_dm*100 if innovationscore_env_dm!=0 |innovationscore_env_dm!=.									
egen 	maxinnovationscore = max(innovationscore_env_dm)
gen 	temp 		=	maxinnovationscore-100						
replace innovationscore_env_dm = innovationscore_env_dm-temp 
replace innovationscore_env_dm = 0 if innovationscore_env_dm<0
drop maxinnovationscore temp

*INNOVATIONS TRUNCATED
egen innovationscore_trunc_dm = rowmean(score25_dm score28_dm score30_dm score32_dm)
replace innovationscore_trunc_dm = (innovationscore_trunc_dm/4)*100
egen 	maxinnovationscore = max(innovationscore_trunc_dm)
gen 	temp 		=	maxinnovationscore-100						
replace innovationscore_trunc_dm = innovationscore_trunc_dm-temp 
replace innovationscore_trunc_dm = 0 if innovationscore_trunc_dm<0
drop maxinnovationscore temp

*GROWTH
egen growthscore_env_dm = rowtotal(score33_env_dm score34_env_dm score35_env_dm)
replace growthscore_env_dm = growthscore_env_dm/12
replace growthscore_env_dm = growthscore_env_dm*100	if growthscore_env_dm!=0 |growthscore_env_dm!=.									
egen 	maxgrowthscore = max(growthscore_env_dm)
gen 	temp 		=	maxgrowthscore-100						
replace growthscore_env_dm = growthscore_env_dm-temp 
replace growthscore_env_dm = 0 if growthscore_env_dm<0
drop maxgrowthscore temp

*GROWTH TRUNCATED
egen growthscore_trunc_dm = rowmean(score33_dm score34_dm score35_dm)
replace growthscore_trunc_dm = (growthscore_trunc_dm/4)*100
egen 	maxgrowthscore = max(growthscore_trunc_dm)
gen 	temp 		=	maxgrowthscore-100						
replace growthscore_trunc_dm = growthscore_trunc_dm-temp 
replace growthscore_trunc_dm = 0 if growthscore_trunc_dm<0
drop maxgrowthscore temp

*AGILITY 
egen agilityscore_env_dm = rowmean(peoplescore_env_dm solutionsscore_env_dm innovationscore_env_dm growthscore_env_dm)

*AGILITY TRUNCATED
egen agilityscore_trunc_dm = rowmean(peoplescore_trunc_dm solutionsscore_trunc_dm innovationscore_trunc_dm growthscore_trunc_dm)
tab agilityscore_trunc_dm

*GENERATING CATEGORICAL VARIABLE FOR OPERATOR
gen operator = 1 if demeanscore>=0
replace operator = 0 if demeanscore<0

*GENERATING ADJUSTED BINARY VARIABLES FOR ANCHOR QUESTIONS
gen 		ip_dm = 1 if demo3_intproc_dm>2.5
replace 	ip_dm = 0 if demo3_intproc_dm<=2.5|demo3_intproc_dm==0
label values ip_dm iplbl
tab ip_dm 

gen 		motiv_dm = 1 if demo_motiv_dm>2.5
replace 	motiv_dm = 0 if demo_motiv_dm<=2.5|demo_motiv_dm==0
label values motiv_dm motivlbl
tab motiv_dm

gen 		usk_dm = 1 if demo2_skills_dm>2.5
replace 	usk_dm = 0 if demo2_skills_dm<=2.5
label values usk_dm usklbl
tab usk_dm

label variable ip_dm "Helpful Internal Proc"
label variable motiv_dm "Motivated"
label variable usk_dm "Uses Core Skills"

*GENERATING CATEGORICAL VARIABLES FOR ANCHOR QUESTIONS
gen 		internal_processes = 1 if demo3_intproc_dm <=1.5
replace 	internal_processes = 2 if demo3_intproc_dm >1.5 & demo3_intproc_dm <=2.5
replace		internal_processes = 3 if demo3_intproc_dm >2.5 & demo3_intproc_dm <=3.5
replace		internal_processes = 4 if demo3_intproc_dm >3.5 

gen 		motivation = 1 if demo_motiv_dm <=1.5
replace 	motivation = 2 if demo_motiv_dm >1.5 & demo_motiv_dm <=2.5
replace		motivation = 3 if demo_motiv_dm >2.5 & demo_motiv_dm <=3.5
replace		motivation = 4 if demo_motiv_dm >3.5 

gen 		use_core_skills = 1 if demo2_skills_dm <=1.5
replace 	use_core_skills = 2 if demo2_skills_dm >1.5 & demo2_skills_dm <=2.5
replace		use_core_skills = 3 if demo2_skills_dm >2.5 & demo2_skills_dm <=3.5
replace		use_core_skills = 4 if demo2_skills_dm >3.5 

label values internal_processes 	demo3_intproclbl
label values motivation 			demo_motivlbl
label values use_core_skills 		demo2_skillslbl
*/

