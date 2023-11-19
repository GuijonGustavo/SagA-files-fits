#!/bin/bash
# Made by:
# Gustavo Magallanes-Guijón <gustavo.magallanes.guijon@ciencias.unam.mx>
# Instituto de Astronomia UNAM
# Ciudad Universitaria
# Ciudad de Mexico
# Mexico

#BEGIN USER

t_start=677560226
t_stop=693112226
cores=32 #CORES. FOR DEFAULT IS 48
bins=1 #BINS. FOR DEFAULT IS 1
src=sagA
sc=L2212190246455E72E43610_SC00.fits
asc=266.416826
decli=-29.007797
radio=15 #RADIUS. FOR DEFAULT IS 15

#END USER

#MAKE DIRS AND GEEK FILE

mkdir particular 
mkdir counts 
mkdir results 
mkdir time 
mkdir cube 
mkdir bin 
mkdir map 
mkdir bitacoras 
touch 'lc_gen.sh'

#CALULATE INTERVALS

t_dif=$(echo "($t_stop - $t_start)/(60 * $bins)" | bc)
t_cociente=$(echo "$t_dif/$cores" | bc)
t_res=$(echo "$t_dif%$cores" | bc)

k=$t_cociente
first=$t_start



#CREATE lc_gen.sh
chmod u+x lc_gen.sh
echo "#!/bin/bash" >> lc_gen.sh
echo "# Made by:" >> lc_gen.sh
echo "# Gustavo Magallanes-Guijón <gustavo.magallanes.guijon@ciencias.unam.mx>" >> lc_gen.sh
echo "# Instituto de Astronomia UNAM" >> lc_gen.sh
echo "# Ciudad Universitaria" >> lc_gen.sh
echo "# Ciudad de Mexico" >> lc_gen.sh
echo "# Mexico" >> lc_gen.sh

echo "n=1" >> lc_gen.sh
echo "nmax=NUM_FILES" >> lc_gen.sh
echo "while (( n < nmax ))" >> lc_gen.sh
echo "do" >> lc_gen.sh
echo "#Lectura del tiempo del satelite y conversión a días julianos modificados" >> lc_gen.sh
echo "fold -80 particular/${src}_particular_\$n.fits | more | grep -a 'TSTART  =' > archivo0.dat" >> lc_gen.sh
echo "sed '2d' archivo0.dat > archivo1.dat" >> lc_gen.sh
echo "sed '2d' archivo1.dat > archivo2.dat" >> lc_gen.sh
echo "sed 's/TSTART  =           //g' archivo2.dat > archivo3.dat" >> lc_gen.sh
echo "sed 's/ [/] mission time of the start of the observation//g' archivo3.dat > archivo.dat" >> lc_gen.sh
echo "ts=\$(cat archivo.dat)" >> lc_gen.sh
echo "mjd=\$(echo \"\$ts * 0.00001157407407407407 + 51909.99998842814916530681\" | bc -l)" >> lc_gen.sh
echo "#Lectura y limpieza de parametros espectrales de LAT" >> lc_gen.sh
echo "F=\$(less bitacoras/${src}_bitacora_\"\$n\".log | grep -A 8 ${src} | grep Flux)" >> lc_gen.sh
echo "echo \"\$mjd	\$F\" >> cont1.dat" >> lc_gen.sh
echo "sed -e s/Flux://g -e s/Index://g -e s/s//g -e s/photon//g -e s/cm^2//g -e s/-//g  cont1.dat >conteo1.dat" >> lc_gen.sh
echo "sed 's/+/	/g' conteo1.dat > con.dat" >> lc_gen.sh
echo "sed 's/[/]//g' con.dat > conteo1a.dat" >> lc_gen.sh
echo "sed 's/e/e-/g' conteo1a.dat > ${src}.dat" >> lc_gen.sh
echo "((n += 1))" >> lc_gen.sh
echo "done" >> lc_gen.sh
echo "rm con.dat cont1.dat conteo1.dat archivo0.dat archivo1.dat archivo2.dat archivo3.dat conteo1a.dat archivo.dat " >> lc_gen.sh
echo "exit 0" >> lc_gen.sh

#CREATE PLOT 

