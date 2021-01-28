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
*						PART 3:  Run selected sections						   *
********************************************************************************

use "$onedrive\Intermediate\wbt_v3.dta", clear

set graphics off
********************************************************************************
*				SOCIAL DESIRABILITY	AND EXTREME RESPONSES						*
********************************************************************************

*GRAPH 1: Histogram of Social Desirability and Extreme Responses
********************************************************************************
global extreme_responses "Extreme Responses"
global social_desirability "Social Desirability"

foreach bias in social_desirability extreme_responses {
hist `bias', freq color(green) lcolor(black) 						///
		xtitle("$`bias' (mean)")						
graph export hist_`bias'.png, as(png) name("Graph") replace

*GRAPH 2: Scatter plot of average social desirability and Extreme Responses by demographics
********************************************************************************

*checking which demographic is statistically significant with extreme responding & social desirability
	local score gend ageb expb gg_above
	foreach var of local score {
		reg  `bias' `var', robust
		estimates store `var'
}

	*significant: gend, gg_above

	preserve
	*generating variables for each demographic category for bias
	local score gend ageb expb gg_above
	foreach var of local score {
		egen `bias'`var'1 	= mean(`bias') if `var'==1
		sort `bias'`var'1
		replace `bias'`var'1 = . if _n!=1
		egen `bias'`var'0		= mean(`bias') if `var'==0
		sort `bias'`var'0
		replace `bias'`var'0 = . if _n!=3
}

*Truncating the dataset to only include the mean bias by each category
	keep if `bias'gend1		!=.	|	`bias'gend0		!=.	|	///
			`bias'ageb1		!=.	|	`bias'ageb0		!=.	|	///
			`bias'expb1		!=.	|	`bias'expb0		!=.	|	///
			`bias'gg_above1			!=.	|	`bias'gg_above0			!=.	
			
	*Generating filter variable for bias in each category
	gen 	filter = 1 if 	`bias'gend1		!=.	| `bias'ageb1	!=.	|	///
							`bias'expb1		!=.	| `bias'gg_above1	!=.	

	replace filter = 0 if 	`bias'gend0		!=.	| `bias'ageb0	!=.	|	///
							`bias'expb0		!=.	| `bias'gg_above0	!=.
							
	*keeping only the variables needed for the chart
	keep 	`bias'gend1		`bias'gend0			///
			`bias'ageb1		`bias'ageb0			///
			`bias'expb1		`bias'expb0			///
			`bias'gg_above1			`bias'gg_above0	filter			
			
	*generating concatenated variable for all average bias by categories		
	egen 	`bias'_dem=rowtotal(`bias'*1 `bias'*0)	

	*generating a label variable with all category names		
	gen 	dem_name =	""
	replace dem_name = "Female" 				if 	`bias'gend1	///
												==	`bias'_dem 	
	replace dem_name = "Female" 					if 	`bias'gend0	///
												==	`bias'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`bias'ageb1	///
												==	`bias'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`bias'ageb0	///
												==	`bias'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`bias'expb1	///
												==	`bias'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`bias'expb0	///
												==	`bias'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`bias'gg_above1		///
												==	`bias'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`bias'gg_above0		///
												==	`bias'_dem 	
	format `bias'_dem %9.2f
	encode dem_name, gen(dem_name_n)	
	drop 	dem_name
	ren dem_name_n dem_name



*generating the graph
sort 	dem_name										
twoway 	(scatter `bias'_dem dem_name if filter==1, 						///
					mlabel(`bias'_dem) mlabposition(3) mcolor(dkblue)	///
					legend(label(1 "Demographic==1"))	mlabsize(vsmall))			///
		(scatter `bias'_dem dem_name if filter==0, 						///
					mlabel(`bias'_dem) mlabposition(3) mcolor(red)		///
					legend(label(2 "Demographic==0")) mlabsize(vsmall)),			///			
	xlabel(1 "Above 10 Exp" 2 "Above 40 Age" 3 "Above GG Grade" 4 "Female", angle(0))		///
	legend() xtitle("") graphregion(color(white)) bgcolor(white) 						///
	ytitle("Average $`bias'")	///
	title( "Average $`bias' by Demographics", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export scatter_`bias'_dem.png, as(png) name("Graph") replace
restore
}

*DROPPING OBSERVATIONS WITH MORE THAN 75% EXTREME RESPONSES
********************************************************************************
keep if extreme_responses_75==0
*17 Observations Deleted

*******************************************************************************
*					ANCHOR QUESTIONS BY DEMOGRAPHIC CATEGORIES
********************************************************************************
global ip_sd "Helpful Internal Processes"
global motiv_sd "Motivation"
global usk_sd "Uses Core Skills"

*GRAPH 2: Scatter plot of average anchor by demographics
********************************************************************************

*checking which demographic is statistically significant with anchors
foreach anchor in ip_sd motiv_sd usk_sd {
	preserve
	replace `anchor'=`anchor'*100
	local score gend ageb expb gg_above
	foreach var of local score {
		reg  `anchor' `var', robust
		estimates store `var'
}

	*significant usk: expb ageb
	*significant ip_sd: gg_above ageb

	*generating variables for each demographic category for bias
	local score gend ageb expb gg_above
	foreach var of local score {
		egen `anchor'`var'1 	= mean(`anchor') if `var'==1
		sort `anchor'`var'1
		replace `anchor'`var'1 = . if _n!=1
		egen `anchor'`var'0		= mean(`anchor') if `var'==0
		sort `anchor'`var'0
		replace `anchor'`var'0 = . if _n!=3
}

*Truncating the dataset to only include the mean bias by each category
	keep if `anchor'gend1		!=.	|	`anchor'gend0		!=.	|	///
			`anchor'ageb1		!=.	|	`anchor'ageb0		!=.	|	///
			`anchor'expb1		!=.	|	`anchor'expb0		!=.	|	///
			`anchor'gg_above1			!=.	|	`anchor'gg_above0			!=.	
			
	*Generating filter variable for bias in each category
	gen 	filter = 1 if 	`anchor'gend1		!=.	| `anchor'ageb1	!=.	|	///
							`anchor'expb1		!=.	| `anchor'gg_above1	!=.	

	replace filter = 0 if 	`anchor'gend0		!=.	| `anchor'ageb0	!=.	|	///
							`anchor'expb0		!=.	| `anchor'gg_above0	!=.
							
	*keeping only the variables needed for the chart
	keep 	`anchor'gend1		`anchor'gend0			///
			`anchor'ageb1		`anchor'ageb0			///
			`anchor'expb1		`anchor'expb0			///
			`anchor'gg_above1			`anchor'gg_above0	filter			
			
	*generating concatenated variable for all average bias by categories		
	egen 	`anchor'_dem=rowtotal(`anchor'*1 `anchor'*0)	

	*generating a label variable with all category names		
	gen 	dem_name =	""
	replace dem_name = "Female" 				if 	`anchor'gend1	///
												==	`anchor'_dem 	
	replace dem_name = "Female" 					if 	`anchor'gend0	///
												==	`anchor'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`anchor'ageb1	///
												==	`anchor'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`anchor'ageb0	///
												==	`anchor'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`anchor'expb1	///
												==	`anchor'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`anchor'expb0	///
												==	`anchor'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`anchor'gg_above1		///
												==	`anchor'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`anchor'gg_above0		///
												==	`anchor'_dem 	
	format `anchor'_dem %9.2f
	encode dem_name, gen(dem_name_n)	
	drop 	dem_name
	ren dem_name_n dem_name



