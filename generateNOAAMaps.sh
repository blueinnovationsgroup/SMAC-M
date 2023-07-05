#!/bin/bash

SRC_DIR=${1:-../ENC_ROOT}
SHP_DEST=${2:-../shp}
MAP_DEST=${3:-../map}

setup_env () {
  echo 'PATH="$HOME/.local/bin/:$PATH"' >>~/.bashrc
  export S57_PROFILE
  export OGR_S57_OPTIONS=SPLIT_MULTIPOINT=ON,ADD_SOUNDG_DEPTH=ON,RECODE_BY_DSSI=ON
  export LC_ALL=C.UTF-8
  export LANG=C.UTF-8
  export QUIET=true
}

init_output_dirs () {
  rm -rf $SHP_DEST/* 2> /dev/null
  rm -rf $MAP_DEST/* 2> /dev/null
  mkdir -p $SHP_DEST/
  mkdir -p $MAP_DEST
  for i in {1..5}; do
    mkdir -p $SHP_DEST/$i;
  done
}

setup_env
init_output_dirs
./chart-installation/data_files_conversion/shp_s57data/generateShapefile.sh $SRC_DIR $SHP_DIR
#pipenv run 
# python3 ./bin/generate_shapefiles.py ./noaa/config.enc.noaa.toml

# Generate .shp files and .map files
# cd ./noaa 


# pipenv run python3 ../chart-installation/generate_map_files/generate_map_config.py config.enc.noaa.toml