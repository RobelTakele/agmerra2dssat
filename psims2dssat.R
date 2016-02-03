#                              psims2dssat                                     #
################################################################################
#              converts *psims.nc files to *.WTH DSSAT weather files           #
#  Required packages                                                           #
#       1. ncdf4                                                               #
#       2. chron                                                               #
#                                                                              #
#******************************************************************************#
#                                                                              #                                        
#***************************  Robel Takele ********************#***************#
#***********************  Assistant Researcher ********************************#
#******************** Climate & Geospatial Research ***************************#
#*************** Ethiopian Institute of Agricultural Research *****************#
#************************ E-mail: takelerobel@gmail.com ***********************#
#************************* Mobile Phone: +251913623066 ************************#
#******************************** January 29, 2016 ****************************# 
#                                                                              #                                                                                                                                                                             
################################################################################

# setwd("/root/Documents/DSSATinput/climate/workDIR/agmerra")

 #source(/psims2dssat.R)

###############################################################################

# Loading required librarys

rm(list=ls())

library("ncdf4")
library("chron")

####################################################################

# To load *.nc files, getting variables and attributes

year <- scan(file = "year", what=list(""))
yr <- as.character(year)
y<- paste0(yr,".nc")
climData = nc_open(y)

lon = ncvar_get(climData,"lon")
lat = ncvar_get(climData,"lat")
timearr= ncvar_get(climData,"time")

prate = ncvar_get(climData,"prate")
tmax = ncvar_get(climData,"tmax")
tmin = ncvar_get(climData,"tmin")
srad = ncvar_get(climData,"srad")

wxcode <- scan(file = "WxCode", what=list(""))
en <- scan(file = "ExN", what=list(""))

######################################################################

# prepares DSSAT date sequence

timlen <- dim(timearr)

d1 <- 1:9
d2 <- 10:99
d3 <- 100:timlen

n1=paste0("00",d1)
n2=paste0("0",d2)
n3=as.character(d3)
n1<- as.array(n1)
n2<- as.array(n2)
n3<- as.array(n3)
cat(n1,n2,n3, file="doy",sep="",fill = 3)
doy<- readLines("doy")
yyn <- substr(yr, 3, 4)

yydoy=paste0(yyn,doy, sep="")

##############################################################################

# Writing DSSAT wheather files
filename=paste0(wxcode,yyn,en,".WTH")

sink(file=paste0(filename),append=T,type="output")

cat(paste("*WEATHER DATA :"),paste(wxcode)) # Writing header 
cat("\n")
cat("\n")
cat(c("@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT"))
cat("\n")
cat(sprintf("%6s %8.3f %8.3f %5.0f %5.1f %5.2f %5.2f %5.2f",wxcode, lat, lon, -99.0,-99.0, -99.0, -99.0,-99.0))
cat("\n")
cat(c('@DATE  SRAD  TMAX  TMIN  RAIN  DEWP  WIND   PAR  EVAP  RHUM'))
cat("\n")
cat(cbind(sprintf("%5s %5.1f %5.1f %5.1f %5.1f",yydoy,srad,tmax,tmin,prate)),sep="\n")

sink()

##################################################################################
