#!/bin/bash  

#######################################################################################################################
#                                                                                                                     #                                                                              
#******************************************* READ ME *****************************************************************#
#                                                                                                                     #                                                                                                                                                                                                                                         #
######################################### agmerra2pisms ###############################################################
#                                                                                                                     #
#     This bash script prepares the AgMERRA Global Gridded Climate Forcing Dataset(Ruane et al., 2015) for input to   #  
#     parallel gridded crop model simulation, in portable site-based psims.nc format(Elliott, J., et al., 2014)       #        
#     and DSSAT(*.WTH) format.                                                                                        #
#                                                                                                                     #
#    -> You can download the global AgMERRA dataset from (http://data.giss.nasa.gov/impacts/agmipcf/agmerra/)         # 
#                                                                                                                     #
#********************************* Dependencies **********************************************************************#                                                              
#                                                                                                                     #
#      1) NetCDF4: The Network Common Data Form -> http://www.unidata.ucar.edu/software/netcdf                        #
#                                                                                                                     #
#      2) CDO: Climate Data Operators -> http://code.zmaw.de/projects/cdo                                             #
#                                                                                                                     #
#      3) R: A Language and Environment for Statistical Computing ->  http://www.r-project.org/                       #
#              Required packages ->  3.1)ncdf4: Interface to Unidata netCDF Version 4 or Earlier                      # 
#                                    3.2)chron: Chronological objects which can handle dates and times                #                                            									     
#                                                                                                                     #
#      4) HDF5 library(optional): This is needed to import CM-SAF [CM-SAF] HDF5 files with the CDO operator           #
#          -> http://www.hdfgroup.org/HDF5                                                                            #
#                                                                                                                     #
#*********************************************************************************************************************# 
#********************************* How to Run(Serial Version)*********************************************************# 
#                                                                                                                     #
#     Step 1) Download all AgMERRA datasets and put in a folder named AgMERRA [prate,tmax,tmin,srad]                  #
#                                                                                                                     #
#     Step 2) Put the bash and R scripts in to the AgMERRA folder [agmerra2dssat.sh & psims2dssat.R]                  #                                                                                                                     #                                                                                                                     
#                                                                                                                     #
#     Step 3) Open the The Linux Terminal(Make sure the command line terminal is a bash shall)                        #
#                                                                                                                     #
#     Step 4) Navigate to the AgMERRA folder where the bash script located                                            #
#                                                                                                                     #
#     Step 5) Make the bash script executable: -> chmod 777 agmerra2dssat.sh                                          #
#                                                                                                                     #
#     Step 6) Execute the bash script: -> ./agmerra2dssat.sh                                                          #
#                                                                                                                     #
#*********************************************************************************************************************#
#                                                                                                                     #
#***************************************  Robel Takele ***************************************************************#
#***********************************  Assistant Researcher ***********************************************************#
#******************************** Climate & Geospatial Research ******************************************************#
#************************** Ethiopian Institute of Agricultural Research *********************************************#
#******************************** E-mail: takelerobel@gmail.com ******************************************************#
#********************************* Mobile Phone: +251913623066 *******************************************************#
#**************************************** January 23, 2016 ***********************************************************# 
#                                                                                                                     #                                                                                                                                           
#######################################################################################################################
##################################### Parallel Version ################################################################
#                                                                                                                     #
#     for parallel run using multiple core single machines or cluster of machines:                                    #
#                -> Requirements                                                                                      #
#                        1) openMPI: Message Passing Library -> http://www.open-mpi.org/software/ompi/v1.4/downloads  #
#                                                                                                                     #                                                                                                                 #
#       Loading modules:                                                                                              #     
#                  -> module load netcdf  [loads the netcdf package]                                                  #
#                  -> module load cdo     [loads the cdo package]                                                     #
#                  -> module load R       [loads the R package]                                                       #
#                  -> module load openMPI [loads the mpi package]                                                     #
#                                                                                                                     #
#       To excute the run:                                                                                            #
#                        mpirun -np 4 ./agmerra2dssat.sh                                                              #                                                          
#                               [Remark: Change the -np 4 argument to the number of processors                        #
#                                        you have on your platform (on my laptop QuadCore I use -np 4)]               #
#                                                                                                                     #
#######################################################################################################################
################################# getting user inputs #################################################################

