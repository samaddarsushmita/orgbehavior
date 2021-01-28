
clear matrix
set more off

	cd 			"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\P&M Survey\Sampling\Outputs\Raw"
	local path 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\P&M Survey\Sampling\Datasets\Intermediate\"

use "`path'staff.dta", clear

duplicates report 	upi_nbr_c
rename 				upi_nbr_c 	UPI
destring 			UPI, replace

gen 				apptfilter	=1 			if 	appttype		==	"HCOF"	|	///
												appttype		==	"HCON"	|	///
												appttype		==	"HTMP"	|	///
												appttype		==	"LCON"	|	///
												appttype		==	"LTMP" 

/********************************************************************************
*		GENERATING FILTER FOR GURR, GSURR AND FCI 
*		NOT INCLUDING OFFICE OF REGIONAL DIRECTOR

*		Units for GURR: SURDR, SURGP, SURLN, GSUDL, GSUOA, SAFU1, SAFU2, SCAUR, 
						SEAU1, SEAU2, SLCUR, SMNUR, SSAU1
						
*		Units for S:    SSODR, SSOGL, SAFS1, SAFS4, SAFS2, SAFS3, SCASO, SEAS1, 
						SEAS2, SLCSO, SMNSO, SSASO
						
*		Units for FCI:  EFNDR, EFNFI, EFNFS, EFNFT, EFNST, EFNLT, EFNRF, EA1F1, 
						EA1F2, EA2C2, EEAF1, EEAF2, EECF1, EECF2, ELCC1
						
*		Units for TR: 	ITRDR ITRSO IAFT1 IAFT2 IAFT3 IAFT4 IEAT1 IEAT2 IECT1 
						IECT2 ILCT1 IMNT1 ISAT1 ISAT2
						
*		Units for GOV: 	EPSDR EPSPA EPSPF EA1G1 EA1G2 EEAG1 EEAG2 EECG1 EECG2 
						EMNGU
						
*		Units for EDU: 	HEDDR HEDGE HAFE1 HAFE2 HAFE3 HEAED HECED HLCED HMNED 
						HSAED
********************************************************************************/

*OUTSHEET ALL UNITS THAT ARE GP REGIONS
*GGHVP GGIVP GGSVP LCRVP MDOSI MNAVP OPSVP SARVP AFRVP EAPVP ECAVP GGCHA GGEVP

