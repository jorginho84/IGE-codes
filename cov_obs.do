/* 
This do-file drops observations with missing covariates
*/

*Only with information of mother or father
keep if merge_father == "With father" & merge_mother == "With mother"

