/* 
This do-file drops observations with missing covariates
*/

*Only with information of mother or father
drop if merge_father == 1 & merge_mother == 1


*Defining group of control variables
local family ed*2 ed*3 d_jefe sexo age_paa* madurez
local school type_school type_educ jornada d_ppag d_psub
local test_scores paa_1 paa_2 paa_3 notas d_especifico


*Only with covariate info
qui: reg `family' `school' `test_scores'
keep if e(sample)==1

