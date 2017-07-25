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




/*Nombre de los datos*/
local data_wage_paa wage_paa


**********************************************
**********************************************
**********************************************
use "$data/`data_wage_paa'.dta", clear

*Defining wage variables
qui: do "$codes/wage_defs.do"

*These are the basic control variables
qui: do "$codes/controls.do"

*Drop obs
qui: do "$codes/cov_obs.do"

*SEs
local SE "robust"

**********************************************
**********************************************
**********************************************
/*IGE across gender and control variables*/


forvalues y = 1/4{ /*4 types of regressions*/

	if `y'==1{
		local control_vars 

	}
	else if `y'==2{
		local control_vars $F_controls
	}

	else if `y'==3{
		local control_vars $A_controls
	}
	else{
		local control_vars $F_controls $A_controls
	}

	*Regressions across gender and control variables
	xi: reg l_av_wage l_av_family_wage `control_vars', vce(`SE')
	mat overall_`y' = _b[l_av_family_wage]
	mat overall_`y'_ci = _b[l_av_family_wage] -  invttail(e(df_r),0.025)*_se[l_av_family_wage], /*
	*/  _b[l_av_family_wage] + invttail(e(df_r),0.025)*_se[l_av_family_wage]

	forvalues x=1/2{
		xi: reg l_av_wage l_av_family_wage `control_vars' if sexo == `x', vce(`SE')
		mat gender`x'_`y' = _b[l_av_family_wage]
		mat gender`x'_`y'_ci = _b[l_av_family_wage] -  invttail(e(df_r),0.025)*_se[l_av_family_wage], /*
	*/  _b[l_av_family_wage] + invttail(e(df_r),0.025)*_se[l_av_family_wage]
	}


}

*The table

local y = 1 
foreach num in 4 6 8 10{
	local x = `num' + 1
	putexcel C`num'=matrix(overall_`y') using "$results/ige_table_gender", sheet("data") modify
	putexcel C`x'=matrix(overall_`y'_ci) using "$results/ige_table_gender", sheet("data") modify
	
	forvalues s=1/2{
		if `s'==1{
			local letter F 
		}
		else{
			local letter I
		}
		putexcel `letter'`num'=matrix(gender`s'_`y') using "$results/ige_table_gender", sheet("data") modify
		putexcel `letter'`x'=matrix(gender`s'_`y'_ci) using "$results/ige_table_gender", sheet("data") modify
		
	}
	
	
	local y = `y' + 1
}


**********************************************
**********************************************
**********************************************
/*IGE across school types and control variables*/

forvalues y = 1/4{ /*4 types of regressions*/

	if `y'==1{
		local control_vars 

	}
	else if `y'==2{
		local control_vars $F_controls
	}

	else if `y'==3{
		local control_vars $A_controls
	}
	else{
		local control_vars $F_controls $A_controls
	}

	*Regressions across school type and control variables
	
	forvalues x=1/3{ /*1: private, 2: voucher, 3: public*/
		xi: reg l_av_wage l_av_family_wage `control_vars' if depe == `x', vce(`SE')
		mat school`x'_`y' = _b[l_av_family_wage]
		mat school`x'_`y'_ci = _b[l_av_family_wage] -  invttail(e(df_r),0.025)*_se[l_av_family_wage], /*
	*/  _b[l_av_family_wage] + invttail(e(df_r),0.025)*_se[l_av_family_wage]
	}


}


*The table

local y = 1 
foreach num in 4 6 8 10{
	local x = `num' + 1
		
	forvalues s=1/3{
		if `s'==1{
			local letter C 
		}
		else if `s'==2{
			local letter F
		}
		else{
			local letter I
		}
		putexcel `letter'`num'=matrix(school`s'_`y') using "$results/ige_table_schools", sheet("data") modify
		putexcel `letter'`x'=matrix(school`s'_`y'_ci) using "$results/ige_table_schools", sheet("data") modify
		
	}
	
	
	local y = `y' + 1
}


**********************************************
**********************************************
**********************************************
/*IGE across regions: save table and graph

maps: 15 regions

*/


