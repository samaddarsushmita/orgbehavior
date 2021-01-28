
/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   					  	ISR CLEANING DO								   *
*   							   2019										   *
********************************************************************************/
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
	*              CLEANING ISR FILE                                           *
	****************************************************************************

	import delimited "$onedriveRaw\Project_ISR_All.csv", clear
	save "$onedrive\Intermediate\ISR_updated.dta", replace


use "$onedrive\Intermediate\ISR_updated.dta", clear
rename project_id ProjectID
tab rating_value_long_name

*GENERATING A VARIABLE TO SCORE THE RATINGS
gen rating_ISR_code=1 if rating_value_long_name=="Highly Unsatisfactory"
replace rating_ISR_code=2 if rating_value_long_name=="Unsatisfactory"
replace rating_ISR_code=3 if rating_value_long_name=="Moderately Unsatisfactory"
replace rating_ISR_code=4 if rating_value_long_name=="Moderately Satisfactory"
replace rating_ISR_code=5 if rating_value_long_name=="Satisfactory"
replace rating_ISR_code=6 if rating_value_long_name=="Highly Satisfactory"
replace rating_ISR_code=0 if rating_value_long_name=="Blank-Not Rated"
replace rating_ISR_code=0 if rating_value_long_name=="Not Applicable"
replace rating_ISR_code=0 if rating_value_long_name=="Not Reported"

bysort ProjectID: egen totalscore=count(rating_ISR_code) if rating_ISR_code!=0|rating_ISR_code!=.
replace totalscore=totalscore*6
bysort ProjectID: egen ISRrating_perc=sum(rating_ISR_code)
replace ISRrating_perc=(ISRrating_perc/totalscore)*6
gen risk_rating=3 if rating_medium_name=="Overall Implementation Risk" & rating_value_long_name=="High"
replace risk_rating=2 if rating_medium_name=="Overall Implementation Risk" & rating_value_long_name=="Moderate"
replace risk_rating=1 if rating_medium_name=="Overall Implementation Risk" & rating_value_long_name=="Low"
bysort ProjectID: egen risk_rating_n=max(risk_rating)
drop risk_rating
rename risk_rating_n risk_rating
collapse (first) ISRrating_perc risk_rating, by(ProjectID)

save "$onedrive\Intermediate\ISR_updated_v2.dta", replace