# Selecting domain parameters (a longitude/latitude box)
# Considered are only those grid cells with the grid center inside the lon/lat box
 
 echo
 echo
 echo  "-----------------------------------------------------------"
 echo  " Selecting Domain (a longitude/latitude box or study area) "
 echo  "-----------------------------------------------------------"
 echo
 echo

 read -n1 -p "Do you want to select domain [Y/N]? " answer
 case $answer in
 Y | y) echo
 echo
 echo
 echo  "-----------------------------------------------------"
 echo  " Selecting Domain: "
 echo  "-----------------------------------------------------"
 echo  "# Warning! considered are only those grid cells     #"    
 echo  "# with the grid center inside the lon/lat box       #" 
 echo  "-----------------------------------------------------"
 echo
 echo
 read -p "Enter your preferred domain name: " DomainName               # reading domain name
    echo     
    echo  "-----------------------------------------------------"
    echo  " Domain name is set to: $DomainName " 
    echo  "-----------------------------------------------------"
    echo
 echo                                                                            # reading domain parameters
 echo  "#****************** READ ME *****************************#"
 echo  "# Notice!                                                #"
 echo  "#   -> Domain parameters: lon1 lon2 lat1 lat2            #"    
 echo  "#   -> lon1=Western longitude, lon2=Eastern longitude    #" 
 echo  "#   -> lat1=Southern or northern latitude                #" 
 echo  "#   -> lat2=Northern or southern latitude                #"
 echo  "#********************************************************#"
 echo
        
    read   -p "Enter domain parameters: " lon1 lon2 lat1 lat2
    echo
    echo  " Domain parameters is set to: $lon1 East to $lon2 East and $lat1 South or North to $lat2 North or South";; 
    
           
 N | n) echo
    DomainName="Global"
    lon1=0.125
    lon2=359.875
    lat1=89.875
    lat2=359.875
    echo
    echo  "-----------------------------------------------------"
    echo  " Continuing with the Global Domain........           " 
    echo  "-----------------------------------------------------"
    echo
 exit;;
 esac

 ##########################################################################################################################
 #	                                                                                                                  #				                                                                                             											
 # Remapping to different horizontal resolution, There are 5 options included in this script                              # 
 # to interpolate horizontal fields to a new grid:                                                                        #
 #                                                                                                                        #
 # 1) remapdis: Distance-weighted average remapping: Performs a distance-weighted average remapping of the four nearest   #					      
 # 2) remapnn:  Nearest neighbor remapping: Performs a nearest neighbor remapping on all input fields                     #
 # 3) remapcon: First order conservative remapping: Performs a first order conservative remapping on all input fields     #
 # 4) remapcon2: Second order conservative remapping: Performs a second order conservative remapping on all input fields  #
 # 5) remaplaf: Largest area fraction remapping: Performs a largest area fraction remapping on all input fields           #
 #                                                                                                                        #
 ##########################################################################################################################

 echo
 echo
 read -n1 -p "Do you want to interpolate horizontal fields to a new grid [Y/N]? " answer
       case $answer in
            Y | y) echo
 echo
 echo
 echo                   " Interpolating horizontal fields to a new grid! "
 echo 
 echo    "------------------------------------------------------------------------------" 
 echo             " Select one of the following options to continue: "  
 echo    "------------------------------------------------------------------------------" 
 echo    " 1. Nearest neighbor remapping [default] " 
 echo    " 2. Distance-weighted average remapping " 
 echo    " 3. First order conservative remapping " 
 echo    " 4. Second order conservative remapping " 
 echo    " 5. Largest area fraction remapping " 
 echo    "------------------------------------------------------------------------------" 

 read -p " Please enter a selection or the default choice [1] will be accepted: " interpolate        
    echo     
    echo "------------------------------------------------------"
    echo " Remapping horizontal fields using: $interpolate .... " 
    echo "------------------------------------------------------" 
    echo

 if [ $interpolate = 1 ]
    then 
    method="remapnn"
 elif [ $interpolate = 2 ]
    then 
    method="remapdis"
 elif [ $interpolate = 3 ]
    then 
    method="remapcon"
 elif [ $interpolate = 4 ]
    then 
    method="remapcon2"
 elif [ $interpolate = 5 ]
    then 
    method="remaplaf"
 fi 

   read  -p "Enter Horizontal Resolution in Degrees: " inc
    echo
    echo      
    echo  "--------------------------------------------------------------"
    echo  " Remapping fields using $method at $inc horizontal resolution " 
    echo  "--------------------------------------------------------------" ;;

 N | n) echo

 interpolate=1 
 inc=0.25  
    echo
    echo  "------------------------------------------------------"       
    echo  " continuing with the original resolution              " 
    echo  "------------------------------------------------------"
    echo
 exit;;
 esac
    echo
    echo
    echo  "*--------------------------------------------------------------*"
    echo  "* File name convention for DSSAT whather files:                *"
    echo  "*       -> IILLYYEN.WTH                                        *" 
    echo  "*            where: II -> Institute Code                       *"
    echo  "*                 LL -> Location Code                          *"
    echo  "*                 YY -> Year of the observation                *"
    echo  "*                 EN -> Number of the experiment in that year  *"            
    echo  "*--------------------------------------------------------------*" 
    echo

  read -n2 -p "Enter Institute Code [II]: " II
    echo
    echo  "------------------------------------------------------"       
    echo  " Institute code is set to: ${II}                      " 
    echo  "------------------------------------------------------"
    echo
    echo

  read -n2 -p "Enter Location Code [LL]: " LL
    echo
    echo  "------------------------------------------------------"       
    echo  " Location code is set to: ${LL}                       " 
    echo  "------------------------------------------------------"
    echo
    echo

  read -n2 -p "Enter number of the experiment [EN]: " EN
    echo
    echo  "------------------------------------------------------"       
    echo  " Number of the experiment is set to: ${EN}            " 
    echo  "------------------------------------------------------"
    echo
    echo 

 echo "${II}${LL}" > WxCode
 echo "${EN}" > ExN