*generating the graph
sort 	dem_name										
twoway 	(scatter `anchor'_dem dem_name if filter==1, 						///
					mlabel(`anchor'_dem) mlabposition(3) mcolor(dkblue)	///
					legend(label(1 "Yes"))	mlabsize(vsmall))			///
		(scatter `anchor'_dem dem_name if filter==0, 						///
					mlabel(`anchor'_dem) mlabposition(3) mcolor(red)		///
					legend(label(2 "No")) mlabsize(vsmall)),			///			
	xlabel(1 "Above 10 Exp?" 2 "Above 40 Age?" 3 "Above GG Grade?" 4 "Female?", angle(0))		///
	legend() xtitle("") graphregion(color(white)) bgcolor(white) 						///
	ytitle("Average $`anchor' Score") title( "$`anchor'", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export scatter_`anchor'_dem.png, as(png) name("Graph") replace
restore
}

********************************************************************************
*						PROPORTION OF AGILE SCORERS
********************************************************************************

********************************************************************************
*						WHAT ARE THE DETERMINANTS OF HIGH SCORES
********************************************************************************
global dimension peoplescore_sd solutionsscore_sd innovationscore_sd growthscore_sd agilityscore_sd
global dimensionstrength strengthpeople strengthsolutions strengthinnovation strengthgrowth

*AVERAGE DIMENSION SCORES 
grstyle init
grstyle set plain, horizontal
grstyle set color Accent: p#bar p#barline
grstyle set intensity 40: bar

preserve
foreach var of global dimension {
egen med_`var' = median(`var')
tab med_`var'
*people 68.75 , solutions 75, innovation 71.15, growth 75, agility 72.96
}

graph box $dimension,															///
	yvaroptions(relabel(1 "People" 		2 "Solutions"							///
						3 "Innovation"	4 "Growth"	5 "Overall Agility"))		///						
	ylabel(40(10)100) outergap(20) bargap(30) showyvars legend(off) nooutsides 	///	
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
restore

*PROPORTION OF STRENGTHS IN EACH CATEGORY
grstyle init
grstyle set plain, horizontal
grstyle set color Accent: p#pie p#pieline
grstyle set intensity 60: pie

graph pie $dimensionstrength,													///
	pie(1, color(green)) pie(2, color(edkblue)) pie(3, color(purple))			///
	pie(4, color(dkorange))	plabel(_all percent)								///
	legend(label(1 "People") label(2 "Solutions") label(3 "Innovation") label(4 "Growth"))			///
	graphregion(color(white)) bgcolor(white)									///
	title( "Proportion of Dimension Strengths", size(medium))					///
	note("Source: Data Collected from 311 users on the Work Behavior Tool", size(vsmall)) 									
graph export pie_strength_sd.png, as(png) name("Graph") replace

global peoplescore_sd "People Scores"
global solutionsscore_sd "Solutions Scores"
global innovationscore_sd "Innovation Scores"
global growthscore_sd "Growth Scores"
global agilityscore_sd "Agility Scores"

*GRAPH 2: Scatter plot of average dimension scores by demographics
********************************************************************************

*checking which demographic is statistically significant with dimensions
foreach dim of global dimension {
	preserve
	local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
	foreach var of local score {
		reg  `dim' `var', robust
		estimates store `var'
}

	*significant agility: ageb usk motiv_sd ip_sd
	*significant growth: gg_above gender usk motiv_sd ip_sd
	*significant innovation: usk ip_sd
	*significant solutions: usk motiv_sd ip_sd
	*Significant people: ageb usk motiv_sd ip_sd

	*generating variables for each demographic category for bias
	local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
	foreach var of local score {
		egen `dim'`var'1 	= mean(`dim') if `var'==1
		sort `dim'`var'1
		replace `dim'`var'1 = . if _n!=1
		egen `dim'`var'0		= mean(`dim') if `var'==0
		sort `dim'`var'0
		replace `dim'`var'0 = . if _n!=3
}

