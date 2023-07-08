#!/bin/bash
# Description
# Uses OGR utilities to converts S57 files into .shp files
#
# Original repo: https://github.com/LarsSchy/SMAC-M

set -e

ENCDIR=$1 # where to find ENC s57 source files
SHPDIR=$2 # where to save sqlite database

get_s57data () {
  wget https://raw.githubusercontent.com/OpenCPN/OpenCPN/master/data/s57data/s57objectclasses.csv -O s57objectclasses.csv $WGET_QUIET
  wget https://raw.githubusercontent.com/OpenCPN/OpenCPN/master/data/s57data/s57attributes.csv -O s57attributes.csv $WGET_QUIET
}

lookup_layer_type () {
  type=$1
  # We will use the type definition proposed by OpenCPN to extract only data mapped by lookup table 
  # Because all datatypes are stored in the S-57 source file, we need to add where clause
  # to filter properly data in the ogr2ogr command line.
  if [ "$type" = "POINT" ]; then
      where="-where PRIM=1"
  elif [ "$type" = "LINESTRING" ]; then
      where="-where PRIM=2"
  elif [ "$type" = "POLYGON" ]; then
      where="-where PRIM=3"
  fi
  echo $where
}

append_layer () {
  LAYER=$1
  _FILE=$2
  usage=$3
  LAYERTYPES=$(dirname "$0")/objlist.txt
  geometry_types=$(grep "^$layer," $LAYERTYPES | awk -F',' '{print $2}')
  for type in $geometry_types; do
    where=$(lookup_layer_type $type)
    
    # We will process only if feature object exist in source S-57 file.
    lnr=$(ogrinfo -ro $where $_FILE "$layer" | awk '/Feature Count: /{if ($3 > 0) print "'"$layer"'"}' | awk -F: '{print $1}')
    
    # Now we can loop ...
    if [[ "$lnr" != "" ]]
    then
        # name is case sensitive for mapping purpose and SQlite doesnt support case sensitive
        ## We need to test with regex it and add '_lcase_' in table name for lcase s-57 objectclasse 
        if ! [[ "$layer" =~ [^a-z_] ]]; then
            output_shp=${SHPDIR}/${usage}/CL${usage}_${layer}_lcase_${type}.shp
        else
            output_shp=${SHPDIR}/${usage}/CL${usage}_${layer}_${type}.shp
        fi
                    
        ogr2ogr -append -skipfailures -f "ESRI Shapefile" $output_shp $where $_FILE $layer >> /tmp/errors 2>&1 
        # TBD: Not sure why "--config S57_PROFILE iw" works on my Ubuntu for WSL but not on Ubuntu 22.04 in a docker containe or native demo machine.
        # ogr2ogr -append -skipfailures -f "ESRI Shapefile" --config S57_PROFILE iw $output_shp $where $_FILE $layer >> /tmp/errors 2>&1 
        
        # add a special dataset to support Lignts signature...
        # if [[ "${layer}" == "LIGHTS" ]]
        # then
        #     cat=CL${usage}_${layer}_${type}

        #     # using cast(${cat}.HEIGHT as numeric(30,5)) -> https://trac.osgeo.org/gdal/ticket/6803
        #     echoon
        #     ogr2ogr -sql "SELECT ${cat}.VALNMR as VALNMR,  ${cat}.LITCHR as LITCHR, ${cat}.SIGGRP as SIGGRP, cast(${cat}.SIGPER as numeric(4,1)) as SIGPER, cast(${cat}.HEIGHT as numeric(30,5))  as HEIGHT, ${cat}.COLOUR as COLOUR, ${cat}.EXCLIT as EXCLIT,litchr_code.Meaning as Meaning,colour_code.Colour_code as Colour_cod FROM '${output_shp}'.${cat} LEFT JOIN 'litchr_code.csv'.litchr_code litchr_code ON ${cat}.LITCHR = litchr_code.ID LEFT JOIN  'colour_code.csv'.colour_code colour_code ON ${cat}.COLOUR = colour_code.ID" ${SHPDIR}/${usage}/CL${usage}_${layer}_${type}_SIGNATURE.shp ${output_shp}
        #     { echooff; } 2>/dev/null
        # fi
    fi
  done
}

convert_s57_file () {
  _FILE=$1
  start=$(date +%s)
  echo Processing $_FILE
  filename=`echo $(basename $_FILE)`
  usage=`echo ${filename:2:1}`
  layers=$(ogrinfo -q $_FILE | cut -d ":" -f2 | cut -d " " -f2)
  for layer in $layers; do
    append_layer $layer $_FILE $usage
  done

  end=$(date +%s)
  echo $(($end - $start)) "seconds"
}

main () {
  S57_FILES=$ENCDIR/**/*.000
  FILES_CNT=$(ls $S57_FILES | wc -l)
  PROCESSED_CNT=0

  for _FILE in $S57_FILES
  do
    convert_s57_file $_FILE
    PROCESSED_CNT=$(($PROCESSED_CNT + 1))
    PROGRESS=$((100*$PROCESSED_CNT / $FILES_CNT))
    echo "Progress ${PROGRESS}%"
  done
}

python3 gen_obj.py
main
python3 convert_labels.py "${SHPDIR}" NATSUR
python3 extract_soundings.py "${SHPDIR}"

# Run script to build light sector shapefiles
# TODO: build a better integration.  Need modification on python script
# for level in {1..5}; do 
#   LIGHTS=${SHPDIR}/${level}/CL${level}_LIGHTS_POINT.shp
#   [ -e $LIGHTS ] && python3 generate_light_sector.py $LIGHTS 3000 || true
# done
