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
		cd 	"C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Engagement Survey\Outputs\Raw\ThreePoint"
	}

********************************************************************************

use "$onedrive\Intermediate\es_2019_v2.dta", clear

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

*SETTING MEDIAN VALUES FOR ALL SCORES AT WB AVERAGE, REGION AVERAGE, PG AVERAGE
sum pfav if level=="WBG Report", d
global medianwbg = trim("`: display %9.2fc r(p50)'")

foreach reg in AFR MNA LCR ECA EAP SAR  {
sum pfav if level=="VPU-REG Report" & pmu=="`reg", d
gl median`reg' = trim("`: display %9.2fc r(p50)'")
}
foreach pg in EFI HD INFRA SD {
sum pfav if level=="VPU-PG Report" & pmu=="`pg'", d
gl median`pg' = trim("`: display %9.2fc r(p50)'")
}
*OVERALL AGILITY
preserve
bysort divison: egen sortfav = mean(pcat5+pcat4) if level=="Org Report"|level=="WBG Report"
graph hbar (mean) $setscale if level=="Org Report"|level=="WBG Report", 				///
	over(divison, sort($setsort ) label(labsize(small)))	stack												///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 					///
	ytitle("Proportion of Reponses", size(small))												///
	title( "Overall Proportion of Responses in Agility Index", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_overall.png, as(png) name("Graph") replace
restore

*AGILITY BY REGION/PG/VPU 
preserve
bysort divison: egen sortfav = mean(pcat5+pcat4) if level=="VPU-REG Report"|level=="VPU-PG Report"|level=="VPU Report"

graph hbar (mean) $setscale if level=="VPU-REG Report"|level=="VPU-PG Report"|level=="VPU Report", 				///
	over(level, sort($setsort ) label(labsize(small))) stack ///
	yline($medianwbg , lcolor(black) lpattern(dash))  ///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars					///
		ylab($medianwbg "WBG Avg", labsize(vsmall)) ///
	ytitle("Proportion of Reponses", size(small))												///
	title( "Proportion of Responses in Agility Index by Mapping", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_vpu_ag.png, as(png) name("Graph") replace
restore

*AGILITY BY VPU-REG 
preserve
bysort divison: egen sortfav = mean(pcat5+pcat4) if level=="VPU-REG Report"
graph hbar (mean) $setscale if level=="VPU-REG Report", 								///
	over(divison, sort($setsort ) label(labsize(small))) ///
	yline($medianwbg , lcolor(black) lpattern(dash)) stack				///
		ylab($medianwbg "WBG Avg", labsize(vsmall)) ///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 					///
	ytitle("Proportion of Reponses", size(small))												///
	title( "Regional Proportion of Responses in Agility Index", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_regional.png, as(png) name("Graph") replace
restore

*AGILITY BY VPU-PG 
preserve
bysort divison: egen sortfav = mean(pcat5+pcat4) if level=="VPU-PG Report"
graph hbar (mean) $setscale if level=="VPU-PG Report", 									///
	over(divison, sort($setsort ) label(labsize(small)))	///
	yline($medianwbg , lcolor(black) lpattern(dash)) stack		///
		ylab($medianwbg "WBG Avg", labsize(vsmall)) ///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 				///
	ytitle("Proportion of Reponses", size(small))												///
	title( "PG Level Proportion of Responses in Agility Index", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_pg.png, as(png) name("Graph") replace
restore

*AGILITY BY VPU 
preserve
bysort divison: egen sortfav = mean(pcat5+pcat4) if level=="VPU Report"
graph hbar (mean) $setscale if level=="VPU Report", 									///
	over(divison, sort($setsort ) label(labsize(small)))	///
	yline($medianwbg , lcolor(black) lpattern(dash)) stack	///
	ylab($medianwbg "WBG Avg", labsize(vsmall)) ///
	$bargap $blabel $barcol3 $barleg3 $graphset  showyvars			///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)									///
	title( "VPU Level Proportion of Responses in Agility Index", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_vpu.png, as(png) name("Graph") replace
restore 

*AGILITY BY GP 
preserve
bysort divison: egen sortfav = mean(pcat5+pcat4) if level=="GP Report"
*replace gpcode = "GOV" if gpcode=="GOV-Proc" | gpcode=="Gov - PS/FM"
graph hbar (mean) $setscale if gpcode!="",		///
	over(gpcode, sort($setsort ) label(labsize(small))) 	///
	yline($medianwbg , lcolor(black) lpattern(dash)) stack			///
		ylab($medianwbg "WBG Avg", labsize(vsmall)) ///
	$bargap $blabel $barcol3 $barleg3 $graphset  showyvars 			///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)									///
	title( "GP Level Proportion of Responses in Agility Index", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_gp.png, as(png) name("Graph") replace
restore

*AGILITY BY PG-GP 
foreach pg in EFI HD INFRA SD {
    	sum pfav if pmu=="`pg'" & gpcode!="", d
		gl medianpg = trim("`: display %9.2fc r(p50)'")
    preserve
bysort divison: egen sortfav`x' = mean(pcat5+pcat4) if gpcode!="" & pmu=="`pg'"
graph hbar (mean) $setscale if gpcode!="" & pmu=="`pg'", 									///
	over(gpcode, sort($setsort ) label(labsize(small))) ///
	yline($medianwbg, lcolor(black) lpattern(dash)) stack		///
	yline($medianpg, lcolor(green) lpattern(dash))			///
	ylab($medianwbg "WBG" $medianpg "PG", angle(90) labsize(vsmall))  ///
	$bargap $blabel $barcol3 $barleg3 $graphset	 showyvars 		 ///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)									///
	title( "GP Level Scores in Agility Index for `x'", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_agile_gp`pg'.png, as(png) name("Graph") replace
restore
}

*AGILITY BY PG-Region-Unit Ag level
	foreach pg in EFI HD INFRA SD {
		sum pfav if level=="PG-Region Unit" & pmu=="`pg'", d
		gl medianpg = trim("`: display %9.2fc r(p50)'")
	  preserve
bysort divison: egen sortfav = mean(pcat5+pcat4) if level=="PG-Region Unit"
cap noi graph hbar (mean) $setscale if level=="PG-Region Unit" & pmu=="`pg'", 									///
	over(region, sort($setsort) label(labsize(small))) ///
	yline($medianwbg, lcolor(black) lpattern(dash)) stack		///
	yline($medianpg, lcolor(green) lpattern(dash))			///
	ylab($medianwbg "WBG" $medianpg "PG", angle(90) labsize(vsmall))  ///
	$bargap $blabel $barcol3 $barleg3 $graphset				 ///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)									///
	title( "Region Unit Level Scores in Agility Index for `pg'", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
cap noi graph export avg_agile_regag`pg'.png, as(png) name("Graph") replace
restore
}

*AGILITY BY Region-PG-Unit Ag level
	foreach reg in AFR MNA LCR ECA EAP SAR {
		preserve
	    sum pfav if level=="PG-Region Unit" & region=="`reg'", d
		gl medianreg = trim("`: display %9.2fc r(p50)'")
cap noi graph hbar (mean) $setscale if level=="PG-Region Unit" & region=="`reg'", 				///
	over(pmu, sort($setsort) label(labsize(small))) ///
	yline($medianwbg, lcolor(black) lpatter(dash)) stack ///
	yline($medianreg, lcolor(green) lpattern(dash))			///
	ylab($medianwbg "WBG" $medianreg "REG", angle(90) labsize(vsmall))  ///
	$bargap $blabel $barcol3 $barleg3 $graphset				 ///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)									///
	title( "PG Unit Level Scores in Agility Index for `reg'", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
cap noi graph export avg_agile_pgag`reg'.png, as(png) name("Graph") replace
restore
}

*AGILITY BY Region-PG-Unit level
	  preserve
cap noi graph hbar (mean) $setscale if level=="PG-Region Unit", 									///
	over(divison, sort($setsort) label(labsize(small))) ///
	yline($medianwbg, lcolor(black) lpatter(dash)) stack ///
	ylab($medianwbg "WBG", angle(90) labsize(vsmall))  ///
	$bargap $blabel $barcol3 $barleg3 $graphset				 ///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)									///
	title( "PG Unit Level Scores in Agility Index", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
cap noi graph export avg_agile_unitregion.png, as(png) name("Graph") replace
restore


/*AGILITY BY EACH VPU REGION UNIT
foreach pmu in "GGE" "GGH" "GGI" "GGS" {
foreach reg in "AFR" "EAP" "ECA" "LCR" "MNA" "SAR" {
	preserve
	cap noi collapse pfav pneut punfav if level=="Unit/Dept Report" & pmu=="`pmu'" & 		///
		regionunitname=="`reg'", by(divison)
	cap noi egen pfav_max=max(pfav)
	cap noi egen punfav_max=max(punfav)
	cap noi format pfav pneut punfav %9.0f
	cap noi encode divison, gen(divison_n)
	cap noi gen pfav_m=divison_n if pfav_m==pfav
	cap noi gen punfav_m=divison_n if punfav_m==punfav	
	cap noi egen pfav_mn=max(pfav_m)
	cap noi replace pfav_mn=pfav_mn-0.5
	cap noi egen punfav_mn=max(punfav_m)
	cap noi replace punfav_mn=punfav_mn-0.5
	cap noi gl pfav=pfav_mn
	cap noi gl punfav=punfav_mn
	cap noi gen zero=0
	cap noi tab divison_n
	cap noi gen punfav_n = punfav*-1
	cap noi twoway 	(bar pfav divison_n,	horizontal xvarlab(Favorable) fcolor(green*.60) 	///
									lcolor(green) barwidth(.8))							///
			(sc divison_n pfav, 	mlabel(pfav) mcolor(green) mlabcolor(black) 		///
									mlabsize(vsmall) mlabposition(3) msymbol(i))		///
			(bar punfav_n divison_n, horizontal xvarlab(Unfavorable) fcolor(maroon*.60) ///
									lcolor(maroon) barwidth(.8) )						///
			(sc divison_n punfav_n, mlabel(punfav) mcolor(maroon) mlabcolor(black) 		///
									mlabsize(vsmall) mlabposition(9) msymbol(i))		///
			(sc divison_n zero, 	mlabel(divison_n) mlabsize(vsmall) mlabcolor(black) ///
									msymbol(i)),										///
	ysca(noline) ylabel(none) yline($punfav, lpattern(dash) lcolor(maroon))  			///
	yline($pfav, sort(1) lpattern(dash) lcolor(green)) 											///
	xtitle("Proportion of Responses") ytitle("") 										///
	xlabel(-60 "60" -40 "40" -20 "20" 0 20 40 60 80 100)								///
	legend(label(1 Favorable) label(3 Unfavorable))  legend(order(1 3))					///
	title("Proportion of Responses on Agility Index for `pmu' `reg'", size(medium))		///
	note("Source: Data Collected from Engagement Survey 2019", span)	
	cap noi graph export bar_`pmu'`reg'.png, as(png) name("Graph") replace
	restore
}

}

*TOP TEN AGILE UNITS
preserve 
collapse pfav pneut punfav if level=="Unit/Dept Report", by(pmuregunit)
sort pfav
gen filter_fav=1 if _n<=10
sort punfav
gen filter_unfav=1 if _n<=10
format pfav pneut punfav %9.0f
sort pfav
gen pmuregunit_n = _n*2 if _n<=10
sort punfav
replace pmuregunit_n = 1-(_n*2)*-1 if _n<=10
labmask pmuregunit_n, values(pmuregunit)

twoway 	(sc pfav pmuregunit_n  	if 	filter_fav==1, yaxis(1) mlabel(pmuregunit) mlabcolor(green)		///
									mlabsize(tiny) mlabposition(12) mcolor(green))					///
		(sc pfav pmuregunit_n   if 	filter_fav==1, yaxis(1) mlabel(pfav) mlabcolor(black)			///
									mlabsize(tiny) mlabposition(6) mcolor(green))					///										
		(sc punfav pmuregunit_n if 	filter_unfav==1, yaxis(2) mlabel(pmuregunit) mlabcolor(maroon)	///
									mlabsize(tiny) mlabposition(6) mcolor(maroon))					///
		(sc punfav pmuregunit_n if 	filter_unfav==1, yaxis(2) mlabel(punfav) mlabcolor(black)		///
									mlabsize(tiny) mlabposition(12) mcolor(maroon)), 				///
	ysca(axis(1) r(30 60)) ylab(44(4)60, axis(1)) ytitle("Proportion of Responses") 				///
	ysca(axis(2) r(10 30)) ylab(10 (2) 18, axis(2)) xsca(r(1 22)) ytitle("", axis(2)) 				///
	xtitle("")	graphregion(color(white)) bgcolor(white) xlabel(none)								///
	title( "Top 10 Units for Agility Index", size(medium)) ytick(44(4)60, axis(1) grid)				///
	legend(label(1 Favorable) label(3 Unfavorable))  legend(order(1 3))								///
	yline(18, axis(2) lstyle(foreground)) ytick(10(2)18, axis(2) grid)								///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export scatter_top10unit.png, as(png) name("Graph") replace
*/
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
	sum pfav if level=="WBG Report" & agileindicator=="$`x'", d
	global medianwbg = trim("`: display %9.2fc r(p50)'")
*OVERALL AGILITY
cap noi graph hbar (mean) $setscale if level=="Org Report"|level=="WBG Report", 		///
	over(divison, sort($setsort ) label(labsize(small)))	stack				///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 						///
	ylab($medianwbg "WBG" $medianag "Agility", labsize(vsmall) angle(90)) 		///
	yline($medianwbg, lcolor(black) lpatter(dash))  							///
	yline($medianag, lcolor(ebblue) lpattern(dash))								///
	ytitle("Proportion of Reponses", size(small)) 								///											
	title( "Overall Proportion of Responses in $`x' Index", size(small))		///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_`x'_overall.png, as(png) name("Graph") replace

*AGILITY BY REGION/PG/VPU 
cap noi graph hbar (mean) $setscale if level=="VPU-REG Report"|							///
	level=="VPU-PG Report"|level=="VPU Report", 								///
	over(level, sort($setsort ) label(labsize(small)))	stack					///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 						///
	ylab($medianwbg "WBG" $medianag "Agility", labsize(vsmall) angle(90)) 		///
	yline($medianwbg, lcolor(black) lpatter(dash))  							///
	yline($medianag, lcolor(ebblue) lpattern(dash))								///
	ytitle("Proportion of Reponses", size(small))								///
	title( "Proportion of Responses in $`x' Index by Mapping", size(medium))	///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_`x'_vpu_ag.png, as(png) name("Graph") replace

*AGILITY BY VPU-REG 
cap noi graph hbar (mean) $setscale if level=="VPU-REG Report", 						///
	over(divison, sort($setsort) label(labsize(small)))	stack					///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 						///
	ylab($medianwbg "WBG" $medianag "Agility", labsize(vsmall) angle(90)) 		///
	yline($medianwbg, lcolor(black) lpatter(dash))  							///
	yline($medianag, lcolor(ebblue) lpattern(dash))								///
	ytitle("Proportion of Reponses", size(small))								///
	title( "Regional Proportion of Responses in $`x' Index", size(medium))		///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_`x'_regional.png, as(png) name("Graph") replace

*AGILITY BY VPU-PG 
cap noi graph hbar (mean) $setscale if level=="VPU-PG Report", 							///
	over(divison, sort($setsort) label(labsize(small)))	stack					///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 						///
	ylab($medianwbg "WBG" $medianag "Agility", labsize(vsmall) angle(90)) 		///
	yline($medianwbg, lcolor(black) lpatter(dash))  							///
	yline($medianag, lcolor(ebblue) lpattern(dash))								///
	ytitle("Proportion of Reponses", size(small))								///
	title( "PG Level Proportion of Responses in $`x' Index", size(medium))		///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_`x'_pg.png, as(png) name("Graph") replace

*AGILITY BY VPU 
cap noi graph hbar (mean) $setscale if level=="VPU Report", 							///
	over(divison, sort($setsort) label(labsize(small)))	stack					///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 						///
	ylab($medianwbg "WBG" $medianag "Agility", labsize(vsmall)) 				///
	yline($medianwbg, lcolor(black) lpatter(dash))  							///
	yline($medianag, lcolor(ebblue) lpattern(dash))								///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)				///
	title( "VPU Level Proportion of Responses in $`x' Index", size(medium))		///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_`x'_vpu.png, as(png) name("Graph") replace

*AGILITY BY GP 
replace gpcode = "GOV" if gpcode=="GOV-Proc" | gpcode=="Gov - PS/FM"
cap noi graph hbar (mean) $setscale if gpcode!="", 										///
	over(gpcode, sort($setsort) label(labsize(small)))	stack					///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 						///
	ylab($medianwbg "WBG" $medianag "Agility", labsize(vsmall)) 				///
	yline($medianwbg, lcolor(black) lpatter(dash))  							///
	yline($medianag, lcolor(ebblue) lpattern(dash))								///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)				///
	title( "GP Level Proportion of Responses in $`x' Index", size(medium))		///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_`x'_gp.png, as(png) name("Graph") replace

*AGILITY BY PG-GP 
foreach pg in EFI HD INFRA SD {
    	sum pfav if pmu=="`pg'" & gpcode!="", d
		gl medianpg = trim("`: display %9.2fc r(p50)'")
cap noi graph hbar (mean) $setscale if gpcode!="" & pmu=="`pg'", 				///
	over(gpcode, sort($setsort) label(labsize(small)))	stack					///
	$bargap $blabel $barcol3 $barleg3 $graphset showyvars 						///
	yline($medianwbg, lcolor(black) lpatter(dash))  							///
	yline($medianpg, lcolor(green) lpatter(dash))  								///
	yline($medianag, lcolor(ebblue) lpattern(dash))								///
	ylab($medianwbg "WBG" $medianpg "PG" $medianag "Agility", labsize(vsmall)) 				///
	ytitle("Proportion of Reponses", size(small))	xsize(3) ysize(4)			///
	title( "GP Level Scores in $`x' Index for `pg'", size(medium))				///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
graph export avg_`x'_gp`pg'.png, as(png) name("Graph") replace
}

*AGILITY BY PG-Region-Unit Ag level
	foreach pg in EFI HD INFRA SD {
	     sum pfav if level=="PG-Region Unit" & pmu=="`pg'", d
		gl medianpg = trim("`: display %9.2fc r(p50)'")
cap noi graph hbar (mean) $setscale if level=="PG-Region Unit" & pmu=="`pg'", 				///
	over(region, sort($setsort) label(labsize(small))) 							///
	yline($medianwbg, lcolor(black) lpattern(dash)) stack						///
	yline($medianpg, lcolor(green) lpattern(dash))								///
	yline($medianag, lcolor(blue) lpatter(dash))  							///
	ylab($medianwbg "WBG" $medianpg "PG" $medianag "Agility", angle(90) labsize(vsmall))  			///
	$bargap $blabel $barcol3 $barleg3 $graphset								 	///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)				///
	title( "Region Unit Level Scores in $`x' Index for `pg'", size(small))		///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
cap noi graph export avg_`x'_regag`pg'.png, as(png) name("Graph") replace
}

*AGILITY BY Region-PG-Unit Ag level
	foreach reg in AFR MNA LCR ECA EAP SAR {
	    sum pfav if level=="PG-Region Unit" & region=="`reg'", d
		gl medianreg = trim("`: display %9.2fc r(p50)'")
cap noi graph hbar (mean) $setscale if level=="PG-Region Unit" & region=="`reg'", 				///
	over(pmu, sort($setsort) label(labsize(small))) 							///
	yline($medianwbg, lcolor(black) lpattern(dash)) stack						///
	yline($medianpg, lcolor(green) lpattern(dash))								///
	yline($medianag, lcolor(blue) lpatter(dash))  							///
	ylab($medianwbg "WBG" $medianpg "PG" $medianag "Agility", angle(90) labsize(vsmall))  			///
	$bargap $blabel $barcol3 $barleg3 $graphset								 	///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)				///
	title( "PG Unit Level Scores in $`x' Index for `reg'", size(small))			///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
cap noi graph export avg_`x'_pgag`reg'.png, as(png) name("Graph") replace
}

*AGILITY BY Region-PG-Unit level
cap noi graph hbar (mean) $setscale if level=="PG-Region Unit", 				///
	over(divison, sort($setsort) label(labsize(small))) 						///
	yline($medianwbg, lcolor(black) lpatter(dash)) stack 						///
	yline($medianag, lcolor(ebblue) lpatter(dash))  							///
	ylab($medianwbg "WBG" $medianag "Agility", angle(90) labsize(vsmall))  			///
	$bargap $blabel $barcol3 $barleg3 $graphset								 	///
	ytitle("Proportion of Reponses", size(small)) xsize(3) ysize(4)				///
	title( "PG Unit Level Scores in $`x' Index", size(small))					///
	note("Source: Data Collected from Engagement Survey 2019", size(vsmall)) 
cap noi graph export avg_`x'_unitregion.png, as(png) name("Graph") replace
restore
}

/*
foreach x in a b c d e f {
*AGILITY BY EACH VPU REGION UNIT
foreach pmu in "GGE" "GGH" "GGI" "GGS" {
foreach reg in "AFR" "EAP" "ECA" "LCR" "MNA" "SAR" {
    preserve
    keep if agileindicator=="$`x'"
	cap noi collapse pfav pneut punfav if level=="Unit/Dept Report" & pmu=="`pmu'" & 		///
		regionunitname=="`reg'", by(divison)
	cap noi egen pfav_max=max(pfav)
	cap noi egen punfav_max=max(punfav)
	cap noi format pfav pneut punfav %9.0f
	cap noi encode divison, gen(divison_n)
	cap noi gen pfav_m=divison_n if pfav_m==pfav
	cap noi gen punfav_m=divison_n if punfav_m==punfav	
	cap noi egen pfav_mn=max(pfav_m)
	cap noi replace pfav_mn=pfav_mn-0.5
	cap noi egen punfav_mn=max(punfav_m)
	cap noi replace punfav_mn=punfav_mn-0.5
	cap noi gl pfav=pfav_mn
	cap noi gl punfav=punfav_mn
	cap noi gen zero=0
	cap noi tab divison_n
	cap noi gen punfav_n = punfav*-1
	sort pfav
	cap noi twoway 	(bar pfav divison_n,	horizontal xvarlab(Favorable) fcolor(green*.60) 	///
									lcolor(green) barwidth(.8))							///
			(sc divison_n pfav, 	mlabel(pfav) mcolor(green) mlabcolor(black) 		///
									mlabsize(vsmall) mlabposition(3) msymbol(i))		///
			(bar punfav_n divison_n, horizontal xvarlab(Unfavorable) fcolor(maroon*.60) ///
									lcolor(maroon) barwidth(.8) )						///
			(sc divison_n punfav_n, mlabel(punfav) mcolor(maroon) mlabcolor(black) 		///
									mlabsize(vsmall) mlabposition(9) msymbol(i))		///
			(sc divison_n zero, 	mlabel(divison_n) mlabsize(vsmall) mlabcolor(black) ///
									msymbol(i)),										///
	ysca(noline) ylabel(none) yline($punfav, lpattern(dash) lcolor(maroon))  			///
	yline($pfav, lpattern(dash) lcolor(green)) 											///
	xtitle("Proportion of Responses") ytitle("") 										///
	xlabel(-60 "60" -40 "40" -20 "20" 0 20 40 60 80 100)								///
	legend(label(1 Favorable) label(3 Unfavorable))  legend(order(1 3))					///
	title("Proportion of Responses on $`x' Index for `pmu' `reg'", size(medium))		///
	note("Source: Data Collected from Engagement Survey 2019", span)	
	cap noi graph export bar_`x'`pmu'`reg'.png, as(png) name("Graph") replace
	restore
}
}
}

*AGILITY BY EACH VPU REGION UNIT
foreach pmu in "GGE" "GGH" "GGI" "GGS" {
foreach reg in "AFR" "EAP" "ECA" "LCR" "MNA" "SAR" {
    preserve
	cap noi collapse pfav pneut punfav if level=="Unit/Dept Report" & pmu=="`pmu'" & 		///
		regionunitname=="`reg'", by(divison)
	cap noi egen pfav_max=max(pfav)
	cap noi egen punfav_max=max(punfav)
	cap noi format pfav pneut punfav %9.0f
	cap noi encode divison, gen(divison_n)
	cap noi gen pfav_m=divison_n if pfav_m==pfav
	cap noi gen punfav_m=divison_n if punfav_m==punfav	
	cap noi egen pfav_mn=max(pfav_m)
	cap noi replace pfav_mn=pfav_mn-0.5
	cap noi egen punfav_mn=max(punfav_m)
	cap noi replace punfav_mn=punfav_mn-0.5
	cap noi gl pfav=pfav_mn
	cap noi gl punfav=punfav_mn
	cap noi gen zero=0
	cap noi tab divison_n
	cap noi gen punfav_n = punfav*-1
	sort pfav
	cap noi twoway 	(bar pfav divison_n,	horizontal xvarlab(Favorable) fcolor(green*.60) 	///
									lcolor(green) barwidth(.8))							///
			(sc divison_n pfav, 	mlabel(pfav) mcolor(green) mlabcolor(black) 		///
									mlabsize(vsmall) mlabposition(3) msymbol(i))		///
			(bar punfav_n divison_n, horizontal xvarlab(Unfavorable) fcolor(maroon*.60) ///
									lcolor(maroon) barwidth(.8) )						///
			(sc divison_n punfav_n, mlabel(punfav) mcolor(maroon) mlabcolor(black) 		///
									mlabsize(vsmall) mlabposition(9) msymbol(i))		///
			(sc divison_n zero, 	mlabel(divison_n) mlabsize(vsmall) mlabcolor(black) ///
									msymbol(i)),										///
	ysca(noline) ylabel(none) yline($punfav, lpattern(dash) lcolor(maroon))  			///
	yline($pfav, lpattern(dash) lcolor(green)) 											///
	xtitle("Proportion of Responses") ytitle("") 										///
	xlabel(-60 "60" -40 "40" -20 "20" 0 20 40 60 80 100)								///
	legend(label(1 Favorable) label(3 Unfavorable))  legend(order(1 3))					///
	title("Proportion of Responses on Agility Index for `pmu' `reg'", size(medium))		///
	note("Source: Data Collected from Engagement Survey 2019", span)	
	cap noi graph export bar_agility`pmu'`reg'.png, as(png) name("Graph") replace
	restore
}
}

*TOP TEN AGILE UNITS
foreach x in a b c d e f {
preserve
keep if agileindicator=="$`x'"
collapse pfav pneut punfav if level=="Unit/Dept Report", by(pmuregunit)
sort pfav
gen filter_fav=1 if _n<=10
sort punfav
gen filter_unfav=1 if _n<=10
format pfav pneut punfav %9.0f
sort pfav
gen pmuregunit_n = _n*2 if _n<=10
sort punfav
replace pmuregunit_n = 1-(_n*2)*-1 if _n<=10
labmask pmuregunit_n, values(pmuregunit)

*setting globals for graph
sort punfav
egen punfav_max = max(punfav) if _n<=10
replace punfav_max=punfav_max+2
gl yline=punfav_max

replace punfav_max=punfav_max+8
gl yline_r=punfav_max

sort pfav
egen pfav_max = max(pfav) if _n<=10
replace pfav_max=pfav_max+2
gl yline2=pfav_max

replace pfav_max=pfav_max+8
gl yline2_r=pfav_max

sort pfav
egen pfav_min = min(pfav) if _n<=10
replace pfav_min=pfav_min
gl yline2_min=pfav_min

sort punfav
egen punfav_min = min(punfav) if _n<=10
replace punfav_min=punfav_min
gl yline_min=punfav_min

twoway 	(sc pfav pmuregunit_n  	if 	filter_fav==1, yaxis(1) mlabel(pmuregunit) mlabcolor(green)		///
									mlabsize(tiny) mlabposition(12) mcolor(green))					///
		(sc pfav pmuregunit_n   if 	filter_fav==1, yaxis(1) mlabel(pfav) mlabcolor(black)			///
									mlabsize(tiny) mlabposition(6) mcolor(green))					///										
		(sc punfav pmuregunit_n if 	filter_unfav==1, yaxis(2) mlabel(pmuregunit) mlabcolor(maroon)	///
									mlabsize(tiny) mlabposition(6) mcolor(maroon))					///
		(sc punfav pmuregunit_n if 	filter_unfav==1, yaxis(2) mlabel(punfav) mlabcolor(black)		///
									mlabsize(tiny) mlabposition(12) mcolor(maroon)), 				///
	ysca(axis(1) r($yline_r $yline2_r)) ylab($yline2_min (4) $yline2, nogrid axis(1)) ytitle("Proportion of Responses") 				///
	ysca(axis(2) r(0 $yline_r)) ylab($yline_min (4) $yline, nogrid axis(2)) xsca(r(1 22)) ytitle("", axis(2)) 				///
	xtitle("")	graphregion(color(white)) bgcolor(white) xlabel(none)								///
	title( "Top 10 Units for $`x' Index", size(medium)) ylabel(none, axis(1)) ylabel(none, axis(2)) ///
	legend(label(1 Favorable) label(3 Unfavorable))  legend(order(1 3))								///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_`x'top10unit.png, as(png) name("Graph") replace
restore
}
*/
********************************************************************************
*					ANALYSIS BY EACH LEVEL OF OBSERVATION
********************************************************************************

*ORGANIZATION LEVEL
*********************************************

ttest pfav if level=="Org Report"|level=="WBG Report", by(divison)
foreach x in a b c d e f {
ttest pfav if agileindicator=="$`x'" & (level=="Org Report"|level=="WBG Report"), by(divison)
}

preserve
collapse (mean) pfav if level=="Org Report"|level=="WBG Report", by(divison)
gen indicator="Agility"
save "$onedrive\Intermediate\temp1.dta", replace
restore
foreach x in a b c d e f {
	preserve
	collapse (mean) pfav if agileindicator=="$`x'" & (level=="Org Report"|level=="WBG Report"), by(divison)
	gen indicator="$`x'"
	save "$onedrive\Intermediate\temp`x'.dta", replace
	restore
}
preserve
use "$onedrive\Intermediate\temp1.dta", clear
foreach x in a b c d e f {
append using "$onedrive\Intermediate\temp`x'.dta"
}
encode divison, gen(divison_n)
tab divison
encode indicator, gen(indicator_n)
tab indicator
format pfav %9.0f
save "$onedrive\Intermediate\temp.dta", replace
restore

preserve
use "$onedrive\Intermediate\temp.dta", clear

twoway 	(sc   indicator_n  pfav if divison_n==1, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc  indicator_n pfav     if divison_n==2, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)), 					///
	xtitle("Proportion of Responses")	graphregion(color(white)) bgcolor(white) 	///
	xlabel(40(5)80)	ytitle("")							///
	ylabel(1 "Overall Agility" 2 "Collaboration" 3 "Goal Orientation" 4 "Innovation"	///
			5 "Learning & Development" 6 "Managmt Agility" 7 "Process Agility", angle(0))		///
	title( "Proportion of Favorable Responses at Organization Level", size(medium)) 			///
	legend(label(1 IBRD) label(2 World Bank Group))  legend(order(1 2))								///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_org.png, as(png) name("Graph") replace
restore

*MAPPING LEVEL
*********************************************

preserve
collapse (mean) pfav if level=="VPU-REG Report"|level=="VPU-PG Report"|level=="VPU Report", by(level)
gen indicator="Agility"
save "$onedrive\Intermediate\temp1.dta", replace
restore
foreach x in a b c d e f {
	preserve
	collapse (mean) pfav if agileindicator=="$`x'" & (level=="VPU-REG Report"|level=="VPU-PG Report"|level=="VPU Report"), by(level)
	gen indicator="$`x'"
	save "$onedrive\Intermediate\temp`x'.dta", replace
	restore
}
preserve
use "$onedrive\Intermediate\temp1.dta", clear
foreach x in a b c d e f {
append using "$onedrive\Intermediate\temp`x'.dta"
}
encode level, gen(level_n)
tab level
encode indicator, gen(indicator_n)
tab indicator
format pfav %9.0f
save "$onedrive\Intermediate\temp.dta", replace
restore
preserve
use "$onedrive\Intermediate\temp.dta", clear

twoway 	(sc indicator_n pfav    if level_n==1, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if level_n==2, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if level_n==3, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)), 					///									
	xtitle("Proportion of Responses")	graphregion(color(white)) bgcolor(white) 	///
	xlabel(40(5)80)	ytitle("")							///
	ylabel(1 "Overall Agility" 2 "Collaboration" 3 "Goal Orientation" 4 "Innovation"	///
			5 "Learning & Development" 6 "Managmt Agility" 7 "Process Agility", angle(0))		///
	title( "Proportion of Favorable Responses at Mapping Level", size(medium)) 			///
	legend(label(1 VPU Report) label(2 VPU-PG Report) label(3 VPU-REG Report)) 							///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_map.png, as(png) name("Graph") replace
restore

*REGION LEVEL
*********************************************

preserve
collapse (mean) pfav if level=="VPU-REG Report", by(divison)
gen indicator="Agility"
save "$onedrive\Intermediate\temp1.dta", replace
restore
foreach x in a b c d e f {
	preserve
	collapse (mean) pfav if agileindicator=="$`x'" & level=="VPU-REG Report", by(divison)
	gen indicator="$`x'"
	save "$onedrive\Intermediate\temp`x'.dta", replace
	restore
}
preserve
use "$onedrive\Intermediate\temp1.dta", clear
foreach x in a b c d e f {
append using "$onedrive\Intermediate\temp`x'.dta"
}
encode divison, gen(divison_n)
tab divison
encode indicator, gen(indicator_n)
tab indicator
format pfav %9.0f
save "$onedrive\Intermediate\temp.dta", replace
restore
preserve
use "$onedrive\Intermediate\temp.dta", clear
twoway 	(sc indicator_n pfav    if divison_n==1, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if divison_n==2, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if divison_n==3, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if divison_n==4, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if divison_n==5, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///									
		(sc indicator_n pfav     if divison_n==6, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)), 					///									
	xtitle("Proportion of Responses")	graphregion(color(white)) bgcolor(white) 	///
	xlabel(50(5)90)	ytitle("")							///
	ylabel(1 "Overall Agility" 2 "Collaboration" 3 "Goal Orientation" 4 "Innovation"	///
			5 "Learning & Development" 6 "Managmt Agility" 7 "Process Agility", angle(0))		///
	title( "Proportion of Favorable Responses at Region Level", size(medium)) 			///
	legend(label(1 AFR) label(2 EAP) label(3 ECA) label(4 LCR) label(5 MNA) label(6 SAR)) 								///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_reg.png, as(png) name("Graph") replace
restore

*PG LEVEL
*********************************************

preserve
collapse (mean) pfav if level=="VPU-PG Report", by(divison)
gen indicator="Agility"
save "$onedrive\Intermediate\temp1.dta", replace
restore
foreach x in a b c d e f {
	preserve
	collapse (mean) pfav if agileindicator=="$`x'" & level=="VPU-PG Report", by(divison)
	gen indicator="$`x'"
	save "$onedrive\Intermediate\temp`x'.dta", replace
	restore
}
preserve
use "$onedrive\Intermediate\temp1.dta", clear
foreach x in a b c d e f {
append using "$onedrive\Intermediate\temp`x'.dta"
}
encode divison, gen(divison_n)
tab divison
encode indicator, gen(indicator_n)
tab indicator
format pfav %9.0f
save "$onedrive\Intermediate\temp.dta", replace
restore
preserve
use "$onedrive\Intermediate\temp.dta", clear
twoway 	(sc indicator_n pfav    if divison_n==1, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if divison_n==2, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if divison_n==3, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)) 					///
		(sc indicator_n pfav     if divison_n==4, 	mlabel(pfav) mlabcolor(black)							///
									mlabsize(tiny) mlabposition(12)), 					///									
	xtitle("Proportion of Responses")	graphregion(color(white)) bgcolor(white) 	///
	xlabel(25(5)75)	ytitle("")							///
	ylabel(1 "Overall Agility" 2 "Collaboration" 3 "Goal Orientation" 4 "Innovation"	///
			5 "Learning & Development" 6 "Managmt Agility" 7 "Process Agility", angle(0))		///
	title( "Proportion of Favorable Responses at Region Level", size(medium)) 			///
	legend(label(1 EFI) label(2 HD) label(3 INFRA) label(4 SD)) 								///
	note("Source: Data Collected from Engagement Survey", size(vsmall)) 
graph export scatter_pg.png, as(png) name("Graph") replace
restore

