#!/bin/bash
#
# by AC Goglio (CMCC)
# annachiara.goglio@cmcc.it
#
# Written: 09/05/2024
#
#set -u
set -e
#set -x 
##############
IN_DIR="/work/oda/med_dev/river_inputs_salinity/*/"
OUT_DIR="/work/oda/med_dev/river_inputs_salinity/formatted/"
##############
for INFILE in $(ls $IN_DIR/*.txt); do
   echo "I am working on file: $INFILE"
   RIVER_PREINNAME=$( echo $INFILE | cut -f 6 -d"/" | cut -f 1 -d"_" )
   if [[ $RIVER_PREINNAME == 'PO' ]]; then
      OUTPRENAME='Po'
   elif [[ $RIVER_PREINNAME == 'RHONE' ]]; then
      OUTPRENAME='Rhone'
   fi
   RIVER_POSTINNAME=$( echo $INFILE | cut -f 5 -d"_" )
   OUT_FILE_NAME="${OUTPRENAME}${RIVER_POSTINNAME}.txt"
   OUT_FILE_NAME_LOW=$( echo $OUT_FILE_NAME | awk '{print tolower($0)}')
   echo "Outfile: $OUT_FILE_NAME_LOW"
   echo "" > ${OUT_DIR}/${OUT_FILE_NAME_LOW}
   while read LINE; do 
     if [[ ${LINE:0:1} != '#' ]]; then
      DAY=$( echo $LINE | cut -f 1 -d"/" ) 
      MONTH=$( echo $LINE | cut -f 2 -d"/" ) 
      YEAR=20$( echo $LINE | cut -f 3 -d"/" | cut -f 1 -d" ") 
      RUNOFF=$( echo $LINE | cut -f 2 -d" " ) 
      SALINITY=$( echo $LINE | cut -f 6 -d" " )
      echo $YEAR-$MONTH-$DAY $RUNOFF $SALINITY >> ${OUT_DIR}/${OUT_FILE_NAME_LOW}
     fi
   done < $INFILE
done