local vpu GGHVP GGIVP GGSVP LCRVP MNAVP OPSVP SARVP AFRVP EAPVP ECAVP GGCHA GGEVP
gen filter = .
foreach x of local vpu {
	replace filter =1 if vpu=="`x'"
}
collapse (count) UPI (first) vpu if filter==1, by(unit)
outsheet UPI unit using unitname.xls, replace
/*GURR
*****
local unitgurr 	SURDR SURGP SURLN GSUDL GSUOA SAFU1 SAFU2 SCAUR SEAU1 SEAU2 	///
				SLCUR SMNUR SSAU1

gen 			gurr	=.
foreach unit of local unitgurr			{
	replace 	gurr	=1 					if 	unit	=="`unit'"
}

*SOCIAL
*******
local unitsocial SSODR SSOGL SAFS1 SAFS4 SAFS2 SAFS3 SCASO SEAS1 SEAS2 SLCSO 	///
				SMNSO SSASO 

gen 			social	=.
foreach unit of local unitsocial			{
	replace 	social	=1 					if 	unit	=="`unit'"
}

*FCI
****
local unitfci 	EFNDR EFNFI EFNFS EFNFT EFNST EFNLT EFNRF EA1F1 EA1F2 EA2C2 	///
				EEAF1 EEAF2 EECF1 EECF2 ELCC1

gen 			fci		=.
foreach unit of local unitfci	{
	replace 	fci		=1 					if 	unit	=="`unit'"
}

*GSURR
******
local unitgsurr SURDR SURGP SURLN GSUDL GSUOA SAFU1 SAFU2 SCAUR SEAU1 SEAU2 	///
				SLCUR SMNUR SSAU1 SSODR SSOGL SAFS1 SAFS4 SAFS2 SAFS3 SCASO 	///
				SEAS1 SEAS2 SLCSO SMNSO SSASO GSURR	

gen 			gsurr	=.
foreach unit of local unitgsurr					{
	replace 	gsurr	=1 					if 	unit	=="`unit'"
}

*TR
******
local unittr 	ITRDR ITRSO IAFT1 IAFT2 IAFT3 IAFT4 IEAT1 IEAT2 IECT1 IECT2 	///
				ILCT1 IMNT1 ISAT1 ISAT2

gen 			tr			=.
foreach unit of local unittr					{
	replace 	tr		=1 					if 	unit	=="`unit'"
}

*GOV
******
local unitgov 	EPSDR EPSPA EPSPF EA1G1 EA1G2 EEAG1 EEAG2 EECG1 EECG2 EMNGU

gen 			gov		=.
foreach unit of local unitgov					{
	replace 	gov		=1 					if 	unit	=="`unit'"
}

*EDU
******
local unitedu 	HEDDR HEDGE HAFE1 HAFE2 HAFE3 HEAED HECED HLCED HMNED HSAED

gen 			edu		=.
foreach unit of local unitedu					{
	replace 	edu		=1 					if 	unit	=="`unit'"
}

*FIXING DATES
local dates appt_start_date appt_end_date

	foreach dates of local dates {
		cap noi gen 	`dates'n	=date(`dates', "MDY")
		cap noi format 	`dates'n 	%td
		cap noi drop 	`dates'
		cap noi rename 	`dates'n 	`dates'
	}

*ENCODING SOME VARIABLES
	encode job_title, 		gen(job_title_n)
	encode appttype, 		gen(appttype_n)
	encode grade, 			gen(grade_n)
	encode unit, 			gen(unit_n)

*non-DC based incorrectly mapped 
	replace loc			="AR" 				if UPI		==379475
	replace loc			="IT" 				if UPI		==207674

*GENERATING A GP FILTER
	gen 	gpfilter	="GURR" 			if gsurr	==1
	replace gpfilter	="FCI" 				if fci		==1
	replace gpfilter	="SOCIAL" 			if social	==1
	replace gpfilter	="TRANSPORT" 		if tr		==1
	replace gpfilter	="GOV" 				if gov		==1
	replace gpfilter	="EDU" 				if edu		==1
	tab 	gpfilter	

/********************************************************************************
*		GENERATING FILTER FOR REGIONS

*		Units for MENA:	(HD)	HMNDR HMNED HMNHN HMNSP
						(IN)	IMNDR IMNE1 IMNT1 
						(S)		SMNDR SMNAG SMNEN SMNSO SMNUR SMNWA 
						(EFI)	EMNDR EMNF2 EMNGU EMNM1 EMNM2 EMNPV EMNRU 
						
*		Units for ECA: 	(HD)	HECDR HECED HECHN HECSP 
						(IN)	IECDR IECE1 IECT1 IECT2 
						(S)		SCADR SCAAG SCAEN SCASO SCAUR SCAWA 
						(EFI)	EECDR EECF1 EECF2 EECG1 EECG2 EECM1 EECM2 EECPV 
								EECRU 
						
*		Units for SAR: 	(HD)	HSADR HSAED HSAHN HSAHP HSASP  
						(IN) 	ISADR ISAE1 ISAT1 ISAT2 
						(S)		SSADR SSAA1 SSAA2 SSACD SSAE1 SSAE2 SSAS2 SSASO 
								SSAU1 SSAW1 SSAW2 
						(EFI)	ESADR ESAC1 
						
*		Units for AFR: 	(HD) 	HAFD1 HAFE1 HAFH1 HAFS1 HAFD2 HAFE2 HAFE3 HAFH2 
								HAFH3 HAFS2 HAFS3 
						(IN)	IAFDR IAFE1 IAFE2 IAFE3 IAFE4 IAFT1 IAFT2 IAFT3 
								IAFT4
						(S)		SAFD1 SAFA1 SAFA4 SAFE1 SAFE4 SAFS1 SAFS4 SAFU1 
								SAFW1 SAFW2 SAFD2 SAFA2 SAFA3 SAFE2 SAFE3 SAFS2 
								SAFS3 SAFU2 SAFW3 
						(EFI)	EA1DR EA1F1 EA1F2 EA1G1 EA1G2 EA1M1 EA1M2 EA1PV 
								EA1RU EA2DR EA2C2  
						
*		Units for EAP: 	(HD)	HEADR HEAED HEAHN HEASP 
						(IN)	IEADR IEAE1 IEAT1 IEAT2 
						(S)		SEADR SEAAG SEAE1 SEAE2 SEAS1 SEAS2 SEAU1 SEAU2 
								SEAW1 SEAW2 
						(EFI) 	EEADR EEAF1 EEAF2 EEAG1 EEAG2 EEAM1 EEAM2 EEAPV 
								EEAR1 EEAR2
						
*		Units for LAC: 	(HD)	HLCDR HLCED HLCHN HLCSP 
						(IN)	ILCDR ILCE1 ILCT1 
						(S)		SLCDR SLCAG SLCEN SLCSO SLCUR SLCWA 
						(EFI)	ELCDR ELCC1 
********************************************************************************/
*MENA
*****
gen region=""
local unitmena 	HMNDR HMNED HMNHN HMNSP IMNDR IMNE1 IMNT1 SMNDR SMNAG SMNEN SMNSO ///
				SMNUR SMNWA EMNDR EMNF2 EMNGU EMNM1 EMNM2 EMNPV EMNRU 

