#!/bin/bash
# Made by:
# Gustavo Magallanes-Guijón <gustavo.magallanes.guijon@ciencias.unam.mx>
# Instituto de Astronomia UNAM
# Ciudad Universitaria
# Ciudad de Mexico
# Mexico
n=1
nmax=267301
while (( n < nmax ))
do
#Lectura del tiempo del satelite y conversión a días julianos modificados
fold -80 particular/sagA_particular_$n.fits | more | grep -a 'TSTART  =' > archivo0.dat
sed '2d' archivo0.dat > archivo1.dat
sed '2d' archivo1.dat > archivo2.dat
sed 's/TSTART  =           //g' archivo2.dat > archivo3.dat
sed 's/ [/] mission time of the start of the observation//g' archivo3.dat > archivo.dat
ts=$(cat archivo.dat)
mjd=$(echo "$ts * 0.00001157407407407407 + 51909.99998842814916530681" | bc -l)
#Lectura y limpieza de parametros espectrales de LAT
F=$(less bitacoras/sagA_bitacora_"$n".log | grep -A 8 sagA | grep Flux)
echo "$mjd	$F" >> cont1.dat
sed -e s/Flux://g -e s/Index://g -e s/s//g -e s/photon//g -e s/cm^2//g -e s/-//g  cont1.dat >conteo1.dat
sed 's/+/	/g' conteo1.dat > con.dat
sed 's/[/]//g' con.dat > conteo1a.dat
sed 's/e/e-/g' conteo1a.dat > sagA.dat
((n += 1))
done
rm con.dat cont1.dat conteo1.dat archivo0.dat archivo1.dat archivo2.dat archivo3.dat conteo1a.dat archivo.dat 
exit 0
