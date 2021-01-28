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

global dimension peoplescore solutionsscore innovationscore growthscore agilityscore

set graphics off

*SUBMISSIONS OVER TIME
sort submissiondate

cap noi twoway line nr_subm submissiondate,										///
					ytitle("Number of Submissions")								///
					xtitle("Submission Date")									///
					title("Submissions over Days")								///
					subtitle(" ")												///
					graphregion(color(white)) bgcolor(white)					///
					lwidth(medthick)	lcolor(green)							///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export subm_day.png, as(png) name("Graph") replace			

*AVERAGE DIMENSION SCORES 
grstyle init
grstyle set plain, horizontal
grstyle set color Accent: p#bar p#barline
grstyle set intensity 40: bar

foreach var of global dimension {
egen med_`var' = median(`var')
tab med_`var'
*people 71.88 , solutions 68.33, innovation 65.38, growth 68.33, agility 67.54
}

graph box $dimension,															///
	yvaroptions(relabel(1 "People" 		2 "Solutions"							///
						3 "Innovation"	4 "Growth"	5 "Overall Agility"))		///						
	ylabel(40(10)100)outergap(20) bargap(30) showyvars legend(off) 				///	
	box(1, fcolor(green) lcolor(green)) 										///
	box(2, fcolor(edkblue) lcolor(edkblue))										///
	box(3, fcolor(purple) lcolor(purple))										///
	box(4, fcolor(dkorange) lcolor(dkorange))									///
	box(5, fcolor(black) lcolor(black)) 										///
	ytitle("Dimension Scores", size(small))										///
	graphregion(color(white)) bgcolor(white)									///
	title( "Average Scores on each Dimension", size(medium))					///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_scores.png, as(png) name("Graph") replace

*DISTRIBUTION OF DEMOGRAPHIC CATEGORIES

graph bar (percent) id, 	over(gender_trunc, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,  pos(inside) format(%9.2f))	///
	bar(1, fcolor(green) lcolor(green)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "Gender", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_gender.png, as(png) name("Graph") replace

graph bar (percent) id if age!=5, 	over(age, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,  pos(inside) format(%9.2f))	///
	bar(1, fcolor(edkblue) lcolor(edkblue)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "Age", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_age.png, as(png) name("Graph") replace

graph bar (percent) id if experience!=6, 	over(experience, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,  pos(inside) format(%9.2f))	///
	bar(1, fcolor(purple) lcolor(purple)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "Experience", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_exp.png, as(png) name("Graph") replace

graph bar (percent) id if grade!=5, 	over(grade, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,  pos(inside) format(%9.2f))	///
	bar(1, fcolor(dkorange) lcolor(dkorange)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "Grade", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_grade.png, as(png) name("Graph") replace

graph bar (percent) id if demo3_intproc!=0, 									///
			over(demo3_intproc, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,  pos(inside) format(%9.2f))	///
	bar(1, fcolor(dkorange) lcolor(dkorange)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "Internal Processes", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_int_proc.png, as(png) name("Graph") replace

graph bar (percent) id if demo_motiv!=0, 									///
			over(demo_motiv, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,  pos(inside) format(%9.2f))	///
	bar(1, fcolor(edkblue) lcolor(edkblue)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "Motivation", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_motiv.png, as(png) name("Graph") replace

graph bar (percent) id if demo2_skills!=0, 									///
			over(demo2_skills, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,  pos(inside) format(%9.2f))	///
	bar(1, fcolor(green) lcolor(green)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "Use of Skills", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_skills.png, as(png) name("Graph") replace

graph hbar (percent) id , 									///
			over(region, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,   format(%9.2f))	///
	bar(1, fcolor(green) lcolor(green)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "Region Mapping", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_region.png, as(png) name("Graph") replace

graph hbar (percent) id , 									///
			over(practice, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,  format(%9.2f))	///
	bar(1, fcolor(edkblue) lcolor(edkblue)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "Practice Mapping", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_practice.png, as(png) name("Graph") replace

graph hbar (percent) id , 									///
			over(vpu_trunc, label(labsize(small))) 									///
	outergap(20) bargap(30) blabel(bar,  format(%9.2f))	///
	bar(1, fcolor(purple) lcolor(purple)) 										///
	ytitle("Proportion of Respondents", size(small))											///
	graphregion(color(white)) bgcolor(white)									///
	title( "VPU Mapping", size(medium))	///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_vpu.png, as(png) name("Graph") replace

*ANCHOR QUESTIONS BY DEMOGRAPHIC CATEGORIES
*INTERNAL PROCESSES - COEF PLOT
preserve
replace int_proc = 100 if int_proc == 1
local dem gender_trunc above40age above10exp gg_above
foreach var of local dem {
reg  int_proc `var', robust
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
graph export coef_intproc_dem.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}
restore

*MOTIVATION - COEF PLOT
preserve
replace motiv = 100 if motiv == 1
local dem gender_trunc above40age above10exp gg_above
foreach var of local dem {
reg  motiv `var', robust
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
graph export coef_motiv_dem.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}
restore

*USE SKILLS - COEF PLOT
preserve
replace use_skills = 100 if use_skills == 1
local dem gender_trunc above40age above10exp gg_above
foreach var of local dem {
reg  use_skills `var', robust
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
graph export coef_use_skills_dem.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}
restore

*DIMENSION SCORES BY DEMOGRAPHIC CATEGORIES

*GENDER
preserve
collapse (mean) $dimension, by(gender_trunc)
rename (peoplescore solutionsscore innovationscore growthscore agilityscore)	///
		(score1 score2 score3 score4 score5)
reshape long score, i(gender_trunc) j(score_name)
drop if gender_trunc==.
label define score_namelbl	1 "People" 		2 "Solutions"						///
							3 "Innovation" 	4 "Growth"
label values score_name score_namelbl
format score %9.1f
sort score_name
twoway (scatter score_name score if gender_trunc==1, mlabel(score)) 			///
		(scatter score_name score  if gender_trunc==0, mlabel(score)), 			///
	legend(	label(1 "Female")		label(2 "Male")) 		///
	ylabel(1 "People" 2 "Solutions" 3 "Innovation" 4 "Growth" 5 "Overall Agility", angle(90))		///
	xlabel(63(2)72) legend() xtitle("Difference from Average")		 	///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")				///
	title( "Scores by Gender", size(medium))									///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export scatter_gender.png, as(png) name("Graph") replace
restore

*GRADE
tab grade
/*

               grade |      Freq.     Percent        Cum.
---------------------+-----------------------------------
               GA-GD |         51       15.32       15.32
               GE-GF |        120       36.04       51.35
                  GG |        105       31.53       82.88
        GH and Above |         48       14.41       97.30
Prefer Not to Answer |          9        2.70      100.00
---------------------+-----------------------------------
               Total |        333      100.00
*/
preserve
collapse (mean) 	$dimension  (count) id, by(grade)
drop if grade==5
twoway 	(line  		$dimension grade, 											///
						lwidth(medthick medthick medthick medthick thick) 		///
						lcolor(green edkblue purple dkorange black)) 			///
		(scatter 	peoplescore grade [fweight=id], sort						///
						msymbol(Oh) mcolor(green)), 							///
					legend(	label(1 "People")		label(2 "Solutions") 		///
							label(3 "Innovation") 	label(4 "Growth")			///
							label(5 "Agility")	label(6 "Number of Observations"))	///			
					xlabel(1 "GA-GD (51)" 2 "GE-GF (120)" 3 "GG (105)" 			///
							4 ">=GH (48)", angle(30) labsize(small))			///	
					ytitle("Dimension Score") xtitle("Grade")					///
					title("Dimension Score by Grade") subtitle(" ")				///
					graphregion(color(white)) bgcolor(white)					///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export line_grade.png, as(png) name("Graph") replace
restore

*AGE
tab age
/*
                 age |      Freq.     Percent        Cum.
---------------------+-----------------------------------
  Less than 30 years |         27        8.11        8.11
      31 to 40 years |         99       29.73       37.84
      41 to 50 years |        105       31.53       69.37
      Above 50 years |        101       30.33       99.70
Prefer Not to Answer |          1        0.30      100.00
---------------------+-----------------------------------
               Total |        333      100.00
*/

preserve
collapse (mean) 	$dimension  (count) id, by(age)
drop if age==5
twoway 	(line  		$dimension age, 											///
						lwidth(medthick medthick medthick medthick thick) 		///
						lcolor(green edkblue purple dkorange black)) 			///
		(scatter 	peoplescore age [fweight=id], sort						///
						msymbol(Oh) mcolor(green)), 							///
					legend(	label(1 "People")		label(2 "Solutions") 		///
							label(3 "Innovation") 	label(4 "Growth")			///
							label(5 "Agility")	label(6 "Number of Observations"))	///			
					xlabel(1 "<30 (27)" 2 "31-40 (99)" 3 "41-50 (105)" 			///
							4 ">=50 (101)", angle(30) labsize(small))			///
					ytitle("Dimension Score")									///
					xtitle("Age in Years")										///
					title("Dimension Score by Age")								///
					subtitle(" ")												///
					graphregion(color(white)) bgcolor(white)					///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export line_age.png, as(png) name("Graph") replace
restore

*EXPERIENCE
tab experience

