# agmerra2dssat


This bash script prepares the AgMERRA Global Gridded Climate Forcing Dataset(Ruane et al., 2015) for input to parallel gridded crop model simulation, in portable site-based psims.nc format(Elliott, J., et al., 2014) and DSSAT(*.WTH) format. 

-> You can download the global AgMERRA dataset from (http://data.giss.nasa.gov/impacts/agmipcf/agmerra/)

 Dependencies
 
     1) NetCDF4: The Network Common Data Form -> http://www.unidata.ucar.edu/software/netcdf                  
                                                                                                                   
     2) CDO: Climate Data Operators -> http://code.zmaw.de/projects/cdo                                           
                                                                                                                   
    3) R: A Language and Environment for Statistical Computing ->  http://www.r-project.org/                       
            Required packages ->  3.1)ncdf4: Interface to Unidata netCDF Version 4 or Earlier                     
                                  3.2)chron: Chronological objects which can handle dates and times                                                         									     
      4) HDF5 library(optional): This is needed to import CM-SAF [CM-SAF] HDF5 files with the CDO operator        
          -> http://www.hdfgroup.org/HDF5                                                                          
                                                
            
            
How to Run

Step 1) Download all AgMERRA datasets and put in a folder named AgMERRA  

Step 2) Put this bash script in to the AgMERRA folder [agmerra2psims.sh]                                                                                                                                                    
Step 3) Open the The Linux Terminal(Make sure the command line terminal is a bash shall)                       
                                                                                                                 
Step 4) Navigate to the AgMERRA folder where the bash script located  

Step 5) Make the bash script executable: -> chmod 777 agmerra2psims.sh    
                                                                                                                 
Step 6) Execute the bash script: -> ./agmerra2psims.sh  

At this point the script will promote you to enter a domain name and a longitude/latitude box of your prefered domain
    -> You can enter any desired string for your Domain name
    -> The domain parameters you are going to enter are: lon1 lon2 lat1 lat2           
               -> lon1 = Western longitude 
               -> lon2 = Eastern longitude     
               -> lat1 = Southern or northern latitude                
               -> lat2 = Northern or southern latitude
               
The script also promote you to remap the data to different horizontal resolution, There are 5 options included in this script to interpolate horizontal fields to a new grid:                                                                      
                                                                                                                       
    1) remapdis: Distance-weighted average remapping: Performs a distance-weighted average remapping of the four nearest   	   
    2) remapnn:  Nearest neighbor remapping: Performs a nearest neighbor remapping on all input fields                   
    3) remapcon: First order conservative remapping: Performs a first order conservative remapping on all input fields   
    4) remapcon2: Second order conservative remapping: Performs a second order conservative remapping on all input fields  
    5) remaplaf: Largest area fraction remapping: Performs a largest area fraction remapping on all input fields 
    
    
Robel Takele, 
Assistant Researcher, 
Climate & Geospatial Research,
Ethiopian Institute of Agricultural Research ,
E-mail: takelerobel@gmail.com, 
Mobile Phone: +251913623066 

               




