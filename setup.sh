#!/bin/bash

apt update
apt install -y python3 python3-pip python3-venv build-essential wget \
  imagemagick xmlstarlet gdal-bin python3-gdal libgdal-dev
pip install Pipfile
pip install wand
