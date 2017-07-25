/*
This do-file makes up a fake wage data to simulate the merge
of paa and sii wages
*/

clear 
clear mata
clear matrix
program drop _all

/*Cambiar folders*/

local user Jorge

if "`user'"=="Jorge"{
	global codes "/home/jorger/ige/codes"
	global data "/home/jorger/ige/data"
	global results "/home/jorger/ige/results"  

}
else if "`user'"=="Nico"{
	global codes 
	global data 
	global results 

}





****************Creating fake wage data from mothers, fathers, and student**************
foreach indi in student father mother{

use "$data/paa_9498_`indi'.dta", clear
	keep rut_

	forvalues x=1998/2015{
		gen lwage=rnormal(3.95,1.22)
		gen wage_`x'=exp(lwage)
		drop lwage
	}

	save "$data/fakew_`indi'.dta", replace
}



