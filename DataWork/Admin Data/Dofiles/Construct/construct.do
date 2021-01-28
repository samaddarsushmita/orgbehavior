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
		global github2	"C:\Users\wb522556\Documents\GitHub\Agile_Productivity_Radar\DataWork\Admin Data\Dofiles\Construct"
	}
	
	if "`c(username)'" == "wb522556" {
		global onedrive	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Datasets"
		global onedriveRaw "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Encrypted\Raw Data"
	}

set more off
cd 				"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Outputs\Raw"

*setting paths

	****************************************************************************
	*                  MERGING TEAM DATA WITH PROJECT DATA                     *
	****************************************************************************

use "$onedrive\Intermediate\team_v2.dta", clear

merge m:1 ProjectID using "$onedrive\Intermediate\project_master_v2.dta"
drop if _merge==1
drop _merge
save "$onedrive\Intermediate\teamproj.dta", replace

	****************************************************************************
	*                  MERGING STAFF DATA WITH PROJECT DATA                    *
	****************************************************************************
use "$onedrive\Intermediate\staff_v2.dta", clear

rename (UPI job_title subtype appttype appt_start_date appt_end_date) (team_leader_upi ttl_jobtitle ttl_subtype ttl_appttype upi_start_date upi_end_date)

save "$onedrive\Intermediate\staff_v3.dta", replace

use "$onedrive\Intermediate\teamproj.dta", clear
merge m:1 team_leader_upi using "$onedrive\Intermediate\staff_v3.dta", keepusing(team_leader_upi ttl_jobtitle ttl_subtype ttl_appttype upi_start_date upi_end_date)
drop if _merge==2
drop _merge
save "$onedrive\Intermediate\teamproj_v2.dta", replace

use "$onedrive\Intermediate\teamproj_v2.dta", clear

*TOTAL MEMBERS
bysort ProjectID: egen totalmembers=count(ProjectID)
sum totalmembers
sort totalmembers
replace team_leader_upi=. if Position=="MEMBER" & project_status_nme!="Closed" 

*Number of projects for each teamlead
sum team_leader_upi
egen long projid_nr = group(ProjectID) 
sum projid_nr
bysort team_leader_upi: egen totalttlproj=count(projid_nr) if team_leader_upi!=. & project_status_nme!="Closed" & Position=="TEAMLEAD"
sum totalttlproj
sort totalttlproj
tab prod_line_nme if totalttlproj>=50
tab ttl_subtype

*REMOVING TEAMLEADS THAT ARE CONSULTANTS OR TEMPORARY
replace team_leader_upi=. if ttl_subtype=="ST" |ttl_subtype==""
*47,698 changes

*dropping and re-generating variable for total projects
drop totalttlproj
bysort team_leader_upi: egen totalttlproj=count(projid_nr) if team_leader_upi!=. & project_status_nme!="Closed" & Position=="TEAMLEAD"
sum totalttlproj

*REMOVING TEAMLEADS FOR PUBLISHING
replace team_leader_upi=. if prod_line_code=="PB" 
*429 changes

*REMOVING TEAMLEADS FOR INTERNAL INVESTIGATION
replace team_leader_upi=. if prod_line_code=="IN"
*832 changes

*REMOVING TEAMLEADS FOR MIGA GUARANTEES
replace team_leader_upi=. if prod_line_code=="MG"
*250 changes

*removing multiple internal evaluations for the following TTL
replace team_leader_upi=. if team_leader_upi==81455 & prod_line_nme=="Review of Bank's Self-evaluation Instrs"
*63 changes

*dropping and re-generating variable for total projects
drop totalttlproj
bysort team_leader_upi: egen totalttlproj=count(projid_nr) if team_leader_upi!=. & project_status_nme!="Closed" & Position=="TEAMLEAD"

*dropping and re-generating variable for total projects
drop totalttlproj
bysort team_leader_upi: egen totalttlproj=count(projid_nr) if team_leader_upi!=. & project_status_nme!="Closed" & Position=="TEAMLEAD"

