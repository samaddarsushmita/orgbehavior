
set more off
cd "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Pilot\Outputs\Raw"
local path1 "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Pilot\Encrypted\Raw Data\"
local path2 "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Work Behavior Tool\Pilot\Datasets\Intermediate\"


import excel "`path1'Work Behavior Tool.xlsx", sheet("data") firstrow clear
save "`path2'pilotdata.dta", replace

use "`path2'pilotdata.dta", clear

*Dropping Random Generated Variables
drop rand*

*Dropping duplicate variables on scores
drop item**_env_* item**_*

/*generating composite enabling env variable for both questions in one indicator
forvalues x=1/50{
cap noi replace score`x'a_env=0 if score`x'a_env==.
cap noi replace score`x'b_env=0 if score`x'b_env==.
cap noi gen score`x'_env=score`x'a_env+score`x'b_env
}
*/

*CHANGING THE SCORES
forvalues x=1/56 {
foreach y in "" "a" "b" {
cap noi replace score`x'`y'=-1 if score`x'`y'==2
cap noi replace score`x'`y'=-2 if score`x'`y'==1
cap noi replace score`x'`y'=1 if score`x'`y'==3
cap noi replace score`x'`y'=2 if score`x'`y'==4
}
}

*CHANGING THE SCORES FOR ENVIRONMENT
forvalues x=1/56 {
foreach y in "" "a" "b" {
cap noi replace score`x'`y'_env=-1 if score`x'`y'_env==2
cap noi replace score`x'`y'_env=-2 if score`x'`y'_env==1
cap noi replace score`x'`y'_env=1 if score`x'`y'_env==3
cap noi replace score`x'`y'_env=2 if score`x'`y'_env==4
}
}

*LABELLING THE SCORES
foreach x in "" "a" "b" {
labvars score1`x' score2`x' score3`x' score4`x' score5`x' score6`x' score7`x' score8`x' ///
score9`x' score10`x' score11`x' score12`x' score13`x' score14`x' score15`x' score16`x' score17`x' ///
score18`x' score19`x' score20`x' score22`x' score23`x' score24`x' score25`x' score26`x' score27`x' ///
score28`x' score29`x' score30`x' score31`x' score32`x' score33`x' score34`x' score35`x' score36`x' score37`x' ///
score38`x' score39`x' score40`x' score41`x' score42`x' score48`x' score49`x' ///
score50`x' score51`x' score52`x' score53`x' score54`x' score55`x' score56`x' "Willing to help others" ///
"Desirability in engaging others in social interaction" ///
"Facilitate tasks with the team effectively" ///
"Developing the abilities of team members by providing feedback and suggestions" ///
"Providing team members with adequate opportunities to learn" ///
"Respect people from different backgrounds" "Fosters an inclusive workplace" ///
"Comfortable working with people having different perspectives" ///
"Genuinely regards people and easily forms close associations with them" ///
"Adjust one's work style to accommodate individual differences" ///
"Accurately assess and utilize the strengths of all the team members" ///
"Coordinate and cooperate with a team productively" ///
"Able to provide solutions during conflicts" ///
"Desire to be collaborative instead of competitive" ///
"Stay updated on company policies and trends that may impact their activities" ///
"Stay updated on the external market to understand it affects the organization" ///
"Capable of identifying and understanding the dynamics of the organization" ///
"Capable of identifying root causes for a problem" ///
"Gather and apply knowledge to strategically solve work-related problems" ///
"Emotionally stable, reliable and dependent in times of crisis" ///
"Deals with ambiguity by being methodical and patient" ///
"Actively cope with tough situations, rather than being passive" ///
"Good at imagination and originality" ///
"Willing to consider new and unconventional ideas and solutions to problems" ///
"Adding new dimensions to one's work" "Flexible approach to one’s work" ///
"Desire to design and implement new programs/processes" ///
"Constantly work towards deriving innovative solutions to problems" ///
"Open to changes taking place in the organization" ///
"Ability to take risks" "Impervious to social norms and judgement" ///
"Determine objectives, set priorities and follow through one's plans" ///
"Holds oneself accountable for high quality" "Holds oneself accountable for time-effective results" ///
"Responsible and active at work to ensure desired results" ///
"Strong commitment towards achieving individual and team goals" ///
"Set challenging goals for oneself and for other team members" ///
"Work towards personal growth and development" ///
"Aware of one's own strength and limitations" ///
"Improve oneself and acquire more knowledge" ///
"Having confidence in one's own skills and hard work" ///
"Attuned to others' emotions" ///
"Trusting of others" "Cooperative, accomodating and understanding" ///
"Able to include other people in decision making" "Comfortable in situations involving uncertainty and risks" ///
"Effectively adapt to new situations" "Takes initiatives and guides others during challenging times" ///
"Open to learning from failure" "Independent and assertive individual"
}

foreach x in a b {
labvars score43`x' score44`x' score45`x' score46`x' score47`x' /// 
"Social Desirability 1" "Social Desirability 2" "Social Desirability 3" ///
"Social Desirability 4" "Social Desirability 5"
}