foreach unit of local unitmena			{
	replace 	region	="MENA" 					if 	unit	=="`unit'"
}

*ECA
*****
local uniteca 	HECDR HECED HECHN HECSP IECDR IECE1 IECT1 IECT2 SCADR SCAAG SCAEN ///
				SCASO SCAUR SCAWA EECDR EECF1 EECF2 EECG1 EECG2 EECM1 EECM2 EECPV ///
				EECRU 

foreach unit of local uniteca			{
	replace 	region	="ECA" 					if 	unit	=="`unit'"
}

*SAR
*****
local unitsar 	HSADR HSAED HSAHN HSAHP HSASP ISADR ISAE1 ISAT1 ISAT2 SSADR SSAA1 ///
				SSAA2 SSACD SSAE1 SSAE2 SSAS2 SSASO SSAU1 SSAW1 SSAW2 ESADR ESAC1 

foreach unit of local unitsar			{
	replace 	region	="SAR"					if 	unit	=="`unit'"
}

*AFR
*****
local unitafr 	HAFD1 HAFE1 HAFH1 HAFS1 HAFD2 HAFE2 HAFE3 HAFH2 HAFH3 HAFS2 HAFS3 ///
				IAFDR IAFE1 IAFE2 IAFE3 IAFE4 IAFT1 IAFT2 IAFT3 IAFT4 SAFD1 SAFA1 ///
				SAFA4 SAFE1 SAFE4 SAFS1 SAFS4 SAFU1 SAFW1 SAFW2 SAFD2 SAFA2 SAFA3 ///
				SAFE2 SAFE3 SAFS2 SAFS3 SAFU2 SAFW3 EA1DR EA1F1 EA1F2 EA1G1 EA1G2 ///
				EA1M1 EA1M2 EA1PV EA1RU EA2DR EA2C2 

foreach unit of local unitafr			{
	replace 	region	="AFR" 					if 	unit	=="`unit'"
}

*EAP
*****
local uniteap 	HEADR HEAED HEAHN HEASP IEADR IEAE1 IEAT1 IEAT2 SEADR SEAAG SEAE1 ///
				SEAE2 SEAS1 SEAS2 SEAU1 SEAU2 SEAW1 SEAW2 EEADR EEAF1 EEAF2 EEAG1 ///
				EEAG2 EEAM1 EEAM2 EEAPV EEAR1 EEAR2