/*
          experience |      Freq.     Percent        Cum.
---------------------+-----------------------------------
   Less than 5 years |         76       22.82       22.82
        5 to 9 years |         85       25.53       48.35
      10 to 19 years |        101       30.33       78.68
      20 to 29 years |         59       17.72       96.40
  More than 30 years |          7        2.10       98.50
Prefer Not to Answer |          5        1.50      100.00
---------------------+-----------------------------------
               Total |        333      100.00
*/

preserve
collapse (mean) 	$dimension  (count) id, by(experience)
drop if experience==6
twoway 	(line  		$dimension experience, 											///
						lwidth(medthick medthick medthick medthick thick) 		///
						lcolor(green edkblue purple dkorange black)) 			///
		(scatter 	peoplescore experience [fweight=id], sort						///
						msymbol(Oh) mcolor(green)), 							///
					legend(	label(1 "People")		label(2 "Solutions") 		///
							label(3 "Innovation") 	label(4 "Growth")			///
							label(5 "Agility")	label(6 "Number of Observations"))	///			
					xlabel(1 "<5 (76)" 2 "5-9 (85)" 3 "10-19 (101)" 			///
						4 "20-29 (59)" 5 ">30 (7)", angle(30) labsize(small))	///
					ytitle("Dimension Score") xtitle("Experience in Years")								///
					title("Dimension Score by Experience")						///
					subtitle(" ") graphregion(color(white)) bgcolor(white)					///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export line_experience.png, as(png) name("Graph") replace
restore

*DIMENSION SCORES BY ANCHOR QUESTIONS