##################################################################################################################
 
 # selecting domain and concatinating to a single file

   
    echo    "--------------------------------------------------"
    echo    " Selecting Domain......                           " 
    echo    "--------------------------------------------------"
    echo

  files=$(ls *.nc4| cut -d '.' -f 1) 

  for file in ${files[@]}; do       

   cdo sellonlatbox,${lon1},${lon2},${lat1},${lat2} ${file}.nc4 ${file}_${DomainName}.nc
  
  done
 # merging time steps into a single file
    echo
    echo    "--------------------------------------------------"
    echo    " Merging time steps.....                          " 
    echo    "--------------------------------------------------"
    echo

   cdo mergetime AgMERRA_*_prate_${DomainName}.nc  AgMERRA_prate_${DomainName}.nc
   cdo mergetime AgMERRA_*_tmax_${DomainName}.nc  AgMERRA_tmax_${DomainName}.nc
   cdo mergetime AgMERRA_*_tmin_${DomainName}.nc  AgMERRA_tmin_${DomainName}.nc
   cdo mergetime AgMERRA_*_srad_${DomainName}.nc  AgMERRA_srad_${DomainName}.nc
 
 # merging variables  in to a single file
    echo
    echo    "--------------------------------------------------"
    echo    " Merging variables.....                           " 
    echo    "--------------------------------------------------"
    echo


  cdo merge AgMERRA_prate_${DomainName}.nc AgMERRA_tmax_${DomainName}.nc AgMERRA_tmin_${DomainName}.nc AgMERRA_srad_${DomainName}.nc  AgMERRA_${DomainName}.nc


  rm AgMERRA_prate_${DomainName}.nc; rm AgMERRA_tmax_${DomainName}.nc  # comment this line, if you don't want 
  rm AgMERRA_tmin_${DomainName}.nc; rm AgMERRA_srad_${DomainName}.nc   # to delete the files  
  rm AgMERRA_*_prate_${DomainName}.nc; rm AgMERRA_*_tmax_${DomainName}.nc; rm AgMERRA_*_tmin_${DomainName}.nc 
  rm AgMERRA_*_srad_${DomainName}.nc

 # getting grid description parameters
 
 cdo griddes2 AgMERRA_${DomainName}.nc > GRID_description
 
 grid2=$(more +14 GRID_description) ; rm grid3

 for grid in ${grid2[@]}; do
 echo "$grid" >> grid3
 done 

  line=$(more +3 grid3) #; more +3 grid3 > line

   i=1
  for l in ${line[@] }; do 
    lon1=$( echo $l ); break
  done
  
  grid4=$(more +3 grid3); more +3 grid3 > grid5
 
  rm xs; test="yvals"

 for gr in ${grid4[@]}; do
     if [[ $gr = $test ]]
        then
        break 
        else
    echo "$gr" >> xs 
    
     fi # if        
 done # for

  line=($(cat xs| wc -w))
  lon2=($(more +${line} xs ))
  latf=$( expr $line + 3)
  lats=($(more +${latf} grid5))
  lat1=$(echo $lats)

  del=$(echo "$lon2 - $lon1" | bc)
  del2=$(echo "$del/$inc" | bc)

  # lonf=$( echo $lon1)
 
  #  i=1
   # until [ $lonf = $lon2 ]; do 
    # lonf=$( echo "$lonf + 0.25" | bc )
    # i=$(expr $i + 1 )
   # done

    gxsize=$( echo " $del2 * $del2" |bc )

 res=$(echo "scale=0 ; $inc * 60/1" | bc  ) # horizontal resolution in arcminites  

