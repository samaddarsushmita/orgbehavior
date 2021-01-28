
/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   					  TEAM CLEANING DO								   *
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
	*              CLEANING TEAM MASTER FILE                                  *
	****************************************************************************


	import delimited "$onedriveRaw\team.csv", clear
	ren ïproj_id ProjectID
	save "$onedrive\Intermediate\team.dta", replace

use "$onedrive\Intermediate\team.dta", clear

ren (upi_nbr upi_start_date upi_end_date upi_role) (UPI From To Position)

sort UPI
drop if UPI==.|UPI==99000000

local dates From To

*sorting dates
	foreach x of local dates {
		cap noi gen `x'n=date(`x', "MDY")
		cap noi format `x'n %td
		cap noi drop `x'
		cap noi rename `x'n `x'
	}
	
*dropping UPIs that are not Members or Team Leaders
sum if Position!="MEMBER" | Position!="TEAMLEAD" 
keep if Position=="MEMBER" | Position=="TEAMLEAD" 

save "$onedrive\Intermediate\team_v2.dta", replace

