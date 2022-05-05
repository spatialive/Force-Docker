#!/bin/bash

#    __________  ____  ____________   _____   ________________    __    __    __
#   / ____/ __ \/ __ \/ ____/ ____/  /  _/ | / / ___/_  __/   |  / /   / /   / /
#  / /_  / / / / /_/ / /   / __/     / //  |/ /\__ \ / / / /| | / /   / /   / / 
# / __/ / /_/ / _, _/ /___/ /___   _/ // /|  /___/ // / / ___ |/ /___/ /___/_/  
#/_/    \____/_/ |_|\____/_____/  /___/_/ |_//____//_/ /_/  |_/_____/_____(_)   
#        

if ! command -v apt-get &> /dev/null
then
    clear
    echo "This script was based on distributions like Debian or derivatives!"
    echo "Your distribution not like debian"
    sleep 3
    exit
fi

INSTALL_DIR="/opt/install/src"
export DEBIAN_FRONTEND=noninteractive 

# Install libraries
apt-get update && apt-get -y install \
    software-properties-common \
    wget \
    unzip \
    curl \
    git \
    vim \
    build-essential \
    libgdal-dev \
    gdal-bin \
    python3-gdal \
    libarmadillo-dev \
    libfltk1.3-dev \
    libgsl0-dev \
    lockfile-progs \
    rename \
    parallel \
    apt-utils \
    cmake \
    make \
    figlet \
    libgtk2.0-dev \
    pkg-config \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    python3-pip \
    pandoc \
    r-base \
    r-base-dev

# Set python aliases for Python 3.x
echo 'alias python=python3' >> ~/.bashrc \
    && echo 'alias pip=pip3' >> ~/.bashrc \
    && . ~/.bashrc 

# NumPy is needed for OpenCV, gsutil for Google downloads
pip3 install --no-cache-dir --upgrade pip && \
pip3 install --no-cache-dir numpy==1.18.1 gsutil scipy==1.6.0 

# Install R packages
Rscript -e 'install.packages("rmarkdown", repos="https://cloud.r-project.org")' && \
Rscript -e 'install.packages("plotly",    repos="https://cloud.r-project.org")' && \
Rscript -e 'install.packages("stringi",   repos="https://cloud.r-project.org")' && \
Rscript -e 'install.packages("knitr",     repos="https://cloud.r-project.org")' && \
Rscript -e 'install.packages("dplyr",     repos="https://cloud.r-project.org")' && \
Rscript -e 'install.packages("raster",    repos="https://cloud.r-project.org")' && \
Rscript -e 'install.packages("sp",        repos="https://cloud.r-project.org")' && \
Rscript -e 'install.packages("rgdal",     repos="https://cloud.r-project.org")' 

# Clear installation data
apt-get clean && rm -r /var/cache/

figlet -f slant "FORCE INSTALL!" | sed -n 's/^.*/#&/p'
sleep 3

# Build OpenCV from source
mkdir -p $INSTALL_DIR/opencv && cd $INSTALL_DIR/opencv && \
wget https://github.com/opencv/opencv/archive/4.1.0.zip \
    && unzip 4.1.0.zip && \
mkdir -p $INSTALL_DIR/opencv/opencv-4.1.0/build && \
cd $INSTALL_DIR/opencv/opencv-4.1.0/build && \
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. \
    && make -j24 \
    && make install \
    && make clean 

# Build SPLITS from source
mkdir -p $INSTALL_DIR/splits && \
cd $INSTALL_DIR/splits && \
wget http://sebastian-mader.net/wp-content/uploads/2017/11/splits-1.9.tar.gz && \
tar -xzf splits-1.9.tar.gz && \
cd $INSTALL_DIR/splits/splits-1.9 && \
./configure CPPFLAGS="-I /usr/include/gdal" CXXFLAGS=-fpermissive \
    && make -j24 \
    && make install \
    && make clean 

# Build FORCE from source
mkdir -p /var/cache/apt/archives/partial && \
apt-get autoclean && \
apt-get install --reinstall python3-numpy && \
mkdir -p $INSTALL_DIR/force && \
cd $INSTALL_DIR/force && \
git clone -b master https://github.com/davidfrantz/force.git && \
cd force && \
./splits.sh enable && \
./debug.sh enable && \
make -j24 && \
make install && \
make clean 

# Cleanup after successfull builds
rm -rf $INSTALL_DIR
