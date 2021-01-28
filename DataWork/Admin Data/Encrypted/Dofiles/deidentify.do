clear matrix
set more off
cd "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Outputs\Raw"

*setting paths
	local path "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Datasets\Intermediate\"
	local path3 "C:\Users\wb522556\WBG\Vincenzo Di Maro - Agile\06 - Agile Productivity Radar\DataWork\Admin Data\Encrypted\Raw Data\"

		****************************************************************************
	*              CLEANING PROJECT MASTER FILE                                *
	****************************************************************************
	
	import delimited "`path3'project_master.csv", clear
	ren proj_id ProjectID
	
	iecodebook template using "`path3'codebook.xlsx"
	
	