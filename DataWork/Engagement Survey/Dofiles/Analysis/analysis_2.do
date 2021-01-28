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
		ssc install labutil, 	replace
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
		cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Engagement Survey\Outputs\Raw\EFI_IBRD_IFC"
	}

********************************************************************************

use "$onedrive\Intermediate\esGGE_2019_v2.dta", clear

*SET GRAPHICS 
set graphics on
grstyle init
grstyle set plain, horizontal
grstyle set color Accent: p#bar p#barline
grstyle set intensity 40: bar

********************************************************************************
*					OVERALL AGILITY INDEX ANALYSIS
********************************************************************************
keep if agileindex==1
gl barcol5 "bar(1, fcolor(dkgreen) lcolor(dkgreen)) bar(2, fcolor(green%60) lcolor(green%60)) bar(3, fcolor(gray) lcolor(gray)) bar(4, fcolor(red) lcolor(red))	bar(5, fcolor(maroon) lcolor(maroon))"														///

gl barcol3 "bar(1, fcolor(dkgreen) lcolor(dkgreen)) bar(2, fcolor(gray) lcolor(gray)) bar(3, fcolor(maroon) lcolor(maroon))"

gl barleg5 `"legend(lab(1 "Very Favorable") lab(2 "Somewhat Favorable") lab(3 "Neutral") lab(4 "Somewhat Unfavorable") lab(5 "Very Unfavorable") size(vsmall))"'

gl barleg3 `"legend(lab(1 "Favorable") lab(2 "Neutral") lab(3 "Unfavorable") size(vsmall))"'

gl graphset "graphregion(color(white)) bgcolor(white)"

gl blabel "blabel(bar,  pos(center) format(%9.0f))"

gl bargap "outergap(20) bargap(30)"

gl setscale "pfav pneut punfav"

gl setsort "pfav"

*SETTING MEDIAN VALUES FOR ALL SCORES AT ORG AVERAGE, PG AVERAGE, REG AVERAGE, GP AVERAGE
sum pfav if level=="Org Report" & division=="IBRD", d
global medianibrd = trim("`: display %9.2fc r(p50)'")

sum pfav if level=="Org Report" & division=="IFC", d
global medianifc = trim("`: display %9.2fc r(p50)'")

global medianwbg = 62

sum pfav if level=="GP Report", d
global mediangp = trim("`: display %9.2fc r(p50)'")

foreach reg in AFR MNA LCR ECA EAP SAR  {
sum pfav if level=="VPU-REG Report" & region=="`reg", d
gl median`reg' = trim("`: display %9.2fc r(p50)'")
}

