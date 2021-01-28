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
	
	local 	staff	 		1	// 	Clean the staff dta
	
	local	team			1 	// 	Clean the team dta
	
	local	spending		1 	// 	Clean the spending dta

	local	isr				1 	// 	Clean the isr dta

	local	ieg				1 	// 	Clean the ieg dta

	
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
		global github2	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Admin Data\Dofiles\Construct"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Datasets"
		global onedriveRaw "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Encrypted\Raw Data"
	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
	
* ------------------------------------------------------------------------------
* 							Cleaning the Project Dta
* ------------------------------------------------------------------------------
*
* ------------------------------------------------------------------------------
	
	if `project'		do "$github\project_clean.do"
	
* ------------------------------------------------------------------------------
* 							Cleaning the staff dta
* ------------------------------------------------------------------------------
*
* ------------------------------------------------------------------------------
	
	if `staff'			do "$github\staff_clean.do"

* ------------------------------------------------------------------------------
* 							Cleaning the team dta
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
	
	if `team'			do "$github\team_clean.do"
	
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* 							Cleaning the spending dta
* ------------------------------------------------------------------------------
*
* ------------------------------------------------------------------------------
	
	if `spending'		do "$github\spending_clean.do"
	
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* 							Cleaning the isr dta
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
	
	if `isr'			do "$github\isr_clean.do"
	
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* 							Cleaning the ieg dta
* ------------------------------------------------------------------------------
*
*
* ------------------------------------------------------------------------------
	
	if `ieg'			do "$github\ieg_clean.do"
	
* ------------------------------------------------------------------------------