*Truncating the dataset to only include the mean bias by each category
	keep if `dim'gend1		!=.	|	`dim'gend0		!=.	|	///
			`dim'ageb1		!=.	|	`dim'ageb0		!=.	|	///
			`dim'expb1		!=.	|	`dim'expb0		!=.	|	///
			`dim'gg_above1			!=.	|	`dim'gg_above0			!=.	|	///
			`dim'ip_sd1		!=.	|	`dim'ip_sd0		!=.	|	///
			`dim'motiv_sd1			!=.	|	`dim'motiv_sd0			!=.	|	///
			`dim'usk_sd1		!=.	|	`dim'usk_sd0		!=.				

			
	*Generating filter variable for bias in each category
	gen 	filter = 1 if 	`dim'gend1		!=.	| `dim'ageb1	!=.	|	///
							`dim'expb1		!=.	| `dim'gg_above1	!=.	|	///
							`dim'ip_sd1		!=.	| `dim'motiv_sd1	!=.	|	///
							`dim'usk_sd1		!=.				
							
	replace filter = 0 if 	`dim'gend0		!=.	| `dim'ageb0	!=.	|	///
							`dim'expb0		!=.	| `dim'gg_above0	!=. |	///
							`dim'ip_sd0		!=.	| `dim'motiv_sd0	!=.	|	///
							`dim'usk_sd0		!=.		
							
	*keeping only the variables needed for the chart
	keep 	`dim'gend1		`dim'gend0			///
			`dim'ageb1		`dim'ageb0			///
			`dim'expb1		`dim'expb0			///
			`dim'gg_above1			`dim'gg_above0				///
			`dim'ip_sd1		`dim'ip_sd0			///
			`dim'motiv_sd1			`dim'motiv_sd0				///
			`dim'usk_sd1		`dim'usk_sd0		filter			
			
	*generating concatenated variable for all average bias by categories		
	egen 	`dim'_dem=rowtotal(`dim'*1 `dim'*0)	

	*generating a label variable with all category names		
	gen 	dem_name =	""
	replace dem_name = "Female" 				if 	`dim'gend1	///
												==	`dim'_dem 	
	replace dem_name = "Female" 					if 	`dim'gend0	///
												==	`dim'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`dim'ageb1	///
												==	`dim'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`dim'ageb0	///
												==	`dim'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`dim'expb1	///
												==	`dim'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`dim'expb0	///
												==	`dim'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`dim'gg_above1		///
												==	`dim'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`dim'gg_above0		///
												==	`dim'_dem 	
	replace dem_name = "Helpful Int Proc" 		if 	`dim'ip_sd1	///
												==	`dim'_dem 	
	replace dem_name = "Helpful Int Proc" 		if 	`dim'ip_sd0	///
												==	`dim'_dem 	
	replace dem_name = "Motivation" 			if 	`dim'motiv_sd1		///
												==	`dim'_dem 	
	replace dem_name = "Motivation" 			if 	`dim'motiv_sd0		///
												==	`dim'_dem 	
	replace dem_name = "Uses Core Skills" 		if 	`dim'usk_sd1	///
												==	`dim'_dem 	
	replace dem_name = "Uses Core Skills" 		if 	`dim'usk_sd0	///
												==	`dim'_dem 	
	format `dim'_dem %9.2f
	encode dem_name, gen(dem_name_n)	
	drop 	dem_name
	ren dem_name_n dem_name

*generating the graph
sort 	dem_name										
twoway 	(scatter `dim'_dem dem_name if filter==1, 						///
					mlabel(`dim'_dem) mlabposition(3) mcolor(dkblue)	///
					legend(label(1 "Yes"))	mlabsize(vsmall))			///
		(scatter `dim'_dem dem_name if filter==0, 						///
					mlabel(`dim'_dem) mlabposition(3) mcolor(red)		///
					legend(label(2 "No")) mlabsize(vsmall)),			///			
	xlabel(1 "Above 10 Exp?" 2 "Above 40 Age?" 3 "Above GG Grade?" 4 "Female?"	///
			5 "Helpful Int Proc?" 6 "Motivated?" 7 "Use Skills?", angle(30))		///
	legend() xtitle("") graphregion(color(white)) bgcolor(white) 						///
	ytitle("Average $`dim'") title( "$`dim'", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export scatter_`dim'_dem.png, as(png) name("Graph") replace
restore
}

*********************************************************************************
*						SKILLS MATCHING WITH DIMENSION SCORES
*********************************************************************************
grstyle init
grstyle set plain, horizontal
grstyle set color Accent: p#bar p#barline
grstyle set intensity 40: bar


graph hbar (mean) skills_*p, 																///
	yvaroptions(relabel(1	"Project Design"	2 	"Project Management and Implementation" ///
						3	"Research and Analysis"		4	"Monitoring and Evaluation"		///
						5	"Resource Management and Budget"	6	"Writing and Editing" 	///
						7	"Capacity Building" 	8	"Legal Counsel and Analysis" 		///
						9	"Client Engagement" 	10	"Data Analysis and Statistical Programming"	///
						11	"Strategy and Policy Dialogue"	12	"Information Technology" 	///
						13	"Financial Analysis" 	14	"Administrative Assistance" 		///
						15	"Event Management"	16	"Media and Strategic Communications"	///
						17	"Team Management"	18	"Human Resources Management" 			///
						19	"Training"	20	"Team Player"))									///			
	ylabel(0(10)60)outergap(20) bargap(30) showyvars legend(off) nooutsides 				///	
	ytitle("Percent of Respondents", size(small))	blabel(bar, format(%9.2f))				///
	graphregion(color(white)) bgcolor(white) title( "Core Skills", size(medium))			///
	note("Source: Data Collected from 334 users on the Work Behavior Tool", size(vsmall)) 
graph export avg_skills_sd.png, as(png) name("Graph") replace

*GRAPH 2: Scatter plot of average dimension scores by top skills
********************************************************************************

*checking which demographic is statistically significant with dimensions
foreach dim of global dimension {
	preserve
	local score skills_2 skills_9 skills_6 skills_3 skills_11 skills_17  skills_1 ///
				skills_20 skills_14 skills_7 
	foreach var of local score {
		reg  `dim' `var', robust
		estimates store `var'
}

	*significant agility: 20, 18
	*significant growth: 18, 17, 11
	*significant innovation: 20, 14, 5, 
	*significant solutions: 20, 18, 14, 
	*Significant people: 10, 
	*significant skills: 5, 10, 11, 14, 17, 18, 20
	*generating variables for each demographic category for bias
	local score skills_2 skills_9 skills_6 skills_3 skills_11 skills_17  skills_1 ///
				skills_20 skills_14 skills_7 
	foreach var of local score {
		egen `dim'`var'_1 	= mean(`dim') if `var'==1
		sort `dim'`var'_1
		replace `dim'`var'_1 = . if _n!=1
		egen `dim'`var'_0		= mean(`dim') if `var'==0
		sort `dim'`var'_0
		replace `dim'`var'_0 = . if _n!=3
}

