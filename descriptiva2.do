local charac sexo egreso   year_na  pareja  trabaja region  ///
comuna socu_pa   socu_ma pcoh esc_pa esc_ma paa_2 paa_1 paa_3 pce_2 pce_1 pce_3 pce_4 ///         
pce_5 notas depe  type_school  type_educ    jornada edp1 edp2 edp3 edm1 edm2 edm3 ///
age_paa age_paa2 madurez  paa_av 
matrix SS1=J(35,3,.)
local i=1
foreach x in `charac'  {

          qui sum `x'
          qui mat SS1[`i',1]=r(mean)'
		  qui mat SS1[`i',2]=r(sd)'
		  qui mat SS1[`i',3]=r(N)'
          
		  local i=`i'+1
		  }
		  .
		 
     mat colnames SS1=Mean SD Observations

putexcel E1=("Mean Final Data")
putexcel F1=("SD Final Data" )
putexcel G1=("Observations Final Data")
putexcel E2 = matrix(SS1)
