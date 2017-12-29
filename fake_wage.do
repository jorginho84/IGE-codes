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



local var_names_labor w1 w2
local var_names_capital w3 w4



****************Creating fake wage data from mothers, fathers, and student**************
use "$data/paa_9498_ok.dta", clear
keep RUT

forvalues x=1998/2015{
	local i = 1
	foreach variable in `var_names_labor' `var_names_capital'{
		gen lwage=rnormal(3.95,1.22)
		gen `variable'_`x'=exp(lwage)
		if `i' >=3{
			gen zeros = rbinomial(1,0.95)
			replace `variable'_`x' = 0 if zeros == 1
			drop lwage	zeros	
		}
		else{
			drop lwage
		}
		
		local i = `i' + 1
	}
		
}

save "$data/fakew_ok.dta", replace



