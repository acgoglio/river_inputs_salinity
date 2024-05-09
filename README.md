 # To build the new EFAS input files with salinity input_files_format.sh (used just one time!) 
 # For each run:
 # 1) copy the input file in the work dir (it will be modified) 
 cp /data/oda/ag15419/river_inputs/rivers_static/dc/runoff_1d365_nomask.nc /work/oda/med_dev/river_inputs_salinity/new_river_inputs/
 # 2) Load the env
 while read M2L; do if [[ ${M2L:0:1} != "#" ]]; then module load $M2L; fi ; done</users_home/oda/ag15419/tobeloaded.txt
 # 3) rename the salinity field
 ncrename -h -O -v s_river,clim_daily_salinity /work/oda/med_dev/river_inputs_salinity/new_river_inputs/runoff_1d365_nomask.nc
 # 4) run the code to produce the new field
 bsub -q s_short -n 1 -P 0510 -Is python efas_salinity.py
 # 5) rename the outfile to be red by NEMO
 mv /work/oda/med_dev/river_inputs_salinity/new_river_inputs/runoff_1d365_nomask.nc /work/oda/med_dev/river_inputs_salinity/new_river_inputs/runoff_1d_nomask_y2017.nc
