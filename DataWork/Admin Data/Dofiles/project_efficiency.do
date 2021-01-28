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
									
	local	master_clean	0	// 	Clean the project dta
	
	
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

global gp fci tr gov edu
********************************************************************************
*						PART 3:  Run selected sections						   *
********************************************************************************
	
* ------------------------------------------------------------------------------
* 							Cleaning all the data
* ------------------------------------------------------------------------------
	
	if `master_clean'		do "$github\master_clean.do"
	
* ------------------------------------------------------------------------------
	****************************************************************************
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

	foreach y of global gp {
bysort year: egen ttlprojbyyr`y' = mean(ttlprojbyyr) if `y'==1 
}
bysort year: egen ttlprojbyyrmean = mean(ttlprojbyyr) 

*LINE GRAPH FOR YEARLY PROJECTS 
scatter ttlprojbyyrfci year if year>=2000 
sort year
twoway 		line 	ttlprojbyyrfci 	year if year>=2000 	||						///
			line 	ttlprojbyyrtr 	year if year>=2000	||						///
			line 	ttlprojbyyrgov 	year if year>=2000	||						///
			line 	ttlprojbyyredu	year if year>=2000	||						///
			lfit	ttlprojbyyrmean year if year>=2000
		

*GENERATING A YEARLY PROJECT VARIABLE FOR TTLs BY TYPE
local projtype `" "A" "L" "S" "'
foreach x of local projtype {
	bysort team_leader_upi year: egen `x'projbyyr=count(projid_nr) if prod_line_type=="`x'"
	sum `x'projbyyr
	estpost tabstat `x'projbyyr, stat(n mean) by(year) col(stat)
	esttab using `x'projbyyr.rtf, cells("count mean(fmt(a3))") varlabels(`e(labels)') replace 
}
gen gp=""
replace gp="FCI" if fci==1
replace gp="EDU" if edu==1
replace gp="GOV" if gov==1
replace gp="TRANSPORT" if tr==1

*TIME OVERRUN BY GPs
preserve
drop if proj_stat_code=="C"
collapse (mean) tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n, by(gp)
drop if gp==""
rename (tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n)			///
		(tovr1 tovr2 tovr3)
reshape long tovr, i(gp) j(timeoverrun)
tostring timeoverrun, replace force
replace timeoverrun="Closing Date" if timeoverrun=="1"
replace timeoverrun="Decision Meeting" if timeoverrun=="2"
replace timeoverrun="Delivery to Client" if timeoverrun=="3"

bysort timeoverrun: egen meantovr = mean(tovr)
gen difftovr = tovr-meantovr

