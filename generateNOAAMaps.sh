#!/bin/bash

SRC_DIR=${1:-../ENC_ROOT}
SHP_DIR=${2:-../shp}
MAP_DIR=${3:-../map}

setup_env () {
  echo 'PATH="$HOME/.local/bin/:$PATH"' >>~/.bashrc
  export S57_PROFILE
  export OGR_S57_OPTIONS=SPLIT_MULTIPOINT=ON,ADD_SOUNDG_DEPTH=ON,RECODE_BY_DSSI=ON
  export LC_ALL=C.UTF-8
  export LANG=C.UTF-8
  export QUIET=true
}

init_output_dirs () {
  rm -rf $SHP_DIR/* 2> /dev/null
  rm -rf $MAP_DIR/* 2> /dev/null
  mkdir -p $SHP_DIR/
  mkdir -p $MAP_DIR
  for i in {1..5}; do
    mkdir -p $SHP_DIR/$i;
  done
}

get_s57data () {
  wget https://raw.githubusercontent.com/OpenCPN/OpenCPN/master/data/s57data/s57objectclasses.csv -O s57objectclasses.csv $WGET_QUIET
  wget https://raw.githubusercontent.com/OpenCPN/OpenCPN/master/data/s57data/s57attributes.csv -O s57attributes.csv $WGET_QUIET
  cp s57objectclasses.csv s57attributes.csv ./chart-installation/data_files_conversion/shp_s57data
}

setup_env
init_output_dirs
get_s57data
echo "Generating SHP files..."
python3 ./bin/generate_shapefiles.py ./noaa/config.enc.noaa.toml
echo "Generating MAP files..."
python3 ./chart-installation/generate_map_files/generate_map_config.py ./noaa/config.enc.noaa.toml