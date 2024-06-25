# imports
import matplotlib.pyplot as plt
import matplotlib as mpl # Palettes
import numpy as np
import netCDF4 as NC
import os
import sys
import warnings
#
warnings.filterwarnings("ignore") # Avoid warnings
mpl.use('Agg')
#
from scipy.optimize import curve_fit
from scipy import stats
import collections
import pandas as pd
import csv
import math
import datetime
from datetime import date, timedelta
from datetime import datetime
from operator import itemgetter
import plotly
from plotly import graph_objects as go # for bar plot
from mpl_toolkits.basemap import Basemap
from matplotlib.colors import LogNorm
from operator import itemgetter # to order lists
from statsmodels.distributions.empirical_distribution import ECDF # empirical distribution functions
import re # grep in python
from glob import glob # * and ? in strings in py
#
#
# by AC Goglio (CMCC)
# annachiara.goglio@cmcc.it
#
# Written: 05/2024
# Modified: 10/05/2024
######################################
# INPUTS
workdir='/work/oda/med_dev/river_inputs_salinity/new_river_inputs/'
csv_infofile='/users_home/oda/med_dev/src_dev/river_inputs_salinity/rivers_info_vsal.csv'
daily_rivers=workdir+'runoff_1d_nomask_y2017-2019.nc'
start_year=2017
end_year=2019
#
runoff_var='sorunoff'
pre_runoff_var='clim_daily_runoff'
salinity_var='s_river'
pre_salinity_var='clim_daily_salinity'
lat_idx='y'
lon_idx='x'
time_idx='time_counter'
yeartocompute=str(start_year)+'-'+str(end_year)

######################################
# Validation: check of the outfile
print ('I am going to plot the diagnostic plots to validate the outfile: ',daily_rivers)
# Open the outfile 
output_daily = NC.Dataset(daily_rivers,'r')
oldout=output_daily.variables[pre_runoff_var][:]
newout=output_daily.variables[runoff_var][:]
oldsout=output_daily.variables[pre_salinity_var][:]
newsout=output_daily.variables[salinity_var][:]
# diff
diff=newout-oldout
sdiff=newsout-oldsout

# Build date array
start_date = date(start_year, 1, 1)
end_date = date(end_year+1, 1, 1)-timedelta(days=1)
daterange = pd.date_range(start_date, end_date)
with open(csv_infofile) as infile:
     for line in infile:
       if line[0] != '#':
         river_name=line.split(';')[5]
         river_lat_idx=line.split(';')[0]
         river_lon_idx=line.split(';')[1]
         print ('I am working on ', river_name,river_lat_idx,river_lon_idx)

         # Plot runoff
         plotname=workdir+'efas_'+river_name+'_'+str(yeartocompute)+'.png'
         plt.figure(figsize=(18,12))
         plt.rc('font', size=16)
         #
         plt.subplot(2,1,1)
         plt.title ('Climatological river forcing Vs EFAS river forcing --- River: '+river_name+'--- Year: '+str(yeartocompute))
         plt.plot(daterange,oldout[:,int(river_lat_idx),int(river_lon_idx)],'-o',label = 'Clim river forcing (AVG='+str(np.round(np.nanmean(oldout[:,int(river_lat_idx),int(river_lon_idx)]),3))+' kg/m2/s)')
         plt.plot(daterange,newout[:,int(river_lat_idx),int(river_lon_idx)],'-o',label = 'EFAS river forcing (AVG='+str(np.round(np.nanmean(newout[:,int(river_lat_idx),int(river_lon_idx)]),3))+' kg/m2/s)')
         plt.grid ()
         plt.ylabel ('River runoff [kg/m2/s]')
         plt.xlabel ('Date')
         plt.legend()
         #
         plt.subplot(2,1,2)
         plt.plot(daterange,diff[:,int(river_lat_idx),int(river_lon_idx)],label = 'EFAS-Clim (STD DEV: '+str(np.round(np.std(diff[:,int(river_lat_idx),int(river_lon_idx)]),5))+')')
         plt.grid ()
         plt.ylabel ('River runoff difference [kg/m2/s]')
         plt.xlabel ('Date')
         plt.legend()
         # Save and close 
         plt.savefig(plotname)
         plt.clf()

         # Plot salinity
         plotname=workdir+'efas_'+river_name+'_'+str(yeartocompute)+'_salinity.png'
         plt.figure(figsize=(18,12))
         plt.rc('font', size=16)
         #
         plt.subplot(2,1,1)
         plt.title ('Climatological river forcing Vs EFAS river forcing --- River: '+river_name+'--- Year: '+str(yeartocompute))
         plt.plot(daterange,oldsout[:,int(river_lat_idx),int(river_lon_idx)],'-o',label = 'Clim river forcing (AVG='+str(np.round(np.nanmean(oldsout[:,int(river_lat_idx),int(river_lon_idx)]),3))+' PSU)')
         plt.plot(daterange,newsout[:,int(river_lat_idx),int(river_lon_idx)],'-o',label = 'EFAS river forcing (AVG='+str(np.round(np.nanmean(newsout[:,int(river_lat_idx),int(river_lon_idx)]),3))+' PSU)')
         plt.grid ()
         plt.ylabel ('River salinity [PSU]')
         plt.xlabel ('Date')
         plt.legend()
         #
         plt.subplot(2,1,2)
         plt.plot(daterange,sdiff[:,int(river_lat_idx),int(river_lon_idx)],label = 'EFAS-Clim (STD DEV: '+str(np.round(np.std(sdiff[:,int(river_lat_idx),int(river_lon_idx)]),5))+')')
         plt.grid ()
         plt.ylabel ('River salinity difference [PSU]')
         plt.xlabel ('Date')
         plt.legend()
         # Save and close 
         plt.savefig(plotname)
         plt.clf()

# Close the outfile
output_daily.close()
