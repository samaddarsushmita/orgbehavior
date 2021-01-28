/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   					 Task Allocation Report MASTER DO					   *
*   							   2019										   *
********************************************************************************
********************************************************************************
*						   SELECT PARTS TO RUN   							   *
********************************************************************************/
	
	* select which parts of this do-file to run
	local 	packages			1	// 	Install packages -- only needs to be ran 
									//	once in each computer
									
	local	cleaning			1	// 	Clean the datasets
	
	local 	page2	 			1	// 	outputs page 2 relevant stats 
	
	local	page3				1 	// 	outputs page 3 relevant stats

	local	page4				1 	// 	outputs page 4 relevant stats
	
	local 	page5				1	// 	outputs page 4 relevant stats

	
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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Task Allocation Check in\Report\Pilot\Code\Dofiles\Cleaning"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Report\Pilot\Datasets\Intermediate"
	}

	
	
 	* Subfolder globals
	* -----------------
	gl clean_do			"$github\clean.do" 
	gl page2_do			"$github\page2.do"
	gl page3_do			"$github\page3.do"
	gl page4_do			"$github\page4.do"
	gl page5_do			"$github\page5.do""
	gl case 			12	
		
********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
	
* ------------------------------------------------------------------------------
* 								Cleaning 
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
	
	if `cleaning'		do "$clean_do"
* ------------------------------------------------------------------------------
* 								Page2 
* ------------------------------------------------------------------------------
*
* ------------------------------------------------------------------------------
	
	if `page2'		do "$page2_do"
* ------------------------------------------------------------------------------
* 								Page3 
* ------------------------------------------------------------------------------
*
* ------------------------------------------------------------------------------
	
	if `page3'		do "$page3_do"
	
* ------------------------------------------------------------------------------
* 								Page4 
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
	
	if `page4'		do "$page4_do"
* ------------------------------------------------------------------------------
* 								Page5 
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
	
	if `page5'		do "$page5_do"
