
/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   					  	IEG CLEANING DO								   *
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

*-------------------------------------------------------------------------------


	****************************************************************************
	*              CLEANING IEG FILE                                           *
	****************************************************************************

import delimited "$onedriveRaw\IEG_World_Bank_Project_Performance_Ratings.csv", clear
ren ïprojectid ProjectID
save "$onedrive\Intermediate\ieg.dta", replace

use "$onedrive\Intermediate\ieg.dta", clear
tab ieg_outcome
rename (ieg_evaldate ieg_evalfy) (ieg_evaldate ieg_evalyear)
*GENERATING A VARIABLE TO SCORE THE IEG RATINGS
gen rating_ieg_code=1 if ieg_outcome=="Highly Satisfactory"
replace rating_ieg_code=2 if ieg_outcome=="Unsatisfactory"
replace rating_ieg_code=3 if ieg_outcome=="Moderately Unsatisfactory"
replace rating_ieg_code=4 if ieg_outcome=="Moderately Satisfactory"
replace rating_ieg_code=5 if ieg_outcome=="Satisfactory"
replace rating_ieg_code=6 if ieg_outcome=="Highly Satisfactory"
replace rating_ieg_code=0 if ieg_outcome=="Not Applicable"
replace rating_ieg_code=0 if ieg_outcome=="Not Available"
replace rating_ieg_code=0 if ieg_outcome=="Not Rated"

bysort ProjectID: egen totalscore=count(rating_ieg_code) if rating_ieg_code!=0|rating_ieg_code!=.
replace totalscore=totalscore*6
bysort ProjectID: egen iegrating=sum(rating_ieg_code)
replace iegrating=(iegrating/totalscore)*6
keep ProjectID ieg_outcome ieg_evaldate ieg_evalyear ieg_bankqualityatentry ieg_bankqualityofsupervision ieg_overallbankperf ieg_implementingagencyperf ieg_governmentperf ieg_overallborrperf ieg_icrquality discieg_sustainability ieg_mequality iegrating

save "$onedrive\Intermediate\ieg_v2.dta", replace
