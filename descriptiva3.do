*Ingreso estudiante
preserve
local prefix_labor w1 w2
local prefix_capital w3 w4
foreach j in student{
forv r=1998/2015 { 
foreach x in `prefix_labor' {
 ge labor`x'_`r'_`j'=`x'_`r'_`j'

} 
foreach x in  `prefix_capital' {
 ge capital`x'_`r'_`j'=`x'_`r'_`j'

} 
 egen w11_`r'=rowtotal(labor*_`r'_`j') 
 egen w21_`r'=rowtotal(capital*_`r'_`j') 
 ge wtotal_`r'_student=w11_`r'+w21_`r'
}
}
.
matrix SS=J(57,3,.)
local i=1
local f w11_1998 w21_1998 wtotal_1998 w11_1999 w21_1999 wtotal_1999 w11_2000 w21_2000 wtotal_2000 ///
w11_2001 w21_2001 wtotal_2001 w11_2002 w21_2002 wtotal_2002 w11_2003 w21_2003 wtotal_2003 w11_2004 w21_2004 wtotal_2004 w11_2005 w21_2005 wtotal_2005 ///
w11_2006 w21_2006 wtotal_2006 w11_2007 w21_2007 wtotal_2007 w11_2007 w21_2007 wtotal_2007 w11_2008 w21_2008 wtotal_2008 w11_2009 w21_2009 wtotal_2009 ///
w11_2010 w21_2010 wtotal_2010 w11_2011 w21_2011 wtotal_2011 w11_2012 w21_2012 wtotal_2012 w11_2013 w21_2013 wtotal_2013 w11_2014 w21_2014 wtotal_2014 ///
w11_2015 w21_2015 wtotal_2015
foreach j in `f' {

          qui sum `j'
          qui mat SS[`i',1]=r(mean)'
		  qui mat SS[`i',2]=r(sd)'
		  qui mat SS[`i',3]=r(N)'
          
		  local i=`i'+1
		  }
		  .
		  
     mat colnames SS=Mean SD Observations
	 mat rownames SS=`f' 
putexcel set "$results/wage1.xlsx",replace
putexcel A1=("Variables Student")
putexcel B1=("Mean-Raw data")
putexcel C1=("SD-Raw data")
putexcel D1=("Observations-Raw data")
putexcel A2 = matrix(SS), rownames
putexcel E1=("Mean-Raw data")
putexcel F1=("SD-Raw data")
putexcel G1=("Observations-Raw data")
putexcel E2 = matrix(SS)
restore
preserve

forv r=1998/2015 { 
ge w11_`r'=av_income_family_labor_`r'
ge w21_`r'=av_income_family_capital_`r' 
ge wtotal_`r'=w11_`r'+w21_`r'
}

.
matrix SS=J(57,3,.)
local i=1
local f w11_1998 w21_1998 wtotal_1998 w11_1999 w21_1999 wtotal_1999 w11_2000 w21_2000 wtotal_2000 ///
w11_2001 w21_2001 wtotal_2001 w11_2002 w21_2002 wtotal_2002 w11_2003 w21_2003 wtotal_2003 w11_2004 w21_2004 wtotal_2004 w11_2005 w21_2005 wtotal_2005 ///
w11_2006 w21_2006 wtotal_2006 w11_2007 w21_2007 wtotal_2007 w11_2007 w21_2007 wtotal_2007 w11_2008 w21_2008 wtotal_2008 w11_2009 w21_2009 wtotal_2009 ///
w11_2010 w21_2010 wtotal_2010 w11_2011 w21_2011 wtotal_2011 w11_2012 w21_2012 wtotal_2012 w11_2013 w21_2013 wtotal_2013 w11_2014 w21_2014 wtotal_2014 ///
w11_2015 w21_2015 wtotal_2015
foreach j in `f' {

          qui sum `j'
          qui mat SS[`i',1]=r(mean)'
		  qui mat SS[`i',2]=r(sd)'
		  qui mat SS[`i',3]=r(N)'
          
		  local i=`i'+1
		  }
		  .
		  
     mat colnames SS=Mean SD Observations
	 mat rownames SS=`f' 
putexcel set "$results/wage2.xlsx",replace
putexcel A1=("Variables Family")
putexcel B1=("Mean-Raw data")
putexcel C1=("SD-Raw data" )
putexcel D1=("Observations-Raw data")
putexcel A2 = matrix(SS), rownames
putexcel E1=("Mean-Raw data")
putexcel F1=("SD-Raw data" )
putexcel G1=("Observations-Raw data")
putexcel E2 = matrix(SS) 
restore
