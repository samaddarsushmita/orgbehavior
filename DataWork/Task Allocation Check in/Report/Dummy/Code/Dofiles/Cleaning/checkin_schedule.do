/*******************************************************************************
*								SUSHMITA SAMADDAR 								*
*   						TASK CHECK IN SCHEDULE							   *
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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Task Allocation Check in\Report\Dummy\Code\Dofiles\Cleaning"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Report\Dummy\Datasets"
	}

********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
set more off

global date `'
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Task Allocation Check in\Report\Dummy\Outputs\Raw"

****ENTER 1 IF THERE IS NEW DATA
local newdata 1

****ENTER MAX NUMBER OF MISSIONS
global travelmax 3

if `newdata' {
import excel "$onedrive\Raw\Registration for Task Check-in_WIDE.xlsx", sheet ("Registration for Task Check-in_")firstrow clear												
save "$onedrive\Intermediate\registration.dta", replace
import excel "$onedrive\Raw\Country Codes.xlsx", sheet("Sheet1") firstrow clear
save "$onedrive\Intermediate\countrycodes.dta", replace
}

forvalues x=1/$travelmax {
use "$onedrive\Intermediate\countrycodes.dta", clear
ren (country 			country_est_hhoffset 			country_est_mmoffset 			country_est_operation) 	///
	(travel_country_`x' travel_country_est_hhoffset_`x'	travel_country_est_mmoffset_`x'	travel_country_est_operation_`x')
keep travel_country_`x' travel_country_est_hhoffset_`x'	travel_country_est_mmoffset_`x'	travel_country_est_operation_`x'
save "$onedrive\Intermediate\travel_countrycodes_`x'.dta", replace
}
use "$onedrive\Intermediate\registration.dta", clear

*GENERATING DATE VARIABLE FROM SUBMISSION DATETIME
cap noi ren SubmissionDate submissiondate
tostring 	submissiondate, g(submissiondate_s) format(%tCNN/DD/CCYY_HH:MM) force
split 		submissiondate_s, gen(submissiondate_n) parse(" ") 	
drop 		submissiondate_n2	submissiondate_s
rename		submissiondate_n1	submissiondate_n
ren 		submissiondate		submissiondatetime

gen 		submissiondate	 = date(submissiondate_n, "MD20Y")
format 		submissiondate %td

sort 		submissiondatetime
gen 		case	=	_n

*****UPDATE THE CASE NUMBER BELOW FOR REFERENCE
*		OLD MAX CASE NUMBER		0
*		NEW MAX CASE NUMBER		39
local 	maxcase					39
*****ENTER THE CASE NUMBER AFTER WHICH YOU WANT TO KEEP THE DATA
keep if case		>=	1

*MERGE REGISTRATION DATA WITH TIMEZONE DATA
merge m:1 country using "$onedrive\Intermediate\countrycodes.dta"
drop if _merge!=3
drop _merge

*CLEAN HOLIDAY DATES
forvalues	x=2/21 {
	replace 	holiday_`x'	=	.												///
		if		holiday_`x'	<	holiday_1
}
save "$onedrive\Intermediate\registration_obs`maxcase'.dta", replace

*****************************WHAT WE NEED***************************************
*	A TABLE WITH THE FOLLOWING VARIABLES FOR EACH CASE
*	1. CASE NUMBER
*	2. CASE NAME
*	3. PHONE NUMBER OF CASE
*	4. DATE OF TEXT MESSAGE (10 Business Days - 3 days registration submission date)
*	5. TIME OF TEXT MESSAGE IN EST (10*3 Instances)
*	6. TIME OF TEXT MESSAGE IN LOCAL TIMEZONE
*	7. COUNTRY 
*	8. TIME ZONE
*	9. TEXT MESSAGE FOR EACH INSTANCE
********************************************************************************

**** TWO ADJUSTMENTS NEEDED - 
*		1. FOR WEEKENDS (INCLUDING DIFFERENT WEEKENDS IN DIFFERENT COUNTRIES)
*		2. FOR HOLIDAYS OBSERVED IN DIFFERENT COUNTRIES

*DUPLICATING ALL OBSERVATIONS 10 TIMES TO EXPAND DATASET
expand 	15
sort 	case

*GENERATING VARIABLE FOR DATE OF TEXT MESSAGE
bysort 		case: 																///
	gen 	date_nr 	=	_n

gen 		date_text 	= 	.

bysort 		case:																///
	replace	date_text	=	submissiondate 										///
	if		date_nr		==	1	
format 		date_text 	%td

*GENERATING VARIABLE FOR DAY OF WEEK FOR EACH DATE_TEXT
gen 		dayofweek_text	=	dow(date_text)

label 	define 	dayofweeklbl 			0	"Sunday"							///
										1 	"Monday"			 				///
										2 	"Tuesday"				 			///
										3	"Wednesday"							///
										4	"Thursday"							///
										5	"Friday"							///
										6	"Saturday"							///

label 	values	dayofweek_text	dayofweeklbl

*CODING WORKWEEK START AND END DAYS
foreach x in country_workweek_start country_workweek_end	{
	gen 		`x'_n	=	0													///
		if		`x'		==	"Sunday"	
	replace		`x'_n	=	1													///
		if		`x'		==	"Monday"
	replace		`x'_n	=	2													///
		if		`x'		==	"Tuesday"
	replace		`x'_n	=	3													///
		if		`x'		==	"Wednesday"
	replace		`x'_n	=	4													///
		if		`x'		==	"Thursday"
	replace		`x'_n	=	5													///
		if		`x'		==	"Friday"
	replace		`x'_n	=	6													///
		if		`x'		==	"Saturday"
drop 			`x'
ren 			`x'_n	`x'
label 	values	`x'	dayofweeklbl
}

*GENERATING VARIABLE FOR WEEKENDS
gen 	weekend_1				=	.
replace	weekend_1				=	6											///
	if	country_workweek_end	==	5												
replace	weekend_1				=	5											///
	if	country_workweek_end	==	4												

gen 	weekend_2				=	.					
replace	weekend_2				=	0											///
	if	country_workweek_start	==	1									
replace	weekend_2				=	6											///
	if	country_workweek_start	==	0									

label 	values	weekend_*	dayofweeklbl

*START DATE FOR TEXT CHECK-IN ALWAYS A MONDAY
replace	date_text				=	date_text+7									///
	if	dayofweek_text			==	1											
replace	date_text				=	date_text+6									///
	if	dayofweek_text			==	2											
replace	date_text				=	date_text+5									///
	if	dayofweek_text			==	3											
replace	date_text				=	date_text+4									///
	if	dayofweek_text			==	4											
replace	date_text				=	date_text+3									///
	if	dayofweek_text			==	5											
replace	date_text				=	date_text+2									///
	if	dayofweek_text			==	6											
replace	date_text				=	date_text+1									///
	if	dayofweek_text			==	0	

*START DATE FOR TEXT CHECK-IN A SUNDAY IF ALTERNATE WEEKENDS
replace	date_text				=	date_text-1									///
	if	weekend_2				==	6											
	
format 	date_text	%td
drop 	dayofweek_text
gen 	dayofweek_text	=	dow(date_text)
label 	values	dayofweek_text	dayofweeklbl

*FILLING THE REST OF THE DATES FOR DATE_TEXT

*WEEK ONE
forvalues 	x=2/5{
bysort	case:																	///
	egen	maxdate_text			=	max(date_text)	
replace 	date_text				=	maxdate_text+1							///
	if		date_nr					==	`x'	
drop		maxdate_text
}	

*WEEK TWO	
bysort	case:																	///
	egen	maxdate_text		=	max(date_text)	
replace date_text				=	maxdate_text+3								///
	if	date_nr					==	6	
drop 	maxdate_text

forvalues 	x=7/10{
bysort	case:																	///
	egen	maxdate_text			=	max(date_text)	
replace 	date_text				=	maxdate_text+1							///
	if		date_nr					==	`x'	
drop		maxdate_text
}	

*WEEK THREE	
bysort	case:																	///
	egen	maxdate_text		=	max(date_text)	
replace date_text				=	maxdate_text+3								///
	if	date_nr					==	11	
drop 	maxdate_text

forvalues 	x=12/15{
bysort	case:																	///
	egen	maxdate_text			=	max(date_text)	
replace 	date_text				=	maxdate_text+1							///
	if		date_nr					==	`x'	
drop		maxdate_text
}	
	
format	date_text	%td
drop 	dayofweek_text
gen 	dayofweek_text	=	dow(date_text)
label 	values	dayofweek_text	dayofweeklbl

*CHECKING FOR HOLIDAYS
bysort	case:																	///
	egen	maxdate_text			=	max(date_text)	
forvalues x=1/21 				{
	replace date_text				=	maxdate_text+3							///
	if	date_text					==	holiday_`x'											
}
drop	maxdate_text

forvalues		case=1/100		{
	cap noi duplicates 	tag 	date_text 										///
		if 		case==	`case', 												///
		gen(dup_date`case')
}

egen			dup_date		=	rowtotal(dup_date*) 
replace			dup_date		=	.											///
	if			dup_date		==	0
gen 			dup_nr			=	.
bysort			case dup_date:													///
	replace		dup_nr			=	_n											///
		if		dup_date		!=	.

drop 			dup_date		

forvalues		case=1/100		{
cap noi drop 	dup_date`case'
}

forvalues 		x=2/5{
	bysort	case:																	///
		egen	maxdate_text			=	max(date_text)	
replace date_text						=	maxdate_text+1							///
	if	dup_nr							==	`x'		
drop 	maxdate_text 	
}	
drop 	dup_nr

*GENERATING TIME OF CHECK-IN FOR EACH DAY IN LOCAL TIMEZONE FOR BASE COUNTRY 

*FIRST CHECK-IN
gen			loc_hh_checkin_1				=	int(round((9+(11-9)*runiform()),1))
gen			loc_mm_checkin_1				=	int(round((runiform()*100),1))
replace		loc_mm_checkin_1				=	0								///
	if		loc_mm_checkin_1				<=	25
replace		loc_mm_checkin_1				=	15								///
	if		loc_mm_checkin_1				>	25								///
	&		loc_mm_checkin_1				<=	50
replace		loc_mm_checkin_1				=	30								///
	if		loc_mm_checkin_1				>	50								///
	&		loc_mm_checkin_1				<=	75
replace		loc_mm_checkin_1				=	45								///
	if		loc_mm_checkin_1				>	75								
	
*SECOND CHECK-IN
gen 		loc_hh_checkin_2				=	loc_hh_checkin_1+3
gen			loc_mm_checkin_2				=	loc_mm_checkin_1

*THIRD CHECK-IN
gen 		loc_hh_checkin_3				=	loc_hh_checkin_2+3
gen			loc_mm_checkin_3				=	loc_mm_checkin_1

*GENERATING STRING WITH COMPOSITE TIME 
forvalues 	x			=	1/3				{
	egen 		loc_checkin_`x'				=	concat(loc_hh_checkin_`x' loc_mm_checkin_`x'), punct(":")
}	

*CONVERTING LOCAL TIME OF CHECK-IN TO EST FOR ENUMERATOR 
gen		est_hh_checkin_1					=	.
gen 	est_mm_checkin_1					=	.
replace est_hh_checkin_1					=	loc_hh_checkin_1-country_est_hhoffset	///
	if	country_est_operation				==	"+"
replace est_mm_checkin_1					=	loc_mm_checkin_1-country_est_mmoffset	///
	if	country_est_operation				==	"+"
replace est_hh_checkin_1					=	loc_hh_checkin_1+country_est_hhoffset	///
	if	country_est_operation				==	"-"
replace est_mm_checkin_1					=	loc_mm_checkin_1+country_est_mmoffset	///
	if	country_est_operation				==	"-"

replace date_text							=	date_text-1						///
	if	est_hh_checkin_1					<	0
format	date_text %td

replace est_hh_checkin_1					=	24-(est_hh_checkin_1*-1)		///
	if	est_hh_checkin_1					<	0	

*MERGING COUNTRY CODES WITH TRAVEL COUNTRIES
forvalues x=1/$travelmax		{
merge m:1	travel_country_`x'	using 	"$onedrive\Intermediate\travel_countrycodes_`x'.dta"
drop if _merge==2
drop _merge
}

*ADJUSTING EST TIME OF CHECK-IN FOR MISSION COUNTRIES
forvalues x=1/$travelmax   {
	replace est_hh_checkin_1				=	loc_hh_checkin_1				///
											-	travel_country_est_hhoffset_`x'	///
		if	country_est_operation			==	"+"								///
		&	date_text						>=	travel_from_`x'					///
		&	date_text						<=	travel_to_`x'					///
		&	travel_country_est_hhoffset_`x'	!=	.
}
forvalues x=1/$travelmax   {
	replace est_mm_checkin_1				=	loc_mm_checkin_1				///
											-	travel_country_est_mmoffset_`x'	///
		if	country_est_operation			==	"+"								///
		&	date_text						>=	travel_from_`x'					///
		&	date_text						<=	travel_to_`x'					///
		&	travel_country_est_mmoffset_`x'	!=	.
}
forvalues x=1/$travelmax   {
	replace est_hh_checkin_1				=	loc_hh_checkin_1				///
											+	travel_country_est_hhoffset_`x'	///
		if	country_est_operation			==	"-"								///
		&	date_text						>=	travel_from_`x'					///
		&	date_text						<=	travel_to_`x'					///
		&	travel_country_est_hhoffset_`x'	!=	.
}
forvalues x=1/$travelmax   {
	replace est_mm_checkin_1				=	loc_mm_checkin_1				///
											+	travel_country_est_mmoffset_`x'	///
		if	country_est_operation			==	"-"								///
		&	date_text						>=	travel_from_`x'					///
		&	date_text						<=	travel_to_`x'					///
		&	travel_country_est_mmoffset_`x'	!=	.
}
replace date_text							=	date_text-1						///
	if	est_hh_checkin_1					<	0
format	date_text %td

replace est_hh_checkin_1					=	24-(est_hh_checkin_1*-1)		///
	if	est_hh_checkin_1					<	0	
replace est_mm_checkin_1					=	60-(est_mm_checkin_1*-1)		///
	if	est_mm_checkin_1					<	0	
	
*ADJUSTING THE SECOND AND THIRD CHECK-IN ACCORDING TO CHANGES IN FIRST CHECK-IN

*SECOND CHECK-IN
gen 		est_hh_checkin_2				=	est_hh_checkin_1+3
gen			est_mm_checkin_2				=	est_mm_checkin_1

*THIRD CHECK-IN
gen 		est_hh_checkin_3				=	est_hh_checkin_2+3
gen			est_mm_checkin_3				=	est_mm_checkin_1

*GENERATING STRING WITH COMPOSITE TIME 
forvalues 	x			=	1/3				{
	egen 		est_checkin_`x'				=	concat(est_hh_checkin_`x' est_mm_checkin_`x'), punct(":")
}	

sort 	case
sort 	date_text		
tab 	est_mm_checkin_1	

outsheet 	case 	name 	phone_number 	email 	country_label 	date_text 		///
			est_checkin_1 	est_checkin_2 	est_checkin_3 		loc_checkin_1 	///
			loc_checkin_2	loc_checkin_3 using "textcheckin_schedule.xls", replace









