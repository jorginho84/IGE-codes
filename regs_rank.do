/* 
This do-file computes rank-based measures of int mobiity
*/

program drop _all

program graphs
	version 13
	args samp d_sample beta ses
	tempfile data_orig
	save `data_orig', replace
	*Figures
	collapse (mean) pc_av_income_student if `d_sample'==1, by(pc_av_income_familyw)
	twoway (scatter pc_av_income_student pc_av_income_familyw, mlcolor(blue) mfcolor(none) msize(large)), /*
	*/ ytitle("Mean offspring income percentile ")  /*
	*/ xtitle("Parents income percentile") /*
	*/ graphregion(fcolor(white) ifcolor(white) lcolor(white) ilcolor(white))/*
	*/ plotregion(fcolor(white) lcolor(white)  ifcolor(white) ilcolor(white)) /*
	*/ yscale(range(0 100))/*
	*/ xlabel(0(10)100) ylabel(0(10)100)/*
	*/ text(5 95 "Slope = `beta'", place(n))/*
	*/ text(5 95 "             (`ses')", place(s))/**/

	graph export "$results/rank/rr_`samp'.pdf", as(pdf) replace

	use `data_orig', clear
end

*Rank-rank regressions
gen d_sample = 1
qui: reg pc_av_income_student pc_av_income_familyw
local beta_overall = string(round((_b[pc_av_income_familyw])*100,0.01),"%9.2f") 
local se_overall = string(round((_se[pc_av_income_familyw])*100,0.01),"%9.2f") 
graphs "overall" d_sample `beta_overall' `se_overall'
drop d_sample

forvalues x=1/2{
	gen d_sample = sexo==`x'
	qui: reg pc_av_income_student pc_av_income_familyw if sexo==`x'
	local beta_overall_sex`x' = string(round((_b[pc_av_income_familyw])*100,0.01),"%9.2f") 
	local se_overall_sex`x' = string(round((_se[pc_av_income_familyw])*100,0.01),"%9.2f") 
	graphs "overall_sex`x'" d_sample `beta_overall_sex`x'' `se_overall_sex`x''
	drop d_sample
}

forvalues dsi = 0/1{

	gen d_sample = d_single==`dsi'
	qui: reg pc_av_income_student pc_av_income_familyw if d_single==`dsi'
	local beta_overall_single`dsi' = string(round((_b[pc_av_income_familyw])*100,0.01),"%9.2f") 
	local se_overall_`dsi' = string(round((_se[pc_av_income_familyw])*100,0.01),"%9.2f") 
	graphs "sample`dsi'" d_sample `beta_overall_single`dsi'' `se_overall_`dsi''
	drop d_sample

	forvalues x=1/2{
		gen d_sample = d_single==`dsi' & sexo==`x'
		qui: reg pc_av_income_student pc_av_income_familyw if d_single==`dsi'& sexo==`x'
		local beta_overall_sex`x'_single`dsi' = string(round((_b[pc_av_income_familyw])*100,0.01),"%9.2f") 
		local se_overall_sex`x'_single`dsi' = string(round((_se[pc_av_income_familyw])*100,0.01),"%9.2f") 
		graphs "sample`dsi'_sex`x'" d_sample `beta_overall_sex`x'_single`dsi'' `se_overall_sex`x'_single`dsi''
		drop d_sample
	}


}