foreach x in "" "a" "b" {
cap noi labvars score14`x' score16`x' score20`x' score22`x' score25`x' score28`x' ///
score30`x' score32`x' score33`x' score37`x' score3`x' score41`x' score50`x' score7`x' score9`x' ///
"Env: Desire to be collaborative instead of competitive"  ///
"Env: Stay updated on the external market to understand it affects the organization" ///
"Env: Emotionally stable, reliable and dependent in times of crisis"			///
"Env: Deals with ambiguity by being methodical and patient"						///
"Env: Willing to consider new and unconventional ideas and solutions to problems"	///
"Env: Desire to design and implement new programs/processes"					///
"Env: Facilitate tasks with the team effectively"								///
"Env: Open to changes taking place in the organization"							///
"Env: Impervious to social norms and judgement"									///
"Env: Determine objectives, set priorities and follow through one's plans"		///
"Env: Strong commitment towards achieving individual and team goals"			///
"Env: Improve oneself and acquire more knowledge"								///
"Env: Cooperative, accomodating and understanding"								///
"Env: Fosters an inclusive workplace"											///
"Env: Genuinely regards people and easily forms close associations with them"						
}


*DESCRIPTIVES
label define genderlbl 1 "Female" 2 "Male" 3 "Transgender Female" 4 "Transgender Male" 5 "Non-Conforming/Non-Binary/Gender Variant" 6 "Not Listed" 7 "Prefer Not to Answer"

label define gradelbl 1 "GA-GD" 2 "GE-GF" 3 "GG" 4 "GH and Above" 5 "Prefer Not to Answer"

label define apptlbl 1 "Open-Ended" 2 "Term" 3 "ETC" 4 "STC/STT" 5 "Other/Team Member"

label define agelbl 1 "Less than 30 years" 2 "31 to 40 years" 3 "41 to 50 years" 4 "Above 50 years" 5 "Prefer Not to Answer"

label define explbl 1 "Less than 5 years" 2 "5 to 9 years" 3 "10 to 19 years" 4 "20 to 29 years" 5 "More than 30 years" 6 "Prefer Not to Answer"

label define rolelbl 1 "Task Team Leader" 2 "Program/Team Assistant" 3 "Safeguard Specialist" 4 "Financial Management Specialist" 5 "Procurement Specialist" 6 "Lawyer/Legal Council" 7 "Practice Manager" 8 "Director" 9 "Country Director or Country Manager" 10 "Other"

label define practicelbl 0 "Not Mapped to a Global Practice" 1 "Finance, Competition and Innovation" 2 "Governance" 3 "Macroeconomics, Trade and Investment" 4 "Poverty and Equity" 5 "Education" 6 "Gender" 7 "Health, Nutrition and Population" 8 "Social Protection and Jobs" 9 	"Agriculture" 10 "Climate Change" 11 "Environment and Natural Resources" 12 "Social, Urban and Rural Resilience" 13 "Water" 14 "Energy and Extractives" 15 "Infrastructure, PPPs and Guarantees" 16 "Transport and Digital Development"

label define regionlbl 0 "Not Mapped to a Region" 1 "Africa" 2 "East Asia and Pacific" 3 "Europe and Central Asia" 4 "Latin America and Caribbean" 5 "Middle East and Central Asia" 6 "South Asia" 