graph hbar difftovr,															///
	over(gp, label(labsize(small)) relabel(`r(relabel)'))						///
	over(timeoverrun, label(labsize(small)) relabel(`r(relabel)')) 				///
	yline(0) ylabel(-180(40)140)												///
	outergap(30) bargap(40) showyvars legend(off) 								///	
	blabel(bar, format(%9.1f) size(small)) 										///
	ytitle("Days of Delay on Active Projects", size(small))						///
	graphregion(color(white)) bgcolor(white) plotregion(color(white))			///
	title( "Days of Delay on Active Projects by Operational Units", size(medium))	///
	subtitle("Difference from the Global Average", size(small)) asyvars			///
	note("Source: World Bank Project and Staff Data", size(vsmall)) 
graph export tovrbyunits.png, as(png) name("Graph") replace			
restore

*MISSED MILESTONES BY GPs
preserve
drop if proj_stat_code=="C"
collapse (mean) tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n, by(gp)
drop if gp==""
rename (tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n)			///
		(tovr1 tovr2 tovr3)
reshape long tovr, i(gp) j(timeoverrun)
tostring timeoverrun, replace force
replace timeoverrun="Closing Date" if timeoverrun=="1"
replace timeoverrun="Decision Meeting" if timeoverrun=="2"
replace timeoverrun="Delivery to Client" if timeoverrun=="3"

bysort timeoverrun: egen meantovr = mean(tovr)
gen difftovr = tovr-meantovr

graph hbar difftovr,															///
	over(gp, label(labsize(small)) relabel(`r(relabel)'))						///
	over(timeoverrun, label(labsize(small)) relabel(`r(relabel)')) 				///
	yline(0) ylabel(-110(20)90)													///
	outergap(30) bargap(40) showyvars legend(off) 								///	
	blabel(bar, format(%9.1f) size(small)) 										///
	ytitle("Days of Delay", size(small))										///
	graphregion(color(white)) bgcolor(white) plotregion(color(white))			///
	title( "Days of Delay by Operational Units", size(medium))					///
	subtitle("Difference from the Global Average", size(small)) asyvars			///
	note("Source: World Bank Project and Staff Data", size(vsmall)) 
graph export tovrbyunits.png, as(png) name("Graph") replace			
restore

*GENERATING NEW VARIABLE FOR YEAR 
egen lastyearactive = rowmax(	final_dlvry_date_n 	dlvry_to_client_date_n 		///
								auth_to_appraisal_neg_date_n decision_mtg_date_n ///
								ais_start_concept_nte_date_n ais_signoff_date_n)
replace lastyearactive = yofd(lastyearactive)
tab lastyearactive
*GENERATING VARIABLES FOR MISSED MILESTONES
bysort gp lastyearactive: egen projbygpyr = count(Position)
local tovr tovr_act_prep_n tovr_delivery_n tovr_del_to_client_n tovr_decision_mtg_n tovr_ais_signoff_n tovr_closing_date_n
foreach x of local tovr {
	gen `x'_miss = 1 if `x'!=. & proj_stat_code=="C"
	bysort gp lastyearactive: egen `x'_c = count(`x'_miss) if proj_stat_code=="C"
	bysort gp lastyearactive: gen `x'_p = `x'_c/projbygpyr if proj_stat_code=="C"
}

*LINE GRAPH FOR YEARLY MISSED MILESTONES 
local tovr tovr_act_prep_n tovr_delivery_n tovr_del_to_client_n tovr_decision_mtg_n tovr_ais_signoff_n tovr_closing_date_n
foreach x of local tovr {
foreach y of global gp {
	gen `x'_p`y' = `x'_p if `y'==1 & proj_stat_code=="C"
}
bysort lastyearactive: egen `x'_pmean = mean(`x'_p) if proj_stat_code=="C"
}
preserve 
drop if proj_stat_code=="A"
sort lastyearactive

local tovr tovr_act_prep_n tovr_delivery_n tovr_del_to_client_n tovr_decision_mtg_n tovr_ais_signoff_n tovr_closing_date_n
foreach x of local tovr {
	twoway 	line 	`x'_pfci 	lastyearactive if lastyearactive>=2000 			///
												& lastyearactive<=2018 	||		///
			line 	`x'_ptr 	lastyearactive if lastyearactive>=2000 			///
												& lastyearactive<=2018	||		///
			line 	`x'_pgov 	lastyearactive if lastyearactive>=2000 			///
												& lastyearactive<=2018	||		///
			line 	`x'_pedu	lastyearactive if lastyearactive>=2000 			///
												& lastyearactive<=2018	||		///
			lfit	`x'_pmean 	lastyearactive if lastyearactive>=2000 			///
												& lastyearactive<=2018,			///
	ytitle("Proportion of Missed Milestones", size(small))				///
	xtitle("Year", size(small))													///
	legend(	label(1 "FCI") 			label(2 "Transport") 						///
			label(3 "Governance") 	label(4 "Education")						///
			label(5	"Overall"))		lcolor(5 "black")							///
	graphregion(color(white)) bgcolor(white) plotregion(color(white))			///
	title( "Overall Days of Delay Over Time", size(medium))						///
	note("Source: World Bank Project and Staff Data", size(vsmall)) 
graph export `x'byunits.png, as(png) name("Graph") replace		
}	

sort lastyearactive
twoway 		line 	tovr_act_prep_n_pmean 		lastyearactive 					///
				if 	lastyearactive>=2000 	& 	lastyearactive<=2018 ||			///
			line 	tovr_delivery_n_pmean 		lastyearactive 					///
				if 	lastyearactive>=2000 	& 	lastyearactive<=2018 ||			///
			line 	tovr_del_to_client_n_pmean 	lastyearactive 					///
				if  lastyearactive>=2000 	& 	lastyearactive<=2018 ||			///
			line 	tovr_decision_mtg_n_pmean	lastyearactive 					///
				if  lastyearactive>=2000 	& 	lastyearactive<=2018 ||			///
			line	tovr_ais_signoff_n_pmean	lastyearactive					///
				if	lastyearactive>=2000	&	lastyearactive<=2018 ||			///
			line 	tovr_closing_date_n_pmean	lastyearactive					///
				if	lastyearactive>=2000	&	lastyearactive<=2018,			///					
	ytitle("Overall Proportion of Missed Milestones", size(small))				///
	legend(	label(1 "Activity Preperation") label(2 "Delivery") 				///
			label(3 "Delivery to Client") 	label(4 "Decision Meeting")			///
			label(5	"Sign off")				label(6	"Closing"))					///
	graphregion(color(white)) bgcolor(white) plotregion(color(white))			///
	title( "Overall Days of Delay Over Time", size(medium))						///
	note("Source: World Bank Project and Staff Data", size(vsmall)) 
graph export tovrbytime.png, as(png) name("Graph") replace			

restore

/*CORRELATION BETWEEN PROJECT TIMELINE AND NUMBER OF PROJECTS FOR TTLs
local var tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n ais_delcl_pn dec_cl_pn
foreach x of local var {
	reg `x' totalttlproj if project_status_nme!="Closed"
	predict hat`x'
	qui sum `x' if project_status_nme!="Closed"
	replace hat`x'=hat`x'-r(mean)
	predict stdf`x'
	}
	graph dot hattovr_closing_date_n hattovr_decision_mtg_n hattovr_del_to_client_n hatais_delcl_pn hatdec_cl_pn,		///
	outergap(20) bargap(30) showyvars legend(off) 	yline(0)						///	
	yvaroptions(relabel(1 "Closing Date" 2 "Decision Meeting" 3 "Delivery to Client" 4 "Sign-off to Delivery"	///
						5 "Decision to Closing"))			///
	blabel(bar, format(%9.1f) size(small)) 									///
	ytitle("Proportion of total time recorded", size(small))					///
	graphregion(color(white)) bgcolor(white)									///
	title( "Menu of Activities Performed by Staff", size(medium))				///
	subtitle(" ")																///
	note("Source: Dummy data extrapolated through pilot Task Check-in", size(vsmall)) 


/*
local var tovr_closing_date_n tovr_decision_mtg_n tovr_del_to_client_n ais_delcl_pn dec_cl_pn
foreach x of local var {
	foreach y of global gp {
		cap noi reg `x' totalttlproj if project_status_nme!="Closed" & `y'==1
		cap noi margins, at(totalttlproj=(1(1)10))vsquish
		cap noi marginsplot, recast(line) recastci(rcap) title("") ytitle("predicted `x'")
	}
}