*Truncating the dataset to only include the mean bias by each category
	keep if `dim'skills_2_1			!=.	|	`dim'skills_2_0		!=.	|	///
			`dim'skills_9_1			!=.	|	`dim'skills_9_0		!=.	|	///
			`dim'skills_6_1			!=.	|	`dim'skills_6_0		!=.	|	///
			`dim'skills_3_1			!=.	|	`dim'skills_3_0		!=.	|	///
			`dim'skills_11_1		!=.	|	`dim'skills_11_0	!=.	|	///
			`dim'skills_17_1		!=.	|	`dim'skills_17_0	!=.	|	///
			`dim'skills_1_1			!=.	|	`dim'skills_1_0		!=.	|	///
			`dim'skills_20_1		!=.	|	`dim'skills_20_0	!=.	|	///			
			`dim'skills_14_1		!=.	|	`dim'skills_14_0	!=.	|	///
			`dim'skills_7_1			!=.	|	`dim'skills_7_0		!=.			
			
	*Generating filter variable for bias in each category
	gen 	filter = 1 if 	`dim'skills_2_1		!=.	| `dim'skills_9_1	!=.	|	///
							`dim'skills_6_1		!=.	| `dim'skills_3_1	!=.	|	///
							`dim'skills_11_1	!=.	| `dim'skills_17_1	!=.	|	///
							`dim'skills_1_1		!=.	| `dim'skills_20_1	!=.	|	///
							`dim'skills_14_1	!=.	| `dim'skills_7_1	!=.	 
							
	replace filter = 0 if 	`dim'skills_2_0		!=.	| `dim'skills_9_0	!=.	|	///
							`dim'skills_6_0		!=.	| `dim'skills_3_0	!=.	|	///
							`dim'skills_11_0	!=.	| `dim'skills_17_0	!=.	|	///
							`dim'skills_1_0		!=.	| `dim'skills_20_0	!=.	|	///
							`dim'skills_14_0	!=.	| `dim'skills_7_0	!=.	 
							
	*keeping only the variables needed for the chart
	keep 	`dim'skills_2_1	`dim'skills_2_0	`dim'skills_9_1	`dim'skills_9_0		///
			`dim'skills_6_1	`dim'skills_6_0	`dim'skills_3_1	`dim'skills_3_0		///
			`dim'skills_11_1 `dim'skills_11_0 `dim'skills_17_1 `dim'skills_17_0	///
			`dim'skills_1_1 `dim'skills_1_0	`dim'skills_20_1 `dim'skills_20_0	///			
			`dim'skills_14_1 `dim'skills_14_0 `dim'skills_7_1 `dim'skills_7_0 	filter	
			
	*generating concatenated variable for all average bias by categories		
	egen 	`dim'_skills=rowtotal(`dim'*1 `dim'*0)	

	*generating a label variable with all category names		
	gen 	skills_name =	""
	replace skills_name = "Project Management and Implementation" if 	`dim'skills_2_1		///
												==	`dim'_skills	
	replace skills_name = "Project Management and Implementation" if 	`dim'skills_2_0		///
												==	`dim'_skills 	
	replace skills_name = "Client Engagement" 	if 	`dim'skills_9_1	///
												==	`dim'_skills 	
	replace skills_name = "Client Engagement" 	if 	`dim'skills_9_0	///
												==	`dim'_skills 	
	replace skills_name = "Writing and Editing" if `dim'skills_6_1	///
												==	`dim'_skills 	
	replace skills_name = "Writing and Editing" if `dim'skills_6_0	///
												==	`dim'_skills 	
	replace skills_name = "Research and Analysis" 		if 	`dim'skills_3_1		///
												==	`dim'_skills 	
	replace skills_name = "Research and Analysis" 		if 	`dim'skills_3_0	///
												==	`dim'_skills 	
	replace skills_name = "Strategy and Policy Dialogue" 		if 	`dim'skills_11_1	///
												==	`dim'_skills 	
	replace skills_name = "Strategy and Policy Dialogue" 		if 	`dim'skills_11_0	///
												==	`dim'_skills 	
	replace skills_name = "Team Management" 			if 	`dim'skills_17_1		///
												==	`dim'_skills 	
	replace skills_name = "Team Management" 			if 	`dim'skills_17_0		///
												==	`dim'_skills 	
	replace skills_name = "Project Design" 		if 	`dim'skills_1_1	///
												==	`dim'_skills 	
	replace skills_name = "Project Design" 		if 	`dim'skills_1_0	///
												==	`dim'_skills 	
	replace skills_name = "Team Player" 		if 	`dim'skills_20_1	///
												==	`dim'_skills 	
	replace skills_name = "Team Player" 		if 	`dim'skills_20_0	///
												==	`dim'_skills 	
	replace skills_name = "Administrative Assistance" 			if 	`dim'skills_14_1		///
												==	`dim'_skills 	
	replace skills_name = "Administrative Assistance" 			if 	`dim'skills_14_0		///
												==	`dim'_skills 	
	replace skills_name = "Capacity Building" 		if 	`dim'skills_7_1	///
												==	`dim'_skills 	
	replace skills_name = "Capacity Building" 		if 	`dim'skills_7_0	///
												==	`dim'_skills 	
											
	format `dim'_skills %9.2f
	encode skills_name, gen(skills_name_n)	
	drop 	skills_name
	ren skills_name_n skills_name

