/*
This do-file computes spline regressions on the IGE
*/

*Percentiles

tempfile data_aux
save `data_aux', replace

*Define how many percentiles
local n_pc = 10
qui: xtile pc_lav_income_familyw = lav_income_familyw, nq(`n_pc') 


forvalues x=1/`n_pc'{
	qui: reg lav_income_student lav_income_familyw  if pc_lav_income_familyw==`x'
	local ige_`x' = _b[lav_income_familyw]
	local se_`x' = _se[lav_income_familyw]
	local lb_`x' = _b[lav_income_familyw] - invnormal(0.025)*_se[lav_income_familyw]
	local ub_`x' = _b[lav_income_familyw] + invnormal(0.025)*_se[lav_income_familyw]
	qui: reg lav_income_student lav_income_familyw  if pc_lav_income_familyw==`x' & av_capital_familyw>0
	local ige_cap_`x' = _b[lav_income_familyw]
	local se_cap_`x' = _se[lav_income_familyw]
	local lb_cap_`x' = _b[lav_income_familyw] - invnormal(0.025)*_se[lav_income_familyw]
	local ub_cap_`x' = _b[lav_income_familyw] + invnormal(0.025)*_se[lav_income_familyw]
	if pc_lav_income_familyw==`x' & av_capital_familyw==0{
		qui: reg lav_income_student lav_income_familyw  if pc_lav_income_familyw==`x' & av_capital_familyw==0
		local ige_lab_`x' = _b[lav_income_familyw]
		local se_lab_`x' = _se[lav_income_familyw]
		local lb_lab_`x' = _b[lav_income_familyw] - invnormal(0.025)*_se[lav_income_familyw]
		local ub_lab_`x' = _b[lav_income_familyw] + invnormal(0.025)*_se[lav_income_familyw]

	}
	else{
		local ige_lab_`x' = 0
		local se_lab_`x' = 0
		local lb_lab_`x' = 0
		local ub_lab_`x' = 0

	}
		
}




preserve
clear
set obs `n_pc'
gen betas=.
gen lb=.
gen ub=.
gen pc=.


local i = 1
forvalues per=1/`n_pc'{
	replace betas = `ige_`per'' if _n==`i'
	replace lb = `lb_`per'' if _n==`i'
	replace ub = `ub_`per'' if _n==`i'
	replace pc = `i' if _n==`i'
	local i = `i' + 1 
}


twoway (scatter betas pc,msymbol(circle) mlcolor(blue) mfcolor(white)) /*
*/ (rcap ub lb pc, lcolor(blue)), /* These are the mean effect and the 95% confidence interval
*/ ytitle("IGE")  xtitle("Log family income deciles") legend(off) /*
*/ graphregion(fcolor(white) ifcolor(white) lcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white)  ifcolor(white) ilcolor(white))  /*
*/ scheme(s2mono) ylabel(, nogrid) 

graph export "$results/spline/ige_pc.pdf", as(pdf) replace

restore


preserve
clear
set obs `n_pc'

gen pc=.
foreach vars in "cap" "lab"{
	gen betas_`vars'=.
	gen lb_`vars'=.
	gen ub_`vars'=.
	

}


foreach vars in "cap" "lab"{
	local i = 1
	forvalues per=1/`n_pc'{
		replace betas_`vars' = `ige_`vars'_`per'' if _n==`i'
		replace lb_`vars' = `lb_`vars'_`per'' if _n==`i'
		replace ub_`vars' = `ub_`vars'_`per'' if _n==`i'
		local i = `i' + 1 
	}
}

local i = 1
forvalues per=1/`n_pc'{
	replace pc = `i' if _n==`i'
	local i = `i' + 1 
}

twoway (scatter betas_cap pc,msymbol(circle) mlcolor(blue) mfcolor(white)) /*
*/ (rcap ub_cap lb_cap pc, lcolor(blue)) /* These are the mean effect and the 95% confidence interval
*/(scatter betas_lab pc,msymbol(square) mlcolor(black) mfcolor(white)) /*
*/ (rcap ub_lab lb_lab pc, lcolor(blue)), /*
*/ ytitle("IGE")  xtitle("Log family income deciles") legend(order(1 "With capital" 3 "No capital")  ) /*
*/ graphregion(fcolor(white) ifcolor(white) lcolor(white) ilcolor(white)) /*
*/ plotregion(fcolor(white) lcolor(white)  ifcolor(white) ilcolor(white))  /*
*/ scheme(s2mono) ylabel(, nogrid) 
*/
graph export "$results/spline/ige_pc_caplab.pdf", as(pdf) replace

restore



use `data_aux', clear