forvalues y = 1/4{ /*4 types of regressions*/

	if `y'==1{
		local control_vars 

	}
	else if `y'==2{
		local control_vars $F_controls
	}

	else if `y'==3{
		local control_vars $A_controls
	}
	else{
		local control_vars $F_controls $A_controls
	}

	*Regressions across school type and control variables
	
	forvalues x=1/13{ /*Regiones*/
		xi: reg l_av_wage l_av_family_wage `control_vars' if region == `x', vce(`SE')
		mat regions`x'_`y' = _b[l_av_family_wage]
		scalar sregions`x'_`y' = _b[l_av_family_wage]
		mat regions`x'_`y'_ci = _b[l_av_family_wage] -  invttail(e(df_r),0.025)*_se[l_av_family_wage], /*
	*/  _b[l_av_family_wage] + invttail(e(df_r),0.025)*_se[l_av_family_wage]
	}


}


*The table

local y = 1 
foreach num in 4 6 8 10{
	local x = `num' + 1
		
	forvalues s=1/13{
		if `s'==1{
			local letter C 
		}
		else if `s'==2{
			local letter F
		}
		else if `s'==3{
			local letter I
		}

		else if `s'==4{
			local letter L
		}

		else if `s'==5{
			local letter O
		}

		else if `s'==6{
			local letter R
		}

		else if `s'==7{
			local letter U
		}

		else if `s'==8{
			local letter X
		}

		else if `s'==9{
			local letter AA
		}

		else if `s'==10{
			local letter AD
		}

		else if `s'==11{
			local letter AG
		}

		else if `s'==12{
			local letter AJ
		}

		else {
			local letter AM
		}

		putexcel `letter'`num'=matrix(regions`s'_`y') using "$results/ige_table_regions", sheet("data") modify
		putexcel `letter'`x'=matrix(regions`s'_`y'_ci) using "$results/ige_table_regions", sheet("data") modify
		
	}
	
	
	local y = `y' + 1
}

*The Map
tempfile wage_aux
save `wage_aux', replace

*creating database of coordinates
shp2dta using "$data/cl_reg_pib2010_bc_c2-33_geo", database("$data/chdb") coordinates("$data/chcoord") genid(id) replace 
*use "$data/chdb", clear

clear
set obs 15 /*15 regions*/
egen id = seq()


*According to chdb id file
gen ige = .


replace ige = sregions1_1 if _n==13 /*arica y parinacota*/
replace ige = sregions1_1 if _n==1 /*tarapaca*/
replace ige = sregions2_1 if _n==2 /*antofagasta*/
replace ige = sregions3_1 if _n==3 /*atacama*/
replace ige = sregions4_1 if _n==4 /*coquimbo*/
replace ige = sregions5_1 if _n==5 /*valparaiso*/
replace ige = sregions13_1 if _n==11 /*RM*/
replace ige = sregions6_1 if _n==6 /*Libertador*/
replace ige = sregions7_1 if _n==7 /*Maule*/
replace ige = sregions8_1 if _n==8 /*Biobio*/
replace ige = sregions9_1 if _n==9 /*Araucania*/
replace ige = sregions10_1 if _n==12 /*Los rios*/
replace ige = sregions10_1 if _n==10 /*Los Lagos*/
replace ige = sregions11_1 if _n==14 /*Aysen*/
replace ige = sregions12_1 if _n==15 /*Magallanes*/

*Cleaning up region data

*Merging with geographic data
merge 1:1 id using "$data/chdb"

drop if _merge!=3

*The graph
spmap ige using "$data/chcoord", id(id) fcolor(Blues)
graph export "$results/regions_ige.pdf", as(pdf) replace



**********************************************
**********************************************
**********************************************
/*
IGE above and below 475 points: find out about kinks design.

*RD plot
rdplot rem_2011 z_tilde if p_z_tilde>=2 & p_z_tilde<=99, binselect(es) kernel(epa)
graph save "$results/rd_all", replace asis


*/

use `wage_aux', clear

