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
local years 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010/*
*/ 2011 2012 2013 2014 2015

/*number of years*/
local n_years 18

/*prefix of wage data*/
local wage_vars wage

/*peso/dollar last year of wage. 
source: www.bcentral.cl*/
local dollar = 654


*Real wages
qui: do "$codes/ipc.do"

*To real wages (year `ipc_base') in dollars. Change accordingly.
*Here, base year is 2015
qui: do "$codes/ipc.do"
foreach wages in `wage_vars'{
	foreach y in `years'{
		foreach ind in father mother student{
			replace `wages'_`y'_`ind'=`wages'_`y'_`ind'*(ipc_2015/ipc_`y')/`dollar'
		}
	}
}

*Log salarios
foreach wages in `wage_vars'{
	foreach year in `years'{
		foreach ind in father mother student{
			gen lw_`year'_`ind' = log(`wages'_`year'_`ind')
		}
	}
}


*Average salary across years
foreach wages in `wage_vars'{
	egen av_`wages' = rowmean(`wages'_*_student)
	gen l_av_`wages' = log(av_`wages')
}

*Family income
foreach wages in `wage_vars'{
	foreach y in `years'{
		egen family_`wages'_`y' = rowtotal(`wages'_`y'_father `wages'_`y'_mother )
	}
}

*Average family income across years
foreach wages in `wage_vars'{
	egen av_family_`wages' = rowmean(family_`wages'_*)
	gen l_av_family_`wages' = log(av_family_`wages')

}

