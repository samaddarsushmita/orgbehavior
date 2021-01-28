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
									
	local	project			1	// 	Clean the project dta
	
	local 	staff	 		0	// 	Clean the staff dta
	
	local	team			0 	// 	Clean the team dta
	
	local	spending		0 	// 	Clean the spending dta

	local	isr				0 	// 	Clean the isr dta

	local	ieg				0 	// 	Clean the ieg dta

	
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
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data"
	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************

use "$onedrive\Datasets\Intermediate\project_master_v2", clear

keep if prod_line_type=="A"

keep if apprvl_fy >= 2005

tab output_type_nme


*Creating a category of outputs

local workshop `" "CAS Participation" "Clinic/Workshop" "Conference" "Course" "Global Dialogue" "Study Tour" "Training"  "Community of Practice" "Knowledge Sharing Forum" "Knowledge-Sharing Forum" "Global Dev Learning Network Ac" "Seminar"  "'

gen cat_output = ""

foreach x of local workshop {
	replace 	cat_output 				= 	"Workshop, Conference, Meeting" 	///
			if 	output_type_nme=="`x'"
}

local report `" "Policy Note" "Report" "Publication" "Model/Survey" "Advisory Services Document" "'

foreach x of local report {
	replace 	cat_output 				= 	"Report, Policy, Survey" 	///
			if 	output_type_nme=="`x'"
}

outsheet 	proj_legal_nme 														///	
			output_type_nme 													///
			apprvl_fy 															///
		if 	cat_output				==	"Report, Policy, Survey"				///
		using "$onedrive\Outputs\Raw\nameproj.xls", replace
/*Creating categories for the projects using name

list proj_legal_nme if regexm(proj_legal_nme, "Meeting") == 1