foreach unit of local uniteap			{
	replace 	region	="EAP"					if 	unit	=="`unit'"
}

*LAC
*****
local unitlac 	HLCDR HLCED HLCHN HLCSP ILCDR ILCE1 ILCT1 SLCDR SLCAG SLCEN SLCSO ///
				SLCUR SLCWA ELCDR ELCC1 

foreach unit of local unitlac			{
	replace 	region	="LAC" 					if 	unit	=="`unit'"
}

tab region

*GENERATING VARIABLE FOR PGs
*****************************

*HD
***
gen pg=""

local unithd 	HMNDR HMNED HMNHN HMNSP HECDR HECED HECHN HECSP HSADR HSAED HSAHN HSAHP ///
			HSASP HAFD1 HAFE1 HAFH1 HAFS1 HAFD2 HAFE2 HAFE3 HAFH2 HAFH3 HAFS2 HAFS3 ///
			HEADR HEAED HEAHN HEASP HLCDR HLCED HLCHN HLCSP 
			
foreach hd of local unithd			{
replace pg="HD" if unit == "`hd'"
}

replace pg="HD" if unit == "HMNDR"
*IN
***
local unitin 	IMNDR IMNE1 IMNT1 IECDR IECE1 IECT1 IECT2 ISADR ISAE1 ISAT1 ISAT2 IAFDR ///
			IAFE1 IAFE2 IAFE3 IAFE4 IAFT1 IAFT2 IAFT3 IEADR IEAE1 IEAT1 IEAT2 ILCDR ///
			ILCE1 ILCT1 IAFT4
foreach in of local unitin			{
replace pg="IN" if unit == "`in'"
}

*SD
***
local unitsd 	SMNDR SMNAG SMNEN SMNSO SMNUR SMNWA SCADR SCAAG SCAEN SCASO SCAUR SCAWA ///
			SSADR SSAA1 SSAA2 SSACD SSAE1 SSAE2 SSAS2 SSASO SSAU1 SSAW1 SSAW2 SAFD1 ///
			SAFA1 SAFA4 SAFE1 SAFE4 SAFS1 SAFS4 SAFU1 SAFW1 SAFW2 SAFD2 SAFA2 SAFA3 ///
			SAFE2 SAFE3 SAFS2 SAFS3 SAFU2 SAFW3 SEADR SEAAG SEAE1 SEAE2 SEAS1 SEAS2 ///
			SEAU1 SEAU2 SEAW1 SEAW2 SLCDR SLCAG SLCEN SLCSO SLCUR SLCWA 
foreach sd of local unitsd			{
replace pg="SD" if unit == "`sd'"
}

*EFI
***
local unitefi 	EMNDR EMNF2 EMNGU EMNM1 EMNM2 EMNPV EMNRU EECDR EECF1 EECF2 EECG1 EECG2 ///
			EECM1 EECM2 EECPV EECRU ESADR ESAC1 EA1DR EA1F1 EA1F2 EA1G1 EA1G2 EA1M1 ///
			EA1M2 EA1PV EA1RU EA2DR EA2C2 EEADR EEAF1 EEAF2 EEAG1 EEAG2 EEAM1 EEAM2 ///
			EEAPV EEAR1 EEAR2 ELCDR ELCC1  
foreach efi of local unitefi			{
replace pg="EFI" if unit == "`efi'"
}

tab pg region

*GENERATING FILTER FOR LOCATION

gen dc_based = 1 if loc=="US"
replace dc_based = 0 if dc_based == .
save "`path'staff_sample.dta", replace
	