*generating the graph
sort 	skills_name										
twoway 	(scatter `dim'_skills skills_name if filter==1, 						///
					mlabel(`dim'_skills) mlabposition(3) mcolor(dkblue)	///
					legend(label(1 "Yes"))	mlabsize(vsmall))			///
		(scatter `dim'_skills skills_name if filter==0, 						///
					mlabel(`dim'_skills) mlabposition(3) mcolor(red)		///
					legend(label(2 "No")) mlabsize(vsmall)),			///			
	xlabel(	1 "Project Mngmt?" 2 "Client Engagement?" 3 "Writing?" 4 "R&A?" 	///
			5 "Strategy/Policy?" 6 "Team Mngmt?" 7 "Project Design?" ///
			8 "Team Player?" 9 "Admin Assistance?" 10 "Capacity Building?", angle(30))		///
	legend() xtitle("") graphregion(color(white)) bgcolor(white) 						///
	ytitle("Average $`dim'") title( "$`dim'", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export scatter_`dim'_topskills.png, as(png) name("Graph") replace
restore
}
*********************************************************************************
*				OPERATIONAL MAPPING OF HIGH SCORERS
*********************************************************************************
cap noi reg peoplescore_sd i.region


********************************************************************************
*						ENABLING ENVIRONMENT
********************************************************************************
*set globals
global dimension_env peoplescore_env_sd solutionsscore_env_sd innovationscore_env_sd growthscore_env_sd agilityscore_env_sd
global dimension_trunc peoplescore_trunc_sd solutionsscore_trunc_sd innovationscore_trunc_sd growthscore_trunc_sd agilityscore_trunc_sd
global dimensions_env_trunc $dimension_env $dimension_trunc
global peoplescore_env_sd "People Environment"
global solutionsscore_env_sd "Solutions Environment"
global innovationscore_env_sd "Innovation Environment"
global growthscore_env_sd "Growth Environment"
global agilityscore_env_sd "Agility Environment"

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

*TTEST RESULTS
*Significant: peoplescore***, innovationscore***
preserve
gen allaverage = 1 
collapse (mean) peoplescore_env_sd solutionsscore_env_sd innovationscore_env_sd ///
				growthscore_env_sd peoplescore_trunc_sd	solutionsscore_trunc_sd ///
				innovationscore_trunc_sd growthscore_trunc_sd, by(allaverage)
rename (peoplescore_env_sd solutionsscore_env_sd innovationscore_env_sd growthscore_env_sd)	///
		(score_e1 score_e2 score_e3 score_e4)
rename (peoplescore_trunc_sd solutionsscore_trunc_sd innovationscore_trunc_sd growthscore_trunc_sd)	///
		(score_t1 score_t2 score_t3 score_t4)		
reshape long score_e score_t, i(allaverage) j(score_name)

label define score_namelbl	1 "People" 		2 "Solutions"						///
							3 "Innovation" 	4 "Growth"
label values score_name score_namelbl
format score_e score_t %9.1f
sort score_name
twoway 	(scatter score_name score_e, mlabel(score_e) mlabposition(12) mcolor(dkblue))							///
		(scatter score_name score_t, mlabel(score_t) mlabposition(6) mcolor(red)), 							///
	legend(label(1 "Environment Scores") label(2 "Personal (Truncated) Scores"))									///
	ylabel(1 "People" 2 "Solutions" 3 "Innovation" 4 "Growth", angle(90))		///
	xlabel(50(5)70) xtitle("Average Scores") yline(1, lpattern(dash) lcolor(black)) ///
	yline(3, lpattern(dash) lcolor(black))	 	///
	graphregion(color(white)) bgcolor(white) ytitle("Dimension")				///s
	title( "Environment vs Personal Scores", size(medium))						///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export diff_env_personal_sd.png, as(png) name("Graph") replace
restore

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
	title("Effect of Environment on Personal Scores")	ylabel(0(0.1)0.5)		///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export coef_env_personal_sd.png, as(png) name("Graph") replace

*MARGINAL EFFECTS FOR AGILITY
reg agilityscore_sd agilityscore_env_sd, robust
margins, at(agilityscore_env_sd=(0(20)100)) post
estimates store agilityscore
coefplot (agilityscore, at recast(line))												///
		(agilityscore, at recast(scatter) mlabel mlabcolor(black)	///
		mlabposition(4)), 	format(%9.2f)	legend(off)		///
		ytitle(Personal Scores) xtitle(Environment Scores) 		///
title("Marginal Effect of Agile Environment on Personal Agile Scores", size(medium))	
graph export env_personal_margins.png, as(png) name("Graph") replace

*checking which demographic is statistically significant with environment dimensions
foreach dim of global dimension_env {
	preserve
	local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
	foreach var of local score {
		reg  `dim' `var', robust
		estimates store `var'
}

	*significant agility: ageb usk motiv_sd ip_sd
	*significant growth: usk motiv_sd ip_sd
	*significant innovation: usk motiv_sd ip_sd
	*significant solutions: ageb usk motiv_sd ip_sd
	*Significant people: ageb usk motiv_sd ip_sd

	*generating variables for each demographic category for bias
	local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
	foreach var of local score {
		egen `dim'`var'1 	= mean(`dim') if `var'==1
		sort `dim'`var'1
		replace `dim'`var'1 = . if _n!=1
		egen `dim'`var'0		= mean(`dim') if `var'==0
		sort `dim'`var'0
		replace `dim'`var'0 = . if _n!=3
}

