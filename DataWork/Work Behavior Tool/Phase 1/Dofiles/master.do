/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   					  WBT DATA MASTER DO								   *
*   							   2019										   *
********************************************************************************
********************************************************************************
*						   SELECT PARTS TO RUN   							   *
********************************************************************************/
	
	* select which parts of this do-file to run
	local 	packages			0	// 	Install packages -- only needs to be ran 
									//	once in each computer
									
	local	cleaning			1	// 	Clean the datasets
	
	local 	construct	 		1	// 	Construct merged datasets 
	
	local	analysis			0 	// 	Descriptive Statistics
	
	
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
	
	ieboilstart, version(13.0)
	`r(version)'
	

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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Work Behavior Tool\Phase 1"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Phase 1\Datasets"
	}

	
 	* Subfolder globals
	* -----------------
	gl cleaning_do			"$github\Dofiles\Cleaning" 
	gl construct_do			"$github\Dofiles\Construct"
	gl analysis_do			"$github\Dofiles\Analysis"

	
		
********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
	
* ------------------------------------------------------------------------------
* 								Cleaning 
* ------------------------------------------------------------------------------
	
	if `cleaning'		{
		do "$cleaning_do\clean.do"
		do "$cleaning_do\pilot_clean.do"
	}
* ------------------------------------------------------------------------------
* 								Construct
* ------------------------------------------------------------------------------
	if `construct'	{
		do "$construct_do\construct.do"
		do "$construct_do\pilot_construct.do"
	}
	
* ------------------------------------------------------------------------------
* 							Decriptive statistics
* ------------------------------------------------------------------------------
	if `analysis'	do "$analysis_do\prelim_analysis.do"
	
*-------------------------------------------------------------------------------