label define vpulbl 1 "SEC" 2 "DEC" 3 "ECR" 4 "HRD" 5 "IAD" 6 "LEG" 7 "OPCS" 8 "BPS" 9 "GCS" 10 "HSD" 11 "ITS" 12 "SPA" 13 "CRO" 14 "DFI" 15 "TRE" 16 "WFA" 17 "GGE" 18 "GGH" 19 "GGI" 20 "GGS" 21 "WBT" 22 "EBC" 23 "IJS" 24 "MEF" 25 "OMB" 26 "PRS" 27 "EDS" 28 "IEG" 29 "IPN" 30 "INT" 31 "OSD" 32 "SBS" 33 "EXC" 34 "CAO" 35 "CEO" 36 "CFO"

label values gender genderlbl
label values appointment apptlbl
label values age agelbl
label values experience explbl
label values grade gradelbl 
label values practice practicelbl 
label values region regionlbl 
label values vpu vpulbl 

*ENABLING ENVIRONMENT

/*ENABLING ENVIRONMENT RELATED QUESTIONS

*For people oriented
foreach x in 3 7 9 50 {
tab score`x'_env
tab score`x'
gen enablingenv`x'=1 if (score`x'_env!=.|score`x'!=.) & score`x'_env>=score`x'
replace enablingenv`x'=0 if (score`x'_env!=.|score`x'!=.) & score`x'_env<score`x'
tab enablingenv`x'
sum score`x'_env
sum score`x'
gen enablingenvdiff`x'=score`x'_env-score`x'
tab enablingenvdiff`x'
}

*For solutions oriented
foreach x in 14 16 20 22 {
tab score`x'_env
tab score`x'
gen enablingenv`x'=1 if (score`x'_env!=.|score`x'!=.) & score`x'_env>=score`x'
replace enablingenv`x'=0 if (score`x'_env!=.|score`x'!=.) & score`x'_env<score`x'
tab enablingenv`x'
sum score`x'_env
sum score`x'
gen enablingenvdiff`x'=score`x'_env-score`x'
tab enablingenvdiff`x'
}

*For innovation oriented
foreach x in 25 28 30 32 {
tab score`x'_env
tab score`x'
gen enablingenv`x'=1 if (score`x'_env!=.|score`x'!=.) & score`x'_env>=score`x'
replace enablingenv`x'=0 if (score`x'_env!=.|score`x'!=.) & score`x'_env<score`x'
tab enablingenv`x'
sum score`x'_env
sum score`x'
gen enablingenvdiff`x'=score`x'_env-score`x'
tab enablingenvdiff`x'
}

*For growth oriented
foreach x in 33 37 41 {
tab score`x'_env
tab score`x'
gen enablingenv`x'=1 if (score`x'_env!=.|score`x'!=.) & score`x'_env>=score`x'
replace enablingenv`x'=0 if (score`x'_env!=.|score`x'!=.) & score`x'_env<score`x'
tab enablingenv`x'
sum score`x'_env
sum score`x'
gen enablingenvdiff`x'=score`x'_env-score`x'
tab enablingenvdiff`x'
}


tab score25_env
tab score25
tabstat enablingenvdiff25, by(grade) stat(mean)
tabstat enablingenvdiff25, by(gender) stat(mean)
tabstat enablingenvdiff25, by(experience) stat(mean)

tab score28_env
tab score28
tabstat enablingenvdiff28, by(grade) stat(mean)
tabstat enablingenvdiff28, by(gender) stat(mean)
tabstat enablingenvdiff28, by(experience) stat(mean)
*/

*PRINCIPAL COMPONENT ANALYSIS 
global list score1 score2 score3 score4 score5 score6 score7 score8 ///
score9 score10 score11 score12 score13 score14 score15 score16 score17 score18 ///
score19 score20 score22 score23 score24 score25 score26 score27 score28 score29 ///
score30 score31 score32 score33 score34 score35 score36 score37 score38 score39 ///
score40 score41 score42 score48 score49 score50 score51 score52 score53 score54 ///
score55 score56

global lista score1a score2a score3a score4a score5a score6a score7a score8a ///
score9a score10a score11a score12a score13a score14a score15a score16a score17a score18a ///
score19a score20a score22a score23a score24a score25a score26a score27a score28a score29a ///
score30a score31a score32a score33a score34a score35a score36a score37a score38a score39a ///
score40a score41a score42a score48a score49a score50a score51a score52a score53a score54a ///
score55a score56a