*Truncating the dataset to only include the mean bias by each category
	keep if `dim'gend1		!=.	|	`dim'gend0		!=.	|	///
			`dim'ageb1		!=.	|	`dim'ageb0		!=.	|	///
			`dim'expb1		!=.	|	`dim'expb0		!=.	|	///
			`dim'gg_above1			!=.	|	`dim'gg_above0			!=.	|	///
			`dim'ip_sd1		!=.	|	`dim'ip_sd0		!=.	|	///
			`dim'motiv_sd1			!=.	|	`dim'motiv_sd0			!=.	|	///
			`dim'usk_sd1		!=.	|	`dim'usk_sd0		!=.				

			
	*Generating filter variable for bias in each category
	gen 	filter = 1 if 	`dim'gend1		!=.	| `dim'ageb1	!=.	|	///
							`dim'expb1		!=.	| `dim'gg_above1	!=.	|	///
							`dim'ip_sd1		!=.	| `dim'motiv_sd1	!=.	|	///
							`dim'usk_sd1		!=.				
							
	replace filter = 0 if 	`dim'gend0		!=.	| `dim'ageb0	!=.	|	///
							`dim'expb0		!=.	| `dim'gg_above0	!=. |	///
							`dim'ip_sd0		!=.	| `dim'motiv_sd0	!=.	|	///
							`dim'usk_sd0		!=.		
							
	*keeping only the variables needed for the chart
	keep 	`dim'gend1		`dim'gend0			///
			`dim'ageb1		`dim'ageb0			///
			`dim'expb1		`dim'expb0			///
			`dim'gg_above1			`dim'gg_above0				///
			`dim'ip_sd1		`dim'ip_sd0			///
			`dim'motiv_sd1			`dim'motiv_sd0				///
			`dim'usk_sd1		`dim'usk_sd0		filter			
			
	*generating concatenated variable for all average bias by categories		
	egen 	`dim'_dem=rowtotal(`dim'*1 `dim'*0)	

	*generating a label variable with all category names		
	gen 	dem_name =	""
	replace dem_name = "Female" 				if 	`dim'gend1	///
												==	`dim'_dem 	
	replace dem_name = "Female" 					if 	`dim'gend0	///
												==	`dim'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`dim'ageb1	///
												==	`dim'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`dim'ageb0	///
												==	`dim'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`dim'expb1	///
												==	`dim'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`dim'expb0	///
												==	`dim'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`dim'gg_above1		///
												==	`dim'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`dim'gg_above0		///
												==	`dim'_dem 	
	replace dem_name = "Helpful Int Proc" 		if 	`dim'ip_sd1	///
												==	`dim'_dem 	
	replace dem_name = "Helpful Int Proc" 		if 	`dim'ip_sd0	///
												==	`dim'_dem 	
	replace dem_name = "Motivation" 			if 	`dim'motiv_sd1		///
												==	`dim'_dem 	
	replace dem_name = "Motivation" 			if 	`dim'motiv_sd0		///
												==	`dim'_dem 	
	replace dem_name = "Uses Core Skills" 		if 	`dim'usk_sd1	///
												==	`dim'_dem 	
	replace dem_name = "Uses Core Skills" 		if 	`dim'usk_sd0	///
												==	`dim'_dem 	
	format `dim'_dem %9.2f
	encode dem_name, gen(dem_name_n)	
	drop 	dem_name
	ren dem_name_n dem_name

*generating the graph
sort 	dem_name										
twoway 	(scatter `dim'_dem dem_name if filter==1, 						///
					mlabel(`dim'_dem) mlabposition(3) mcolor(dkblue)	///
					legend(label(1 "Yes"))	mlabsize(vsmall))			///
		(scatter `dim'_dem dem_name if filter==0, 						///
					mlabel(`dim'_dem) mlabposition(3) mcolor(red)		///
					legend(label(2 "No")) mlabsize(vsmall)),			///			
	xlabel(1 "Above 10 Exp?" 2 "Above 40 Age?" 3 "Above GG Grade?" 4 "Female?"	///
			5 "Helpful Int Proc?" 6 "Motivated?" 7 "Use Skills?", angle(30))		///
	legend() xtitle("") graphregion(color(white)) bgcolor(white) 						///
	ytitle("Average $`dim'") title( "$`dim'", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export scatter_`dim'_dem.png, as(png) name("Graph") replace
restore
}


/********************************************************************************
*				ITEM CORRELATES WITH TOP PERCENTILE IN EACH DIMENSION
********************************************************************************
global dimension30p 		peoplescore_sd30p solutionsscore_sd30p 	///
							innovationscore_sd30p growthscore_sd30p 	///
							agilityscore_sd30p
global peoplescore_sd30p "People"
global solutionsscore_sd30p "Solutions"
global innovationscore_sd30p "Innovation"
global growthscore_sd30p "Growth"
global agilityscore_sd30p "Agility"

foreach dim of global dimension {
	preserve
	local score score1_sd score2_sd score3_sd score4_sd score5_sd score6_sd 	///
				score7_sd score8_sd score9_sd score10_sd score11_sd score12_sd  ///
				score48_sd score49_sd score50_sd score51_sd
	foreach var of local score {
		reg  people `var', robust
		estimates store `var'
}
}

reg peoplescore_sd30p score1_sd score2_sd score3_sd score4_sd score5_sd score6_sd 	///
				score7_sd score8_sd score9_sd score10_sd score11_sd score12_sd  ///
				score48_sd score49_sd score50_sd score51_sd
/********************************************************************************
*								ANNEX SLIDES
********************************************************************************

*GRAPH 2: Scatter plot of average dimension scores by other statistically significant skills
********************************************************************************

*checking which demographic is statistically significant with dimensions
foreach dim of global dimension {
	preserve
	local score skills_1 skills_2 skills_3 skills_4 skills_5 skills_6 skills_7 	///
				skills_8 skills_9 skills_10 skills_11 skills_12 skills_13  skills_14 ///
				skills_15 skills_16 skills_17 skills_18 skills_19 skills_20  
	foreach var of local score {
		reg  `dim' `var', robust
		estimates store `var'
}

	local score skills_5 skills_10 skills_18
	foreach var of local score {
		egen `dim'`var'_1 	= mean(`dim') if `var'==1
		sort `dim'`var'_1
		replace `dim'`var'_1 = . if _n!=1
		egen `dim'`var'_0		= mean(`dim') if `var'==0
		sort `dim'`var'_0
		replace `dim'`var'_0 = . if _n!=3
}