echo "#!/bin/bash" >> $src.plt
echo "# Made by:" >> $src.plt
echo "# Gustavo Magallanes-Guijón <gustavo.magallanes.guijon@ciencias.unam.mx>" >> $src.plt
echo "# Instituto de Astronomia UNAM" >> $src.plt
echo "# Ciudad Universitaria" >>  $src.plt
echo "# Ciudad de Mexico" >>  $src.plt
echo "# Mexico" >> $src.plt


echo "set terminal png size 1280,960" >> $src.plt
echo "set key autotitle columnhead" >> $src.plt
echo "set key" >> $src.plt
echo "set output \"${src}.png\"" >> $src.plt
echo "set title \"Fermi/GAMMA $src\"" >> $src.plt
echo "set xlabel \"MJD\"" >> $src.plt
echo "set x2data time" >> $src.plt
echo "set timefmt \"%Y-%m-%d\"" >> $src.plt
echo "set format x2 \"%Y-%m-%d\"" >> $src.plt
echo "set x2tics" >> $src.plt
echo "set x2range[\"2005-03-01\":\"2020-04-01\"]" >> $src.plt
echo "set ylabel \"Flux (photons/cm^2/s)\"" >> $src.plt
echo "plot '${src}.dat' using 1:2:3 title \"Flux (photons/cm^2/s)\" with yerrorbars lc \"blue\"" >> $src.plt


#CREATE i FILES