# writing the new grid description file 
  echo
  echo    "-----------------------------------------------------------"
  echo    " writig the new grid description file ....                 " 
  echo    "-----------------------------------------------------------"
  echo

 rm newGRIDdescription

 echo "#" >> newGRIDdescription ; echo "# gridID 1" >> newGRIDdescription; echo "#" >> newGRIDdescription
 echo "gridtype  = lonlat" >> newGRIDdescription; echo "gridsize  = ${gxsize}" >> newGRIDdescription
 echo "xname     = longitude" >> newGRIDdescription; echo "xlongname = longitude" >> newGRIDdescription
 echo "xunits    = degrees_east" >> newGRIDdescription; echo "yname     = latitude" >> newGRIDdescription
 echo "ylongname = latitude"  >> newGRIDdescription; echo "yunits    = degrees_north" >> newGRIDdescription
 echo "xsize     = ${del2}" >> newGRIDdescription; echo "ysize     = ${del2}" >>newGRIDdescription; echo "xfirst    = ${lon1}" >> newGRIDdescription
 echo "xinc     = ${inc}" >> newGRIDdescription; echo "yfirst     = ${lat1}" >>newGRIDdescription; echo "yinc     = -${inc}" >> newGRIDdescription
    echo
    echo  "------------------------------------------------------------------------------------"
    echo  " This may take a while!                                                             "
    echo  " Remapping fields using $method at $inc horizontal resolution is in progress....... " 
    echo  "------------------------------------------------------------------------------------"
    echo
 cdo ${method},newGRIDdescription   AgMERRA_${DomainName}.nc AgMERRA.${DomainName}.${res}min.nc 

########################################################################################################################################################

 # Getting grid values and grid index
    echo
    echo  "*******************************************************"
    echo  " Generating grid value files and grid index files!     "
    echo  "*******************************************************"
    echo
  
  rm griddeslatnlon_lst
  cdo griddes2 AgMERRA.${DomainName}.${res}min.nc   > allgriddes
  griddes=$(more +14  allgriddes)
 
 for grid in ${griddes[@]}; do
 echo "$grid" >> griddeslatnlon_lst
 done 

 griddeslatnlon=$(more +3 griddeslatnlon_lst)
 more +3 griddeslatnlon_lst > griddeslatnlon
   
 test="yvals"
 rm lons

 for gridde in ${griddeslatnlon[@]}; do
     if [ $gridde != $test ]
        then
    echo "$gridde" >> lons     
        else
    break
    
     fi # if        
 done # for
 
 lonNumbers=$( cat lons | wc -w ) 
 num=$(expr $lonNumbers + 3)

 more +$num griddeslatnlon > lats

 mv lats gridlats
 mv lons gridlons

 rm griddeslatnlon_lst
 rm allgriddes
 rm griddeslatnlon
 
