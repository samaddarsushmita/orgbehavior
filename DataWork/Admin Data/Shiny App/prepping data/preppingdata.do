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
									
	local	master_clean	1	// 	Clean the project dta
	
	local	construct		1	// 	Construct the merged data
	
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
		global github2	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Admin Data\Shiny App\prepping data"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Datasets"
	}

set more off
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Outputs\Raw"

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
	
* ------------------------------------------------------------------------------
* 							Cleaning all the data
* ------------------------------------------------------------------------------
	
	if `master_clean'		do "$github\master_clean.do"

* ------------------------------------------------------------------------------
* 							Construct merged team project data
* ------------------------------------------------------------------------------
	
	if `construct'		do "$github2\construct.do"
	
	
* ------------------------------------------------------------------------------
	****************************************************************************
	*                   TTL DATA WITH PROJECT DATA                             *
	****************************************************************************

use "$onedrive\Intermediate\teamproj_v3.dta", clear

********************************************************************************
* CREATE A DATASET FOR DASHBOARD AT THE LEVEL OF PROJECT WITH;
*	1. Project ID, Year, Project Status, Project Category, Time Period, Region, Unit, Practice Group 
*	2. Timeliness: Days of Delay, Proportion of delay every year for each unit, Project Cycle
*	3. Cost: Expenses by Max Item, 
*	4. Quality: IEG and ISR Ratings
*	5: Effectiveness: Changes in TTLs during the project 

********************************************************************************
*GENERATING VARIABLE FOR UNIT




