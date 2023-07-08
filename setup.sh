#!/bin/bash

add-apt-repository ppa:ubuntugis/ppa
apt update
apt install -y python3 python3-pip python3-venv build-essential wget \
  imagemagick xmlstarlet gdal-bin python3-gdal libgdal-dev python-software-properties
pip install Pipfile
pip install wand
