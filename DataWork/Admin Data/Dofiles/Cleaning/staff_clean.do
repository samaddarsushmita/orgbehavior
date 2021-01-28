/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   					  PROJECT CLEANING DO								   *
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
	*              CLEANING STAFF MASTER FILE                                  *
	****************************************************************************

	import delimited "$onedriveRaw\staff.csv", clear encoding(UTF-8) 
		
save "$onedrive\Intermediate\staff.dta", replace
	

use "$onedrive\Intermediate\staff.dta", clear
duplicates report upi_nbr_c
rename upi_nbr_c UPI
destring UPI, replace
gen filter=1 if appttype=="HCOF"|appttype=="HCON"|appttype=="HTMP"|appttype=="LCON"|appttype=="LTMP" 

*FIXING DATES
local dates appt_start_date appt_end_date
	foreach x of local dates {
		cap noi gen `x'n=date(`x', "MDY")
		cap noi format `x'n %td
		cap noi drop `x'
		cap noi rename `x'n `x'
	}
	
	**************
	*DESCRIPTIVES*
	**************
	encode job_title, gen(job_title_n)
	encode appttype, gen(appttype_n)
	encode grade, gen(grade_n)
	encode unit, gen(unit_n)
	
	****************
	*HIRING FOR STAFF*
	****************
	
*NUMBER OF STAFF HIRED OVER YEARS (OVERALL)
gen year_start=year(appt_start_date)
bysort year_start: egen staffstartbyyr=count(UPI) if filter!=1
estpost tabstat staffstartbyyr, stat(n) by(year_start) col(stat)
esttab using staffstartbyyr.rtf, cells("count") varlabels(`e(labels)') replace 

*NUMBER OF STAFF HIRED OVER YEARS (by GPs)

foreach x of global gp {
	bysort year_start: egen staffstartbyyr`x'=count(UPI) if `x'==1 & filter!=1
	estpost tabstat staffstartbyyr`x', stat(n) by(year_start) col(stat)
	esttab using staffstartbyyr`x'.rtf, cells("count") varlabels(`e(labels)') replace 
}

*NUMBER OF STAFF HIRED OVER YEARS IN HQ (OVERALL)
bysort year_start: egen staffstartbyyrhq=count(UPI) if loc=="US" & filter!=1
estpost tabstat staffstartbyyrhq, stat(n) by(year_start) col(stat)
esttab using staffstartbyyrhq.rtf, cells("count") varlabels(`e(labels)') replace 

*NUMBER OF STAFF HIRED OVER YEARS IN HQ (by GPs)

foreach x of global gp {
	bysort year_start: egen staffstartbyyr`x'hq=count(UPI) if `x'==1 & loc=="US" & filter!=1
	estpost tabstat staffstartbyyr`x'hq, stat(n) by(year_start) col(stat)
	esttab using staffstartbyyr`x'hq.rtf, cells("count") varlabels(`e(labels)') replace 
}

save "$onedrive\Intermediate\staff_v2.dta", replace
