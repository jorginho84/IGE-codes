 /*
This do-file merges the SIMCE with wage data

ASEGURAR QUE RUT ESTE EN FORMATO NUMERICO

Salarios anuales (respetar el sgte formato):
rem_yyyy, donde "rem" indica el tipo de variable; "yyyy" corresponde al anio

*/
clear
set more off



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





/*Name of wage_data (all of it)*/
local wage_variables wage_*

/*Nombre de data para data_final (recomendable: no cambiar)*/
local data_wage_paa wage_paa

/*1 if simulating SII merge, 0 if not*/
local simulated_sii=1

/*Max number of siblings*/
local n_siblings = 5

******************************************************************
******************************************************************
*log using "$results/merge_wages_paa.smcl", replace

/*
use "$data/paa_9496_student.dta", clear
*/



*******************************************************************************
****ESTA LINEA PROBABLEMENTE CAMBIE (NO SERA NECESARIA SI SII ENTREGA DATOS DE ANTEMANO)****
*******************************************************************************

if `simulated_sii'==1{
	foreach ind in student father mother{
		use "$data/paa_9498_`ind'.dta", clear
		merge 1:1 rut_ using "$data/fakew_`ind'.dta"
		drop _merge
		tempfile wagedata_`ind'
		save `wagedata_`ind'', replace

	}
}

**********************************************************************
**********************************************************************
**********************************************************************
/*
We have data on wage and paa. Now, merge them (wide form)
"$data/paa_9496_mother.dta"
use "$data/paa_9496_student.dta"

*/

use `wagedata_student', clear
count
keep stud_id
sort stud_id
tempfile wagedata_student_aux
save `wagedata_student_aux', replace


foreach ind in father mother{

	use `wagedata_`ind'', clear

	*Rename all variables
	foreach vars of varlist _all{
		rename `vars' `vars'_`ind'

	}
	
	forvalues x=1/`n_siblings'{
		preserve
		rename stud_id`x'_`ind' stud_id
		keep stud_id `wage_variables'
		drop if stud_id==.
		isid stud_id
		merge 1:1 stud_id using `wagedata_student_aux'
		keep if _merge==3
		drop _merge
		tempfile data_`ind'_aux_`x'
		save `data_`ind'_aux_`x'', replace
		restore
		
	}

	use `data_`ind'_aux_1', clear
	forvalues x=2/4{
		append using `data_`ind'_aux_`x''

	}

	*Students w/ mothers and fathers
	tempfile all_`ind'
	save `all_`ind'', replace


}


use `wagedata_student', clear
foreach vars of varlist `wage_variables'{
	rename `vars' `vars'_student
}
merge 1:1 stud_id using `all_father'
gen merge_father=""
replace merge_father="With father" if _merge==3
replace merge_father="W/o father" if _merge==1
drop _merge
merge 1:1 stud_id using `all_mother'
gen merge_mother=""
replace merge_mother="With mother" if _merge==3
replace merge_mother="W/o mother" if _merge==1
drop _merge

save "$data/`data_wage_paa'.dta", replace

/*Here: analysis of merge*/
