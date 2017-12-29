***Summary statistics*****
* Jorge
clear
clear matrix
clear mata
set more off
local user Jorge

if "`user'"=="Jorge"{
	global codes "/home/jorger/ige/codes"
	global data "/home/jorger/ige/data"
	global results "/home/jorger/ige/results"  

}
else if "`user'"=="Nico"{
	global codes 
	global data 
	global results 

}





	global codes "C:\Users\death\Desktop\jorge\ige-codes"
	global data "C:\Users\death\Desktop\jorge\data"
	global results "C:\Users\death\Desktop\jorge\results"
cd "$results"



***********************************************************************
***********************************************************************
***********************************************************************

********************************************************************************
*Step 1: Summary statistics of students variables (tex and xlsx format)
********************************************************************************
use "$data/data_wage_paa.dta", clear
*Real wages
qui: do "$codes/ipc.do"

*Defining wage variables
qui: do "$codes/wage_defs.do"

*These are the basic control variables: unpacking variables
qui: do "$codes/controls.do"

*Drop obs
qui: do "$codes/cov_obs.do"

local charac sexo egreso   year_na  pareja  trabaja region  ///
comuna socu_pa   socu_ma pcoh esc_pa esc_ma paa_2 paa_1 paa_3 pce_* ///         
notas depe  type_school  type_educ    jornada edp* edm* d_jefe ///
age_paa* madurez d_ppag d_psub d_muni paa_av d_especifico
matrix SS=J(31,3,.)
local i=1
foreach x in `charac'  {

          qui sum `x'
          qui mat SS[`i',1]=r(mean)'
		  qui mat SS[`i',2]=r(sd)'
		  qui mat SS[`i',3]=r(N)'
          
		  local i=`i'+1
		  }
		  .
		 
     mat colnames SS=Mean SD Observations
	 mat rownames SS=`charac' 
outtable using SS,mat(SS) replace
putexcel set results,replace
putexcel A1="Variables"
putexcel B1="Mean"
putexcel C1="SD" 
putexcel D1="Observations"
putexcel A2 = matrix(SS), rownames

********************************************************************************
*Step 2: Summary statistics of wage variables (tex and xlsx format) from fakew_ok.dta
********************************************************************************
forv r=1998/2015 { 
ge w11_`r'=familyw_w1_`r'+familyw_w2_`r' 
ge w21_`r'=familyw_w3_`r'+familyw_w4_`r' 
ge wtotal_`r'=w11_`r'+w21_`r'
}
.
matrix SS=J(57,3,.)
local i=1
local r w11_1998 w21_1998 wtotal_1998 w11_1999 w21_1999 wtotal_1999 w11_2000 w21_2000 wtotal_2000 ///
w11_2001 w21_2001 wtotal_2001 w11_2002 w21_2002 wtotal_2002 w11_2003 w21_2003 wtotal_2003 w11_2004 w21_2004 wtotal_2004 w11_2005 w21_2005 wtotal_2005 ///
w11_2006 w21_2006 wtotal_2006 w11_2007 w21_2007 wtotal_2007 w11_2007 w21_2007 wtotal_2007 w11_2008 w21_2008 wtotal_2008 w11_2009 w21_2009 wtotal_2009 ///
w11_2010 w21_2010 wtotal_2010 w11_2011 w21_2011 wtotal_2011 w11_2012 w21_2012 wtotal_2012 w11_2013 w21_2013 wtotal_2013 w11_2014 w21_2014 wtotal_2014 ///
w11_2015 w21_2015 wtotal_2015
foreach j in `r' {

          qui sum `j'
          qui mat SS[`i',1]=r(mean)'
		  qui mat SS[`i',2]=r(sd)'
		  qui mat SS[`i',3]=r(N)'
          
		  local i=`i'+1
		  }
		  .
		  
     mat colnames SS=Mean SD Observations
	 mat rownames SS=`r' 
outtable using wages1,mat(SS) replace
putexcel set wage1,replace
putexcel A1="Variables"
putexcel B1="Mean"
putexcel C1="SD" 
putexcel D1="Observations"
putexcel A2 = matrix(SS), rownames

********************************************************************************
*Step 3: Summary statistics of wage variables (tex and xlsx format) from fakew_ok.dta
********************************************************************************
use "$data/fakew_ok.dta", replace
forv r=1998/2015 { 
ge w11_`r'=w1_`r'+w2_`r' 
ge w21_`r'=w3_`r'+w4_`r'
ge wtotal_`r'=w11_`r'+w21_`r'
}
.
matrix SS=J(57,3,.)
local i=1
local r w11_1998 w21_1998 wtotal_1998 w11_1999 w21_1999 wtotal_1999 w11_2000 w21_2000 wtotal_2000 ///
w11_2001 w21_2001 wtotal_2001 w11_2002 w21_2002 wtotal_2002 w11_2003 w21_2003 wtotal_2003 w11_2004 w21_2004 wtotal_2004 w11_2005 w21_2005 wtotal_2005 ///
w11_2006 w21_2006 wtotal_2006 w11_2007 w21_2007 wtotal_2007 w11_2007 w21_2007 wtotal_2007 w11_2008 w21_2008 wtotal_2008 w11_2009 w21_2009 wtotal_2009 ///
w11_2010 w21_2010 wtotal_2010 w11_2011 w21_2011 wtotal_2011 w11_2012 w21_2012 wtotal_2012 w11_2013 w21_2013 wtotal_2013 w11_2014 w21_2014 wtotal_2014 ///
w11_2015 w21_2015 wtotal_2015
foreach j in `r' {

          qui sum `j'
          qui mat SS[`i',1]=r(mean)'
		  qui mat SS[`i',2]=r(sd)'
		  qui mat SS[`i',3]=r(N)'
          
		  local i=`i'+1
		  }
		  .
		  
     mat colnames SS=Mean SD Observations
	 mat rownames SS=`r' 
outtable using wages,mat(SS) replace
putexcel set wage,replace
putexcel A1="Variables"
putexcel B1="Mean"
putexcel C1="SD" 
putexcel D1="Observations"
putexcel A2 = matrix(SS), rownames

********************************************************************************
*Step 4: Post-merge equal mean wages
********************************************************************************
use "$data/data_wage_paa.dta", clear
forv r=1998/2015 { 
egen w111_`r'=rowmean(w1_`r'_*)
egen w112_`r'=rowmean(w2_`r'_*)
ge w11_`r'=w111_`r'+w112_`r'
egen w211_`r'=rowmean(w3_`r'_* w4_`r'_*)
egen w212_`r'=rowmean(w4_`r'_*)
ge w12_`r'=w211_`r'+w212_`r'
ge wtotal_`r'=w11_`r'+w21_`r'
}
.
matrix SS=J(57,3,.)
local i=1
local r w11_1998 w21_1998 wtotal_1998 w11_1999 w21_1999 wtotal_1999 w11_2000 w21_2000 wtotal_2000 ///
w11_2001 w21_2001 wtotal_2001 w11_2002 w21_2002 wtotal_2002 w11_2003 w21_2003 wtotal_2003 w11_2004 w21_2004 wtotal_2004 w11_2005 w21_2005 wtotal_2005 ///
w11_2006 w21_2006 wtotal_2006 w11_2007 w21_2007 wtotal_2007 w11_2007 w21_2007 wtotal_2007 w11_2008 w21_2008 wtotal_2008 w11_2009 w21_2009 wtotal_2009 ///
w11_2010 w21_2010 wtotal_2010 w11_2011 w21_2011 wtotal_2011 w11_2012 w21_2012 wtotal_2012 w11_2013 w21_2013 wtotal_2013 w11_2014 w21_2014 wtotal_2014 ///
w11_2015 w21_2015 wtotal_2015
foreach j in `r' {

          qui sum `j'
          qui mat SS[`i',1]=r(mean)'
		  qui mat SS[`i',2]=r(sd)'
		  qui mat SS[`i',3]=r(N)'
          
		  local i=`i'+1
		  }
		  .
		  
     mat colnames SS=Mean SD Observations
	 mat rownames SS=`r' 
outtable using wages_1,mat(SS) replace
putexcel set wage_1,replace
putexcel A1="Variables"
putexcel B1="Mean"
putexcel C1="SD" 
putexcel D1="Observations"
putexcel A2 = matrix(SS), rownames
********************************************************************************
********************************************************************************
use "$data/data_wage_paa.dta", clear
forv r=1998/2015 { 
egen w111_`r'=rowmean(w1_`r'_*)
egen w112_`r'=rowmean(w2_`r'_*)
ge w11_`r'=w111_`r'+w112_`r'
egen w211_`r'=rowmean(w3_`r'_* w4_`r'_*)
egen w212_`r'=rowmean(w4_`r'_*)
ge w21_`r'=w211_`r'+w212_`r'
ge wtotal_`r'=w11_`r'+w21_`r'
}
.
matrix SS=J(57,3,.)
local i=1
local r w11_1998 w21_1998 wtotal_1998 w11_1999 w21_1999 wtotal_1999 w11_2000 w21_2000 wtotal_2000 ///
w11_2001 w21_2001 wtotal_2001 w11_2002 w21_2002 wtotal_2002 w11_2003 w21_2003 wtotal_2003 w11_2004 w21_2004 wtotal_2004 w11_2005 w21_2005 wtotal_2005 ///
w11_2006 w21_2006 wtotal_2006 w11_2007 w21_2007 wtotal_2007 w11_2007 w21_2007 wtotal_2007 w11_2008 w21_2008 wtotal_2008 w11_2009 w21_2009 wtotal_2009 ///
w11_2010 w21_2010 wtotal_2010 w11_2011 w21_2011 wtotal_2011 w11_2012 w21_2012 wtotal_2012 w11_2013 w21_2013 wtotal_2013 w11_2014 w21_2014 wtotal_2014 ///
w11_2015 w21_2015 wtotal_2015
foreach j in `r' {

          qui sum `j'
          qui mat SS[`i',1]=r(mean)'
		  qui mat SS[`i',2]=r(sd)'
		  qui mat SS[`i',3]=r(N)'
          
		  local i=`i'+1
		  }
		  .
		  
     mat colnames SS=Mean SD Observations
	 mat rownames SS=`r' 
outtable using wages_1,mat(SS) replace
putexcel set wage_1,replace
putexcel A1="Variables"
putexcel B1="Mean"
putexcel C1="SD" 
putexcel D1="Observations"
putexcel A2 = matrix(SS), rownames
********************************************************************************
********************************************************************************