*Truncating the dataset to only include the mean bias by each category
	keep if `dim'skills_5_1			!=.	|	`dim'skills_5_0		!=.	|	///
			`dim'skills_10_1		!=.	|	`dim'skills_10_0	!=.	|	///
			`dim'skills_18_1		!=.	|	`dim'skills_18_0	!=.		

			
	*Generating filter variable for bias in each category
	gen 	filter = 1 if `dim'skills_5_1!=. | `dim'skills_10_1!=. | `dim'skills_18_1!=.			
							
	replace	filter = 0 if `dim'skills_5_0!=. | `dim'skills_10_0!=. | `dim'skills_18_0!=.			
							
	*keeping only the variables needed for the chart
	keep	`dim'skills_5_1	`dim'skills_5_0	`dim'skills_10_1 `dim'skills_10_0	///
			`dim'skills_18_1 `dim'skills_18_0	filter
			
	*generating concatenated variable for all average bias by categories		
	egen 	`dim'_skills=rowtotal(`dim'*1 `dim'*0)	

	*generating a label variable with all category names		
	gen 	skills_name =	""
	replace skills_name = "Resource Management and Budget" 	if 	`dim'skills_5_1	///
												==	`dim'_skills 	
	replace skills_name = "Resource Management and Budget" 	if 	`dim'skills_5_0	///
												==	`dim'_skills 	
	replace skills_name = "Data Analysis and Statistical Programming" if `dim'skills_10_1	///
												==	`dim'_skills 	
	replace skills_name = "Data Analysis and Statistical Programming" if `dim'skills_10_0	///
												==	`dim'_skills 	
	replace skills_name = "Human Resources Management" 			if 	`dim'skills_18_1		///
												==	`dim'_skills 	
	replace skills_name = "Human Resources Management" 			if 	`dim'skills_18_0		///
												==	`dim'_skills 	
	format `dim'_skills %9.2f
	encode skills_name, gen(skills_name_n)	
	drop 	skills_name
	ren skills_name_n skills_name

*generating the graph
sort 	skills_name										
twoway 	(scatter `dim'_skills skills_name if filter==1, 						///
					mlabel(`dim'_skills) mlabposition(3) mcolor(dkblue)	///
					legend(label(1 "Yes"))	mlabsize(vsmall))			///
		(scatter `dim'_skills skills_name if filter==0, 						///
					mlabel(`dim'_skills) mlabposition(3) mcolor(red)		///
					legend(label(2 "No")) mlabsize(vsmall)),			///			
	xlabel(1 "RM and Budget?" 2 "Data Analysis?" 3 "HRM?" 4 "Female?", angle(30))		///
	legend() xtitle("") graphregion(color(white)) bgcolor(white) 						///
	ytitle("Average $`dim'") title( "$`dim'", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export scatter_`dim'_otherskills.png, as(png) name("Graph") replace
restore
}

********************************************************************************
*						WHAT ARE THE DETERMINANTS OF HIGH PERCENTILE
********************************************************************************

*GRAPH 2: Scatter plot of average dimension scores by demographics
********************************************************************************

*checking which demographic is statistically significant with dimensions
foreach dim of global dimension30p {
	preserve
	local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
	foreach var of local score {
		reg  `dim' `var', robust
		estimates store `var'
}

	*significant agility: usk
	*significant growth: usk motiv_sd ip_sd gend
	*significant innovation: 
	*significant solutions: usk motiv_sd 
	*Significant people: motiv_sd gg_above ageb

	*generating variables for each demographic category for bias
	local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
	foreach var of local score {
		egen `dim'`var'1 	= mean(`dim') if `var'==1
		sort `dim'`var'1
		replace `dim'`var'1 = . if _n!=1
		egen `dim'`var'0		= mean(`dim') if `var'==0
		sort `dim'`var'0
		replace `dim'`var'0 = . if _n!=3
}

*Truncating the dataset to only include the mean bias by each category
	keep if `dim'gend1		!=.	|	`dim'gend0		!=.	|	///
			`dim'ageb1		!=.	|	`dim'ageb0		!=.	|	///
			`dim'expb1		!=.	|	`dim'expb0		!=.	|	///
			`dim'gg_above1			!=.	|	`dim'gg_above0			!=.	|	///
			`dim'ip_sd1		!=.	|	`dim'ip_sd0		!=.	|	///
			`dim'motiv_sd1			!=.	|	`dim'motiv_sd0			!=.	|	///
			`dim'usk_sd1		!=.	|	`dim'usk_sd0		!=.				

			
	*Generating filter variable for bias in each category
	gen 	filter = 1 if 	`dim'gend1		!=.	| `dim'ageb1	!=.	|	///
							`dim'expb1		!=.	| `dim'gg_above1	!=.	|	///
							`dim'ip_sd1		!=.	| `dim'motiv_sd1	!=.	|	///
							`dim'usk_sd1		!=.				
							
	replace filter = 0 if 	`dim'gend0		!=.	| `dim'ageb0	!=.	|	///
							`dim'expb0		!=.	| `dim'gg_above0	!=. |	///
							`dim'ip_sd0		!=.	| `dim'motiv_sd0	!=.	|	///
							`dim'usk_sd0		!=.		
							
	*keeping only the variables needed for the chart
	keep 	`dim'gend1		`dim'gend0			///
			`dim'ageb1		`dim'ageb0			///
			`dim'expb1		`dim'expb0			///
			`dim'gg_above1			`dim'gg_above0				///
			`dim'ip_sd1		`dim'ip_sd0			///
			`dim'motiv_sd1			`dim'motiv_sd0				///
			`dim'usk_sd1		`dim'usk_sd0		filter			
			
	*generating concatenated variable for all average bias by categories		
	egen 	`dim'_dem=rowtotal(`dim'*1 `dim'*0)	

	*generating a label variable with all category names		
	gen 	dem_name =	""
	replace dem_name = "Female" 				if 	`dim'gend1	///
												==	`dim'_dem 	
	replace dem_name = "Female" 					if 	`dim'gend0	///
												==	`dim'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`dim'ageb1	///
												==	`dim'_dem 	
	replace dem_name = "Above 40 Age" 			if 	`dim'ageb0	///
												==	`dim'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`dim'expb1	///
												==	`dim'_dem 	
	replace dem_name = "Above 10 Exp" 			if 	`dim'expb0	///
												==	`dim'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`dim'gg_above1		///
												==	`dim'_dem 	
	replace dem_name = "Above GG Grade" 		if 	`dim'gg_above0		///
												==	`dim'_dem 	
	replace dem_name = "Helpful Int Proc" 		if 	`dim'ip_sd1	///
												==	`dim'_dem 	
	replace dem_name = "Helpful Int Proc" 		if 	`dim'ip_sd0	///
												==	`dim'_dem 	
	replace dem_name = "Motivation" 			if 	`dim'motiv_sd1		///
												==	`dim'_dem 	
	replace dem_name = "Motivation" 			if 	`dim'motiv_sd0		///
												==	`dim'_dem 	
	replace dem_name = "Uses Core Skills" 		if 	`dim'usk_sd1	///
												==	`dim'_dem 	
	replace dem_name = "Uses Core Skills" 		if 	`dim'usk_sd0	///
												==	`dim'_dem 	
	format `dim'_dem %9.2f
	encode dem_name, gen(dem_name_n)	
	drop 	dem_name
	ren dem_name_n dem_name

*generating the graph
sort 	dem_name										
twoway 	(scatter `dim'_dem dem_name if filter==1, 						///
					mlabel(`dim'_dem) mlabposition(3) mcolor(dkblue)	///
					legend(label(1 "Yes"))	mlabsize(vsmall))			///
		(scatter `dim'_dem dem_name if filter==0, 						///
					mlabel(`dim'_dem) mlabposition(3) mcolor(red)		///
					legend(label(2 "No")) mlabsize(vsmall)),			///			
	xlabel(1 "Above 10 Exp?" 2 "Above 40 Age?" 3 "Above GG Grade?" 4 "Female?"	///
			5 "Helpful Int Proc?" 6 "Motivated?" 7 "Use Skills?", angle(30))		///
	legend() xtitle("") graphregion(color(white)) bgcolor(white) 						///
	ytitle("Average $`dim'") title( "$`dim'", size(medium))				///
	note("Source: Data Collected from Work Behavior Tool", size(vsmall)) 
graph export scatter_`dim'_dem.png, as(png) name("Graph") replace
restore
}



/*AGILITY SCORES

local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
foreach var of local score {
reg  agilityscore_sd `var', robust
estimates store `var'
}
coefplot 	(gend, label(Female))									///
			(ageb, label(Age>=40))							///
			(expb, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(ip_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(usk_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
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
local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
foreach var of local score {
reg  peoplescore_sd `var', robust
estimates store `var'
}
coefplot 	(gend, label(Female))									///
			(ageb, label(Age>=40))							///
			(expb, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(ip_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(usk_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
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
local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
foreach var of local score {
reg  solutionsscore_sd `var', robust
estimates store `var'
}
coefplot 	(gend, label(Female))									///
			(ageb, label(Age>=40))							///
			(expb, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(ip_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(usk_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
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
local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
foreach var of local score {
reg  innovationscore_sd `var', robust
estimates store `var'
}
coefplot 	(gend, label(Female))									///
			(ageb, label(Age>=40))							///
			(expb, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(ip_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(usk_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
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
local score gend ageb expb gg_above ip_sd motiv_sd usk_sd
foreach var of local score {
reg  growthscore_sd `var', robust
estimates store `var'
}
coefplot 	(gend, label(Female))									///
			(ageb, label(Age>=40))							///
			(expb, label(Experience>=10))							///
			(gg_above, label(>=GG Grade))										///
			(ip_sd, label(Helpful Internal Proc))							///
			(motiv_sd, label(Motivated))											///
			(usk_sd, label(Uses Core Skills)), drop(_cons) yline(0) 			///
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



