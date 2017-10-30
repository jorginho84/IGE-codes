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


/*Time frame*/
local min_y = 1998
local max_y = 2016

/*Names of wages*/
local var_names_labor v1* v2*
local var_names_capital v3* v4*

/*All wage variables (check format of SII data first)*/
forvalues y=`min_y'/`max_y'{
	local wage_labor_`y' v1_`y'	v2_`y'	
	
	local wage_capital_`y' v3_`y' v4_`y'
}


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
	
	use "$data/paa_9498_ok.dta", clear
	merge 1:1 rut_ using "$data/fakew_ok.dta"
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
	rename rut_ rut_`ind'
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


*Those who are not merged: students with brothers but did not put both father/mother rut
*They may be from different families/father or mother died/ or forgot to put it
*I'll leave them as it is


