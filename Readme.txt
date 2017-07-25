
Para replicar:

1. Mantener estructura folders (crear 3)

codes
data
results

2. Copiar datos PAA: paa`x'.dta, para `x'=94-98 al folder "data"


3. Correr los siguientes do-files:

-data_paa: prepara data de paa
-fake_wage: simula salarios
-merge_wage_paa: pega datos psu y salarios
-master_regs: regresiones.

En cada uno de estos do-files, cambiar folders para guardar resultados, etc

Dejar el resto de los do-files en folder "codes" (son llamados dentro de las rutinas principales)