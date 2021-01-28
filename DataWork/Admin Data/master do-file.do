/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   					  ADMIN DATA MASTER DO								   *
*   							   2019										   *
********************************************************************************
********************************************************************************
*						   SELECT PARTS TO RUN   							   *
********************************************************************************/
	
	* select which parts of this do-file to run
	local 	packages			1	// 	Install packages -- only needs to be ran 
									//	once in each computer
									
	local	cleaning			1	// 	Clean the datasets
	
	local 	construct	 		1	// 	Construct merged datasets 
	
	local	analysis			1 	// 	Descriptive Statistics
	
	
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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Admin Data"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data"
	}

	
	
 	* Subfolder globals
	* -----------------
	gl cleaning_do			"$github/Do-files/Cleaning" 
	gl construct_do			"$github/Do-files/Construct"
	gl analysis_do			"$github/Do-files/Analysis"

	
		
********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
	
* ------------------------------------------------------------------------------
* 								Cleaning 
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	$analysis_dt\hhwater_plotcropgs.dta
*				$masterdata/master_hh.dta

* 	CREATES:	$out_bal/attrition_table.tex
*
* ------------------------------------------------------------------------------
	
	if `cleaning'		do "$analysis_do/cleaning.do"
	
* ------------------------------------------------------------------------------
* 								Construct
* ------------------------------------------------------------------------------
*
*	REQUIRES:	$masterdata/master_hh.dta
*				$analysis_dt\hhwater_plotcropgs.dta
*	CREATES:	$out_bal\balance_table.tex
*
* ------------------------------------------------------------------------------
	
	if `construct'	do "$analysis_do/construct.do"
	
* ------------------------------------------------------------------------------
* 							Decriptive statistics
* ------------------------------------------------------------------------------
*
* 	OUTLINE:		TABLE 1 - Sample sizes by round
*					TABLE 2 - Basic Descriptives of Sample Over Study Period
*					TABLE 3 - Distribution of treatment and control assignment			
* 	REQUIRES:		$analysis\hhwater_plotcropgs.dta.dta
*					$masterdata/master_hh.dta
*					$masterdata/plot_tracker.dta
*					$masterdata/master_plot.dta
* 	CREATES:		$out_desc/T1_obs_per_round.tex
*					$out_desc/T2_descriptives.tex
*					$out_desc/T3_takeup.tex
*
* ------------------------------------------------------------------------------
	
	if `analysis'	do "$analysis_do/admin_descr.do"
	
*-------------------------------------------------------------------------------