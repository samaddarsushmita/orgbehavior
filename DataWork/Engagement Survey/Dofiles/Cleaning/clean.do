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

												
import excel "$onedrive\Raw\engagementsurvey_2019_5point.xlsx", firstrow case(lower) clear
											
save "$onedrive\Intermediate\es_2019.dta", replace

********************************************************************************

use "$onedrive\Intermediate\es_2019.dta", clear

ren j pfav2018
ren q questionnumber
*GENERATING A FILTER FOR LEVEL OF OBSERVATION
gen 	level = reporttype
replace level = "VPU-REG Report" 	if 	divison=="AFR"|	divison=="EAP"|	divison=="ECA"|	///
										divison=="LCR"|	divison=="MNA"|	divison=="SAR"
										
replace level = "VPU-PG Report" 	if 	divison=="GGE"| divison=="GGH"| divison=="GGI"| divison=="GGS"

replace level = "VPU Report" 		if 	divison=="BPS"|	divison=="CRO"|	divison=="DEC"| ///
										divison=="DFI"| divison=="ECR"| divison=="GIA"| ///
										divison=="HRD"| divison=="ICS"| divison=="IEG"| ///
										divison=="INT"| divison=="ITS"| divison=="LEG"| ///
										divison=="OPS"| divison=="SEC"| divison=="TRE"| divison=="WFA"
foreach var in divison pmu {
replace `var' = "EFI" 	if `var'=="GGE" 
replace `var' = "HD" 	if `var'=="GGH"
replace `var' = "INFRA" if `var'=="GGI"
replace `var' = "SD" 	if `var'=="GGS"
}