*OVERALL AGILITY
preserve
bysort division: egen sortfav = mean(pcat5+pcat4) if level=="Org Report"
graph hbar (mean) $setscale if level=="Org Report", 				///
	over(division, sort($setsort ) label(labsize(small)))	stack												///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars ///
	yline($medianwbg , lcolor(black) lpattern(dash)) 					///
	ytitle("Proportion of Reponses", size(small)) ylab($medianwbg "WBG Avg: 62", labsize(vsmall))	///
	title( "Overall Agility by Organizations", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_overall.png, as(png) name("Graph") replace
restore

*AGILITY BY GPs BY ORG
preserve
bysort division org: egen sortfav = mean(pcat5+pcat4) if level=="GP Report"
egen div_org = concat(division org), punct("-")
graph hbar (mean) $setscale if level=="GP Report", 				///
	over(div_org, sort($setsort ) label(labsize(small))) stack ///
	yline($medianwbg , lcolor(black) lpattern(dash))  ///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars					///
		ylab($medianwbg "WBG Avg: 62", labsize(vsmall)) ///
	ytitle("Proportion of Reponses", size(small))												///
	title( "GP Agility by Organizations", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_gp_org.png, as(png) name("Graph") replace
restore

*AGILITY BY ORG-REG OVERALL
preserve
bysort org: egen sortfav = mean(pcat5+pcat4) if region!="" & org!="IBRD/IFC" & org!=""
graph hbar (mean) $setscale if region!="" & org!="IBRD/IFC", 								///
	over(org, sort($setsort ) label(labsize(small))) ///
	yline($medianwbg , lcolor(black) lpattern(dash)) stack				///
		ylab($medianwbg "WBG Avg", labsize(vsmall)) ///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 					///
	ytitle("Proportion of Reponses", size(small))												///
	title( "Overall Regional Agility by Organizations", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_regional.png, as(png) name("Graph") replace
restore

*AGILITY BY REG BY ORG
foreach x in IBRD IFC {
bysort region: egen sortfav = mean(pcat5+pcat4) if region!="" & org!="IBRD/IFC" & org=="`x'"
graph hbar (mean) $setscale if region!="" & org!="IBRD/IFC" & org=="`x'", 								///
	over(region, sort($setsort ) label(labsize(small))) ///
	yline($medianwbg , lcolor(black) lpattern(dash)) stack				///
		ylab($medianwbg "WBG Avg", labsize(vsmall)) ///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 					///
	ytitle("Proportion of Reponses", size(small))												///
	title( "Overall Regional Agility in `x'", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_regional_`x'.png, as(png) name("Graph") replace
drop sortfav
}

*AGILITY BY ORG-REG BY REG
foreach x in AFR EAP ECA LCR MNA SAR {
bysort division: egen sortfav = mean(pcat5+pcat4) if level=="VPU-ORG-REG Report"
graph hbar (mean) $setscale if level=="VPU-ORG-REG Report" & (division=="`x'-IBRD"|division=="`x'-IFC"), 	///
	over(division, sort($setsort ) label(labsize(small))) ///
	yline($medianwbg , lcolor(black) lpattern(dash)) stack				///
		ylab($medianwbg "WBG Avg", labsize(vsmall)) ///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 					///
	ytitle("Proportion of Reponses", size(small))												///
	title( "Organizational Agility in `x'", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_org_`x'.png, as(png) name("Graph") replace
drop sortfav
}

********************************************************************************
*						INDICATORS ANALYSIS
********************************************************************************

gl a "Managmt Agility" 
gl b "Process Agility" 
gl c "Goal Orientation" 
gl d "Innovation" 
gl e "Collaboration" 
gl f "Learning & Development" 


	sum pfav if level=="WBG Report", d
	gl medianag = trim("`: display %9.2fc r(p50)'")

foreach reg in AFR MNA LCR ECA EAP SAR  {
}
foreach pmu in EFI HD INFRA SD {
sum pfav if level=="VPU-PG Report" & pmu=="`pmu'", d
gl median`pmu'`x' = trim("`: display %9.2fc r(p50)'")
}


foreach x in a b c d e f {
	preserve
	keep if agileindicator=="$`x'"
	
*OVERALL AGILITY
bysort division: egen sortfav = mean(pcat5+pcat4) if level=="Org Report"
graph hbar (mean) $setscale if level=="Org Report", 				///
	over(division, sort($setsort ) label(labsize(small)))	stack												///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars ///					///
	ytitle("Proportion of Reponses", size(small))	///
	title( "$`x' by Organizations", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_overall_`x'.png, as(png) name("Graph") replace
drop sortfav

*AGILITY BY GPs BY ORG
bysort division org: egen sortfav = mean(pcat5+pcat4) if level=="GP Report"
egen div_org = concat(division org), punct("-")
graph hbar (mean) $setscale if level=="GP Report", 				///
	over(div_org, sort($setsort ) label(labsize(small))) stack ///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars	///
	ytitle("Proportion of Reponses", size(small))												///
	title( "GP $`x' by Organizations", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_gp_org_`x'.png, as(png) name("Graph") replace
drop sortfav

*AGILITY BY ORG-REG OVERALL
bysort org: egen sortfav = mean(pcat5+pcat4) if region!="" & org!="IBRD/IFC" & org!=""
graph hbar (mean) $setscale if region!="" & org!="IBRD/IFC", 								///
	over(org, sort($setsort ) label(labsize(small))) stack				///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 					///
	ytitle("Proportion of Reponses", size(small))												///
	title( "Overall Regional $`x' by Organizations", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_regional_`x'.png, as(png) name("Graph") replace
drop sortfav

*AGILITY BY REG BY ORG
foreach z in IBRD IFC {
bysort region: egen sortfav = mean(pcat5+pcat4) if region!="" & org!="IBRD/IFC" & org=="`z'"
graph hbar (mean) $setscale if region!="" & org!="IBRD/IFC" & org=="`z'", 								///
	over(region, sort($setsort ) label(labsize(small))) ///
	yline($medianwbg , lcolor(black) lpattern(dash)) stack				///
		ylab($medianwbg "WBG Avg", labsize(vsmall)) ///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 					///
	ytitle("Proportion of Reponses", size(small))												///
	title( "Overall Regional Agility in `z'", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_regional_`z'_`x'.png, as(png) name("Graph") replace
drop sortfav
}


*AGILITY BY ORG-REG BY REG
foreach y in AFR EAP ECA LCR MNA SAR {
bysort division: egen sortfav = mean(pcat5+pcat4) if level=="VPU-ORG-REG Report"
graph hbar (mean) $setscale if level=="VPU-ORG-REG Report" & (division=="`y'-IBRD"|division=="`y'-IFC"), 	///
	over(division, sort($setsort ) label(labsize(small))) stack				///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 					///
	ytitle("Proportion of Reponses", size(small))							///
	title( "Organizational $`x' in `y'", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_org_`y'_`x'.png, as(png) name("Graph") replace
drop sortfav
}
restore
}

********************************************************************************
*					ANALYSIS BY EACH LEVEL OF OBSERVATION
********************************************************************************

*ORGANIZATION LEVEL
*********************************************

ttest pfav if level=="Org Report", by(division)
foreach x in a b c d e f {
ttest pfav if agileindicator=="$`x'" & level=="Org Report", by(division)
}

preserve
collapse (mean) pfav if level=="Org Report", by(division)
gen indicator="Agility"
save "$onedrive\Intermediate\temp1.dta", replace
restore
foreach x in a b c d e f {
	preserve
	collapse (mean) pfav if agileindicator=="$`x'" & (level=="Org Report"), by(division)
	gen indicator="$`x'"
	save "$onedrive\Intermediate\temp`x'.dta", replace
	restore
}
preserve
use "$onedrive\Intermediate\temp1.dta", clear
foreach x in a b c d e f {
append using "$onedrive\Intermediate\temp`x'.dta"
}
encode division, gen(division_n)
tab division
encode indicator, gen(indicator_n)
tab indicator
format pfav %9.0f
save "$onedrive\Intermediate\temp.dta", replace
restore

preserve
use "$onedrive\Intermediate\temp.dta", clear

twoway 	(sc   indicator_n  pfav if division_n==1, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc  indicator_n pfav     if division_n==2, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)), 					///
	xtitle("Proportion of Responses")	graphregion(color(white)) bgcolor(white) 	///
	xlabel(30(5)80)	ytitle("")							///
	ylabel(1 "Overall Agility" 2 "Collaboration" 3 "Goal Orientation" 4 "Innovation"	///
			5 "Learning & Development" 6 "Managmt Agility" 7 "Process Agility", angle(0))		///
	title( "Proportion of Favorable Responses at Organization Level", size(medium)) 			///
	legend(label(1 IBRD) label(2 IFC))  legend(order(1 2))								///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_org.png, as(png) name("Graph") replace
restore

*AGILITY BY GPs BY ORG
*********************************************
egen div_org = concat(division org), punct("-")
preserve
collapse (mean) pfav if level=="GP Report", by(division org)
gen indicator="Agility"
save "$onedrive\Intermediate\temp1.dta", replace
restore
foreach x in a b c d e f {
	preserve
	collapse (mean) pfav if agileindicator=="$`x'" & level=="GP Report", by(div_org)
	gen indicator="$`x'"
	save "$onedrive\Intermediate\temp`x'.dta", replace
	restore
}
preserve
use "$onedrive\Intermediate\temp1.dta", clear
foreach x in a b c d e f {
append using "$onedrive\Intermediate\temp`x'.dta"
}
encode div_org, gen(div_org_n)
tab div_org
encode indicator, gen(indicator_n)
tab indicator
format pfav %9.0f
save "$onedrive\Intermediate\temp.dta", replace
restore
preserve
use "$onedrive\Intermediate\temp.dta", clear

twoway 	(sc indicator_n pfav    if div_org_n==1, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if div_org_n==2, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if div_org_n==3, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if div_org_n==4, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if div_org_n==5, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if div_org_n==6, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///									
		(sc indicator_n pfav     if div_org_n==7, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)), 					///									
	xtitle("Proportion of Responses")	graphregion(color(white)) bgcolor(white) 	///
	xlabel(40(5)80)	ytitle("")							///
	ylabel(1 "Overall Agility" 2 "Collaboration" 3 "Goal Orientation" 4 "Innovation"	///
			5 "Learning & Development" 6 "Managmt Agility" 7 "Process Agility", angle(0))		///
	title( "Proportion of Favorable Responses at GP Level", size(medium)) 			///
	legend(label(1 FCI-IBRD/IFC) label(2 GOV-PS/FM-IBRD) label(3 GOV-Proc-IBRD)		///
			label(4 MTI-IBRD/IFC) label(5 POV-IBRD) label(6 Prospects-IBRD) label(7 TIC-IBRD/IFC) size(vsmall)) 	///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_gp.png, as(png) name("Graph") replace
restore

*AGILITY BY ORG-REG OVERALL
*********************************************
preserve
collapse (mean) pfav if region!="" & org!="IBRD/IFC" & org!="", by(org)
gen indicator="Agility"
save "$onedrive\Intermediate\temp1.dta", replace
restore
foreach x in a b c d e f {
	preserve
	collapse (mean) pfav if agileindicator=="$`x'" & region!="" & org!="IBRD/IFC" & org!="", by(org)
	gen indicator="$`x'"
	save "$onedrive\Intermediate\temp`x'.dta", replace
	restore
}
preserve
use "$onedrive\Intermediate\temp1.dta", clear
foreach x in a b c d e f {
append using "$onedrive\Intermediate\temp`x'.dta"
}
encode org, gen(org_n)
tab org_n
encode indicator, gen(indicator_n)
tab indicator
format pfav %9.0f
save "$onedrive\Intermediate\temp.dta", replace
restore
preserve
use "$onedrive\Intermediate\temp.dta", clear
twoway 	(sc indicator_n pfav    if org_n==1, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if org_n==2, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)), 					///
	xtitle("Proportion of Responses")	graphregion(color(white)) bgcolor(white) 	///
	xlabel(50(5)90)	ytitle("")							///
	ylabel(1 "Overall Agility" 2 "Collaboration" 3 "Goal Orientation" 4 "Innovation"	///
			5 "Learning & Development" 6 "Managmt Agility" 7 "Process Agility", angle(0))		///
	title( "Proportion of Favorable Responses at Region Level", size(medium)) 			///
	legend(label(1 IBRD) label(2 IFC)) 								///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_reg_overall.png, as(png) name("Graph") replace
restore

*AGILITY BY REG BY ORG
*************************************************
foreach y in IBRD IFC {
preserve
collapse (mean) pfav if region!="" & org!="IBRD/IFC" & org=="`y'", by(region)
gen indicator="Agility"
save "$onedrive\Intermediate\temp1.dta", replace
restore
foreach x in a b c d e f {
	preserve
	collapse (mean) pfav if agileindicator=="$`x'" & region!="" & org!="IBRD/IFC" & org=="`y'", by(region)
	gen indicator="$`x'"
	save "$onedrive\Intermediate\temp`x'.dta", replace
	restore
}
preserve
use "$onedrive\Intermediate\temp1.dta", clear
foreach x in a b c d e f {
append using "$onedrive\Intermediate\temp`x'.dta"
}
encode region, gen(region_n)
tab region_n
encode indicator, gen(indicator_n)
tab indicator
format pfav %9.0f
save "$onedrive\Intermediate\temp.dta", replace
restore
preserve
use "$onedrive\Intermediate\temp.dta", clear
twoway 	(sc indicator_n pfav    if region_n==1, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if region_n==2, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12))					///
		(sc indicator_n pfav     if region_n==3, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12))					///
		(sc indicator_n pfav     if region_n==4, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12))					///		
		(sc indicator_n pfav     if region_n==5, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12))					///									
		(sc indicator_n pfav     if region_n==6, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)), 					///									
	xtitle("Proportion of Responses")	graphregion(color(white)) bgcolor(white) 	///
	xlabel(50(5)90)	ytitle("")							///
	ylabel(1 "Overall Agility" 2 "Collaboration" 3 "Goal Orientation" 4 "Innovation"	///
			5 "Learning & Development" 6 "Managmt Agility" 7 "Process Agility", angle(0))		///
	title( "Proportion of Favorable Responses at Region Level in `y'", size(medium)) 			///
	legend(label(1 AFR) label(2 EAP) label(3 ECA) label(4 "LCR") label(5 "MNA") label(6 "SAR")) 								///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_reg_`y'.png, as(png) name("Graph") replace
restore
}	

*AGILITY BY ORG-REG BY REG
*********************************************
foreach y in AFR EAP ECA LCR MNA SAR {
preserve
collapse (mean) pfav if level=="VPU-ORG-REG Report" & (division=="`y'-IBRD"|division=="`y'-IFC"), by(division)
gen indicator="Agility"
save "$onedrive\Intermediate\temp1.dta", replace
restore
foreach x in a b c d e f {
	preserve
	collapse (mean) pfav if agileindicator=="$`x'" & level=="VPU-ORG-REG Report" & (division=="`y'-IBRD"|division=="`y'-IFC"), by(division)
	gen indicator="$`x'"
	save "$onedrive\Intermediate\temp`x'.dta", replace
	restore
}
preserve
use "$onedrive\Intermediate\temp1.dta", clear
foreach x in a b c d e f {
append using "$onedrive\Intermediate\temp`x'.dta"
}
encode division, gen(division_n)
tab division
encode indicator, gen(indicator_n)
tab indicator
format pfav %9.0f
save "$onedrive\Intermediate\temp.dta", replace
restore
preserve
use "$onedrive\Intermediate\temp.dta", clear
twoway 	(sc indicator_n pfav    if division_n==1, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if division_n==2, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)), 					///									
	xtitle("Proportion of Responses")	graphregion(color(white)) bgcolor(white) 	///
	xlabel(25(5)75)	ytitle("")							///
	ylabel(1 "Overall Agility" 2 "Collaboration" 3 "Goal Orientation" 4 "Innovation"	///
			5 "Learning & Development" 6 "Managmt Agility" 7 "Process Agility", angle(0))		///
	title( "Proportion of Favorable Responses in `y'", size(medium)) 			///
	legend(label(1 IBRD) label(2 IFC)) 								///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_org_`y'.png, as(png) name("Graph") replace
restore
}
