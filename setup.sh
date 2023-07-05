#!/bin/bash

installDeps () {
  sudo apt-get update
  sudo apt-get install -y python3 python3-pip python3-venv build-essential \
    imagemagick xmlstarlet gdal-bin python3-gdal libgdal-dev
  pip install Pipfile
}

# setup_virtual_env () {
#   pip install pipenv
#   pipenv install
#   pipenv run pip install "GDAL<=$(gdal-config --version)"
#   pipenv run pip install --global-option=build_ext --global-option="-I/usr/include/gdal" GDAL==`gdal-config --version`
# }

installDeps
# setup_virtual_env