 /*
This do-file merges the SIMCE with wage data

ASEGURAR QUE RUT ESTE EN FORMATO NUMERICO

Salarios anuales (respetar el sgte formato):
rem_yyyy, donde "rem" indica el tipo de variable; "yyyy" corresponde al anio

*/
clear
set more off



/*Cambiar folders*/

local user C

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

else if "`user'" == "C"{
	global codes "C:\Users\death\Desktop\jorge1\ige-codes"
	global data "C:\Users\death\Desktop\jorge1/data"
	global results "C:\Users\death\Desktop\jorge1/results"

}





/*Nombre de data para data_final (recomendable: no cambiar)*/
local data_wage_paa wage_paa

/*1 if simulating SII merge, 0 if not*/	
local simulated_sii=1


/*Time frame*/
local min_y = 1998
local max_y = 2015

/*Names of wages: la idea es clasificarlas aca*/
local var_names_labor w1* w2*
local var_names_capital w3* w4*

local prefix_labor w1 w2
local prefix_capital w3 w4


******************************************************************
******************************************************************
*log using "$results/merge_wages_paa.smcl", replace

/*
use "$data/paa_9496_student.dta", clear
*/



*******************************************************************************
****ESTA LINEA PROBABLEMENTE CAMBIE (NO SERA NECESARIA YA QUE/*
*/ SII ENTREGA DATOS DE ANTEMANO)****
*******************************************************************************

if `simulated_sii'==1{
	
	use "$data/paa_9498_ok.dta", clear
	merge 1:1 RUT using "$data/fakew_ok.dta"
	drop _merge
	tempfile wage_data_all
	save `wage_data_all', replace

	
}



**********************************************************************
**********************************************************************
**********************************************************************
/*
data in wide form: each obs is a student.

*/

foreach ind in "father" "mother"{
	keep if individual=="`ind'"
	rename RUT rut_`ind'
	keep rut_`ind' fam_id `var_names_labor' `var_names_capital'

	foreach variable of varlist `var_names_labor' `var_names_capital'{
		rename `variable' `variable'_`ind'
	}

	sort fam_id
	tempfile data_`ind'
	save `data_`ind'', replace

	use `wage_data_all', clear



}



*Note the format of wage data.
*This will probably change

keep if individual=="student"

merge m:1 fam_id using `data_father'
rename _merge merge_father

merge m:1 fam_id using `data_mother'
rename _merge merge_mother

*rename student wages
foreach varname in `prefix_labor' `prefix_capital'{
	forvalues y = `min_y'/`max_y'{
		rename `varname'_`y' `varname'_`y'_student

	}

}


*Those who are not merged: students with brothers but did not put both father/mother rut
*They may be from different families/father or mother died/ or forgot to put it
*I'll leave them as it is

save "$data/`data_wage_paa'.dta", replace

