/*
Este do-file prepara datos/variables PAA

*/

clear
clear matrix
clear mata
set more off


*ANTES DE CORRER:
*Cambiar folders
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



***********************************************************************
***********************************************************************
***********************************************************************

*use "C:\Users\Jorge\Dropbox\simce_sc\data\paa94.dta", clear

forvalues y=94/98{
	use "$data/paa`y'.dta", clear
	drop _merge

	*Test scores
	local paa_test paa_h paa_b paa_s paa_f paa_mat paa_q  paa_v paa_m notas

	*PAA
	foreach paa of varlist paa_h paa_b paa_s paa_f paa_mat paa_q  paa_v paa_m notas{
		replace `paa'=. if `paa'==0
	}


	*Edad paa
	gen age_paa=`y' - year_na - 1
	gen age_paa2=age_paa^2

	/*educación del padre*/

	gen edp1=0 if esc_pa!=.
	gen edp2=0 if esc_pa!=.           /*captura categoría 2*/
	gen edp3=0 if esc_pa!=.           /*captura categoría 3*/

	replace edp1=1 if esc_pa<4 & esc_pa>0  
	replace edp2=1 if esc_pa>=4 & esc_pa<=5   
	replace edp3=1 if esc_pa>=6 | esc_pa==0   

	/*educación de la madre*/

	gen edm1=0 if esc_ma!=.
	gen edm2=0 if esc_ma!=. 
	gen edm3=0 if esc_ma!=.
	replace edm1=1 if esc_ma<4 & esc_ma>0   
	replace edm2=1 if esc_ma>=4 & esc_ma<=5   
	replace edm3=1 if esc_ma>=6 | esc_ma==0 

	*Gender
	label define gender_lbl 1 "Male" 2 "Female"
	label values sexo gender_lbl

	label variable edp1 "estudios básicos o sin estudios del padre"
	label variable edp2 "estudios medios incompletos o completos del padre"
	label variable edp3 "estudios superiores completos o incompletos del padre"
	label variable edm1 "estudios básicos o sin estudios de madre"
	label variable edm2 "estudios medios incompletos o completos de madre"
	label variable edm3 "estudios superiores completos o incompletos de madre"

	/*madurez medida por distancia del año de egreso*/
	gen madurez=`z'-egreso-1   
	
				/*TRABAJA O NO EL PADRE Y/O MADRE*/
	/*se consideró activos y otros; =1 para activos*/

	replace socu_pa=0 if socu_pa>=2 & socu_pa<=7 
	replace socu_ma=0 if socu_ma>=2 & socu_ma<=7
	replace socu_ma=. if socu_ma>7 /*bad coding*/

	*Average mat and language
	egen paa_av=rowmean(paa_v paa_m)
	replace paa_av=. if paa_av==0 

	*Rut to numeric. Drop students with no RUT
	destring rut rut_pa rut_ma, force replace
	drop if rut==.
	
	*Dependencia-colegio
	gen d_ppag=depe==1
	gen d_psub=depe==2
	gen d_muni=depe==3
	
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

use `data_94', clear
append using `data_95'
append using `data_96'
append using `data_97'
append using `data_98'

*Dejando ultima paa
gen year_neg=-year
sort rut year_neg
bysort rut: egen seq_aux=seq()
keep if seq_aux==1
drop seq_aux year_neg


isid rut
save "$data/paa_9498_ok.dta", replace


*A long dataset
egen stud_id = seq()
rename rut rut_student
rename rut_pa rut_father
rename rut_ma rut_mother
reshape long rut_, i(stud_id) j(individual) string

*Save only students
preserve
keep if individual=="student"
save "$data/paa_9498_student.dta", replace
restore

*Save fathers and mothers
foreach parent in father mother{
	preserve
	keep if individual=="`parent'"
	keep individual stud_id rut_
	drop if rut_==. | rut_==0 /*invalid RUT. Leaving only numeric*/
	bysort rut: egen seq_aux=seq() /*generating number of siblings*/
	reshape wide stud_id, i(rut_) j(seq_aux) /*preserving stud_id*/
	isid rut_
	save "$data/paa_9498_`parent'.dta", replace
	restore
}


