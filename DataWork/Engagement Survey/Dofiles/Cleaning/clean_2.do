/*******************************************************************************
*							SUSHMITA SAMADDAR 								   *
*   				Engagement Survey  CLEANING DO								*
*   							   2019										   *
********************************************************************************
********************************************************************************
*						   SELECT PARTS TO RUN   							   *
********************************************************************************/
	
	* select which parts of this do-file to run
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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Engagement Survey\Dofiles\Cleaning"
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Engagement Survey\Data"
		cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Engagement Survey\Outputs\Raw"
	}

********************************************************************************
*							IMPORTING DATA										*
********************************************************************************
set more off

												
import excel "$onedrive\Raw\ES2019 Master Data 2 - GGE for Agile.xlsx", firstrow case(lower) clear
											
save "$onedrive\Intermediate\esGGE_2019.dta", replace

********************************************************************************

use "$onedrive\Intermediate\esGGE_2019.dta", clear

ren k pfav2018
ren q questionnumber

*REPLACING DIVISION WITH GP NAMES
replace division = "FCI" if division=="EFNDR (FCI)"
replace division = "MTI" if division=="EMFDR (MTI)"
replace division = "Prospects" if division=="EPGDR"
replace division = "GOV-Proc" if division=="EPRDR (GOV - Proc.)"
replace division = "GOV-PS/FM" if division=="EPSDR (Gov - PS/FM)"
replace division = "POV" if division=="EPVDR (POV)"
replace division = "TIC" if division=="ETIDR (TIC)"

*GENERATING A FILTER FOR LEVEL OF OBSERVATION
gen 	level = reporttype
replace level = "Org Report" 		if 	level=="Aggregate Report"
replace level = "PG Report" 		if 	level=="VPU Report"
replace level = "GP Report"			if 	division=="FCI"
replace level = "GP Report"			if 	division=="MTI"
replace level = "GP Report"			if 	division=="Prospects"
replace level = "GP Report"			if 	division=="GOV-Proc"
replace level = "GP Report"			if 	division=="GOV-PS/FM"
replace level = "GP Report"			if 	division=="POV"
replace level = "GP Report"			if 	division=="TIC"

replace pmu = "EFI" 	if pmu=="GGE" 
replace division = "EFI-IBRD" if division=="GGE-IBRD"
replace division = "EFI-IFC" if division=="GGE-IFC"
replace division = "EFI" if division=="GGE"
replace org = "IBRD" if org == "IBRD only"
replace org = "IFC" if org == "IFC only"

**ADDING ANOTHER LEVEL OF OBSERVATION
local qnr 4 8 11 12 13 14 15 16 17 18 19 20 21 22 26 27 28 32 35 36 41 42 43 44 48 49 50 51 52 53 54 55 56 57 58 59 65

*we need to aggregate scores at the VPU-ORG-REG level and VPU-REG level

destring pcat5 pcat3 pcat4 pcat2 pcat1 pfav pneut punfav, replace force

*FOR VPU-ORG-REG level
gen 		div_code 	= 1 if division == "AFR-IBRD"
replace 	div_code 	= 2 if division == "ECA-IBRD"
replace 	div_code 	= 3 if division == "EAP-IBRD"
replace 	div_code 	= 4 if division == "LCR-IBRD"
replace 	div_code 	= 5 if division == "MNA-IBRD"
replace 	div_code 	= 6 if division == "SAR-IBRD"
replace 	div_code 	= 7 if division == "AFR-IFC"
replace 	div_code 	= 8 if division == "ECA-IFC"
replace 	div_code 	= 9 if division == "EAP-IFC"
replace 	div_code 	= 10 if division == "LCR-IFC"
replace 	div_code 	= 11 if division == "MNA-IFC"
replace 	div_code 	= 12 if division == "SAR-IFC"

	save "$onedrive\Intermediate\temp.dta", replace 
	collapse (mean) pfav pneut punfav pcat1 pcat2 pcat3 pcat4 pcat5 (first) division level if level == "Unit/Dept Report" & org!="IBRD/IFC" & region!="", by(org region questionnumber)
	ren (pfav pneut punfav pcat1 pcat2 pcat3 pcat4 pcat5 questionnumber) (pfav_n pneut_n punfav_n pcat1_n pcat2_n pcat3_n pcat4_n pcat5_n questionnumber_n)
	replace level = "VPU-ORG-REG Report"
