/*
Este do-file prepara datos/variables PAA

*/

clear
clear matrix
clear mata
set more off


*ANTES DE CORRER:
*Cambiar folders

local user  = "Jorge"

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


***********************************************************************
***********************************************************************
***********************************************************************

/*Defining variables*/

forvalues y=94/98{
	use "$data/paa`y'.dta", clear
	drop _merge

	*Test scores
	local paa_test paa_h paa_b paa_s paa_f paa_mat paa_q  paa_v paa_m notas

	*PAA
	foreach paa of varlist paa_h paa_b paa_s paa_f paa_mat paa_q  paa_v paa_m notas{
		replace `paa'=. if `paa'==0
	}


	/*si el individuo tiene pareja*/
	gen pareja=0 if estciv!=.               
	replace pareja=1 if estciv==2 | estciv==5
	drop estciv

/*si no tiene trabajo remunerado es categoría base*/

	gen trabaja=0 if trab_r==1  
	replace trabaja=1 if trab_r>=2 
	drop trab_r
	
				/*TRABAJA O NO EL PADRE Y/O MADRE*/
	/*se consideró activos y otros; =1 para activos*/

	replace socu_pa=0 if socu_pa>=2 & socu_pa<=7 
	replace socu_ma=0 if socu_ma>=2 & socu_ma<=7
	replace socu_ma=. if socu_ma>7 /*bad coding*/

	*Rut to numeric. Drop students with no RUT
	destring rut rut_pa rut_ma, force replace
	drop if rut==.
	replace rut_pa=. if rut_pa==0
	replace rut_ma=. if rut_ma==0

	*Tipo colegio
	rename alumno type_school
	
	*Tipo educacion
	gen type_educ = 1 if tip_ed==9 | tip_ed==1 | tip_ed==2 
	replace type_educ = 0 if tip_ed>=3 & tip_ed<=8
	
	*Horario
	gen jornada=0 if horario!=. 

	if `y'<96{
	    replace jornada=1 if horario==0         /*=1 si es diurno*/
	}
	else{
	    replace jornada=1 if horario==1 
	}
	drop horario

	*Generating comuna identifier
	egen comuna = group(nom_com)
	drop nom_com

	*Year paa
	gen year=`y'

	/*
	*Iguala observaciones? dejar solo ruts validos. Luego borramos observaciones c/missing en covariates
	keep `paa_test' paa_av age_paa rut rut_pa rut_ma dig_pa dig_ma digito sexo egreso codcol prov_com region depe socu_pa socu_ma /*
	*/ d_ppag d_psub d_muni esc_pa esc_ma edp* edm* year 
	*/


	sort rut
	tempfile data_`y'
	save `data_`y'', replace

}


*************************************
*************************************
*************************************
/*All databases*/

use `data_94', clear
append using `data_95'
append using `data_96'
append using `data_97'
append using `data_98'
preserve
qui: do "$codes/descriptiva1.do"
restore 
*Dejando ultima paa
gen year_neg=-year
sort rut year_neg
bysort rut: egen seq_aux=seq()
keep if seq_aux==1
drop seq_aux year_neg


isid rut

*Disregarding students with no rut_pa or rut_ma
drop if rut_pa==. & rut_ma==.
drop if rut_pa==rut_ma


*Families ID: this is for merging later
gen fam_id =strofreal(rut_ma,"%11.0g") + "_" + strofreal(rut_pa,"%11.0g")
gen individual="student" 
rename rut rut_

tempfile data_aux
save `data_aux', replace


****Generating database of parents***

*Fathers
keep rut_pa dig_pa fam_id
drop if rut_pa==.
duplicates drop rut_pa, force
gen individual="father"
rename rut_pa rut_
rename dig_pa digito
tempfile data_father
save `data_father', replace


*Mothers
use `data_aux', clear
keep rut_ma dig_ma fam_id
drop if rut_ma==.
duplicates drop rut_ma, force
rename rut_ma rut_
rename dig_ma digito
gen individual="mother"
tempfile data_mother
save `data_mother', replace

*Both parents
append using `data_father'


*Now students and other variables
append using `data_aux'

drop rut_pa rut_ma dig_ma dig_pa


/*drop students: rut=rut_pa or rut_ma*/
duplicates tag rut_, gen(dupli)
keep if dupli==0 
drop dupli

*after previous drops, drop fathers and mothers w/ no students
gen d_stud = individual=="student"
bysort fam_id: egen tot_stud =total(d_stud)
drop if tot_stud==0



*This database is sorted by family.
*Use only observable characteristics associated to students

*Define control variables
local identifiers rut_ fam_id individual digito 
local charac sexo egreso year_na trabaja region comuna
local family socu_pa socu_ma esc_pa esc_ma
local test_scores paa_v paa_m paa_h notas
local schools codcol depe type_school type_educ


keep `identifiers' `charac' `family' `test_scores' `schools'


/*
egen paa = rowmean(paa_v paa_m)

xtile pc_paa = paa, nq(100)
xtile pc50_paa = paa, nq(50)
xtile pc25_paa = paa, nq(25)
xtile pc10_paa = paa, nq(10)


/*Checking #unique categories*/

duplicates r pc_paa region
duplicates r pc10_paa region depe if individual=="student" & depe!=.
duplicates tag region depe, gen(dupli)

duplicates r pc25_paa depe

duplicates r pc10_paa esc_pa esc_ma socu_pa socu_ma
*/

*Packing
/*
foreach name in charac family test_scores schools{

	local i = 1
	foreach variable in ``name''{
		tostring `variable', replace
		if `i' == 1{
			gen `name'_v = `variable'
		}
		else{
			replace `name'_v = `name'_v + "_" + `variable'
		}

		drop `variable'

		*drop `variable'
		local i = `i' + 1
	}

}




order rut_ digito fam_id individual *_v
*/
rename rut_ RUT
rename digito DV


save "$data/paa_9498_ok.dta", replace

*This is for SII
outsheet _all using "$data/data_RCU_ok.csv", replace