**ADDING ANOTHER LEVEL OF OBSERVATION
set obs `=_N+888'

local qnr 4 8 11 12 13 14 15 16 17 18 19 20 21 22 26 27 28 32 35 36 41 42 43 44 48 49 50 51 52 53 54 55 56 57 58 59 65

replace level = "PG-Region Unit" if level==""
replace pmu = "EFI" if _n>=8209 & _n<=8430
replace region = "AFR" if _n>=8209 & _n<=8245
replace region = "MNA" if _n>=8246 & _n<=8282
replace region = "LCR" if _n>=8283 & _n<=8319
replace region = "SAR" if _n>=8320 & _n<=8356
replace region = "EAP" if _n>=8357 & _n<=8393
replace region = "ECA" if _n>=8394 & _n<=8430
replace pmu = "HD" if _n>=8431 & _n<=8652
replace region = "AFR" if _n>=8431 & _n<=8467
replace region = "MNA" if _n>=8468 & _n<=8504
replace region = "LCR" if _n>=8505 & _n<=8541
replace region = "SAR" if _n>=8542 & _n<=8578
replace region = "EAP" if _n>=8579 & _n<=8615
replace region = "ECA" if _n>=8616 & _n<=8652
replace pmu = "INFRA" if _n>=8653 & _n<=8874
replace region = "AFR" if _n>=8653 & _n<=8689
replace region = "MNA" if _n>=8690 & _n<=8726
replace region = "LCR" if _n>=8727 & _n<=8763
replace region = "SAR" if _n>=8764 & _n<=8800
replace region = "EAP" if _n>=8801 & _n<=8837
replace region = "ECA" if _n>=8838 & _n<=8874
replace pmu = "SD" if _n>=8875 & _n<=9096
replace region = "AFR" if _n>=8875 & _n<=8911
replace region = "MNA" if _n>=8912 & _n<=8948
replace region = "LCR" if _n>=8949 & _n<=8985
replace region = "SAR" if _n>=8986 & _n<=9022
replace region = "EAP" if _n>=9023 & _n<=9059
replace region = "ECA" if _n>=9060 & _n<=9096


replace region = "AFR" if divison =="SAFD2"|  divison =="SAFD1"| divison =="IAFDR"| divison =="HAFD2"| divison =="HAFD1"| divison =="EA2DR" | divison =="EA1DR"  
replace region = "MNA" if divison =="SMNDR"|  divison =="IMNDR"| divison =="HMNDR"| divison =="EMNDR"  
replace region = "LCR" if divison =="SLCDR"|  divison =="ILCDR"| divison =="HLCDR"| divison =="ELCDR"
replace region = "SAR" if divison =="SSADR"|  divison =="ISADR"| divison =="HSADR"| divison =="ESADR"
replace region = "EAP" if divison =="SEADR"|  divison =="IEADR"| divison =="HEADR"| divison =="EEADR"
replace region = "ECA" if divison =="SCADR"|  divison =="IECDR"| divison =="HECDR"| divison =="EECDR"

/*
replace region = "AFR" if _n>=8209 & _n<=8245|(_n>=8431 & _n<=8467)|(_n>=8653 & _n<=8689)|(_n>=8875 & _n<=8911)
replace region = "MNA" if _n>=8246 & _n<=8282|(_n>=8468 & _n<=8504)|(_n>=8690 & _n<=8726)|(_n>=8912 & _n<=8948)
replace region = "LCR" if _n>=8283 & _n<=8319|(_n>=8505 & _n<=8541)|(_n>=8727 & _n<=8763)|(_n>=8949 & _n<=8985)
replace region = "ECA" if _n>=8320 & _n<=8356|(_n>=8542 & _n<=8578)|(_n>=8764 & _n<=8800)|(_n>=8986 & _n<=9022)
replace region = "EAP" if _n>=8457 & _n<=8493|(_n>=8579 & _n<=8615)|(_n>=8801 & _n<=8837)|(_n>=9023 & _n<=9059)
replace region = "SAR" if _n>=8494 & _n<=8530|(_n>=8616 & _n<=8652)|(_n>=8838 & _n<=8874)|(_n>=9060 & _n<=9096)
*/
replace divison = "EFI-AFR" if level== "PG-Region Unit" & pmu == "EFI" & region == "AFR" 
replace divison = "EFI-MNA" if level== "PG-Region Unit" & pmu == "EFI" & region == "MNA" 
replace divison = "EFI-LCR" if level== "PG-Region Unit" & pmu == "EFI" & region == "LCR" 
replace divison = "EFI-ECA" if level== "PG-Region Unit" & pmu == "EFI" & region == "ECA" 
replace divison = "EFI-EAP" if level== "PG-Region Unit" & pmu == "EFI" & region == "EAP" 
replace divison = "EFI-SAR" if level== "PG-Region Unit" & pmu == "EFI" & region == "SAR" 
replace divison = "HD-AFR" if level== "PG-Region Unit" & pmu == "HD" & region == "AFR" 
replace divison = "HD-MNA" if level== "PG-Region Unit" & pmu == "HD" & region == "MNA" 
replace divison = "HD-LCR" if level== "PG-Region Unit" & pmu == "HD" & region == "LCR" 
replace divison = "HD-ECA" if level== "PG-Region Unit" & pmu == "HD" & region == "ECA" 
replace divison = "HD-EAP" if level== "PG-Region Unit" & pmu == "HD" & region == "EAP" 
replace divison = "HD-SAR" if level== "PG-Region Unit" & pmu == "HD" & region == "SAR" 
replace divison = "INFRA-AFR" if level== "PG-Region Unit" & pmu == "INFRA" & region == "AFR" 
replace divison = "INFRA-MNA" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "MNA" 
replace divison = "INFRA-LCR" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "LCR" 
replace divison = "INFRA-ECA" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "ECA" 
replace divison = "INFRA-EAP" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "EAP" 
replace divison = "INFRA-SAR" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "SAR" 
replace divison = "SD-AFR" if level== "PG-Region Unit"  & pmu == "SD" & region == "AFR" 
replace divison = "SD-MNA" if level== "PG-Region Unit"  & pmu == "SD" & region == "MNA" 
replace divison = "SD-LCR" if level== "PG-Region Unit"  & pmu == "SD" & region == "LCR" 
replace divison = "SD-ECA" if level== "PG-Region Unit"  & pmu == "SD" & region == "ECA" 
replace divison = "SD-EAP" if level== "PG-Region Unit"  & pmu == "SD" & region == "EAP" 
replace divison = "SD-SAR" if level== "PG-Region Unit"  & pmu == "SD" & region == "SAR" 

gen 	div_code 	= 1 if divison == "EFI-AFR"
replace div_code 	= 2 if divison =="EFI-MNA"
replace div_code 	= 3 if divison =="EFI-LCR"
replace div_code 	= 4 if divison =="EFI-ECA"
replace div_code 	= 5 if divison =="EFI-EAP"
replace div_code 	= 6 if divison =="EFI-SAR"
replace div_code 	= 7 if divison =="HD-AFR"
replace div_code 	= 8 if divison =="HD-MNA" 
replace div_code 	= 9 if divison =="HD-LCR"
replace div_code 	= 10 if divison =="HD-ECA"
replace div_code 	= 11 if divison =="HD-EAP"
replace div_code 	= 12 if divison =="HD-SAR"
replace div_code 	= 13 if divison =="INFRA-AFR"
replace div_code 	= 14 if divison =="INFRA-MNA"
replace div_code 	= 15 if divison =="INFRA-LCR"
replace div_code 	= 16 if divison =="INFRA-ECA"
replace div_code 	= 17 if divison =="INFRA-EAP"
replace div_code 	= 18 if divison =="INFRA-SAR"
replace div_code 	= 19 if divison =="SD-AFR"
replace div_code 	= 20 if divison =="SD-MNA"
replace div_code 	= 21 if divison =="SD-LCR"
replace div_code 	= 22 if divison =="SD-ECA"
replace div_code 	= 23 if divison =="SD-EAP"
replace div_code 	= 24 if divison =="SD-SAR"

destring pcat5 pcat3 pcat4 pcat2 pcat1 pfav pneut punfav, replace force

	save "$onedrive\Intermediate\temp.dta", replace 
	collapse (mean) pfav pneut punfav pcat1 pcat2 pcat3 pcat4 pcat5 (first) divison if level == "Unit/Dept Report" , by(pmu region level questionnumber)
	ren (pfav pneut punfav pcat1 pcat2 pcat3 pcat4 pcat5 questionnumber) (pfav_n pneut_n punfav_n pcat1_n pcat2_n pcat3_n pcat4_n pcat5_n questionnumber_n)
	replace level = "PG-Region Unit"
	replace divison=""
replace divison = "EFI-AFR" if level== "PG-Region Unit" & pmu == "EFI" & region == "AFR" 
replace divison = "EFI-MNA" if level== "PG-Region Unit" & pmu == "EFI" & region == "MNA" 
replace divison = "EFI-LCR" if level== "PG-Region Unit" & pmu == "EFI" & region == "LCR" 
replace divison = "EFI-ECA" if level== "PG-Region Unit" & pmu == "EFI" & region == "ECA" 
replace divison = "EFI-EAP" if level== "PG-Region Unit" & pmu == "EFI" & region == "EAP" 
replace divison = "EFI-SAR" if level== "PG-Region Unit" & pmu == "EFI" & region == "SAR" 
replace divison = "HD-AFR" if level== "PG-Region Unit" & pmu == "HD" & region == "AFR" 
replace divison = "HD-MNA" if level== "PG-Region Unit" & pmu == "HD" & region == "MNA" 
replace divison = "HD-LCR" if level== "PG-Region Unit" & pmu == "HD" & region == "LCR" 
replace divison = "HD-ECA" if level== "PG-Region Unit" & pmu == "HD" & region == "ECA" 
replace divison = "HD-EAP" if level== "PG-Region Unit" & pmu == "HD" & region == "EAP" 
replace divison = "HD-SAR" if level== "PG-Region Unit" & pmu == "HD" & region == "SAR" 
replace divison = "INFRA-AFR" if level== "PG-Region Unit" & pmu == "INFRA" & region == "AFR" 
replace divison = "INFRA-MNA" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "MNA" 
replace divison = "INFRA-LCR" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "LCR" 
replace divison = "INFRA-ECA" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "ECA" 
replace divison = "INFRA-EAP" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "EAP" 
replace divison = "INFRA-SAR" if level== "PG-Region Unit"  & pmu == "INFRA" & region == "SAR" 
replace divison = "SD-AFR" if level== "PG-Region Unit"  & pmu == "SD" & region == "AFR" 
replace divison = "SD-MNA" if level== "PG-Region Unit"  & pmu == "SD" & region == "MNA" 
replace divison = "SD-LCR" if level== "PG-Region Unit"  & pmu == "SD" & region == "LCR" 
replace divison = "SD-ECA" if level== "PG-Region Unit"  & pmu == "SD" & region == "ECA" 
replace divison = "SD-EAP" if level== "PG-Region Unit"  & pmu == "SD" & region == "EAP" 
replace divison = "SD-SAR" if level== "PG-Region Unit"  & pmu == "SD" & region == "SAR" 
drop if divison==""
gen 	div_code 	= 1 if divison == "EFI-AFR"
replace div_code 	= 2 if divison =="EFI-MNA"
replace div_code 	= 3 if divison =="EFI-LCR"
replace div_code 	= 4 if divison =="EFI-ECA"
replace div_code 	= 5 if divison =="EFI-EAP"
replace div_code 	= 6 if divison =="EFI-SAR"
replace div_code 	= 7 if divison =="HD-AFR"
replace div_code 	= 8 if divison =="HD-MNA" 
replace div_code 	= 9 if divison =="HD-LCR"
replace div_code 	= 10 if divison =="HD-ECA"
replace div_code 	= 11 if divison =="HD-EAP"
replace div_code 	= 12 if divison =="HD-SAR"
replace div_code 	= 13 if divison =="INFRA-AFR"
replace div_code 	= 14 if divison =="INFRA-MNA"
replace div_code 	= 15 if divison =="INFRA-LCR"
replace div_code 	= 16 if divison =="INFRA-ECA"
replace div_code 	= 17 if divison =="INFRA-EAP"
replace div_code 	= 18 if divison =="INFRA-SAR"
replace div_code 	= 19 if divison =="SD-AFR"
replace div_code 	= 20 if divison =="SD-MNA"
replace div_code 	= 21 if divison =="SD-LCR"
replace div_code 	= 22 if divison =="SD-ECA"
replace div_code 	= 23 if divison =="SD-EAP"
replace div_code 	= 24 if divison =="SD-SAR"
tab div_code
keep div_code pfav_n pneut_n punfav_n pcat1_n pcat2_n pcat3_n pcat4_n pcat5_n questionnumber_n
	save "$onedrive\Intermediate\temp2.dta", replace 
	use "$onedrive\Intermediate\temp.dta", clear 
merge m:m div_code using "$onedrive\Intermediate\temp2.dta", keepusing(pfav_n pneut_n punfav_n pcat1_n pcat2_n pcat3_n pcat4_n pcat5_n questionnumber_n)
tab div_code if _merge==2
drop _merge

foreach var in pfav pneut punfav pcat1 pcat2 pcat3 pcat4 pcat5 questionnumber {
replace `var' = `var'_n if level== "PG-Region Unit" 
}
gen agileindex = .

local agile 8 16 18 9 20 21 58 42 11 13 54 53 48 49 50 51 55 56 57 26 27 28 19 
foreach q of local agile {
	replace agileindex = 1 if questionnumber==`q'
}
br questionnumber if level== "PG-Region Unit" 
*TAG AGILE INDEX IN SURVEY
********************************************************************************
*agile questions: 16 8 18 17 20 

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

save "$onedrive\Intermediate\es_2019_v2.dta", replace
						