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
		global github	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Admin Data"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data"
		local path 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Datasets\Intermediate\"
		local path3 "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Encrypted\Raw Data\"
	}

set more off
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Outputs\Raw"

*setting paths

	use "`path'ttlprojspendratings_v3.dta", clear

/*ppp rates added

*import excel "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\Admin Data\Raw\ppp_rates.xlsx", sheet("Sheet1") firstrow clear
*save "`path'ppp_rates.dta", replace

use "`path'ppp_rates.dta", clear

merge m:m country_name year using "`path'ttlprojspendISR_v3.dta"
drop _merge
save "`path'ttlprojspendISR_v4.dta", replace

use "`path'ttlprojspendISR_v4.dta", clear
global gp fci gurr tr gov edu

*DISBURSEMENT - PPP Adjusted
gen disbursement_amt_100k_ppp=disbursement_amt_100k/ppp_rates
hist disbursement_amt_100k_ppp if disbursement_amt_100k_ppp!=., percent

*GENERATING A YEARLY DISBURSEMENT AMOUNT FOR TTLs - PPP Adjusted

bysort team_leader_upi year: egen TTL_dis_pbyyr=mean(disbursement_amt_100k_ppp)
sum TTL_IEGbyyr
estpost tabstat TTL_dis_pbyyr, stat(n mean) by(year) col(stat)
esttab using TTL_dis_pbyyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 

foreach y of global gp {
	cap noi estpost tabstat TTL_dis_pbyyr if `y'==1, stat(n mean) by(year) col(stat)
	cap noi esttab using TTL_dis_pbyyr`y'.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}

*SPENDING - PPP ADJUSTED
gen amount_ppp=amount/ppp_rates
cap noi tabstat amount_ppp, by(gurr) stat(n mean)
cap noi ttest amount_ppp, by(gurr)

local projtype `" "S" "A" "L" "'
foreach x of local projtype {
cap noi tabstat amount_ppp if prod_line_type=="`x'", by(gurr) stat(n mean)
cap noi ttest amount_ppp if prod_line_type=="`x'", by(gurr)
}
hist amount_ppp, percent

*GENERATING A YEARLY SPENDING VARIABLE FOR TTLs
estpost tabstat amount_ppp if project_status_nme=="Closed", stat(n mean) by(year) col(stat)
esttab using amount_pbyyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 

foreach y of global gp {
	cap noi estpost tabstat amount_ppp if `y'==1 & project_status_nme=="Closed", stat(n mean) by(year) col(stat)
	cap noi esttab using amount_pbyyr`y'.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}

*GENERATING A YEARLY SPENDING VARIABLE FOR TTLs BY TYPE
local projtype `" "S" "A" "L" "'
foreach x of local projtype {
estpost tabstat amount_ppp if prod_line_type=="`x'" & project_status_nme=="Closed", stat(n mean) by(year) col(stat)
esttab using `x'amount_pbyyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}
*/

*PORTFOLIO DISTRIBUTION
*% of projects by type
encode ProjectID, gen(q_projid)
local projtype `" "A" "L" "S" "'
egen totalproj=count(q_projid)
foreach x of local projtype {
gen `x'proj_p=.
egen `x'proj=count(q_projid) if prod_line_type=="`x'"
replace `x'proj_p=`x'proj/totalproj
tabstat `x'proj_p, stat(n mean)
}

local projtype `" "A" "L" "S" "'
foreach y of global gp {
cap noi egen totalproj`y'=count(q_projid) if `y'==1
}
foreach x of local projtype {
foreach y of global gp {
cap noi gen `x'proj_p`y'=.
cap noi egen `x'proj`y'=count(q_projid) if prod_line_type=="`x'" & `y'==1
cap noi replace `x'proj_p`y'=`x'proj`y'/totalproj`y' if `y'==1
cap noi tabstat `x'proj_p`y', stat(n mean)
}
}

