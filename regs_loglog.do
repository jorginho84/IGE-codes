/* 
This do-file computes log-log and variations on the overall sample
*/
program drop _all

*The pval function
program pval, rclass
	version 13
	args loc_pval
	tempname pval_indicator
	if `loc_pval'<=0.01{
		return local pval_indicator "***"
	}
	else if `loc_pval'<=0.05{
		return local pval_indicator "**"
	}
	else if `loc_pval'<=0.1{
		return local pval_indicator "*"
	}
	else{
		return local pval_indicator ""	
	}
end


*Opening table

file open loglog using "$results/loglog.tex", write replace
file write loglog "\begin{tabular}{llccccccccccccc}" _n
file write loglog "\hline" _n
file write loglog "\multirow{2}[2]{*}{Regression} &       & \multirow{2}[2]{*}{Overall} &       & \multirow{2}[2]{*}{Males} &       & \multirow{2}[2]{*}{Females} &       & \multicolumn{3}{c}{Single} &       & \multicolumn{3}{c}{Not single} \bigstrut[t]\\" _n
file write loglog "&&& &&&&& Male  & Female & All   && Male  & Female & All \bigstrut[b]\\" _n
file write loglog "\cline{1-1}\cline{3-3}\cline{5-5}\cline{7-7}\cline{9-11}\cline{13-15} &&&&&&&&&&&& &&  \bigstrut[t]\\" _n

*For excel table
local letter1 = "D"
local letter2 = "F"
local letter3 = "H"
local letter4 = "J"
local letter5 = "K"
local letter6 = "L"
local letter7 = "N"
local letter8 = "O"
local letter9 = "P"

putexcel set "$results/table_loglog", sheet("loglog") modify


*********************************************************
*********************************************************
/*Log-Log regressions*/
*********************************************************
*********************************************************


*
local i = 1
foreach vars in " " 0{ /*loop: log-log y log-log con zeros*/
	*1. Log-Log overall
	qui: reg lav_income_student`vars' lav_income_familyw`vars'
	local beta_loglog_overall = string(round((_b[lav_income_familyw`vars'])*100,0.01),"%9.2f")
	local se_loglog_overall = string(round((_se[lav_income_familyw`vars'])*100,0.01),"%9.2f")
	qui: test lav_income_familyw`vars'
	pval r(p)
	local pval_overall r(pval_indicator)


	*2. Log-Log males (1) and females (2)

	forvalues x=1/2{
		qui: reg lav_income_student`vars' lav_income_familyw`vars' if sexo==`x'
		local beta_loglog_sex`x' = string(round((_b[lav_income_familyw`vars'])*100,0.01),"%9.2f")
		local se_loglog_sex`x' = string(round((_se[lav_income_familyw`vars'])*100,0.01),"%9.2f")
		qui: test lav_income_familyw`vars'
		pval r(p)
		local pval_sex`x' r(pval_indicator)

	}


	*3. By household composition
	

	forvalues dsi = 0/1{
		qui: reg lav_income_student`vars' lav_income_familyw`vars' if d_single==`dsi'
		local beta_loglog_single`dsi'_overall = string(round((_b[lav_income_familyw`vars'])*100,0.01),"%9.2f")
		local se_loglog_single`dsi'_overall = string(round((_se[lav_income_familyw`vars'])*100,0.01),"%9.2f")
		qui: test lav_income_familyw`vars'
		pval r(p)
		local pval_single`dsi'_overall r(pval_indicator)

		forvalues x=1/2{
			qui: reg lav_income_student`vars' lav_income_familyw`vars' if sexo==`x' & d_single==`dsi'
			local beta_loglog_single`dsi'_sex`x' = string(round((_b[lav_income_familyw`vars'])*100,0.01),"%9.2f")
			local se_loglog_single`dsi'_sex`x' = string(round((_se[lav_income_familyw`vars'])*100,0.01),"%9.2f")
			qui: test lav_income_familyw`vars'
			pval r(p)
			local pval_single`dsi'_sex`x' r(pval_indicator)

		}


	}

	
	**Writing in table

	if `i'==1{
		file write loglog "Log-Log"	
		local num_table = 5 

	}
	else if `i'==2{
		file write loglog "Log-Log (zeros in log income)"
		local num_table = 8		
	}
	local num_se = `num_table'+1
	
	local j = 1
	foreach vars in overall sex1 sex2 single1_overall single1_sex1 single1_sex2 single0_overall single0_sex1 single0_sex2 {
		
		if `j'<=4 | `j'==7{
			file write loglog "&& `beta_loglog_`vars''`pval_loglog_`vars''"	
		}
		else{
			file write loglog "& `beta_loglog_`vars''`pval_loglog_`vars''"		
		}

		putexcel `letter`j''`num_table'=("`beta_loglog_`vars''`pval_loglog_`vars''") 
		
		local j = `j' + 1
	}
	file write loglog "\\"_n
	local j = 1
	foreach vars in overall sex1 sex2 single1_overall single1_sex1 single1_sex2 single0_overall single0_sex1 single0_sex2 {
		if `j'<=4 | `j'==7{
			file write loglog "&& (`se_loglog_`vars'')"	
		}
		else{
			file write loglog "& (`se_loglog_`vars'')"
		}

		putexcel `letter`j''`num_se'=("(`se_loglog_`vars'')") 
		
		local j = `j' + 1
	}
	file write loglog "\\"_n
	file write loglog "&&&&&&&&&       &       &       &       &       &  \\" _n

	local i = `i' + 1

}


**************************************************************************************
**************************************************************************************
/*d ln E /d ln X*/
**************************************************************************************
**************************************************************************************




*Step 2: database of percentiles and regression
program define reg_beta, rclass
	version 13
	args d_sample
	preserve
	collapse (mean) av_income_student if `d_sample'==1, by(pc_av_income_student)
	rename pc_av_income_student pc
	tempfile mean_stud
	save `mean_stud', replace
	restore

	preserve
	collapse (mean) av_income_familyw if `d_sample'==1, by(pc_av_income_familyw)
	rename pc_av_income_familyw pc
	qui: merge 1:1 pc using `mean_stud'

	gen lav_income_student=log(av_income_student)
	gen lav_income_familyw=log(av_income_familyw)
	reg lav_income_student lav_income_familyw
	return local beta_ed_overall = string(round((_b[lav_income_family])*100,0.01),"%9.2f")
	return local se_ed_overall = string(round((_se[lav_income_family])*100,0.01),"%9.2f")
	qui: test lav_income_familyw
	local pval = r(p)

	if `pval'<=0.01{
		return local pval_indicator "***"
	}
	else if `pval'<=0.05{
		return local pval_indicator "**"
	}
	else if `pval'<=0.1{
		return local pval_indicator "*"
	}
	else{
		return local pval_indicator ""	
	}

	restore

end

*computing estimates by sample
gen d_sample  =1
reg_beta d_sample
local beta_rege_overall =  r(beta_ed_overall)
local se_rege_overall =  r(se_ed_overall)
local pvalue = r(pval_ed_overall)
local pval_rege_overall = r(pval_indicator)
drop d_sample

forvalues x=1/2{
	gen d_sample = sexo==`x'
	reg_beta d_sample
	local beta_rege_sex`x' =  r(beta_ed_overall)
	local se_rege_sex`x' =  r(se_ed_overall)
	local pvalue = r(pval_ed_overall)
	local pval_rege_sex`x' = r(pval_indicator)
	drop d_sample


}

forvalues dsi = 0/1{
	gen d_sample = d_single==`dsi'
	reg_beta d_sample
	local beta_rege_single`dsi'_overall =  r(beta_ed_overall)
	local se_rege_single`dsi'_overall =  r(se_ed_overall)
	local pvalue = r(pval_ed_overall)
	local pval_rege_single`dsi'_overall = r(pval_indicator)
	drop d_sample

	

	forvalues x=1/2{
		gen d_sample = d_single==`dsi' & sexo == `x'
		reg_beta d_sample
		local beta_rege_single`dsi'_sex`x' =  r(beta_ed_overall)
		local se_rege_single`dsi'_sex`x' =  r(se_ed_overall)
		local pvalue = r(pval_ed_overall)
		local pval_rege_single`dsi'_sex`x' = r(pval_indicator)
		drop d_sample
			

	}


}

*Write in table

file write loglog "\$d \ln E[Y\mid X] / d \ln X\$"
local i = 1
foreach vars in overall sex1 sex2 single1_overall single1_sex1 single1_sex2 single0_overall single0_sex1 single0_sex2 {
	if `i'<=4 | `i'==7{
		file write loglog "&& `beta_rege_`vars''`pval_rege_`vars''"	
	}
	else{
		file write loglog "& `beta_rege_`vars''`pval_rege_`vars''"		
	}

	putexcel `letter`i''11=("`beta_rege_`vars''`pval_rege_`vars''") 
	
	local i = `i' + 1
}
file write loglog "\\"_n
local i = 1
foreach vars in overall sex1 sex2 single1_overall single1_sex1 single1_sex2 single0_overall single0_sex1 single0_sex2 {
	if `i'<=4 | `i'==7{
		file write loglog "&& (`se_rege_`vars'')"
	}
	else{
		file write loglog "& (`se_rege_`vars'')"

	}
	putexcel `letter`i''12=("(`se_rege_`vars'')") 

	local i = `i' + 1
}
file write loglog "\\"_n

************************************************************
************************************************************
************************************************************
/*Median regressions*/




*1. Log-Log overall
qui: qreg lav_income_student0 lav_income_familyw0
local beta_loglog_overall = string(round((_b[lav_income_familyw0])*100,0.01),"%9.2f")
local se_loglog_overall = string(round((_se[lav_income_familyw0])*100,0.01),"%9.2f")
qui: test lav_income_familyw0
pval r(p)
local pval_overall r(pval_indicator)


*2. Log-Log males (1) and females (2)

forvalues x=1/2{
	qui: qreg lav_income_student0 lav_income_familyw0 if sexo==`x'
	local beta_loglog_sex`x' = string(round((_b[lav_income_familyw0])*100,0.01),"%9.2f")
	local se_loglog_sex`x' = string(round((_se[lav_income_familyw0])*100,0.01),"%9.2f")
	qui: test lav_income_familyw0
	pval r(p)
	local pval_sex`x' r(pval_indicator)

}


*3. By household composition


forvalues dsi = 0/1{
	qui: qreg lav_income_student0 lav_income_familyw0 if d_single==`dsi'
	local beta_loglog_single`dsi'_overall = string(round((_b[lav_income_familyw0])*100,0.01),"%9.2f")
	local se_loglog_single`dsi'_overall = string(round((_se[lav_income_familyw0])*100,0.01),"%9.2f")
	qui: test lav_income_familyw0
	pval r(p)
	local pval_single`dsi'_overall r(pval_indicator)

	forvalues x=1/2{
		qui: qreg lav_income_student0 lav_income_familyw0 if sexo==`x' & d_single==`dsi'
		local beta_loglog_single`dsi'_sex`x' = string(round((_b[lav_income_familyw0])*100,0.01),"%9.2f")
		local se_loglog_single`dsi'_sex`x' = string(round((_se[lav_income_familyw0])*100,0.01),"%9.2f")
		qui: test lav_income_familyw0
		pval r(p)
		local pval_single`dsi'_sex`x' r(pval_indicator)

	}


}


**Writing in table

file write loglog "Median (zeros in log income)"



local i = 1
foreach vars in overall sex1 sex2 single1_overall single1_sex1 single1_sex2 single0_overall single0_sex1 single0_sex2 {
	
	if `i'<=4 | `i'==7{
		file write loglog "&& `beta_loglog_`vars''`pval_loglog_`vars''"

	}
	else{
		file write loglog "& `beta_loglog_`vars''`pval_loglog_`vars''"	
	}

	putexcel `letter`i''14=("`beta_loglog_`vars''`pval_loglog_`vars''") 
	
	local i = `i' + 1
}
file write loglog "\\"_n
local i = 1
foreach vars in overall sex1 sex2 single1_overall single1_sex1 single1_sex2 single0_overall single0_sex1 single0_sex2 {
	if `i'<=4 | `i'==7{
		file write loglog "&& (`se_loglog_`vars'')"	
	}
	else{
		file write loglog "& (`se_loglog_`vars'')"
	}
	
	putexcel `letter`i''15=("(`se_loglog_`vars'')") 
	local i = `i' + 1
}
file write loglog "\\"_n
file write loglog "&&&&&&&&&       &       &       &       &       &  \\" _n



************************************************************
************************************************************
************************************************************

*Closing table
file write loglog "      &&&&&&&&&&&&&&  \bigstrut[b]\\" _n
file write loglog " \hline" _n
file write loglog " \end{tabular}" _n
file close loglog