replace division = "AFR-IBRD" if org == "IBRD" & region == "AFR" 
replace division = "ECA-IBRD" if org == "IBRD" & region == "ECA" 
replace division = "EAP-IBRD" if org == "IBRD" & region == "EAP" 
replace division = "LCR-IBRD" if org == "IBRD" & region == "LCR" 
replace division = "MNA-IBRD" if org == "IBRD" & region == "MNA" 
replace division = "SAR-IBRD" if org == "IBRD" & region == "SAR" 
replace division = "AFR-IFC" if org == "IFC" & region == "AFR" 
replace division = "ECA-IFC" if org == "IFC" & region == "ECA" 
replace division = "EAP-IFC" if org == "IFC" & region == "EAP" 
replace division = "LCR-IFC" if org == "IFC" & region == "LCR" 
replace division = "MNA-IFC" if org == "IFC" & region == "MNA" 
replace division = "SAR-IFC" if org == "IFC" & region == "SAR" 

gen 		div_code 	= 1 if division == "AFR-IBRD"
replace 	div_code 	= 2 if division == "ECA-IBRD"
replace 	div_code 	= 3 if division == "EAP-IBRD"
replace 	div_code 	= 4 if division == "LCR-IBRD"
replace 	div_code 	= 5 if division == "MNA-IBRD"
replace 	div_code 	= 6 if division == "SAR-IBRD"
replace 	div_code 	= 7 if division == "AFR-IFC"
replace 	div_code 	= 8 if division == "ECA-IFC"
replace 	div_code 	= 9 if division == "EAP-IFC"
replace 	div_code 	= 10 if division == "LCR-IFC"
replace 	div_code 	= 11 if division == "MNA-IFC"
replace 	div_code 	= 12 if division == "SAR-IFC"

tab div_code

keep div_code pfav_n pneut_n punfav_n pcat1_n pcat2_n pcat3_n pcat4_n pcat5_n questionnumber_n
	save "$onedrive\Intermediate\temp2.dta", replace 
	use "$onedrive\Intermediate\temp.dta", clear 
merge m:m div_code using "$onedrive\Intermediate\temp2.dta", keepusing(pfav_n pneut_n punfav_n pcat1_n pcat2_n pcat3_n pcat4_n pcat5_n questionnumber_n)
tab div_code if _merge==2
drop _merge

