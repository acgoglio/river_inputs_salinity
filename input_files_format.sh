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
FLAG_RIVER="EBRO" # Choose PO, EBRO or RHONE river
IN_DIR="/work/oda/med_dev/river_inputs_salinity/dati_ADiL/${FLAG_RIVER}"
OUT_DIR="/work/oda/med_dev/river_inputs_salinity/formatted_EBM/"
FLAG_EFAS_OR_EBM="EBM"
##############
if [[ $FLAG_RIVER == "PO" ]] || [[ $FLAG_RIVER == "RHONE" ]]; then
   FILES_STRING="$IN_DIR/*.txt"
elif [[ $FLAG_RIVER == "EBRO" ]]; then
   FILES_STRING="$IN_DIR/ALL*.txt"
fi

# Po and Rhone
#for INFILE in $(ls $IN_DIR/*.txt); do
# Ebro
#for INFILE in $(ls $IN_DIR/ALL*.txt); do

for INFILE in $(ls $FILES_STRING ); do
   echo "I am working on file: $INFILE"
   # Po and Rhone
   if [[ $FLAG_RIVER == "PO" ]] || [[ $FLAG_RIVER == "RHONE" ]]; then
      RIVER_PREINNAME=$( echo $INFILE | cut -f 8 -d"/" | cut -f 1 -d"_" )
      echo "RIVER_PREINNAME=$RIVER_PREINNAME"
   # Ebro:
   elif [[ $FLAG_RIVER == "EBRO" ]]; then
      RIVER_PREINNAME=$( echo $INFILE | cut -f 8 -d"/" | cut -f 1 -d"_" )
      echo "$RIVER_PREINNAME"
   fi

   if [[ $RIVER_PREINNAME == 'PO' ]]; then
      OUTPRENAME='Po'
   elif [[ $RIVER_PREINNAME == 'RHONE' ]]; then
      OUTPRENAME='Rhone'
   elif [[ $RIVER_PREINNAME == 'ALLEBRO' ]]; then
      OUTPRENAME='Ebro'
   fi
   
   if [[ $RIVER_PREINNAME == 'PO' ]] || [[ $RIVER_PREINNAME == 'RHONE' ]] ; then
      RIVER_POSTINNAME=$( echo $INFILE | cut -f 6 -d"_" )
      OUT_FILE_NAME="${OUTPRENAME}${RIVER_POSTINNAME}.txt"
      OUT_FILE_NAME_LOW=$( echo $OUT_FILE_NAME | awk '{print tolower($0)}')
      echo "Outfile: $OUT_FILE_NAME_LOW"
      echo "" > ${OUT_DIR}/${OUT_FILE_NAME_LOW}
      while read LINE; do 
        if [[ ${LINE:0:1} != '#' ]]; then
         DAY=$( echo $LINE | cut -f 1 -d"/" ) 
         MONTH=$( echo $LINE | cut -f 2 -d"/" ) 
         YEAR=20$( echo $LINE | cut -f 3 -d"/" | cut -f 1 -d" ") 
         if [[ $FLAG_EFAS_OR_EBM == 'EFAS' ]]; then
            RUNOFF=$( echo $LINE | cut -f 2 -d" " ) 
         elif [[ $FLAG_EFAS_OR_EBM == 'EBM' ]]; then
            RUNOFF=$( echo $LINE | cut -f 4 -d" " )
         fi
         SALINITY=$( echo $LINE | cut -f 6 -d" " )
         echo $YEAR-$MONTH-$DAY $RUNOFF $SALINITY >> ${OUT_DIR}/${OUT_FILE_NAME_LOW}
         echo $YEAR-$MONTH-$DAY $RUNOFF $SALINITY 
        fi
      done < $INFILE
   elif [[ $RIVER_PREINNAME == 'ALLEBRO' ]]; then
      OUT_FILE_NAME="${OUTPRENAME}.txt"
      OUT_FILE_NAME_LOW=$( echo $OUT_FILE_NAME | awk '{print tolower($0)}')
      echo "Outfile: $OUT_FILE_NAME_LOW"
      echo "" > ${OUT_DIR}/${OUT_FILE_NAME_LOW}
      while read LINE; do
        if [[ ${LINE:0:1} != '#' ]]; then
         DAY=$( echo $LINE | cut -f 1 -d"/" )
         MONTH=$( echo $LINE | cut -f 2 -d"/" )
         YEAR=20$( echo $LINE | cut -f 3 -d"/" | cut -f 1 -d" ")
         if [[ $FLAG_EFAS_OR_EBM == 'EFAS' ]]; then
            RUNOFF_1=$( echo $LINE | cut -f 2 -d" " )
            RUNOFF_2=$( echo $LINE | cut -f 11 -d" " )
         elif [[ $FLAG_EFAS_OR_EBM == 'EBM' ]]; then
            RUNOFF_1=$( echo $LINE | cut -f 4 -d" " )
            RUNOFF_2=$( echo $LINE | cut -f 13 -d" " )
         fi
         RUNOFF=$( echo ${RUNOFF_1}+${RUNOFF_2} | bc )
         echo "${RUNOFF_1}+${RUNOFF_2}=$RUNOFF"
         SALINITY=$( echo $LINE | cut -f 6 -d" " )
         echo $YEAR-$MONTH-$DAY $RUNOFF $SALINITY >> ${OUT_DIR}/${OUT_FILE_NAME_LOW}
        fi
      done < $INFILE
   fi
done