********************************************************************************
*					GP BASED SAMPLING 											*
********************************************************************************	
use "`path'staff_sample.dta", clear

	
		*	KEEPING ONLY STAFF WITH FOLLOWING CHARACTERISTICS
	*	1. In GPs under our gpfilter
	*	2. Currently active
	*	3. Between GE to GH grade
	*	4. Located in the US
	*	5. Not a practice manager
	
	keep 									if gpfilter	!=""
	keep 									if active	=="Y"
	keep 									if grade_n	==16	|				///
												grade_n	==17	|				///
												grade_n	==15	|				///
												grade_n	==14
	keep 									if loc		=="US"
	keep 									if job_title!="Practice Manager"	

						**************
						*DESCRIPTIVES*
						**************
						
	*TABULATE JOB TITLE AND GRADE BY GPs
	************************************
	local gpl gurr fci social tr gov edu
	
	foreach gp of local gpl 				{
		tab job_title_n grade_n 			if 	`gp'		==	1 	& 			///
												active		==	"Y" & 			///
												loc			==	"US"			
	}
	
	local gpl gurr fci social tr gov edu
	
	foreach gp of local gpl					{
		tab unit `gp'					
	}



/*	We will take a census of all TTLs in the units with the largest number of staff
*	The following units from each gp will be chosen as final outputs
*	GURR:		SLCUR SCAUR
*	FCI:		EFNFI EFNFS
*	SOCIAL:		SCASO SSOGL
*	TRANSPORT: 	ILCT1 IAFT4
*	GOV:		EECG2 EMNGU
*	EDU:		HEDGE HMNED
*/
						*****************
						*	OUTPUTS		*
						*****************
global pii 	full_name UPI unit vpu room_num work_phone work_extn email_address 	///
			loc_name loc active grade mail_stop_nbr city_name city_code mobile

*FOR GURR
*********
outsheet $pii 								if 	unit		=="SLCUR" 		|	///
												unit		=="SCAUR"			///
												using 		samplegurr.xls, 	replace

*FOR FCI
*********
outsheet $pii 								if 	unit		=="EFNFI" 		|	///
												unit		=="EFNFS"			///
												using 		samplefci.xls, 		replace
*FOR SOCIAL
***********
outsheet $pii 								if 	unit		=="SCASO" 		|	///
												unit		=="SSOGL"			///
												using 		samplesocial.xls, 	replace
*FOR TRANSPORT
**************
outsheet $pii 								if 	unit		=="ILCT1" 		|	///
												unit		=="IAFT4"			///
												using 		sampletr.xls, 		replace
*FOR GOV
*********
outsheet $pii 								if 	unit		=="EECG2" 		|	///
												unit		=="EMNGU"			///
												using 		samplegov.xls, 		replace
*FOR EDU
*********
outsheet $pii 								if 	unit		=="HEDGE" 		|	///
												unit		=="HMNED"			///
												using 		sampleedu.xls, 		replace
*ALL TRANSPORT
outsheet $pii 								if 	tr 			==	1				///
												using 		allsampletr.xls, 		replace
												
********************************************************************************
*					REGION BASED SAMPLING 											*
********************************************************************************	
use "`path'staff_sample.dta", clear

	
		*	KEEPING ONLY STAFF WITH FOLLOWING CHARACTERISTICS
	*	1. In GPs under our regfilter
	*	2. Currently active
	*	3. Between GE to GH grade
	
	keep 									if region	!=""
	keep 									if active	=="Y"
	keep 									if grade_n	==16	|				///
												grade_n	==17	|				///
												grade_n	==15	|				///
												grade_n	==14

						**************
						*DESCRIPTIVES*
						**************
						
	*TABULATE JOB TITLE AND GRADE BY GPs
	************************************
	local reg MENA ECA EAP SAR AFR LAC
	
	foreach region of local reg 				{
		tab job_title_n grade_n 		if 	region	==	"`region'" 	& 			///
												active			==	"Y" 
	}


	local reg MENA ECA EAP SAR AFR LAC
	
	foreach region of local reg				{
		tab pg dc_based   if 	region	==	"`region'"	
		tab pg grade_n   if 	region	==	"`region'"					

	}
	
	local reg MENA ECA EAP SAR AFR LAC
	
	foreach region of local reg				{
		tab unit dc_based   	if 	region	==	"`region'"	
		tab unit grade_n  	 	if 	region	==	"`region'"					

	}