foreach var in pfav pneut punfav pcat1 pcat2 pcat3 pcat4 pcat5 questionnumber {
replace `var' = `var'_n if level== "VPU-ORG-REG Report" 
drop `var'_n
}
drop div_code

*FOR VPU-REG level
gen 		div_code 	= 1 if division == "AFR"
replace 	div_code 	= 2 if division == "ECA"
replace 	div_code 	= 3 if division == "EAP"
replace 	div_code 	= 4 if division == "LCR"
replace 	div_code 	= 5 if division == "MNA"
replace 	div_code 	= 6 if division == "SAR"

	save "$onedrive\Intermediate\temp.dta", replace 
	collapse (mean) pfav pneut punfav pcat1 pcat2 pcat3 pcat4 pcat5 (first) division level if level == "Unit/Dept Report" & org!="IBRD/IFC" & region!="", by(region questionnumber)
	ren (pfav pneut punfav pcat1 pcat2 pcat3 pcat4 pcat5 questionnumber) (pfav_n pneut_n punfav_n pcat1_n pcat2_n pcat3_n pcat4_n pcat5_n questionnumber_n)
	replace level = "VPU-REG Report"
replace division = "AFR" if region == "AFR" 
replace division = "ECA" if region == "ECA" 
replace division = "EAP" if region == "EAP" 
replace division = "LCR" if region == "LCR" 
replace division = "MNA" if region == "MNA" 
replace division = "SAR" if region == "SAR" 

gen 		div_code 	= 1 if division == "AFR"
replace 	div_code 	= 2 if division == "ECA"
replace 	div_code 	= 3 if division == "EAP"
replace 	div_code 	= 4 if division == "LCR"
replace 	div_code 	= 5 if division == "MNA"
replace 	div_code 	= 6 if division == "SAR"

tab div_code

keep div_code pfav_n pneut_n punfav_n pcat1_n pcat2_n pcat3_n pcat4_n pcat5_n questionnumber_n
	save "$onedrive\Intermediate\temp2.dta", replace 
	use "$onedrive\Intermediate\temp.dta", clear 
merge m:m div_code using "$onedrive\Intermediate\temp2.dta", keepusing(pfav_n pneut_n punfav_n pcat1_n pcat2_n pcat3_n pcat4_n pcat5_n questionnumber_n)
tab div_code if _merge==2
drop _merge

foreach var in pfav pneut punfav pcat1 pcat2 pcat3 pcat4 pcat5 questionnumber {
replace `var' = `var'_n if level== "VPU-REG Report" 
drop `var'_n
}
drop div_code

*TAG AGILE INDEX IN SURVEY
********************************************************************************
*agile questions: 16 8 18 17 20 

gen agileindex = .
local agile 8 16 18 9 20 21 58 42 11 13 54 53 48 49 50 51 55 56 57 26 27 28 19 
foreach q of local agile {
	replace agileindex = 1 if questionnumber==`q'
}

*DEFINING VALUES IN CATEGORICAL VARIABLES

*THEME ID
label define themeidlbl	1	"Overall Perceptions"		2 "Leadership"	3 "Role & Empowerment"	///
						4	"Learning & Development"	5 "Performance" 6 "Pay & Benefits"		///
						7	"Work Life Balance"			8 "Inclusion" 	9 "Collaboration"		///
						10	"Instnl Practices"			11 "Respect"	12 "Taking Action"

/*AGILE INDICATORS		
gen 	agileindicator=""
replace agileindicator="Goal Orientation"	if questionnumber==16|questionnumber==8|questionnumber==18|questionnumber==17
replace agileindicator="Innovation" 		if questionnumber==20|questionnumber==21|questionnumber==58
replace agileindicator="Managmt Agility" 	if questionnumber==54|questionnumber==53|questionnumber==11|questionnumber==12|questionnumber==13
replace agileindicator="Collaboration" 		if questionnumber==48|questionnumber==49|questionnumber==50|questionnumber==51|questionnumber==52
replace agileindicator="Process Agility"	if questionnumber==55|questionnumber==56|questionnumber==57
replace agileindicator="Inclusion" 			if questionnumber==42|questionnumber==41|questionnumber==43|questionnumber==44
replace agileindicator="Learning & Development" if questionnumber==26|questionnumber==27|questionnumber==28
*/

*AGILE INDICATORS - 2
gen 	agileindicator=""
replace agileindicator="Goal Orientation"	if questionnumber==8|questionnumber==16|questionnumber==18|questionnumber==9
replace agileindicator="Innovation" 		if questionnumber==20|questionnumber==21|questionnumber==58|questionnumber==42
replace agileindicator="Managmt Agility" 	if questionnumber==11|questionnumber==13|questionnumber==54|questionnumber==53
replace agileindicator="Collaboration" 		if questionnumber==48|questionnumber==49|questionnumber==50|questionnumber==51
replace agileindicator="Process Agility"	if questionnumber==55|questionnumber==56|questionnumber==57
replace agileindicator="Learning & Development" if questionnumber==26|questionnumber==27|questionnumber==28|questionnumber==19

*remaining 4,15,19,22,32,35,36,59,65 : 13 questions

save "$onedrive\Intermediate\esGGE_2019_v2.dta", replace
						