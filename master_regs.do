/* 
This do-file computes log-log regressions
*/


clear
set more off

/*Cambiar folders*/
local user Jorge


if "`user'" == "Jorge"{
	global codes "/home/jorger/ige/codes"
	global data "/home/jorger/ige/data"
	global results "/home/jorger/ige/results"  

}
else if "`user'" == "Nico"{
	global codes 
	global data 
	global results 

}

else if "`user'" == "C"{
	global codes "C:\Users\death\Desktop\jorge1\ige-codes"
	global data "C:\Users\death\Desktop\jorge1/data"
	global results "C:\Users\death\Desktop\jorge1/results"

}


/*Nombre de los datos*/
local data_wage_paa wage_paa


**********************************************
**********************************************
**********************************************
use "$data/`data_wage_paa'.dta", clear

*Real wages
qui: do "$codes/ipc.do"

*Defining wage variables
do "$codes/wage_defs.do"

*These are the basic control variables: unpacking variables
qui: do "$codes/controls.do"

*Drop obs
qui: do "$codes/cov_obs.do"

*SEs
local SE "robust"


************************************
*Estadistica descriptiva (para base final)

qui: do "$codes/descriptiva2.do"
do "$codes/descriptiva3.do"


************************************
*log-log regressions and variations
*Each regression produces a table on excel and on .tex


qui: do "$codes/regs_loglog.do"

qui: do "$codes/regs_rank.do"

do "$codes/regs_splines.do"