*many outliers for totalmembers 
replace totalmembers=. if totalmembers>=30

*Number of projects for each teamlead by type
local projtype `" "A" "L" "S" "'
foreach x of local projtype {
		bysort team_leader_upi: egen `x'ttlproj=count(projid_nr) if team_leader_upi!=. & project_status_nme!="Closed" & prod_line_type=="`x'" & Position=="TEAMLEAD"
		bysort ProjectID: egen `x'members=count(ProjectID) if prod_line_type=="`x'" 
}

*Number of projects per member
drop projid_nr
egen long projid_nr = group(ProjectID)
bysort UPI: egen totalprojUPI=count(projid_nr) if project_status_nme!="Closed" & (team_leader_upi!=.| Position=="MEMBER")
sum totalprojUPI

*Number of projects for each UPI by type
local projtype `" "A" "L" "S" "'
foreach x of local projtype {
	bysort UPI: egen `x'projUPI=count(projid_nr) if prod_line_type=="`x'" & project_status_nme!="Closed" & (team_leader_upi!=.| Position=="MEMBER")
}

*GENERATING A VARIABLE FOR EXPERIENCE IN WB
local dates upi_start_date upi_end_date
tostring upi_start_date upi_end_date, replace
	foreach x of local dates {
		cap noi gen `x'n=date(`x', "DMY")
		cap noi format `x'n %td
		cap noi drop `x'
		cap noi rename `x'n `x'
	}

gen years_exp=mdy(08,05,2019) - upi_start_date 
replace years_exp=years_exp/365
tabstat years_exp, stat(n mean)


local projtype `" "A" "L" "S" "'
foreach x of local projtype {
	bysort UPI: egen `x'years_exp=mean(years_exp) if prod_line_type=="`x'" & project_status_nme!="Closed" & (team_leader_upi!=.| Position=="MEMBER")
}

*GENERATING VARIABLE FOR YEAR OF PROJECTS
gen year=apprvl_fy
replace year=year(ais_sign_off_date) if year==.| year>=2021|year==0|year==1
tab year
*GENERATING A YEARLY PROJECT VARIABLE FOR UPI
drop projid_nr 
egen long projid_nr = group(ProjectID)
bysort UPI year: egen UPIprojbyyr=count(projid_nr) if team_leader_upi!=.| Position=="MEMBER"
sum UPIprojbyyr

*GENERATING A YEARLY PROJECT VARIABLE FOR UPI BY TYPE
local projtype `" "A" "L" "S" "'
foreach x of local projtype {
	bysort UPI year: egen `x'UPIprojbyyr=count(projid_nr) if (team_leader_upi!=. | Position=="MEMBER") & prod_line_type=="`x'"
	sum `x'UPIprojbyyr
}	

save "$onedrive\Intermediate\teamproj_v3.dta", replace


	/****************************************************************************
	*                   TTL DATA WITH PROJECT DATA                             *
	****************************************************************************

use "`path'teamproj_v3.dta", clear

keep if team_leader_upi!=. & Position=="TEAMLEAD"

save "`path'ttlproj.dta", replace

use "`path'ttlproj.dta", clear

*GENERATING A YEARLY PROJECT VARIABLE FOR TTLs
drop projid_nr 
egen long projid_nr = group(ProjectID)
bysort team_leader_upi year: egen ttlprojbyyr=count(projid_nr)
sum ttlprojbyyr