*INTERNAL PROCESSES
tab demo3_intproc
/*

demo3_intpr |
         oc |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |          9        2.70        2.70
          1 |         38       11.41       14.11
          2 |        117       35.14       49.25
          3 |        141       42.34       91.59
          4 |         28        8.41      100.00
------------+-----------------------------------
      Total |        333      100.00
*/
preserve
collapse (mean) 	$dimension  (count) id, by(demo3_intproc)
drop if demo3_intproc==0
twoway 	(line  		$dimension demo3_intproc, 											///
						lwidth(medthick medthick medthick medthick thick) 		///
						lcolor(green edkblue purple dkorange black)) 			///
		(scatter 	peoplescore demo3_intproc [fweight=id], sort						///
						msymbol(Oh) mcolor(green)), 							///
					legend(	label(1 "People")		label(2 "Solutions") 		///
							label(3 "Innovation") 	label(4 "Growth")			///
							label(5 "Agility")	label(6 "Number of Observations"))	///			
					xlabel(1 `" "Unhelpful" "(38)" "' 2 `" "Somewhat" "Unhelpful (117)" "' ///
					3 `" "Somewhat" "Helpful (141)" "' 4 `" "Helpful" "(28)" "', labsize(small))	///
					ytitle("Dimension Score") xtitle("Score on Internal Processes")								///
					title("Dimension Score by Score on Internal Processes")						///
					subtitle(" ")	graphregion(color(white)) bgcolor(white)					///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export line_intproc.png, as(png) name("Graph") replace
restore

*MOTIVATION
tab demo_motiv
/*


 demo_motiv |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         11        3.30        3.30
          1 |         10        3.00        6.31
          2 |         64       19.22       25.53
          3 |        119       35.74       61.26
          4 |        129       38.74      100.00
------------+-----------------------------------
      Total |        333      100.00

*/
preserve
collapse (mean) 	$dimension  (count) id, by(demo_motiv)
drop if demo_motiv==0
twoway 	(line  		$dimension demo_motiv, 											///
						lwidth(medthick medthick medthick medthick thick) 		///
						lcolor(green edkblue purple dkorange black)) 			///
		(scatter 	peoplescore demo_motiv [fweight=id], sort						///
						msymbol(Oh) mcolor(green)), 							///
					legend(	label(1 "People")		label(2 "Solutions") 		///
							label(3 "Innovation") 	label(4 "Growth")			///
							label(5 "Agility")	label(6 "Number of Observations"))	///			
					xlabel(1 `" "Unmotivated" "(10)" "' 2 `" "Somewhat" "Unmotivated (64)" "' ///
					3 `" "Somewhat" "Motivated (119)" "' 4 `" "Motivated" "(129)" "', labsize(small))	///
					ytitle("Dimension Score") xtitle("Score on Motivation")								///
					title("Dimension Score by Motivation Score") subtitle(" ")												///
					graphregion(color(white)) bgcolor(white)					///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export line_motiv.png, as(png) name("Graph") replace
restore

*SKILLS
tab demo2_skills
/*

demo2_skill |
          s |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |          1        0.30        0.30
          1 |         18        5.41        5.71
          2 |         63       18.92       24.62
          3 |        109       32.73       57.36
          4 |        142       42.64      100.00
------------+-----------------------------------
      Total |        333      100.00


*/
preserve
collapse (mean) 	$dimension  (count) id, by(demo2_skills)
drop if demo2_skills==0
twoway 	(line  		$dimension demo2_skills, 											///
						lwidth(medthick medthick medthick medthick thick) 		///
						lcolor(green edkblue purple dkorange black)) 			///
		(scatter 	peoplescore demo2_skills [fweight=id], sort						///
						msymbol(Oh) mcolor(green)), 							///
					legend(	label(1 "People")		label(2 "Solutions") 		///
							label(3 "Innovation") 	label(4 "Growth")			///
							label(5 "Agility")	label(6 "Number of Observations"))	///			
					xlabel(1 `" "Unused" "(18)" "' 2 `" "Somewhat" "Unused (63)" "' ///
					3 `" "Somewhat" "Used (109)" "' 4 `" "Used" "(142)" "', labsize(small))	///
					ytitle("Dimension Score") xtitle("Score on Using Core Skills")								///
					title("Dimension Score by Score on Using Core Skills")						///
					subtitle(" ") graphregion(color(white)) bgcolor(white)					///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export line_skills.png, as(png) name("Graph") replace
restore


*GENDER
*COEF PLOT
local score peoplescore solutionsscore innovationscore growthscore agilityscore
foreach var of local score {
reg  `var' gender_trunc, robust
estimates store `var'
}

coefplot 	(peoplescore, 		label(People Score) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(solutionsscore, 	label(Solutions Score) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(innovationscore, 	label(Innovation Score) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(growthscore, 		label(Growth Score) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange)))						///
			(agilityscore, 		label(Agility Score) 							///
								mcolor(black) 									///
								ciopts(lcolor(black))), 						///
			drop(_cons) xline(0)  format(%9.2f) 	ylabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) xlabel(-10(5)10)			///
			graphregion(color(white)) bgcolor(white)							///
	title( "Scores by Gender (1=Female)", size(medium))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_gender.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*INTERNAL PROCESSES

*COEF PLOT
local score peoplescore solutionsscore innovationscore growthscore agilityscore
foreach var of local score {
reg  `var' int_proc, robust
estimates store `var'
}

coefplot 	(peoplescore, 		label(People Score) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(solutionsscore, 	label(Solutions Score) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(innovationscore, 	label(Innovation Score) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(growthscore, 		label(Growth Score) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange)))						///
			(agilityscore, 		label(Agility Score) 							///
								mcolor(black) 									///
								ciopts(lcolor(black))), 						///
			drop(_cons) xline(0)  format(%9.2f) 	ylabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) xlabel(-10(5)10)								///
			graphregion(color(white)) bgcolor(white)							///
	title( "Scores by Internal Processes Response (1=Useful)", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_intproc.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*USING SKILLS

*COEF PLOT
local score peoplescore solutionsscore innovationscore growthscore agilityscore
foreach var of local score {
reg  `var' use_skills, robust
estimates store `var'
}

coefplot 	(peoplescore, 		label(People Score) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(solutionsscore, 	label(Solutions Score) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(innovationscore, 	label(Innovation Score) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(growthscore, 		label(Growth Score) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange)))						///
			(agilityscore, 		label(Agility Score) 							///
								mcolor(black) 									///
								ciopts(lcolor(black))), 						///
			drop(_cons) xline(0)  format(%9.2f) 	ylabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) xlabel(-10(5)10)								///
			graphregion(color(white)) bgcolor(white)							///
	title( "Scores by Skills Matching (1=Used Skills)", size(medium))			///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_skills.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*MOTIVATION
*   gg_above above10exp above40age
*COEF PLOT
local score peoplescore solutionsscore innovationscore growthscore agilityscore
foreach var of local score {
reg  `var' motiv, robust
estimates store `var'
}

coefplot 	(peoplescore, 		label(People Score) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(solutionsscore, 	label(Solutions Score) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(innovationscore, 	label(Innovation Score) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(growthscore, 		label(Growth Score) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange)))						///
			(agilityscore, 		label(Agility Score) 							///
								mcolor(black) 									///
								ciopts(lcolor(black))), 						///
			drop(_cons) xline(0)  format(%9.2f) 	ylabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) xlabel(-10(5)10)								///
			graphregion(color(white)) bgcolor(white)							///
	title( "Scores by Motivation (1=Motivated)", size(medium))			///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_motiv.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*GRADE
*COEF PLOT
local score peoplescore solutionsscore innovationscore growthscore agilityscore
foreach var of local score {
reg  `var' gg_above, robust
estimates store `var'
}

coefplot 	(peoplescore, 		label(People Score) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(solutionsscore, 	label(Solutions Score) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(innovationscore, 	label(Innovation Score) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(growthscore, 		label(Growth Score) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange)))						///
			(agilityscore, 		label(Agility Score) 							///
								mcolor(black) 									///
								ciopts(lcolor(black))), 						///
			drop(_cons) xline(0)  format(%9.2f) 	ylabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) xlabel(-10(5)10)							///
			graphregion(color(white)) bgcolor(white)							///
	title( "Scores by Grade (1=GG and Above)", size(medium))			///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_gg_above.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*AGE - COEF PLOT
local score peoplescore solutionsscore innovationscore growthscore agilityscore
foreach var of local score {
reg  `var' above40age, robust
estimates store `var'
}

coefplot 	(peoplescore, 		label(People Score) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(solutionsscore, 	label(Solutions Score) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(innovationscore, 	label(Innovation Score) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(growthscore, 		label(Growth Score) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange)))						///
			(agilityscore, 		label(Agility Score) 							///
								mcolor(black) 									///
								ciopts(lcolor(black))), 						///
			drop(_cons) xline(0)  format(%9.2f) 	ylabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) xlabel(-10(5)10)								///
			graphregion(color(white)) bgcolor(white)							///
	title( "Scores by Age (1=40 Yrs and Above)", size(medium))			///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_above40age.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*EXPERIENCE - COEF PLOT
local score peoplescore solutionsscore innovationscore growthscore agilityscore
foreach var of local score {
reg  `var' above10exp, robust
estimates store `var'
}

coefplot 	(peoplescore, 		label(People Score) 							///
								mcolor(green) 									///
								ciopts(lcolor(green)))							///
			(solutionsscore, 	label(Solutions Score) 							///
								mcolor(edkblue) 								///
								ciopts(lcolor(edkblue)))						///
			(innovationscore, 	label(Innovation Score) 						///
								mcolor(purple) 									///
								ciopts(lcolor(purple)))							///
			(growthscore, 		label(Growth Score) 							///
								mcolor(dkorange) 								///
								ciopts(lcolor(dkorange)))						///
			(agilityscore, 		label(Agility Score) 							///
								mcolor(black) 									///
								ciopts(lcolor(black))), 						///
			drop(_cons) xline(0)  format(%9.2f) 	ylabel("")					///
			mlabposition(12) mlabel	mlabcolor(black) xlabel(-10(5)10)								///
			graphregion(color(white)) bgcolor(white)							///
	title( "Scores by Experience (1=10 Yrs and Above)", size(medium))			///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_above10exp.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*WHAT ARE THE DETERMINANTS OF HIGH SCORES
*AGILITY SCORES

local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  agilityscore `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Agility Score")																	///
	ysize(3) xsize(3)	ylabel(-10(5)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_agility.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*PEOPLE
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  peoplescore `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical	ylabel(-10(5)10)											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("People Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_people.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*SOLUTIONS
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  solutionsscore `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical	ylabel(-10(5)10)										///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Solutions Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_solutions.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*INNOVATION
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  innovationscore `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical	ylabel(-10(5)10)										///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Innovation Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_innovation.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*GROWTH
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  growthscore `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical ylabel(-10(5)10)											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Growth Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_growth.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*REGIONAL DISTRIBUTION OF SCORES
tab region
/*

                      region |      Freq.     Percent        Cum.
-----------------------------+-----------------------------------
      Not Mapped to a Region |        145       43.54       43.54
                      Africa |         45       13.51       57.06
       East Asia and Pacific |         30        9.01       66.07
     Europe and Central Asia |         34       10.21       76.28
 Latin America and Caribbean |         27        8.11       84.38
Middle East and Central Asia |         21        6.31       90.69
                  South Asia |         31        9.31      100.00
-----------------------------+-----------------------------------
                       Total |        333      100.00

*/
preserve
collapse (mean) 	$dimension (count) id, by(region)
sum $dimension
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
 peoplescore |          7    71.24251     1.64659   68.47559   73.33774
solutionss~e |          7    67.06643     2.04669   63.03941   69.67709
innovation~e |          7     64.7603    1.804434     62.435   67.30857
 growthscore |          7    68.30215    1.988009   65.53912   70.64484
*/
replace region = 7 if region == 0
twoway	(scatter 	peoplescore region [fweight=id], mcolor(green) ) 						///
		(scatter 	solutionsscore region, mcolor(edkblue))						///
		(scatter 	innovationscore region, mcolor(purple))							///
		(scatter 	growthscore region, mcolor(dkorange))						///
		(line 		agilityscore region, sort lcolor(black)),							///
					legend(	label(1 "People") label(2 "Solutions") 				///
							label(3 "Innovation") label(4 "Growth")	label(5 "Agility"))			///	
					xlabel(1 "AFR (45)" 2 "EAP (30)" 3 "ECA (34)" 				///
							4 "LAC (27)" 5 "MENA (21)" 6 "SAR (31)"				///
							7 "Not Mapped (145)", angle(30) labsize(small))		///	
					ytitle("Dimension Score") xtitle("Grade")					///
					title("Dimension Score by Regions")	subtitle(" ")			///
					graphregion(color(white)) bgcolor(white)					///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export dim_region.png, as(png) name("Graph") replace
restore

*COEF PLOT - AGILITY
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  agilityscore region`x', robust
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
	title("Agility Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_agility.png, as(png) name("Graph") replace
restore

*COEF PLOT - PEOPLE
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  peoplescore region`x', robust
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
graph export coef_region_people.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  solutionsscore region`x', robust
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
graph export coef_region_solutions.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  innovationscore region`x', robust
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
graph export coef_region_innovation.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  growthscore region`x', robust
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
graph export coef_region_growth.png, as(png) name("Graph") replace
restore

*PRACTICE
preserve
collapse (mean) $dimension (count) id , by(practice)
tab practice id
sum $dimension
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
 peoplescore |         17    69.68516    4.085173   62.30625   76.04333
solutionss~e |         17     67.4262    3.530833     61.666      76.67
innovation~e |         17    64.90026    4.057645      58.08   73.39667
 growthscore |         17    68.91951     3.92754   63.33429      77.22

*/
replace practice = 17 if practice == 0
sort id
twoway	(scatter 	peoplescore practice [fweight=id], mcolor(green) ) 						///
		(scatter 	solutionsscore practice, mcolor(edkblue))						///
		(scatter 	innovationscore practice, mcolor(purple))							///
		(scatter 	growthscore practice, mcolor(dkorange))						///
		(line 		agilityscore practice, sort lcolor(black)),						///
					legend(	label(1 "People")	label(2 "Solutions")						///
							label(3 "Innovation")	label(4 "Growth")	label(5 "Agility"))						///	
					xlabel(1 "FCI" 2 "GOV (25)" 3 "MTI" 4 "POV (5)" 5 "EDU (7)" ///
							6 "GEN (1)"	7 "HNP (9)" 8 "SPJ (7)" 9 "AGR (11)" 	///
							10 "CC (3)" 11 "ENV (8)" 12 "SUR (35)" 13 "WAT (12)" ///
							14 "EE (5)" 15 "INF (4)" 16 "TR (14)" 17 "Not Mapped (159)", angle(30) labsize(small))		///	
					ytitle("Dimension Score") xtitle("Grade")					///
					title("Dimension Score by Practice")	subtitle(" ")			///
					graphregion(color(white)) bgcolor(white)					///
					xsize(7)													///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export dim_practice.png, as(png) name("Graph") replace
restore

********************************************************************************
* 									STRENGTHS
********************************************************************************
*PEOPLE STRENGTHS
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  strengthpeople `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical	ylabel(-20(10)40)											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("People Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_strengthpeople.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*SOLUTIONS
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  strengthsolutions `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical	ylabel(-20(10)40)										///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Solutions Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_strengthsolutions.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*INNOVATION
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  strengthinnovation `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical	ylabel(-40(10)20)										///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", angle(30) labsize(small))	///
	graphregion(color(white)) bgcolor(white)								///
	title("Innovation Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_strengthinnovation.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

*GROWTH
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  strengthgrowth `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical ylabel(-40(10)20)											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Growth Score")																	///
	ysize(3) xsize(3)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_strengthgrowth.png, as(png) name("Graph") replace

foreach var of local score {
estimates drop `var'
}

********************************************************************************
*								ENVIRONMENT SCORES
*********************************************************************************

global dimension_env peoplescore_env solutionsscore_env innovationscore_env growthscore_env agilityscore_env
global dimension_trunc peoplescore_trunc solutionsscore_trunc innovationscore_trunc growthscore_trunc agilityscore_trunc

global dimensions_env_trunc  $dimension_env $dimension_trunc

foreach var of global dimensions_env_trunc {
egen med_`var' = median(`var')
tab med_`var'
*people_env 68.75, solutions_env 65, innovation_env 62.5, growth_env 66.67, agility_env 65,
*people_trunc 62.5, solutionsscore_trunc 65, innovationscore_trunc 62.5 growth_trunc 66.67 agility_trunc 64.11
}

*DOT PLOT WITH ALL DIFFERENCE IN MEANS FOR ENV AND PERSONAL

*TTEST
foreach var of global dimension {
	ttest `var'_env=`var'_trunc
}

*GENERATING DIFFERENCE IN MEANS VARIABLES
foreach var of global dimension {
gen `var'_env_trunc=`var'_env-`var'_trunc
gen `var'_env_score=`var'_env-`var'
}

*TTEST RESULTS
*Significant: peoplescore***, innovationscore*** 
preserve
gen allaverage = 1 
collapse (mean) peoplescore_env_trunc solutionsscore_env_trunc 					///
				innovationscore_env_trunc growthscore_env_trunc, by(allaverage)
rename (peoplescore_env_trunc solutionsscore_env_trunc innovationscore_env_trunc growthscore_env_trunc)	///
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
	xlabel(-2(1)2) legend() xline(0) xtitle("Difference from Average")		 	///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")				///s
	title( "Environment vs Personal Scores", size(medium))									///
	subtitle("Difference from Average", size(small))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export diff_env_personal.png, as(png) name("Graph") replace
restore

*COEF PLOT OF AGILITY SCORE BY ENV DIMENSIONS

local score peoplescore_env solutionsscore_env innovationscore_env growthscore_env
foreach var of local score {
reg  agilityscore `var', robust
estimates store `var'
}
coefplot 	(peoplescore_env, label(People))									///
			(solutionsscore_env, label(Solutions))								///
			(innovationscore_env, label(Innovation))							///
			(growthscore_env, label(Growth)), drop(_cons) xline(0) 				///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(12)			///
			legend(off)	xlabel(-.3(.1).3)										///
			ylabel(1 "People" 2 "Solutions" 3 "Innovation" 4 "Growth", 			///
					angle(0) labsize(small))									///
	graphregion(color(white)) bgcolor(white) xlabel(-10(5)10)					///
	title("Agility Score vs Enabling Environment") ysize(3) xsize(3)			///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_agility_env.png, as(png) name("Graph") replace

local score peoplescore_env solutionsscore_env innovationscore_env growthscore_env
foreach var of local score {
estimates drop `var'
}

*COEF PLOT OF ENV DIMENSIONS BY CHARACTERISTICS

*PEOPLE
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  peoplescore_env `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment People Score")											///
	ysize(3) xsize(3)	ylabel(-10(5)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_people_env.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
estimates drop `var'
}

*SOLUTIONS
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  solutionsscore_env `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment Solutions Score")											///
	ysize(3) xsize(3)		 ylabel(-10(5)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_solutions_env.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
estimates drop `var'
}

*INNOVATION
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  innovationscore_env `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment Innovation Score")											///
	ysize(3) xsize(3)	ylabel(-10(5)10)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_innovation_env.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
estimates drop `var'
}

*GROWTH
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  growthscore_env `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment Growth Score")											///
	ysize(3) xsize(3)		ylabel(-10(5)10)														///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_growth_env.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
estimates drop `var'
}

*AGILITY
local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
reg  agilityscore_env `var', robust
estimates store `var'
}
coefplot 	(gender_trunc, label(Female))									///
			(above40age, label(Age>=40))							///
			(above10exp, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(int_proc, label(Helpful Internal Proc))							///
			(motiv, label(Motivated))											///
			(use_skills, label(Uses Core Skills)), drop(_cons) yline(0) 			///
			mlabel format(%9.2f) mlabcolor(black)	mlabposition(3)			///
			legend(off)		vertical											///
			xlabel(1 "Female" 2 "Age>=40" 3 "Experience>=10" 4 ">=GG Grade" 	///
					5 "Helpful Internal Proc" 6 "Motivated" 7 "Uses Core Skills", ///
					angle(30) labsize(small))								///
	graphregion(color(white)) bgcolor(white)								///
	title("Environment Agility Score")											///
	ysize(3) xsize(3)	ylabel(-10(5)10)															///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_agility_env.png, as(png) name("Graph") replace

local score gender_trunc above40age above10exp gg_above int_proc motiv use_skills
foreach var of local score {
estimates drop `var'
}

*REGIONAL DISTRIBUTION OF ENVIRONMENT SCORES

*GRADE
tab region
global envdimension peoplescore_env solutionsscore_env innovationscore_env growthscore_env agilityscore_env
preserve
collapse (mean) $envdimension (count) id, by(region)
sum $envdimension
/*

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
peoplescor~v |          7    67.69457    2.395777   64.33823     71.875
solutionss~v |          7    64.45582     2.42914   60.29412   68.14815
innovation~v |          7    59.57216    1.243152   57.35294   61.49194
growthscor~v |          7    68.37542    3.025449   64.95098   72.83951
agilitysco~v |          7    64.83239    2.022411   61.47059   67.22222


*/
replace region = 7 if region == 0
twoway	(scatter 	peoplescore_env region [fweight=id], mcolor(green) ) 						///
		(scatter 	solutionsscore_env region, mcolor(edkblue))						///
		(scatter 	innovationscore_env region, mcolor(purple))							///
		(scatter 	growthscore_env region, mcolor(dkorange))						///
		(line 		agilityscore_env region, sort lcolor(black)),							///
					legend(	label(1 "Environment People") label(2 "Environment Solutions") 				///
							label(3 "Environment Innovation") label(4 "Environment Growth")	label(5 "Environment Agility"))			///	
					xlabel(1 "AFR (45)" 2 "EAP (30)" 3 "ECA (34)" 				///
							4 "LAC (27)" 5 "MENA (21)" 6 "SAR (31)"				///
							7 "Not Mapped (145)", angle(30) labsize(small))		///	
					ytitle("Environment Dimension Score") xtitle("Grade")					///
					title("Environment Dimension Score by Regions")	subtitle(" ")			///
					graphregion(color(white)) bgcolor(white)					///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export dim_envregion.png, as(png) name("Graph") replace
restore

*COEF PLOT - AGILITY
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  agilityscore_env region`x', robust
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
	title("Environment Agility Score", size(medium))	ysize(3) xsize(3)						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_region_agility_env.png, as(png) name("Graph") replace
restore

*COEF PLOT - PEOPLE
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  peoplescore_env region`x', robust
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
graph export coef_region_people_env.png, as(png) name("Graph") replace
restore

*COEF PLOT - SOLUTIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  solutionsscore_env region`x', robust
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
graph export coef_region_solutions_env.png, as(png) name("Graph") replace
restore

*COEF PLOT - INNOVATIONS
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  innovationscore_env region`x', robust
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
graph export coef_region_innovation_env.png, as(png) name("Graph") replace
restore

*COEF PLOT - GROWTH
preserve
replace region = 7 if region == 0
tab region, gen(region)
forvalues x = 1/7 {
reg  growthscore_env region`x', robust
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
graph export coef_region_growth_env.png, as(png) name("Graph") replace
restore

*PRACTICE
preserve
collapse (mean) $envdimension (count) id , by(practice)
tab practice id
sum $envdimension
replace practice = 17 if practice == 0
sort id
twoway	(scatter 	peoplescore_env practice [fweight=id], mcolor(green) ) 						///
		(scatter 	solutionsscore_env practice, mcolor(edkblue))						///
		(scatter 	innovationscore_env practice, mcolor(purple))							///
		(scatter 	growthscore_env practice, mcolor(dkorange))						///
		(line 		agilityscore_env practice, sort lcolor(black)),						///
					legend(	label(1 "Environment People") label(2 "Environment Solutions") 				///
							label(3 "Environment Innovation") label(4 "Environment Growth")	label(5 "Environment Agility"))						///	
					xlabel(1 "FCI" 2 "GOV (25)" 3 "MTI" 4 "POV (5)" 5 "EDU (7)" ///
							6 "GEN (1)"	7 "HNP (9)" 8 "SPJ (7)" 9 "AGR (11)" 	///
							10 "CC (3)" 11 "ENV (8)" 12 "SUR (35)" 13 "WAT (12)" ///
							14 "EE (5)" 15 "INF (4)" 16 "TR (14)" 17 "Not Mapped (159)", angle(30) labsize(small))		///	
					ytitle("Environment Dimension Score") xtitle("Grade")					///
					title("Environment Dimension Score by Practice")	subtitle(" ")			///
					graphregion(color(white)) bgcolor(white)					///
					xsize(7)													///
					note("Source: Data Collected from 339 users on the Work Behavior Tool")	
graph export dim_practice_env.png, as(png) name("Graph") replace
restore

********************************************************************************
*								KEY ITEMS										*
********************************************************************************
*PEOPLE: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 48, 49, 50, 51
*PEOPLE ENV: score3_env score5_env score7_env score50_env

*SOLUTIONS: 13, 14, 15, 16, 17, 18, 19, 20, 22, 23, 48, 50, 52, 53, 54
*SOLUTIONS ENV: score14_env score16_env score20_env score22_env score50_env

*INNOVATION: 25, 26, 27, 28, 29, 30, 31, 32, 52, 53, 55, 56
*INNOVATION ENV: score25_env score28_env score30_env score32_env

*GROWTH: 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 49, 51, 54, 55, 56
*GROWTH ENV: score33_env score34_env score35_env

********************************************************************************
*			PEOPLE ITEM SCORES BY DEMOGRAPHIC CATEGORIES
*********************************************************************************

global people 	score2_p score3_p score4_p score5_p score7_p score10_p score11_p  	///
				score12_p score48_p score49_p score51_p

*CORE PEOPLE ITEMS COEF PLOT
*CORE ITEMS: 3, 5, 7, 50
*ITEM 3 
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score3_p `var', robust
	estimates store `var'_score3
}
*ITEM 5
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score5_p `var', robust
	estimates store `var'_score5
}
*ITEM 7
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score7_p `var', robust
	estimates store `var'_score7
}
*ITEM 50
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score50_p `var', robust
	estimates store `var'_score50
}

*FACILITATE SCORE
coefplot (gender_trunc_score3, 	label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score3, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score3, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score3, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score3, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score3, 			label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score3, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Facilitate Score by Demographics", size(medium)) ysize(3) xsize(3)				///
	note(	"Facilitate: Facilitate tasks with the team effectively " 						///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item3.png, as(png) name("Graph") replace

*PROVIDE LEARNING
coefplot (gender_trunc_score5, 	label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score5, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score5, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score5, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score5, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score5, 			label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score5, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Provide Learning Score by Demographics", size(medium)) ysize(3) xsize(3)			///
	note(	"Provide Learning: Providing team members with adequate opportunities to learn" ///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item5.png, as(png) name("Graph") replace

*INCLUSIVE
coefplot (gender_trunc_score7, 	label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score7, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score7, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score7, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score7, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score7, 			label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score7, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Inclusive Score by Demographics", size(medium)) ysize(3) xsize(3)				///
	note(	"Inclusive: Fosters an inclusive workplace" 									///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item7.png, as(png) name("Graph") replace

*COOPERATIVE
coefplot (gender_trunc_score50, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score50, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score50, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score50, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score50, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score50, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score50, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Cooperative Score by Demographics", size(medium)) ysize(3) xsize(3)				///
	note(	"Cooperative: Cooperative, accommodating and understanding" 					///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item50.png, as(png) name("Graph") replace

foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
estimates drop `var'_score3  `var'_score5 `var'_score7 `var'_score50
}				

*OTHER SIGNIFICANT ITEMS COEF PLOT
*GENDER - 11
foreach var in score11_p {
	reg  `var' gender_trunc, robust
	estimates store `var'_gender
}
*AGE- COEF PLOT - 4, 10, 12
foreach var in score3_p score4_p score10_p score12_p {
	reg  `var' above40age, robust
	estimates store `var'_age
}
*EXPERIENCE- COEF PLOT - 51
foreach var in score3_p score51_p {
	reg  `var' above10exp, robust
	estimates store `var'_exp
}
*GRADE- COEF PLOT - 48
foreach var in score3_p score5_p score48_p {
	reg  `var' gg_above, robust
	estimates store `var'_grade
}
*INTERNAL PROCESSES- COEF PLOT - 7
foreach var in score7_p {
	reg  `var' int_proc, robust
	estimates store `var'_int_proc
}
*MOTIVATION - COEF PLOT - 10, 49 
foreach var in score3_p score10_p score49_p {
	reg  `var' motiv, robust
	estimates store `var'_motiv
}

coefplot (score11_p_gender, label(Item11)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(score4_p_age, 		label(Item4) 	mcolor(edkblue) ciopts(lcolor(edkblue))		///	
								offset(-0.20))											///									
		(score10_p_age, 	label(Item10) 	mcolor(edkblue) ciopts(lcolor(edkblue)))	///	
		(score12_p_age, 	label(Item12) 	mcolor(edkblue) ciopts(lcolor(edkblue))		///	
								offset(0.20))											///													
		(score51_p_exp, 	label(Item51)	mcolor(emerald) ciopts(lcolor(emerald)))	///	
		(score48_p_grade, 	label(Item48)	mcolor(brown)	ciopts(lcolor(brown)))		///		
		(score10_p_motiv, 	label(Item10)	mcolor(orange) 	ciopts(lcolor(orange)))		///				
		(score49_p_motiv, 	label(Item49)	mcolor(orange) 	ciopts(lcolor(orange))		///
								offset(0.20)), 											///
		drop(_cons) yline(0) 															///
	mlabel format(%9.2f) mlabcolor(black)	mlabposition(12)	noci 					///
	xlabel(	1 "Gender: 11" 	2 "Age: 4, 10, 12" 	3 "Exp: 51" 							///
			4 "Grade: 48" 	5 "Motiv: 10, 49", 											///
	labsize(small))	vertical ylabel(-5(5)15) legend(off)								///
	graphregion(color(white)) bgcolor(white) ysize(3) xsize(7)							///
	title("Other Item Scores for People by Demographics", size(medium))					///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_peopleitems.png, as(png) name("Graph") replace

********************************************************************************
*			SOLUTIONS ITEM SCORES BY DEMOGRAPHIC CATEGORIES
*********************************************************************************

*CORE SOLUTIONS ITEMS COEF PLOT
*CORE ITEMS: 14, 16, 20, 22
*ITEM 14 
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score14_p `var', robust
	estimates store `var'_score14
}
*ITEM 16
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score16_p `var', robust
	estimates store `var'_score16
}
*ITEM 20
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score20_p `var', robust
	estimates store `var'_score20
}
*ITEM 22
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score22_p `var', robust
	estimates store `var'_score22
}

*COLLABORATIVE SCORE
coefplot (gender_trunc_score14, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score14, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score14, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score14, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score14, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score14, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score14, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Collaborative Score by Demographics", size(medium)) ysize(3) xsize(3)			///
	note(	"Collaborative: Desire to be collaborative instead of competitive" 				///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item14.png, as(png) name("Graph") replace

*UPDATED
coefplot (gender_trunc_score16, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score16, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score16, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score16, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score16, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score16, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score16, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Updated Score by Demographics", size(medium)) ysize(3) xsize(3)			///
	note(	"Updated: Stay updated on the external market to understand it affects the organization" ///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item16.png, as(png) name("Graph") replace

*RELIABLE
coefplot (gender_trunc_score20, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score20, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score20, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score20, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score20, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score20, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score20, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Reliable Score by Demographics", size(medium)) ysize(3) xsize(3)				///
	note(	"Reliable: Fosters an inclusive workplace" 									///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item20.png, as(png) name("Graph") replace

*METHODICAL
coefplot (gender_trunc_score22, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score22, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score22, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score22, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score22, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score22, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score22, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Methodical Score by Demographics", size(medium)) ysize(3) xsize(3)				///
	note(	"Methodical: Deals with ambiguity by being methodical and patient" 					///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item22.png, as(png) name("Graph") replace

foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
estimates drop `var'_score14  `var'_score16 `var'_score20 `var'_score22
}				

*OTHER SIGNIFICANT SOLUTIONS ITEMS
global solutions score13_p score14_p score15_p score16_p score17_p score18_p		///
				score19_p score20_p score22_p score23_p score48_p score50_p 	///
				score52_p score53_p score54_p
*REGRESSION - GENDER -
foreach var of global solutions {
	reg  `var' gender_trunc, robust
	estimates store `var'_gender
}
*REGRESSION - AGE - 23, 54
foreach var of global solutions {
	reg  `var' above40age, robust
	estimates store `var'_age
}
*REGRESSION - EXP - 13, 23, 54
foreach var of global solutions {
	reg  `var' above10exp, robust
	estimates store `var'_exp
}
*REGRESSION - GRADE - 23, 48, 54
foreach var of global solutions {
	reg  `var' gg_above, robust
	estimates store `var'_grade
}
*REGRESSION - INTERNAL PROCESSES -15, 19
foreach var of global solutions {
	reg  `var' int_proc, robust
	estimates store `var'_int_proc
}
*REGRESSION - MOTIVATION - 15, 19, 54
foreach var of global solutions {
	reg  `var' motiv, robust
	estimates store `var'_motiv
}
*REGRESSION - USES SKILLS - 54
foreach var of global solutions {
	reg  `var' use_skills, robust
	estimates store `var'_skills
}

coefplot (score23_p_age, 	label(Item23) 	mcolor(edkblue) ciopts(lcolor(edkblue))		///	
								offset(-0.20))											///									
		(score54_p_age, 	label(Item54) 	mcolor(edkblue) ciopts(lcolor(edkblue)))	///	
		(score13_p_exp, 	label(Item13)	mcolor(emerald) ciopts(lcolor(emerald))		///	
								offset(-0.20))											///											
		(score23_p_exp, 	label(Item23)	mcolor(green) 	ciopts(lcolor(green)))		///	
		(score54_p_exp, 	label(Item54)	mcolor(green) 	ciopts(lcolor(green))		///	
								offset(0.20))											///													
		(score23_p_grade, 	label(Item23)	mcolor(brown)	ciopts(lcolor(brown))		///	
								offset(-0.20))											///													
		(score48_p_grade, 	label(Item48)	mcolor(brown)	ciopts(lcolor(brown)))		///		
		(score54_p_grade, 	label(Item54)	mcolor(brown)	ciopts(lcolor(brown))		///	
								offset(0.20))											///		
		(score15_p_int_proc, label(Item15)	mcolor(red)		ciopts(lcolor(red)))		///	
		(score19_p_int_proc, label(Item19)	mcolor(red)		ciopts(lcolor(red))			///	
								offset(0.20))											///				
		(score15_p_motiv, 	label(Item15)	mcolor(orange) 	ciopts(lcolor(orange))		///	
								offset(-0.20))											///									
		(score19_p_motiv, 	label(Item19)	mcolor(orange) 	ciopts(lcolor(orange)))		///						
		(score54_p_motiv, 	label(Item54)	mcolor(orange) 	ciopts(lcolor(orange))		///
								offset(0.20))											///
		(score54_p_skills, 	label(Item54)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) 															///
	mlabel format(%9.2f) mlabcolor(black)	mlabposition(12)	noci 					///
	xlabel(	1 "Age: 23, 54" 2 "Exp: 13, 23, 54" 3 "Grade: 23, 48, 54" 					///
			4 "Int_Proc: 15, 19" 5 "Motiv: 15, 19, 54"	6 "Use Skills: 54", 			///
	labsize(small))	vertical ylabel(-5(5)15) legend(off)								///
	graphregion(color(white)) bgcolor(white) ysize(3) xsize(7)							///
	title("Other Item Scores for Solutions by Demographics", size(medium))					///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_solitems.png, as(png) name("Graph") replace

foreach var of global solutions {
estimates drop `var'_skills `var'_motiv `var'_int_proc `var'_grade  `var'_exp 	///
				`var'_age  `var'_gender
}				

********************************************************************************
*			INNOVATION ITEM SCORES BY DEMOGRAPHIC CATEGORIES
*********************************************************************************

*CORE INNOVATION ITEMS COEF PLOT
*CORE ITEMS: 25, 28, 30, 32
*ITEM 25 
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score25_p `var', robust
	estimates store `var'_score25
}
*ITEM 28
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score28_p `var', robust
	estimates store `var'_score28
}
*ITEM 30
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score30_p `var', robust
	estimates store `var'_score30
}
*ITEM 32
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score32_p `var', robust
	estimates store `var'_score32
}

*UNCONVENTIONAL SCORE
coefplot (gender_trunc_score25, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score25, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score25, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score25, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score25, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score25, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score25, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Unconventional Score by Demographics", size(medium)) ysize(3) xsize(3)			///
	note(	"Unconventional: Willing to consider new and unconventional ideas and solutions to problems" ///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item25.png, as(png) name("Graph") replace

*INVENTIVE
coefplot (gender_trunc_score28, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score28, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score28, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score28, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score28, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score28, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score28, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Inventive Score by Demographics", size(medium)) ysize(3) xsize(3)				///
	note(	"Inventive: Desire to design and implement new programs/processes" 				///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item28.png, as(png) name("Graph") replace

*ADAPTIVE
coefplot (gender_trunc_score30, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score30, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score30, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score30, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score30, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score30, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score30, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Adaptive Score by Demographics", size(medium)) ysize(3) xsize(3)					///
	note(	"Adaptive: Open to changes taking place in the organization" 					///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item30.png, as(png) name("Graph") replace

*IMPERVIOUS
coefplot (gender_trunc_score32, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score32, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score32, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score32, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score32, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score32, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score32, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Impervious Score by Demographics", size(medium)) ysize(3) xsize(3)				///
	note(	"Impervious: Impervious to social norms and judgement" 							///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item32.png, as(png) name("Graph") replace

foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
estimates drop `var'_score25  `var'_score28 `var'_score30 `var'_score32
}				

*OTHER SIGNIFICANT INNOVATION ITEMS
global innovation score25_p score26_p score27_p score28_p score29_p score30_p	///
				score31_p score32_p score52_p score53_p score55_p score56_p
*REGRESSION - GENDER - 27, 55
foreach var of global innovation {
	reg  `var' gender_trunc, robust
	estimates store `var'_gender
}
*REGRESSION - AGE - 29, 56
foreach var of global innovation {
	reg  `var' above40age, robust
	estimates store `var'_age
}
*REGRESSION - EXP -
foreach var of global innovation {
	reg  `var' above10exp, robust
	estimates store `var'_exp
}
*REGRESSION - GRADE - 27
foreach var of global innovation {
	reg  `var' gg_above, robust
	estimates store `var'_grade
}
*REGRESSION - INTERNAL PROCESSES -27, 55
foreach var of global innovation {
	reg  `var' int_proc, robust
	estimates store `var'_int_proc
}
*REGRESSION - MOTIVATION - 27, 30
foreach var of global innovation {
	reg  `var' motiv, robust
	estimates store `var'_motiv
}
*REGRESSION - USES SKILLS - 29
foreach var of global innovation {
	reg  `var' use_skills, robust
	estimates store `var'_skills
}

coefplot (score27_p_gender, label(Item27)	mcolor(maroon) 	ciopts(lcolor(maroon))		///
								offset(-0.20))											///	
		(score55_p_gender, label(Item55)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///							
		(score29_p_age, 	label(Item29) 	mcolor(edkblue) ciopts(lcolor(edkblue)))	///	
		(score56_p_age, 	label(Item56) 	mcolor(edkblue) ciopts(lcolor(edkblue))		///	
								offset(0.20))											///											
		(score27_p_grade, 	label(Item27)	mcolor(brown)	ciopts(lcolor(brown)))		///	
		(score27_p_int_proc, label(Item27)	mcolor(red)		ciopts(lcolor(red)))		///	
		(score55_p_int_proc, label(Item55)	mcolor(red)		ciopts(lcolor(red))			///	
								offset(0.20))											///				
		(score27_p_motiv, 	label(Item27)	mcolor(orange) 	ciopts(lcolor(orange))		///	
								offset(-0.20))											///									
		(score30_p_motiv, 	label(Item30)	mcolor(orange) 	ciopts(lcolor(orange)))		///						
		(score29_p_skills, 	label(Item29)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) 															///
	mlabel format(%9.2f) mlabcolor(black)	mlabposition(12)	noci 					///
	xlabel(	1 "Gender: 27, 55" 2 "Age: 29, 59" 3 "Grade: 27" 							///
			4 "Int_Proc: 27, 55" 5 "Motiv: 27, 30"	6 "Use Skills: 29", 				///
	labsize(small))	vertical ylabel(-15(5)15) legend(off)								///
	graphregion(color(white)) bgcolor(white) ysize(3) xsize(7)							///
	title("Other Item Scores for Innovation by Demographics", size(medium))					///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_innitems.png, as(png) name("Graph") replace

foreach var of global innovation {
estimates drop `var'_skills `var'_motiv `var'_int_proc `var'_grade  `var'_exp 	///
				`var'_age  `var'_gender
}				

********************************************************************************
*			GROWTH ITEM SCORES BY DEMOGRAPHIC CATEGORIES
*********************************************************************************

*CORE INNOVATION ITEMS COEF PLOT
*CORE ITEMS: 33, 34, 35
*ITEM 33 
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score25_p `var', robust
	estimates store `var'_score33
}
*ITEM 34
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score28_p `var', robust
	estimates store `var'_score34
}
*ITEM 35
foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
	reg score30_p `var', robust
	estimates store `var'_score35
}

*RESPONSIBLE SCORE
coefplot (gender_trunc_score33, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score33, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score33, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score33, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score33, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score33, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score33, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Responsible Score by Demographics", size(medium)) ysize(3) xsize(3)			///
	note(	"Responsible: Determine objectives, set priorities and follow through one's plans" ///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item33.png, as(png) name("Graph") replace

*HIGH QUALITY
coefplot (gender_trunc_score34, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score34, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score34, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score34, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score34, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score34, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score34, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("High Quality Score by Demographics", size(medium)) ysize(3) xsize(3)				///
	note(	"High Quality: Holds oneself accountable for high quality" 				///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item34.png, as(png) name("Graph") replace

*TIME EFFECTIVE
coefplot (gender_trunc_score35, label(Gender)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///
		(above40age_score35, 	label(Age) 		mcolor(edkblue) ciopts(lcolor(edkblue)))	///
		(above10exp_score35, 	label(Exp) 		mcolor(green) 	ciopts(lcolor(green)))		///	
		(gg_above_score35, 		label(Grade) 	mcolor(brown) 	ciopts(lcolor(brown)))		///	
		(int_proc_score35, 		label(In_pr) 	mcolor(purple) 	ciopts(lcolor(purple)))		///	
		(motiv_score35, 		label(Motiv)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(use_skills_score35, 	label(Skills)	mcolor(teal) 	ciopts(lcolor(teal))), 		///
		drop(_cons) yline(0) mlabel format(%9.2f) mlabcolor(black)	mlabposition(3) 		///
	xlabel(	1 "Gender" 2 "Age" 3 "Experience" 4 "Grade" 									///
			5 "Internal Processes" 6 "Motivation" 7 "Uses Skills", 							///
	labsize(small) angle(30))	vertical ylabel(-15(5)15) legend(off)						///
	graphregion(color(white)) bgcolor(white)												///
	title("Time Effective Score by Demographics", size(medium)) ysize(3) xsize(3)					///
	note(	"Time Effective: Holds oneself accountable for time-effective results" 					///
			"Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_item35.png, as(png) name("Graph") replace


foreach var in gender_trunc above40age above10exp gg_above int_proc motiv use_skills {
estimates drop `var'_score33  `var'_score34 `var'_score35 
}				

*OTHER SIGNIFICANT GROWTH ITEMS
global growth score33_p score34_p score35_p score36_p score37_p score38_p score39_p ///
				score40_p score41_p score42_p score49_p score51_p score54_p score55_p score56_p
*REGRESSION - GENDER - 40, 55
foreach var of global growth {
	reg  `var' gender_trunc, robust
	estimates store `var'_gender
}
*REGRESSION - AGE - 39, 54, 56
foreach var of global growth {
	reg  `var' above40age, robust
	estimates store `var'_age
}
*REGRESSION - EXP - 51, 54
foreach var of global growth {
	reg  `var' above10exp, robust
	estimates store `var'_exp
}
*REGRESSION - GRADE - 39, 41, 51, 54
foreach var of global growth {
	reg  `var' gg_above, robust
	estimates store `var'_grade
}
*REGRESSION - INTERNAL PROCESSES - 37, 39, 55
foreach var of global growth {
	reg  `var' int_proc, robust
	estimates store `var'_int_proc
}
*REGRESSION - MOTIVATION - 37, 39, 55
foreach var of global growth {
	reg  `var' motiv, robust
	estimates store `var'_motiv
}
*REGRESSION - USES SKILLS - 40, 54
foreach var of global growth {
	reg  `var' use_skills, robust
	estimates store `var'_skills
}

coefplot (score40_p_gender, label(Item40)	mcolor(maroon) 	ciopts(lcolor(maroon)))		///	
		(score55_p_gender, label(Item55)	mcolor(maroon) 	ciopts(lcolor(maroon))		///		
								offset(0.20))											///			
		(score39_p_age, 	label(Item39) 	mcolor(edkblue) ciopts(lcolor(edkblue))		///	
								offset(-0.20))											///	
		(score54_p_age, 	label(Item54) 	mcolor(edkblue) ciopts(lcolor(edkblue)))	///									
		(score56_p_age, 	label(Item56) 	mcolor(edkblue) ciopts(lcolor(edkblue))		///	
								offset(0.20))											///	
		(score51_p_exp, 	label(Item51)	mcolor(green) 	ciopts(lcolor(green)))		///	
		(score54_p_exp, 	label(Item54)	mcolor(green) 	ciopts(lcolor(green))		///	
								offset(0.20))											///			
		(score39_p_grade, 	label(Item39)	mcolor(brown)	ciopts(lcolor(brown))		///	
								offset(-0.40))											///					
		(score41_p_grade, 	label(Item39)	mcolor(brown)	ciopts(lcolor(brown))		///
								offset(-0.20))											///							
		(score51_p_grade, 	label(Item39)	mcolor(brown)	ciopts(lcolor(brown)))		///	
		(score54_p_grade, 	label(Item39)	mcolor(brown)	ciopts(lcolor(brown))		///
								offset(0.20))											///							
		(score37_p_int_proc, label(Item37)	mcolor(red)		ciopts(lcolor(red))			///	
								offset(-0.20))											///		
		(score39_p_int_proc, label(Item39)	mcolor(red)		ciopts(lcolor(red)))		///	
		(score55_p_int_proc, label(Item55)	mcolor(red)		ciopts(lcolor(red))			///	
								offset(0.20))											///		
		(score37_p_motiv, 	label(Item37)	mcolor(orange) 	ciopts(lcolor(orange))		///	
								offset(-0.20))											///									
		(score39_p_motiv, 	label(Item39)	mcolor(orange) 	ciopts(lcolor(orange)))		///	
		(score55_p_motiv, 	label(Item55)	mcolor(orange) 	ciopts(lcolor(orange))		///
								offset(0.20))											///											
		(score40_p_skills, 	label(Item40)	mcolor(teal) 	ciopts(lcolor(teal))		///
								offset(-0.20))											///											
		(score54_p_skills, 	label(Item54)	mcolor(teal) 	ciopts(lcolor(teal))), 		///		
		drop(_cons) yline(0) 															///
	mlabel format(%9.2f) mlabcolor(black) mlabposition(12) noci 						///
	xlabel(	1 "Gender: 40, 55" 2 "Age: 39, 54, 56" 3 "Exp: 51, 54" 						///
			4 "Grade: 39, 41, 51, 54" 5 "Int Proc: 37, 39, 55" 							///
			6 "Motiv: 37, 39, 55" 7 "Use Skills: 40, 54", labsize(small))				///
			vertical ylabel(-15(5)15) legend(off)										///
	graphregion(color(white)) bgcolor(white) ysize(3) xsize(7)							///
	title("Other Item Scores for Growth by Demographics", size(medium))					///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_gritems.png, as(png) name("Graph") replace

foreach var of global growth {
estimates drop `var'_skills `var'_motiv `var'_int_proc `var'_grade  `var'_exp 	///
				`var'_age  `var'_gender
}				

********************************************************************************
*				ENABLING ENVIRONMENT OF KEY PEOPLE ITEMS						*
********************************************************************************

global keypeople score3 score5 score7 score50

*DOT PLOT WITH ALL DIFFERENCE IN MEANS FOR ENV AND PERSONAL

*TTEST
foreach var of global keypeople {
	ttest `var'_env_p=`var'_p
}

*TTEST RESULTS
*Significant: score50*** score7*** score5*** score3***
preserve

*GENERATING DIFFERENCE IN MEANS VARIABLES
foreach var of global keypeople {
gen `var'_env_people=`var'_env_p-`var'_p
}
gen allaverage = 1 
collapse (mean) score50_env_people score7_env_people score5_env_people score3_env_people, by(allaverage)
rename (score50_env_people score7_env_people score5_env_people score3_env_people)	///
		(score_env_people1 score_env_people2 score_env_people3 score_env_people4)
reshape long score_env_people, i(allaverage) j(score_name)

label define score_namelbl	1 "Facilitate" 	2 "Provide Learning"				///
							3 "Inclusive" 	4 "Cooperative"
label values score_name score_namelbl
format score_env_people %9.1f
sort score_name
twoway (scatter score_name score_env_people, mlabel(score_env_people)), 		///
	legend(label(1 "Environment Vs Personal (Trunc)"))							///
	ylabel(1 "Facilitate" 2 "Provide Learning" 3 "Inclusive" 4 "Cooperative", angle(30))		///
	xlabel(-25(5)25) legend() xline(0) xtitle("Difference from Average")		 	///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")				///s
	title( "Environment vs Personal Key Items Scores", size(medium))									///
	subtitle("Difference from Average", size(small))							///
	note("Source: Data Collected from Work Behavior Tool"						///
		"All Differences are Statistically Significant", size(vsmall)) 
graph export diff_env_personal_peoplekey.png, as(png) name("Graph") replace
restore

********************************************************************************
*				ENABLING ENVIRONMENT OF KEY SOLUTIONS ITEMS						*
********************************************************************************

global keysolutions score14 score16 score20 score22

*DOT PLOT WITH ALL DIFFERENCE IN MEANS FOR ENV AND PERSONAL

*TTEST
foreach var of global keysolutions {
	ttest `var'_env_p=`var'_p
}

*TTEST RESULTS
*Significant: score22*** score16***
preserve

*GENERATING DIFFERENCE IN MEANS VARIABLES
foreach var of global keysolutions {
gen `var'_env_solutions=`var'_env_p-`var'_p
}
gen allaverage = 1 
collapse (mean) score14_env_solutions score16_env_solutions score20_env_solutions score22_env_solutions, by(allaverage)
rename (score14_env_solutions score16_env_solutions score20_env_solutions score22_env_solutions)	///
		(score_env_solutions1 score_env_solutions2 score_env_solutions3 score_env_solutions4)
reshape long score_env_solutions, i(allaverage) j(score_name)

label define score_namelbl	1 "Collaborative" 	2 "Updated"				///
							3 "Reliable" 		4 "Methodical"
label values score_name score_namelbl
format score_env_solutions %9.1f
sort score_name
twoway (scatter score_name score_env_solutions, mlabel(score_env_solutions)), 		///
	legend(label(1 "Environment Vs Personal (Trunc)"))							///
	ylabel(1 "Collaborative" 2 "Updated" 3 "Reliable" 4 "Methodical", angle(30))		///
	xlabel(-25(10)25) legend() xline(0) xtitle("Difference from Average")		 	///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")				///s
	title( "Environment vs Personal Key Items Scores", size(medium))									///
	subtitle("Difference from Average", size(small))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export diff_env_personal_solutionskey.png, as(png) name("Graph") replace
restore

********************************************************************************
*			ENABLING ENVIRONMENT OF KEY INNOVATION ITEMS						*
********************************************************************************

global keyinnovation score25 score28 score30 score32

*DOT PLOT WITH ALL DIFFERENCE IN MEANS FOR ENV AND PERSONAL

*TTEST
foreach var of global keyinnovation {
	ttest `var'_env_p=`var'_p
}

*TTEST RESULTS
*Significant: score30*** score25***
preserve

*GENERATING DIFFERENCE IN MEANS VARIABLES
foreach var of global keyinnovation {
gen `var'_env_innovation=`var'_env_p-`var'_p
}
gen allaverage = 1 
collapse (mean) score25_env_innovation score28_env_innovation score30_env_innovation score32_env_innovation, by(allaverage)
rename (score25_env_innovation score28_env_innovation score30_env_innovation score32_env_innovation)	///
		(score_env_innovation1 score_env_innovation2 score_env_innovation3 score_env_innovation4)
reshape long score_env_innovation, i(allaverage) j(score_name)

label define score_namelbl	1 "Unconventional" 	2 "Inventive"				///
							3 "Adaptive" 		4 "Impervious"
label values score_name score_namelbl
format score_env_innovation %9.1f
sort score_name
twoway (scatter score_name score_env_innovation, mlabel(score_env_innovation)), 		///
	legend(label(1 "Environment Vs Personal (Trunc)"))							///
	ylabel(1 "Unconventional" 2 "Inventive" 3 "Adaptive" 4 "Impervious", angle(30))		///
	xlabel(-15(5)15) legend() xline(0) xtitle("Difference from Average")		 	///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")				///s
	title( "Environment vs Personal Key Items Scores", size(medium))									///
	subtitle("Difference from Average", size(small))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export diff_env_personal_innovationkey.png, as(png) name("Graph") replace
restore

********************************************************************************
*			ENABLING ENVIRONMENT OF KEY GROWTH ITEMS						*
********************************************************************************

global keygrowth score33 score34 score35 

*DOT PLOT WITH ALL DIFFERENCE IN MEANS FOR ENV AND PERSONAL

*TTEST
foreach var of global keygrowth {
	ttest `var'_env_p=`var'_p
}

*TTEST RESULTS
*Significant: score33*** score35***
preserve

*GENERATING DIFFERENCE IN MEANS VARIABLES
foreach var of global keygrowth {
gen `var'_env_growth=`var'_env_p-`var'_p
}
gen allaverage = 1 
collapse (mean) score33_env_growth score34_env_growth score35_env_growth, by(allaverage)
rename (score33_env_growth score34_env_growth score35_env_growth)	///
		(score_env_growth1 score_env_growth2 score_env_growth3)
reshape long score_env_growth, i(allaverage) j(score_name)

label define score_namelbl	1 "Responsible" 	2 "High-Quality"				///
							3 "Time-Effective" 	
label values score_name score_namelbl
format score_env_growth %9.1f
sort score_name
twoway (scatter score_name score_env_growth, mlabel(score_env_growth)), 		///
	legend(label(1 "Environment Vs Personal (Trunc)"))							///
	ylabel(1 "Responsible" 2 "High-Quality" 3 "Time-Effective", angle(30))		///
	xlabel(-15(5)15) legend() xline(0) xtitle("Difference from Average")		 	///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")				///
	title( "Environment vs Personal Key Items Scores", size(medium))									///
	subtitle("Difference from Average", size(small))							///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export diff_env_personal_growthkey.png, as(png) name("Graph") replace
restore

save "$onedrive\Intermediate\wbt_v4.dta", replace

/********************************************************************************
*					COMPARISION WITH AGILE CHAMPIONS							*
********************************************************************************

use "$onedrive\Intermediate\wbt_pilot_v3.dta", clear

*AVERAGE DIMENSION SCORES 
grstyle init
grstyle set plain, horizontal
grstyle set color Accent: p#bar p#barline
grstyle set intensity 40: bar

foreach var of global dimension {
egen med_`var' = median(`var')
tab med_`var'
*people 76.56 , solutions 73.33, innovation 71.15, growth 71.67, agility 74.505
}

graph box $dimension,															///
	yvaroptions(relabel(1 "People" 		2 "Solutions"							///
						3 "Innovation"	4 "Growth"	5 "Overall Agility"))		///						
	ylabel(40(10)100)outergap(20) bargap(30) showyvars legend(off) 				///	
	box(1, fcolor(green) lcolor(green)) 										///
	box(2, fcolor(edkblue) lcolor(edkblue))										///
	box(3, fcolor(purple) lcolor(purple))										///
	box(4, fcolor(dkorange) lcolor(dkorange))									///
	box(5, fcolor(black) lcolor(black)) 										///
	ytitle("Dimension Scores", size(small))										///
	graphregion(color(white)) bgcolor(white)									///
	title( "Average Scores on each Dimension", size(medium))					///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_pilot_scores.png, as(png) name("Graph") replace

*DOT PLOT WITH AGILE CHAMPIONS ENV-PERSONAL

*TTEST
foreach var of global dimension {
	ttest `var'_env=`var'_trunc
}

*GENERATING DIFFERENCE IN MEANS VARIABLES
foreach var of global dimension {
gen `var'_env_trunc=`var'_env-`var'_trunc
gen `var'_env_score=`var'_env-`var'
}

*TTEST RESULTS
*Significant: agilityscore***, innovationscore***, solutionscore***, peoplescore***, growthscore***
preserve
gen allaverage = 1 
collapse (mean) peoplescore_env_trunc solutionsscore_env_trunc innovationscore_env_trunc 		///
				growthscore_env_trunc agilityscore_env_trunc, by(allaverage)
rename (peoplescore_env_trunc solutionsscore_env_trunc innovationscore_env_trunc 				///
		growthscore_env_trunc agilityscore_env_trunc) 											///
		(score_env_trunc1 score_env_trunc2 score_env_trunc3 score_env_trunc4 score_env_trunc5)
reshape long score_env_trunc, i(allaverage) j(score_name)

label define score_namelbl	1 "People" 		2 "Solutions"										///
							3 "Innovation" 	4 "Growth" 5 "Agility"
label values score_name score_namelbl
format score_env_trunc %9.1f
sort score_name
twoway (scatter score_name score_env_trunc, mlabel(score_env_trunc)), 							///
	legend(label(1 "Environment Vs Personal (Trunc)"))											///
	ylabel(1 "People" 2 "Solutions" 3 "Innovation" 4 "Growth" 5 "Agility", angle(90))			///
	xlabel(-30(5)5) legend() xline(0) xtitle("Difference from Average")		 					///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")								///
	title( "Environment vs Personal Scores", size(medium))										///
	subtitle("Difference from Average", size(small))											///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export diff_ach_env_personal.png, as(png) name("Graph") replace
restore

save "$onedrive\Intermediate\wbt_pilot_v4.dta", replace

*DOT PLOT WITH AGILE CHAMPIONS VS PHASE 1

*APPENDING DATA FROM PILOT WITH AGILE CHAMPIONS
append using "$onedrive\Intermediate\wbt_v4.dta", force

*TTEST
foreach var of global dimension {
	ttest `var', by(phase)
}

*TTEST RESULTS
*Significant: peoplescore***, innovationscore***, agilityscore***, growthscore***, solutionscore***
preserve
collapse (mean) peoplescore solutionsscore innovationscore growthscore agilityscore, by(phase)
rename (peoplescore solutionsscore innovationscore growthscore agilityscore)					///
		(score1 score2 score3 score4 score5)
reshape long score, i(phase) j(score_name)

label define score_namelbl	1 "People" 		2 "Solutions"										///
							3 "Innovation" 	4 "Growth" 5 "Agility"
label values score_name score_namelbl
format score %9.1f
sort score_name
twoway 	(scatter score_name score if phase == 2, mlabel(score))									///
		(scatter score_name score if phase == 1, mlabel(score)), 								///
	legend(label(1 "Phase 1") label(2 "Agile Champions"))										///
	ylabel(1 "People" 2 "Solutions" 3 "Innovation" 4 "Growth" 5 "Agility", angle(30))			///
	xlabel(60(5)80) legend() xline(0) xtitle("Score")		 									///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")								///
	title( "Phase 1 vs Agile Champions", size(medium))											///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export diff_agilech_phase1.png, as(png) name("Graph") replace
restore

*DOT PLOT WITH AGILE CHAMPIONS ENV-PERSONAL AND PHASE 1 COMPARISON

*TTEST RESULTS
*Significant: agilityscore***, innovationscore***, solutionscore***, peoplescore***, growthscore***
preserve
collapse (mean) peoplescore_env_trunc solutionsscore_env_trunc innovationscore_env_trunc 		///
				growthscore_env_trunc agilityscore_env_trunc, by(phase)
rename (peoplescore_env_trunc solutionsscore_env_trunc innovationscore_env_trunc 				///
		growthscore_env_trunc agilityscore_env_trunc) 											///
		(score_env_trunc1 score_env_trunc2 score_env_trunc3 score_env_trunc4 score_env_trunc5)
reshape long score_env_trunc, i(phase) j(score_name)

label define score_namelbl	1 "People" 		2 "Solutions"										///
							3 "Innovation" 	4 "Growth" 5 "Agility"
label values score_name score_namelbl
format score_env_trunc %9.1f
sort score_name
twoway 	(scatter score_name score_env_trunc if phase == 2, mlabel(score_env_trunc))				///
		(scatter score_name score_env_trunc if phase == 1, mlabel(score_env_trunc)), 			///
	legend(label(1 "Phase 1") label(2 "Agile Champions"))									///
	ylabel(1 "People" 2 "Solutions" 3 "Innovation" 4 "Growth" 5 "Agility", angle(30))			///
	xlabel(-30(5)5) legend() xline(0) xtitle("Difference from Average")		 					///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")								///
	title( "Phase 1 vs Agile Champions", size(medium))											///
	subtitle("Difference from Average", size(small))											///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export diff_ach_ph1_env_personal.png, as(png) name("Graph") replace
restore

*DISTRIBUTION OF HIGHEST SCORES
global strength_p strengthpeople_p strengthsolutions_p strengthinnovation_p strengthgrowth_p

graph hbar (mean) $strength_p, over(phase, label(labsize(small)))	stack						///
	outergap(20) bargap(30) showyvars blabel(bar,  pos(inside) format(%9.2f))					///
	legend(lab(1 "People") lab(2 "Solutions")lab(3 "Innovation")lab(4 "Growth") size(vsmall)) 	///
	bar(1, fcolor(green) lcolor(green)) 														///
	bar(2, fcolor(edkblue) lcolor(edkblue))														///
	bar(3, fcolor(purple) lcolor(purple))														///
	bar(4, fcolor(dkorange) lcolor(dkorange))													///
	ytitle("Dimension Scores", size(small))														///
	graphregion(color(white)) bgcolor(white)													///
	title( "Proportion of Strengths in Each Dimension", size(medium))							///
	note("Source: Data Collected from 339 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_strength.png, as(png) name("Graph") replace

save "$onedrive\Intermediate\wbt_pilot_v4.dta", replace



