/*
This do-file defines de control variables
*/

*********************************************************************
*********************************************************************
*********************************************************************
/*Unpacking*/

local identifiers rut_ fam_id individual digito 
local charac sexo egreso year_na pareja trabaja region comuna
local family socu_pa socu_ma pcoh esc_pa esc_ma
local test_scores paa_v paa_m paa_h paa_b paa_s paa_f paa_mat paa_q  notas
local schools codcol depe type_school type_educ jornada


foreach name in charac family test_scores schools{

	split `name'_v, gen(`name'_v) parse(_)

}


/*Renaming*/
	
foreach name in charac family test_scores schools{
	local i = 1
	foreach variable in ``name''{
		rename `name'_v`i' `variable'
		destring `variable', force replace

		local i = `i' + 1
	}
}




*********************************************************************
*********************************************************************
/*educación del padre y madre: esc_pa & esc_ma*/
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


label variable edp1 "estudios básicos o sin estudios del padre"
label variable edp2 "estudios medios incompletos o completos del padre"
label variable edp3 "estudios superiores completos o incompletos del padre"
label variable edm1 "estudios básicos o sin estudios de madre"
label variable edm2 "estudios medios incompletos o completos de madre"
label variable edm3 "estudios superiores completos o incompletos de madre"   

*Who's head
gen d_jefe = 0 if pcoh!=.
replace d_jefe = 1 if pcoh == 3
label variable d_jefe "jefe familia es postulante"

*Gender
label define gender_lbl 1 "Male" 2 "Female"
label values sexo gender_lbl 

*Edad paa
gen age_paa=`y' - year_na - 1
gen age_paa2=age_paa^2


/*madurez medida por distancia del año de egreso*/
gen madurez=`z'-egreso-1 


*School type
label define type_school_lbl 1 "boys" 2 "girls" 3 "mixed"
label values type_school type_school_lbl

*Tipo educacion
label define type_educ_lbl 1 "Científico humanista" 0 "Tecnico-profesional"
label values type_educ type_educ_lbl

*Horario
label define horario_lbl 1 "Diurno" 0 "Otros"
label values jornada horario_lbl

*Dependencia-colegio
gen d_ppag=depe==1
gen d_psub=depe==2
gen d_muni=depe==3

*Average mat and language
egen paa_av=rowmean(paa_v paa_m)
replace paa_av=. if paa_av==0 



*Test scores
rename paa_m paa_1                 /*Prueba Aptitud Matemática*/
rename paa_v paa_2                 /*Prueba Aptitud Verbal*/
rename paa_h paa_3                 /*Prueba de Historia  y Geografía de Chile*/
rename paa_mat pce_1               /*PCE Matemática*/ 
rename paa_b pce_2                 /*PCE Biología*/
rename paa_s pce_3                 /*PCE Ciencias Sociales*/  
rename paa_f pce_4                 /*PCE Física*/
rename paa_q pce_5                 /*PCE Química*/

label variable paa_1 "Prueba Aptitud Matemática"                
label variable paa_2 "Prueba Aptitud Verbal"                
label variable paa_3 "Prueba de Historia  y Geografía de Chile"                
label variable pce_1 "PCE Matemática"              
label variable pce_2 "PCE Biología"                
label variable pce_3 "PCE Ciencias Sociales"                
label variable pce_4 "PCE Física"                
label variable pce_5 "PCE Química"               

*Dummy if especifico!=0
gen d_especifico = 0
forvalues x=1/5{
	replace d_especifico = 1 if pce_`x'!=.	
}

*If coming from a single- or two-parents household
gen d_single = (merge_father==3 & merge_mother==1) | (merge_father==1 & merge_mother==3)