global listb score1b score2b score3b score4b score5b score6b score7b score8b ///
score9b score10b score11b score12b score13b score14b score15b score16b score17b score18b ///
score19b score20b score22b score23b score24b score25b score26b score27b score28b score29b ///
score30b score31b score32b score33b score34b score35b score36b score37b score38b score39b ///
score40b score41b score42b score48b score49b score50b score51b score52b score53b score54b ///
score55b score56b

global peoplelist score1 score2 score3 score4 score5 score6 score7 score8 ///
score9 score10 score11 score12 score48 score49 score50 score51

global solutionlist score13 score14 score15 score16 score17 score18 score19 score20 ///
score22 score23 score48 score50 score52 score53 score54

global innovationlist score24 score25 score26 score27 score28 score29 score30 score31 ///
score32 score52 score53 score55 score56

global growthlist score33 score34 score35 score36 score37 score38 score39 score40 score41 ///
score42 score49 score51 score54 score55

global enva score14a score16a score20a score22a score25a score28a score30a 		///
score32a score33a score37a score3a score41a score50a score7a score9a

global envb score14b score16b score20b score22b score25b score28b score30b 		///
score32b score33b score37b score3b score41b score50b score7b score9b

global ncomp 6

describe $list
summarize $list
sktest $list

sktest $lista

sktest $listb


/*
/*
foreach x in "" "a" "b" {
forvalues y=1/56 {
cap noi hist score`y'`x', percent bin(5)
graph save score`y'`x'.gph, replace
}
}
*/
*Another way of looking at this data is to see what proportion of entries fall in each value of the variables
foreach x in "" "a" "b" {
forvalues y=1/56 {
cap noi egen temp`y'`x'1a=count(score`y'`x') if score`y'`x'==-2
cap noi egen temp`y'`x'1b=count(score`y'`x')
cap noi gen score`y'`x'_1=temp`y'`x'1a/temp`y'`x'1b
cap noi drop temp`y'`x'1a temp`y'`x'1b
}
}

foreach x in "" "a" "b" {
forvalues y=1/56 {
cap noi egen temp`y'`x'2a=count(score`y'`x') if score`y'`x'==-1
cap noi egen temp`y'`x'2b=count(score`y'`x')
cap noi gen score`y'`x'_2=temp`y'`x'2a/temp`y'`x'2b
cap noi drop temp`y'`x'2a temp`y'`x'2b
}
}

foreach x in "" "a" "b" {
forvalues y=1/56 {
cap noi egen temp`y'`x'3a=count(score`y'`x') if score`y'`x'==1
cap noi egen temp`y'`x'3b=count(score`y'`x')
cap noi gen score`y'`x'_3=temp`y'`x'3a/temp`y'`x'3b
cap noi drop temp`y'`x'3a temp`y'`x'3b
}
}

foreach x in "" "a" "b" {
forvalues y=1/56 {
cap noi egen temp`y'`x'4a=count(score`y'`x') if score`y'`x'==2
cap noi egen temp`y'`x'4b=count(score`y'`x')
cap noi gen score`y'`x'_4=temp`y'`x'4a/temp`y'`x'4b
cap noi drop temp`y'`x'4a temp`y'`x'4b
}
}

forvalues y=1/56 {
foreach x in "" "a" "b" {
cap noi replace score`y'`x'_1=score`y'`x'_1*100
cap noi replace score`y'`x'_2=score`y'`x'_2*100
cap noi replace score`y'`x'_3=score`y'`x'_3*100
cap noi replace score`y'`x'_4=score`y'`x'_4*100
cap noi tabstat score`y'`x'_1 score`y'`x'_2 score`y'`x'_3 score`y'`x'_4, stat(mean)
}
}

/*
forvalues y=1/56 {
foreach x in "" "a" "b" {
cap noi sum score`y'`x'_1 if score`y'`x'_1>=0.30
}
}
/*
forvalues y=1/56 {
foreach x in "" "a" "b" {
cap noi sum score`y'`x'_2 if score`y'`x'_2>=0.30
}
}

forvalues y=1/56 {
foreach x in "" "a" "b" {
cap noi sum score`y'`x'_3 if score`y'`x'_3>=0.30
}
}
/*
forvalues y=1/56 {
foreach x in "" "a" "b" {
cap noi sum score`y'`x'_4 if score`y'`x'_4>=0.30
}
}