j=1
for (( i=1; i<=$cores+1; i++ ))
do
    echo  "./${src}_${i}.sh" >> 'geek'
    touch $src'_'$i.sh
    chmod u+x $src'_'$i.sh
    echo "#!/bin/bash" >> $src'_'$i.sh
    echo "# Made by:" >> $src'_'$i.sh
    echo "# Gustavo Magallanes-Guijón <gustavo.magallanes.guijon@ciencias.unam.mx>" >> $src'_'$i.sh
    echo "# Instituto de Astronomia UNAM" >> $src'_'$i.sh
    echo "# Ciudad Universitaria" >> $src'_'$i.sh
    echo "# Ciudad de Mexico" >> $src'_'$i.sh
    echo "# Mexico" >> $src'_'$i.sh
    
    echo "t_inc=${first}" >> $src'_'$i.sh
    echo "n=$j" >> $src'_'$i.sh
    echo "m=$k" >> $src'_'$i.sh
    echo "while ((n<=m))" >> $src'_'$i.sh
    echo "do" >> $src'_'$i.sh
    
        echo "    t_fin=\$(echo \"\$t_inc + 60\" | bc)" >> $src'_'$i.sh
        echo "    echo \"Comienza gtselect\"" >> $src'_'$i.sh
        echo "    gtselect zmax=90 emin=100 emax=300000 infile=@events.txt outfile=${src}_particular_\$n.fits ra=$asc dec=$decli rad=$radio evclass=128 tmin=\$t_inc tmax=\$t_fin" >> $src'_'$i.sh
        echo "    echo \"listo ${src}_particular_\$n.fits\"" >> $src'_'$i.sh
        echo "    echo \$t_inc" >> $src'_'$i.sh
        echo "    echo \$t_fin" >> $src'_'$i.sh
        echo "    echo \"Comienza gtmktime\"" >> $src'_'$i.sh
        echo "    if [[ -f ${src}_particular_\$n.fits ]]; then" >> $src'_'$i.sh
        echo "    gtmktime scfile=$sc filter=\"(DATA_QUAL>0)&&(LAT_CONFIG==1)\" roicut=yes evfile=${src}_particular_\$n.fits outfile=${src}_time_\$n.fits" >> $src'_'$i.sh
        echo "    echo \"listo ${src}_time_\$n.fits\"" >> $src'_'$i.sh
        echo "    fi" >> $src'_'$i.sh
        echo "    echo \"Comienza gtltcube\"" >> $src'_'$i.sh
        echo "    if [[ -f ${src}_time_\$n.fits ]]; then" >> $src'_'$i.sh
        echo "    gtltcube evfile=${src}_time_\$n.fits scfile=$sc outfile=${src}_cube_\$n.fits dcostheta=0.025 binsz=1" >> $src'_'$i.sh
        echo "    echo \"listo ${src}_cube_\$n.fits\"" >> $src'_'$i.sh
        echo "    fi" >> $src'_'$i.sh
        echo "    echo \"Comienza gtbin\"" >> $src'_'$i.sh
        echo "    if [[ -f ${src}_cube_\$n.fits ]]; then" >> $src'_'$i.sh
        echo "    gtbin evfile=${src}_time_\$n.fits scfile=$sc outfile=${src}_bin_\$n.fits algorithm=CMAP nxpix=120 nypix=120 binsz=0.25 coordsys=CEL xref=$asc yref=$decli axisrot=0 proj=AIT" >> $src'_'$i.sh
        echo "    echo \"listo ${src}_bin_\$n.fits\"" >> $src'_'$i.sh
        echo "    fi" >> $src'_'$i.sh
        echo "    echo \"Comienza gtexpmap\"" >> $src'_'$i.sh
        echo "    if [[ -f ${src}_bin_\$n.fits ]]; then" >> $src'_'$i.sh
        echo "    gtexpmap evfile=${src}_time_\$n.fits scfile=$sc expcube=${src}_cube_\$n.fits outfile=${src}_map_\$n.fits irfs=P8R3_SOURCE_V2 srcrad=$radio nlong=120 nlat=120 nenergies=20" >> $src'_'$i.sh
        echo "    echo \"listo ${src}_map_\$n.fits\"" >> $src'_'$i.sh
        echo "    fi" >> $src'_'$i.sh
        echo "    echo \"Comienza gtdiffrsp\"" >> $src'_'$i.sh
        echo "    the_world_is_flat=true" >> $src'_'$i.sh
        echo "    if [[ -f ${src}_map_\$n.fits ]]; then" >> $src'_'$i.sh
        echo "    gtdiffrsp evfile=${src}_time_\$n.fits scfile=$sc srcmdl=$src.xml irfs=P8R3_SOURCE_V2" >> $src'_'$i.sh
        echo "    the_world_is_flat=false" >> $src'_'$i.sh
        echo "    echo \"listo gtdiffrsp\"" >> $src'_'$i.sh
        echo "    fi" >> $src'_'$i.sh
        echo "    echo \"Comienza gtlike\"" >> $src'_'$i.sh
        echo "    if [[ \$the_world_is_flat==false ]]; then" >> $src'_'$i.sh
        echo "    gtlike irfs=P8R3_SOURCE_V2 expcube=${src}_cube_\$n.fits srcmdl=$src.xml statistic=UNBINNED optimizer=MINUIT evfile=${src}_time_\$n.fits scfile=$sc expmap=${src}_map_\$n.fits > ${src}_bitacora_\$n.log" >> $src'_'$i.sh
        echo "    echo \"listo gtlike\"" >> $src'_'$i.sh
        echo "    fi" >> $src'_'$i.sh
        echo "    echo \"Comienza bitacora\"" >> $src'_'$i.sh
        echo "    if [[ -f ${src}_bitacora_\$n.log ]]; then" >> $src'_'$i.sh
        echo "    mv ${src}_particular_\$n.fits particular" >> $src'_'$i.sh
        echo "    mv ${src}_time_\$n.fits time" >> $src'_'$i.sh
        echo "    mv ${src}_cube_\$n.fits cube" >> $src'_'$i.sh
        echo "    mv ${src}_bin_\$n.fits bin" >> $src'_'$i.sh
        echo "    mv ${src}_map_\$n.fits map" >> $src'_'$i.sh
        echo "    mv ${src}_bitacora_\$n.log bitacoras" >> $src'_'$i.sh
        echo "    mv counts_spectra.fits counts/counts_spectra_\$n.fits" >> $src'_'$i.sh
        echo "    mv results.dat results/results_\$n.dat" >> $src'_'$i.sh
        echo "    echo \"Listo ${src}_bitacora_\$n.log\"" >> $src'_'$i.sh
        echo "    fi" >> $src'_'$i.sh
        echo "    ((n+=1))" >> $src'_'$i.sh
        echo "    ((t_inc=\$t_fin + 1))" >> $src'_'$i.sh
    echo "done" >> $src'_'$i.sh
    
    ((j+=$t_cociente))
    ((k+=$t_cociente))
    ((t_start+=60))
    
    #ADD AN UNIT FOR INTERVALES DON'T FOLDING
    ((first+=(60)*($t_cociente+1)))
    
done
