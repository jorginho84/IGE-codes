/* 
This do-file defines the wage data

Define parental wage data as: 
wage_y_x, 
where y= year and x=individual (father/mother)

Student wage data:
wage_y

*Define: monthly or annual

*/

/*set the number of years*/
local years 2004 2005 2006 2007 2008 2009 2010/*
*/ 2011 2012 2013 2014 2015

/*number of years*/
local n_years 12

/*Time frame*/
local min_y = 2004
local max_y = 2016

/*Names of wages: la idea es clasificarlas aca*/
local prefix_labor w1 w2
local prefix_capital w3 w4


/*peso/dollar last year of wage. 
source: www.bcentral.cl*/
local dollar = 654


*To real wages (year `ipc_base') in dollars. Change accordingly.
*Here, base year is 2015
foreach wages in `prefix_labor' `prefix_labor'{
	foreach y in `years'{
		foreach ind in father mother student{
			replace `wages'_`y'_`ind'=`wages'_`y'_`ind'*(ipc_2015/ipc_`y')/`dollar'
		}
	}
}

*Average income of student across all years
egen av_income_student = rowmean(*_student)
gen av_income_student0 = av_income_student
replace av_income_student0 = 1 if av_income_student==0
gen lav_income_student = log(av_income_student)
gen lav_income_student0 = log(av_income_student0)


*Sources of income by family
foreach wages in `prefix_labor' `prefix_capital'{
	foreach y in `years'{
		egen familyw_`wages'_`y' = rowtotal(`wages'_`y'_father `wages'_`y'_mother )
	}
}

*Average capital family income 
foreach y in `years'{
	gen av_income_family_capital_`y' = 0
	
	foreach wages in `prefix_capital'{
		replace av_income_family_capital_`y' = av_income_family_capital_`y' + familyw_`wages'_`y'
	}
	
}

*Average labor family income 
foreach y in `years'{
	gen av_income_family_labor_`y' = 0
	
	foreach wages in `prefix_labor'{
		replace av_income_family_labor_`y' = av_income_family_labor_`y' + familyw_`wages'_`y'
	}
	
}

*Average income of family across all years
egen av_capital_familyw = rowmean(av_income_family_capital_*)
egen av_labor_familyw = rowmean(av_income_family_labor_*)
egen av_income_familyw = rowmean(familyw_*)
gen av_income_familyw0 = av_income_familyw
replace av_income_familyw0 = 1 if av_income_familyw==0
gen lav_income_familyw = log(av_income_familyw)
gen lav_income_familyw0 = log(av_income_familyw0)


*Percentiles
xtile pc_av_income_student = av_income_student, nq(100)
xtile pc_av_income_familyw = av_income_familyw, nq(100)

*Redefine ranking in case of ties (income zero)
tempfile data_aux
save `data_aux', replace

collapse (mean) av_income_student, by(pc_av_income_student)
keep if av_income_student==0
count
if r(N)>1{ /*if income is zero for more than one percentile, av these percentiles*/
	egen pc_av_income_student_new = rowmean(pc_av_income_student)
	merge 1:m pc_av_income_student using `data_aux'
	replace pc_av_income_student = pc_av_income_student_new if av_income_student==0
	drop pc_av_income_student_new

}
else{
	use `data_aux', clear
}

*Redefine ranking in case of ties (income zero)

tempfile data_aux2
save `data_aux2', replace

collapse (mean) av_income_familyw, by(pc_av_income_familyw)
keep if av_income_familyw==0
count
if r(N)>1{ /*if income is zero for more than one percentile, av these percentiles*/
	egen pc_av_income_familyw_new = rowmean(pc_av_income_familyw)
	merge 1:m pc_av_income_familyw using `data_aux'
	replace pc_av_income_familyw = pc_av_income_familyw_new if av_income_familyw==0
	drop pc_av_income_familyw_new

}
else{
	use `data_aux2', clear
}

compress

