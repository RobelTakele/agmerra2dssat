#!/bin/bash 

 
 # Years to run

 firstYear=1980
 lastYear=2011
 rm years

  file=$(ls *.nc| cut -d '.' -f 1) 

   i=$(echo ${firstYear})
 until [ $i = $lastYear ]; do 
       cdo selyear,${i} ${file}.psims.nc ${i}.nc; echo "${i}" >> years
       i=$[ $i + 1 ]
 done 
 
 years=$(cat years)

 ln -s ../../../../WxCode
 ln -s ../../../../ExN
 ln -s ../../../../psims2dssat.R
 rm *.WTH
 
 for y in ${years[@]}; do
     echo "${y}" > year
     R CMD BATCH ./psims2dssat.R
 done
      