# getting grid index (dy, dx)

 latsize=$( cat gridlats | wc -w )
 latidy=$(expr $latsize + 1)
 lonsize=$( cat gridlons | wc -w )
 lonidx=$(expr $lonsize + 1)
 
 rm dxs;  rm dys 

 i=1 
 until [ $i -eq $lonidx ]; do 
 echo "$i" >> dxs
 i=$[ $i + 1 ]
 done 

 j=1
 until [ $j -eq $latidy ]; do 
 echo "$j" >> dys
 j=$[ $j + 1 ]
 done 

 mv dxs dxlst
 mv dys dylst


########################################################################################################################
# splitting the data in to single grid/simulation site 								       #
# pSIMS climate input files incorporates metadata about the (row, col)                                                 #
# that denotes a file’s location in the global grid in both the file name and directory structure, i.e.                #
# /agmerra.15min/${dy}/${dx}/${dy}_${dx}.psims.nc, [(Elliott,J.,et al.,2014), 2.The pSIMS climate data input pipeline] #
########################################################################################################################

 echo
 echo "***************************************************************"
 echo "* splitting the data in to single grid/simulation site        *" 
 echo "* that denotes a file’s location in the global grid           *"
 echo "* in both the file name and directory structure               *"
 echo "* i.e /agmerra.${inc}.degree/${dy}/${dx}/${dy}_${dx}.psims.nc *"
 echo "***************************************************************"
 echo

 res=$(echo "scale=0 ; $inc * 60/1" | bc  ) # horizontal resolution in arcminites 
 
 mkdir climate; cd climate
 mkdir agmerra.${res}min ; cd agmerra.${res}min

 cp ../../gridlats .
 cp ../../gridlons .
 cp ../../dxlst .
 cp ../../dylst .
 
 gridlats=$(cat gridlats) 
 gridlons=$(cat gridlons)
 dxlst=$(cat dxlst)
 dylst=$(cat dylst)
 
 echo
 echo "------------------------------------------------------------"
 echo "------------------------------------------------------------"
 echo " This may take a while!                                     "
 echo " splitting the data in to single grid..........             "
 echo "------------------------------------------------------------"
 echo "------------------------------------------------------------"
 echo

 for dy in ${dylst[@]}; do 
     mkdir ${dy}; cd ${dy}  
           for dx in ${dxlst[@]}; do
	       mkdir ${dx}; cd ${dx} 
               y=$(expr $dy - 1) 
               line=($(cat ../../gridlons)) 
               lon=$(echo ${line[$y]})
               x=$(expr $dx - 1)
               line=($(cat ../../gridlats)) 
               lat=$(echo ${line[$x]})
               cdo remapnn,lon=${lon}/lat=${lat} ../../../../AgMERRA.${DomainName}.${res}min.nc    ${dy}_${dx}.psims.nc
               ln -s ../../../../setparams.sh;./setparams.sh;  cd .. 
         done; cd .. # for dx
 done; cd .. # for dy

 echo
 echo "************************************************************"
 echo "* splitting the data in to single grid is done!            *"
 echo "* Generating DSSAT *.WTH files is done!                    *"
 echo "************************************************************"
 echo "* Generating new gridlist for ${DomainName} domain         *"      
 echo "************************************************************"
 echo
 echo

 # preparing gridlist file
 
 for dy in ${dylst[@]} ; do
     latid=$(echo ${dy})
        for dx in ${dxlst[@]};do 
            lonid=$(echo ${dx});
            echo "${latid}/${lonid}" >> agmerra.gridlist.${DomainName}.${res}min
        done
  done
 
 echo
 echo "*****************************************************************"
 echo "* Preparing climate input files for pSIMS & DSSAT is DONE!!!    *"
 echo "*                                                               *"
 echo "* you can make a symbolic link to pSIMS root directory          *"
 echo "* using ln -s agmerra.${res}min /..psimsRoot/data/climate/      *"
 echo "*                                                               *"
 echo "* For enquares, questions and suggetions:                       *"
 echo "*              -> Email: takelerobel@gmail.com                  *"
 echo "*              -> Mobile: +251913623066                         *"
 echo "*****************************************************************"
 echo "*                      Thank You!!!                             *"
 echo "*****************************************************************"
 echo
 echo 

  
#*************************************************************************************************************************
##########################################################################################################################
  
        
