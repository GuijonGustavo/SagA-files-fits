#!/bin/bash
# Made by:
# Gustavo Magallanes-Guijón <gustavo.magallanes.guijon@ciencias.unam.mx>
# Instituto de Astronomia UNAM
# Ciudad Universitaria
# Ciudad de Mexico
# Mexico
t_inc=693114146
n=259201
m=267300
while ((n<=m))
do
    t_fin=$(echo "$t_inc + 60" | bc)
    echo "Comienza gtselect"
    gtselect zmax=90 emin=100 emax=300000 infile=@events.txt outfile=sagA_particular_$n.fits ra=266.416826 dec=-29.007797 rad=15 evclass=128 tmin=$t_inc tmax=$t_fin
    echo "listo sagA_particular_$n.fits"
    echo $t_inc
    echo $t_fin
    echo "Comienza gtmktime"
    if [[ -f sagA_particular_$n.fits ]]; then
    gtmktime scfile=L2212190246455E72E43610_SC00.fits filter="(DATA_QUAL>0)&&(LAT_CONFIG==1)" roicut=yes evfile=sagA_particular_$n.fits outfile=sagA_time_$n.fits
    echo "listo sagA_time_$n.fits"
    fi
    echo "Comienza gtltcube"
    if [[ -f sagA_time_$n.fits ]]; then
    gtltcube evfile=sagA_time_$n.fits scfile=L2212190246455E72E43610_SC00.fits outfile=sagA_cube_$n.fits dcostheta=0.025 binsz=1
    echo "listo sagA_cube_$n.fits"
    fi
    echo "Comienza gtbin"
    if [[ -f sagA_cube_$n.fits ]]; then
    gtbin evfile=sagA_time_$n.fits scfile=L2212190246455E72E43610_SC00.fits outfile=sagA_bin_$n.fits algorithm=CMAP nxpix=120 nypix=120 binsz=0.25 coordsys=CEL xref=266.416826 yref=-29.007797 axisrot=0 proj=AIT
    echo "listo sagA_bin_$n.fits"
    fi
    echo "Comienza gtexpmap"
    if [[ -f sagA_bin_$n.fits ]]; then
    gtexpmap evfile=sagA_time_$n.fits scfile=L2212190246455E72E43610_SC00.fits expcube=sagA_cube_$n.fits outfile=sagA_map_$n.fits irfs=P8R3_SOURCE_V2 srcrad=15 nlong=120 nlat=120 nenergies=20
    echo "listo sagA_map_$n.fits"
    fi
    echo "Comienza gtdiffrsp"
    the_world_is_flat=true
    if [[ -f sagA_map_$n.fits ]]; then
    gtdiffrsp evfile=sagA_time_$n.fits scfile=L2212190246455E72E43610_SC00.fits srcmdl=sagA.xml irfs=P8R3_SOURCE_V2
    the_world_is_flat=false
    echo "listo gtdiffrsp"
    fi
    echo "Comienza gtlike"
    if [[ $the_world_is_flat==false ]]; then
    gtlike irfs=P8R3_SOURCE_V2 expcube=sagA_cube_$n.fits srcmdl=sagA.xml statistic=UNBINNED optimizer=MINUIT evfile=sagA_time_$n.fits scfile=L2212190246455E72E43610_SC00.fits expmap=sagA_map_$n.fits > sagA_bitacora_$n.log
    echo "listo gtlike"
    fi
    echo "Comienza bitacora"
    if [[ -f sagA_bitacora_$n.log ]]; then
    mv sagA_particular_$n.fits particular
    mv sagA_time_$n.fits time
    mv sagA_cube_$n.fits cube
    mv sagA_bin_$n.fits bin
    mv sagA_map_$n.fits map
    mv sagA_bitacora_$n.log bitacoras
    mv counts_spectra.fits counts/counts_spectra_$n.fits
    mv results.dat results/results_$n.dat
    echo "Listo sagA_bitacora_$n.log"
    fi
    ((n+=1))
    ((t_inc=$t_fin + 1))
done