local projtype `" "A" "L" "S" "'
bysort year: egen totalprojyr=count(q_projid)
foreach x of local projtype {
gen `x'proj_pyr=.
bysort year: egen `x'projyr=count(q_projid) if prod_line_type=="`x'"
bysort year: replace `x'proj_pyr=`x'projyr/totalprojyr
estpost tabstat `x'proj_pyr if prod_line_type=="`x'", stat(n mean) by(year) col(stat)
esttab using `x'proj_pyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}

local projtype `" "A" "L" "S""'
foreach y of global gp {
cap noi bysort year `y': egen totalprojyr`y'=count(q_projid)
}
foreach x of local projtype {
foreach y of global gp {
cap noi gen `x'proj_pyr`y'=.
cap noi bysort year `y': egen `x'projyr`y'=count(q_projid) if prod_line_type=="`x'" & `y'==1
cap noi bysort year `y': replace `x'proj_pyr`y'=`x'projyr`y'/totalprojyr`y' if `y'==1
cap noi estpost tabstat `x'proj_pyr`y' if prod_line_type=="`x'", stat(n mean) by(year) col(stat)
cap noi esttab using `x'proj_pyr`y'.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}
}

*BY TTL
local projtype `" "A" "L" "S" "'
bysort year UPI: egen totalprojyrttl=count(q_projid)
foreach x of local projtype {
gen `x'proj_pyrttl=.
bysort year UPI: egen `x'projyrttl=count(q_projid) if prod_line_type=="`x'"
bysort year UPI: replace `x'proj_pyrttl=`x'projyrttl/totalprojyrttl
estpost tabstat `x'proj_pyrttl if prod_line_type=="`x'", stat(n mean) by(year) col(stat)
esttab using `x'proj_pyrttl.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}

local projtype `" "A" "L" "S""'
foreach y of global gp {
cap noi bysort year UPI `y': egen totalprojyrttl`y'=count(q_projid) if `y'==1
}
foreach x of local projtype {
foreach y of global gp {
cap noi gen `x'proj_pyrttl`y'=.
cap noi bysort year UPI `y': egen `x'projyrttl`y'=count(q_projid) if prod_line_type=="`x'" & `y'==1
cap noi bysort year UPI `y': replace `x'proj_pyrttl`y'=`x'projyrttl`y'/totalprojyrttl`y' if `y'==1
cap noi estpost tabstat `x'proj_pyrttl`y' if prod_line_type=="`x'" & `y'==1, stat(n mean) by(year) col(stat)
cap noi esttab using `x'proj_pyrttl`y'.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}
}


*CORRELATION BETWEEN RATINGS AND YEARS OF EXPERIENCE FOR TTLs
local var IEGrating ISRrating risk_rating
foreach x of local var {
reg `x' years_exp if team_leader_upi!=. & Position=="TEAMLEAD"
reg `x' years_exp if gurr==1 & team_leader_upi!=. & Position=="TEAMLEAD"
reg `x' years_exp if gurr==0 & team_leader_upi!=. & Position=="TEAMLEAD"
}

*CORRELATION BETWEEN RATINGS AND DISBURSEMENT AMOUNT FOR TTLs
local var IEGrating ISRrating risk_rating
foreach x of local var {
reg `x' disbursement_amt_100k_ppp if team_leader_upi!=. & Position=="TEAMLEAD"
reg `x' disbursement_amt_100k_ppp if gurr==1 & team_leader_upi!=. & Position=="TEAMLEAD"
reg `x' disbursement_amt_100k_ppp if gurr==0 & team_leader_upi!=. & Position=="TEAMLEAD"
}

*CORRELATION BETWEEN RATINGS AND SPENDING AMOUNT FOR TTLs
local var IEGrating ISRrating risk_rating
foreach x of local var {
reg `x' amount_ppp if team_leader_upi!=. & Position=="TEAMLEAD"
reg `x' amount_ppp if gurr==1 & team_leader_upi!=. & Position=="TEAMLEAD"
reg `x' amount_ppp if gurr==0 & team_leader_upi!=. & Position=="TEAMLEAD"
}

/*
use "`path'teamproj_v3.dta", clear
keep if team_leader_upi!=. & Position=="TEAMLEAD" 
merge m:m ProjectID using "`path'spendingBPS.dta"

collapse (mean) amount (count) projid_nr, by(Costtype team_leader_upi)
save "`path'teamleadprojspend.dta", replace

use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamprojspend.dta", clear
estpost tabstat amount, by(Costtype) statistics(n mean sum) columns(statistics) elabel
esttab using cost.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 

egen maxamountupi=max(amount), by(UPI)
replace maxamountupi=amount if projid_nr==1
bysort UPI: gen maxcosttypeupi=Costtype if maxamountupi==amount
drop if maxcosttypeupi==""
tabstat maxamountupi projid_nr, by(Costtype) stat(n mean)

estpost tabstat maxamountupi, by(Costtype) statistics(n mean) columns(statistics) elabel
esttab using maxcost.rtf, cells(" count mean(fmt(a3))") varlabels(`e(labels)') replace 
outsheet maxcosttypeupi maxamountupi UPI using maxcoosttypeupi.xls, replace
*/
use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/spendingBPS_v2.dta", clear

*dropping empty rows and censored rows
merge m:1 ProjectID using teamleadproj.dta
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspend.dta", replace
use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspend.dta", clear
keep if _n<=531773
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp1.dta", replace
collapse (mean) amount (count) projid_nr (sum) amount, by(Costtype Fiscalyear)
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp1.dta", replace
use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspend.dta", clear
keep if _n>531773
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp2.dta", replace
collapse (mean) amount (count) projid_nr (sum) amount, by(Costtype Fiscalyear)
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp2.dta", replace
append using temp1.dta
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspendyr.dta", replace

use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspendyr.dta", replace

estpost tabstat amount if Costtype=="Lab Allocation TRS", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costyr1.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 
estpost tabstat amount if Costtype=="Short Term Consultnt", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costyr2.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 
estpost tabstat amount if Costtype=="Consultants Contract", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costyr3.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 
estpost tabstat amount if Costtype=="Development Grants", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costyr4.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 
estpost tabstat amount if Costtype=="Travel Airfare", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costyr5.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 

/*
use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/spendingBPS_v2.dta", clear
merge m:1 ProjectID using teamleadproj.dta
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspend.dta", replace
use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspend.dta", clear
keep if _n<=531773
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp1.dta", replace
collapse (mean) amount (count) projid_nr if gurr==1, by(Costtype UPI)
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp1.dta", replace
use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspend.dta", clear
keep if _n>531773
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp2.dta", replace
collapse (mean) amount (count) projid_nr if gurr==1, by(Costtype UPI)
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp2.dta", replace
append using temp1.dta
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspendgurr.dta", replace
*/

use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspendgurr.dta", clear
*gurr level 

estpost tabstat amount, by(Costtype) statistics(n mean sum) columns(statistics) elabel
esttab using costgurr.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 

egen maxamountupi=max(amount), by(UPI)
replace maxamountupi=amount if projid_nr==1
bysort UPI: gen maxcosttypeupi=Costtype if maxamountupi==amount
drop if maxcosttypeupi==""
tabstat maxamountupi projid_nr, by(Costtype) stat(n mean)

estpost tabstat maxamountupi, by(Costtype) statistics(n mean) columns(statistics) elabel
esttab using maxcostgurr.rtf, cells(" count mean(fmt(a3))") varlabels(`e(labels)') replace 
outsheet maxcosttypeupi maxamountupi UPI using maxcoosttypeupi.xls, replace


/*
use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspend.dta", clear
keep if _n<=531773
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp1.dta", replace
collapse (mean) meanamount=amount (count) projid_nr (sum) sumamount=amount if gurr==1, by(Costtype Fiscalyear)
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp1.dta", replace
use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspend.dta", clear
keep if _n>531773
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp2.dta", replace
collapse (mean) meanamount=amount (count) projid_nr (sum) sumamount=amount if gurr==1, by(Costtype Fiscalyear)
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/temp2.dta", replace
append using temp1.dta
save "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspendgurryr.dta", replace

use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/teamleadprojspendgurryr.dta", clear

estpost tabstat meanamount if Costtype=="Lab Allocation TRS", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costgurryr1.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 
estpost tabstat meanamount if Costtype=="Short Term Consultnt", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costgurryr2.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 
estpost tabstat meanamount if Costtype=="Consultants Contract", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costgurryr3.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 
estpost tabstat meanamount if Costtype=="Development Grants", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costgurryr4.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 
estpost tabstat meanamount if Costtype=="Travel Airfare", by(Fiscalyear) statistics(n mean sum) columns(statistics) elabel
esttab using costgurryr5.rtf, cells("count mean(fmt(a3)) sum") varlabels(`e(labels)') replace 

/*
use "/Users/sushmitasamaddar/OneDrive/World Bank/Agile/Admin Data/Intermediate/spendingBPS.dta", clear
merge m:m ProjectID using project_master_v2.dta, keepusing(gurr fci)
tabstat amount, by(Fiscalyear) stat(sum mean)
tabstat amount if gurr==1, by(Fiscalyear) stat(sum mean)