estpost tabstat ttlprojbyyr, stat(n mean) by(year) col(stat)
esttab using ttlprojbyyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 

	foreach y of global gp {
		cap noi estpost tabstat ttlprojbyyr if `y'==1, stat(n mean) by(year) col(stat)
		cap noi esttab using ttlprojbyyr`y'.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}

*GENERATING A YEARLY PROJECT VARIABLE FOR TTLs BY TYPE
local projtype `" "A" "L" "S" "'
foreach x of local projtype {
	bysort team_leader_upi year: egen `x'projbyyr=count(projid_nr) if prod_line_type=="`x'"
	sum `x'projbyyr
	estpost tabstat `x'projbyyr, stat(n mean) by(year) col(stat)
	esttab using `x'projbyyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}

local projtype `" "A" "L" "S" "'
foreach x of local projtype {
	foreach y of global gp {
		cap noi estpost tabstat `x'projbyyr if `y'==1, stat(n mean) by(year) col(stat)
		cap noi esttab using `x'projbyyr`y'.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
	}
}

*CORRELATION BETWEEN PROJECT TIMELINE AND NUMBER OF PROJECTS FOR TTLs
local var tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n ais_delcl_pn dec_cl_pn
foreach x of local var {
	reg `x' totalttlproj if project_status_nme!="Closed"
	margins, at(totalttlproj=(1(1)10))vsquish
	marginsplot, recast(line) recastci(rcap) title("") ytitle("predicted `x'")
}

local var tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n ais_delcl_pn dec_cl_pn
foreach x of local var {
	foreach y of global gp {
		cap noi reg `x' totalttlproj if project_status_nme!="Closed" & `y'==1
		cap noi margins, at(totalttlproj=(1(1)10))vsquish
		cap noi marginsplot, recast(line) recastci(rcap) title("") ytitle("predicted `x'")
	}
}

/*CORRELATION BETWEEN PROJECT TIMELINE AND YEARS OF EXPERIENCE FOR TTLs
local var tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n ais_delcl_pn dec_cl_pn
foreach x of local var {
	reg `x' years_exp if project_status_nme!="Closed"
}

local var tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n ais_delcl_pn dec_cl_pn
foreach x of local var {
	foreach y of global gp {
		cap noi reg `x' years_exp if project_status_nme!="Closed" & `y'==1
	}
}

*CORRELATION BETWEEN PROJECT TIMELINE AND TEAM MEMBERS
local var tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n ais_delcl_pn dec_cl_pn
foreach x of local var {
reg `x' totalmembers if project_status_nme!="Closed"
}

local var tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n ais_delcl_pn dec_cl_pn
foreach x of local var {
	foreach y of global gp {
		cap noi reg `x' totalmembers if project_status_nme!="Closed" & `y'==1
	}
}

save "`path'ttlproj_v2.dta", replace

	****************************************************************************
	*                   SPENDING DATA WITH TTL DATA                            *
	****************************************************************************

use "`path'spendingBPS_v2.dta", clear
merge m:m ProjectID using "`path'ttlproj_v2.dta"
save "`path'ttlprojspend.dta", replace

use "`path'ttlprojspend.dta", clear
drop if _merge==1
drop _merge

tabstat amount, stat(n mean)

 foreach y of global gp {
	cap noi tabstat amount if `y'==1, stat(n mean)
  }
  
local projtype `" "A" "L" "S""'
foreach x of local projtype {
		cap noi tabstat amount if prod_line_type=="`x'", stat(n mean)
}
  
local projtype `" "A" "L" "S""'
foreach x of local projtype {
	foreach y of global gp {
		cap noi tabstat amount if prod_line_type=="`x'" & `y'==1, stat(n mean)
	}
}
hist amount, percent

*GENERATING A YEARLY SPENDING VARIABLE FOR TTLs
estpost tabstat amount if project_status_nme=="Closed", stat(n mean) by(year) col(stat)
esttab using amountbyyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 

	foreach y of global gp {
		cap noi estpost tabstat amount if `y'==1 & project_status_nme=="Closed", stat(n mean) by(year) col(stat)
		cap noi esttab using amountbyyr`y'.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}

*GENERATING A YEARLY SPENDING VARIABLE FOR TTLs BY TYPE
local projtype `" "A" "L" "S" "'
foreach x of local projtype {
	estpost tabstat amount if prod_line_type=="`x'" & project_status_nme=="Closed", stat(n mean) by(year) col(stat)
	esttab using `x'amountbyyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}

local projtype `" "A" "L" "S" "'
foreach x of local projtype {
	foreach y of global gp {
		cap noi estpost tabstat amount if `y'==1 & prod_line_type=="`x'" & project_status_nme=="Closed", stat(n mean) by(year) col(stat)
		cap noi esttab using `x'amountbyyr`y'.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
	}
}

local projtype `" "A" "L" "S" "'
foreach x of local projtype {
	estpost tab prod_line_nme if prod_line_type=="`x'" 
	esttab using `x'.rtf, varlabels(`e(labels)') replace
}
save "`path'ttlprojspend_v2.dta", replace


	****************************************************************************
	*                   RATINGS DATA WITH PROJECT AND SPENDING DATA            *
	****************************************************************************
use "`path'ISR_updated_v2.dta", clear

merge 1:m ProjectID using "`path'ttlprojspend_v2.dta"
drop _merge
save "`path'ttlprojspendISR.dta", replace

use "`path'ieg_v2.dta", clear

merge m:m ProjectID using "`path'ttlprojspendISR.dta"

save "`path'ttlprojspendratings.dta", replace

use "`path'ttlprojspendratings.dta", clear

tabstat ISRrating_perc, stat(n mean sd)

	foreach y of global gp {
		cap noi tabstat ISRrating_perc if `y'==1
	}

*GENERATING A YEARLY ISR RATINGS FOR TTLs
gen isr_year=year(isr_date)
bysort team_leader_upi isr_year: egen TTL_ISRbyyr=mean(ISRrating_perc)
sum TTL_ISRbyyr

estpost tabstat TTL_ISRbyyr, stat(n mean sd) by(isr_year) col(stat)
esttab using TTL_ISRbyyr.rtf, cells("count mean(fmt(a3)) sd") varlabels(`e(labels)') replace 

	foreach y of global gp {
		cap noi bysort team_leader_upi isr_year: egen `y'TTL_ISRbyyr=mean(ISRrating_perc) if `y'==1
		cap noi estpost tabstat `y'TTL_ISRbyyr, stat(n mean sd) by(isr_year) col(stat)
		cap noi esttab using TTL_ISRbyyr`y'.rtf, cells("count mean(fmt(a3)) sd") varlabels(`e(labels)') replace 
	}


save "`path'ttlprojspendratings_v2.dta", replace

hist IEGrating, percent

*GENERATING A YEARLY IEG RATINGS FOR TTLs

bysort team_leader_upi IEG_evalyear: egen TTL_IEGbyyr=mean(IEGrating)
sum TTL_IEGbyyr
estpost tabstat TTL_IEGbyyr, stat(n mean sd) by(IEG_evalyear) col(stat)
esttab using TTL_IEGbyyr.rtf, cells("count mean(fmt(a3)) sd") varlabels(`e(labels)') replace 

foreach y of global gp {
	cap noi estpost tabstat TTL_IEGbyyr if `y'==1, stat(n mean sd) by(IEG_evalyear) col(stat)
	cap noi esttab using TTL_IEGbyyr`y'.rtf, cells("count mean(fmt(a3)) sd") varlabels(`e(labels)') replace 
}

*DISBURSEMENT
gen disbursement_amt_100k=ibrd_cmt_usd_amt_100k+ida_cmt_usd_amt_100k
replace disbursement_amt_100k=. if disbursement_amt_100k==0
hist disbursement_amt_100k if disbursement_amt_100k!=., percent

*GENERATING A YEARLY DISBURSEMENT AMOUNT FOR TTLs

bysort team_leader_upi year: egen TTL_disbyyr=mean(disbursement_amt_100k)
sum TTL_IEGbyyr
estpost tabstat TTL_disbyyr, stat(n mean) by(year) col(stat)
esttab using TTL_disbyyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 

foreach y of global gp {
	cap noi estpost tabstat TTL_disbyyr if `y'==1, stat(n mean) by(IEG_evalyear) col(stat)
	cap noi esttab using TTL_disbyyr`y'.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}
drop _merge
ren long_nme country_name
save "`path'ttlprojspendratings_v3.dta", replace
